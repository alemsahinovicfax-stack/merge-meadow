# Home — Season Select, pass 2 (Godot 4 handoff)

Direction **1a Season Stage** (recommended). 1b Season Board is only in `design/` for reference.
Artboard 1080 × 1920; header 143 / content 1597 / footer 180 are unchanged hub chrome.
Economy, season order and IAP prices are unchanged.

## Contents
- `godot/styles/*.tres`: StyleBoxFlat resources (flat fill, radius, border, at most one hard shadow). Season-tinted boxes ship with the Frost Orchard mood; at runtime `duplicate()` them and set `bg_color` via `SeasonColors`.
- `godot/season_colors.gd`: all derived colours (locked, soon, art slot, far token, ink). Nothing is hardcoded per season.
- `godot/season_stage_tree.txt`: node tree, sizes and which style goes on each node.
- `assets/icons`, `assets/flowers`: SVGs (import with scale for 1080 px).
- `design/`: the source designs (open `Home Season Select v2.dc.html` in a browser, with `support.js` next to it).

## Behaviour
- **Play** always starts a run in the **active** season. The label is "run in {active}", even while previewing another season.
- **Tap card / Open meadow** opens the SeasonField for the focused, unlocked season. The focused season becomes active.
- **Focus ≠ active.** Previewing never changes the active season. Only one season is active at a time.
- **Focusable:** unlocked free seasons, the *next* free lock, and all 4 premium packs. Far locks can't take focus: a tap shakes the token (180 ms) and shows toast_blocked "Unlock {prev} first". The pager skips far locks.
- **Unlock (next lock):** 500 coins + 20 ★3 of the previous season's top flower.
  - GATHER: unlock_button_disabled with the text "Needs X coins + Y flowers".
  - READY: numbers in #FFD56B, unlock_button_ready.
  - UNLOCKING, 420 ms: a 520 px ring scales from 0.2 to 1 at 55% alpha, the lock turns into a coin, the bars drain in 200 ms, and the fill tweens from locked to mood.
  - AFTER: the season becomes active, and toast_success "{name} unlocked · now playing" shows for 2.4 s.
- **Camp unlock:** open Home with that season focused *and* active, and show toast "Unlocked in Camp · now playing". Don't play the unlock animation again.
- **Premium:** the preview shows all 6 flowers. PriceTag = the store string. Buy → PURCHASING (Buy is disabled, Play still works) → bought: the season is active and gets a ✓ token. Ember Fen = SOON, with no price.
- **Daily gift** stays in the Play row.

## Gestures
- A horizontal swipe **on SeasonCard** pages seasons: 1080 px slide, 280 ms cubic out. At either end it rubber-bands 40 px and never passes through to the hub.
- A horizontal swipe **anywhere else** (header, SeasonBrowser, PlayRow, footer) goes to the hub pager.
- Taps on a SeasonToken jump straight to that season.

## Type & touch
Nunito. Name 80/900 · buttons 46/900 · body 38/700–800 · numbers 44–56/900 (tabular).
Nothing is below 38 px. Touch targets are ≥ 120 px (pager 96 visual / 132 hit).

## Palette
- country_bloom: #A8E6CF
- frost_orchard: #C5D5E8
- lantern_meadow: #C9B8E0
- amber_canopy: #E8C48A
- moonlit_warren: #3D3A6B
- coral_tide_garden: #E8A090
- starfall_glade: #6B5B95
- ember_fen: #C45C26
- chrome #1A241E · active rim #FFF6D6 · warm white #FFF8F0 · ink #2D3436
- Play #FFB88C · Unlock #E8C44A · coin #FFD56B · price bg #FFE8B8 · premium #D4A5FF

## Layer names
HomePage, SeasonStage, SeasonCard, ActiveBadge, SeasonRoster, UnlockPoster, CoinProgress, FlowerProgress, UnlockButton, PremiumCard (= SeasonCard in PREMIUM state), PriceTag, SeasonBrowser, ProgressIndicator, PlayButton, DailyGiftCard, HubSwipeZone (debug only).

## Open
- Final pack prices ($4.99 is a placeholder).
- Whether Ember Fen stays visible or is hidden until it ships.
- Flower art: most roster flowers are still circle placeholders.
