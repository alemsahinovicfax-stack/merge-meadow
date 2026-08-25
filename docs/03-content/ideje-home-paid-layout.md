---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, layout, paid, sezone, scratch]
povezano:
  - ideje-home-paid
  - ideje-home-paid-gesta
  - ideje-home-paid-pitanja
  - ideje-home-polish-layout
  - ideje-home-polish-carousel
  - ideje-home-chrome-layout
ai_sažetak: "HOME-04 layout — SeasonStage split PaidBand top / FreeBand bottom; 20/80 uz min visine; 3-slot na obje; Pip/Play van Stagea."
---

# IDEJE — HOME-04 layout (dual-band Stage)

> [[ideje-home-paid|HOME-04 hub]]. Scena: [`game/scenes/ui/season_stage.tscn`](../../game/scenes/ui/season_stage.tscn) unutar `HomeColumn` u [`main_menu.tscn`](../../game/scenes/main_menu.tscn). Free 3-slot pravila: [[ideje-home-polish-carousel|HOME-01 carousel]]. Chrome oko Stagea: [[ideje-home-chrome-layout|HOME-03 layout]] (Pip, Play, Play Endless) **ne dirati** osim što Stage postaje viši.

## Metafora strana

Paid je **uvijek gore**. Free je **uvijek dolje**.  
Ne zamjenjuju mjesta. Zamjenjuju **visinu**.

| `home_band` | PaidBand | FreeBand |
|-------------|----------|----------|
| `free` (default) | Preview ~20% **top** | Hero ~80% **bottom** |
| `paid` | Hero ~80% **top** | Preview ~20% **bottom** |

Intuicija: „premium svijet živi gore; besplatni lanac dolje. Kliknem gore kad želim igrati paid. Kliknem dolje kad želim natrag na free.“

## 20/80 nije 20% telefona

Omjer je **unutar `SeasonStage`**, ne 20% od 1920px visine ekrana.

Literalno 20% **današnjeg** stripa (~300px) = ~60px — **nečitljivo**. Zato:

| Zona | Draft visina (1080 širok portrait) | Note |
|------|-------------------------------------|------|
| **Hero** | **~280–340px** | Isti osjećaj kao HOME-01/03 strip |
| **Preview** | **~100–140px** | Mini 3-slot, ime još čitljivo |
| **Stage ukupno** | **~400–480px** | Hero + preview + mali separator 4–8px |
| Omjer | cilj **~80 / ~20** unutar Stagea | Clamp preview na min **100px**, hero na min **260px** |

Ako safe area + chest/basket + Pip + Play + Endless ne stanu: **smanjiti Pip/spacer**, ne ubiti preview ispod 100px. Ne gurati Play u Stage.

Playtest smije ±10% na visinama. P22 horizontalni omjer (centar ~1.35× side) vrijedi na **hero** traci. Preview: isti raspored, sve **skalirano** (centar i dalje vizualno veći od side, ali apsolutno manji).

## Ciljni Home (default = free hero)

```
┌─────────────────────────────────────┐
│  wallet / settings                  │  hub chrome
│  Daily chest / Basket               │  HomeTopStack — van Stagea
│  Pip                                │  HomeColumn — van Stagea
│                                     │
│  ┌─────┐ ┌──────┐ ┌─────┐           │  PaidBand PREVIEW ~20%
│  │  —  │ │Moonlit│ │Coral│           │  statično; unowned sivo
│  └─────┘ └──★───┘ └─────┘           │  tap okvira = swap
│  - - - - - - - - - - - - - - - -    │  separator
│     [S1]   [ S2 veći ]   [🔒S3]     │  FreeBand HERO ~80%
│      L         C            R       │  swipe + P40 Browser na C
│                                     │
│              [ Play ]               │  van Stagea
│         [ Play Endless ]            │  van Stagea
└─────────────────────────────────────┘
```

Nakon tap na Moonlit okvir (paid preview):

```
│  ┌─────┐ ┌──────────┐ ┌─────┐       │  PaidBand HERO ~80%
│  │  —  │ │ Moonlit★ │ │Coral│       │  swipe paid; C = Browser
│  └─────┘ └──────────┘ └─────┘       │
│  - - - - - - - - - - - - - - - -    │
│   [S1] [ S2 mini ] [🔒S3]           │  FreeBand PREVIEW ~20%
│                                     │  statično; tap okvira = natrag
│              [ Play ]               │
```

## Node mapa (draft PAID-B)

Danas: `SeasonStage` → `%StripMotion` → `Row` → Left/Center/Right slotovi + Browser + Unlock sheet overlay.

Cilj: Stage i dalje **jedan** `block_hub_swipe` root (STOP). Unutra:

```
SeasonStage          STOP, group block_hub_swipe
├─ BandColumn        VBox, IGNORE (ili STOP samo Stage)
│  ├─ PaidBand       Control, size_flags stretch po omjeru
│  │  ├─ PaidMotion  kao StripMotion (IGNORE)
│  │  └─ PaidRow     HBox L/C/R (IGNORE djeca — HIT-A)
│  ├─ BandSep        4–8px (opc.)
│  └─ FreeBand       Control
│     ├─ StripMotion postojeći
│     └─ Row         postojeći L/C/R
├─ SeasonBrowser     overlay, STOP kad visible
└─ SeasonUnlockSheet overlay
```

`size_flags_stretch_ratio`: hero 4, preview 1 (80/20). Kod u B smije tweenati ratio u C; u B v1 **instant** set ratio na `home_band` je OK (P52 tween je C).

Ne stavljati Browser u BandColumn — ostaje top-level overlay Stagea (P32).

## Dvije 3-slot trake, isti algoritam

Free: **ne dirati** `strip_focus_id` / `strip_left_id` / `strip_center_id` / `strip_right_id` semantiku iz HOME-B. Locked next i dalje samo **desno**, sivo + katanac. Nema wrapa (P20). Nema paid ID-eva u free slotovima.

Paid: isti **prozor od tri mjesta** nad `SeasonCatalog.paid_defs()` (redoslijed P51 = array order, danas Moonlit pa Coral).

Fokus = `paid_strip_focus_id`. New game default: prvi paid def (`moonlit_warren`), čak i unowned (P45).

```
Paid indeksi:            0:Moonlit     1:Coral     (2:future…)
Fokus Moonlit:           [  —  ] [ Moonlit★ ] [ Coral ]
Fokus Coral:             [ Moonlit ] [ Coral★ ] [  —  ]
Fokus pack 1 od 4:       [  —  ] [ P1★ ] [ P2 ]
Fokus pack 2 od 4:       [ P1 ] [ P2★ ] [ P3 ]
Fokus zadnji od 4:       [ P3 ] [ P4★ ] [  —  ]
```

`—` = slot skriven (nema susjeda). Nema wrapa. Nema petog slota na Homeu (P59). Višak packova = Shop grid + Browser lista.

### Unowned smije biti centar (razlika vs free)

Free locked **nikad** nije centar (linear gate; swipe bounce).  
Paid **nije** linear. New game oba unowned. P45: sve paid vidljive; tap unowned preview **ipak** otvara paid-fokus.

Zato paid centar **smije** biti unowned: sivo + cijena ili katanac, ime čitljivo. Side unowned isto sivo. Owned = puna boja (kao free unlocked).

To **nije** „paid je jači“ — to je katalog tema. Copy na kartici: ime + lock/price, **ne** power.

## Što ostaje van Stagea

Iz [[ideje-home-chrome-layout|HOME-03]]:

1. PipPortrait  
2. (nema HomeTitle)  
3. TutorialHint dok treba  
4. **SeasonStage** (sada viši)  
5. PlayButton  
6. PlayThemeBadge (P21/P43/P50)  
7. EndlessPlayButton  

Chest/basket u `HomeTopStack` iznad kolone. Wallet/settings hub overlay.

Ne stavljati Play u 20% preview. Ne stavljati paid kartice pored Play.

## Badge (P21 usklađen s dual-band)

Mismatch = igrač vidi hero-centar koji **nije** tema koju Play vozi.

| Hero band | Hero centar | `active_season_id` | Badge |
|-----------|-------------|--------------------|-------|
| free | Country Bloom owned | Country Bloom | sakriven |
| free | Country Bloom | Moonlit (owned) | `Theme: Moonlit Warren` |
| paid | Moonlit owned | Moonlit | sakriven |
| paid | Moonlit **unowned** | Country Bloom (zadnji playable) | `Theme: Country Bloom` ili generic — vidi P50 |
| paid | Coral owned | Moonlit | `Theme: Moonlit Warren` |

Play **uvijek** čita `active_season_id`. Endless isto (P39).

P50 default: kad paid-centar unowned, **ne** prepisuj `active`; Play ostaje na zadnjem playable.

## Save (P49 default)

Uz postojeći `strip_focus_id` (free):

| Polje | Tip | New game |
|-------|-----|----------|
| `home_band` | `"free"` / `"paid"` | `"free"` |
| `paid_strip_focus_id` | String paid id | prvi paid def, ili `""` pa clamp na prvi |

Normalize:

- `home_band` invalid → `free`
- `paid_strip_focus_id` mora biti postojeći paid id; inače prvi u katalogu
- Free strip pravila HOME-B ostaju (clamp na unlocked free)

Nakon runa / povratka na Home: **zadnji band** (persist). „Default prva free“ = new game + nikad nije swapao, **ne** reset na svaki `show` Home pagea.

Grant paid (P12): **ne** forsirati `home_band = paid` dok je igrač u Shopu (P48). Fokus paid id smije se postaviti na kupljeni id da preview/hero pokaže tu karticu kad dođe na Home — opcionalno; default **da** `paid_strip_focus_id = granted id`, `home_band` **ne dirati**.

Unlock free S2: `strip_focus_id = S2` kao danas; `home_band` ne dirati.

## Thumbnail / art

PAID-B smije ColorRect + ime (kao HOME-B). Nema obaveznog final arta. Preview i hero dijele isti mood color iz SeasonDef kad thumbnail_path prazan.

## Vertikalni zrak vs hub swipe

Stage raste → manje praznog BG-a između Pip i Play. Hub page swipe i dalje živi **izvan** Stage recta (Play, chest, rubovi). Obje trake unutar Stagea = `block_hub_swipe` (root dovoljan ako Stage STOP pokriva cijeli BandColumn).

Ne stavljati `block_hub_swipe` na cijeli Home page.

## Što PAID-B ne radi

- Swap tween visine (C / P52) — B smije instant ratio.
- Promjena tap mape osim što oba banda moraju biti **vidljiva** i hit-testabilna; C dorađuje preview-vs-hero semantiku. B minimum: default free-hero layout + paid kartice gore.
- Shop grid (A).
- Follow-finger.

Ako B isporuči layout bez radnog tap-swap, C to pali. Prefer u B: **instant swap već radi** na tap preview frame (lakše playtestati omjer), C doda tween + swipe izolaciju. Implementator: vidi prompt B — layout + vidljive trake + **smije** instant swap da se 20/80 vidi oba stanja.

## Smoke (PAID-B)

[`season_home_smoke.gd`](../../game/scripts/dev/season_home_smoke.gd):

- New game: free centar S1; PaidBand visible; Moonlit i Coral postoje; `home_band == free`.
- Paid grant: free centar **i dalje** S1 (P16 free traka); Moonlit owned vizual; `home_band` ostaje free osim ako test eksplicitno swap-a.
- Stage visina > stare single-strip (grubi check: PaidBand + FreeBand oba `visible` i visina > 0).

## Fair F2P

Preview paid na new game **nije** paywall. S1 je hero. Play radi bez IAP. Sivi packovi su „postoji još svjetova“, kao locked S2 desno.

## Povezano

- [[ideje-home-paid-gesta|gesta]] — tko prima swipe/tap
- [[ideje-home-polish-carousel|carousel]] — P16 povijest; free pravila ostaju
- [[ideje-home-paid-pitanja|P45 P49 P50 P51 P52 P59]]
