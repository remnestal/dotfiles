#!/usr/bin/env python3
"""Claude Code status line.
Left → right: pwd (basename) | local HH:MM + UTC offset | model
              | context bar+tokens (blue) | 5h usage % + reset countdown (threshold color)
"""
import json, os, sys
from datetime import datetime

RESET = "\x1b[0m"; BOLD = "\x1b[1m"; DIM = "\x1b[2m"
BLUE = "\x1b[34m"; GREEN = "\x1b[32m"; YELLOW = "\x1b[33m"
ORANGE = "\x1b[38;5;208m"; RED = "\x1b[31m"  # orange needs 256-color (not 8-color ANSI)

FILL, EMPTY, W = "●", "○", 10           # dot bar

def bar(label, pct, color, text=None):
    pct = max(0.0, min(100.0, pct))
    filled = round(pct * W / 100)
    value = text if text is not None else f"{int(round(pct))}%"
    return f"{DIM}{label}{RESET} {color}{FILL * filled}{RESET}{DIM}{EMPTY * (W - filled)}{RESET} {color}{value}{RESET}"

def fmt_tokens(n):
    n = int(n)
    return f"{n / 1000:.0f}K" if n >= 1000 else str(n)

def usage_color(p):
    if p < 70: return GREEN
    if p < 80: return YELLOW
    if p < 90: return ORANGE
    return RED

def fmt_remaining(secs):
    secs = max(0, int(secs))
    d, rem = divmod(secs, 86400); h, rem = divmod(rem, 3600); m = rem // 60
    if d: return f"{d}d{h}h"
    if h: return f"{h}h{m:02d}m"
    return f"{m}m"

def main():
    data = json.load(sys.stdin)

    # pwd basename, far left (just the current dir name, e.g. "dotfiles")
    cwd = data.get("cwd") or data.get("workspace", {}).get("current_dir", "")
    name = os.path.basename(cwd.rstrip("/")) or cwd or "?"
    segs = [f"{BOLD}{name}{RESET}"]

    # clock + UTC offset (handles fractional offsets like +5:30)
    now = datetime.now().astimezone()
    tot = int(now.utcoffset().total_seconds() // 60)
    sign = "+" if tot >= 0 else "-"
    oh, om = divmod(abs(tot), 60)
    utc = f"{sign}{oh}" if om == 0 else f"{sign}{oh}:{om:02d}"
    segs.append(f"{BOLD}{now:%H:%M}{RESET} {DIM}UTC{utc}{RESET}")

    # model
    segs.append(f"{DIM}{data.get('model', {}).get('display_name', '?')}{RESET}")

    # context: blue dot bar (fill from used_percentage) + actual tokens in context.
    # total_input_tokens is the numerator behind used_percentage (input + cache
    # read/write), so the number matches the bar; both may be null/0 early on.
    cw = data.get("context_window") or {}
    cpct = cw.get("used_percentage")
    ctok = cw.get("total_input_tokens")
    segs.append(bar("ctx", 0 if cpct is None else cpct, BLUE,
                    text=fmt_tokens(ctok) if ctok is not None else None))

    # 5-hour usage: threshold-colored bar + % + reset countdown (rate_limits is
    # absent for API-key users and before the first API response — drop when missing)
    fh = (data.get("rate_limits") or {}).get("five_hour") or {}
    up = fh.get("used_percentage")
    if up is not None:
        seg = bar("usg", up, usage_color(int(round(up))))
        ra = fh.get("resets_at")
        if ra is not None:
            seg += f" {DIM}({fmt_remaining(ra - datetime.now().timestamp())}){RESET}"
        segs.append(seg)

    print(f" {DIM}│{RESET} ".join(segs))

if __name__ == "__main__":
    main()
