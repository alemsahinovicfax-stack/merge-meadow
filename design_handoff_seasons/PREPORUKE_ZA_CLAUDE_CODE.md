# Preporuke za implementaciju (Claude Code, Godot 4.7)

Ovo su koraci koje dizajn ne može sam uraditi. Svaki je nezavisan i ima kriterij „gotovo“. Izvor brojeva je uvijek `godot/seasons_export.json`; ništa ne hardkodirati po sezoni — nova sezona mora raditi samo dodavanjem reda u `kits`.

## 0. Priprema (obavezno prvo)
1. Kopiraj `godot/seasons_export.json` → `res://data/seasons/seasons_kit.json`.
2. Kopiraj `godot/ui_seasons.gd` → `res://scripts/visual/ui_seasons.gd`.
3. Kopiraj `assets/flowers/*.svg` (144) → `res://assets/sprites/flowers/` (18 CB se prepisuju, isti nazivi), `assets/seasons/<id>/*.svg` → `res://assets/sprites/seasons/<id>/`, `assets/pip/*.svg` → `res://assets/sprites/`. Pusti Godot da napravi `.import` (SVG scale 1, bez mipmapa).
- **Gotovo:** `UiSeasons.kit("ember_fen")` vraća rječnik; `ResourceLoader.exists` za svih 144 + 16 + 2 putanja.

## 1. SeasonBackdrop (novo) — jedan renderer recepta
- Novi `res://scripts/visual/season_backdrop.gd` (`Control`), generalizacija `arena_meadow_bg.gd`. Ulaz: `recipe: Dictionary`, `base_w := 1080`, `avoid: Array`.
- Implementiraj vrste slojeva tačno kao `buildScene()` u `design/seasons_kit.js`: band · ridge (`up`, `tilt`, `rim`) · mow · fence · row · poly (`smooth` = Catmull-Rom, 6 segmenata) · ellipse · line · shape (tačka ili lista `[x, y, size, rot]`) · scatter (R2, `noAvoid`).
- Oblici = `shapes` iz JSON-a (primitivi c, e, p, r, l, a). Geometriju računaj **jednom** u `_build_cache()` kad se promijeni sezona ili veličina; `_draw()` samo crta keš (`draw_colored_polygon`, `draw_polyline`). Bez shadera, bez gradijenata.
- **Gotovo:** polje svih 8 sezona u Godotu izgleda kao `SeasonScreen surface=field` (uporedi screenshot); profiler: 0 ms računanja po frejmu nakon prvog.

## 2. Home kartica i polje
- `home_v3_card.gd`: ukloni `_band()` trake; dijete `SeasonBackdrop` s `recipe = UiSeasons.recipe(id, "card")`, veličina = rect kartice u prelazu. 13 mjesta crtati u istom rectu (`UiSeasons.spot_rects(id, rect.size)`) — to je ključ prelaza bez šava.
- `season_field.gd`: `MeadowSky/Far/Near` → `SeasonBackdrop`. Mjesta iz `kits[id].spots` (pragovi isti).
- Tekst na livadi (ime sezone, napomena, imena cvijeća koja fale): `UiSeasons.ink_field(id)`. Pozadina stranice: `UiSeasons.page_color(id)`.
- Stanje **soon** (Ember): crteži alpha 0,5, `SoonTag` „Coming soon“ s isprekidanim rubom 4 px (nacrtati `draw_dashed_line` ili StyleBox), bez dugmeta.
- Locked: `NeedStars` ikona = ★3 prethodne sezone (`kits[id].prev_free` → `roster[5]`).
- Tačke traka iz `bands` (free / premium); aktivna sezona = breskva + 3 px rub.
- Swipe između kartica: crossfade 0,22 s (`surfaces.card.swipe`).
- **Gotovo:** prelaz kartica → polje 560 ms bez skoka pozadine u svih 8 sezona; screenshot u = 0,99 i u = 1 se razlikuju samo u chromeu.

## 3. Ambijent (zamjena za season_ambient.gd specijalne slučajeve)
- Novi `SeasonAmbient` (`Node2D`): `UiSeasons.ambient_layers(def)` jednom; u `_process` za svaku česticu `t = fposmod((time - delay) / sec, 1)` i `UiSeasons.ambient_at(L, t)` → `position`, `rotation`, `scale`, `modulate.a`. Oblik čestice = mali `SeasonBackdrop`/keširan `Polygon2D` iz `shapes`.
- Budžet: ≤ 24 čestice (već ograničeno u `ambient_layers`), 1 petlja.
- Polje: ambijent tek kad je u = 1, fade-in 0,3 s; Pip spava → `modulate.a` ambijenta na 0,35 za 1,2 s.
- Run: isti čvor s `kits[id].run.ambient`, rect 1080 × 1920.
- **Gotovo:** stari `petals` / `stars_motes` grane u `season_ambient.gd` obrisane; svih 8 sezona radi preko istog koda.

## 4. Animacije polja
- Njihanje cvijeća: `rotation_degrees = 3 · sin(TAU · t / (3 + (i % 5) · 0,5) + faza)`, pivot = baza; uključivo opcijom (Settings → Reduce motion isključuje).
- Pip njuši (`season_field_pip.gd`): tekstura `pip_sniff.svg`, cvijet tween scale 1 → 1,08 → 1 (0,3 s) + 3 čestice oblika prvog sloja ambijenta sezone (rise 80 px, 0,7 s).
- Pip spava: `pip_sleep.svg`, squash 1,04 / 0,94, 3 × „z“.
- Pip zona ostaje **Rect2(151, 1306, 614, 131)**.
- **Gotovo:** na polju ≤ 2 stalne petlje (ambijent + njihanje).

## 5. Looks pločica
- Ako već nije u `FieldScreen`: `field_wardrobe_button.gd` na (876, 1265, 180, 180). Rect je u `field_avoid` — rasuti elementi tu ne crtaju centar.

## 6. Shop
- `season_pack_card.gd` / `ui_shop_v2.gd`: obriši `season_bands`; `SeasonBackdrop` s `recipe = UiSeasons.recipe(id, "shop")` na 1024 × 356 unutar okvira; ime = `ink_field`.
- Stanja dugmeta: buy · busy (ostale kartice dim) · pending · restoring · play · failed; Ember (`soon`) bez cijene i dugmeta.
- **Cijene: pročitati iz store API-ja** (Google Play Billing `ProductDetails.formattedPrice`) — `kits[id].price` je samo placeholder iz mocka (€2.99 / €3.49 / €2.99). Bez tajmera, popusta i „limited“ (Pillar 2).
- **Gotovo:** cijena u Shopu = cijena iz storea za lokalnu valutu.

## 7. Camp link
- `season_link_card.gd`: obriši `UiCamp.season_tint`; `SeasonBackdrop(recipe "camp")` 1026 × 312 iza teksta; tekst `#3D3D33`; jedna tvrda sjena 0 8 0.
- Cvijet u okviru = `kits[id].camp_flower` (★3 prethodne besplatne sezone).
- Burst prsten: r = (0,2 + 0,8 t) · 260, rub 14, boja `rgba(255,245,209, 0,55·(1−t))`.

## 8. Arena
- `ui_arena_v2.gd`: pri učitavanju spoji `kits[id].arena` u `FIELDS[id]` (base, layers po `id`, scatter paleta po `id`, `addLayers`, `addScatter`, combo) — logika je u `design/arena_v2_data.js` (blok „Season Kit“). Nepoznate ključeve ignoriši.
- Rezovi cvijeća: `flowers[key].crop` iz JSON-a (zamijeni stari `CROP`).

## 9. Run
- `lane_background.gd`: boje `ground`, `lane`, `laneEdge`, `seam`; materijal = `run.material_tile` (pločica 192 × period, ponavljaj vertikalno, pomak = 400 px/s); daljina = `run.far.items` × 0,35; blizina = `run.near.items` × 1,0.
- `obstacle_visual.gd`: `Sprite2D` iz `obstacles[...].svg` (176 × 150, offset (42, 34) u kutiji 260 × 230), ovratnik 240 × 52 u `collar_colors`. **Kolizija 64 × 64 ostaje.** Odabir: `run.obstacles[kind % 2]`.
- **Ne popunjavati** `run_bg_path` / `obstacle_theme_id`.
- **Gotovo:** grayscale screenshot svake sezone — prepreka i pickup se razlikuju oblikom.

## 10. Brisanje (poslije 1–9)
- `SeasonTheme.bg_modulate`, `obstacle_modulate`, `home_field_tint`; `UiCamp.season_tint`; `UiShopV2.season_bands`; `SEASON_HUE` i proceduralni krug u `camp_plant_draw.gd` / `seed_visual_config.gd` za tipove koji sad imaju crtež; `HomeV3Card._band()`, `SeasonField._band_*`.
- **Gotovo:** `grep -r "bg_modulate\|season_tint\|season_bands\|SEASON_HUE"` = 0 pogodaka; igra se pokreće bez upozorenja.

## 11. Testovi (preporuka)
- GUT/unit: `UiSeasons.ridge_y`, `scatter_at`, `ambient_at` daju iste brojeve kao JS (`design/seasons_kit.js`) za 5 fiksnih ulaza po sezoni.
- Kontrast: test koji za svaku sezonu provjerava `sticker_contrast` boja iz `field` slojeva ispod rectova kontrola (lista u `surfaces.field.controls`) ≥ 6,14.
- Performanse na slabijem Androidu: polje i run 60 fps, ambijent ≤ 24 čvora.

## 12. Otvoreno za tebe (odluka, ne kod)
- Da li polje treba T2 umjesto T3 za izraslo cvijeće (sada T3, kao faza 1).
- Da li Reduce motion gasi i ambijent ili samo njihanje.
