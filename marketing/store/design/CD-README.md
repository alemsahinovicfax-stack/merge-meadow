# Merge Meadow · Play Store asset package

## Hook: "Run. Merge. Bloom."
I picked candidate A from brief §2, and use D ("No energy. No timers.") as the closing line on screenshot 8 and on the promo banner.

Why A:
- Three verbs cover the whole loop (run → merge → grow) in about 3 seconds, and screenshots 1–3 show each one in order.
- It's 18 characters, so it still reads on a 150 px thumbnail and on the feature graphic at 360×176.
- It tells people what they'll be doing. "Cozy" (C) is a mood. D is a strong trust signal, but it's a defensive claim, so it works better as proof at the end than as the opening line.

Proposed short description (73/80 chars): "Run for seeds, merge them into crystal flowers, and grow your cozy meadow."

## Files
| File | Size | Notes |
|---|---|---|
| feature_graphic_light_1024x500.png | 1024×500 | Country Bloom, day |
| feature_graphic_dark_1024x500.png | 1024×500 | Starfall night |
| screenshots/01–08_*.png | 1080×1920 | 24-bit RGB PNG, no alpha |
| icon_512.png | 512×512 | NEW in Round 2 (hero Pip + crystal peony, peach→gold) |
| icon_adaptive_fg_432.png / _bg_432.png / icon_mono_432.png | 432×432 | Android adaptive + themed (mono) layers |
| hero_pip/ | 2113×2160 | Round 3 hero Pip: transparent PNG + SVG (crystal peony / nova bloom), plus _disc variants with a soft halo; builder build_hero_pip_v3.js |
| promo_1200x630.png | 1200×630 | testers / GitHub / privacy page |
| store_preview.html | — | all assets + simulated store listing (light/dark). Open in a browser. |
| review/icon_review.png | — | icon at 48–144 px, square/circle mask, light/dark |
| source/Store Assets v3.dc.html | — | editable source for every asset (open in a browser; edit the text inline) |

All exported PNGs are color type 2 (RGB) with no alpha channel, so Play will accept the feature graphic.

## Screenshots
| # | Headline | Sub-line | Captures used |
|---|---|---|---|
| 01 | Run. Merge. Bloom. | Dash through the meadow for seeds | s01_run_country_bloom (+ 1.5× zoom on the seed burst from the same frame) |
| 02 | Merge two of a kind | Seeds grow into crystal flowers | s12_arena_merge_drag (+ zoom on the dragged tile) |
| 03 | Watch your meadow grow | Every ★3 flower blooms at home | s09_field_country_bloom |
| 04 | 7 meadows to explore | Each season is its own world | s02_run_starfall_glade (front), s04_run_moonlit_warren, s03_run_frost_orchard |
| 05 | 140 levels to bloom | Chests and rewards along the path | s10_level_path_country_bloom |
| 06 | Beat your best | Endless runs in every season | s05b_endless_best_clean_amber (no zoom, soft gold highlight on "New best!") |
| 07 | Loot after every run | Coins and seeds, every time | s13_arena_combo + crop of the s06_loot_country_bloom card |
| 08 | No energy. No timers. | Earn themes and looks by playing | s16_shop_seasons + crop of the s17_shop_looks "Pip Blossom" card |

Not used: s07, s08, s14 (menu screens), s15 (half empty), s11 (s12 covers it better).
Order follows the brief. 1–3 tell the hook as a sequence. 4–5 show the amount of content. 6–7 show what keeps you playing. 8 is the fair-play promise that convinces people at the end.

## Feature graphic / promo
- Pip: brand/icon_adaptive_fg_432.png (unchanged).
- Flowers: real T3 sprites crystal_peony_t3 (light) and nova_bloom_t3 + lunar_orchid_t3 (dark).
- Light background: an untouched crop of s09 (hills, fence, flowers) under a warm-white fade so the text stays readable.
- Safe zone: the title, hook, Pip's face and the flower all sit inside the central 820×400 box. Toggle "showGuides" in the source to see it.
- Promo: same motif plus a tilted s01 capture.

## Icon: redesigned in Round 2
See "Round 2 changes" below and review/icon_review.png.

## Type & color
- Font: Nunito Variable (game/assets/fonts/nunito, OFL), weight 900 for headlines and 800 for sub-lines.
- Headline 124 px (cap height ≈ 88 px, above the 72 px minimum) · sub-line 46 px.
- Ink #2D3436 · Warm white #FFF8F0 · Mint #A8E6CF · Lavender #D4A5FF · Peach #FFB88C · Sky #B8E0F5 / #E2F2FA · Night #2A2458 / #16132E / #4B4192
- Screenshot backgrounds: 01 #E6F4D8→#BFE2A8 · 02 #DDF6EC→#A8E6CF · 03 #FFF8F0→#FDDFC6 · 04 night radial · 05 #E2F2FA→#B8E0F5 · 06 #FBE7D0→#EDBE8E · 07 #F1E6FF→#D4A5FF · 08 #FFF1E4→#FFC9A3
- Frame: 8 px ink outline, 64 px radius, one hard drop (0 18px 0 ink @22%) plus a soft shadow. The soft shadow is only on the frame, never on gameplay.

## Play rules check (brief §5)
- [x] Screenshots: 8 per device, 1080×1920 (sides 320–3840 px, aspect ratio 1.78 : 1, under 2 : 1)
- [x] Feature graphic exactly 1024×500, no alpha
- [x] Icon exactly 512×512, 32-bit PNG, under 1 MB, no added rounding or shadow
- [x] No rankings or awards, no prices in real money, "free" not used anywhere
- [x] No fake UI, no Google or Android logos
- [x] Only real game content: captures are scaled, framed, rotated, or zoomed (crops of the same frame), never redrawn or edited
- [x] No "100 levels", difficulty modes, Remove Ads, Starter Pack, or "pets"
- [x] Text under 20% of each screenshot (headline block ≈ 1000×330 px ≈ 16%)
- Note: screenshot 08 shows in-game coin prices (10,000 / 2,500 coins). These are the earnable in-game currency, not real money.

## Editing later (e.g. Ember Fen → "8 meadows")
Open source/Store Assets v3.dc.html, edit the headline text, then re-export that artboard at 1×. Each artboard has an id: fg-light, fg-dark, ss-01 … ss-08, promo, icon-review.

## Round 2 changes
**Hero Pip (hero_pip/)**
- Store-only mascot, built from the real rig parts (game/assets/pip/parts, three_q view of game/data/pip/rig.json), so his silhouette, colors and ink outline are the in-game Pip's.
- Pose: slight 3/4 turn, small hop with a ground shadow, left ear tilted, sparkle eyes, grin. He holds a ★3 crystal peony (or nova bloom) in both paws toward the viewer.
- Store-only rendering: soft volume shading, a cool rim light, warm bounce light, a glow and sparkles on the flower.
- Full body every time: ear tips, feet and tail all sit inside the canvas, with transparent edges on all 4 sides.
- Files: hero_pip_crystal_peony.png / .svg and hero_pip_nova_bloom.png / .svg (2469×2160, transparent). Re-pose or swap the flower with build_hero_pip.js + pose.json.

**Feature graphic (light + dark)**
- Rebuilt around hero Pip, full body, inside the 820×400 safe zone. The faded crop of s09 is gone.
- Light: a layered meadow (sky, sun glow, clouds, 5 hill layers, T3 flowers in the foreground).
- Dark: a Starfall night (stars, meteor, lavender glow, night hills, Starfall T3 flowers).
- Tested at 360×176: the title, the pill and Pip's face still read.

**Promo 1200×630**
- Same rebuild. Hero Pip is full body and holding the flower, with the tilted s01 phone behind him.

**Icon (icon_512 + adaptive + mono)**
- New: hero Pip's head and shoulders next to the glowing crystal peony, on a warm peach → gold radial background (#FFF4C8 → #FFD56B → #FFB88C → #F28F7A). It stands out on both white and dark Play backgrounds.
- Checked at 48 px and in square, circle and squircle masks (review/icon_review.png, old vs new).
- Adaptive fg (transparent): the face, ears and flower are inside the 66% safe circle. The bg is the same gradient. Mono is a white silhouette for Android themed icons.
- To ship it in the game: copy the 4 files to game/assets/branding/, run make_app_icons.gd, then build a new AAB.

**Screenshot fixes**
- 02: the zoom is now fully inside the canvas (744–1044 px) and uses a 1:1 native crop of the dragged tulip tile, so it's sharp.
- 06: the duplicate zoomed chip is gone. A clean gold callout ring with sparkles now marks the real "New best!" badge.
- 07: the loot card now sits over a run (s02_run_starfall_glade) instead of the Arena. Three reward chips (clover, seed sprout, tulip), cropped 1:1 from s06, fly out of the card.
- All 8: the flat gradients are replaced with season decoration: two soft hill layers, petals and sparkles (game fx sprites), and T3 crystal flowers in the bottom corners. Screenshot 04 gets night stars and a meteor, 05 gets clouds. Nothing covers the gameplay.
- 01: hero Pip peeks out from behind the right edge of the phone frame.

**Captures used (updated)**
- 07 now uses s02_run_starfall_glade + crops of the s06_loot_country_bloom card and reward chips.
- Everything else is the same as above.

**Store preview**
- store_preview.html now uses the new icon. "Developer name" is clearly marked as a placeholder.

Everything from Round 1 stays the same: the hook, the 8 headlines, the order, the short description, Nunito and the palette. The Play rules check above still passes for all Round 2 files: no alpha on the feature graphic or screenshots, exact sizes, and no gameplay altered.

## Round 3 changes
**Hero Pip v3 (hero_pip/)**
- Redrawn as a marketing illustration. He keeps the same identity: mint body, pink inner ears, cream belly, ink #2D3436 outline, rosy cheeks, head tuft.
- The glossy "dome" gradient is gone. Shading is now soft and painted: light from the top-left, a gentle shadow under the head and on the right side, and a soft floor shade on the body.
- The two sharp collar spikes are replaced by a smooth jaw line with small cheek-fluff scallops.
- Flower: both paws hug the stem at chest height, and the crystal bloom sits next to his right cheek, facing the viewer. The extra bud and the sprite's lower stem are clipped away; only the real T3 bloom is used, on a new stem.
- Pose: slight 3/4 turn, a small hop (one foot kicked back, ground shadow), a 5° happy lean toward the flower, a bent right ear, the tail visible, and tiny sparkles by the bloom.
- Files:
  - hero_pip_crystal_peony.png / hero_pip_nova_bloom.png: transparent, character + flower + its glow only, no disc.
  - *_disc.png: the same art with a soft warm halo behind it, for social posts.
  - Everything is 2113–2146 × 2160 with transparent edges on all four sides. Source: build_hero_pip_v3.js + hero_pip_v3_pose.json.

**Updated with the new hero**
- Both feature graphics, the promo and the icon use the same composition and colors as Round 2. Only Pip has changed.
- The banners use the no-disc PNGs, because the background already has its own sun or moon glow.
- Icon: hero Pip v3 head and shoulders with the hugged peony, on the same peach → gold background. Adaptive fg, bg and mono were rebuilt too. The face and bloom stay inside the 66% safe circle.

**Screenshot 01**
- The half-cut peeking Pip is gone.
- The phone moves 94 px left (it's still the same size, and the s01 capture is untouched). Full-body hero Pip now stands on the hill to the right of the phone, completely visible.

**Screenshot 06**
- Now uses the new clean capture s05b_endless_best_clean_amber: 4:26 · Pace 13 · New best!, 212 coins, 19 seeds.
- There's no zoom. A soft gold ring highlights the "New best!" chip, with one sparkle outside the phone.

Everything else is unchanged: hook, headlines, order, colors, decorations, and screenshots 02–05, 07 and 08.
