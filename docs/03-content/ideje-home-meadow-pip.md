---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, pip, scratch]
povezano:
  - ideje-home-meadow
  - ideje-home-meadow-field
  - ideje-home-meadow-pitanja
  - ideje-home-meadow-chrome
  - ideje-home-meadow-life
ai_sažetak: "HOME-12 C wander ✅. HOME-13 CHROME-A ✅ hide. HOME-14 LIFE-D ✅ Pip ponovo u polju (hod/njuh/spavanje)."
---

# IDEJE — HOME-12 Pip wander

> [[ideje-home-meadow|hub]] · freeze P145, P149.  
> **Kod:** **MEADOW-C ✅**. Ovisi o B. **Jedan** Pip node na shellu — nije Pip po sezoni.  
> **HOME-13:** wander **off** u kodu (**CHROME-A ✅**, P160) — [[ideje-home-meadow-chrome|chrome hub]].  
> **HOME-14:** MeadowPip ponovo u polju (**LIFE-D ✅**, P187–P188) — [[ideje-home-meadow-life-pip|life pip]]. Portrait ostaje off.

## Što se vidi

Pip crta [`pip_draw.gd`](../../game/scripts/visual/pip_draw.gd) (`PipDraw.draw_pip`); **ne** run [`pip_visual.gd`](../../game/scripts/visual/pip_visual.gd). `IGNORE`. Wander Tween između **trenutnih** flower `Vector2` točaka. `apply_season` / rebuild cvijeća → wander targeti se ažuriraju (ne hoda prema freed nodeovima).

Close → stop tween, hide (isti node ostaje u stablu).

## Što C **ne** radi

- Run companion API / Mochi. Klik. Drugi Pip tscn po sezoni.

## Smoke

**MEADOW-C (povijest):** open → Pip visible IGNORE; wander. **CHROME-A:** open → Pip **hidden**, isti UniqueName, Frost reuse instance_id. Close → still hidden, tween off.

## Acceptance C

- Pip šeta među cvijećem **otvorene** sezone.
- Pip i cvijeće nisu klik.
- Play = run; Seasons = karusel; run companion netaknut.
