---
status: draft
tags: [vizija, pillars]
---

# Design pillars

## Sažetak

Tri **nepregovarljiva** principa dizajna. Svaka odluka o mehanici, UI-u, monetizaciji ili sadržaju mora proći test: “Je li ovo u skladu s našim pillarema?”

**Prioritet kad se sukobe:** Pillar 2 (Fair F2P) → Pillar 1 (Svaki run se isplati) → Pillar 3 (Kamp te zove natrag).  
Pillar 2 se **nikad ne žrtvuje** — jedan loš paywall može ubiti store rating i cijeli revenue funnel.

## Pillars

### 1. Svaki run se isplati

**Princip:** U ~90 sekundi igrač mora osjetiti napredak — loot, merge materijal ili množitelj za sljedeći run.

**Primjeri u praksi:**
- ✅ Jasni pickup efekti, brojka raste na kraju runa (“+12 orbs”), mini milestone u runu
- ✅ Kratki run čak i kad “izgubiš” — barem nešto za kamp
- ❌ Prazan run bez nagrade, “skoro” bez ikakvog loota
- ❌ Predugačak run bez feedbacka (monotonija → quit prije oglasa)

**Zašto novac:** Zadovoljavajući run → više runova/dan → više rewarded ad opportunitija.

### 2. Fair F2P — core je uvijek besplatan

**Princip:** Run i merge nikad nisu iza paywalla; monetizacija samo na **prirodnim pauzama** (kraj runa, kamp, shop).

**Primjeri u praksi:**
- ✅ Rewarded revive, dupli loot, remove ads, starter pack, consumable boosteri u kampu
- ✅ Interstitial samo nakon runa (ako uopće), nikad usred lanea
- ❌ Plati da nastaviš run, energy koja blokira core loop
- ❌ Pay-to-win množitelji koji ruše balans za free igrače

**Zašto novac:** Bolji reviewi + D7 → više igrača doživi dovoljno sesija za ads i IAP.

### 3. Kamp te zove natrag

**Princip:** Svaka sesija ostavlja **nefinished business** u kampu — merge spreman, upgrade skoro, daily čeka.

**Primjeri u praksi:**
- ✅ “Još 1 merge do level 3 magneta”, daily chest, novi ljubimac na horizonu
- ✅ Vizualni napredak kampa (pastelni kutak raste s tobom)
- ❌ Kamp je samo meni bez emocionalnog napretka
- ❌ Sve završeno u jednoj sesiji — nema razloga otvoriti app sutra

**Zašto novac:** D1/D7 retention → lifetime ad revenue; impatijentni igrači → IAP speed-up.

## Test pillara

Kad donosiš odluku, pitaj:

1. Koji pillar ovo podržava?
2. Koji pillar ovo krši?
3. Ako krši pillar — zašto je trade-off vrijedan za retention ili prihod?

**Brzi monetizacijski test:** Ako feature donosi kratkoročni revenue ali krši Pillar 2 → **odbaci**.

## Odluke (zaključano)

| Pitanje | Odgovor |
|---------|---------|
| #1 prioritet | Pillar 2 — Fair F2P |
| Konflikt pillars 1 vs 3 | Kratki run (1) ne smije biti prazan samo da gura povratak u kamp (3) — run uvijek daje nešto |
| Komunikacija testerima | “Core besplatan, kamp te zove, svaki run se isplati” |

## Otvorena pitanja

- [ ] Hoće li endless mode imati blaži loot da ne krši Pillar 1 na dugim sesijama?
- [ ] Maksimalan broj interstitiala po danu (guardrail za Pillar 2)?

## Povezano

- [[koncept|koncept]]
- [[../02-design/gdd-overview|gdd-overview]]
- [[../06-production/scope-i-granice|scope-i-granice]]
