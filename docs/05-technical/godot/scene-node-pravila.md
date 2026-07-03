---
type: tehnicko
status: aktivan
milestone: M6
tags: [tehnicko, godot, scene]
povezano:
  - _index
  - konvencije-koda
  - greske-katalog
ai_sažetak: "Scene tree pravila — @onready tip mora odgovarati sceni, grupe, instanciranje, jedna skripta po odgovornosti."
---

# Scene i node pravila

## Zlatno pravilo: tip u skripti = tip u sceni

Ovo je uzrok bug-a #1 iz [[greske-katalog|greske-katalog]]. Kad pišeš `@onready` referencu, deklarirani tip **mora** biti kompatibilan s tipom node-a u `.tscn`.

```gdscript
# Scena: LootOverlay je CanvasLayer
@onready var loot_overlay: CanvasLayer = $LootOverlay   # ✅ tačno
@onready var loot_overlay: Control    = $LootOverlay    # ❌ pukne _ready() tiho
```

Kad tip ne odgovara, Godot baci grešku pri izvršavanju `_ready()` i **prekine ostatak `_ready()`** — pola scene ostane neinicijalizirano, a simptomi izgledaju nepovezano (tajmer stoji, ništa se ne spawna).

**Provjera:** klikni node u sceni → gornji lijevi ugao Inspector-a pokazuje tip klase. Taj tip (ili njegov roditelj) ide u `@onready`.

| Node u sceni | Ispravan tip u skripti |
|--------------|------------------------|
| `CanvasLayer` | `CanvasLayer` (NE `Control`) |
| `Control`, `PanelContainer`, `VBoxContainer` | `Control` ili konkretni tip |
| `Area2D` | `Area2D` |
| `Node2D`, `Polygon2D` | `Node2D` |
| `Label`, `Button` | `Label`, `Button` |

## @onready reference — pravila

- Koristi `@onready` za sve node reference: `@onready var player: Player = $Player`.
- Putanja `$A/B/C` je relativna od node-a na kojem je skripta.
- Ako node može ne postojati, koristi `%UniqueName` (Scene → desni klik → Access as Unique Name) umjesto krhke duge putanje.
- **Ne** hvataj node-ove u `_init()` — stablo još ne postoji; `@onready`/`_ready()` su sigurni.

## Jedna skripta = jedna odgovornost

| Skripta | Odgovornost | NE radi |
|---------|-------------|---------|
| `run_controller.gd` | scroll, spawn, run state, HUD update | ne detektira swipe |
| `player.gd` | lane pozicija, swipe input, sudar detekcija | ne spawna orbove |
| `orb.gd` | vlastiti pickup + `collected` signal | ne zna za brojač |

Ako skripta počne raditi dvije stvari — razdvoji.

## Instanciranje scena iz koda

```gdscript
var _orb_scene: PackedScene = preload("res://scenes/run/orb.tscn")

func _spawn_orb(pos: Vector2) -> void:
    var orb := _orb_scene.instantiate()
    orb.position = pos
    orb.collected.connect(_on_orb_collected)  # spoji signal PRIJE add_child
    world.add_child(orb)
```

- `preload` (konstantno, učita se pri kompajliranju) za scene koje uvijek trebaš.
- `load` samo kad je putanja dinamična.
- Spoji signale **prije** `add_child` da ne propustiš rani emit.
- Čisti instance s `queue_free()` (ne `free()`) — sigurno unutar frame-a.

## Grupe za "tko je što"

Umjesto provjere tipa/putanje, koristi grupe:

```gdscript
# u sceni: Orb node → Groups → dodaj "orb"; Obstacle → "obstacle"
func _on_area_entered(area: Area2D) -> void:
    if area.is_in_group("orb"):
        area.collect()
    elif area.is_in_group("obstacle"):
        hit_obstacle.emit()
```

## Organizacija stabla (run scene primjer)

```
RunScene (Node2D)          # run_controller.gd
├── Background (Polygon2D)
├── LaneGuides (Node2D)    # linije se crtaju iz koda
├── World (Node2D)         # spawnani orbovi/prepreke — čisti se na reset
├── Player (Area2D)        # player.gd
├── HUD (CanvasLayer)      # UI iznad gameplaya
│   ├── TimerLabel
│   └── OrbCounter
└── LootOverlay (CanvasLayer)  # overlay na kraju runa
    └── Panel → VBox → LootLabel, RetryButton
```

- Sve što se spawna → pod `World`, da reset runa samo očisti `World`.
- UI → `CanvasLayer` (ne skalira se s kamerom).

## Povezano

- [[konvencije-koda|konvencije-koda]]
- [[fizika-kolizije|fizika-kolizije]] — Area2D, layeri
- [[greske-katalog|greske-katalog]] — #1 tip mismatch
- [[_index|← Godot priručnik]]
