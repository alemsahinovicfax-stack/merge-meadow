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
status: draft             # draft | aktivan | zatvoreno | out-v1 | ideja | koncept | arhiva
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

## `status` vrijednosti — pojašnjenje

| Vrijednost | Značenje |
|------------|----------|
| `draft` | Sadržaj postoji ali nije finalno potvrđen |
| `aktivan` | Trenutno važeći, održava se |
| `zatvoreno` | Gotovo, ne mijenja se, ali nije arhivirano (npr. završen milestone) |
| `out-v1` | Svjesno izvan scopea za v1 |
| `ideja` | Scratch/brainstorm, još nije odluka |
| `koncept` | **Hub `_index.md` fajlovi** — nema svoj sadržaj, samo linkovi na djecu |
| `arhiva` | Fajl je premješten u `_archive/` — zamijenjen novijim dokumentom, zadržan kao historijski zapis |

## Operativni hubovi (dodatna polja)

`CHECKPOINT.md` zadržava svoja dodatna polja (`aktivna_sekcija`, `b0_aktivan`, `sljedeci_korak`, …). Ne prepisuj ih generičkom šemom. (`RADIONICA-razvoj.md`/`milestone-i.md`/`roadmap.md` su arhivirani u `06-production/_archive/` — CHECKPOINT je jedini izvor istine za fazu/milestone.)

## Za agenta

- **`ai_sažetak`** — čitaj prvo; ako dovoljno, ne čitaj cijeli fajl
- **`povezano`** — lista imena nota; ekvivalent eksplicitnih backlinkova
- Dataview upiti u noteu **ne izvršavaju se** u Cursoru — istina mora biti u YAML ili CHECKPOINT-u

## Predlošci

- [[../templates/template-doc|template-doc]] — generički doc
- [[../templates/template-daily|template-daily]] — dnevna nota
- [[../templates/template-mehanika|template-mehanika]] · [[../templates/template-lik|template-lik]] · [[../templates/template-nivo|template-nivo]] · [[../templates/template-odluka|template-odluka]]
