---
type: dizajn
status: aktivan
milestone: M6
tags: [dizajn, core-loop]
povezano:
  - gdd-overview
  - lane-run
  - merge-kamp
  - progresija
ai_sažetak: "Petlja run → loot → kamp → merge → jači run; micro ~90s, session 8–15 min."
---

# Core loop

## Sažetak

Petlja: **run → loot → kamp → merge → jači run**. Svakih ~90 sekundi igrač prolazi micro petlju; svakih 8–15 minuta završava session s razlogom da se vrati sutra.

## 30-sekundna petlja (micro)

```
Swipe → Skupljaj → Feedback → Nagrada (loot)
```

Opis:
1. Igrač **swipea** lijevo/desno u laneu; lik auto-trči naprijed.
2. Sistem **spawna** orbs i prepreke; svaki pickup daje instant feedback (SFX, +1 fly to HUD).
3. Ishod: **kraj runa** (prepreka ili finish) → ekran loota s ukupnim orbovima za kamp.

**Monetizacijski moment (kraj micro petlje):** rewarded **dupli loot** ili **revive** (Pillar 2 — opcionalno, ne blokira core).

## 5-minutna petlja (session)

```
Run → Loot screen → Kamp → Merge → Upgrade → Sljedeći run
```

Opis:
1. **Start** iz kampa ili nakon prethodnog runa — igrač vidi trenutni množitelj/magnet level.
2. **1–3 runa** (~90 s svaki) s rastućim lootom.
3. **Milestone:** prvi merge 2→1 u kampu ili unlock sljedećeg upgrade tiera.
4. **Satisfying stop:** kamp pokazuje “još 1 merge do level X” ili daily chest spreman — soft cliff, ne hard stop.

Tipična session: **4–6 runova + 2–3 min u kampu** = 8–15 min/dan.

## 1-satna / dnevna petlja (meta)

```
Napredak kampa → Unlock (magnet/množitelj/ljubimac) → Jači runovi → Želja za nastavkom
```

Opis:
1. Nakon više sesija kroz dan/tjedan: kamp vizualno raste, tier merge predmeta raste.
2. **Unlock** magnet level 2, množitelj ×1.5, novi pastelni ljubimac.
3. Nova strategija: prioritet skupljanja rijeđih orbova za high-tier merge.
4. **Daily reward** i “nefinished merge” drže D7.

## Motivacijski motori

| Horizont | Motor | Komercijalni učinak |
|----------|-------|---------------------|
| Kratkoročno | Pickup feedback, brojka raste u runu | Više runova po sessionu |
| Srednje | Merge pop, upgrade unlock | D1 retention |
| Dugoročno | Kamp raste, kolekcija ljubimaca, daily streak | D7 + IAP speed-up |

## Fail state

| Događaj | Ponašanje | Monetizacija |
|---------|-----------|--------------|
| Sudar s preprekom | Run završava | — |
| Odmah nakon faila | **Zadrži 50% loota** (besplatno) | Fair — Pillar 2 |
| Opcija | **Rewarded revive** — nastavi run, zadrži 100% | Ad revenue |
| Retry | Besplatan, instant | — |
| IAP continue | **Ne** u v1 | Krši Pillar 2 |

## Tutorial (prvih 60 sekundi)

1. **0–10 s:** jedan swipe — lik se pomakne; prvi orb pickup (veliki feedback).
2. **10–45 s:** kratki run bez opasne prepreke ili s blagom.
3. **45–90 s:** prva prepreka, fail, loot screen objašnjen.
4. **90 s–3 min:** vođenje u kamp — prvi merge 2→1 (player promise iz [[../01-vision/koncept|koncept]]).

Bez tekstualnog zida — maks. 2 callout bubblea.

## Natural stop (cliff)

- **Soft cliff:** “Još 1 merge do Magnet Lv.3” na kamp ekranu.
- **Daily cliff:** daily chest dostupan sljedeći dan.
- **Ne:** energy koja blokira run (v1).

## Otvorena pitanja

- [ ] Točan % loota na fail (50% ili 75%) — playtest
- [ ] Max rewarded reviveova po runu (1 preporuka)

## Povezano

- [[progresija|progresija]]
- [[ekonomija|ekonomija]]
- [[mehanike/_index|mehanike]]
- [[../01-vision/pitch|pitch]]
- [[../01-vision/design-pillars|design-pillars]]
