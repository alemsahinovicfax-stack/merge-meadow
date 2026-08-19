---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, sezone, ekonomija, iap, f2p, scratch]
povezano:
  - ideje-sezone
  - ideje-sezone-ux-home
  - ideje-sezone-pitanja
  - ekonomija
  - ekonomija-brojevi
  - design-pillars
ai_sažetak: "SEZ-01 ekonomija — free coins+T3 gate, paid IAP packs, Pillar 2 guardrails."
---

# IDEJE — Sezone ekonomija i monetizacija

> Scratch · [[ideje-sezone|SEZ-01]]. Brojevi su **draft** dok playtest ne kaže drugačije.

## Dvije putanje unlocka

| Kind | Valuta | Gate | Redoslijed |
|------|--------|------|------------|
| **Free** | `wallet_coins` + T3 Flower stash | prag po sezoni | Linear `order` |
| **Paid** | Pravi novac (IAP) | kupnja / restore | Ne-linear |

S1 **Country Bloom** — cost 0, odmah unlocked.

## Free unlock (S2+)

### Formula (draft)

```
can_unlock(season) =
  season.kind == free
  AND previous free (order-1) unlocked
  AND wallet_coins >= season.coins_cost
  AND t3_flower_count >= season.t3_flowers_required
```

Pri uspješnom unlocku:

1. Oduzmi `coins_cost` iz `wallet_coins`.
2. **T3 flowers:** draft A — samo **provjera** (ne troši); draft B — **potroši** Y iz `garden_crystal_stash` (global ili po tipu). → [[ideje-sezone-pitanja|pitanje 3]]
3. Dodaj `season.id` u `unlocked_seasons`.
4. Opcionalno auto-`active_season_id = season.id`.

### Draft tablica troškova (placeholder)

| Season order | Example id | Coins | T3 flowers req |
|--------------|------------|-------|----------------|
| 1 | `country_bloom` | 0 | 0 |
| 2 | `frost_orchard` | 80 | 5 |
| 3 | `lantern_meadow` | 150 | 8 |
| 4+ | TBD | raste | raste |

> Sink: free sezone **ne** smiju zahtijevati IAP. Ako coins/T3 nedostaju → igraj / merge / exchange, ne „Buy season with real money“ kao jedini put.

### Odnos prema postojećem exchange

- Seed trade i Flower exchange (Bug-031 rates) ostaju izvor soft coins.
- T3 flower stash (`garden_crystal_stash`) = gate resurs (UI ime Flower).
- Diamonds (`wallet_diamonds`) — **ne** trošiti na free season unlock u draftu (zadržati za shop/kozmetiku TBD).

## Paid seasons (IAP)

### Product draft

| Field | Example |
|-------|---------|
| Product id | `season_pack_moonlit_warren` |
| Type | non-consumable (owned forever) |
| Store listing | Art + „Unlock Moonlit Warren theme“ |
| Restore | Obavezno (Play Billing / kasnije StoreKit) |

### Kupnja flow

1. Shop row **ili** Browser paid card → IAP.
2. Na success: `owned_paid_seasons += id`, `active_season_id` opc. = id.
3. Stub na Windowsu isto kao postojeći `IAPManager` (editor).

### Shop UI

- Sekcija **Season packs** ispod / pored cosmetics.
- Owned → „Select on Home“ deep-link.
- **Ne** prikazivati paid kao jači loot / bolji magnet.

## Pillar 2 — Fair F2P checklist

- [x] S1 uvijek igriv bez IAP i bez teškog grind-a na startu
- [x] Svaka **free** sezona dostupna grindom (coins + flowers)
- [x] Paid ne mijenja loot %, magnet, fail penalty, energy
- [ ] Paid = art, seed **set** (kozmetički/tematski), animal skin, BG, enemies art
- [ ] Ako paid daje **unique seeds**: free sezone i dalje imaju kompletan napredak u svom setu; paid nije obavezan za „clear game“
- [x] Ads / remove-ads ostaju odvojeni od season packs
- [x] Paid IAP stub (Windows) — SKU + Shop/Browser → `grant_paid_season`

**Brzi test:** „Da li free igrač može biti ponosan na svoj vrt i Album bez plaćanja?“ → da.

## Sink rizici (paziti)

| Rizik | Mitigacija |
|-------|------------|
| T3 gate previsok | Playtest brojevi; soft gate early |
| Coins cost = paywall soft | Sink kroz exchange + daily; ne digi IAP |
| Paid preskače free story | OK ako Pillar 2; jasno u UI „Premium theme“ |
| Double spend confusion | Jedan clear CTA Unlock vs Buy |

## Metrike (kasnije)

- % igrača koji otključaju free S2 u D7
- Conversion paid season pack
- Time-to-unlock S2 (median)
- Churn nakon locked teaser frustracije

## Povezano

- [[../02-design/ekonomija|ekonomija]] · [[../02-design/ekonomija-brojevi|ekonomija-brojevi]]
- [[../01-vision/design-pillars|design-pillars]]
- [[ideje-sezone-ux-home|UX]] · [[ideje-sezone-data-model|data model]]
