---
type: meta
status: aktivan
milestone: —
tags: [meta, obsidian, agent]
povezano:
  - AGENTS
  - CHECKPOINT
ai_sažetak: "Standardna YAML polja za sve note — agent čita frontmatter prije tijela."
---

# Frontmatter šema

Kopiraj u nove note ili koristi [[../templates/template-doc|template-doc]].

## Obavezna polja (GDD docovi)

```yaml
---
type: dizajn              # vision | dizajn | mehanika | sadrzaj | iskustvo | tehnicko | produkcija | adr | meta | personal
status: draft             # draft | aktivan | zatvoreno | out-v1 | ideja
milestone: M6             # M0–M8 ili —
tags: [dizajn, core-loop]
povezano:
  - core-loop
  - gdd-overview
ai_sažetak: "Jedna rečenica što ova stranica govori agentu."
---
```

## `type` vrijednosti

| Vrijednost | Folder |
|------------|--------|
| `vision` | `01-vision/` |
| `dizajn` | `02-design/` |
| `mehanika` | `02-design/mehanike/` |
| `sadrzaj` | `03-content/` |
| `iskustvo` | `04-experience/` |
| `tehnicko` | `05-technical/` |
| `produkcija` | `06-production/` |
| `adr` | `05-technical/odluke/` |
| `meta` | `07-meta/` |
| `personal` | `00-personal/` |

## Operativni hubovi (dodatna polja)

`CHECKPOINT.md` i `RADIONICA-razvoj.md` zadržavaju svoja polja (`trenutna_faza`, `aktivna_sekcija`, `b0_aktivan`, …). Ne prepisuj ih generičkom šemom.

## Za agenta

- **`ai_sažetak`** — čitaj prvo; ako dovoljno, ne čitaj cijeli fajl
- **`povezano`** — lista imena nota; ekvivalent eksplicitnih backlinkova
- Dataview upiti u noteu **ne izvršavaju se** u Cursoru — istina mora biti u YAML ili CHECKPOINT-u

## Predlošci

- [[../templates/template-doc|template-doc]] — generički doc
- [[../templates/template-daily|template-daily]] — dnevna nota
- [[../templates/template-mehanika|template-mehanika]] · [[../templates/template-lik|template-lik]] · [[../templates/template-nivo|template-nivo]] · [[../templates/template-odluka|template-odluka]]
