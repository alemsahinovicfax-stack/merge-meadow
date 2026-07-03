---
status: draft
tags: [iskustvo, ui]
---

# UI / UX

## Sažetak

Portrait, jednoručni flow optimiziran za **brzi ulaz u run** i **monetizaciju na loot ekranu** — bez agresivnih prekida usred gameplaya (Pillar 2).

## Ekrani (screen map)

```
Splash (1s)
    ↓
Main Menu ── Play ──→ Lane Run (HUD)
    │                      ↓
    ├── Kamp ←──────── Loot Screen
    ├── Shop                 ↑ (Revive in-run samo rewarded modal)
    └── Settings
```

### Popis ekrana

| Ekran | Svrha | Monetizacija |
|-------|-------|--------------|
| Splash | Brand, brzo učitavanje | — |
| Main menu | Play, Kamp, Shop, Settings | Shop vidljiv |
| Lane run HUD | Core gameplay | — |
| Pause | Resume, Quit to menu | — |
| Loot / “Nice run!” | Nagrada + odluke | **×2 Loot**, Revive (rewarded) |
| Kamp | Merge, upgrade, daily | Shop shortcut |
| Shop | Remove ads, starter, boosters | IAP |
| Settings | Zvuk, haptic, notifications | — |
| Tutorial overlay | Prvi launch only | — |

## Flow detalji

### Prvi launch (player promise &lt;60 s)

1. Splash → **direktno tutorial run** (bez main menu zida)
2. Vođeni swipe + prvi pickup
3. Kratki fail → loot ekran (objašnjenje)
4. Vođenje u kamp → prvi merge
5. Tek onda **Main menu** s “Play” istaknutim

### Returning player (min tapova do gameplaya)

**Main menu → Play = 1 tap** → lane run.

### Run završetak (komercijalni hub)

```
Run end → Loot screen
    ├── Tap ×2 Loot → Rewarded video → doubled orbs
    ├── Tap Revive (ako fail, max 1×) → Rewarded → continue run
    ├── Tap Retry → besplatno novi run
    └── Tap U kamp → merge ekran
```

**Ton:** “Nice run!” / “+XX Orbs” — ne “GAME OVER” crvenilo.

### Kamp → sljedeći run

- Bottom nav: **Play** (primary), Kamp, Shop
- Soft cliff: pulsing “1 merge do Magnet Lv.X”
- Daily chest badge na Kamp ikoni

### Shop (v1 SKU)

| SKU | Cijena (draft) | Pozicija |
|-----|----------------|----------|
| Remove Ads | €3.99 | Hero kartica |
| Starter Pack | €1.99 | Ispod remove ads |
| Booster pack | €0.99–1.99 | Consumables |

## Mobile UX

- **Safe areas:** notch + home indicator — HUD i bottom nav unutar safe zone
- **Loading:** splash &lt;2 s; async load kamp asseta u pozadini
- **Offline:** kamp i run rade offline; shop IAP zahtijeva mrežu
- **Errors:** IAP fail → friendly toast, retry; ad fail → “Ad not available”, nastavi bez kazne

## Onboarding

- Max **2 callout bubblea** u tutorial runu
- Skip nakon prvog mergea u kampu
- Ne prikazuj Shop dok tutorial nije gotov

## Ostalo (v1 scope)

| Feature | v1 |
|---------|-----|
| Dark mode | OUT |
| Tablet layout | OUT (scaled phone) |
| Lokalizacija | EN only launch |

## Otvorena pitanja

- [ ] Interstitial na loot ekranu — A/B nakon launcha
- [ ] Daily popup: auto ili samo badge?

## Povezano

- [[../02-design/kontrole-i-input|kontrole-i-input]]
- [[../02-design/core-loop|core-loop]]
- [[art-direction|art-direction]]
- [[pristupacnost|pristupacnost]]
