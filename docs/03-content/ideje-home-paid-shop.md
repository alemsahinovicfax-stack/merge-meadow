---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, shop, iap, paid, sezone, ux, scratch]
povezano:
  - ideje-home-paid
  - ideje-home-paid-pitanja
  - ideje-sezone-ekonomija
  - ideje-sezone
  - plan-prompts-home-paid
ai_sažetak: "HOME-04 shop — pack kartice kao Browser prozori; 2 po redu; wrap; owned bez Select; IAP na unowned."
---

# IDEJE — HOME-04 shop (Season packs)

> [[ideje-home-paid|HOME-04 hub]]. Kod: [`game/scripts/ui/shop_screen.gd`](../../game/scripts/ui/shop_screen.gd), [`game/scenes/ui/shop_screen.tscn`](../../game/scenes/ui/shop_screen.tscn). Vizualni donor: [`season_browser.gd`](../../game/scripts/ui/season_browser.gd) `_make_paid_card` (168×120).

## Problem (točno u kodu)

`SeasonPacksPanel` ima `SeasonPacksList` **VBox**. Za svaki `SeasonCatalog.paid_defs()` spawn-a se `UiClickButton` `custom_minimum_size.y = 72`, puna širina scrolla.

Label (`_season_pack_button_label`):

| Stanje | Tekst danas |
|--------|-------------|
| Unowned | `{title} — {price}` |
| Owned, nije active | `{title} — Select theme` |
| Owned, active | `{title} — Selected` |

Tap (`_on_season_pack_pressed`):

- Owned → `GameState.set_active_season(season_id)` + status „is now your active theme.“
- Unowned → `IAPManager.purchase(sku)`

To čini Shop **picker teme**. Igrač mora „selektovati paid sezonu da bi je igrao“ iz Shopa. HOME-04 to **izbacuje**.

Hint „Cosmetic themes. No extra power.“ je točan i **ostaje**.

## Cilj osjećaja

Otvoriš Shop, skrolaš do **Season packs**. Vidiš **iste prozore** kao Premium red u Season Browseru: pravokutne kartice s imenom sezone, ne shop-row gumbi. U **jednom retku stoje dvije**. Kad (ako) dodamo treću i četvrtu paid sezonu, one sjede **u retku ispod**, isti format — lista raste dolje unutar postojećeg `MainScroll`.

Kupovina je jedina akcija na unowned kartici. Owned kartica kaže da je tvoja; igraš je s Homea.

## Što shop **jest** (PAID-A)

1. Ukloniti Select / Selected / `set_active_season` iz shop owned tap-a.
2. Kartica vizualno = Browser paid prozor (ne 72px full-width).
3. Layout **2 stupca**; N>2 wrap na sljedeći red.
4. Unowned tap = IAP (postojeći `purchase`).
5. Owned tap = **no-op** (P47). Label **Owned**.
6. P12 na **uspješan grant** i dalje smije postaviti `active_season_id` (to je kupnja, ne Select gumb). Shop UI nakon toga pokazuje Owned, ne Selected.
7. Shared widget s Browserom da „izgleda kao Browser“ nije copy-paste boja.

## Što shop **nije**

- Nije dual-band Home (to je B/C).
- Nije deep-link „Go to Home“ na owned tap (P47 / P56).
- Nije 2-col obavezan u Browseru (P53: Browser paid ostaje horizontalni P6).
- Nije mijenjanje SKU-ova, cijena, Fair F2P copy, restore purchases, remove-ads panela.
- Nije auto-swap `home_band` na paid dok je igrač još na Shop pageu (P48).

## Layout (2 po redu + prostor ispod)

```
┌─────────────────────────────────────┐
│  Season packs                       │
│  Cosmetic themes. No extra power.   │
│                                     │
│  ┌──────────────┐ ┌──────────────┐  │
│  │ Moonlit      │ │ Coral Tide   │  │
│  │ Warren       │ │ Garden       │  │
│  │ $x.xx        │ │ Owned        │  │
│  └──────────────┘ └──────────────┘  │
│  ┌──────────────┐ ┌──────────────┐  │  ← treći/četvrti pack kad postoje
│  │ Future pack  │ │ Future pack  │  │
│  └──────────────┘ └──────────────┘  │
└─────────────────────────────────────┘
```

Danas su 2 paid defa → **jedan red, dvije kartice**. Prazan treći slot se **ne** crta. `GridContainer` `columns = 2`, `size_flags_horizontal` fill na karticama jednako (50/50 minus separation).

`SeasonPacksPanel` ostaje u `MainScroll/MainContent` — visina panela raste s brojem redova; shop već skrola.

Separation draft: 8–12px (kao `SeasonPacksList` danas 8). Kartica min size draft: **~168×120** kao Browser, ali u shop stupcu širina = `(scroll_inner - pad - sep) / 2`. Visina smije rasti s autowrap imena (P14 EN, max 2 linije + cijena).

Ne stavljati horizontalni `ScrollContainer` za packove. Wrap je **vertikalni** rast.

## Stanja kartice

| Stanje | Vizual | Tap |
|--------|--------|-----|
| Unowned, IAP idle | Puna/accent kartica, ime + **price label** (`IAPManager.get_price_label`) | `purchase(sku)` |
| Unowned, IAP busy | Disabled (kao danas `btn.disabled = is_busy`) | no-op |
| Owned | Primary/subtle, ime + **Owned** (EN). Nema Select, nema check uz Play. | **no-op** (P47) |
| Purchase fail | Rebuild/refresh; ostaje unowned | — |
| Purchase ok | Owned; `grant_paid_season` + P12 active. Status tekst smije reći da je tema otključana, **ne** „Selected in shop“. | — |

Fair F2P: **ne** „Stronger loot“, **ne** power badge. Cijena je cijena teme.

## Shared widget (preporuka PAID-A)

Novi npr. `season_pack_card.gd` + mini scena **ili** factory u postojećem stilu Browsera:

- `apply(season_id)` ili `(title, sku, owned)`
- Signal `buy_pressed(sku)` samo kad unowned
- Owned: `mouse_filter` smije ostati STOP ali handler prazan (da HIT ne „propadne“ u scroll na čudan način)
- Isti `button_variant` jezik: unowned accent, owned primary/subtle

**Shop** stavlja kartice u Grid. **Browser** PaidRow i dalje HBox, ali `_make_paid_card` postaje instanca istog widgeta. Owned label u Browseru danas `"%s\nSelect"` → **Owned** (usklađeno; odabir i dalje postoji u Browseru na **tap owned** → `set_active` + close — to je Browser, ne Shop).

Važno: Browser owned tap **ostaje select** (P46 katalog). Samo Shop gubi select. Widget treba `mode` ili flag `select_on_owned: bool` (Shop false, Browser true), **ili** Shop i Browser spajaju različite signale.

Preporuka: widget emitira `pressed`. Shop: ako owned ignore; ako unowned buy. Browser: ako owned `set_active`+close; ako unowned buy.

## Copy (EN, P14)

| Element | Tekst |
|---------|--------|
| Section title | `Season packs` (ostaje) |
| Hint | `Cosmetic themes. No extra power.` (ostaje) |
| Unowned | `{display_name}` + price |
| Owned | `{display_name}` + `Owned` |
| Status after buy | Smije: `Moonlit Warren unlocked.` Ne: `…is now your active theme` vezano uz shop select. P12 i dalje može postaviti active u saveu — copy ne mora lagati, ali ne smije zvučati kao da si „selektovao u shopu“. Draft: `Theme unlocked. Choose it on Home.` **ili** kratko `Unlocked.` Override u P47 follow-up ako smeta. |

Default status: **`{title} unlocked.`** Bez „Select on Home“ gumba (P56).

## IAP / GameState (ne dirati math)

- SKU: `season_pack_moonlit_warren`, `season_pack_coral_tide` (`monetization_config.gd`).
- `grant_paid_season` + P12 auto `active` **ostaju** na purchase_completed.
- `IAPManager.owns_product` i dalje izvor owned UI.
- Restore purchases panel ostaje; restore i dalje grant-a packove.
- Dev reset owned (`clear_owned_paid_seasons`) i dalje radi; kartice se vrate na cijenu.

## Smokes (PAID-A)

Ažurirati [`season_iap_smoke.gd`](../../game/scripts/dev/season_iap_smoke.gd) i shop smokes:

- Mock purchase → owned + playable + P12 active **smije** biti paid (grant).
- Simulacija **drugog** tap-a na owned shop karticu **ne** smije zvati `set_active` ako je igrač u međuvremenu stavio active na free (assert: tap owned shop ne prepisuje active). Najčišće: unit/UI hook ili dokumentirati da shop handler nema `set_active` granu — grep smoke.
- Shop open smoke: `SeasonPacksList` / grid ima 2 childa za 2 defa; nisu full-width 72 gumbi s „Select theme“.

## Node mapa (draft)

`SeasonPacksList` (VBox) → zamijeni s `GridContainer` `%SeasonPacksGrid` `columns=2`. `_build_shop_lists` spawna kartice umjesto `UiClickButton`. `_refresh_season_pack_rows` zove `card.apply` / refresh owned.

Ne dirati: CoinShop, Boosters, IapPanel (remove ads / starter / restore) osim ako typography helperi moraju vidjeti novi grid.

## Playtest (čovjek) — Shop

1. Otvori Shop, skrolaj do Season packs: **dva prozora u retku**, ne dva dugačka gumba.
2. Unowned tap → purchase stub → kartica **Owned**.
3. Još jednom tap Owned → **ništa** (active se ne mijenja ako si na Homeu stavio S1).
4. Home / Browser i dalje mogu staviti paid active.
5. Fair: nigdje „+loot“ na pack kartici.

## Povezano

- [[ideje-home-paid|hub]] · [[ideje-home-paid-pitanja|P47 P48 P53 P56]]
- [[ideje-sezone-ekonomija|SEZ ekonomija]] — stari „Select on Home“ deep-link **ukinut**
