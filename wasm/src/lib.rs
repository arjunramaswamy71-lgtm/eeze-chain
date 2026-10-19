//! EEZE Chain for the browser. JavaScript talks to it through one function, `call`, with JSON in
//! and JSON out, so there's no generated glue code to keep in step.

pub mod sim;

use serde_json::{Value, json};
use std::cell::RefCell;

thread_local! {
    static SIM: RefCell<Option<sim::Sim>> = const { RefCell::new(None) };
}

/// JavaScript asks for memory to write its request into.
#[unsafe(no_mangle)]
pub extern "C" fn alloc(len: usize) -> *mut u8 {
    let mut v = Vec::<u8>::with_capacity(len);
    let p = v.as_mut_ptr();
    std::mem::forget(v);
    p
}

/// JavaScript hands back memory it's finished with.
///
/// # Safety
/// `ptr` and `len` must come from `alloc` or from `call`'s answer.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn dealloc(ptr: *mut u8, len: usize) {
    unsafe { drop(Vec::from_raw_parts(ptr, 0, len)) };
}

fn run(req: Value) -> Value {
    let cmd = req["cmd"].as_str().unwrap_or("");
    SIM.with(|cell| {
        let mut slot = cell.borrow_mut();
        if cmd == "init" {
            *slot = Some(sim::Sim::new(
                req["now"].as_u64().unwrap_or(1_760_000_000_000),
            ));
            return json!({ "ok": true });
        }
        let Some(s) = slot.as_mut() else {
            return json!({ "error": "call init first", "code": 500 });
        };
        match cmd {
            "tick" => {
                s.tick(req["ms"].as_u64().unwrap_or(0));
                json!({ "now": s.now })
            }
            "overview" => s.overview(),
            "control" => match s.control(req["action"].as_str().unwrap_or(""), &req) {
                Ok(v) => v,
                Err(e) => json!({ "error": e, "code": 400 }),
            },
            "api" => {
                let body = req["body"].as_str().unwrap_or("").as_bytes().to_vec();
                match s.api(
                    req["node"].as_u64().unwrap_or(0) as usize,
                    req["method"].as_str().unwrap_or("GET"),
                    req["path"].as_str().unwrap_or("/"),
                    req["query"].as_str().unwrap_or(""),
                    &body,
                ) {
                    Ok(v) => v,
                    Err((code, e)) => json!({ "error": e, "code": code }),
                }
            }
            _ => json!({ "error": format!("unknown command {cmd}"), "code": 400 }),
        }
    })
}

/// Takes a JSON request, returns a pointer and length (packed into one number) to the JSON answer.
///
/// # Safety
/// `ptr` and `len` must describe memory JavaScript wrote after calling `alloc`.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn call(ptr: *mut u8, len: usize) -> u64 {
    let input = unsafe { Vec::from_raw_parts(ptr, len, len) };
    let req: Value = serde_json::from_slice(&input).unwrap_or(json!({}));
    let mut out = serde_json::to_vec(&run(req)).unwrap();
    out.shrink_to_fit();
    let (p, l) = (out.as_mut_ptr(), out.len());
    std::mem::forget(out);
    ((p as u64) << 32) | l as u64
}
