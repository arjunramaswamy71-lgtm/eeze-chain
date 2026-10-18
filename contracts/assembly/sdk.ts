// The small toolkit every EEZE Chain contract uses to talk to the chain.

@external("env", "input_len") declare function _input_len(): i32;
@external("env", "input_read") declare function _input_read(ptr: i32): void;
@external("env", "output") declare function _output(ptr: i32, len: i32): void;
@external("env", "storage_len") declare function _storage_len(kp: i32, kl: i32): i32;
@external("env", "storage_read") declare function _storage_read(kp: i32, kl: i32, vp: i32): i32;
@external("env", "storage_write") declare function _storage_write(kp: i32, kl: i32, vp: i32, vl: i32): void;
@external("env", "storage_delete") declare function _storage_delete(kp: i32, kl: i32): void;
@external("env", "caller") declare function _caller(ptr: i32): void;
@external("env", "self_address") declare function _self(ptr: i32): void;
@external("env", "value") declare function _value(): u64;
@external("env", "balance") declare function _balance(): u64;
@external("env", "height") declare function _height(): u64;
@external("env", "transfer") declare function _transfer(ap: i32, amount: u64): i32;
@external("env", "emit") declare function _emit(tp: i32, tl: i32, dp: i32, dl: i32): void;
@external("env", "revert") declare function _revert(ptr: i32, len: i32): void;

function ptr(a: Uint8Array): i32 {
  return <i32>a.dataStart;
}

export function utf8(s: string): Uint8Array {
  return Uint8Array.wrap(String.UTF8.encode(s));
}

export function concat(a: Uint8Array, b: Uint8Array): Uint8Array {
  const out = new Uint8Array(a.length + b.length);
  out.set(a, 0);
  out.set(b, a.length);
  return out;
}

/** Stops the call. Everything it changed is undone, and the message goes in the receipt. */
export function fail(msg: string): void {
  const m = utf8(msg);
  _revert(ptr(m), m.length);
}

export function require(ok: bool, msg: string): void {
  if (!ok) fail(msg);
}

export function input(): Uint8Array {
  const b = new Uint8Array(_input_len());
  if (b.length > 0) _input_read(ptr(b));
  return b;
}

export function output(b: Uint8Array): void {
  _output(ptr(b), b.length);
}

export function caller(): Uint8Array {
  const a = new Uint8Array(20);
  _caller(ptr(a));
  return a;
}

export function selfAddress(): Uint8Array {
  const a = new Uint8Array(20);
  _self(ptr(a));
  return a;
}

/** CTDY sent with this call. */
export function value(): u64 { return _value(); }
export function balance(): u64 { return _balance(); }
export function height(): u64 { return _height(); }

/** Sends CTDY from this contract. */
export function pay(to: Uint8Array, amount: u64): void {
  if (amount == 0) return;
  require(_transfer(ptr(to), amount) == 0, "contract doesn't have enough CTDY");
}

export function emit(topic: string, data: Uint8Array): void {
  const t = utf8(topic);
  _emit(ptr(t), t.length, ptr(data), data.length);
}

export function sameAddress(a: Uint8Array, b: Uint8Array): bool {
  if (a.length != b.length) return false;
  for (let i = 0; i < a.length; i++) if (a[i] != b[i]) return false;
  return true;
}

// ---- storage ----

export function load(key: Uint8Array): Uint8Array | null {
  const n = _storage_len(ptr(key), key.length);
  if (n < 0) return null;
  const v = new Uint8Array(n);
  _storage_read(ptr(key), key.length, ptr(v));
  return v;
}

export function save(key: Uint8Array, v: Uint8Array): void {
  _storage_write(ptr(key), key.length, ptr(v), v.length);
}

export function remove(key: Uint8Array): void {
  _storage_delete(ptr(key), key.length);
}

export function u64Bytes(v: u64): Uint8Array {
  const b = new Uint8Array(8);
  for (let i = 0; i < 8; i++) b[i] = <u8>(v >> (<u64>i * 8));
  return b;
}

export function bytesU64(b: Uint8Array, at: i32 = 0): u64 {
  let v: u64 = 0;
  for (let i = 0; i < 8; i++) v |= (<u64>b[at + i]) << (<u64>i * 8);
  return v;
}

export function loadU64(key: Uint8Array): u64 {
  const v = load(key);
  return v == null ? 0 : bytesU64(v);
}

export function saveU64(key: Uint8Array, v: u64): void {
  save(key, u64Bytes(v));
}

export function loadFlag(key: Uint8Array): bool {
  const v = load(key);
  return v != null && v.length > 0 && v[0] == 1;
}

export function saveFlag(key: Uint8Array, on: bool): void {
  if (on) {
    const b = new Uint8Array(1);
    b[0] = 1;
    save(key, b);
  } else remove(key);
}

// ---- reading arguments (same format as the chain's abi) ----

export class Reader {
  pos: i32 = 0;
  constructor(public b: Uint8Array) {}

  private tag(t: u8, what: string): void {
    require(this.pos < this.b.length, "missing argument: " + what);
    require(this.b[this.pos] == t, "wrong type for argument: " + what);
    this.pos++;
  }
  private len(): i32 {
    require(this.pos + 4 <= this.b.length, "argument cut short");
    const n = <i32>this.b[this.pos] | (<i32>this.b[this.pos + 1] << 8) | (<i32>this.b[this.pos + 2] << 16) | (<i32>this.b[this.pos + 3] << 24);
    this.pos += 4;
    require(n >= 0 && this.pos + n <= this.b.length, "argument cut short");
    return n;
  }
  u64(what: string): u64 {
    this.tag(1, what);
    require(this.pos + 8 <= this.b.length, "argument cut short");
    const v = bytesU64(this.b, this.pos);
    this.pos += 8;
    return v;
  }
  str(what: string): string {
    this.tag(4, what);
    const n = this.len();
    const s = String.UTF8.decodeUnsafe(this.b.dataStart + <usize>this.pos, <usize>n);
    this.pos += n;
    return s;
  }
  addr(what: string): Uint8Array {
    this.tag(3, what);
    require(this.pos + 20 <= this.b.length, "argument cut short");
    const a = this.b.slice(this.pos, this.pos + 20);
    this.pos += 20;
    return a;
  }
  more(): bool {
    return this.pos < this.b.length;
  }
}

/** Builds a return value in the same format. */
export class Writer {
  parts: Array<Uint8Array> = [];
  size: i32 = 0;
  private push(b: Uint8Array): Writer {
    this.parts.push(b);
    this.size += b.length;
    return this;
  }
  private one(v: u8): Uint8Array {
    const b = new Uint8Array(1);
    b[0] = v;
    return b;
  }
  private len(n: i32): Uint8Array {
    const b = new Uint8Array(4);
    b[0] = <u8>n; b[1] = <u8>(n >> 8); b[2] = <u8>(n >> 16); b[3] = <u8>(n >> 24);
    return b;
  }
  u64(v: u64): Writer { this.push(this.one(1)); return this.push(u64Bytes(v)); }
  addr(a: Uint8Array): Writer { this.push(this.one(3)); return this.push(a); }
  str(s: string): Writer {
    const b = utf8(s);
    this.push(this.one(4)); this.push(this.len(b.length)); return this.push(b);
  }
  bool(v: bool): Writer { return this.u64(v ? 1 : 0); }
  done(): Uint8Array {
    const out = new Uint8Array(this.size);
    let at = 0;
    for (let i = 0; i < this.parts.length; i++) {
      out.set(this.parts[i], at);
      at += this.parts[i].length;
    }
    return out;
  }
}

// ---- 128-bit numbers, so share maths never overflows ----

export class U128 {
  constructor(public hi: u64 = 0, public lo: u64 = 0) {}

  static mul(a: u64, b: u64): U128 {
    const a0 = a & 0xffffffff, a1 = a >> 32, b0 = b & 0xffffffff, b1 = b >> 32;
    const p00 = a0 * b0, p01 = a0 * b1, p10 = a1 * b0, p11 = a1 * b1;
    const mid = (p00 >> 32) + (p01 & 0xffffffff) + (p10 & 0xffffffff);
    const lo = (p00 & 0xffffffff) | (mid << 32);
    const hi = p11 + (p01 >> 32) + (p10 >> 32) + (mid >> 32);
    return new U128(hi, lo);
  }
  add(o: U128): U128 {
    const lo = this.lo + o.lo;
    const carry: u64 = lo < this.lo ? 1 : 0;
    return new U128(this.hi + o.hi + carry, lo);
  }
  sub(o: U128): U128 {
    const lo = this.lo - o.lo;
    const borrow: u64 = this.lo < o.lo ? 1 : 0;
    return new U128(this.hi - o.hi - borrow, lo);
  }
  /** Divides by a 64-bit number. The answer must fit in 64 bits. */
  div(d: u64): u64 {
    require(d != 0, "divide by zero");
    let rem: u64 = 0;
    let q: u64 = 0;
    let rhi: u64 = 0; // the bit pushed out of `rem` on shift
    for (let i = 127; i >= 0; i--) {
      rhi = rem >> 63;
      rem = rem << 1;
      const bit: u64 = i >= 64 ? (this.hi >> <u64>(i - 64)) & 1 : (this.lo >> <u64>i) & 1;
      rem |= bit;
      if (rhi == 1 || rem >= d) {
        rem -= d;
        if (i < 64) q |= (<u64>1) << <u64>i;
        else require(false, "number too big");
      }
    }
    return q;
  }
  /** Divides by a 64-bit number, giving a 128-bit answer. */
  divWide(d: u64): U128 {
    const hiQ = this.hi / d;
    const r = new U128(this.hi % d, this.lo);
    return new U128(hiQ, r.div(d));
  }
  bytes(): Uint8Array {
    return concat(u64Bytes(this.hi), u64Bytes(this.lo));
  }
  static from(b: Uint8Array | null): U128 {
    if (b == null) return new U128();
    return new U128(bytesU64(b, 0), bytesU64(b, 8));
  }
}
