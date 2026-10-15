---
type: produkcija
status: aktivan
milestone: M6
tags: [produkcija, scope]
povezano:
  - CHECKPOINT
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
- Run: header u jednom redu, vertikalna traka napretka umjesto sekundi, nagradni grm između traka (pokupi se pri promjeni trake) — dodano 2026-10-09 na zahtjev, [[../04-experience/design-drafts/run-hud-v2-cd-brief|run-hud-v2-cd-brief]]
- 2 ljubimca (Pip default + 1 unlock)

### UX / flow
- Splash → tutorial run (prvi launch) → main menu
- Loot ekran: ×2 rewarded, revive rewarded (max 1/run), retry, u kamp
- Kamp: merge, upgrade, daily chest
- Settings ekran (zupčanik u headeru): Music i Sound effects (slider + mute), Vibration, Reduce motion, Restore purchases, Remove Ads status, Privacy choices (pristanak za reklame), Privacy policy, Contact support, Credits, Version; Dev sekcija samo u debug buildu — dodano 2026-10-12 na zahtjev, [[../04-experience/design-drafts/ispravke-settings-cd-brief|ispravke-settings-cd-brief]]
- Classic Pip je pravi skin u Ormaru (besplatan, ne prodaje se); zlatni okvir Albuma radi sa skrolom — 2026-10-12, isti brief
- Muncher u Areni: novi lik (Nibbs, krtica — u igri 2026-10-14; cutout rig + animacije svih stanja, krtičnjak); pravila ponašanja ostaju — dodano 2026-10-12 na zahtjev, [[../04-experience/design-drafts/muncher-premium-pip-cd-brief|muncher-premium-pip-cd-brief]]
- Premium Pip skin (1 komad, pravi novac): Sir Pip · Meadow Knight (u igri 2026-10-14, SKU `pip_knight`, cijena prijedlog €3.99) — potpuno drugačiji dizajn i tema, vlastiti dijelovi i animacije, Shop Looks + Ormar; samo kozmetika (Pillar 2) — 2026-10-12, isti brief
- Shop: remove ads, starter pack (7 dana od prvog pokretanja), boosteri (Merge Hint jednokratan, Loot Burst consumable) — Shop v2, 2026-10-02

### Monetizacija
- AdMob rewarded video (×2 loot, revive)
- Opcionalni interstitial **samo** na loot ekranu (A/B post-launch)
- IAP: remove ads, starter pack, boosters, premium Pip skin (samo kozmetika, od 2026-10-12)
- Offline gameplay; IAP zahtijeva mrežu

### Tech
- Godot 4, **Android launch prvo**; iOS export kad se prikupi ~**99 USD** (Apple Developer)
- EN UI copy
- Zvuk cijele igre: SFX za svaki događaj (UI, ekonomija, Arena, muncher, Pip, run, loot) + muzika — hub, Arena i run, haptika uz velike trenutke; privremeno sintetizovano dok ne stigne pravi zvuk — prošireno 2026-10-14 na zahtjev („zvuk za cijelu igru"), [[../04-experience/audio-direction|audio-direction]]
- Muzika po sezoni: svaka od 8 sezona ima svoje tri teme (home / arena / run) u skladu sa sezonom, muzika prati aktivnu sezonu — dodano 2026-10-14 na zahtjev, [[../04-experience/muzika-sezone|muzika-sezone]]
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
| **SEZ-01 sezone / teme** | v1.1+ (P0 freeze) — nije launch blocker |
| Dijamanti (valuta, rijetki pickup u runu, „+1” pop, ikona) | Izbačeno 2026-10-09 na zahtjev — valuta se nigdje nije trošila. Premium sezone ostaju IAP (zlatni tab / zlatna cijena bez ikone) |

## v1.1+ — IN scope ✅ (SEZ-P0, 2026-08-19)

Agent **smije** kodirati SEZ-B…E kao v1.1 track (nakon P0). Nije dio v1 launch IN.

| IN | Napomena |
|----|----------|
| **SEZ-01** | Free linear sezone (coins + T3 check-only) + paid IAP packs; Home Stage + Browser; Unlock sheet na next-free teaser; run spawn/BG hook; Fair F2P (paid = tema, ne snaga) — **isporučeno** |

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
| **M8** | D | Launch IN lista | OUT tablica (uklj. sezone na launch) |
| **v1.1+** | — | [[verzije-nakon-launcha|verzije-nakon-launcha]] + **SEZ-01** (B–E) | v2+, battle pass, cloud |

## Kapacitet

| Stavka | Vrijednost |
|--------|------------|
| Tim | Solo dev (student) |
| Sati/tjedno | ~5–8 (varira) |
| Marketing | €50–100 test CPI |
| Dev stroj | Slabiji laptop — Godot odabran zbog toga |

## Otvorena pitanja

- [x] Launch redoslijed — **Android kad max polish; iOS kad ~99 USD** → [[troskovi-launcha|troskovi-launcha]]
- [ ] Točan Android launch datum (TBD — ovisno o fakultetu + D0 polish)
- [ ] Je li 100 runova launch blocker ili 50 + endless za raniji launch?

## Povezano

- [[CHECKPOINT|CHECKPOINT]]
- [[../01-vision/design-pillars|design-pillars]]
- [[../05-technical/engine-odluka|engine-odluka]]
- [[verzije-nakon-launcha|verzije-nakon-launcha]]
