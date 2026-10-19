//! The smart-contract machine. Contracts are WebAssembly. Every instruction burns gas,
//! so a contract that loops forever just runs out of gas and stops.
//!
//! A contract can also ask another contract a question (a read-only "static call"), the way a
//! security token asks the identity registry whether a buyer has passed KYC. Read-only calls
//! can't change anything, so they can't be used to sneak around the rules of the contract they call.

use crate::types::{Address, Bytes};
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::sync::Arc;
use wasmi::{
    Caller, Config, Engine, Extern, Linker, Memory, Module, Store, StoreLimits, StoreLimitsBuilder,
};

pub type Storage = BTreeMap<Vec<u8>, Vec<u8>>;

/// A contract on the chain. Shared pointers keep snapshots cheap.
#[derive(Clone, Debug, PartialEq)]
pub struct Contract {
    pub code: Arc<Bytes>,
    pub creator: Address,
    pub storage: Arc<Storage>,
}

/// Every contract as it was when the transaction started, for read-only calls.
pub type World = BTreeMap<Address, Contract>;

/// Extra gas for things that cost the network more than a normal instruction.
pub const GAS_STORAGE_WRITE: u64 = 5_000;
pub const GAS_STORAGE_READ: u64 = 500;
pub const GAS_PER_BYTE: u64 = 10;
pub const GAS_TRANSFER: u64 = 2_000;
pub const GAS_EMIT: u64 = 300;
pub const GAS_CALL: u64 = 2_500;
pub const MAX_MEMORY: usize = 16 * 1024 * 1024;
pub const MAX_DEPTH: u32 = 4;

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct Event {
    pub contract: Address,
    pub topic: String,
    pub data: Bytes,
}

/// What the contract can see about the call it is running in.
#[derive(Clone, Debug)]
pub struct CallEnv {
    pub caller: Address,
    pub this: Address,
    /// CTDY sent along with this call.
    pub value: u64,
    /// The contract's balance, already including `value`.
    pub balance: u64,
    pub height: u64,
    pub time: u64,
}

pub struct VmResult {
    pub ok: bool,
    pub gas_used: u64,
    pub output: Vec<u8>,
    pub events: Vec<Event>,
    pub error: Option<String>,
    /// The contract's storage after the call. Only saved if `ok`.
    pub storage: Storage,
    /// Payments the contract made. Only applied if `ok`.
    pub transfers: Vec<(Address, u64)>,
}

struct Host {
    env: CallEnv,
    input: Vec<u8>,
    output: Vec<u8>,
    storage: Storage,
    transfers: Vec<(Address, u64)>,
    events: Vec<Event>,
    limits: StoreLimits,
    world: Arc<World>,
    readonly: bool,
    depth: u32,
    /// What the last read-only call answered.
    last_return: Vec<u8>,
}

fn engine() -> Engine {
    let mut c = Config::default();
    c.consume_fuel(true);
    // No floating point: the same contract must give the exact same answer on every computer.
    c.floats(false);
    Engine::new(&c)
}

/// Checks a contract can be loaded before it is put on the chain.
pub fn validate(code: &[u8]) -> Result<(), String> {
    let engine = engine();
    let module = Module::new(&engine, code).map_err(|e| format!("not valid wasm: {e}"))?;
    if module.get_export("call").is_none() {
        return Err("contract must export a `call` function".into());
    }
    for imp in module.imports() {
        if imp.module() != "env" || !HOST_FUNCS.contains(&imp.name()) {
            return Err(format!(
                "contract imports unknown function {}::{}",
                imp.module(),
                imp.name()
            ));
        }
    }
    Ok(())
}

pub const HOST_FUNCS: &[&str] = &[
    "input_len",
    "input_read",
    "output",
    "storage_len",
    "storage_read",
    "storage_write",
    "storage_delete",
    "caller",
    "self_address",
    "value",
    "balance",
    "transfer",
    "emit",
    "height",
    "time",
    "revert",
    "abort",
    "static_call",
    "return_data",
];

fn mem(c: &Caller<'_, Host>) -> Result<Memory, wasmi::Error> {
    match c.get_export("memory") {
        Some(Extern::Memory(m)) => Ok(m),
        _ => Err(wasmi::Error::new("contract has no memory")),
    }
}

fn read(c: &Caller<'_, Host>, ptr: i32, len: i32) -> Result<Vec<u8>, wasmi::Error> {
    if len < 0 || len as usize > MAX_MEMORY {
        return Err(wasmi::Error::new("bad length"));
    }
    let m = mem(c)?;
    let mut buf = vec![0u8; len as usize];
    m.read(c, ptr as u32 as usize, &mut buf)
        .map_err(|_| wasmi::Error::new("read outside memory"))?;
    Ok(buf)
}

fn write(c: &mut Caller<'_, Host>, ptr: i32, data: &[u8]) -> Result<(), wasmi::Error> {
    let m = mem(c)?;
    m.write(c, ptr as u32 as usize, data)
        .map_err(|_| wasmi::Error::new("write outside memory"))
}

fn charge(c: &mut Caller<'_, Host>, gas: u64) -> Result<(), wasmi::Error> {
    let left = c.get_fuel()?;
    if left < gas {
        c.set_fuel(0)?;
        return Err(wasmi::Error::new("out of gas"));
    }
    c.set_fuel(left - gas)?;
    Ok(())
}

fn no_writes(c: &Caller<'_, Host>) -> Result<(), wasmi::Error> {
    if c.data().readonly {
        return Err(wasmi::Error::new("a read-only call can't change anything"));
    }
    Ok(())
}

/// AssemblyScript keeps text as UTF-16 with the byte length stored just before it.
fn read_as_string(c: &Caller<'_, Host>, ptr: i32) -> String {
    if ptr < 4 {
        return String::new();
    }
    let Ok(len) = read(c, ptr - 4, 4) else {
        return String::new();
    };
    let n = u32::from_le_bytes(len.try_into().unwrap()).min(2048) as i32;
    let Ok(raw) = read(c, ptr, n) else {
        return String::new();
    };
    let units: Vec<u16> = raw
        .chunks(2)
        .filter(|p| p.len() == 2)
        .map(|p| u16::from_le_bytes([p[0], p[1]]))
        .collect();
    String::from_utf16_lossy(&units)
}

fn linker(engine: &Engine) -> Linker<Host> {
    let mut l = Linker::<Host>::new(engine);
    l.func_wrap("env", "input_len", |c: Caller<'_, Host>| -> i32 {
        c.data().input.len() as i32
    })
    .unwrap();
    l.func_wrap(
        "env",
        "input_read",
        |mut c: Caller<'_, Host>, ptr: i32| -> Result<(), wasmi::Error> {
            let input = c.data().input.clone();
            write(&mut c, ptr, &input)
        },
    )
    .unwrap();
    l.func_wrap(
        "env",
        "output",
        |mut c: Caller<'_, Host>, ptr: i32, len: i32| -> Result<(), wasmi::Error> {
            let data = read(&c, ptr, len)?;
            charge(&mut c, data.len() as u64 * GAS_PER_BYTE)?;
            c.data_mut().output = data;
            Ok(())
        },
    )
    .unwrap();
    l.func_wrap(
        "env",
        "storage_len",
        |mut c: Caller<'_, Host>, kp: i32, kl: i32| -> Result<i32, wasmi::Error> {
            charge(&mut c, GAS_STORAGE_READ)?;
            let k = read(&c, kp, kl)?;
            Ok(c.data()
                .storage
                .get(&k)
                .map(|v| v.len() as i32)
                .unwrap_or(-1))
        },
    )
    .unwrap();
    l.func_wrap(
        "env",
        "storage_read",
        |mut c: Caller<'_, Host>, kp: i32, kl: i32, vp: i32| -> Result<i32, wasmi::Error> {
            let k = read(&c, kp, kl)?;
            let Some(v) = c.data().storage.get(&k).cloned() else {
                return Ok(-1);
            };
            charge(&mut c, GAS_STORAGE_READ + v.len() as u64 * GAS_PER_BYTE)?;
            write(&mut c, vp, &v)?;
            Ok(v.len() as i32)
        },
    )
    .unwrap();
    l.func_wrap(
        "env",
        "storage_write",
        |mut c: Caller<'_, Host>, kp: i32, kl: i32, vp: i32, vl: i32| -> Result<(), wasmi::Error> {
            no_writes(&c)?;
            let k = read(&c, kp, kl)?;
            let v = read(&c, vp, vl)?;
            charge(
                &mut c,
                GAS_STORAGE_WRITE + (k.len() + v.len()) as u64 * GAS_PER_BYTE,
            )?;
            c.data_mut().storage.insert(k, v);
            Ok(())
        },
    )
    .unwrap();
    l.func_wrap(
        "env",
        "storage_delete",
        |mut c: Caller<'_, Host>, kp: i32, kl: i32| -> Result<(), wasmi::Error> {
            no_writes(&c)?;
            charge(&mut c, GAS_STORAGE_READ)?;
            let k = read(&c, kp, kl)?;
            c.data_mut().storage.remove(&k);
            Ok(())
        },
    )
    .unwrap();
    l.func_wrap(
        "env",
        "caller",
        |mut c: Caller<'_, Host>, ptr: i32| -> Result<(), wasmi::Error> {
            let a = c.data().env.caller.0;
            write(&mut c, ptr, &a)
        },
    )
    .unwrap();
    l.func_wrap(
        "env",
        "self_address",
        |mut c: Caller<'_, Host>, ptr: i32| -> Result<(), wasmi::Error> {
            let a = c.data().env.this.0;
            write(&mut c, ptr, &a)
        },
    )
    .unwrap();
    l.func_wrap("env", "value", |c: Caller<'_, Host>| -> i64 {
        c.data().env.value as i64
    })
    .unwrap();
    l.func_wrap("env", "balance", |c: Caller<'_, Host>| -> i64 {
        c.data().env.balance as i64
    })
    .unwrap();
    l.func_wrap("env", "height", |c: Caller<'_, Host>| -> i64 {
        c.data().env.height as i64
    })
    .unwrap();
    l.func_wrap("env", "time", |c: Caller<'_, Host>| -> i64 {
        c.data().env.time as i64
    })
    .unwrap();
    l.func_wrap(
        "env",
        "transfer",
        |mut c: Caller<'_, Host>, ap: i32, amount: i64| -> Result<i32, wasmi::Error> {
            no_writes(&c)?;
            charge(&mut c, GAS_TRANSFER)?;
            let to = Address(read(&c, ap, 20)?.try_into().unwrap());
            let amount = amount as u64;
            let h = c.data_mut();
            if amount > h.env.balance {
                return Ok(1);
            }
            h.env.balance -= amount;
            h.transfers.push((to, amount));
            Ok(0)
        },
    )
    .unwrap();
    l.func_wrap(
        "env",
        "emit",
        |mut c: Caller<'_, Host>, tp: i32, tl: i32, dp: i32, dl: i32| -> Result<(), wasmi::Error> {
            no_writes(&c)?;
            let topic = String::from_utf8_lossy(&read(&c, tp, tl)?).to_string();
            let data = read(&c, dp, dl)?;
            charge(
                &mut c,
                GAS_EMIT + (topic.len() + data.len()) as u64 * GAS_PER_BYTE,
            )?;
            let contract = c.data().env.this;
            c.data_mut().events.push(Event {
                contract,
                topic,
                data: Bytes(data),
            });
            Ok(())
        },
    )
    .unwrap();
    // Ask another contract something. Returns the answer's length, or -1 if it failed.
    l.func_wrap(
        "env",
        "static_call",
        |mut c: Caller<'_, Host>, ap: i32, ip: i32, il: i32| -> Result<i32, wasmi::Error> {
            charge(&mut c, GAS_CALL)?;
            let target = Address(read(&c, ap, 20)?.try_into().unwrap());
            let input = read(&c, ip, il)?;
            let (world, depth, env) = {
                let h = c.data();
                (h.world.clone(), h.depth, h.env.clone())
            };
            if depth >= MAX_DEPTH {
                return Err(wasmi::Error::new("calls nested too deep"));
            }
            let Some(callee) = world.get(&target).cloned() else {
                c.data_mut().last_return.clear();
                return Ok(-1);
            };
            let gas = c.get_fuel()?;
            let callee_env = CallEnv {
                caller: env.this,
                this: target,
                value: 0,
                balance: 0,
                height: env.height,
                time: env.time,
            };
            let out = run_inner(
                world,
                &callee.code.0,
                "call",
                input,
                (*callee.storage).clone(),
                callee_env,
                gas,
                true,
                depth + 1,
            );
            charge(&mut c, out.gas_used)?;
            let h = c.data_mut();
            if out.ok {
                h.last_return = out.output;
                Ok(h.last_return.len() as i32)
            } else {
                h.last_return.clear();
                Ok(-1)
            }
        },
    )
    .unwrap();
    l.func_wrap(
        "env",
        "return_data",
        |mut c: Caller<'_, Host>, ptr: i32| -> Result<(), wasmi::Error> {
            let data = c.data().last_return.clone();
            write(&mut c, ptr, &data)
        },
    )
    .unwrap();
    l.func_wrap(
        "env",
        "revert",
        |c: Caller<'_, Host>, ptr: i32, len: i32| -> Result<(), wasmi::Error> {
            let msg = read(&c, ptr, len)
                .map(|m| String::from_utf8_lossy(&m).to_string())
                .unwrap_or_default();
            Err(wasmi::Error::new(format!("reverted: {msg}")))
        },
    )
    .unwrap();
    // AssemblyScript calls this when an assert fails.
    l.func_wrap(
        "env",
        "abort",
        |c: Caller<'_, Host>,
         msg: i32,
         _file: i32,
         line: i32,
         _col: i32|
         -> Result<(), wasmi::Error> {
            let m = read_as_string(&c, msg);
            Err(wasmi::Error::new(format!("reverted: {m} (line {line})")))
        },
    )
    .unwrap();
    l
}

fn clean_error(e: &wasmi::Error) -> String {
    let s = e.to_string();
    if s.contains("all fuel consumed") || s.contains("out of gas") {
        return "out of gas".into();
    }
    s
}

/// Runs one contract function (`init` when deploying, `call` otherwise).
pub fn run(
    world: Arc<World>,
    code: &[u8],
    entry: &str,
    input: Vec<u8>,
    storage: Storage,
    env: CallEnv,
    gas: u64,
) -> VmResult {
    run_inner(world, code, entry, input, storage, env, gas, false, 0)
}

/// Runs a function that may only read, for questions asked without a transaction.
pub fn run_readonly(
    world: Arc<World>,
    code: &[u8],
    input: Vec<u8>,
    storage: Storage,
    env: CallEnv,
    gas: u64,
) -> VmResult {
    run_inner(world, code, "call", input, storage, env, gas, true, 0)
}

#[allow(clippy::too_many_arguments)]
fn run_inner(
    world: Arc<World>,
    code: &[u8],
    entry: &str,
    input: Vec<u8>,
    storage: Storage,
    env: CallEnv,
    gas: u64,
    readonly: bool,
    depth: u32,
) -> VmResult {
    let engine = engine();
    let host = Host {
        env,
        input,
        output: Vec::new(),
        storage,
        transfers: Vec::new(),
        events: Vec::new(),
        limits: StoreLimitsBuilder::new()
            .memory_size(MAX_MEMORY)
            .instances(1)
            .build(),
        world,
        readonly,
        depth,
        last_return: Vec::new(),
    };
    let mut store = Store::new(&engine, host);
    store.limiter(|h| &mut h.limits);
    store.set_fuel(gas).expect("fuel is on");

    let outcome: Result<(), String> = (|| {
        let module = Module::new(&engine, code).map_err(|e| format!("bad wasm: {e}"))?;
        let inst = linker(&engine)
            .instantiate_and_start(&mut store, &module)
            .map_err(|e| clean_error(&e))?;
        match inst.get_typed_func::<(), ()>(&store, entry) {
            Ok(f) => f.call(&mut store, ()).map_err(|e| clean_error(&e)),
            Err(_) if entry == "init" => Ok(()), // contracts don't have to have a setup step
            Err(_) => Err(format!("contract has no `{entry}` function")),
        }
    })();

    let left = store.get_fuel().unwrap_or(0);
    let gas_used = gas - left;
    let host = store.into_data();
    match outcome {
        Ok(()) => VmResult {
            ok: true,
            gas_used,
            output: host.output,
            events: host.events,
            error: None,
            storage: host.storage,
            transfers: host.transfers,
        },
        Err(e) => VmResult {
            ok: false,
            gas_used,
            output: Vec::new(),
            events: Vec::new(),
            error: Some(e),
            storage: host.storage,
            transfers: Vec::new(),
        },
    }
}
