---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, naslov, sezone, scratch]
povezano:
  - ideje-home-cardfit
  - ideje-home-cardfit-pitanja
  - ideje-home-incard-roster
ai_sažetak: "HOME-09 naslov — ime sezone opet vertikalno centrirano u hero-centar prozoru; override P100 (gore)."
---

# IDEJE — HOME-09 ime sezone na sredini kartice

> [[ideje-home-cardfit|hub]]. Override [[ideje-home-incard-pitanja|P100]] (naslov gore). **Kod CARDFIT-B ✅.**

## Što je krivo

Prije HOME-08, `CenterTitle` / `PaidCenterTitle` su punili karticu: `horizontal_alignment` CENTER, `vertical_alignment` CENTER. Igrač čita **Country Bloom** kao identitet cijelog prozora.

INCARD-A je maknuo naslov u vrh da „roster/gate ne prekriju ime“ (P100): `anchors_preset` 10 (top-wide), `offset_bottom` 72, `vertical_alignment` TOP. Playtest: selektovana sezona **mora** imati ime na sredini kao prije. Gore je korekcija koja je pokvarila poster.

HOME-09 ne bira između imena i rostera. Ime je sloj u sredini kartice. Roster je sloj donje-lijevo. Gate je sloj donje-desno. To je poster s natpisom u sredini i legendom u kutovima, ne header + body.

## Layout (P107)

`CenterTitle` (free hero) i `PaidCenterTitle` (paid hero):

- Parent ostaje `CenterFill` / `PaidCenterFill` (PanelContainer slot ne smije imati više od jednog fill overlaya — HOME-08 to već radi).
- Sidro: **cijeli** Fill (`anchors` full rect, `offset` 0).
- `horizontal_alignment` = CENTER
- `vertical_alignment` = CENTER
- `autowrap_mode` = word wrapping (duga imena: `Moonlit Warren`, `Lantern Meadow`)
- `mouse_filter` = IGNORE (HIT-A — swipe/select ide na Stage)
- Font ~28 ostaje (HOME-08). Ne vraćati mali font.

L/R side kartice (`LeftTitle` / `RightTitle` i paid ekvivalenti) **ne** dirati ovim sliceom — uske, ime već na kartici. Samo **hero-centar**.

Preview 20% traka: naslov kako sad (mali); nije ovaj prigovor.

## Overlay vs ime

Roster donje-lijevo i gate donje-desno **smiju** vizualno prekriti donji dio slova ako je ime dugačko i wrapa u treći red. Preferencija: ime ostaje vizualno u **sredini** kartice (centar bounding boxa labele = centar Fill-a). Ne gurati labelu prema gore da „oslobodi“ roster — to je P100 i playtest ga je odbio.

Ako 6 redova rostera + gate + centrirani naslov izgledaju zbijeno na kratkom hero slotu (`HERO_MIN` 300): prvo širina rostera (P109), pa eventualno smanjiti visinu reda ~48. **Ne** vraćati naslov gore.

## Boja naslova (povezano P108, otvoreno)

Danas je `CenterTitle` hardkodiran tamno `Color(0.18, 0.22, 0.2)` — čitljiv na Bloom/Frost/Lantern/Amber/Coral (svijetle kartice). Na Moonlit (`3D3A6B`) i Starfall (`6B5B95`) tamni tekst na tamnoj kartici je slab.

CARDFIT-B **smije** (nije obavezno u istom PR-u kao algoritam rostera) postaviti `font_color` naslova: tamni tekst na svijetlim karticama, cream `FFF6D6` na tamnim. Ako agent u B dira samo roster frame i ostavi naslov tamnim na Moonlit, to je poznati ostatak — zabilježen kao otvoreno pitanje, ne blokira A.

Outline playable-active (5px cream, HOME-06) ostaje na **kartici**, ne na labeli.

## Što ne dirati

- `set_active` / Play badge / outline pravila (P61, P75)
- In-place L/R morph — naslov je dijete slota pa se pretapa s karticom (P101 ostaje)
- 🔒 prefix na locked next-lock: ako HOME-08/07 već dodaje lock znak u naslov, ostaviti; ne izmišljati novi chrome u ovom sliceu osim centra

## Tehnički (za CARDFIT-B, ne P0 kod)

- [`season_stage.tscn`](../../game/scenes/ui/season_stage.tscn): `CenterTitle` i `PaidCenterTitle` — full rect, vertical center. Maknuti `offset_bottom` 72/48 top-only.
- Ne dirati `FreeRoster` / `PaidRoster` sidro (i dalje bottom-left); samo širinu u roster sliceu.
- Smoke: hero Bloom — `CenterTitle.vertical_alignment == VERTICAL_ALIGNMENT_CENTER` i anchors pune visine Fill-a, ne top-72.

## Acceptance

- Free-hero Country Bloom u centru: **Country Bloom** stoji na sredini zelene kartice, ne uz gornji rub.
- Cycle na Amber (nakon A): **Amber Canopy** na sredini jantar kartice; roster lijevo-dolje; gate desno-dolje ako je next-lock.
- Paid-hero Coral: **Coral Tide** na sredini koraljnog prozora.
- L/R uske kartice i dalje imaju svoje kratke naslove — ovaj slice ih ne dira.
