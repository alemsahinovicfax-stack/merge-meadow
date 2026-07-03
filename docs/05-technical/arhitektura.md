---
type: tehnicko
status: aktivan
milestone: M6
tags: [tehnicko, arhitektura]
povezano:
  - engine-odluka
  - platforme
  - scope-i-granice
ai_sažetak: "Godot 4 scene tree + autoload singletoni; offline-first bez servera u v1."
---

# Arhitektura

## Sažetak

Godot 4 **scene tree** + autoload singletoni. Offline-first; bez servera u v1.

## Visoka razina

```
main.tscn
├── MainMenu
├── RunScene (lane gameplay)
├── LootScreen
├── CampScene (merge + upgrades)
└── ShopOverlay

Autoloads:
├── GameState      # run progress, unlocks
├── SaveManager    # local JSON
├── AudioManager
├── AdManager      # AdMob wrapper (M7+)
└── IAPManager     # billing (launch)
```

## Moduli

| Modul | Odgovornost | Godot pattern |
|-------|-------------|---------------|
| **Input** | Swipe L/R, drag merge | `_input()` + touch events |
| **RunController** | Spawn, scroll, collision, loot tally | Node2D + Area2D |
| **CampController** | Merge grid, upgrade UI | Control + drag-drop |
| **GameState** | Orbs, tiers, upgrade levels | Autoload Resource/RefCounted |
| **SaveManager** | Persist kamp + settings | `user://save.json` |
| **UIManager** | Screen transitions | Scene change + fade |
| **AudioManager** | SFX pool, music bus | AudioStreamPlayer pool |
| **AdManager** | Rewarded callbacks | Plugin singleton (M7) |
| **IAPManager** | Purchase flow | Plugin (launch) |

## Data flow

```
RunScene
  → (run_end) → loot: int orbs_t1
  → GameState.add_orbs()
  → SaveManager.save()
  → LootScreen
  → (to camp) → CampScene
  → merge/upgrade mutira GameState
  → SaveManager.save()
```

## Scene organizacija (`game/`)

```
game/
├── project.godot
├── scenes/
│   ├── main.tscn
│   ├── run/
│   ├── camp/
│   ├── ui/
│   └── tutorial/
├── scripts/
│   ├── autoload/
│   └── systems/
├── assets/
│   ├── sprites/
│   ├── audio/
│   └── fonts/
└── export/          # export presets (gitignore binaries)
```

## Odluke

| Pitanje | Odluka |
|---------|--------|
| ECS vs OOP | **Scene tree + skripte** — dovoljno za scope |
| Save format | JSON u `user://` |
| Online | Ne u v1 |
| `game/` folder | Nakon [[CHECKPOINT|CHECKPOINT]] Sekcija A ✅ |

## Otvorena pitanja

- [ ] Resource (.tres) za level config vs JSON
- [ ] Object pooling za orbs — implement u greyboxu ako FPS padne

## Povezano

- [[engine-odluka|engine-odluka]]
- [[platforme|platforme]]
- [[../06-production/CHECKPOINT|CHECKPOINT]]
