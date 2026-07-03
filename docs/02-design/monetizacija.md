---
status: draft
tags: [dizajn, monetizacija]
---

# Monetizacija

## Sažetak

**F2P hybrid** — rewarded video (primarno) + lagani IAP. Core loop uvijek besplatan (Pillar 2).

## Model

- [ ] Premium (jednokratna kupnja)
- [x] Free-to-play + IAP
- [x] Free-to-play + ads
- [x] Hibrid — **odabrano**
- [ ] N/A

## Revenue stack (launch)

| Sloj | Implementacija | Prioritet |
|------|----------------|-----------|
| Rewarded video | ×2 loot, revive (max 1/run) | P0 — greybox test |
| Interstitial | Samo loot ekran, opcionalno | P1 — A/B post-launch |
| IAP remove ads | €3.99 | P0 launch |
| IAP starter pack | €1.99 jednokratno | P0 launch |
| IAP boosters | €0.99–1.99 consumable | P1 launch |

## Ad plasman (Fair F2P)

| Moment | Format | Dozvoljeno |
|--------|--------|------------|
| Kraj runa — ×2 loot | Rewarded | ✅ |
| Kraj runa — revive | Rewarded | ✅ max 1/run |
| Loot ekran — prije retry | Interstitial | ⚠️ opcionalno, A/B |
| Usred lane runa | Bilo što | ❌ zabranjeno |
| Prije prvog mergea (tutorial) | Bilo što | ❌ |

## IAP katalog (v1)

| SKU | Cijena | Sadržaj |
|-----|--------|---------|
| `remove_ads` | €3.99 | Trajno ukloni interstitiale; rewarded ostaje opcionalan |
| `starter_pack` | €1.99 | Burst T2 orbs + 1 booster (jednokratno po accountu) |
| `booster_hint` | €0.99 | Consumable — kasnije ako treba |
| `speed_merge_24h` | €1.49 | Opcionalno v1.1 |

## Etika i player trust

- Bez loot boxeva i gacha
- Transparentne cijene u shopu
- Rewarded = uvijek opcionalan
- Remove ads za igrače koji ne žele interstitiale
- Bez dark patterns (lažni X, preteški dismiss)

## Segmentacija (očekivani mix)

| Segment | ~% | Prihod |
|---------|-----|--------|
| Samo ads | ~90% | ARPDAU $0.03–0.15 |
| Casual payer | ~5% | €2–5 lifetime |
| Whales | ~1% | Ignorirati u v1 |

## Integracija (Godot)

- **Android:** AdMob plugin + Google Play Billing
- **iOS:** AdMob + StoreKit (build preko Mac/CI)
- Test ad uniti tijekom greyboxa

## Vertical slice vs launch

| Feature | M7 slice | Launch |
|---------|----------|--------|
| Rewarded test ads | ✅ | ✅ |
| IAP remove ads | Stub/test | Production |
| Interstitial | OUT slice | Opcionalno |
| Starter pack | OUT slice | ✅ |

## Otvorena pitanja

- [ ] Točan EUR pricing po regiji (store auto)
- [ ] Ad frequency cap (max interstitial/dan)

## Povezano

- [[ekonomija|ekonomija]]
- [[../04-experience/ui-ux|ui-ux]]
- [[../06-production/scope-i-granice|scope-i-granice]]
