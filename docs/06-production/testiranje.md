---
status: draft
tags: [produkcija, testiranje]
---

# Testiranje

## Sažetak

QA plan za solo deva — HP emulator + iPhone kad iOS build postoji.

## Faze testiranja

| Faza | Kada | Uređaj | Fokus |
|------|------|--------|-------|
| Dev smoke | Svaki commit | Emulator | Crashes, input |
| Greybox playtest | M6 | Android emulator | Feel, 5 min |
| Slice playtest | M7 | Emulator + iPhone | Full loop |
| Closed beta | Pre-launch | 5–10 ljudi | Retention, bugs |
| Store test | Launch | Internal / TestFlight | IAP, ads |

## Checklist po buildu (smoke)

- [ ] App se pokreće bez crasha
- [ ] Swipe radi
- [ ] Run završava i prikazuje loot
- [ ] Kamp se otvara
- [ ] Save/load nakon restarta app-a
- [ ] Pause radi
- [ ] Zvuk off u settings

## M7 playtest script (5 min)

1. Prvi launch — prođi tutorial bez pomoći
2. Odigraj 3 runa
3. Napravi 1 merge u kampu
4. Kupi ili testiraj rewarded (test ad)
5. Pitanja: Je li jasno? Bi li nastavio sutra?

## Feedback kanal

- Google Form ili Discord — 3 pitanja: zabava 1–5, jasnoća 1–5, što nedostaje?

## Otvorena pitanja

- [ ] TestFlight beta broj testera

## Povezano

- [[CHECKPOINT|CHECKPOINT]]
- [[rizici|rizici]]
