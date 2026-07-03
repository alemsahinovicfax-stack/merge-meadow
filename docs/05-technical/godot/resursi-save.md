---
type: tehnicko
status: aktivan
milestone: M7
tags: [tehnicko, godot, resursi, save]
povezano:
  - _index
  - ../arhitektura
  - ../../02-design/ekonomija
ai_sažetak: "preload vs load, .tres resursi za level/balans config, JSON save u user:// (M7); u M6 nema perzistencije."
---

# Resursi i save

> ⚠️ **M6 greybox nema save ni perzistenciju.** Brojač je lokalan i nestaje na restart. Ovaj doc je priprema za **M7** (kamp, upgradei, balans config). Čitaj kad kreneš C1.

## preload vs load

| | Kad | Ponašanje |
|---|-----|-----------|
| `preload("res://...")` | putanja fiksna | Učita se pri kompajliranju skripte; brže |
| `load("res://...")` | putanja dinamična (runtime) | Učita se kad se linija izvrši |

```gdscript
const OrbScene := preload("res://scenes/run/orb.tscn")   # uvijek treba
var skin := load("res://skins/%s.tres" % skin_id)         # dinamično
```

## Custom Resource za config (.tres)

Za level/balans podatke koristi tipizirani `Resource` umjesto magičnih brojki u kodu. Lako se uređuje u Inspectoru i verzionira.

```gdscript
# level_config.gd
extends Resource
class_name LevelConfig

@export var duration: float = 75.0
@export var scroll_speed: float = 400.0
@export var spawn_interval: float = 1.2
@export var obstacle_chance: float = 0.25
```

Snimiš instance kao `res://data/levels/level_01.tres`. Balans brojke usklađuj s [[../../02-design/ekonomija|ekonomija]] i `ekonomija-balans.csv`.

> Otvoreno pitanje iz [[../arhitektura|arhitektura]]: `.tres` vs JSON za level config. Za **statični dizajnerski config** → `.tres` (tipizirano, Inspector). Za **igračev save** → JSON (vidi dolje).

## Save igrača — JSON u `user://`

`user://` je jedina lokacija u koju build smije pisati (na Androidu app-private folder).

```gdscript
# SaveManager.gd (autoload — M7)
const SAVE_PATH := "user://save.json"

func save_game(data: Dictionary) -> void:
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    f.store_string(JSON.stringify(data))

func load_game() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {}
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
    var parsed = JSON.parse_string(f.get_as_text())
    return parsed if parsed is Dictionary else {}
```

## Pravila

- **Nikad** ne piši u `res://` u buildu — read-only na uređaju.
- Save nakon svake bitne promjene stanja (loot dodijeljen, merge, upgrade).
- Validiraj učitane podatke (verzija save-a, tipovi) — igrač može imati stari format.
- Bez servera u v1 ([[../arhitektura|arhitektura]]) — sve lokalno.

## Povezano

- [[../arhitektura|arhitektura]] — SaveManager, GameState
- [[../../02-design/ekonomija|ekonomija]] — brojke koje idu u config
- [[_index|← Godot priručnik]]
