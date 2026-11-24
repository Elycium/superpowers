#!/usr/bin/env python3
"""Build report.html for a signal-forge run. Standard library only; no network.

Usage:
    python3 build_report.py <run-folder>

<run-folder> is forge-output/<run-slug>/ and may contain:
    run.json      {"title", "date", "fragments": [{"id","name","template"}],
                   "decisions": [{"question","answer"|null}], "models"}
    result.md     the reverse-engineer output
    directive.md  the panel review + RECONSTRUCTION DIRECTIVE
    cards/*.md    extraction cards (INDEX.md is skipped)

Writes <run-folder>/report.html next to them. Missing files are fine; their
tabs show an empty state.
"""

import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
TEMPLATE = HERE / "report-template.html"
PLACEHOLDER = "/*FORGE_DATA*/"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8") if path.is_file() else ""


def front_matter(md: str) -> dict:
    """Reads the flat top-level keys we need from a card's YAML header."""
    m = re.match(r"^---\n(.*?)\n---\n", md, re.S)
    if not m:
        return {}
    out = {}
    for line in m.group(1).splitlines():
        kv = re.match(r"^([a-z_]+):\s*(.*?)\s*$", line)
        if kv and kv.group(2) and not kv.group(2).startswith(("[", "{")):
            out[kv.group(1)] = kv.group(2).strip("\"'")
    return out


def section(md: str, pattern: str) -> str:
    """Body of the first ##/###/#### heading matching pattern, up to the next ## or ### heading."""
    lines = md.splitlines()
    for i, line in enumerate(lines):
        if re.match(r"^#{2,4}\s", line) and re.search(pattern, line, re.I):
            body = []
            for nxt in lines[i + 1:]:
                if re.match(r"^#{2,3}\s", nxt):
                    break
                body.append(nxt)
            return "\n".join(body).strip()
    return ""


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    run = Path(sys.argv[1]).resolve()
    if not run.is_dir():
        print(f"Not a folder: {run}")
        return 1

    meta = json.loads(read(run / "run.json") or "{}")
    result_md = read(run / "result.md")

    cards = []
    for path in sorted((run / "cards").glob("*.md")) if (run / "cards").is_dir() else []:
        if path.name.upper() == "INDEX.MD":
            continue
        md = read(path)
        fm = front_matter(md)
        cards.append({
            "card_id": fm.get("card_id", path.stem),
            "card_type": fm.get("card_type", ""),
            "title": fm.get("title", path.stem),
            "version": fm.get("version", ""),
            "markdown": md,
        })

    # Keep the order from INDEX.md (source order) when it exists.
    index = read(run / "cards" / "INDEX.md")
    order = re.findall(r"^\|\s*`?([A-Z]{1,2}-[a-z]+-[\w-]+)`?\s*\|", index, re.M)
    if order:
        rank = {cid: i for i, cid in enumerate(order)}
        cards.sort(key=lambda c: rank.get(c["card_id"], len(rank)))

    data = {
        "title": meta.get("title") or run.name,
        "slug": run.name,
        "date": meta.get("date", ""),
        "models": meta.get("models", ""),
        "fragments": meta.get("fragments", []),
        "decisions": meta.get("decisions", []),
        "result_md": result_md,
        "conflicts_md": section(result_md, r"CONFLICT"),
        "gaps_md": section(result_md, r"GAP"),
        "directive_md": read(run / "directive.md"),
        "cards": cards,
    }

    # "</" must not appear raw inside a <script> element.
    payload = json.dumps(data, ensure_ascii=False).replace("</", "<\\/")
    html = TEMPLATE.read_text(encoding="utf-8")
    if PLACEHOLDER not in html:
        print("Template is missing its data placeholder.")
        return 1
    out = run / "report.html"
    out.write_text(html.replace(PLACEHOLDER, payload, 1), encoding="utf-8")
    print(f"Wrote {out} ({len(cards)} cards)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
