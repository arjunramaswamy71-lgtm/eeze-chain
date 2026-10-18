"""
The maths of attacking a proof-of-work chain, checked by simulation.

1. Double spend (Nakamoto 2008, section 11): if an attacker has a share q of all mining power and
   the merchant waits for z confirmations, what is the chance the attacker can still catch up?
   Satoshi's formula uses a shortcut (it treats the attacker's progress as Poisson). Rosenfeld (2014)
   gave the exact version (negative binomial). We check both against 200,000 simulated races each.

2. Selfish mining (Eyal & Sirer 2014): a miner who hides blocks and releases them strategically
   can earn MORE than their fair share, even below 50%. We simulate the strategy and compare
   with the paper's closed-form answer.

Usage:  python sim/attacks.py
"""

import json
import math
from pathlib import Path

import numpy as np

OUT = Path(__file__).resolve().parent / "out"
rng = np.random.default_rng(2026)


# ---------------------------------------------------------------- double spend

def nakamoto(q, z):
    """Satoshi's formula: chance an attacker with share q ever catches up from z blocks behind."""
    p = 1 - q
    if q >= p:
        return 1.0
    lam = z * q / p
    s, poisson = 1.0, math.exp(-lam)
    for k in range(z + 1):
        if k > 0:
            poisson *= lam / k
        s -= poisson * (1 - (q / p) ** (z - k))
    return s


def exact(q, z):
    """Rosenfeld's exact answer: while honest miners find z blocks, the attacker finds k
    (negative binomial). From z-k behind, the chance to ever catch up is (q/p)^(z-k)."""
    p = 1 - q
    if q >= p:
        return 1.0
    total, pmf = 0.0, p**z  # k = 0
    for k in range(0, 2000):
        if k > 0:
            pmf *= q * (k + z - 1) / k
        total += pmf * (1.0 if k >= z else (q / p) ** (z - k))
        if k > z and pmf < 1e-15:
            break
    return total


def simulate_double_spend(q, z, trials=200_000, give_up=60):
    """Plays out the race block by block. While the honest network finds z blocks, the attacker
    finds some too. After that, each next block is the attacker's with chance q, and the attacker
    keeps going until level with the honest chain, or so far behind (give_up) it's hopeless."""
    k = rng.negative_binomial(z, 1 - q, size=trials) if z > 0 else np.zeros(trials, dtype=int)
    d = (z - k).astype(np.int64)
    won = d <= 0
    active = ~won
    for _ in range(5000):
        if not active.any():
            break
        idx = np.flatnonzero(active)
        d[idx] += np.where(rng.random(idx.size) < q, -1, 1)
        w = idx[d[idx] <= 0]
        lost = idx[d[idx] >= give_up]
        won[w] = True
        active[w] = False
        active[lost] = False
    return won.mean()


def confirmations_needed(q, risk=0.001):
    for z in range(0, 400):
        if exact(q, z) < risk:
            return z
    return None


# ---------------------------------------------------------------- selfish mining

def selfish_formula(a, g):
    """Eyal & Sirer (2014), equation 8: the selfish pool's share of the rewards."""
    num = a * (1 - a) ** 2 * (4 * a + g * (1 - 2 * a)) - a**3
    den = 1 - a * (1 + (2 - a) * a)
    return num / den


def simulate_selfish(a, g, rounds=150_000):
    """Runs the selfish-mining strategy from the paper, block by block.
    a = the pool's share of mining power, g = share of honest miners who build on the pool's
    block when there is a tie."""
    pool = honest = 0  # blocks that ended up on the final chain
    lead = 0  # how many hidden blocks the pool is ahead
    tie = False  # two branches of length 1 racing
    r = rng.random(rounds)
    r2 = rng.random(rounds)
    for i in range(rounds):
        if r[i] < a:  # the pool finds a block
            if tie:
                pool += 2  # wins the race with both its blocks
                tie = False
                lead = 0
            else:
                lead += 1
        else:  # honest miners find a block
            if tie:
                if r2[i] < g:
                    pool += 1
                    honest += 1  # honest block built on the pool's branch
                else:
                    honest += 2
                tie = False
                lead = 0
            elif lead == 0:
                honest += 1
            elif lead == 1:
                tie = True  # pool reveals its block: a race
                lead = 0
            elif lead == 2:
                pool += 2  # pool reveals everything and wins
                lead = 0
            else:
                pool += 1  # reveal one, stay ahead
                lead -= 1
    pool += lead
    return pool / (pool + honest)


def main():
    OUT.mkdir(exist_ok=True)
    result = {}

    qs = [0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45]
    zs = list(range(0, 11))
    table = []
    print("Double spend: chance the attacker catches up  (Satoshi / exact / simulated)")
    shown = [1, 2, 3, 6, 10]
    print("   q   " + "".join(f"  z={z:<17}" for z in shown))
    for q in qs:
        row = {"q": q, "formula": [exact(q, z) for z in zs], "satoshi": [nakamoto(q, z) for z in zs]}
        sims = {z: simulate_double_spend(q, z) for z in shown}
        row["simulated"] = {str(z): v for z, v in sims.items()}
        row["confirmations_for_0.1pct"] = confirmations_needed(q)
        table.append(row)
        print(f" {q:.2f} " + "".join(f" {nakamoto(q, z):.3f}/{exact(q, z):.3f}/{sims[z]:.3f}" for z in shown))
    worst = max(abs(row["formula"][z] - row["simulated"][str(z)]) for row in table for z in shown)
    print(f"largest gap between the exact formula and the simulation: {worst:.4f}")
    over = max(row["satoshi"][z] - row["formula"][z] for row in table for z in zs)
    under = max(row["formula"][z] - row["satoshi"][z] for row in table for z in zs)
    print(f"Satoshi's shortcut is off by up to +{over:.3f} at few confirmations and -{under:.3f} at many,")
    print("so at the waits people actually use, it UNDERstates the risk.")
    print("\nConfirmations to wait for under 0.1% risk:")
    for row in table:
        n = row["confirmations_for_0.1pct"]
        print(f"   attacker with {row['q']*100:.0f}% of mining power: {n if n is not None else 'over 400'} blocks")
    result["double_spend"] = {"z": zs, "rows": table, "max_gap": worst}

    print("\nSelfish mining: the pool's share of rewards (fair share would equal its mining share)")
    alphas = [round(x, 3) for x in np.arange(0.05, 0.5, 0.05)]
    sm = []
    for g in [0.0, 0.5, 1.0]:
        sim = [simulate_selfish(a, g) for a in alphas]
        form = [selfish_formula(a, g) for a in alphas]
        sm.append({"gamma": g, "alpha": alphas, "simulated": sim, "formula": form})
        cross = next((a for a, s in zip(alphas, form) if s > a), None)
        print(f"   gamma={g}: pays more than fair from about {cross:.2f} of the mining power on our grid. "
              f"at 30%: {sim[5]*100:.1f}% of rewards (formula {form[5]*100:.1f}%)")
    result["selfish"] = sm
    result["thresholds"] = {"gamma0": 1 / 3, "gamma0.5": 1 / 4, "gamma1": 0}

    # What our live testnet did: an attacker with 4 of 5 mining threads.
    result["live_attacker_share"] = 0.8
    result["live_attack_formula_z3"] = exact(0.8, 3)

    (OUT / "attacks.json").write_text(json.dumps(result, indent=1))
    charts(result)
    print(f"\nsaved {OUT / 'attacks.json'} and charts")


def charts(r):
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 10, "axes.spines.top": False,
                         "axes.spines.right": False})
    ink, accent, mid = "#1C2A2B", "#16AED5", "#9AA8A6"

    fig, ax = plt.subplots(figsize=(7, 4.2), dpi=150)
    for row, shade in zip(r["double_spend"]["rows"][1::2], [mid, "#5E8F62", "#C39A3E", "#A9473B"]):
        z = r["double_spend"]["z"]
        ax.plot(z, row["formula"], color=shade, lw=2, label=f"attacker {row['q']*100:.0f}%")
        ax.plot(z, row["satoshi"], color=shade, lw=1, ls=":")
        sz = [int(k) for k in row["simulated"]]
        ax.scatter(sz, [row["simulated"][str(k)] for k in sz], color=shade, s=18, zorder=3)
    ax.set_yscale("log")
    ax.set_ylim(1e-5, 1.2)
    ax.set_xlabel("confirmations the merchant waits for")
    ax.set_ylabel("chance the double spend works")
    ax.set_title("Chance a double spend works\nlines: exact formula   dotted: Satoshi's shortcut   dots: simulation", loc="left", color=ink)
    ax.legend(frameon=False)
    fig.tight_layout()
    fig.savefig(OUT / "double_spend.png")

    fig, ax = plt.subplots(figsize=(7, 4.2), dpi=150)
    a = r["selfish"][0]["alpha"]
    ax.plot([0, 0.5], [0, 0.5], color=mid, lw=1, ls="--", label="fair share")
    for s, shade in zip(r["selfish"], ["#5E8F62", accent, "#A9473B"]):
        ax.plot(a, s["formula"], color=shade, lw=2, label=f"gamma {s['gamma']}")
        ax.scatter(a, s["simulated"], color=shade, s=18, zorder=3)
    ax.set_xlabel("selfish pool's share of mining power")
    ax.set_ylabel("share of block rewards it gets")
    ax.set_title("Selfish mining pays above the dashed line", loc="left", color=ink)
    ax.set_xlim(0, 0.5)
    ax.set_ylim(0, 0.75)
    ax.legend(frameon=False)
    fig.tight_layout()
    fig.savefig(OUT / "selfish_mining.png")


if __name__ == "__main__":
    main()
