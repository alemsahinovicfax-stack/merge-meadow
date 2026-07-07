---
type: produkcija
status: aktivan
milestone: M6
tags: [produkcija, scope]
povezano:
  - milestone-i
  - gdd-overview
  - verzije-nakon-launcha
ai_sažetak: "v1 IN/OUT scope za solo deva; scope guard referenca za agenta."
---

# Scope i granice

## Sažetak

v1 **launch** scope za Merge Meadow — dovoljno za monetizaciju (ads + IAP), realan za solo studenta (~5–8 h/tj., 4–6 mj.).

## v1 launch — IN scope ✅

### Core gameplay
- Lane run — swipe, skupljanje orbova, prepreke (~100 konfiguriranih runova)
- Endless mode (osnovni procedural spawn)
- Merge kamp — 2→1 merge, min 3 tiera orbova
- Upgradei: magnet, množitelj (min 4 levela svaki)
- 2 ljubimca (Pip default + 1 unlock)

### UX / flow
- Splash → tutorial run (prvi launch) → main menu
- Loot ekran: ×2 rewarded, revive rewarded (max 1/run), retry, u kamp
- Kamp: merge, upgrade, daily chest
- Shop: remove ads, starter pack, booster consumables

### Monetizacija
- AdMob rewarded video (×2 loot, revive)
- Opcionalni interstitial **samo** na loot ekranu (A/B post-launch)
- IAP: remove ads, starter pack, boosters
- Offline gameplay; IAP zahtijeva mrežu

### Tech
- Godot 4, Android + iOS export
- EN UI copy
- SFX (pickup, merge, fail); muzika opcionalna u kampu
- Flat 2D **flat cartoon** (pastel, soft outline) — bez pixel grida

### Content
- 100 run level konfiguracija + endless
- Level generator — **mjesec 2** (post-launch update, ne launch blocker)

## v1 — OUT of scope ❌

| OUT | Razlog |
|-----|--------|
| Multiplayer, leaderboard, cloud save | Server scope + održavanje |
| Priča, cutscene, NPC dijalog | Content pipeline |
| Dark mode, tablet layout | UX scope |
| 3+ ljubimci na launch | Art scope |
| Battle pass, gacha, klanski sustav | Ekonomija scope |
| Lokalizacija (osim EN) | ASO kasnije |
| Energy/stamina koji blokira run | Krši Pillar 2 |
| Pay-to-continue run (IAP) | Krši Pillar 2 |
| 3D grafika | Nepotrebno + teže na slabom laptopu |
| Web build | Nije revenue target |
| Level generator na launch | Mjesec 2 — launch s 100 + endless |

## Vertical slice (Faza 6–7) — prije punog launcha

Manji scope za **prvi igrivi dokaz** u `game/`:

| Slice IN | Launch IN |
|----------|-----------|
| 1 lane run + osnovni loot ekran | 100 runova |
| Placeholder art | Final **flat cartoon** |
| Kamp merge (1 tier) | Puni merge tree |
| 10 test runova | 100 + endless |
| Android APK test | Android + iOS store |

## Pravilo odlučivanja

Za svaku novu ideju:
1. Podržava li **Pillar 2 (Fair F2P)** i **zaradu** (retention ili ads/IAP)?
2. Može li solo dev završiti u **4–6 mj.**?
3. Ako NE na sva tri → **OUT** ili post-launch → zapiši u [[verzije-nakon-launcha|verzije-nakon-launcha]]
4. Je li u **trenutnom milestoneu**? — vidi tablica ispod

Agent te upozorava — `.cursor/rules/scope-guard.mdc`

## Scope po milestoneu (što smiješ kodirati)

| Milestone | CHECKPOINT | Smiješ | Ne smiješ (agent upozorava) |
|-----------|------------|--------|-----------------------------|
| **M6** | B | Lane run, placeholder loot | Merge, shop, ads, iOS, menu |
| **M7** | C | Cijeli loop, test AdMob, art slice | 100 levela, pun production shop |
| **M8** | D | Launch IN lista | OUT tablica |
| **v1.1+** | — | [[verzije-nakon-launcha|verzije-nakon-launcha]] | Sve ostalo |

## Kapacitet

| Stavka | Vrijednost |
|--------|------------|
| Tim | Solo dev (student) |
| Sati/tjedno | ~5–8 (varira) |
| Marketing | €50–100 test CPI |
| Dev stroj | Slabiji laptop — Godot odabran zbog toga |

## Otvorena pitanja

- [ ] Točan launch datum (TBD ovisno o fakultetu/ispitima)
- [ ] Je li 100 runova launch blocker ili 50 + endless za raniji launch?

## Povezano

- [[milestone-i|milestone-i]]
- [[roadmap|roadmap]]
- [[../01-vision/design-pillars|design-pillars]]
- [[../05-technical/engine-odluka|engine-odluka]]
- [[verzije-nakon-launcha|verzije-nakon-launcha]]
