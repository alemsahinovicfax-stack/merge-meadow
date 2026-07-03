---
type: tehnicko
status: aktivan
milestone: M6
tags: [tehnicko, godot, fizika, kolizije]
povezano:
  - _index
  - scene-node-pravila
  - greske-katalog
ai_sažetak: "Collision layer/mask tablica za Merge Meadow, Area2D pickup/sudar pattern, česte kolizijske zamke."
---

# Fizika i kolizije

Za lane run koristimo **`Area2D`** (detekcija preklapanja), ne `CharacterBody2D` — nema fizikalnog guranja, samo "je li se dodirnulo".

## Collision layers i masks

- **Layer** = "na kojem sloju JA jesam".
- **Mask** = "koje slojeve JA gledam / detektiram".
- Dva node-a se detektiraju ako je layer jednog u mask-i drugog.

### Tablica slojeva (Merge Meadow)

| Layer # | Ime | Tko | Layer | Mask (gleda) |
|---------|-----|-----|-------|--------------|
| 1 | `player` | Player | 1 | 2 |
| 2 | `pickups` | Orb, Obstacle | 2 | — (0) |

Player je na layeru 1 i gleda layer 2 (pickups). Orbovi/prepreke su na layeru 2 i **ne gledaju** ništa (mask 0) — dovoljno je da ih Player vidi. Tako izbjegavamo dvostruku detekciju.

Imena slojeva definirana u `project.godot`:

```
[layer_names]
2d_physics/layer_1="player"
2d_physics/layer_2="pickups"
```

## Pickup / sudar pattern

Detekciju drži **jedan** node (Player), a orb/prepreka samo reagiraju na poziv:

```gdscript
# player.gd
func _ready() -> void:
    area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
    if area.is_in_group("orb"):
        area.collect()          # orb sam sebe skuplja + emitira signal
    elif area.is_in_group("obstacle"):
        hit_obstacle.emit()     # javi run_controlleru
```

```gdscript
# orb.gd
signal collected
func collect() -> void:
    collected.emit()
    queue_free()
```

## Česte kolizijske zamke

| Simptom | Uzrok | Rješenje |
|---------|-------|----------|
| Ništa se ne detektira | Layer/mask ne odgovaraju | Player mask mora sadržavati orb layer |
| Dvostruki pickup | Oba node-a detektiraju | Samo Player ima mask; pickups mask = 0 |
| `body_entered` se ne okida | `Area2D` ne emitira `body_entered` za druge `Area2D` | Koristi `area_entered` za Area↔Area |
| Sudar promašen pri brzom scrollu | Hitbox premali, veliki `delta` | Povećaj `CollisionShape2D`, razmisli o `move_and_collide` kasnije |
| `CollisionShape2D` prazan | Nema dodijeljen `shape` | Dodijeli `RectangleShape2D`/`CircleShape2D` |

## `area_entered` vs `body_entered`

- **Area2D ↔ Area2D** → `area_entered(area)`.
- **Area2D ↔ PhysicsBody2D** → `body_entered(body)`.
- U našem greyboxu su svi Area2D → koristimo `area_entered`.

## Povezano

- [[scene-node-pravila|scene-node-pravila]] — grupe
- [[signali-komunikacija|signali-komunikacija]]
- [[../performanse|performanse]] — object pooling ako FPS padne
- [[_index|← Godot priručnik]]
