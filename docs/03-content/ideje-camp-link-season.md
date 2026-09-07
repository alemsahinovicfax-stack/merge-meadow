---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, kamp, ux, sezone, unlock, scratch]
povezano:
  - ideje-camp-link
  - ideje-camp-link-pitanja
  - ideje-home-lockflow
  - plan-prompts-home-camp-field
ai_sažetak: "CAMP-03 C ✅ — kamp kartica next locked free sezone (barovi + Unlock); Unlock vodi na Home poster, ne zove unlock_free."
---

# IDEJE — CAMP-03 season (next-lock kartica)

> [[ideje-camp-link|hub]] · freeze C31–C34.  
> **Kod:** **CAMP3-C ✅**. Ista visina kao Seeds/Flowers nakon +10%. Ne dirati Home UnlockGate spend. Fair F2P: kamp gumb **ne** troši coins.

## Danas

Home [`season_unlock_gate.gd`](../../game/scripts/ui/season_unlock_gate.gd) `refresh_gate`: coins bar, T3/Seeds bar, Unlock; visible kad hero == `next_locked_free_id()` i nije playable. Tap zove `unlock_free`.

Kamp nema tu informaciju.

## C — link, ne spend

1. Nova kartica u camp Content (npr. `%SeasonLinkCard`), **ista `custom_minimum_size.y`** kao GardenCard / CrystalCard nakon CAMP3-A.
2. Sadržaj kao Home gate za `GameState.next_locked_free_id()`: ime/🔒 opcionalno, **Coins n/need**, **Seeds n/need** (isti `t3_flower_count` / `coins_cost` / `t3_flowers_required`), ProgressBari, gumb **Unlock**.
3. Boje: `SeasonTheme` / `season_card_contrast` **te** sezone (ne generic camp cream ako sezona ima tint).
4. **Samo Unlock** je `MOUSE_FILTER_STOP`. Ostatak kartice IGNORE. Kartica tap bez gumba **ne** navigira.
5. Unlock **ne** zove `unlock_free`. Radi: `set_free_strip_focus(id)`, `home_band` free, `close_season_field` ako je polje otvoreno, `go_to_meta_page(MAIN)`. Igrač vidi **locked poster** (barovi + pravi Unlock), ne meadow.
6. Ako `next_locked_free_id()` prazan (sve free otključane): kartica **hidden**. Paid sezone nisu na ovoj kartici.
7. UniqueName za smoke. Ne duplicirati cijeli SeasonStage.

## Smoke (C34)

Bloom unlocked, Frost locked next: kartica visible; bar values match gate; Unlock emit/clicked → hub page MAIN, `strip_focus_id` frost (ili next lock), `home_season_field_open == false`, `wallet_coins` **ne** padaju. UnlockGate na Homeu visible. Kartica min height ≈ GardenCard. Nema next lock: kartica hidden.

## Acceptance

- U kampu vidiš isti progres kao na zaključanoj free sezoni na Homeu.
- Kamp Unlock je senzor za Home, ne za spend.
