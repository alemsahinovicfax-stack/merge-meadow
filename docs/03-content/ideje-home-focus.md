---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, gesta, sezone, focus, scratch]
povezano:
  - ideje-home-focus-gesta
  - ideje-home-focus-browser
  - ideje-home-focus-chrome
  - ideje-home-focus-pitanja
  - plan-prompts-home-focus
  - ideje-home-glide
  - ideje-home-paid
  - ideje-kad-predloziti
  - CHECKPOINT
ai_sažetak: "HOME-06 hub — band-swap ostaje; L/R in-place pretapanje; invert swipe; Browser fokus; outline; test-lock; bez Theme badgea."
---

# IDEJE — Home fokus + korekcija glajda (HOME-06 hub)

> **ID:** **HOME-06** · v1.1+ (nije v1 launch blocker).  
> **Kod:** **FOCUS-A–C ✅** (2026-08-20). Prompti: [[../06-production/plan-prompts-home-focus|plan-prompts-home-focus]].  
> **Prethodnik:** [[ideje-home-glide|HOME-05]] P0–C ✅ — **krivo shvaćen L/R**; band-swap visina je ispravna referenca.  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — ne dira IAP cijene, power, energy.

## Pitch

HOME-05 je uradio tri stvari odjednom. Igrač voli **samo jednu**: visinski glajd kad se prebacuje **free ↔ paid** (tap na preview **i** vertikalni swipe). Ostalo treba korekciju, ne novi feature-set.

**Što ostaje (ne dirati visine).** Paid uvijek gore, free uvijek dolje. Hero ~80%, preview ~20%. Tween `BAND_TWEEN_SEC` (~0.25s, sine ease-out) na `size_flags_stretch_ratio` + `custom_minimum_size.y`. To je referentni osjećaj.

**Što je krivo.**

1. **L/R cycle** (Country Bloom → Frost, klik ili swipe) **nije gladak** dok pomiče cijeli 3-slot red. Igrač želi **istu preobrazbu kao band-swap**: slotovi stoje, sadržaj se pretapa ~250ms.
2. **Vertikalni swipe je naopako.** HOME-05: prst gore → paid. Treba: prst **dolje** na free-hero → paid-hero; prst **gore** na paid-hero → free.
3. **Season Browser** postavi `active_season_id` (outline se pojavi) ali **ne** prebaci `home_band` niti centrira tu sezonu na Home 3-slotu. Sezona „izgleda selektovana“, a hero i dalje pokazuje staru.
4. **Outline** 3px `E8D5A3` se ne čita na svijetlom Country Bloom.
5. **Zadnja free i zadnja paid** trebaju biti **zaključane za test** (`amber_canopy`, `ember_fen`) da se vidi lock UI.
6. Između **Play** i **Play Endless** iskače tekst (`Theme: …`). Ugasiti.

## Zašto sada

HOME-05 GLIDE-A–C je zatvoren u kodu, ali playtest kaže da L/R nije „to klizanje“, Browser ne fokusira, swipe je invertiran, outline je slab, badge smeta. Korekcija je **isti Home Stage**, ne novi ekran. Ako agent opet spoji „duži offset“ s „isti osjećaj kao band-swap“, cut ostaje.

Kod mora ostati razdvojen: **A gesta**, **B Browser+badge**, **C outline+test-lock**.

## Što HOME-05 **jest** vs što HOME-06 **overridea**

| HOME-05 (ostaje kao povijest) | HOME-06 |
|-------------------------------|---------|
| P60: L/R committed full-slot `width+8`, ~250ms | **Override P69:** **nema** HBox pomaka. In-place pretapanje `BAND_TWEEN_SEC` (kao band visine). Nema follow-finger. |
| P62: swipe gore = paid | **Override P70:** swipe **dolje** = paid |
| P61: outline = playable `active` | Ostaje (P75), ali **kontrast** (P79) |
| P65: V swipe ne bira karticu | Ostaje |
| Katalog S4 + 2 paid | Ostaje; zadnje dvije **test-lock** (P73) |
| `PlayThemeBadge` kad mismatch | **Ugašen** (P74) |

Puna tablica: [[ideje-home-focus-pitanja|pitanja]] P69–P80. P1–P68 ostaju osim overridea gore.

## Simptom vs cilj

| Danas (nakon HOME-05) | Cilj |
|-----------------------|------|
| Free↔paid visine klize ~250ms (tap + swipe) | **Zadrži.** Referenca. |
| Swipe gore na free-hero → paid | Swipe **dolje** na free-hero → paid |
| L/R: red se pomakne, pa kartice skoče | Slotovi stoje; Bloom se pretapa u Frost ~250ms |
| Browser tap: outline da, hero ne | Ta sezona = hero centar + točan band |
| Gold 3px outline na Bloom se ne vidi | Tamni + svijetli stroke, čitljiv na svijetlom i tamnom |
| Amber / Ember unlockable kroz debug | Uvijek locked dok je `TEST_LOCK_LAST_SEASONS` |
| `Theme: Moonlit Warren` između Play gumba | Praznina; samo dva Play CTA |

## Što HOME-06 **jest**

- Invert vertikalnog swipea (tap-swap ostaje).
- L/R in-place pretapanje (klik L/R i swipe L/R, free **i** paid hero) — isti easing kao band-swap.
- Browser owned/unlocked → `swap_home_band` + strip centar.
- Jaki outline na playable active.
- Test-lock zadnje free i zadnje paid sezone.
- Ugašen `PlayThemeBadge`.

Detalj: [[ideje-home-focus-gesta|gesta]] · [[ideje-home-focus-browser|browser]] · [[ideje-home-focus-chrome|chrome]].

## Što HOME-06 **nije**

- Follow-finger, wrap, novi 4. slot u sceni kao produkt (overflow samo ako A mora da nestane cut).
- Shop Select (PAID-A ostaje).
- Preview horizontalni cycle (P55/P63 ostaje).
- Unique S2 seed ID-evi, AdMob, Play Console, SAVE_VERSION bump.
- Hub pager stranice, tutorial korak, inline IAP na Home hero.
- Mijenjanje band-swap visina / min visina / 20/80 omjera.

## Agent

- **FOCUS-D ✅** L/R in-place pretapanje. Nema FOCUS-E (follow-finger, wrap).
- Kad korisnik dira Home swipe / Browser fokus / outline / lock / Theme badge, predloži **HOME-06**.
- Ne predlagati HOME-05 L/R „još duži offset“ — to je već promašaj.
- Ne implementirati OUT (IAP live, iOS, energy).

## Povezano

- [[ideje-home-unlock|HOME-07]] · [[ideje-home-incard|HOME-08]] · [[ideje-home-glide|HOME-05]] · [[ideje-home-paid|HOME-04]] · [[ideje-home-chrome|HOME-03]]
- [[../06-production/CHECKPOINT|CHECKPOINT]] · [[../06-production/plan-prompts-home-focus|prompti]]
