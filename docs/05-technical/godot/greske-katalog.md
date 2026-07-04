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
