#!/usr/bin/env python3
"""Builds docs/prototype.html: a self-contained click-through prototype.

Embeds the renders from docs/screenshots (regenerate them first with the
screenshots golden test) and overlays clickable hotspots wired to the same
navigation as the app. Run from the repository root:

    python3 tool/generate_prototype_html.py
"""
import base64
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SHOTS_DIR = ROOT / "docs" / "screenshots"
OUT = ROOT / "docs" / "prototype.html"

SHOTS = [
    "welcome", "sign_in", "account_summary", "account_transactions",
    "account_manage_card", "account_details", "credit_card",
    "transaction_details",
]

TITLES = {
    "welcome": "Welcome",
    "sign_in": "Member Sign In",
    "account_summary": "Account Summary",
    "account_transactions": "Transactions",
    "account_manage_card": "Manage Card",
    "account_details": "Account Details",
    "credit_card": "Credit Card",
    "transaction_details": "Transaction Details",
}

# Hotspots as (left%, top%, width%, height%, target screen).
TABS = [
    (0, 25.3, 33.3, 5.4, "account_transactions"),
    (33.3, 25.3, 33.3, 5.4, "account_manage_card"),
    (66.6, 25.3, 33.4, 5.4, "account_details"),
]
BACK = (2, 0.5, 14, 4, "account_summary")
HOTSPOTS = {
    "welcome": [
        (6, 84.2, 88, 6.2, "sign_in"),           # red "Log In"
        (6, 91.6, 88, 6.2, "account_summary"),   # "Log in with Biometrics"
    ],
    "sign_in": [
        (2, 1.2, 16, 4.2, "welcome"),
        (4, 55.8, 92, 5.8, "account_summary"),
    ],
    "account_summary": [
        (4, 37.3, 92, 5.8, "account_transactions"),
        (4, 44.6, 92, 5.7, "account_transactions"),
        (4, 52.0, 92, 5.7, "account_transactions"),
        (4, 64.4, 92, 12.5, "credit_card"),
        (4, 84.3, 92, 8.0, "account_transactions"),
    ],
    "account_transactions": [BACK] + TABS + [
        (4, 43.9, 92, 9.8, "transaction_details"),
    ],
    "account_manage_card": [BACK] + TABS,
    "account_details": [BACK] + TABS,
    "credit_card": [(2, 0.5, 14, 4, "account_summary")],
    "transaction_details": [(2, 0.5, 14, 4, "account_transactions")],
}

TEMPLATE = """<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>BECU Prototype — Click-through</title>
<style>
 body{{margin:0;background:#22272e;font-family:system-ui,sans-serif;
      display:flex;flex-direction:column;align-items:center;min-height:100vh}}
 header{{color:#cdd6e0;font-size:14px;padding:14px 16px 6px;text-align:center}}
 header b{{color:#fff}}
 #crumb{{color:#7ee2eb;font-weight:600}}
 .frame{{position:relative;width:min(402px,96vw);margin:10px 0 30px;
        border-radius:24px;overflow:hidden;box-shadow:0 12px 40px rgba(0,0,0,.55)}}
 .screen{{display:none;position:relative;line-height:0}}
 .screen.active{{display:block}}
 .screen img{{width:100%;height:auto}}
 .hs{{position:absolute;cursor:pointer;border-radius:8px}}
 .hs:hover{{background:rgba(0,124,137,.16);outline:2px solid rgba(126,226,235,.8)}}
</style></head><body>
<header><b>BECU mobile prototype</b> — click the highlighted areas to navigate
 &nbsp;·&nbsp; viewing: <span id="crumb"></span></header>
<div class="frame">
{screens}
</div>
<script>
function go(id){{
  document.querySelectorAll('.screen').forEach(s=>s.classList.remove('active'));
  const el=document.getElementById(id);
  el.classList.add('active');
  document.getElementById('crumb').textContent=el.dataset.title;
  window.scrollTo(0,0);
}}
go('welcome');
</script></body></html>"""


def main() -> None:
    screens = []
    for shot in SHOTS:
        data = base64.b64encode((SHOTS_DIR / f"{shot}.png").read_bytes()).decode()
        spots = "".join(
            f'<a class="hs" style="left:{l}%;top:{t}%;width:{w}%;height:{h}%" '
            f"onclick=\"go('{target}')\"></a>"
            for l, t, w, h, target in HOTSPOTS[shot]
        )
        screens.append(
            f'<div class="screen" id="{shot}" data-title="{TITLES[shot]}">'
            f'<img src="data:image/png;base64,{data}" alt="{TITLES[shot]}">'
            f"{spots}</div>"
        )
    OUT.write_text(TEMPLATE.format(screens="\n".join(screens)))
    print(f"wrote {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
