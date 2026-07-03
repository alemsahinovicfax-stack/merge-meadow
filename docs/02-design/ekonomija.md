---
status: draft
tags: [dizajn, ekonomija]
---

# Ekonomija

## Sažetak

Jedna soft valuta (**Orbs**) s tierovima kroz merge; IAP daje burst, ne paywall.

## Valute / resursi

| Resurs | Tip | Source | Sink |
|--------|-----|--------|------|
| **Orbs T1** | soft | Lane run pickup | Merge → T2 |
| **Orbs T2** | soft | Merge 2×T1 | Merge → T3, upgrade bar |
| **Orbs T3** | soft | Merge 2×T2 | High-tier upgrade, ljubimac unlock |
| **Stars** (opcionalno) | meta | Daily, milestone runovi | Cosmetic unlock |
| **Gems** | hard (IAP) | IAP starter, rijetki daily | Speed-up, boosteri |

**v1 launch:** fokus na Orbs T1–T3; Gems minimalno (starter pack only).

## Ekonomski loop

```
Run (earn T1) → Kamp merge (T1→T2→T3) → Upgrade sink → Jači run → više T1
```

## Početne vrijednosti (draft — balans u spreadsheetu Faza 6)

| Parametar | Vrijednost |
|-----------|------------|
| Prosječan T1 po runu (rani leveli) | 15–25 |
| Fail loot | 50% T1 |
| Rewarded ×2 | 100% T1 |
| T1→T2 merge | 2:1 |
| T2→T3 merge | 2:1 |
| Magnet Lv.1 cost | 20 T2 |
| Daily chest | 10 T1 + 2 T2 |

## Balans principi

- **Inflacija:** endless mode ima blago smanjen drop rate; upgrade cost raste eksponencijalno blago
- **Grind:** D1 magnet Lv.2 dostupan u 2–3 sesije bez IAP
- **Pay-to-win:** IAP daje burst resursa, ne ekskluzivnu snagu; free igrač može sve unlockati grindom
- **Pillar 2:** nikad sink koji blokira run (nema “nemaš orbs = ne možeš igrati”)

## IAP ↔ ekonomija

| IAP | Efekt na ekonomiju |
|-----|-------------------|
| Starter pack | +30 T2, +1 booster — skraćuje grind 1 dan |
| Speed merge | Preskače čekanje u redu — cosmetic QoL |
| Remove ads | Ne mijenja ekonomiju |

## Daily caps

- Nema hard capa na runove (v1)
- Daily chest: 1× dnevno
- Rewarded revive: max 1 po runu

## Otvorena pitanja

- [ ] Spreadsheet simulacija D1/D7 orb flow
- [ ] Uvesti Gems u v1 ili samo post-launch?

## Povezano

- [[monetizacija|monetizacija]]
- [[progresija|progresija]]
- [[mehanike/merge-kamp|merge-kamp]]
