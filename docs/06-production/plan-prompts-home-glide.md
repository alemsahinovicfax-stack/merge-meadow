---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, home, gesta, sezone, plan, prompt]
povezano:
  - ideje-home-glide
  - ideje-home-glide-pitanja
  - ideje-home-paid
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi HOME-05 — GLIDE-P0 → A L/R → B vertikalni swap → C outline+katalog (sve ✅)."
---

# Plan promptovi — HOME-05 Glide + katalog

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri → Agent.  
> **Redoslijed:** **GLIDE-P0 → A → B → C**  
> **Ideje:** [[../03-content/ideje-home-glide|hub]] · [[../03-content/ideje-home-glide-pitanja|pitanja]]

**GLIDE-P0** urađen 2026-08-20 (docs). **GLIDE-A–C** urađeni 2026-08-20 (glide + vertikalni swap + katalog).

## Freeze

| # | Odluka |
|---|--------|
| P1–P59 | Ostaju (HOME-01…04, HIT-A, dual-band, P55 H preview, …) |
| **P60** | L/R full-slot ~250ms; nema follow-finger |
| **P61** | Outline = Play active |
| **P62** | Vertikalni swipe = band swap; tap ostaje |
| **P63** | Preview H statičan; V smije |
| **P64** | Axis lock 20px |
| **P65** | V swipe ne mijenja fokus kartice |
| **P66–P68** | +1 free +2 paid; stub pool; 3-slot |

Ne dirati: unique S2 seed ID-evi, Play Console, AdMob, wrap, hub pager stranice, Shop Select (A already).

---

## Prompt — GLIDE-P0 (Docs) — urađeno

```
MODE: Plan only — ne implementiraj.

Projekt: Merge Meadow, HOME-05 glide + katalog — docs freeze.

Dokumentiraj: full-slot L/R glajd; vertikalni swipe = swap_home_band; Play outline; amber_canopy + starfall_glade + ember_fen; P60–P68.

Relevantno: ideje-home-glide*.md, season_stage.gd, plan-prompts-home-glide.md.

Nema game/ u P0.
```

---

## Prompt — GLIDE-A (L/R full-slot glide) — urađeno

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-05 L/R glide.

GLIDE-A:
U season_stage.gd _play_slide i _play_paid_slide: putovanje ≈ center.width + 8px (ne 0.55×). Trajanje BAND_TWEEN_SEC 0.25 ease-out. Isto na free i paid hero. Bounce na rubu ostaje. Preview horizontalno i dalje ne cyclea.

Relevantno: season_stage.gd, P60.

U planu:
- Zamjena width*0.55; koristiti BAND_TWEEN_SEC
- season_home_smoke: cycle i dalje radi; await ~0.3s
- Headless OpenGL; godot-run.ps1 jednom
- Ne vertikalni swipe (B), ne katalog (C)

Acceptance: Country Bloom → Frost odklize ~cijeli slot na free hero; paid hero isto na PaidMotion.
```

---

## Prompt — GLIDE-B (Vertikalni swipe) — urađeno

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-05 vertikalni band swipe.

GLIDE-B:
Axis lock nakon 20px (|dx| vs |dy|). Vertikalni swipe zove swap_home_band s praznim focus_id (zadrži fokus benda). Free-hero + dy<0 → paid; paid-hero + dy>0 → free. Suprotno = bounce. Preview H i dalje nije cycle; V na preview smije swap. Tap mapa PAID-C ostaje. Hub page ne skače. Input lock tijekom tweena.

Relevantno: season_stage.gd, P62–P65.

U planu:
- _update_press dominantna os
- Smoke: swap_home_band i dalje; hub MAIN; preview H ne cyclea
- Headless OpenGL; godot-run.ps1 jednom
- Ne katalog/outline (C)

Acceptance: swipe gore na free-hero prebacuje paid 80%; swipe dolje vraća; tap okvira i dalje radi.
```

---

## Prompt — GLIDE-C (Outline + katalog) — urađeno

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, HOME-05 outline + nove sezone.

GLIDE-C:
Outline 3px gold/cream na slotu active_season_id ako je playable. seasons.json: amber_canopy free order 4, 220 coins, 12 T3, stub seeds. Paid starfall_glade + ember_fen SKU u MonetizationConfig (€2.99 / €3.49). Mood boje. Shop 4 kartice, 2-col wrap. season_theme tint. Smoke: 4 paid u gridu; 4 free defs; 4 paid defs.

Relevantno: seasons.json, monetization_config.gd, season_stage.gd, season_theme.gd, shop_open_smoke, P61 P66–P68.

U planu:
- JSON + SKU + _mood_color + theme
- shop_open_smoke child_count 4
- Headless OpenGL; godot-run.ps1 jednom
- Ne follow-finger

Acceptance: S4 locked desno od Lantern kad je S3 centar; Shop 2×2 packova; Play tema ima outline.
```

---

## Redoslijed i DoD

1. GLIDE-P0 docs — ✅ 2026-08-20  
2. A L/R full-slot — ✅ 2026-08-20  
3. B vertikalni swipe — ✅ 2026-08-20  
4. C outline + katalog — ✅ 2026-08-20  

Nema GLIDE-D (follow-finger, wrap).

## Povezano

- [[../03-content/ideje-home-glide|HOME-05 hub]]
- [[plan-prompts-home-paid|HOME-04]]
- [[CHECKPOINT|CHECKPOINT]]
