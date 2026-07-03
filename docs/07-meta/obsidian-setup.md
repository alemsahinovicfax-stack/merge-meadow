---
type: meta
status: aktivan
milestone: —
tags: [meta, obsidian]
povezano:
  - frontmatter-shema
  - CHECKPOINT
ai_sažetak: "Obsidian plugini, bookmarki i dnevni workflow za Merge Meadow vault."
---

# Obsidian setup — Merge Meadow

Vault = folder **`Mobilna igra`** (isti kao Cursor workspace).

## Već konfigurirano (u repo)

- Novi fajlovi → `docs/`
- Attachments → `docs/07-meta/reference/images`
- Daily notes → `docs/07-meta/daily/` + [[../templates/template-daily|template-daily]]
- Templates → `docs/templates/`
- `alwaysUpdateLinks: true`

## Plugini (instaliraj ručno)

| Plugin | Zašto |
|--------|--------|
| **Obsidian Linter** | Konzistentan YAML i markdown — manje grešaka kad agent editira |
| **Templater** (opcionalno) | Dinamički datum u predlošcima |
| **Folder Notes** (opcionalno) | `_index.md` kao folder note |
| **Dataview** (opcionalno) | Tvoj dashboard — agent ne vidi rezultate upita |

### Linter — preporučene opcije

- YAML keys sorted
- Heading style: ATX (`#`)
- Insert final newline
- Trailing spaces: remove

## Bookmarki (postavi jednom)

1. [[../06-production/CHECKPOINT|CHECKPOINT]]
2. [[../00-home|00-home]]
3. [[otvorena-pitanja|otvorena-pitanja]]
4. [[frontmatter-shema|frontmatter-shema]]

## Dnevni workflow

1. **Daily note** (Ctrl/Cmd+P → „Open today's daily note“)
2. U daily: link na CHECKPOINT + cilj dana
3. Rad u Cursoru
4. Na kraju: ažuriraj CHECKPOINT frontmatter + jedna linija u [[changelog|changelog]]

## Jedan vault

Stari `ObsidianNotes/` folder uklonjen — osobne note su u [[../00-personal/_index|00-personal]].

## Za AI

Vidi root [[../../AGENTS|AGENTS.md]] u Cursor workspaceu.
