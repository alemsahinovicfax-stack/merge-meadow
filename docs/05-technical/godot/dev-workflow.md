---
type: tehnicko
status: aktivan
milestone: M6
tags: [tehnicko, godot, workflow, testiranje]
povezano:
  - _index
  - godot-dev-setup
  - ../../06-production/testiranje
ai_sažetak: "Dev petlja: headless smoke-test PRIJE editora, F5 lokalno, export APK, Definition of Done, git po featureu."
---

# Dev workflow

Cilj: uhvatiti greške **prije** nego što ručno otvoriš editor/emulator. (Bug #1 iz [[greske-katalog|greske-katalog]] bi bio uhvaćen headless testom.)

## Petlja po featureu

```
1. Pročitaj relevantni doc (konvencije / scene / fizika ...)
2. Napiši kod
3. Headless smoke-test  ← hvata greške u _ready()/parse
4. F5 u editoru (miš = touch)
5. Kad feel treba provjeru → export APK na emulator
6. Označi Definition of Done
7. git commit (po featureu)
```

## 1. Godot se pokreće iz Cursor terminala

Vidi `.cursor/rules/godot-launch.mdc` i [[godot-dev-setup|godot-dev-setup]]:

```powershell
.\scripts\godot-run.ps1           # pokreni IGRU jednom (play prozor)
.\scripts\godot-run.ps1 -Editor   # otvori editor jednom
.\scripts\godot-open.ps1          # editor (alias, jednokratno)
.\scripts\godot-watch.ps1         # SAMO ručni rad: auto-restart na svaku izmjenu
```

Skripta dodaje `--rendering-driver opengl3` (HP AMD) i otvara `game/`. **Ne** dvostruki klik na exe.

**Pravilo paljenja:**

- **Agent** pali Godot **jednom, na kraju** rada preko `godot-run.ps1`. Tokom editiranja koristi headless smoke-test, ne GUI.
- **`godot-watch.ps1`** je za tvoj ručni rad kad ti sitno mijenjaš kod i želiš da se igra sama restarta. **Ne** pokrećeš ga dok agent radi — inače Godot bljeska na svaku izmjenu. Zaustavi s **Ctrl+C**.

## 2. Headless smoke-test (prije editora)

Provjeri da se projekt i scena učitaju bez grešaka, bez GUI-a:

```powershell
# učitaj projekt kratko i izađi (validira parse + _ready)
& "$env:USERPROFILE\Desktop\Godot_v4.7-stable_win64.exe" --headless --rendering-driver opengl3 --path "game" --quit-after 3
```

- Bilo koja greška u `_ready()` / parse skripte ispisuje se u konzolu ovdje.
- `--quit-after N` = odradi N frame-ova pa izađi.
- Ako konzola pokaže `SCRIPT ERROR` → popravi prije nego što otvoriš editor.

## 3. F5 u editoru

- Emulacija touch mišem je uključena (`emulate_touch_from_mouse`) — vidi [[input-touch|input-touch]].
- **Uvijek drži otvoren Output + Debugger panel** — 90% bugova se tamo prijavi.

## 4. Export APK (kad testiraš feel)

Ne treba za svaku promjenu — samo kad provjeravaš osjećaj na uređaju:

1. Project → Install Android Build Template (jednom po projektu)
2. Project → Export → Android → Export Project (Debug)
3. Pokreni na Pixel_4 emulatoru
4. Detalji: [[../platforme|platforme]]

## 5. Definition of Done (po featureu)

Feature je "gotov" kad:

- [ ] Statički tipiran, prati [[konvencije-koda|konvencije-koda]]
- [ ] Headless smoke-test bez `SCRIPT ERROR`
- [ ] F5 — feature radi kako je opisano
- [ ] Nema novih grešaka/warninga u Output panelu
- [ ] Odgovarajući CHECKPOINT checkbox označen
- [ ] (ako feel-relevantno) provjereno na emulatoru

## 6. Git po featureu

- Jedan feature/popravka = jedan commit (vidi `changelog.md`).
- Poruka: kratko *što* i *zašto* (npr. "fix: loot_overlay tip CanvasLayer — run se nije pokretao").
- Commit tek kad smoke-test prođe.
- Ne commitaj `game/.godot/`, `.import/`, `export/` (već u `.gitignore`).

## Brza referenca komandi

| Radnja | Komanda |
|--------|---------|
| **Pokreni igru jednom** | `.\scripts\godot-run.ps1` |
| Otvori editor jednom | `.\scripts\godot-run.ps1 -Editor` ili `.\scripts\godot-open.ps1` |
| Watch (ručni rad, auto-restart) | `.\scripts\godot-watch.ps1` |
| Headless smoke | `... --headless --path "game" --quit-after 3` |
| Ugasi Godot | `taskkill /IM Godot_v4.7-stable_win64.exe /F` |

## Povezano

- [[godot-dev-setup|godot-dev-setup]] — OpenGL launch
- [[greske-katalog|greske-katalog]] — što tražiti kad pukne
- [[../../06-production/testiranje|testiranje]] — QA faze
- [[_index|← Godot priručnik]]
