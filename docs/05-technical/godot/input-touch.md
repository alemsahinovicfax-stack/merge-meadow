---
type: tehnicko
status: aktivan
milestone: M6
tags: [tehnicko, godot, input, touch]
povezano:
  - _index
  - ../../02-design/kontrole-i-input
  - greske-katalog
ai_sažetak: "Touch/swipe input u Godotu — emulacija mišem, prag swipea, ignoriranje vertikale, enable/disable."
---

# Input i touch

Igra je **portrait, jednoručna** ([[../../02-design/kontrole-i-input|kontrole-i-input]]): swipe L/R u runu, drag u kampu (M7).

## Testiranje na desktopu — emulacija mišem

U `project.godot`:

```
[input_devices]
pointing/emulate_touch_from_mouse=true
```

Tako u editoru (F5) mišem simuliraš touch — ne treba emulator za svaku sitnicu. Ali obradi **oboje** u kodu jer emulacija ne pokriva sve rubne slučajeve.

## Swipe detekcija

Prati početak i kraj dodira, pa usporedi:

```gdscript
const SWIPE_THRESHOLD := 50.0   # px — ispod ovoga nije swipe

var _touch_start: Vector2 = Vector2.ZERO
var _touching: bool = false

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            _touch_start = event.position
            _touching = true
        elif _touching:
            _handle_swipe(event.position)
            _touching = false
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            _touch_start = event.position
            _touching = true
        elif _touching:
            _handle_swipe(event.position)
            _touching = false

func _handle_swipe(end_pos: Vector2) -> void:
    var delta := end_pos - _touch_start
    if absf(delta.x) < SWIPE_THRESHOLD:
        return                          # premalo — ignoriraj (tap)
    if absf(delta.x) < absf(delta.y):
        return                          # vertikalni pokret — nije lane swipe
    if delta.x > 0.0:
        _move_lane(1)
    else:
        _move_lane(-1)
```

## Pravila

- **Prag** (`SWIPE_THRESHOLD`) sprječava da tap slučajno mijenja lane.
- **Ignoriraj vertikalu** (`absf(delta.x) < absf(delta.y)`) da scroll gore/dolje ne triggera lane promjenu.
- **Enable/disable input** kad run nije aktivan (loot ekran):

```gdscript
func set_input_enabled(enabled: bool) -> void:
    _input_enabled = enabled

func _input(event: InputEvent) -> void:
    if not _input_enabled:
        return
    ...
```

## `_input` vs `_unhandled_input`

- `_input` — hvata sve, uklj. UI. Za gameplay swipe je OK dok UI ne raste.
- Kad dodamo UI dugmad (M7) razmisli o `_unhandled_input` da UI klikovi ne triggeraju gameplay swipe.

## Otvorena pitanja (za playtest B3)

- Kalibracija `SWIPE_THRESHOLD` na stvarnom Android ekranu (DPI razlike).
- Instant snap vs tween između laneova — [[../../02-design/mehanike/lane-run|lane-run]] otvoreno pitanje.

## Povezano

- [[../../02-design/kontrole-i-input|kontrole-i-input]] — dizajn kontrola
- [[greske-katalog|greske-katalog]]
- [[_index|← Godot priručnik]]
