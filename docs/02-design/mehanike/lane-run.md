---
status: draft
tags: [mehanika, lane-run]
---

# Lane run

## Sažetak

One-thumb swerve collector — ~90 s auto-run kroz lane, skupljanje orbova, izbjegavanje prepreka.

## Kako funkcionira

1. Igrač **swipea** lijevo/desno; lik se pomiče između 3 laneova (ili smooth swerve).
2. Sistem **auto-scrolla** naprijed, spawna orbs (common/rare) i prepreke prema level konfiguraciji.
3. Ishod: **finish** (finish line) ili **fail** (sudar) → loot ekran s orbovima za kamp.

## Feel / game feel

- Responsivan swipe (&lt;100 ms input lag).
- Svaki orb: mali “pop” + fly-to-HUD animacija.
- Brzina raste blago kroz run (ne naglo).
- Fail: kratki freeze + gentle screen shake, ne agresivno.

## Balans

| Parametar | Početna vrijednost | Napomena |
|-----------|-------------------|----------|
| Trajanje runa | ~60–90 s | Skraćuje se na ranim levelima |
| Laneovi | 3 | Jednostavno za thumb |
| Loot na fail | 50% orbova | + rewarded revive za 100% |
| Prepreke | Rijetke rano, gustošće level 20+ | Curve u [[../progresija|progresija]] |

## UI feedback

- HUD: orb counter, množitelj ikona, pause (gornji kut).
- Kraj runa: veliki broj “+XX Orbs”, gumb Dupli loot (rewarded), Retry, U kamp.

## Monetizacija

| Moment | Tip |
|--------|-----|
| Kraj runa — dupli loot | Rewarded video |
| Kraj runa — revive | Rewarded video (max 1/run) |
| Kraj runa — interstitial | Opcionalno, samo ovdje (ne mid-run) |

## Ovisnosti

- Zahtijeva: [[kontrole-i-input|kontrole-i-input]]
- Povezano s: [[merge-kamp|merge-kamp]], [[mnozitelj-upgrade|mnozitelj-upgrade]], [[../core-loop|core-loop]]

## Otvorena pitanja

- [x] 3 fiksna lanea vs fluid swerve — **greybox: 3 lane + tween 0.12 s** (B3 2026-07-03); swerve test u M7 ako treba
- [ ] Endless mode: ista mehanika, procedural spawn

## Reference

- [[../01-vision/konkurencija-i-inspiracija|Subway Surfers — session structure]]
