---
type: tehnicko
status: aktivan
milestone: M6
tags: [tehnicko, godot, konvencije]
povezano:
  - _index
  - scene-node-pravila
  - greske-katalog
ai_sažetak: "GDScript stil za Merge Meadow — statičko tipiranje, snake_case, redoslijed u skripti, kad (ne) komentirati."
---

# Konvencije koda — GDScript

Pravila vrijede od **prve linije koda** (i u greyboxu). Placeholder grafika je OK; neuredan kod nije.

## Statičko tipiranje — obavezno

Uvijek tipiraj varijable, parametre i povratne vrijednosti. Godot tako hvata greške ranije i editor daje autocomplete.

```gdscript
var orb_count: int = 0
var scroll_speed: float = 400.0
var lane_positions: Array[float] = []

func add_orbs(amount: int) -> void:
    orb_count += amount

func get_lane_x(index: int) -> float:
    return lane_positions[index]
```

- `:=` za inferenciju kad je tip očit: `var width := get_viewport_rect().size.x` (ovo je `float`).
- **Ne** miješaj: ako pišeš eksplicitni tip, piši ga do kraja (`var x: int = 0`, ne `var x := 0` pa kasnije `x = "tekst"`).

## Imenovanje

| Element | Stil | Primjer |
|---------|------|---------|
| Varijable, funkcije | `snake_case` | `orb_count`, `_start_run()` |
| Privatne (interne) | `_` prefiks | `_spawn_timer`, `_update_hud()` |
| Konstante | `UPPER_SNAKE` | `RUN_DURATION`, `BASE_SCROLL_SPEED` |
| Signali | `snake_case`, prošlo vrijeme / događaj | `orb_collected`, `run_ended` |
| Node-ovi u sceni | `PascalCase` | `RunController`, `LootOverlay` |
| Fajlovi skripti | `snake_case.gd` | `run_controller.gd` |
| Scene fajlovi | `snake_case.tscn` | `run_scene.tscn` |
| Klase (`class_name`) | `PascalCase` | `class_name Orb` |

## Redoslijed unutar skripte

Uvijek isti redoslijed — lako se snalaziš u tuđem (i svom starom) kodu:

```gdscript
extends Node2D
class_name RunController        # 1. class_name (ako treba)

signal run_ended(loot: int)     # 2. signali

const RUN_DURATION := 75.0      # 3. konstante
enum State { READY, RUNNING, ENDED }  # 4. enumi

@export var scroll_speed: float = 400.0   # 5. @export varijable
@onready var player: Player = $Player     # 6. @onready reference

var _elapsed: float = 0.0       # 7. obične varijable (privatne s _)

func _ready() -> void: ...      # 8. Godot lifecycle (_ready, _process, _input)
func _process(delta: float) -> void: ...

func start_run() -> void: ...   # 9. javne metode
func _spawn_orb() -> void: ...  # 10. privatne metode (_)
func _on_player_hit() -> void: ... # 11. signal handleri (_on_)
```

## Signal handleri

Imenuj `_on_<izvor>_<dogadjaj>`:

```gdscript
player.hit_obstacle.connect(_on_player_hit_obstacle)

func _on_player_hit_obstacle() -> void:
    _end_run(true)
```

## Komentari — kad DA, kad NE

- **NE** komentiraj očito: `orb_count += 1  # povećaj brojač` ❌
- **DA** komentiraj *zašto*, ne *što*: `# 50% loota na fail — Pillar 2 (Fair F2P), vidi ekonomija.md`
- Kratki `#` iznad bloka koji radi nešto neočito (npr. ramp formula, hitbox tolerancija).

## Magične brojke → konstante

Svaki broj koji utječe na feel ide u imenovanu konstantu na vrhu (lako za balansiranje u playtestu):

```gdscript
const SWIPE_THRESHOLD := 50.0     # px — ispod ovoga swipe se ignorira
const SPAWN_INTERVAL := 1.2       # s
const RAMP_STEP := 0.05           # +5% brzine svakih RAMP_EVERY s
const RAMP_EVERY := 15.0          # s
```

## Guard clauses umjesto ugniježđenja

```gdscript
func _process(delta: float) -> void:
    if not run_active:
        return
    # glavna logika bez dubokog if-a
```

## Povezano

- [[scene-node-pravila|scene-node-pravila]] — kako reference na node-ove
- [[signali-komunikacija|signali-komunikacija]] — signal patterni
- [[greske-katalog|greske-katalog]] — česte greške
- [[_index|← Godot priručnik]]
