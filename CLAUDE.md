# CLAUDE.md — Merge Meadow (agent vodič, kanonski)

> Ovo je **kanonski** izvor pravila ponašanja za AI agente na ovom projektu (Claude Code čita ovaj fajl automatski). `AGENTS.md` i `.cursor/rules/*.mdc` su tanki pokazivači na ovaj fajl — ne diraj oboje odvojeno, drift između kopija je upravo ono što je ovaj reorg riješio (vidi `docs/06-production/CHECKPOINT.md` § Povezano za historiju).

Vault root = `docs/`. Repo root = cijeli `Mobilna igra/`. Kod = `game/` (Godot 4.x).

## Početak sesije (redoslijed)

1. `docs/06-production/CHECKPOINT.md` — **samo frontmatter** (`aktivna_sekcija`, `sljedeci_korak`, `b0_aktivan`, `milestone`)
2. Ako `b0_aktivan: true` → kratki B0 podsjetnik; inače **ne spominji B0** (0 tokena)
3. Prva neoznačena `[ ]` u aktivnoj CHECKPOINT sekciji = sljedeći korak
4. Po potrebi dalje: `docs/06-production/otvorena-pitanja.md`, `docs/06-production/scope-i-granice.md`
5. Scratch ideje: `docs/06-production/ideje-kad-predloziti.md` — ponudi **max 1** kad trigger odgovara koraku (§ Proaktivne ideje niže)

`CHECKPOINT.md` je **jedini izvor istine** za fazu/milestone — `RADIONICA-razvoj.md`/`milestone-i.md`/`roadmap.md` su arhivirani (`docs/06-production/_archive/`), zamrznuti prije M7/M8, ne koristi ih za trenutno stanje.

## Scope guard (obavezno prije nove feature/većeg koda)

1. Pročitaj CHECKPOINT frontmatter — trenutni `milestone`
2. Pročitaj `docs/06-production/scope-i-granice.md` — nađi red za **taj isti milestone** u tablici "Scope po milestoneu" (IN/OUT). Ne pamti scope statično ovdje — čitaj uživo svaki put, scope se mijenja kako projekt napreduje.
3. Provjeri `docs/01-vision/design-pillars.md` — krši li Pillar 2 (Fair F2P)? Pillar 2 se **nikad ne žrtvuje**.

Kad nešto nije u scopeu trenutnog milestonea ili je na OUT listi, **zaustavi se** i napiši:

```
⚠️ SCOPE — izvan trenutnog koraka
Traženo: [kratko]
Trenutno: M__ / CHECKPOINT [sekcija] — dozvoljeno: [lista iz scope-i-granice.md]
Status: [OUT za v1 | IN ali tek u M7/M8 | krši Pillar __]
Preporuka: [odgodi ILI ažuriraj scope-i-granice.md ako svjesno mijenjamo plan]
```

Ne implementiraj OUT feature dok korisnik eksplicitno ne potvrdi (i tada prvo ažuriraj `scope-i-granice.md`).

**Izuzeci:** bugfix/refaktor unutar trenutne checkpoint stavke — OK bez upozorenja. Korisnik kaže "dodaj u scope" → ažuriraj `scope-i-granice.md` + `changelog.md`, pa implementiraj.

## Frontmatter šema

Puna dokumentacija: `docs/07-meta/frontmatter-shema.md`.

| Polje | Obavezno | Značenje |
|-------|----------|----------|
| `type` | na novim docovima | `vision`, `dizajn`, `mehanika`, `sadrzaj`, `iskustvo`, `tehnicko`, `produkcija`, `adr`, `meta`, `personal` |
| `status` | da | `draft`, `aktivan`, `zatvoreno`, `out-v1`, `ideja`, `koncept` (hub `_index.md`), `arhiva` (`_archive/`) |
| `milestone` | ako relevantno | `M0`–`M8` ili `—` |
| `tags` | da | kratka lista |
| `povezano` | preporučeno | wiki imena bez putanje, npr. `core-loop`, `CHECKPOINT` |
| `ai_sažetak` | na ključnim stranicama | jedna rečenica — čitaj prije cijelog fajla |

`CHECKPOINT.md` zadržava dodatna polja (`aktivna_sekcija`, `b0_aktivan`, `sljedeci_korak`, …) — ne prepisuj ih generičkom šemom.

## Link konvencija

- Relativno od `docs/`: `[[06-production/CHECKPOINT|CHECKPOINT]]`
- Svaka nova stranica: link na roditeljski `_index` + min. 1 povezana tema
- Termini: `docs/07-meta/glossary.md`
- Kad arhiviraš doc u `_archive/`: dodaj banner `> Arhivirano YYYY-MM-DD — zamijenjeno sa X` na vrh, i ažuriraj eksplicitne relativne linkove (bare `[[wikilink]]` imena obično ne treba dirati — Obsidian ih rezolvira po imenu bez obzira na folder)

## Što ne dirati bez razloga

- `docs/templates/` — predlošci
- `docs/00-personal/credentials.local.md` i `*.local.md` — **gitignore, tajne**
- Zatvorena B0 sekcija kad je `b0_aktivan: false`
- `.obsidian/app.json`, `daily-notes.json`, `templates.json` — dijeljena Obsidian konfiguracija

## Proaktivne ideje (max 1 po sesiji)

Ponudi scratch ideju iz `docs/03-content/ideje-*.md` samo kad: (1) trenutni CHECKPOINT korak se poklapa s trigger tablicom u `docs/06-production/ideje-kad-predloziti.md`, (2) korisnik direktno dira tu oblast, ili (3) na kraju sesije ako pomaže sljedećem koraku. **Ne** predlaži usred hitnog bugfixa niti OUT-scope feature. Format:

```
💡 IDEJA [ID] — naslov
Zašto sada: … / Što: … / Effort: S/M/L · Milestone: …
Primjeniti sada, odgoditi, ili preskočiti?
```

Ne implementiraj dok korisnik ne potvrdi.

## Git — solo (master)

- **Default grana:** `master` — radi i pushaj direktno, bez feature grana i PR-ova osim ako korisnik eksplicitno traži
- **Ne predlagati** feature grane ni PR proaktivno — samo za eksperiment/risky refactor na eksplicitan zahtjev
- **Remote = engleski:** commit poruke, branch imena, PR tekst (lokalno docs/chat mogu ostati na hrvatskom)
- **Commit samo kad korisnik eksplicitno traži** — ne commitaj proaktivno
- Push na kraju sesije ili na zahtjev: `git push origin master`

## Godot na HP laptopu (obavezno)

**AMD integrisana grafika** — Godot 4.7 ne otvara projekte bez OpenGL moda.

- **Uvijek:** `scripts/godot-open.ps1`/`.bat` ili `scripts/godot-run.ps1` (dodaje `--rendering-driver opengl3` automatski)
- **Ne** pokretati raw `Godot_v4.7-stable_win64.exe` dvostrukim klikom ili bez flaga
- **Pali Godot samo JEDNOM, na kraju sesije/prompta**, nakon što su izmjene + headless smoke-test gotovi
- **Ne** pokreći `godot-watch.ps1` dok editiraš kod — to je isključivo za korisnikov ručni rad (auto-restart na svaku izmjenu bi višestruko palio Godot usred agent rada)
- Za provjeru grešaka tokom rada koristi **headless smoke-test** (`--headless ... --quit-after N`), ne GUI
- Detalji: `docs/05-technical/godot-dev-setup.md`, `docs/05-technical/godot/dev-workflow.md`

## Pisanje Godot koda (game/)

Prije pisanja/izmjene koda u `game/` konzultiraj **Godot priručnik**: `docs/05-technical/godot/_index.md`.

- Konvencije: statičko tipiranje, `snake_case`, redoslijed u skripti (`konvencije-koda.md`)
- **Tip u `@onready` mora odgovarati tipu node-a u sceni** (`scene-node-pravila.md`; čest bug — `greske-katalog.md` #1)
- Kolizije: layer/mask tablica (`fizika-kolizije.md`)
- Prije "gotovo": **headless smoke-test** (`dev-workflow.md`)
- Kad nešto pukne i potrošiš vrijeme → dodaj unos u `greske-katalog.md`
- Kod arhitektura refaktor (GameState split, naming, GUT testing) je planiran za **nakon trenutnog feature-a** — vidi `docs/06-production/plan-arhitektura-refaktor.md`, ne kreni na to usput

## Novi asset u game/assets/ (C2+)

Novi PNG/SVG **nije odmah učitljiv** — `load()` vraća `null` dok Godot ne napravi `.import` + `.godot/imported/*.ctex` (Pip-nevidljiv bug, 2026-07-06, `greske-katalog.md` #6).

1. Pokreni `.\scripts\godot-import.ps1` (ili `godot-run.ps1`, radi import automatski)
2. Commitaj `*.import` uz raw fajl (npr. `pip_idle.svg.import`)
3. U kodu: `PipAssets.get_texture()` + fallback na `PipDraw` ako texture null
4. Headless provjera: `ResourceLoader.exists("res://assets/...")` prije playtesta

Figma → igra: korisnik exportuje **PNG** (transparent) u `game/assets/sprites/`, agent importa + wire-a. Detalji: `docs/04-experience/ui-i-art-alati.md`.

## Slojevi dokumentacije

| Folder | Svrha |
|--------|--------|
| `00-personal/` | Osobne bilješke (nije GDD) |
| `01-vision/` … `07-meta/` | Službena dokumentacija igre |
| `templates/` | Predlošci za nove note |
| `*/_archive/` | Superseded dokumenti — historijski zapis, ne ažurirati |

## Reference

- [[docs/06-production/CHECKPOINT|CHECKPOINT]] — dnevni operativni hub
- [[docs/06-production/scope-i-granice|scope-i-granice]] — IN/OUT po milestoneu
- [[docs/07-meta/frontmatter-shema|frontmatter-shema]]
- [[docs/05-technical/godot/_index|Godot priručnik]]
