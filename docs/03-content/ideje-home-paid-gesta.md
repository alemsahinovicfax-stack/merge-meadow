---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, gesta, swipe, paid, sezone, scratch]
povezano:
  - ideje-home-paid
  - ideje-home-paid-layout
  - ideje-home-paid-pitanja
  - ideje-home-chrome-gesta
  - ideje-home-hit-targets-gesta
  - ideje-home-polish-carousel
ai_sažetak: "HOME-04 gesta — preview statičan; tap samo okvir sezone za band swap; hero swipe izoliran; P40 Browser samo hero centar; HIT-A ostaje."
---

# IDEJE — HOME-04 gesta (izolacija + click-to-swap)

> [[ideje-home-paid|HOME-04 hub]]. Hit-through: [[ideje-home-hit-targets|HOME-02]] **ostaje**. Hero slide: [[ideje-home-chrome-gesta|HOME-03]] P42 **ostaje na hero traci**. Ovo dodaje **drugu traku** i **swap**, ne novi wrap.

## Pravilo jednom rečenicom

Swipe radi **samo** na traci koja je trenutno hero (~80%). Preview (~20%) je **slika**; jedina gesta tamo je **kratki tap na okvir sezone** → ta traka postaje hero.

## Dvije mape (hero vs preview)

Hit-test: `get_global_rect()` na L/C/R slota **te trake**. Release pozicija. Prag `SWIPE_LOCK_PX` 20 (P30) **samo na hero**. Preview: dx iznad praga i dalje **nije cycle** (P55) — ili tretiraš kao otkazan tap, ili ignorišeš swipe; **ne** mijenjaj fokus preview trake.

Redoslijed hit-testa na traci: L → R → C → gap return (kao CHROME-B). Granica L/C preferira L.

### Hero (~80%)

Ista sematika kao današnji free strip, primijenjena na **aktivni** katalog (free ili paid).

| Zona | Tap (nije swipe) | Swipe |
|------|------------------|-------|
| **C** | `open_browser()` (P40, **P46**) | cycle ±1 po pravilima trake |
| **L** visible owned/unlocked | fokus + `set_active` ako playable | dio swipea |
| **R** unlocked free / owned paid | isto | dio swipea |
| **R** locked **free** | Unlock sheet (P11). Ne Browser. | bounce, ne fokus na locked |
| **C ili L/R unowned paid** | Tap C = Browser (kupnja tamo). Tap L/R unowned = **fokus na taj paid**, **bez** `set_active` (P50, P54). | Paid: smije cycle na unowned centar. Free: ne cycle na locked. |
| **G** gap te trake | no-op (P41) | no-op |

Hero **paid** swipe bounce na krajevima liste (nema wrapa), analog P20. Hero **free** bounce na locked next / nema prev — **ne dirati**.

### Preview (~20%)

| Zona | Tap | Swipe / drag |
|------|-----|----------------|
| **Bilo koji vidljivi okvir sezone** (L, C ili R) | **Band swap** + fokus na **tu** sezonu | **Ne** (P55). Statično. |
| Locked free u preview | Swap u **free-hero** (ako već nisi) + Unlock sheet; locked **ne** postaje centar | Ne |
| Unowned paid u preview | Swap u **paid-hero** s tom karticom u **centru**; `active` se **ne** mijenja (P45, P50) | Ne |
| Owned paid / unlocked free u preview | Swap + ta sezona centar hero + `set_active` | Ne |
| Gap / pad preview trake | **no-op** | Ne |
| Separator između bandova | no-op | Ne |

**Klik se prima samo na okviru sezone.** To je P40/P41 proširen na preview: nije „tap bilo gdje gore“, nego tap **kartice**.

## Band swap (što se dogodi)

1. `home_band` prelazi `free` ↔ `paid`.
2. Visine: stari hero → preview min visina; stari preview → hero. **Strane ostaju** (paid top, free bottom).
3. Traka koja ulazi u hero dobija `StripMotion` slide semantiku; ona koja izlazi **prestaje** primati swipe (P55).
4. Fokus: ID sezone čiji je okvir tapnut postaje `strip_focus_id` ili `paid_strip_focus_id`.
5. `set_active_season` samo ako je ta sezona **playable** (unlocked free ili owned paid).
6. Tween visine ~220–280ms ease-out (P52). **C**; B smije instant.
7. Tijekom tweena: `_slide_busy` analog — ignoriraj nove swipeove i tap-swap (anti double-swap).
8. Na kraju: `refresh()` obje trake; Play badge P50.

Ne animirati **zamjenu strana** (paid ne ide dolje).

## Izolacija swipea (ključni zahtjev)

Dok je free hero:

- Horizontalni drag koji **počinje** na FreeBand hero → `cycle_free_strip`, PaidBand **x ostaje 0**, paid fokus se ne mijenja.
- Drag koji počinje na PaidBand preview → nije cycle; ako je tap (dx < 20) na okviru → swap.

Dok je paid hero: obrnuto.

Hub `SwipePager`: Stage root i dalje u `block_hub_swipe`. Drag na **bilo kojoj** traci unutar Stagea ne smije mijenjati Shop/Camp page. Drag na Play (ispod Stagea) smije (postojeća pravila).

Ne dijeliti jedan `_pressing` state na obje trake bez `press_band` enum. Inače prst koji krene na preview i ode na hero ukrade cycle.

Preporuka state:

```
_pressing: bool
_press_band: none | paid | free
_press_start: Vector2
_swiped: bool
_band_tween_busy: bool
```

Ako press na preview: swipe lock ne pali cycle; na release, ako `!_swiped` i hit slot → swap. Ako `_swiped` (prst odlutao) → no-op (sigurnije od slučajnog swap-a).

Ako press na hero: postojeći CHROME-C path za **tu** traku.

## HIT-A invariant

Djeca `PaidRow` / `FreeRow` / motion holdera: `MOUSE_FILTER_IGNORE`.  
Stage (ili BandColumn ako Stage ne pokriva hit): `STOP` + `gui_input`.  
**Ne** stavljati `Button` na slotove.  
Ne vraćati STOP na kartice radi „lakšeg“ tapa — to je HOME-02 regresija.

Overlay Browser/Unlock: STOP, `block_hub_swipe`; dok visible, Stage ne prima (P32).

## P40 override (važno)

| Gdje | Tap centar |
|------|------------|
| Hero 80% C rect | Browser (katalog free + paid) |
| Preview 20% C rect | **Swap banda**, ne Browser |

Implementacija: `_handle_tap` mora znati `home_band` i koja je traka hitnuta. `else Browser` je **zabranjen** (isti bug kao prije CHROME-B).

## P11 locked free iz previewa

Igrač vidi mini 🔒S3 dolje dok je u paid-hero. Tap tog okvira:

1. Swap u free-hero (S3 ostaje **desni** locked, centar ostaje zadnji unlocked fokus — **ne** S3 u centru).
2. Otvori Unlock sheet za taj id.

Ako je već free-hero, tap R locked = samo sheet (kao danas).

## Unowned paid iz previewa

Tap Moonlit (unowned) gore dok je free-hero:

1. Swap paid-hero, centar Moonlit, Coral desno (ili L ako fokus Coral).
2. Ne `set_active` na Moonlit.
3. Play i dalje vozi zadnji playable (S1). Badge ako treba (P50).
4. Kupnja: otvori Browser (drugi tap na **hero** C) ili idi u Shop. **Nema** inline IAP u C v1 (P54).

## Slide (hero only)

Svaka traka ima vlastiti motion holder. `cycle_*` na **hero** = CHROME-C slide ~220ms na tom holderu. Preview holder `position.x = 0` uvijek.

Bounce: locked/rub **te** hero trake, 8–12px, ne wrap.

Follow-finger: **ne** u C v1 (P42 ostaje).

## Play / Endless tijekom swap-a

Gumbi ispod Stagea; nisu u hit mapi trake. Tijekom visinskog tweena Play i dalje radi (active se ne mijenja osim ako je swap postavio playable fokus).

## Overlay vs swap

Ako je Browser otvoren, nema swap/swipe ispod. Close Browser, zatim geste.

## Playtest (čovjek)

1. Default: swipe **dolje** na velikoj free traci → S1/S2; **gornji** paid mini se **ne** miče.
2. Tap **praznine** gore između paid kartica → ništa.
3. Tap **Moonlit okvir** gore → paid raste, free mini dolje; Moonlit veliki.
4. Swipe na velikom paid → Coral; **donji** free mini se ne miče.
5. Tap **S1 okvir** dolje → natrag; S1 veliki.
6. Tap **sredine** velike trake → Browser; zatvori.
7. Tap sredine **mini** trake → swap, **ne** Browser.
8. New game: Play i dalje Country Bloom bez kupnje.
9. Hub swipe s Play zone → Shop/Camp; swipe na Stageu ne mijenja page.

## Smoke (PAID-C)

Proširiti `season_home_smoke`:

- Free cycle ne mijenja `paid_strip_focus_id`.
- Simulirani tap (ako smoke može) ili API `swap_to_paid(id)` / `swap_to_free(id)`: `home_band` flip; drugi band visina preview.
- `open_browser` nije pozvan na preview centar (ako testiraš kroz API, razdvoji `on_preview_slot_tapped` vs `on_hero_center_tapped`).
- Hub isolation ostaje.
- Await band tween ~0.3s.

Ako headless ne može lako tapnuti, izloži `swap_home_band(to, focus_id)` za smoke i zasebno testiraj da cycle_free ne zove cycle_paid.

## Povezano

- [[ideje-home-chrome-gesta|HOME-03]] — slide, P40/P41
- [[ideje-home-hit-targets-gesta|HOME-02]] — prag, IGNORE
- [[ideje-home-paid-pitanja|P45–P46 freeze; P52 P54 P55]]
