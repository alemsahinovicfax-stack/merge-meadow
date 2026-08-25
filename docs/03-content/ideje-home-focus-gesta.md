---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, gesta, swipe, sezone, scratch]
povezano:
  - ideje-home-focus
  - ideje-home-focus-pitanja
  - ideje-home-paid-gesta
  - ideje-home-glide
  - ideje-home-chrome-gesta
ai_sažetak: "HOME-06 gesta — invert V swipe; L/R in-place pretapanje kao band-swap; preview H statičan."
---

# IDEJE — HOME-06 gesta (invert + L/R pretapanje)

> [[ideje-home-focus|HOME-06 hub]]. Band-swap visine: [[ideje-home-paid-gesta|HOME-04 gesta]] + [[ideje-home-glide|HOME-05]] P62 **ostaju** (samo smjer swipea se invertira). HIT-A ostaje. Preview H: P55.

## Pravilo jednom rečenicom

Free↔paid **raste/skuplja visinu** (~250ms) na istim nodeovima. Lijevo-desno radi **istu preobrazbu**: slotovi stoje, ime/boja/lock se pretapaju u novi 3-slot prozor, isti `BAND_TWEEN_SEC`. Vertikalni swipe: prst dolje otvara paid, prst gore otvara free.

## Referenca koja se ne dira

`swap_home_band` + `_tween_band_heights`:

- `RATIO_HERO` / `RATIO_PREVIEW` (1 i 4, odnosno 20/80 uz `PREVIEW_MIN=110`, `HERO_MIN=300`)
- `BAND_TWEEN_SEC` 0.25, `TRANS_SINE`, `EASE_OUT`
- Paid **uvijek** top, free **uvijek** bottom
- Tijekom tweena `_band_tween_busy` — nema drugog swipea / tap-swapa
- Tap na preview okvir i dalje radi isti swap (P46 / PAID-C)

Igrač je rekao da mu se **samo ovo** sviđa. Ne mijenjaj duration, easing, ni omjere „da L/R bude sličniji“.

## Vertikalni swipe (P70 invert)

Axis lock ostaje: nakon 20px dominantni `|dx|` vs `|dy|` (P64). Vertikalni swipe **ne** cycle-a kartice (P65) — `focus_id` odredišnog benda ostaje kakav je bio (`swap_home_band(band, "")`).

| Gdje je prst | Smjer | Danas (HOME-05) | Cilj (HOME-06) |
|--------------|-------|-----------------|----------------|
| Free-hero (dolje, ~80%) | prst **dolje** (`dy > 0`) | bounce | `swap_home_band("paid")` |
| Free-hero | prst **gore** (`dy < 0`) | paid | bounce (već si na donjem svijetu) |
| Paid-hero (gore, ~80%) | prst **gore** (`dy < 0`) | bounce | `swap_home_band("free")` |
| Paid-hero | prst **dolje** (`dy > 0`) | free | bounce |
| Preview traka | vertikalni swipe | smije swap (P63) | **isti invert** kao gore: dolje → paid, gore → free; bounce ako već na tom bandu |
| Horizontalni swipe na preview | — | nije cycle (P55) | ostaje |

Tap na preview okvir **nije** invert — i dalje „tapni onu traku koju želiš kao hero“. Invert je **samo** finger-swipe.

Hub `SwipePager`: Stage i dalje `block_hub_swipe`. Vertikalni swap ne smije mijenjati Shop/Camp page.

Kod: `_on_vertical_swipe` u `season_stage.gd` — zamijeni predznak `dy`.

## L/R — zašto cut postoji

`_play_slide` pomakne cijeli HBox (`offset_left/right`), pa `cycle` + `refresh()` + `offset = 0`. Identiteti skoče. Free↔paid nema taj rez jer tweena visinu na **istim** PaidBand/FreeBand nodeovima.

## L/R — cilj (P69 override: in-place pretapanje)

Ista mehanika **izgledom/glatkoćom** kao `_tween_band_heights`, ne isti omjer širine.

1. Slotovi **ostaju**. Nema `offset` tweena na `%StripMotion` / `%PaidMotion`.
2. Pola `BAND_TWEEN_SEC`: `modulate.a` kartica 1→0 (sine out).
3. Na pola: `cycle_*_strip` + `_fill_*` novi prozor (ime, mood, lock, outline) dok su kartice na a=0.
4. Druga pola: `modulate.a` 0→1. `refresh()` na kraju je no-op.
5. Stretch centra 1.35 ostaje layout na miru — ne 80/20 širine.
6. Trajanje/easing = band-swap (`BAND_TWEEN_SEC`, `TRANS_SINE`, `EASE_OUT`).

Isto na **paid hero**. Preview **horizontalno ne cyclea**. Klik L/R i swipe L/R isti path. Bounce na rubu ostaje. `_slide_busy` tijekom pretapanja.

## Što nije L/R cilj

- Pomak cijelog 3-slot reda (GLIDE-A / stari P69-C).
- Follow-finger. Wrap. Drugi HBox.
- Animirati band visine dok mijenjaš Bloom→Frost.
- Drugi `BAND_TWEEN_SEC` samo za L/R.

## HIT-A invariant

Djeca redova: `MOUSE_FILTER_IGNORE`. Stage root `STOP`. Gesta se čita na Stageu. Ne vraćati filter na slotove da bi L/R „bolje klizio“.

## Acceptance (gesta)

- Country Bloom → Frost (klik desno ili swipe lijevo): kartice stoje, Bloom se pretapa u Frost (~250ms), bez pomaka reda i bez snap-a imena.
- Isto na paid hero (Moonlit → Coral), ako su owned.
- Preview H swipe ne mijenja paid/free fokus kartice.
- Free-hero + prst dolje → paid raste gore (isti visinski glajd kao tap).
- Paid-hero + prst gore → free raste dolje.
- Suprotan swipe = bounce, ne silent no-op.
- Headless `season_home_smoke`: cycle i dalje mijenja `strip_focus_id`; await ≥ 0.3s.
