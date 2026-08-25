---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, gesta, sezone, scratch]
povezano:
  - ideje-home-glide-pitanja
  - plan-prompts-home-glide
  - ideje-home-focus
  - ideje-home-paid
  - ideje-home-chrome-gesta
  - ideje-sezone
  - ideje-kad-predloziti
  - CHECKPOINT
ai_sažetak: "HOME-05 hub — full-slot L/R glajd; vertikalni swipe = band swap; Play-active outline; +1 free +2 paid (P0–C ✅). Korekcija: HOME-06."
---

# IDEJE — Home glide + katalog (HOME-05 hub)

> **Korekcija:** L/R cut, invert swipe, Browser fokus, outline, test-lock, badge → [[ideje-home-focus|HOME-06]]. Ne raditi „duži offset“ kao fix.
>
> **ID:** **HOME-05** · v1.1+ (nije v1 launch blocker).  
> **Kod:** **GLIDE-A–C ✅** (2026-08-20). Prompti: [[../06-production/plan-prompts-home-glide|plan-prompts-home-glide]].  
> **Prethodnik:** [[ideje-home-paid|HOME-04]] P0–C ✅.  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — nove paid sezone = kozmetika, ne snaga.

## Pitch

Band swap free↔paid (visina 20↔80, ~250ms) je jasan glajd. L/R cycle (Country Bloom → Frost) danas je kratki nudge (`width * 0.55`) pa cut. Igrač želi **isti osjećaj** lijevo-desno, na **obje** trake.

Uz to: cijeli Stage smije **vertikalni** swipe da radi isto što i tap-swap sekcije; **klik ostaje**. Play-sezona treba **outline**. Katalog: +1 free (S4), +2 paid (Shop 2×2).

## Freeze (2026-08-20)

| # | Odluka |
|---|--------|
| **P60** | L/R = committed glajd ~cijeli slot + 8px sep, ~250ms ease-out. **Nema** follow-finger. |
| **P61** | Outline = `active_season_id` (Play tema). Ako kartica nije u 3-slotu → samo `Theme:` badge. |
| **P62** | Vertikalni swipe = `swap_home_band` (visine). Tap okvira ostaje. |
| **P63** | Preview **horizontalno** statičan (P55). Vertikalno smije na hero **i** preview. |
| **P64** | Axis lock: nakon 20px dominantni \|dx\| vs \|dy\|. |
| **P65** | Vertikalni swipe **ne** bira karticu — zadrži fokus odredišnog benda. Tap bira id. |
| **P66** | +1 free `amber_canopy` (220c / 12 T3); +2 paid `starfall_glade` / `ember_fen`. |
| **P67** | Stub seed poolovi (kao S2/S3). Nema unique S2 ID-eva. |
| **P68** | 3-slot prozor ostaje (P59). Nema wrapa. |

Puna tablica: [[ideje-home-glide-pitanja|pitanja]].

## L/R (GLIDE-A)

Putovanje ≈ `center.size.x + 8`. Trajanje = `BAND_TWEEN_SEC` (0.25). Paid hero: `%PaidMotion`. Bounce na rubu. Preview H: nema cycle.

## Vertikalno (GLIDE-B)

Paid uvijek gore. Prst **gore** na free-hero → paid-hero. Prst **dolje** na paid-hero → free-hero. Suprotno / već na tom bandu → bounce. Hub page ne skače.

## Outline + katalog (GLIDE-C)

Gold/cream border 3px na slotu čiji je id playable `active`. Nove sezone u JSON + `MonetizationConfig`. Shop wrapa 3. i 4. pack.

## Što HOME-05 **nije**

Follow-finger, wrap, inline IAP, Shop deep-link, unique seed pools, AdMob, tutorial.

## Agent

- **GLIDE-C ✅** (track zatvoren). Nema GLIDE-D (follow-finger, wrap).
- Kad korisnik dira Home swipe / outline / nove sezone **nakon korekcije**, predloži **HOME-06** ([[ideje-home-focus]]). HOME-05 je zatvoren.

## Povezano

- [[ideje-home-paid|HOME-04]] · [[ideje-home-chrome|HOME-03]] · [[ideje-sezone|SEZ-01]]
- [[../06-production/CHECKPOINT|CHECKPOINT]]
