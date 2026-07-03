---
status: draft
tags: [produkcija, rizici]
---

# Rizici

## Sažetak

Top rizici za solo studenta na HP Windows + iPhone — s mitigacijom.

## Rizik matrica

| Rizik | Vj. | Utjecaj | Mitigacija |
|-------|-----|---------|------------|
| Scope creep | visoka | visok | [[scope-i-granice|scope]], [[CHECKPOINT|CHECKPOINT]], pillari |
| iOS build bez Maca | **visoka** | srednji | Android prvi; Mac/CI plan; TestFlight kasnije |
| Slab laptop / spor export | srednja | srednji | Godot 4; mali projekt; Android emulator |
| Burnout (solo + fakultet) | visoka | visok | 5–8 h/tj. realno; M5½ prije koda; mali M6 |
| Ad/IAP integracija kompleksna | srednja | srednji | Test ad uniti u M7; Android prije iOS |
| Nema downloada / prihoda | srednja | visok | Hybrid monetizacija; €50 test CPI; ASO EN |
| Projekat nikad ne launcha | srednja | visok | Vertical slice prije 100 levela; CHECKPOINT |

## Top 3 rizika (danas)

1. **iOS pipeline s Windowsa** — ne možeš exportati IPA direktno s HP-a. *Plan B:* razvoj + Android monetizacija test; iOS kad riješiš Mac pristup (fakultet, prijatelj, GitHub Actions).
2. **Prevelik scope prije prvog APK** — *Plan B:* M6 = samo lane run; merge u M7.
3. **Burnout** — *Plan B:* smanji na Android-only launch ako iOS kasni.

## Plan B (manji scope)

| Rez | Scope |
|-----|-------|
| A (ideal) | Android + iOS, hybrid monetizacija, 100 runova |
| B | Android launch prvi, iOS +2 tjedna |
| C | Android only, rewarded ads only (bez IAP) — minimum prihoda |

## Povezano

- [[CHECKPOINT|CHECKPOINT]]
- [[roadmap|roadmap]]
- [[../05-technical/platforme|platforme]]
