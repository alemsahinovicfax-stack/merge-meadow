---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, pitanja, paid, shop, sezone, scratch]
povezano:
  - ideje-home-paid
  - ideje-home-paid-shop
  - ideje-home-paid-layout
  - ideje-home-paid-gesta
  - ideje-home-polish-pitanja
  - ideje-home-chrome-pitanja
  - plan-prompts-home-paid
ai_sažetak: "HOME-04 pitanja — P45–P59 freeze chat 2026-08-20."
---

# IDEJE — HOME-04 pitanja

> [[ideje-home-paid|HOME-04 hub]]. SEZ P1–P15, HOME P17–P28 / P30–P44 ostaju. **P16** je overridean samo za **zasebnu paid traku** (free traka i dalje samo free).

## Kako koristiti

1. Pregledaj **P45–P59** (freeze 2026-08-20). Override samo ako svjesno mijenjaš spec.
2. Kod: prompti **A → B → C** u [[../06-production/plan-prompts-home-paid|plan-prompts-home-paid]].
3. Ne vraćaj SEZ-C jedan karusel (paid+free isti swipe). Ne ukidaj Browser (P46).

---

## P45 — Unowned paid na Home preview traci

**Pitanje:** Gornjih ~20% (paid preview, prije klika u fokus): što se prikazuje kad pack nije kupljen? Katalog ima 2 stub-a: Moonlit Warren, Coral Tide.

| Opcija | |
|--------|--|
| A | **Sve** paid sezone. Unowned = sivo/cijena/katanac; owned = puna boja. Tap unowned u 20% **ipak** prebacuje u paid-fokus. Kupnja ostaje na kartici / Shopu / Browseru. |
| B | Samo owned. Ako ništa nije kupljeno, 20% prazno ili „Season packs“ teaser → Shop. |
| C | Sve vidljive, ali tap unowned u 20% **ne** swap-a — otvara Shop/IAP. Paid-hero samo za owned. |

**Odgovor (freeze 2026-08-20):** **A**.

---

## P46 — Season Browser nakon dual-banda

**Pitanje:** Popup (tap središnje kartice, P40) ima free red + Premium paid. Dual-band preuzima brzi odabir. Što s Browserom?

| Opcija | |
|--------|--|
| A | **Ostaje.** Centar u **80% hero** i dalje otvara Browser. Dual-band = brzi odabir; Browser = katalog. |
| B | Ukinuti Browser. Odabir samo dual-band + Unlock sheet. Shop za kupnju. |
| C | Ne dirati Browser kod u ovom tracku; odluka poslije playtesta. |

**Odgovor (freeze 2026-08-20):** **A**. Preview centar **nije** Browser — to je swap (vidi gesta).

---

## P47 — Shop owned tap

**Pitanje:** Kad nema „Select theme“, što radi tap na owned pack u Shopu?

| Opcija | |
|--------|--|
| A | **No-op.** Label `Owned`. |
| B | Gumb „Go to Home“ / deep-link hub page. |
| C | I dalje `set_active_season` (stari Shop picker). |

**Odgovor (2026-08-20):** **A**. Browser owned tap i dalje select+close (katalog). Status nakon IAP: `{title} unlocked.` (ne „Selected“).

---

## P48 — P12 grant vs Home band

**Pitanje:** Nakon kupnje u Shopu, auto `active_season_id` (P12) ostaje. Skakati li odmah na paid-hero dok je igrač na Shop pageu?

| Opcija | |
|--------|--|
| A | P12 active **da**. `home_band` **ne** dirati u Shopu. `paid_strip_focus_id` smije = kupljeni id. |
| B | I `home_band = paid` odmah (igrač vidi paid-hero kad swipea natrag na Home). |
| C | Ni active ni band na grant; igrač bira ručno. |

**Odgovor (2026-08-20):** **A**. Grant nije „Select u shopu“. Home persist (P49) pokaže zadnji band kad se vrati.

---

## P49 — Save persist banda

**Pitanje:** Reset na free-hero svaki put kad se otvori Home, ili pamtiti zadnji band?

| Opcija | |
|--------|--|
| A | Persist `home_band` + `paid_strip_focus_id`. New game = `free` + S1. Nakon runa ostaje zadnji band. |
| B | Svaki ulazak na Home page = `free` hero. |
| C | Persist samo u sesiji, ne u JSON. |

**Odgovor (2026-08-20):** **A**. „Default prva free“ = new game / nikad swap, ne cold-reset svakog show-a.

Migrate: novi SAVE_VERSION polja; stari save → `home_band=free`, paid fokus = prvi paid def.

---

## P50 — Play kad je paid-centar unowned

**Pitanje:** New game, igrač otvori paid-hero s Moonlit unowned u centru. Što radi Play?

| Opcija | |
|--------|--|
| A | **Ne** diraj `active`. Play vozi zadnji playable (S1). Badge ako vizual ≠ active. |
| B | Disable Play dok centar nije playable. |
| C | Play na unowned centar otvara IAP/Shop. |

**Odgovor (2026-08-20):** **A**. Nema paywall na Play gumbu.

---

## P51 — Redoslijed paid trake

**Pitanje:** Tko je lijevo/desno u paid 3-slotu?

| Opcija | |
|--------|--|
| A | `SeasonCatalog.paid_defs()` array order (`seasons.json`). Danas Moonlit, Coral. |
| B | Novo polje `paid_order` u JSON sada. |
| C | Alfabet display_name. |

**Odgovor (2026-08-20):** **A**. `paid_order` kasnije ako katalog poraste i treba ručni sort.

---

## P52 — Animacija 20 ↔ 80

**Pitanje:** Instant cut visina ili tween?

| Opcija | |
|--------|--|
| A | Tween visine **220–280ms** ease-out (usklađeno s P42). |
| B | Instant. |
| C | Crossfade modulate bez layout tweena. |

**Odgovor (2026-08-20):** **A** u **PAID-C**. PAID-B smije instant da se omjer vidi.

---

## P53 — Browser paid layout

**Pitanje:** Shop postaje 2-col. Mijenja li se Browser Premium red?

| Opcija | |
|--------|--|
| A | Browser **ostaje horizontalni** (P6). Shared kartica sa Shopom. |
| B | Browser paid također 2-col grid. |
| C | Browser paid wrap kao Shop. |

**Odgovor (2026-08-20):** **A**. 2-col Browser nije ovaj track.

---

## P54 — Inline IAP na Home hero

**Pitanje:** Tap unowned paid u **hero** (80%) kupuje odmah?

| Opcija | |
|--------|--|
| A | **Ne** u C v1. Tap C = Browser; tap L/R unowned = fokus bez active. Kupnja Shop/Browser. |
| B | Tap unowned hero C = `IAPManager.purchase`. |
| C | Mini buy sheet na Homeu. |

**Odgovor (2026-08-20):** **A**.

---

## P55 — Swipe na preview traci

**Pitanje:** Smije li preview (~20%) horizontalno cycleati svoj katalog?

| Opcija | |
|--------|--|
| A | **Ne.** Statičan. Tap-or-nothing na okviru. Drag ≠ cycle. |
| B | Da, nezavisni swipe i na preview. |
| C | Preview swipe samo ako ima >3 paid. |

**Odgovor (2026-08-20):** **A**. Hero swipe je jedini cycle. To je jezgra ideje („gornji dio se ne pomiče dok swipeaš donji“).

---

## P56 — Deep-link Shop → Home

**Pitanje:** Owned kartica ili post-buy CTA šalje na Home?

| Opcija | |
|--------|--|
| A | **Ne** u PAID-A. |
| B | „Choose on Home“ gumb → hub Home page + opcionalno paid-hero. |

**Odgovor (2026-08-20):** **A**.

---

## P57 — Reduce-motion / haptics

**Pitanje:** Settings flag, skip tween, snap haptic?

**Odgovor (2026-08-20):** **Ne** u ovom tracku. Kao HOME-03.

---

## P58 — Tutorial

**Pitanje:** Novi korak „ovo su paid sezone gore“?

**Odgovor (2026-08-20):** **Ne.** Trake vidljive; nije tutorial korak (P25). Endless i dalje poslije `tutorial_complete` (P44).

---

## P59 — Više od 2 paid sezone

**Pitanje:** Kad budemo imali 4–6 packova, Home paid traka postaje grid?

| Opcija | |
|--------|--|
| A | **Ne.** Home = 3-slot prozor `focus ± 1`. Shop wrap 2-col. Browser lista/horizontal. |
| B | Home preview postaje 2-col mini-grid. |

**Odgovor (2026-08-20):** **A**. Zato Shop **sada** ostavlja prostor ispod za sljedeće redove.

---

## Pitanja za kasnije (ne blokiraju A/B/C)

1. Thumbnail art vs ColorRect na preview visini 100px — čitljivost imena.
2. Label „Premium“ iznad PaidBand — default **ne** (raspored kartica mora govoriti sam).
3. Sound na band swap.
4. Accessibility: unowned samo sivilo vs sivilo+katanac+cijena — default **sve tri** sitno ako stane; preview smije dropati cijenu ostaviti lock.
5. Ima li smisla `paid_order` u JSON prije trećeg packa — ne.
6. Localization dužih imena na preview (Coral Tide Garden) — autowrap 2 linije, P14 EN ostaje.
7. Treba li preview prikazivati 2 kartice umjesto 3-slot peek kad su samo 2 paid — default **isti 3-slot** (`[—][A★][B]`).
8. Badge tap → Browser paid — i dalje no-op (P43) osim overridea.

---

## Sažetak freeze HOME-04

| # | Odluka | Freeze? |
|---|--------|---------|
| **P45** | Sve paid na Home traci; unowned sivo; tap 20% swap | **Da** |
| **P46** | Browser ostaje; hero C = Browser | **Da** |
| **P47** | Shop owned = Owned, no-op | **Da** |
| **P48** | P12 active da; band ne skače u Shopu | **Da** |
| **P49** | Persist `home_band` + paid fokus | **Da** |
| **P50** | Unowned hero: Play = zadnji playable | **Da** |
| **P51** | Paid order = katalog array | **Da** |
| **P52** | Visina tween u C | **Da** |
| **P53** | Browser paid ostaje horizontal | **Da** |
| **P54** | Nema inline IAP na Home C v1 | **Da** |
| **P55** | Preview swipe zabranjen | **Da** |
| **P56** | Nema Shop deep-link A | **Da** |
| **P57** | Nema reduce-motion | **Da** |
| **P58** | Nema season tutoriala | **Da** |
| **P59** | Home 3-slot i za N>2 paid | **Da** |

**P45–P59** freeze chat 2026-08-20. „Pitanja za kasnije“ iznad ne blokiraju kod.

## Povezano

- [[ideje-home-paid|hub]] · [[ideje-home-paid-shop|shop]] · [[ideje-home-paid-layout|layout]] · [[ideje-home-paid-gesta|gesta]]
- [[ideje-home-polish-pitanja|P16–P27]] · [[ideje-home-chrome-pitanja|P36–P44]]
- [[../06-production/plan-prompts-home-paid|prompti]]
