---
type: tehnicko
status: aktivan
milestone: M6
tags: [tehnicko, godot, greske, gotchas]
povezano:
  - _index
  - scene-node-pravila
  - dev-workflow
ai_sažetak: "Živa lista naučenih Godot grešaka u projektu — simptom, uzrok, rješenje. Dodaj novi unos kad nešto pukne."
---

# Katalog grešaka (gotchas)

> **Živa lista.** Kad nešto pukne i potrošiš vrijeme na to — dodaj unos ovdje. Format: **Simptom → Uzrok → Rješenje → Prevencija.**

---

## #1 — `@onready` tip ne odgovara node-u u sceni

**Datum:** 2026-07-03 (M6 B2, prvi playtest)

**Simptom:**
- Swipe radi (kvadratić se pomiče), ALI tajmer stoji na "75s", orb brojač na 0, ništa se ne spawna ni ne kreće.

**Uzrok:**
```gdscript
@onready var loot_overlay: Control = $LootOverlay   # LootOverlay je CanvasLayer!
```
`CanvasLayer` nije `Control`. Godot baci grešku pri izvršavanju te linije u `_ready()` i **prekine ostatak `_ready()`** — `_start_run()` se nikad ne pozove, `run_active` ostane `false`, pa `_process()` odmah izlazi (`if not run_active: return`). Swipe radi jer je `player.gd` nezavisna skripta.

**Rješenje:**
```gdscript
@onready var loot_overlay: CanvasLayer = $LootOverlay   # tip = tip u sceni
```

**Prevencija:**
- [[scene-node-pravila|scene-node-pravila]] "Zlatno pravilo": tip u `@onready` = tip node-a u sceni.
- **Headless smoke-test** ([[dev-workflow|dev-workflow]]) bi ovu grešku ispisao u konzolu prije nego što se otvori editor.
- Prati Godot **Output/Debugger panel** — greška je bila tamo, samo neuhvaćena.

---

## #2 — `_draw()` na `Area2D` + Control portrait size 0

**Datum:** 2026-07-04 (F1 Pip placeholder)

**Simptom:**
- U runu se vidi samo HUD tekst "Pip" gore lijevo; zeko se ne crta na dnu ekrana.
- Main menu / HUD portrait prazan (samo layout).

**Uzrok:**
1. Custom `_draw()` na `Area2D` nije pouzdano vidljiv u play modu (collision node, ne vizualni).
2. `Control` s `custom_minimum_size` ali `size == (0,0)` prije layouta → `scale = 0` u `_draw()`.

**Rješenje:**
- Pip vizual kao **`Node2D` child** (`PipVisual` + `pip_visual.gd`) koji crta u `_draw()`.
- UI portrait: `_ensure_size()` + `NOTIFICATION_RESIZED` u `pip_placeholder_control.gd`.

**Prevencija:**
- Vizual lika = **Node2D/Sprite2D child**, ne `_draw()` na `Area2D`.
- UI custom draw: provjeri `size` prije crtanja.

---

## #3 — Viewport 0×0 u `_ready()` → Pip gore lijevo, nema laneova

**Datum:** 2026-07-04 (F2)

**Simptom:**
- Pip u gornjem lijevom kutu (0,0); nema vertikalnih traka; spawn/scroll ne radi ili je sve na jednoj točki.

**Uzrok:**
`get_viewport_rect().size` u `_ready()` ponekad još **0×0** → `lane_x_positions = [0,0,0]`, `player.position.y = 0`.

**Rješenje:**
- `await` dok viewport nije ≥ 100 px visine prije `_calculate_lanes()`.
- Lane guide: **`Line2D`** umjesto `ColorRect` pod `Node2D`.

**Prevencija:** `_wait_for_viewport()` pri svakom world setupu; ne računaj lane pozicije u prvom frameu bez provjere.

---

## #4 — `CONNECT_DEFERRED` na `Button.pressed` ne poziva handler

**Datum:** 2026-07-04 (M7)

**Simptom:**
- Hover i pressed vizual gumba rade, ali ništa se ne dogodi (ni Double tekst, ni promjena scene).

**Uzrok:**
`button.pressed.connect(_on_pressed, CONNECT_DEFERRED)` — na Godot 4.7 + touch emulacija callback se ne izvrši.

**Rješenje:** spoji `pressed` **bez** `CONNECT_DEFERRED`; scene change u handleru preko `call_deferred("_do_change_scene", path)` na istom Control nodeu.

**Prevencija:** [[scene-node-pravila|scene-node-pravila]].

---

## #5 — `emulate_touch_from_mouse` lomi UI klik na desktopu

**Datum:** 2026-07-04 (M7)

**Simptom:**
- Hover i pressed **vizual** gumba rade; `Button.pressed` / handler se **ne pozove** (miš na Windowsu).

**Uzrok:**
`project.godot` → `pointing/emulate_touch_from_mouse=true` — klik miša postane touch event; `BaseButton.pressed` često ne okine handler (Godot 4.7).

**Rješenje:**
1. `emulate_touch_from_mouse=false` u `project.godot` + `Input.emulate_touch_from_mouse = false` u `GameState._ready()` (runtime sigurnost).
2. **`UiClickButton` extends `PanelContainer`** (ne `Button`) — hvata miš + touch u `gui_input`, emituje `clicked`. BaseButton interno guta signale na desktopu.
3. `SceneRouter` autoload za promjenu scene iz UI-a.

**Prevencija:** svi gameplay UI gumbi koriste `UiClickButton`; scene change preko `SceneRouter`.

---

## #6 — Novi sprite nevidljiv (`load()` = null)

**Datum:** 2026-07-06 (C2 Pip art pass)

**Simptom:**
- Pip (ili drugi PNG/SVG) **potpuno nevidljiv** u runu i UI; nema `SCRIPT ERROR`.

**Uzrok:**
Novi fajl u `game/assets/` dodan izvan editora. Godot **nije importao** asset → `ResourceLoader.exists()` = false → `load()` vraća `null` → `Sprite2D` bez texture.

**Rješenje:**
1. `.\scripts\godot-import.ps1` (ili `godot-run.ps1` koji sada import radi automatski)
2. Commit **`pip_idle.svg.import`** uz source fajl
3. `pip_assets.gd`: provjeri `ResourceLoader.exists` + fallback na `PipDraw`

**Prevencija:**
- [[dev-workflow|dev-workflow]] — import prije playtesta
- `.cursor/rules/godot-assets-import.mdc`
- Agent: nakon novog asseta uvijek `godot-import.ps1`

---

## #7 — Android emulator: "Unable to set up Godot engine" / crni ekran

**Datum:** 2026-07-09 (D4 screenshot prep), prošireno 2026-07-10

**Simptom:**
- Klik na ikonu igre u emulatoru → **Unable to set up Godot engine** (ili crni ekran).
- Logcat: `createContext failed: EGL_SUCCESS` ili `Couldn't present to Vulkan queue (VkResult error 5)`.

**Uzrok (lanac):**

| # | Problem | Simptom |
|---|---------|---------|
| 1 | Stari test APK (`com.example.newgameproject`) | Pogrešna app / crash |
| 2 | Export bez **x86_64** ABI | APK ne radi na Pixel AVD |
| 3 | **API 30 system image** → guest `ANDROID_EMU_gles_max_version_2` (GLES 2 only) | Godot 4 `gl_compatibility` treba **GLES 3+** → `createContext failed: EGL_SUCCESS` |
| 4 | Stale export cache → manifest `rendering.method=mobile` (Vulkan) | Engine starta, ali crni ekran (Vulkan queue error) |
| 5 | **SwiftShader** na API 33 | Godot starta, ali shader uniform limit (261) — koristi **`-gpu host`** |

**Rješenje (provjereno 2026-07-10):**

1. Instaliraj **API 33+** system image (`google_apis` ili `google_apis_playstore`, x86_64):
   ```powershell
   sdkmanager "system-images;android-33;google_apis;x86_64"
   ```
2. Kreiraj AVD **Pixel_4_API33** (skripta ispod to radi automatski).
3. Pokreni emulator s **host GPU** (AMD integrisana OK na API 33):
   ```powershell
   .\scripts\start-android-emulator.ps1              # Pixel_4_API33, -gpu host
   .\scripts\android-launch-game.ps1                 # install + start + logcat
   ```
4. Export: `x86_64=true`, manifest `gl_compatibility`, `merge_meadow_debug.apk`.
5. **Ne koristi Pixel_4 (API 30)** za Godot 4 — guest je uvijek GLES 2, bez obzira na SwiftShader/host.

**Prevencija:**
- `export_presets.cfg`: `x86_64=true`, `command_line/extra_args="--rendering-driver opengl3"`.
- `project.godot`: `renderer/rendering_method.mobile="gl_compatibility"`.
- Dev emulator: **Pixel_4_API33** (ne API 30 s default GPU).
- Screenshot tek nakon svježeg exporta iz `game/`.

---

## #8 — Loot → Camp: dupli klik pokreće Play

**Datum:** 2026-07-10

**Simptom:** Fail loot → **To Camp** → kamp se otvori, ali odmah krene novi run.

**Uzrok:** `camp_controller._unhandled_input` hvata **mouse release** na Play poziciji. To Camp i Play su skoro isti Y; release nakon scene change aktivira Play.

**Rješenje:**
1. Uklonjen dupli button routing iz `camp_controller` (`UiClickButton.clicked` je dovoljan).
2. `SceneRouter` blokira UI input 400 ms nakon `change_to`.
3. `UiClickButton` ignorira input dok je block aktivan.
4. Loot zaključava gumbe pri odlasku u kamp.

**Prevencija:** ne dodavati `_unhandled_input` release-handling za gumbe s `UiClickButton`.

---

## #9 — Autoload `GameState` ne učitava → Play (i sve) ne radi

**Datum:** 2026-07-12 (D0 / Mochi)

**Simptom:** Main menu **Play** ne reagira; u Godot outputu `Invalid access ... on Nil` za `GameState`.

**Uzrok:** Parse error u `game_state.gd` — `mochi_unlock_seen` korišten u save/load bez `var` deklaracije. Cijeli autoload padne; global `GameState` je `null`.

**Rješenje:** Dodati `var mochi_unlock_seen: bool = false` uz ostale companion varijable.

**Prevencija:** headless `--verbose` ili `--quit-after 3` — provjeri da se `GameState` pojavi u root children; svaka nova save polja mora imati `var`.

---

## Kako dodati novi unos

```markdown
## #N — kratak naslov

**Datum:** YYYY-MM-DD (milestone/checkpoint)

**Simptom:** što se vidi / ne radi.

**Uzrok:** prava tehnička greška.

**Rješenje:** konkretna promjena (kod/postavka).

**Prevencija:** koje pravilo/doc ovo sprječava ubuduće.
```

## Brza dijagnostika (kad nešto "ne radi")

1. **Otvori Debugger/Output panel** u Godotu — greška je skoro uvijek tu.
2. Pokreni **headless smoke-test** ([[dev-workflow|dev-workflow]]) — vidiš greške bez GUI-a.
3. "Radi X ali ne Y?" → vjerojatno je nešto u `_ready()` puklo pa je Y neinicijaliziran.
4. Node reference `null`? → kriva putanja `$Path` ili tip u `@onready`.
5. Kolizija ne radi? → [[fizika-kolizije|fizika-kolizije]] layer/mask tablica.

## Povezano

- [[scene-node-pravila|scene-node-pravila]]
- [[dev-workflow|dev-workflow]]
- [[_index|← Godot priručnik]]
