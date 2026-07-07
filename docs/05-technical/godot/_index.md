---
type: tehnicko
status: aktivan
milestone: M6
tags: [hub, tehnicko, godot]
povezano:
  - arhitektura
  - godot-dev-setup
  - CHECKPOINT
ai_sažetak: "Hub Godot priručnika — konvencije koda, scene, fizika, signali, input, workflow, katalog grešaka."
---

# Godot priručnik — Merge Meadow

> Odgovara na: **KAKO konkretno pišemo Godot kod** u ovom projektu?

Ovo je praktični priručnik za razvoj u `game/`. [`arhitektura.md`](../arhitektura.md) opisuje **što** gradimo (moduli, scene tree); ovaj folder opisuje **kako** to pišemo bez tipičnih grešaka.

## Kad čitati što

| Radiš | Čitaj prvo |
|-------|-----------|
| Pišeš novu skriptu | [[konvencije-koda\|konvencije-koda]] |
| Praviš / mijenjaš scenu | [[scene-node-pravila\|scene-node-pravila]] |
| Kolizije, pickup, sudar | [[fizika-kolizije\|fizika-kolizije]] |
| Komunikacija node ↔ node | [[signali-komunikacija\|signali-komunikacija]] |
| Swipe / tap / touch | [[input-touch\|input-touch]] |
| Save, level config, .tres | [[resursi-save\|resursi-save]] |
| Nešto puca / čudno se ponaša | [[greske-katalog\|greske-katalog]] |
| Prije commita / testa | [[dev-workflow\|dev-workflow]] |
| iOS export / iPhone test (C4) | [[ios-export\|ios-export]] |

## Zlatna pravila (TL;DR)

1. **Tip u `@onready` mora odgovarati tipu node-a u sceni** — inače `_ready()` pukne tiho. (Vidi [[greske-katalog\|greske-katalog]] #1.)
2. **Statičko tipiranje uvijek** — `var x: int = 0`, `func f() -> void:`.
3. **Node-ovi komuniciraju signalima prema gore, pozivima prema dolje** — dijete emitira signal, roditelj poziva metode djeteta.
4. **Headless smoke-test prije nego što otvoriš editor** — vidi [[dev-workflow\|dev-workflow]].
5. **Placeholder je OK, prljav kod nije** — greybox art da, ali konvencije koda vrijede od prve linije.

## Povezano

- [[../arhitektura|arhitektura]] — moduli i scene tree
- [[../godot-dev-setup|godot-dev-setup]] — OpenGL launch (HP laptop)
- [[../performanse|performanse]] — FPS/RAM ciljevi
- [[../_index|← Tehničko]]
