"""
Runs a real EEZE Chain network on this computer and puts it through everything:

  1. Mining (proof of work) with several nodes talking to each other
  2. Sending CoTdy (CTDY) and checking every node agrees
  3. A live 51% attack: an attacker with 4x the mining power secretly builds a longer chain,
     then releases it to erase a payment the victim already saw confirmed
  4. The switch to staking (proof of stake)
  5. A cheating validator signing two blocks for one turn, caught and slashed automatically
  6. A tokenized building: KYC, buying shares, rent paid out, claims

Usage:  python sim/testnet.py          (build first: cargo build --release, npm run build in contracts/)
        python sim/testnet.py --keep   (leaves the network running so you can explore it in the browser)
"""

import json
import os
import shutil
import signal
import subprocess
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
EEZE = ROOT / "target" / "release" / ("eeze.exe" if os.name == "nt" else "eeze")
WORK = ROOT / "sim" / "testnet-data"
OUT = ROOT / "sim" / "out"
COIN = 100_000_000
POS_HEIGHT = 60

procs = {}
report = {"steps": []}


def say(msg=""):
    print(msg, flush=True)


def step(title):
    say("\n" + "=" * 70 + f"\n{title}\n" + "=" * 70)
    report["steps"].append({"title": title})


def note(**kw):
    report["steps"][-1].update(kw)


def api(port, path, body=None):
    url = f"http://127.0.0.1:{port}{path}"
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            return json.loads(r.read())
    except urllib.error.HTTPError as e:
        return {"error": json.loads(e.read()).get("error"), "code": e.code}


def cli(port, *args, check=True):
    r = subprocess.run([str(EEZE), "--rpc", f"http://127.0.0.1:{port}", *args], capture_output=True, text=True)
    if check and r.returncode != 0:
        raise SystemExit(f"command failed: eeze {' '.join(args)}\n{r.stderr}")
    return r.stdout.strip()


def address(seed):
    return cli(0, "address", "--key", f"seed:{seed}")


def start(name, port, apiport, key, *extra, peers=()):
    args = [str(EEZE), "node", "--name", name, "--port", str(port), "--api", str(apiport),
            "--key", f"seed:{key}", "--data", str(WORK / name), "--genesis", str(WORK / "genesis.json")]
    for p in peers:
        args += ["--peer", f"127.0.0.1:{p}"]
    args += list(extra)
    log = open(WORK / f"{name}.log", "a")
    procs[name] = subprocess.Popen(args, stdout=log, stderr=subprocess.STDOUT, cwd=ROOT)
    for _ in range(100):
        if "height" in (api(apiport, "/status") if _alive(apiport) else {}):
            return
        time.sleep(0.1)
    raise SystemExit(f"{name} didn't start, see {WORK / (name + '.log')}")


def _alive(port):
    try:
        urllib.request.urlopen(f"http://127.0.0.1:{port}/status", timeout=1)
        return True
    except Exception:
        return False


def stop(name):
    p = procs.pop(name, None)
    if p:
        p.send_signal(signal.SIGINT if os.name != "nt" else signal.CTRL_BREAK_EVENT) if False else p.terminate()
        p.wait()


def height(port):
    return api(port, "/status")["height"]


def wait_until(cond, timeout, what):
    t0 = time.time()
    while time.time() - t0 < timeout:
        if cond():
            return True
        time.sleep(0.25)
    say(f"   (timed out waiting for {what})")
    return False


def ctdy(units):
    return f"{units / COIN:,.2f} CTDY"


def main():
    if not EEZE.exists():
        raise SystemExit("build the node first:  cargo build --release")
    shutil.rmtree(WORK, ignore_errors=True)
    WORK.mkdir(parents=True)
    OUT.mkdir(parents=True, exist_ok=True)

    # A local network: fast blocks, staking from block 60.
    g = json.loads(cli(0, "genesis"))
    g["chain_id"] = "eeze-local-testnet"
    g["time"] = int(time.time() * 1000) - 1000
    g["target_ms"] = 1000
    g["slot_ms"] = 1500
    g["pos_height"] = POS_HEIGHT
    g["unbonding_blocks"] = 10
    g["alloc"].append([address("eve"), 1_000 * COIN])
    g["stakes"] = [[address("mallory"), 3_000 * COIN]]
    (WORK / "genesis.json").write_text(json.dumps(g, indent=2))

    who = {s: address(s) for s in ["arjun", "bank", "alice", "bob", "eve", "eve-2", "mallory"]}
    report["wallets"] = who

    # ------------------------------------------------------------------
    step("1. Start the network")
    start("miner", 7101, 8101, "miner1", "--mine")
    start("bob", 7102, 8102, "bob", peers=[7101])
    start("arjun", 7103, 8103, "arjun", "--validate", peers=[7101])
    start("bank", 7104, 8104, "bank", "--validate", peers=[7101, 7103])
    start("mallory", 7105, 8105, "mallory", "--validate", "--evil-double-sign", peers=[7101, 7102])
    # The attacker: 4 mining threads vs the honest miner's 1, and NOT connected to anyone.
    start("attacker", 7109, 8109, "attacker", "--mine", "--threads", "4")
    say("5 honest nodes + 1 hidden attacker node running")
    wait_until(lambda: height(8102) >= 3, 60, "first blocks")
    say(f"honest chain at #{height(8101)}, attacker's secret chain at #{height(8109)}")

    # ------------------------------------------------------------------
    step("2. Send CoTdy and check every node agrees")
    out = cli(8102, "send", "--key", "seed:arjun", "--to", who["alice"], "--amount", "25")
    say(out)
    time.sleep(2)
    bals = {n: api(p, f"/account/{who['alice']}")["balance"] for n, p in
            [("miner", 8101), ("bob", 8102), ("arjun", 8103), ("bank", 8104)]}
    say(f"alice's balance as seen by each node: { {k: ctdy(v) for k, v in bals.items()} }")
    assert len(set(bals.values())) == 1 and bals["bob"] == 10_025 * COIN
    note(alice_balance=bals["bob"])

    say("arjun and the bank lock up CTDY to become validators for later:")
    say(cli(8103, "stake", "--key", "seed:arjun", "--amount", "5000"))
    say(cli(8104, "stake", "--key", "seed:bank", "--amount", "15000"))

    # ------------------------------------------------------------------
    step("3. 51% attack: Eve tries to spend the same 900 CTDY twice")
    pay_bob = cli(8102, "send", "--key", "seed:eve", "--to", who["bob"], "--amount", "900", "--no-wait").split()[-1]
    # Same coins, same nonce, sent only to the attacker's secret chain:
    sneaky = cli(8109, "send", "--key", "seed:eve", "--to", who["eve-2"], "--amount", "900", "--no-wait").split()[-1]
    say(f"Eve pays Bob 900 CTDY on the real network: {pay_bob[:18]}…")
    say(f"Eve secretly sends the same 900 CTDY to her other wallet on the hidden chain: {sneaky[:18]}…")

    def confs():
        t = api(8102, f"/tx/{pay_bob}")
        return t.get("confirmations", 0)

    wait_until(lambda: confs() >= 3, 60, "3 confirmations")
    say(f"Bob sees his payment with {confs()} confirmations and hands over the goods.")
    time.sleep(8)
    h_honest, h_attack = height(8101), height(8109)
    say(f"honest chain #{h_honest}  vs  attacker's hidden chain #{h_attack} (with 4x the hashing behind it)")

    # The attacker reveals the hidden chain.
    stop("attacker")
    start("attacker", 7109, 8109, "attacker", peers=[7101, 7102])
    reorged = wait_until(lambda: api(8102, f"/tx/{sneaky}").get("status") == "confirmed", 30, "the hidden chain to spread")
    bob_tx = api(8102, f"/tx/{pay_bob}")
    bob_bal = api(8102, f"/account/{who['bob']}")["balance"]
    eve2_bal = api(8102, f"/account/{who['eve-2']}")["balance"]
    reorg_lines = [l for l in (WORK / "bob.log").read_text().splitlines() if "REORG" in l]
    if reorged:
        say("Attacker released the heavier chain. Every honest node switched to it:")
        for l in reorg_lines[-2:]:
            say("   " + l)
        say(f"Bob's payment now: {bob_tx.get('status', bob_tx.get('error'))}")
        say(f"Bob's balance: {ctdy(bob_bal)} (the 900 is gone)   Eve's other wallet: {ctdy(eve2_bal)}")
        say("Lesson: confirmations only protect you if no one controls most of the mining power.")
    else:
        say("The attacker's chain wasn't heavier this time, so the honest chain held.")
    note(double_spend_worked=reorged, honest_height=h_honest, attacker_height=h_attack,
         bob_payment=bob_tx.get("status", "erased"), eve2_balance=eve2_bal)

    # ------------------------------------------------------------------
    step(f"4. Mining stops at block {POS_HEIGHT}; validators take over (proof of stake)")
    wait_until(lambda: height(8101) >= POS_HEIGHT + 15, 180, "staking blocks")
    st = api(8101, "/status")
    vals = api(8101, "/validators")
    say(f"now at #{st['height']}, consensus: {st['consensus']}")
    for v in vals["validators"]:
        name = next((k for k, a in who.items() if a == v["address"]), v["address"][:10])
        say(f"   {name:8} stake {ctdy(v['stake']):>16}   chance {v['share']*100:5.1f}%   recent blocks {v['recent_blocks']}")
    note(consensus=st["consensus"], validators=vals["validators"])

    # ------------------------------------------------------------------
    step("5. Mallory signs two different blocks for the same turn")
    wait_until(lambda: api(8101, "/status")["burned"] > 0, 120, "a slashing")
    m = api(8101, f"/account/{who['mallory']}")
    st = api(8101, "/status")
    caught = [l for f in ["bob", "arjun", "bank", "miner"] for l in (WORK / f"{f}.log").read_text().splitlines() if "CAUGHT" in l]
    for l in caught[:2]:
        say("   " + l)
    say(f"Mallory's stake: 3,000 CTDY -> {ctdy(m['stake'] + sum(u[1] for u in m['unbonding']))}")
    say(f"CTDY destroyed by slashing: {ctdy(st['burned'])}")
    note(mallory_stake_after=m["stake"], burned=st["burned"])
    stop("mallory")

    # ------------------------------------------------------------------
    step("6. The bank tokenizes a building")
    wasm = ROOT / "contracts" / "build" / "rwa.wasm"
    out = cli(8104, "deploy", "--key", "seed:bank", "--wasm", str(wasm),
              "str:Blacksburg Main St Building", "str:BMSB", "u64:1000", f"u64:{10 * COIN}", "str:deed sha256 9f2c41e1")
    asset = out.split("contract address ")[-1].strip()
    say(f"contract {asset}: 1,000 shares at 10 CTDY each")
    cli(8104, "call", "--key", "seed:bank", "--contract", asset, "--method", "approve", f"addr:{who['alice']}")
    say("bank approves Alice (KYC)")
    say(cli(8102, "call", "--key", "seed:alice", "--contract", asset, "--method", "buy", "--value", "1000", "u64:100"))
    say("Alice buys 100 shares for 1,000 CTDY")
    print(cli(8102, "call", "--key", "seed:bob", "--contract", asset, "--method", "buy", "--value", "10", "u64:1", check=False))
    say("Bob tries to buy without KYC: refused")
    cli(8104, "call", "--key", "seed:bank", "--contract", asset, "--method", "distribute", "--value", "500")
    owed = cli(8102, "query", "--contract", asset, "--method", "claimable", f"addr:{who['alice']}")
    say(f"bank pays 500 CTDY of rent; Alice (10% of shares) can claim {int(owed) / COIN} CTDY")
    say(cli(8102, "call", "--key", "seed:alice", "--contract", asset, "--method", "claim"))
    note(contract=asset, alice_claimable=int(owed))

    # ------------------------------------------------------------------
    step("7. Does every node agree?")
    time.sleep(3)
    tips = {n: api(p, "/status") for n, p in [("miner", 8101), ("bob", 8102), ("arjun", 8103), ("bank", 8104), ("attacker", 8109)]}
    for n, s in tips.items():
        say(f"   {n:9} #{s['height']}  {s['tip'][:18]}…")
    agree = len({(s["height"], s["tip"]) for s in tips.values()}) == 1
    say("All nodes agree on the same chain." if agree else "Nodes are still catching up with each other.")
    note(all_agree=agree, final_height=tips["bob"]["height"])

    (OUT / "testnet_report.json").write_text(json.dumps(report, indent=2))
    say(f"\nReport saved to {OUT / 'testnet_report.json'}")
    if "--keep" in sys.argv:
        say("\nThe network is still running. Open the explorer and wallet at http://127.0.0.1:8102")
        say("Press Ctrl+C to stop it.")
        while True:
            time.sleep(1)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
    finally:
        for n in list(procs):
            stop(n)
