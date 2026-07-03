---
type: tehnicko
status: aktivan
milestone: M6
tags: [tehnicko, godot, signali]
povezano:
  - _index
  - scene-node-pravila
  - arhitektura
ai_sažetak: "Komunikacija: signali prema gore, pozivi prema dolje; autoload singletoni za globalno stanje (M7)."
---

# Signali i komunikacija

## Osnovno pravilo

```
Dijete  ──(signal)──▶  Roditelj      "javljam da se nešto desilo"
Roditelj ──(poziv)──▶  Dijete        "naređujem ti da nešto uradiš"
```

- Dijete **ne zna** tko ga sluša (labava veza).
- Roditelj **zna** svoju djecu (može ih zvati direktno).

## Signali — deklaracija i emit

```gdscript
# orb.gd (dijete)
signal collected

func collect() -> void:
    collected.emit()
    queue_free()
```

```gdscript
# run_controller.gd (roditelj) — spoji pri instanciranju
orb.collected.connect(_on_orb_collected)

func _on_orb_collected() -> void:
    orb_count += 1
    _update_hud()
```

- Signali nose podatke kad treba: `signal run_ended(loot: int)` → `run_ended.emit(loot)`.
- Handler imenuj `_on_<izvor>_<signal>` (vidi [[konvencije-koda|konvencije-koda]]).

## Pozivi prema dolje

Roditelj slobodno zove javne metode djeteta:

```gdscript
player.set_input_enabled(false)
player.reset_lane()
```

## Kad NE koristiti signale

- Za "naredbu" prema poznatom djetetu → direktan poziv je jasniji.
- Za globalno stanje (orbovi u banci, unlockani upgradei) → **autoload**, ne lanac signala kroz pola stabla.

## Autoload singletoni (M7 — ne sad)

> ⚠️ Za M6 greybox držimo brojač **lokalno** u `run_controller.gd`. Autoloadi (`GameState`, `SaveManager`) dolaze u M7 kad postoji kamp i perzistencija. Ovdje su radi konteksta.

Plan iz [[../arhitektura|arhitektura]]:

```gdscript
# GameState.gd (autoload — Project Settings → Autoload)
extends Node

signal orbs_changed(total: int)

var total_orbs: int = 0

func add_orbs(amount: int) -> void:
    total_orbs += amount
    orbs_changed.emit(total_orbs)
```

Pristup od bilo kud: `GameState.add_orbs(loot)`. Autoload je globalni singleton — koristi ga za **stanje**, ne za gameplay logiku pojedine scene.

## Decoupling checklist

- [ ] Dijete ne poziva `get_parent().neka_metoda()` (krhko) — emitira signal.
- [ ] Nema `get_node("../../../Nešto")` lanaca — koristi signale ili `%UniqueName`.
- [ ] Globalno stanje u autoloadu, ne proslijeđeno kroz 5 node-ova.

## Povezano

- [[scene-node-pravila|scene-node-pravila]]
- [[../arhitektura|arhitektura]] — autoload lista
- [[_index|← Godot priručnik]]
