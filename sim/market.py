"""
How much does the price move when you trade on the asset market?

The token's built-in market is a constant-product pool (the Uniswap v2 formula): it holds
shares and CTDY, and keeps  CTDY x shares  the same after every trade, minus a 0.3% fee.
Big trades move the price, because each share you take makes the next one scarcer.

This compares the textbook formula with quotes from the real contract
(sim/out/market_quotes.json, made by `cargo run --release --example market_quotes` in core/),
and works out the "slippage": how much more than the starting price you end up paying.

Usage:  python sim/market.py
"""

import json
import math
from pathlib import Path

OUT = Path(__file__).resolve().parent / "out"
COIN = 100_000_000


def formula_buy(rc, rs, x, fee):
    """Shares out for x CTDY in, before rounding down to whole shares."""
    x_net = x * (1 - fee)
    return rs * x_net / (rc + x_net)


def main():
    q = json.loads((OUT / "market_quotes.json").read_text())
    rc, rs, fee = q["pool_ctdy"], q["pool_shares"], q["fee"]
    start_price = rc / rs / COIN
    print(f"Pool: {rs:,} shares and {rc / COIN:,.0f} CTDY, so {start_price:.2f} CTDY a share to start.\n")
    print(f"{'trade (% of pool)':>18} {'CTDY sent':>12} {'shares out':>11} {'formula':>10} {'avg price':>10} {'slippage':>9}")
    rows = []
    worst_gap = 0.0
    for b in q["buys"]:
        x = b["ctdy_in"]
        got = b["shares_out"]
        f = formula_buy(rc, rs, x, fee)
        worst_gap = max(worst_gap, abs(math.floor(f) - got))
        # The contract only keeps what those whole shares cost and refunds the rest.
        avg = b["cost"] / COIN / got if got else float("inf")
        slip = avg / start_price - 1
        rows.append({"pct": b["pct_of_pool"], "ctdy_in": x / COIN, "shares": got, "formula": f, "avg_price": avg, "slippage": slip})
        print(f"{b['pct_of_pool']:>17}% {x / COIN:>12,.0f} {got:>11,} {f:>10.1f} {avg:>10.2f} {slip * 100:>8.1f}%")
    print(f"\nThe contract matches the formula to within {worst_gap:.0f} share (it rounds down to whole shares).")

    # Rule of thumb from the formula: slippage ~ fee + trade size as a share of the pool.
    small = [r for r in rows if r["pct"] <= 5]
    print("For small trades, slippage is about the fee plus the trade's size as a share of the pool:")
    for r in small[-3:]:
        print(f"   {r['pct']}% of the pool -> {r['slippage'] * 100:.1f}% slippage (rule of thumb {r['pct'] + fee * 100:.1f}%)")
    print("\nSo a thin market is expensive: spending 10% of the pool's CTDY costs about 10% over the price.")
    print("That's one reason tokenized assets with few holders (like a single building) trade less")
    print("easily than tokenized Treasury funds, which can be redeemed at the fund price instead.")

    (OUT / "market.json").write_text(json.dumps({"start_price": start_price, "rows": rows, "max_gap_shares": worst_gap}, indent=1))
    chart(rows, rc, rs, fee, start_price)


def chart(rows, rc, rs, fee, start_price):
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 10, "axes.spines.top": False, "axes.spines.right": False})
    ink, accent, mid = "#1C2A2B", "#16AED5", "#9AA8A6"
    fig, ax = plt.subplots(figsize=(7, 4.2), dpi=150)
    xs = [10 ** (i / 40) for i in range(-40, 94)]
    curve = [(x * rc / 100 / COIN) / formula_buy(rc, rs, x * rc / 100, fee) / start_price * 100 - 100 for x in xs]
    ax.plot(xs, curve, color=mid, lw=2, label="formula")
    ax.scatter([r["pct"] for r in rows], [r["slippage"] * 100 for r in rows], color=accent, s=22, zorder=3, label="the real contract")
    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.set_xlabel("trade size, as % of the CTDY in the pool")
    ax.set_ylabel("% paid over the starting price")
    ax.set_title("Bigger trades move the price more", loc="left", color=ink)
    ax.legend(frameon=False)
    fig.tight_layout()
    fig.savefig(OUT / "market_slippage.png")
    print(f"\nsaved {OUT / 'market_slippage.png'}")


if __name__ == "__main__":
    main()
