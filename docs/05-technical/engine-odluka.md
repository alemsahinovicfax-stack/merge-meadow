---
status: draft
tags: [tehnicko, engine]
decision: godot-4
---

# Engine odluka

## Sažetak

**Godot 4.x** — 2D hybrid casual, Android + iOS export, pogodan za **slabiji laptop** i solo student dev.

## Kriteriji

| Kriterij | Težina | Godot 4 |
|----------|--------|---------|
| Mobile export | visoka | ✅ Android + iOS (oficijalni export) |
| 2D support | visoka | ✅ Native 2D, dobar za lane + UI |
| Learning curve | visoka | ✅ GDScript jednostavan, puno 2D tutoriala |
| Community / docs | srednja | ✅ Aktivan, mobile export dokumentiran |
| Performanse (dev PC) | **kritično za nas** | ✅ Lagani editor, mali projekti — radi na slabijem laptopu |
| Cijena | visoka | ✅ 100% besplatno, bez royaltyja |
| Ads / IAP plugini | visoka | ✅ AdMob, Godot Google Play Billing / iOS IAP (community + official paths) |

## Kandidati

### Godot 4 — **ODABRANO**

- ✅ Besplatan, open source, mali footprint editora
- ✅ Odličan 2D pipeline (scene tree, tweens, particles)
- ✅ Brzi iteracije na slabom hardveru — **ključno za student laptop**
- ✅ Jedan codebase → Android + iOS
- ❌ iOS export zahtijeva Mac za finalni build (planirati pristup Macu ili cloud CI kasnije)
- ❌ Manje “enterprise” monetizacije out-of-the-box nego Unity — ali dovoljno za AdMob + IAP

### Unity

- ✅ Ogroman ekosustav za ads/IAP tutoriale
- ❌ Teži editor i projekti — **lošije na slabom laptopu**
- ❌ Sporiji learning curve za solo početnika
- ❌ Runtime fee / licence politika (kompleksnije za studenta)

### Flutter / Flame

- ✅ Ako bi već znao Dart
- ❌ Manje game-specific tooling za lane runner juice
- ❌ Nije optimalan za brzi mobile game slice

## Finalna odluka

**Odabir:** Godot **4.3+** (stabilna 4.x grana)

**Zašto:** Merge Meadow je **2D flat + pixel UI** — Godot pokriva sve mehanike (lane, merge UI, tweens) uz minimalne zahtjeve na stroju. Brži path do `game/` foldera = brži path do storea i prihoda. Unity bi bio overkill i opterećujući za development na slabijem laptopu.

## Tehnički stack (draft)

| Sloj | Alat |
|------|------|
| Engine | Godot 4.x |
| Jezik | GDScript (C# samo ako kasnije zatreba) |
| VCS | Git |
| Monetizacija | AdMob plugin + Google Play Billing / App Store IAP |
| CI (kasnije) | GitHub Actions za Android APK |

## Otvorena pitanja

- [ ] Točna verzija Godot 4.x pri inicijalizaciji `game/`
- [ ] iOS build: pristup Macu ili cloud build prije App Store submita
- [ ] AdMob plugin izbor (community vs custom)

## Povezano

- [[platforme|platforme]]
- [[arhitektura|arhitektura]]
- [[../06-production/scope-i-granice|scope-i-granice]]
