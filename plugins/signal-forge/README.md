# signal-forge

Turn messy sources into reusable **extraction cards**, let an advisory panel decide what to build, then rebuild one cited system. Everything runs inside Claude (Claude Code or Cowork): no API key, no server.

```
Sources A, B, C
   │  template per source: system-prompt · sop-handbook · api-spec · research-paper · meeting-notes
   ▼
① high-signal-data-architect   → standalone, executable cards (one file each, @Frag loci)
   │
   ▼
② get-more-perspectives         → panel votes + RECONSTRUCTION DIRECTIVE (cites card IDs)
   │  pauses only if the panel split → you decide (DECISION @user)
   ▼
③ reverse-engineer              → unified system + SURFACED CONFLICTS + GAPS
   │
   ▼
report.html                     → Spec · Conflicts · Gaps · Directive · Cards
```

## Extraction cards

Each card is one Markdown file with a YAML header (`card_id`, `card_type`, `template`, `version`, `source` loci, `tags`, `inputs`, `outputs`) and a fixed body (Purpose, When to run, Inputs, Procedure, Rules, Output, If something fails, Do not overread, Self-check).

- **Standalone:** a card never points to another card; every term it uses is defined inside it.
- **Executable:** the body reads as instructions. Paste a card into any Claude conversation, or save it as a `SKILL.md`, and it runs.
- **Repeatable:** card IDs come from the fragment, type and the source's own wording, so the same source and template give the same cards on every run.

The format is in `skills/high-signal-data-architect/card-format.md`; the five use-case templates are in `skills/high-signal-data-architect/templates/`.

## Use

- `/forge` with pasted or attached sources runs the whole chain and writes `forge-output/<run-slug>/` (cards, directive, result, `report.html`).
- Each skill also works on its own. The panel can be used for any generative-AI or invention decision.

`skills/forge/build_report.py` builds the HTML report with the Python standard library only.

## Install (Claude Code)

```
/plugin marketplace add Elycium/superpowers
/plugin install signal-forge@superpowers-dev
```

For Cowork, upload the zipped `plugins/signal-forge/` folder as a plugin.

Shared notation: `[S1: Action] @FragA:P2`, `->` sequence, `+` concurrency, `?` decision, `|` branch. Labels: `@FragA:P2` source fact, `DECISION @panel (4–1)` panel ruling, `DECISION @user` your decision.
