---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, unlock, sezone, roster, scratch]
povezano:
  - ideje-home-unlock-gesta
  - ideje-home-unlock-gate
  - ideje-home-unlock-roster
  - ideje-home-unlock-pitanja
  - plan-prompts-home-unlock
  - ideje-home-focus
  - CHECKPOINT
ai_sažetak: "HOME-07 hub — swipe dolje = select; next-lock selectable + Unlock; lantern test; 48 T3 roster dolje-lijevo."
---

# IDEJE — Home unlock + flower roster (HOME-07 hub)

> **ID:** **HOME-07** · v1.1+ (nije v1 launch blocker).  
> **Kod:** **UNLOCK-A–C ✅**. Layout **overridean** [[ideje-home-incard|HOME-08]] (roster/gate u prozoru, ne Stage overlay). Chrome **overridean** [[ideje-home-cardfit|HOME-09]] (Amber off TEST_LOCK; naslov sredina; roster kontrast). Prompti: [[../06-production/plan-prompts-home-unlock|plan-prompts-home-unlock]].  
> **Prethodnik:** [[ideje-home-focus|HOME-06]] FOCUS-D ✅.  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — paid roster je kozmetički pregled, ne snaga; coin Unlock samo na **free** next-lock.

## Pitch

Tri rupe nakon HOME-06:

1. Swipe dolje više **ne** ide na paid. Igrač želi: **selektuj** sezonu u fokusu ako je playable; ako nije, zadnju koja jeste. Free↔paid ostaje **tap preview**.
2. Zaključane sezone nisu iste. **Sljedeća** free (Lantern nakon Frost) treba biti **selectable** — vidiš je u centru, progress coins+T3, sivo Unlock dok nemaš resurse. Dalje (Amber) ostaje bounce. Nakon Unlock, sljedeća nasljeđuje taj UI.
3. **Što sezona nudi:** dolje-lijevo lista 6 cvjetova (3×★1, 2×★2, 1×★3), svi **T3 izgled**, zvijezde, ime. Paid locked: swipe redom i vidi roster.

## Freeze (2026-08-20)

| # | Odluka |
|---|--------|
| **P81** | Swipe dolje = select fokus ili zadnji playable. Ne band swap. |
| **P82** | Swipe gore = bounce. Band = tap preview. |
| **P83** | Next-lock selectable; further locked nije centar. |
| **P84** | Debug skip lantern; `can_unlock_free(lantern)` da. Amber/Ember TEST_LOCK. |
| **P85–P91** | Inline gate; T3 progres; 48 stubova; T3 art+stars+ime; paid swipe+roster; tamni okvir; run `seed_type_ids` ne dirati. |

Puna tablica: [[ideje-home-unlock-pitanja|pitanja]].

## Što HOME-07 **nije**

- Inline IAP na Home (P54).
- Follow-finger, wrap, SAVE_VERSION, AdMob.
- Mijenjanje band 20/80 ili L/R in-place pretapanja.

## Agent

- **UNLOCK-A–C ✅** swipe dolje select; next-lock Unlock; 48 roster.
- **Layout overlay → HOME-08.** Kad korisnik dira „cvijeće nije u prozoru“ / premalo / Unlock na kartici → [[ideje-home-incard|HOME-08]], ne vraćati Stage overlay.
- **Amber / naslov / kontrast → HOME-09.** Kad korisnik dira Unlock nije na Amberu, ime nije na sredini, roster ista boja → [[ideje-home-cardfit|HOME-09]].
- Kad korisnik dira Unlock logiku, next locked, swipe dolje select → **HOME-07**.
- Ne vraćati swipe dolje = paid (HOME-06 P70 overridean za dolje).

## Povezano

- [[ideje-home-incard|HOME-08]] · [[ideje-home-cardfit|HOME-09]] · [[ideje-home-focus|HOME-06]] · [[ideje-home-paid|HOME-04]] · [[ideje-sezone|SEZ-01]]
- [[../06-production/CHECKPOINT|CHECKPOINT]]
