# AGENTS — vodič za AI (Cursor) i Obsidian vault

> Vault root = `docs/`. Cursor workspace = cijeli repo (`Mobilna igra/`). Kod kasnije u `game/`.

## Početak sesije (redoslijed)

1. `docs/06-production/CHECKPOINT.md` — **samo frontmatter** (`aktivna_sekcija`, `sljedeci_korak`, `b0_aktivan`)
2. Ako `b0_aktivan: true` → kratki B0 podsjetnik; inače preskoči B0
3. Prva neoznačena `[ ]` u aktivnoj CHECKPOINT sekciji = sljedeći korak
4. Po potrebi: `RADIONICA-razvoj.md`, `milestone-i.md`, `otvorena-pitanja.md`

## Frontmatter šema

Puna dokumentacija: `docs/07-meta/frontmatter-shema.md`

| Polje | Obavezno | Značenje |
|-------|----------|----------|
| `type` | na novim docovima | `vision`, `dizajn`, `mehanika`, `sadrzaj`, `iskustvo`, `tehnicko`, `produkcija`, `adr`, `meta`, `personal` |
| `status` | da | `draft`, `aktivan`, `zatvoreno`, `out-v1`, `ideja` |
| `milestone` | ako relevantno | `M0`–`M8` ili `—` |
| `tags` | da | kratka lista |
| `povezano` | preporučeno | wiki imena bez putanje, npr. `core-loop`, `CHECKPOINT` |
| `ai_sažetak` | na ključnim stranicama | jedna rečenica — čitaj prije cijelog fajla |

Operativni hubovi (`CHECKPOINT`, `RADIONICA`) imaju dodatna polja — ne briši ih.

## Link konvencija

- Relativno od `docs/`: `[[06-production/CHECKPOINT|CHECKPOINT]]`
- Svaka nova stranica: link na roditeljski `_index` + min. 1 povezana tema
- Termini: `docs/07-meta/glossary.md`

## Što ne dirati bez razloga

- `docs/templates/` — predlošci
- `docs/00-personal/credentials.local.md` i `*.local.md` — **gitignore, tajne**
- Zatvorena B0 sekcija kad je `b0_aktivan: false`
- `.obsidian/app.json`, `daily-notes.json`, `templates.json` — dijeljena Obsidian konfiguracija

## Slojevi dokumentacije

| Folder | Svrha |
|--------|--------|
| `00-personal/` | Osobne bilješke (nije GDD) |
| `01-vision/` … `07-meta/` | Službena dokumentacija igre |
| `templates/` | Predlošci za nove note |

## Obsidian za korisnika

Setup upute: `docs/07-meta/obsidian-setup.md`

## Godot na HP laptopu (obavezno)

**AMD integrisana grafika** — Godot 4.7 **ne otvara projekte** bez OpenGL moda.

- **Uvijek:** `scripts/godot-open.ps1` ili `scripts/godot-open.bat`
- **Flag:** `--rendering-driver opengl3`
- **Ne** pokretati raw `Godot_v4.7-stable_win64.exe` dvostrukim klikom
- Detalji: `docs/05-technical/godot-dev-setup.md`
