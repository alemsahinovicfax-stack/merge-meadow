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
