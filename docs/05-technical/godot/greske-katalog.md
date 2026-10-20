---
type: tehnicko
status: aktivan
milestone: M6
tags: [tehnicko, godot, greske, gotchas]
povezano:
  - _index
  - scene-node-pravila
  - dev-workflow
ai_sažetak: "Živa lista naučenih Godot grešaka u projektu — simptom, uzrok, rješenje. Dodaj novi unos kad nešto pukne."
---

# Katalog grešaka (gotchas)

> **Živa lista.** Kad nešto pukne i potrošiš vrijeme na to — dodaj unos ovdje. Format: **Simptom → Uzrok → Rješenje → Prevencija.**

---

## #1 — `@onready` tip ne odgovara node-u u sceni

**Datum:** 2026-07-03 (M6 B2, prvi playtest)

**Simptom:**
- Swipe radi (kvadratić se pomiče), ALI tajmer stoji na "75s", orb brojač na 0, ništa se ne spawna ni ne kreće.

**Uzrok:**
```gdscript
@onready var loot_overlay: Control = $LootOverlay   # LootOverlay je CanvasLayer!
```
`CanvasLayer` nije `Control`. Godot baci grešku pri izvršavanju te linije u `_ready()` i **prekine ostatak `_ready()`** — `_start_run()` se nikad ne pozove, `run_active` ostane `false`, pa `_process()` odmah izlazi (`if not run_active: return`). Swipe radi jer je `player.gd` nezavisna skripta.

**Rješenje:**
```gdscript
@onready var loot_overlay: CanvasLayer = $LootOverlay   # tip = tip u sceni
```

**Prevencija:**
- [[scene-node-pravila|scene-node-pravila]] "Zlatno pravilo": tip u `@onready` = tip node-a u sceni.
- **Headless smoke-test** ([[dev-workflow|dev-workflow]]) bi ovu grešku ispisao u konzolu prije nego što se otvori editor.
- Prati Godot **Output/Debugger panel** — greška je bila tamo, samo neuhvaćena.

---

## #2 — `_draw()` na `Area2D` + Control portrait size 0

**Datum:** 2026-07-04 (F1 Pip placeholder)

**Simptom:**
- U runu se vidi samo HUD tekst "Pip" gore lijevo; zeko se ne crta na dnu ekrana.
- Main menu / HUD portrait prazan (samo layout).

**Uzrok:**
1. Custom `_draw()` na `Area2D` nije pouzdano vidljiv u play modu (collision node, ne vizualni).
2. `Control` s `custom_minimum_size` ali `size == (0,0)` prije layouta → `scale = 0` u `_draw()`.

**Rješenje:**
- Pip vizual kao **`Node2D` child** (`PipVisual` + `pip_visual.gd`) koji crta u `_draw()`.
- UI portrait: `_ensure_size()` + `NOTIFICATION_RESIZED` u `pip_placeholder_control.gd`.

**Prevencija:**
- Vizual lika = **Node2D/Sprite2D child**, ne `_draw()` na `Area2D`.
- UI custom draw: provjeri `size` prije crtanja.

---

## #3 — Viewport 0×0 u `_ready()` → Pip gore lijevo, nema laneova

**Datum:** 2026-07-04 (F2)

**Simptom:**
- Pip u gornjem lijevom kutu (0,0); nema vertikalnih traka; spawn/scroll ne radi ili je sve na jednoj točki.

**Uzrok:**
`get_viewport_rect().size` u `_ready()` ponekad još **0×0** → `lane_x_positions = [0,0,0]`, `player.position.y = 0`.

**Rješenje:**
- `await` dok viewport nije ≥ 100 px visine prije `_calculate_lanes()`.
- Lane guide: **`Line2D`** umjesto `ColorRect` pod `Node2D`.

**Prevencija:** `_wait_for_viewport()` pri svakom world setupu; ne računaj lane pozicije u prvom frameu bez provjere.

---

## #4 — `CONNECT_DEFERRED` na `Button.pressed` ne poziva handler

**Datum:** 2026-07-04 (M7)

**Simptom:**
- Hover i pressed vizual gumba rade, ali ništa se ne dogodi (ni Double tekst, ni promjena scene).

**Uzrok:**
`button.pressed.connect(_on_pressed, CONNECT_DEFERRED)` — na Godot 4.7 + touch emulacija callback se ne izvrši.

**Rješenje:** spoji `pressed` **bez** `CONNECT_DEFERRED`; scene change u handleru preko `call_deferred("_do_change_scene", path)` na istom Control nodeu.

**Prevencija:** [[scene-node-pravila|scene-node-pravila]].

---

## #5 — `emulate_touch_from_mouse` lomi UI klik na desktopu

**Datum:** 2026-07-04 (M7)

**Simptom:**
- Hover i pressed **vizual** gumba rade; `Button.pressed` / handler se **ne pozove** (miš na Windowsu).

**Uzrok:**
`project.godot` → `pointing/emulate_touch_from_mouse=true` — klik miša postane touch event; `BaseButton.pressed` često ne okine handler (Godot 4.7).

**Rješenje:**
1. `emulate_touch_from_mouse=false` u `project.godot` + `Input.emulate_touch_from_mouse = false` u `GameState._ready()` (runtime sigurnost).
2. **`UiClickButton` extends `PanelContainer`** (ne `Button`) — hvata miš + touch u `gui_input`, emituje `clicked`. BaseButton interno guta signale na desktopu.
3. `SceneRouter` autoload za promjenu scene iz UI-a.

**Prevencija:** svi gameplay UI gumbi koriste `UiClickButton`; scene change preko `SceneRouter`.

---

## #6 — Novi sprite nevidljiv (`load()` = null)

**Datum:** 2026-07-06 (C2 Pip art pass)

**Simptom:**
- Pip (ili drugi PNG/SVG) **potpuno nevidljiv** u runu i UI; nema `SCRIPT ERROR`.

**Uzrok:**
Novi fajl u `game/assets/` dodan izvan editora. Godot **nije importao** asset → `ResourceLoader.exists()` = false → `load()` vraća `null` → `Sprite2D` bez texture.

**Rješenje:**
1. `.\scripts\godot-import.ps1` (ili `godot-run.ps1` koji sada import radi automatski)
2. Commit **`pip_idle.svg.import`** uz source fajl
3. `pip_assets.gd`: provjeri `ResourceLoader.exists` + fallback na `PipDraw`

**Prevencija:**
- [[dev-workflow|dev-workflow]] — import prije playtesta
- `.cursor/rules/godot-assets-import.mdc`
- Agent: nakon novog asseta uvijek `godot-import.ps1`

---

## #7 — Android emulator: "Unable to set up Godot engine" / crni ekran

**Datum:** 2026-07-09 (D4 screenshot prep), prošireno 2026-07-10

**Simptom:**
- Klik na ikonu igre u emulatoru → **Unable to set up Godot engine** (ili crni ekran).
- Logcat: `createContext failed: EGL_SUCCESS` ili `Couldn't present to Vulkan queue (VkResult error 5)`.

**Uzrok (lanac):**

| # | Problem | Simptom |
|---|---------|---------|
| 1 | Stari test APK (`com.example.newgameproject`) | Pogrešna app / crash |
| 2 | Export bez **x86_64** ABI | APK ne radi na Pixel AVD |
| 3 | **API 30 system image** → guest `ANDROID_EMU_gles_max_version_2` (GLES 2 only) | Godot 4 `gl_compatibility` treba **GLES 3+** → `createContext failed: EGL_SUCCESS` |
| 4 | Stale export cache → manifest `rendering.method=mobile` (Vulkan) | Engine starta, ali crni ekran (Vulkan queue error) |
| 5 | **SwiftShader** na API 33 | Godot starta, ali shader uniform limit (261) — koristi **`-gpu host`** |

**Rješenje (provjereno 2026-07-10):**

1. Instaliraj **API 33+** system image (`google_apis` ili `google_apis_playstore`, x86_64):
   ```powershell
   sdkmanager "system-images;android-33;google_apis;x86_64"
   ```
2. Kreiraj AVD **Pixel_4_API33** (skripta ispod to radi automatski).
3. Pokreni emulator s **host GPU** (AMD integrisana OK na API 33):
   ```powershell
   .\scripts\start-android-emulator.ps1              # Pixel_4_API33, -gpu host
   .\scripts\android-launch-game.ps1                 # install + start + logcat
   ```
4. Export: `x86_64=true`, manifest `gl_compatibility`, `merge_meadow_debug.apk`.
5. **Ne koristi Pixel_4 (API 30)** za Godot 4 — guest je uvijek GLES 2, bez obzira na SwiftShader/host.

**Prevencija:**
- `export_presets.cfg`: `x86_64=true`, `command_line/extra_args="--rendering-driver opengl3"`.
- `project.godot`: `renderer/rendering_method.mobile="gl_compatibility"`.
- Dev emulator: **Pixel_4_API33** (ne API 30 s default GPU).
- Screenshot tek nakon svježeg exporta iz `game/`.

---

## #8 — Loot → Camp: dupli klik pokreće Play

**Datum:** 2026-07-10

**Simptom:** Fail loot → **To Camp** → kamp se otvori, ali odmah krene novi run.

**Uzrok:** `camp_controller._unhandled_input` hvata **mouse release** na Play poziciji. To Camp i Play su skoro isti Y; release nakon scene change aktivira Play.

**Rješenje:**
1. Uklonjen dupli button routing iz `camp_controller` (`UiClickButton.clicked` je dovoljan).
2. `SceneRouter` blokira UI input 400 ms nakon `change_to`.
3. `UiClickButton` ignorira input dok je block aktivan.
4. Loot zaključava gumbe pri odlasku u kamp.

**Prevencija:** ne dodavati `_unhandled_input` release-handling za gumbe s `UiClickButton`.

---

## #10 — Shop: `ScrollContainer` + `custom_minimum_size.x` sync → crash (signal 11)

**Datum:** 2026-07-29 (D0 polish)

**Simptom:** Klik **Shop** (ili headless `shop_open_smoke.gd`) — Godot **signal 11** / „Object was deleted while awaiting a callback”; cijeli proces pukne.

**Uzrok:** `shop_screen.gd` slušao `MainScroll.resized` i postavljao `MainContent.custom_minimum_size.x = scroll.width`. Na Godot 4.7 (OpenGL, headless) to pokrene layout petlju / use-after-free u ScrollContainer-u.

**Rješenje:**
1. Ukloniti `_sync_scroll_width` / `resized` handler na shop `MainScroll`.
2. Širinu sadržaja držati preko `size_flags_horizontal = EXPAND_FILL` na `MainContent` (bez runtime min-width sync-a).
3. Dinamički shop redovi: `HBoxContainer` / `VBoxContainer` (ne `PanelContainer.new()` u scrollu).

**Prevencija:** `UiClickGuard` autoload + `scripts/dev/ui_button_click_smoke.gd` prije playtesta; ne sync-ati `custom_minimum_size` iz `ScrollContainer.resized` bez potrebe.

---

## #9 — Autoload `GameState` ne učitava → Play (i sve) ne radi

**Datum:** 2026-07-12 (D0 / Mochi)

**Simptom:** Main menu **Play** ne reagira; u Godot outputu `Invalid access ... on Nil` za `GameState`.

**Uzrok:** Parse error u `game_state.gd` — `mochi_unlock_seen` korišten u save/load bez `var` deklaracije. Cijeli autoload padne; global `GameState` je `null`.

**Rješenje:** Dodati `var mochi_unlock_seen: bool = false` uz ostale companion varijable.

**Prevencija:** headless `--verbose` ili `--quit-after 3` — provjeri da se `GameState` pojavi u root children; svaka nova save polja mora imati `var`.

---

## #11 — Meta hub: `Invalid new child index` pri lazy load stranice

**Datum:** 2026-07-29 (D0-F2)

**Simptom:** Loot → Camp/Arena ili `go_to_page(3)` pri bootu — ERROR `Invalid new child index: 3` u `meta_hub_controller._load_page`.

**Uzrok:** `host.move_child(page, index)` zahtijeva da host već ima dovoljno djece; stranice su se učitavale out-of-order (npr. Arena prije Shop/Home).

**Rješenje:** `_ensure_page_slots()` — 5 placeholder `PageSlot_*` kontrola prije učitavanja; zamjena slota pravom scenom na indeksu.

**Prevencija:** `meta_hub_flow_smoke.gd` + `loot_camp_nav_smoke.gd`.

---

## Kako dodati novi unos

```markdown
## #N — kratak naslov

**Datum:** YYYY-MM-DD (milestone/checkpoint)

**Simptom:** što se vidi / ne radi.

**Uzrok:** prava tehnička greška.

**Rješenje:** konkretna promjena (kod/postavka).

**Prevencija:** koje pravilo/doc ovo sprječava ubuduće.
```

---

## #12 — Signal emit + `.bind` = dupli argument (Shop cosmetics)

**Datum:** 2026-08-16 (M8 D0, Bug-017)

**Simptom:**
- Klik na „N coins“ u Shop Cosmetics ne smanjuje wallet; dugme izgleda klikabilno.

**Uzrok:**
```gdscript
signal buy_pressed(item_id: String)
row.buy_pressed.connect(_on_cosmetic_buy.bind(item_id))
# emit(item_id) + bind(item_id) → handler dobije 2 argumenta, očekuje 1 → fail
```

**Rješenje:**
```gdscript
row.buy_pressed.connect(_on_cosmetic_buy)  # koristi emitirani ID
```

**Prevencija:**
- Kad signal već nosi ID, **ne** `.bind` isti ID.
- Headless smoke za buy path (`shop_cosmetic_buy_smoke.gd`).

## #13 — Home season kartice gutaju swipe (`mouse_filter STOP`)

**Datum:** 2026-08-19 (HOME-02 HIT-A)

**Simptom:** Swipe/tap sezona radi samo u prazninama između panela. Srednja kartica nije klikabilna; bokovi nisu swipeable.

**Uzrok:** `PanelContainer` slotovi i Labeli default/STOP. `SeasonStage.gui_input` nikad ne vidi prst na kartici.

**Rješenje:** `MOUSE_FILTER_IGNORE` na `Row` stablu (`_ignore_hits`); Stage ostaje STOP. Browser/Unlock sheet ne IGNORE.

**Prevencija:** `season_home_smoke` assert filtera; [[../../03-content/ideje-home-hit-targets-tehnika|HOME-02 tehnika]].

## #14 — SurfaceTool mesh "inside-out" (CCW winding iz glTF/three.js navike)

**Datum:** 2026-09-16 (CD capability test, `seed_bag_mesh.gd`)

**Simptom:** Proceduralni mesh izgleda prozirno/šuplje uz `CULL_BACK`, iako su normale tačne i isti model iz `.gltf`/`.obj` izgleda ispravno.

**Uzrok:** Godot koristi **clockwise** front face. glTF, OBJ i three.js koriste counter-clockwise, a Godotovi importeri pri uvozu okreću redoslijed. SurfaceTool/ArrayMesh ne okreću ništa.

**Rješenje:** u builderu dodaj vrhove redom `a, c, b` (normala i dalje `(b−a)×(c−a)` prema van).

**Prevencija:** headless provjera: za svaki trokut `(b−a)×(c−a)` mora biti **suprotan** spremljenoj normali, kao kod uvezenog glTF-a (`_cd_sandbox/_cc_verify/cd_verify_smoke.gd`).

## #15 — Android export ne prihvata scenu s komandne linije

**Datum:** 2026-09-16 (benchmark na emulatoru)

**Simptom:** `adb shell am start ... --esa command_line_params res://.../scena.tscn` → logcat: `ERROR: Scene path was specified on the command line, but this Godot binary was compiled without support for path overrides. Aborting.`

**Uzrok:** export templates su kompajlirani s `disable_path_overrides`. `GodotAppLauncher` alias uz to odbacuje extras, a `GodotApp` nije exported (treba `adb root`).

**Rješenje:** za jednokratni APK privremeno promijeni `application/run/main_scene` u `project.godot`, uradi `--export-debug` u scratch putanju, pa vrati backup i provjeri hash.

**Prevencija:** ne gubi vrijeme na intent extras za izbor scene. Benchmark scena se mora sama ugasiti (`get_tree().quit()`) i ispisati rezultat u konzolu (logcat).

## #16 — `queue_free` + novi child u `configure()` = beskonačna petlja resize-a i crash

**Datum:** 2026-09-21 (Home redizajn, `HomePremiumHeader`)

**Simptom:** meta hub pada već u prvom frejmu: stotine redova `Object was deleted while awaiting a callback.`, pa `CrashHandlerException: signal 11`. Sama Home scena, učitana bez huba, radi.

**Uzrok:** `configure()` je brisao tačkice s `queue_free()` i odmah dodavao nove. Stare žive do kraja frejma, pa je red svakim pozivom bio širi za 264 px. ScrollContainer s `horizontal_scroll_mode = DISABLED` preuzima širinu sadržaja → `resized` → `_refresh_trail()` → `configure()` → još širi red … zauvijek u istom frejmu.

**Rješenje:** djeca se ponovo koriste (sakrij višak, dodaj samo ako fali), a `_on_trail_resized` osvježava samo kad se promijeni visina (širina ne mijenja raspored).

**Prevencija:** u kodu koji se zove iz `resized` nikad `queue_free` + `add_child` istog sadržaja; ako baš mora, `remove_child` prije `queue_free`. Pri sumnji: privremeni brojač poziva s `Engine.get_process_frames()` odmah pokaže petlju u jednom frejmu.

## #17 — Home se izlijeva van ekrana (min. širina djeteta razvuče VBox)

**Datum:** 2026-09-23 (HOME-20, Season Stage v2)

**Simptom:** cijela Home kolona 1286 px umjesto 1032 — kartica, dock i Play red izlaze 103 px lijevo i desno.

**Uzrok:** stari "Daily gift" sadržaj (ikona + dva teksta u redu) imao je minimalnu širinu 438 px; `PlayRow` (836 + 12 + 438) je prisilio `HomeColumn` na svoju min. širinu, a kontejneri je ne smanjuju ispod nje.

**Rješenje:** Gift je sada custom `Control` od tačno 180 × 180 (crta sadržaj u `_draw()`), stage je apsolutni raspored iz `SeasonStage.dc.html`.

**Prevencija:** `season_home_smoke` provjerava tačne rectove i da nijedna vidljiva kontrola Home stranice ne izlazi iz 1080 × 1597.

## #18 — Nunito variable: `variation_opentype = {"wght": 900}` ne radi

**Datum:** 2026-09-23 (HOME-20)

**Simptom:** sve težine iste širine kao default (200); tekst tanak.

**Uzrok:** `FontVariation.variation_opentype` ne prepoznaje string ključ `"wght"`.

**Rješenje:** int tag `0x77676874` (ili ime ose `"weight"`) — `UiStage.AXIS_WEIGHT`.

**Prevencija:** kod novog variable fonta izmjeri `get_string_size` za 400 i 900; moraju se razlikovati.

## #19 — `move_child(a, b.get_index())` stavi `a` IZA `b` kad ide naprijed

**Datum:** 2026-09-23 (HOME-19 polje sezone)

**Simptom:** u polju sezone redoslijed livada → Play → nadogradnje → korpa umjesto livada → korpa → nadogradnje → Play.

**Uzrok:** `move_child` prvo ukloni dijete pa ga ubaci na indeks; kad se pomjera unaprijed, indeks cilja je već pomaknut za 1.

**Rješenje:** red djece je u `.tscn`; runtime pomjeranje uklonjeno.

**Prevencija:** raspored drži u sceni; ako baš treba `move_child` unaprijed, cilj je `b.get_index() - 1`.

## #20 — skok na sekciju u `ScrollContainer`: pozicija djeteta već sadrži skrol

**Datum:** 2026-09-24 (Shop chipovi Looks · Seasons · Boosters · Support)

**Simptom:** prvi tap na chip odskroluje tačno, svaki sljedeći stane prekratko (Support je pokazivao kraj sezona).

**Uzrok:** `ScrollContainer` skroluje tako što pomjera svoje dijete, pa `pad.position.y` postaje `-scroll`. Cilj je računat kao `sekcija.position.y + pad.position.y`, što je oduzimalo već preskrolanu visinu.

**Rješenje:** cilj se računa samo iz sadržaja (`sekcija.position.y + content.position.y`), bez pozicije skrolovanog kontejnera — isto i za scroll-spy.

**Prevencija:** za `scroll_vertical` koristi koordinate unutar sadržaja; ako baš treba globalno, oduzmi `scroll.global_position.y` i dodaj trenutni `scroll_vertical`.

## #21 — smoke test javi „OK", a skripta se nije ni kompajlirala

**Datum:** 2026-09-28 (Home v3 prenos)

**Simptom:** `godot --headless -s scripts/dev/X_smoke.gd` ispiše „X_smoke OK" i izađe s 0, a iznad stoji `SCRIPT ERROR: Compile Error` (npr. `Identifier not found: GameState` ili `Could not find type "HomeV3Glyph"`).

**Uzrok:** dva odvojena slučaja.
1. `-s` skripta (`extends SceneTree`) kompajlira se **prije** autoloada. Ako statički koristi klasu (`UiHomeV3.X`, `as HomeV3Card`) koja preko lanca ovisnosti koristi autoload identifikator (`PipDraw` → `GameState`), kompajliranje padne.
2. Nova `class_name` klasa napravljena izvan editora nije u global class cacheu dok Godot ne odradi import, pa je druge skripte ne vide.

**Rješenje:** u testu učitaj takvu klasu tek u `_run()` (`var V: GDScript = load("res://…/ui_home_v3.gd")`, pa `V.KONSTANTA`), bez statičkih tipova. Poslije nove `class_name` klase pokreni `--headless --import` (ili `godot-import.ps1`).

**Prevencija:** u izlazu testa uvijek traži i `SCRIPT ERROR`, ne samo „OK" (`grep -c "SCRIPT ERROR"` mora biti 0).

**Dopuna 2026-10-14 (zvuk):** isto važi za `class_name` klase koje test koristi direktno (`UiPip`, `UiPopups`, kartice…) — kad one statički pozovu autoload (`AudioManager.play`), `-s` test pada. Zato zvuk ide kroz `Sfx` (`scripts/visual/sfx.gd`): statičke funkcije koje autoload traže u toku igre (`root.get_node_or_null("AudioManager")`), a bez njega su tihe. Isti obrazac za svaki budući servis koji zovu i UI klase.

## #22 — tekstura iz `load()` u `_draw()` se crta kao bijeli pravougaonik

**Datum:** 2026-10-05 (Sezone faza 1, prepreke u runu)

**Simptom:** nova SVG prepreka u runu je bijeli pravougaonik tačno svoje veličine (176 × 150). Headless provjera piksela teksture je ispravna, a ista tekstura na `Sprite2D` se vidi normalno.

**Uzrok:** `draw_texture_rect(load(path), …)` u `_draw()` upisuje u canvas samo RID teksture, ne i referencu na `Texture2D`. Kad `_draw()` završi, niko ne drži resurs, pa se oslobodi i renderer crta nevažeći RID (bijelo). Ako isti resurs drži neko drugi (npr. `Sprite2D`), greška se ne vidi.

**Rješenje:** teksturu koju crtaš drži u varijabli ili statičkom kešu (`static var _tex_cache` u `obstacle_visual.gd`, `FlowerAssets._cache`, `PipAssets._skin_cache`).

**Prevencija:** nikad `load()` direktno u argumentu `draw_*` poziva; tekstura mora imati vlasnika koji živi dok se crtež vidi.

## #23 — oslobođen objekat je `== null`: „isti cilj" grana proguta sakrivanje

**Datum:** 2026-10-05 (Merge Hint u Areni)

**Simptom:** zagrade Merge Hinta ostanu na polju poslije spajanja para i kad sesija Arene završi.

**Uzrok:** `set_target(null)` je prvo provjeravao `if target == _target: follow(); return`. Kad se označena sjemenka spoji, `_target` je oslobođen objekat, a u Godotu 4.7 je `oslobođen == null` **true** (headless provjera: `freed == null` true, `freed != null` false, `is_instance_valid(freed)` false). Zato je `null == _target` prošlo kao „isti cilj" i oznaka se nikad nije sakrila. Uz to `set_arena_page_active(false)` gasi `_process`, pa se oznaka ne bi ni osvježila.

**Rješenje:** poredi s `get_target()` (vraća `null` za nevažeći), stanje „prikazano" drži u svom flagu (`_shown`), ne u `visible` dok traje izlaz, a na kraju sesije i pri gašenju stranice zovi `clear_now()`.

**Prevencija:** za čuvanu referencu na čvor koji može nestati nikad ne poredi `== null` / `==` direktno; prvo `is_instance_valid()`.

**Dopuna 2026-10-14 (muncher, „sjemenka pobjegla"):** ista zamka. `if _target_chip != null and not is_instance_valid(_target_chip)` nikad nije uhvatio spojenu metu, jer je oslobođena meta već `== null`. Rješenje: flag `_target_held` (meta je postojala u prošlom ticku) + `is_instance_valid` / `is_queued_for_deletion()`; test `muncher_rig_smoke.gd`.

## #24 — GL Compatibility na laptopu ne reže crtanje (ni `clip_contents`)

**Datum:** 2026-10-05 (kartica izbora sezone i Shop kartica)

**Simptom:** recept Season Kita ide do −2 / 102 / 101 % recta, pa pozadina kartice izbora i Shop kartice viri izvan okvira kartice (najviše u swipeu između kartica).

**Uzrok:** proba sa `--rendering-driver opengl3` na AMD iGPU (i u SubViewportu i u glavnom prozoru): crvena površina veća od svog Controla ostala je neodrezana i sa `clip_contents = true` na roditelju, i sa `RenderingServer.canvas_item_set_clip` + `canvas_item_set_custom_rect` na zasebnom canvas itemu. Scissor se ovdje ne primjenjuje, pa se rezanje ne može prepustiti rendereru.

**Rješenje:** rezati geometriju. `SeasonBackdrop` reže slojeve u % na [0, 100] jednom pri gradnji (`Geometry2D.intersect_polygons` / `intersect_polyline_with_polygon`), a oblik koji viri preko recta pri crtanju trokut po trokut. Uglovi kartice i dalje idu maskom u boji stranice.

**Prevencija:** crtež koji mora ostati u okviru na ovom rendereru ne smije izaći iz svog recta; ne oslanjaj se na `clip_contents` / `clip_children` za ukrasne mreže.


**Dopuna 2026-10-12 (Album):** lista u `ScrollContainer` iza okvira je izlazila ispod donje ivice zlatnog okvira. Obrazac koji radi: lista je pravougaona „rupa", oko nje četiri neprozirna `ColorRect` poklopca (z iznad liste), pa obrub prozora (`draw_center = false`, z iznad poklopaca) — `UiJournal.list_window()`, test `album_window_smoke.gd`. Isti princip ima Settings: neproziran TopBar iznad liste.
## #25 — smoke testovi pregaze pravi save

**Datum:** 2026-10-05 (Sezone faza 1)

**Simptom:** poslije punog headless prolaza kroz `scripts/dev/*_smoke.gd` pravi save (`%APPDATA%/Godot/app_userdata/Merge Meadow/player_save.json`) ima druge `active_season_id`, `owned_paid_seasons`, `magnet_level`, `wallet_coins`, `home_band`, `wardrobe_seen` i `lifetime_seeds_collected`.

**Uzrok:** `--script` test i igra dijele isti `user://`. GameState snima skoro na svaku promjenu (`save_player_save()`), a 24 smoke testa i `balance_snapshot.gd` mijenjali su stanje ili brisali `player_save.json` bez backupa.

**Rješenje:** test u `_initialize()` uzme `CampSmokeUtil.backup_save()` (to je prije nego GameState boota), a svaki izlaz ide kroz `_quit(code)`, koji zove `CampSmokeUtil.restore_save(self, _backup)` pa `quit(code)`. Prazan backup znači da savea nije bilo, pa `restore_save` briše fajl koji je test napravio.

**Prevencija:** smoke test nikad ne zove `quit()` direktno, samo `_quit()`. Provjera: kopiraj save sa strane, pusti sve `*_smoke.gd`, pa `cmp` sa kopijom mora reći da su isti.

**Dopuna 2026-10-10:** odgođeni save (`save_player_save_soon`, Arena i swipe sezona) se isprazni i na izlazu (`NOTIFICATION_PREDELETE`) — **poslije** testovog vraćanja kopije. Testovi s vlastitim `_restore_save` (samo upišu fajl) su tako ostavljali testno stanje u saveu (testni save 1447 → 2003 bajta između dva mjerenja). Rješenje u `GameState`: pamti hash sadržaja koji je sam napisao ili učitao (`_save_disk_hash`); `flush_save_soon` preskače ako je fajl u međuvremenu promijenio neko drugi.

## #26 — `PackedInt32Array` u Dictionaryju: `append` ne stiže nazad

**Datum:** 2026-10-06 (Sezone faza 2, test kontrasta)

**Simptom:** mreža ćelija `grid[key] = PackedInt32Array()` pa `(grid[key] as PackedInt32Array).append(i)` ostane prazna. Svaki uzorak boje je bio „bijel", a kontrast isti za svih 8 sezona.

**Uzrok:** Packed nizovi (`PackedInt32Array`, `PackedVector2Array` …) su vrijednosni tipovi s copy-on-write. Čitanje iz Dictionaryja daje kopiju, pa `append` mijenja kopiju, ne vrijednost u rječniku.

**Rješenje:** u rječniku drži `Array` (referentni tip), ili poslije izmjene vrati niz nazad (`grid[key] = arr`).

**Prevencija:** Packed niz u Dictionaryju / Arrayu mijenjaj samo preko lokalne varijable koju na kraju upišeš nazad. Isto važi za `chunk["idx"]` u `SeasonBackdrop._append` (zato tamo stoji `chunk["idx"] = all_idx`).

## #27 — StyleBoxFlat sjena ne crta se sa `shadow_size = 0`

**Datum:** 2026-10-09 (Run HUD v2, pilula `N / 50` u Areni)

**Simptom:** „tvrda sjena 0 6 0" iz dizajna se ne vidi ispod čipa.

**Uzrok:** StyleBoxFlat crta sjenu samo kad je `shadow_size > 0`; `shadow_offset` sam ništa ne radi.

**Rješenje:** `shadow_size = 1` (gotovo tvrda sjena), kao `UiPopups._hard_shadow`.

**Prevencija:** za CSS `box-shadow: 0 Npx 0` uvijek `shadow_size = 1` + `shadow_offset`. Shop v2 `hard_shadow()` popravljen istim putem (commit 6655a82).

## #28 — Label s `text_overrun_behavior` ima minimalnu širinu 0

**Datum:** 2026-10-09 (Run HUD v2, LevelChip)

**Simptom:** „Level 12" se ne vidi u čipu; zastavica je tu, tekst ne.

**Uzrok:** kad je overrun uključen (ili `clip_text`), Label ne traži širinu teksta — u `PanelContainer`/`HBox` dobije 0 px i sav tekst se odreže.

**Rješenje:** overrun samo kad tekst stvarno ne stane, uz fiksnu `custom_minimum_size.x` (vidi `run_controller._layout_level_chip`).

**Prevencija:** test provjerava da je širina labele ≥ širine teksta (`font.get_string_size`), ne samo da tekst postoji.

## #29 — skupo crtanje: AA StyleBoxFlat i AA linije po komadu

**Datum:** 2026-10-09 (FPS pregled cijele igre, `perf_suite_bench.gd`)

**Simptom:** Arena šteka pri svakom spajanju (frejm 28–46 ms); Home kartica sezone bez cvijeća ima ~1300 draw poziva.

**Uzrok:**
- `draw_style_box` sa zaobljenim AA StyleBoxFlat košta ~0,15 ms CPU po pozivu; sjemenka u Areni ih je crtala 4–6 (0,7 ms), a posle mergea se prekrtalo ~25 sjemenki.
- Svaki AA `draw_polyline` / `draw_line` je svoj draw poziv; isprekidan rub kao niz crtica = stotine poziva svaki frejm.
- Puls / animacija rješavana kroz `queue_redraw()` cijelog crteža svaki frejm.

**Rješenje:** statični dio se iscrta jednom u teksturu (`ArenaChipBake`); sve crtice jednim `draw_multiline(..., true)`; animirani dio u zaseban čvor, pa se mijenja samo `modulate` / transform (prsten sjemenke, glava munchera, sloj rasutih elemenata livade).

**Prevencija:** prije nego nešto animiraš kroz `queue_redraw()`, provjeri cijenu crteža (`perf_suite_bench.gd`, `MM_ROOT=1 MM_VSYNC=1`). Pravilo: po frejmu se mijenjaju transformi i modulate, ne geometrija.

**Dopuna 2026-10-10:** `draw_multiline(..., true)` s **poluprozirnom** bojom za luk iz ravnih segmenata daje pruge: meki rubovi susjednih segmenata se preklapaju i dvaput miješaju (magnet prsten u runu). Za isprekidan luk: jedna mreža trouglova s trakom alfa 0 na rubu (`pip_visual._draw_dash_ring`, `RenderingServer.canvas_item_add_triangle_array`) = 1 draw poziv, pravi luk.

## #30 — `load_threaded_get` čeka sve ispred sebe u redu threadova

**Datum:** 2026-10-10 (start huba, prefetch cvijeća)

**Simptom:** posle dodavanja prefetcha tekstura start huba je duži 1,2 s; kasnije jedan frejm od ~650 ms baš kad se doda Arena stranica.

**Uzrok:** pozadinska učitavanja (`ResourceLoader.load_threaded_request`) idu kroz isti red niskog prioriteta u `WorkerThreadPool` — praktično redom. Tekstura cvijeća zatražena posle Shop i Arena scena čeka da se one učitaju (~0,6 s). Kad kartica u tom trenutku nacrta cvijeće, `load_threaded_get` (a i obični `load()` iste putanje) blokira glavni thread do kraja cijelog reda ispred.

**Rješenje:** male stvari koje UI uskoro crta (cvijeće, ~100 ms za 48 tekstura) zatraži **prije** velikih scena; ono što početna stranica crta odmah ne ide u pozadinu (`meta_hub_controller._finish_boot`: frejm kasnije prvo `FlowerAssets.prefetch_rosters()`, pa stranice).

**Prevencija:** pri dodavanju `load_threaded_request` pitaj: ko će ovo `get`-ovati i šta je ispred u redu? Mjeri vremensku liniju starta (frejm po frejm, koja stranica je dodana kad), ne samo prosjek.

## #31 — GDScript u `WorkerThreadPool` pri izlasku = pad (exit 139)

**Datum:** 2026-10-10 (Pip atlas u pozadini)

**Simptom:** smoke test ispiše „OK", pa proces padne s kodom 139 (segfault) — samo testovi koji grade Shop.

**Uzrok:** zadatak (`WorkerThreadPool.add_task` s GDScript lambdom) je još radio dok se SceneTree gasio i skripte oslobađale.

**Rješenje:** pri prvom zadatku `root.tree_exiting.connect(_drain_jobs)` — sačekaj (`wait_for_task_completion`) sve zadatke prije gašenja (`UiPip`). Svaki `add_task` mora imati tačno jedan `wait_for_task_completion`.

**Prevencija:** svaki posao u threadu treba vlasnika koji ga sačeka i na izlazu; smoke testovi gledaju i exit kod, ne samo „OK" u izlazu.

## #32 — debug pomoć koja sama mijenja save briše pravi napredak

**Datum:** 2026-10-12 (prijava: sezone se ne slažu između sekcija, kupljene nestaju)

**Simptom:** posle runa (ili novog pokretanja) kupljene premium sezone nisu „tvoje", otključana sezona iz Campa je opet zaključana, Home polje pokazuje jednu sezonu, Arena drugu.

**Uzrok:** `meta_hub_controller._ready()` i `main_menu._ready()` u debug buildu su zvali `GameState.debug_playtest_two_free()` (playtest iz CAMP-02 ere): svaki put kad se hub napravi — start, povratak iz runa — obriše `owned_paid_seasons`, vrati `unlocked_seasons` na S1 + S2, postavi aktivnu na Frost i snimi. Igrač igra debug build (`godot-run.ps1`), pa je to izgledalo kao nasumične greške sinhronizacije. Smoke testovi su to sakrili jer postavljaju `skip_debug_season_unlock = true`.

**Rješenje:** poziv izbačen; debug pomoći se zovu samo ručno (Dev sekcija u Settingsu). `season_sync_smoke.gd` namjerno NE postavlja `skip_debug_season_unlock` i provjerava da povratak u hub ne mijenja sezone.

**Prevencija:** debug pomoć koja piše u save nikad ne ide u `_ready()` ni u bilo koji automatski tok. Bar jedan test mora ići kroz igru bez „skip" zastavica koje gase dev ponašanje.

## #33 — Pip rig crta preko susjednih oznaka (z do 11)

**Datum:** 2026-10-12 (Ormar, oznaka „Free" na Classic Pipu; veo na nekupljenim skinovima)

**Simptom:** oznaka „Free" je pola sakrivena iza glave Pipa; Pip na kartici pod velom ostaje pun boje.

**Uzrok:** `UiPip` daje dijelovima riga `z_index` do 11 (`_part_z`, relativno). Sve što je u istom pregledu sa z 0 (oznake, kvačica, veo nacrtan u `_draw` pregleda) crta se ispod njih.

**Rješenje:** oznake kartice `z_index = 12` (`ItemCard.TAG_Z`); pod velom se Pip priguši `modulate.a = 0.45` (`ItemPreview.veil` setter).

**Prevencija:** UI iznad Pipa u istom kontejneru mora imati z > 11; veo koji treba da prekrije Pipa ide kao čvor sa z > 11, ne u `_draw`.

**Dopuna 2026-10-14:** Pip u pregledu sad stoji na `UiPip.HOST_LIFT` (+4, vidi #35), pa oznake idu na `TAG_Z = 16`; „Free" / „Premium" su ispod imena kartice, ne preko pregleda.

## #34 — zajednička AnimationLibrary s klipovima za čvorove koje nemaju svi

**Datum:** 2026-10-14 (Sir Pip, premium skin)

**Simptom:** svaki Classic / Blossom Pip u Shopu ispiše desetine `AnimationMixer: 'k_cape_idle', couldn't resolve track: 'root/pip/body/k_cape:…'`, čim se negdje napravi Sir Pip.

**Uzrok:** `UiPip` dijeli jednu `AnimationLibrary` po pogledu. AnimationMixer pri osvježavanju keša provjerava putanje **svih** animacija u biblioteci, ne samo one koja svira. Kad Sir Pip doda klipove sa `k_cape` / `k_helm`, Classic instance ih ne nalaze.

**Rješenje:** skin sa vlastitim čvorovima riga ima svoju biblioteku (`_lib_skin`, ključ `pogled|rm|skin`); ostali skinovi i dalje dijele jednu.

**Prevencija:** biblioteka koja se dijeli između instanci smije imati samo klipove čije putanje postoje u svakoj instanci. Test bez upozorenja: `grep -c WARNING` u izlazu `premium_pip_smoke` mora biti 0.

## #35 — dio s negativnim z pada ispod pozadine domaćina

**Datum:** 2026-10-14 (Sir Pip u Shopu i Ormaru)

**Simptom:** ogrtač Sir Pipa (z −1) i sjena Pipa (z −4) se ne vide u pregledu u Shopu / Ormaru, a na polju se vide.

**Uzrok:** `ItemPreview` (i Shop kartice) crtaju pozadinu u svom `_draw()` na z 0. Dijete sa z < 0 se crta prije roditelja, dakle ispod njegove pozadine.

**Rješenje:** domaćin koji sam crta pozadinu diže Pipa: `actor.z_index = UiPip.HOST_LIFT` (4) — `ItemPreview`, „All set", Starter Pack. Najviši dio je tada 15, pa oznake kartice idu na 16.

**Prevencija:** pri novom domaćinu za Pip (ili drugi rig s negativnim z) provjeri da li roditelj crta u `_draw()`; ako da, digni dijete za najniži z riga. Snimak površine s premium skinom (ogrtač iza tijela) to odmah pokaže.

## #36 — pravilo iz CD paketa nije tačno za fajlove iz istog paketa

**Datum:** 2026-10-14 (design_handoff_muncher_premium_pip)

**Simptom:** uši i šape Sir Pipa ostaju mint u igri, a u pregledaču paketa su medene.

**Uzrok:** `skins_knight.json` kaže „zamijenjeni dijelovi su u finalnim bojama, bez recolora", ali SVG-ovi `k_ear_*` / `k_paw_*` / `k_body_*` nose classic tokene krzna (`#A8E6CF`, `#7CCBAE`, `#FFCCD5`). Pregledač ih tiho preboji.

**Rješenje:** recolor ide na sve dijelove skina; boje oklopa nisu classic tokeni, pa ostaju (`UiPip._raster`).

**Prevencija:** poslije prenosa paketa uvijek tabla svih pogleda × skinova (Godot snimak) uz pregledač paketa — ne vjerovati opisu pravila, nego boji na ekranu. Isti paket: SVG-ovi nose ~7,7 KB C2PA metapodataka po fajlu (skida ih kopiranje u `game/assets`).

## #37 — sinhroni `load()` zvukova na startu = kasni frejmovi huba

**Datum:** 2026-10-14 (zvuk u igri)

**Simptom:** posle dodavanja zvuka start huba (`hub_boot_5s`) ima 21–35 kasnih frejmova od ~280 (bilo 7–11), najgori 64–97 ms; bez zvuka (`AudioManager` zamijenjen praznim) opet normalno.

**Uzrok:** `AudioManager` je efekte učitavao „u pozadini" sa 4 `load()` po frejmu na glavnom threadu. Jedan WAV (QOA) je ~3 ms (do 10 ms), tema (OGG) ~13 ms — pa je prvih ~16 frejmova dobilo +13 ms baš dok hub gradi stranice, a `play_music("meadow")` na startu još 13 ms.

**Rješenje:** sve preko `ResourceLoader.load_threaded_request`, efekti **po jedan** (sljedeći se traži tek kad je prethodni gotov — red je FIFO, #30, pa stranice huba ne čekaju iza 62 fajla), prva tema se traži već u `_ready` autoloada, ostale kad zatrebaju (stara počne da se gasi odmah, nova uđe kad je fajl tu). Efekat koji zatreba prije reda: sinhrono (~3 ms, jednom); ako je baš taj fajl u threadu, `load(path, "", CACHE_MODE_IGNORE)` — inače bi `load()` čekao sve ispred njega u redu. A/B (3 × naizmjenično): sa zvukom 16–24 kasna, bez zvuka 21–27 — šum laptopa.

**Prevencija:** svaki „preload" mjeri u ms po fajlu (`ResourceLoader.load(..., CACHE_MODE_IGNORE)` u petlji) prije nego odlučiš koliko po frejmu; više od ~1 ms po frejmu na startu ide u thread. Bench starta uvijek A/B (servis isključen preko `override.cfg` `[autoload]`), jer laptop šumi ±10 kasnih frejmova.

## #38 — Vibration u Settingsu ne radi na Androidu (dozvola isključena)

**Datum:** 2026-10-14 (haptika uz zvuk)

**Simptom:** prekidač Vibration postoji i čuva se, `Input.vibrate_handheld()` se zove, a telefon ne vibrira.

**Uzrok:** `export_presets.cfg` je imao `permissions/vibrate=false` — Android tiho ignoriše vibraciju bez dozvole `VIBRATE`.

**Rješenje:** `permissions/vibrate=true` (normalna dozvola, korisnik je ne mora odobriti, ne mijenja Play listing).

**Prevencija:** za svaku funkciju koja zove sistemski servis (vibracija, mreža, notifikacije) provjeri dozvolu u `export_presets.cfg` u istom koraku kad dodaješ kod; desktop i headless testovi to nikad neće uhvatiti.

## #39 — izlaz usred pozadinskog učitavanja scene = „Parse Error … shop_screen.tscn"

**Datum:** 2026-10-14 (smoke testovi huba, od 2026-10-10)

**Simptom:** `meta_hub_smoke` (i `hub_chrome_icons_smoke`, `swipe_snap_smoke`) poslije „OK" ispiše `ERROR: Parse Error: Failed. [Resource file res://scenes/ui/shop_screen.tscn:13]` i `Failed loading resource`; exit kod 0. U 4 od 4 prolaza.

**Uzrok:** test izađe 3 frejma poslije starta huba, dok se Shop stranica još učitava u threadu (`load_threaded_request`). Pri gašenju `ResourceLoader` namjerno prekida učitavanja u toku — zavisnost (skripta Shopa, linija 13 `script = ExtResource(...)`) se više ne učita, pa scena „ne parsira". Isto bi se desilo kad igrač ugasi igru u prvoj sekundi.

**Rješenje:** `BackgroundLoad` (`scripts/visual/background_load.gd`): svako pozadinsko učitavanje ide kroz `BackgroundLoad.request(path)` (hub stranice, cvijeće, `AudioManager`), a na `root.tree_exiting` se preuzme sve što vlasnik nije uzeo — u toku (čeka se) i gotovo (inače „Resource still in use"). 0 grešaka u 12 prolaza; gašenje isto brzo. `meta_hub_smoke` provjerava da hub ide kroz `BackgroundLoad`.

**Napomena (nije od ovoga):** muzika koja svira u trenutku `quit()` ponekad ostane u AudioServeru (zaustavljena reprodukcija se čisti tek sljedećeg frejma, kog nema) → „N resources still in use" za `.ogg`. Bezopasno; test koji pušta muziku je utiša i sačeka 0,3 s prije izlaza (`audio_smoke`).

**Prevencija:** svaki `load_threaded_request` ide kroz `BackgroundLoad.request` — kao poslovi u `WorkerThreadPool` (#31), ko pokrene posao, sačeka ga i na izlazu.

## #40 — sloj iznad stranice (Settings, štand Shopa) ima manji z od sadržaja stranice

**Datum:** 2026-10-16 (playtest)

**Simptom:**
- U Areni otvoriš Settings — neki elementi Arene (muncher, pilula „N / 50", combo oznaka) ostanu preko Settingsa.
- U Shopu na Boosters tabu skrolaš — Pip (skin) iz kraja „All set" ide preko štanda s tabovima.

**Uzrok:** `z_index` se sabira niz roditelje i važi preko cijelog canvasa, bez obzira na red u stablu:
- Settings je imao z 50, a Arena ima slojeve do z 60 (muncher 45 + rig, pilula 60, combo 60; letenje coina je top_level z 100).
- Štand Shopa je imao z 3, a Pip u karticama ide do z 15 (`UiPip.HOST_LIFT` 4 + dijelovi do 11), oznaka „Premium" z 16.
- `clip_contents` ne pomaže: GL Compat na laptopu ne reže (#24), a štand je unutar iste stranice.

**Rješenje:**
- `SettingsScreen.Z` = 200.
- Štand Shopa `TAB_BAR_Z` = 20, toast 22.
- `fixes_1016_smoke.gd` računa efektivni z cijelog podstabla (relativni z, top_level) i traži da je sloj iznad najvišeg sadržaja.

**Prevencija:** svaki sloj koji mora pokriti stranicu (overlay, štand, header) dobija z iznad **najvišeg efektivnog z sadržaja** — izmjeri ga (kao u testu), ne pretpostavljaj. Kad dodaješ novi visok z (Pip `HOST_LIFT`, oznake, letenje), provjeri overlaye iznad njega.

## #41 — vreća sjemena s limitom tiho briše plijen

**Datum:** 2026-10-16 (drugi put; prvi put 2026-10-05, `seasons-izvjestaj` #4)

**Simptom:** na kraju runa plijen se vidi (i ×2), a u Campu sjemena nema.

**Uzrok:** `SEED_BAG_SOFT_CAP` 40 — `add_seeds_to_bag` je dodavao samo do limita, a `deposit_loot_to_camp` je ostatak brisao. U save-u igrača 38 / 40 → od plijena su stala 2 sjemena. Poruka „Bag full · X of Y" na kraju runa nije bila dovoljna.

**Rješenje:** vreća nema limit (`SeedBagDomain.add`). Arena ionako sipa samo koliko polje prima, pa višak čeka u vreći. Isto su ranije tiho gubili ostatak Arene (T1 natrag u vreću) i vacuum T2 → 2 × T1.

**Prevencija:** pravilo koje odbacuje igračevu zaradu ne smije biti tiho — ili se ne odbacuje, ili igrač bira (prodaj / ostavi). Test: `fixes_1016_smoke` (vreća 38 + plijen 20 = 58).

## #42 — množitelj po tipu „pojede" bonus; revive ga primijeni dvaput

**Datum:** 2026-10-16

**Simptom:** igrač kupi Loot Boost, a plijen izgleda isto kao prije („kao da se ne aplicira").

**Uzrok:**
- `finish_run` je zaokruživao svaki tip posebno: `round(1 × 1,25) = 1`. Run s mnogo tipova po jedno-dva sjemena dobije 0–1 bonusa.
- Revive je nastavljao od `carry_seed_bag` (već pojačan), pa se na kraju množilo drugi put.
- Nigdje se nije vidjelo da je boost primijenjen.

**Rješenje:** `scale_loot_seeds` — cilj na ukupnom broju, raspodjela najvećim ostatkom; sirovi carry za revive; zlatni pečat na loot ekranu.

**Prevencija:** množitelj na zbiru koji se dijeli po kategorijama računaj na **ukupno** pa raspodijeli; stanje koje se nastavlja čuvaj **prije** transformacije. Testovi: `loot_boost_twin_smoke`, GUT `test_game_state_loot_boost`.

## #43 — obrisan `class_name` sruši headless: „Identifier X not declared"

**Datum:** 2026-10-17

**Simptom:** poslije brisanja skripte s `class_name` (npr. `UiShop`), GUT i headless padnu na tuđim klasama (`UiSettings`, `BackgroundLoad`, `Sfx`) i `GameState` autoload se ne učita. U `.godot/global_script_class_cache.cfg` stari unos još pokazuje na obrisani fajl, a novije klase mogu nestati iz keša.

**Uzrok:** Godot u headlessu registruje globalne klase iz tog keša. Pokvaren ili nepotpun keš znači da `class_name` više nije u opsegu, pa se svaka skripta koja ga koristi ne parsira.

**Rješenje:** `.\scripts\godot-import.ps1` (rebuild keša). Ne ručno krpati cfg osim kao hitan korak prije importa.

**Prevencija:** poslije brisanja `class_name` skripte uvijek import, pa GUT. Keš je u `.godot/` i nije u gitu.

## #44 — animacija iz JSON-a čitana po frejmu: 3 ms samo za efekte

**Datum:** 2026-10-20

**Simptom:** efekti dodira pickupa (design_handoff_run_pickups) radili su tačno, ali headless CPU mjerenje je pokazalo ~3,3 ms po frejmu u najgorem slučaju (15 dodira / s), a idle 10 pickupa ~0,45 ms. GPU bench to nije jasno pokazao — laptop šeta i do 2× između pokretanja.

**Uzrok:** za svaki sprite svaki frejm: 7 poziva `key(keys.get("x"), …)` nad Dictionary / Array iz JSON-a (dinamički tipovi, petlja kroz ključeve), plus `.get()` na podacima idle-a. U GDScriptu na ovom laptopu poziv funkcije ≈ 2–5 µs, upis svojstva čvora ≈ 1 µs.

**Rješenje:** `PickupArt.events()` jednom prevede događaje u tipizirane klase (`CEvent`, `CSpr`) i ispeče staze (120 uzoraka / s) u `PackedFloat32Array`; runtime miješa dva uzorka. Jedan upis `transform` umjesto tri svojstva; alfa samo kad se mijenja; idle parametri u varijablama iz `_ready`. Rezultat ~0,35 ms najgore, ~45 µs tipično.

**Prevencija:** za svaki CD paket s animacijom iz JSON-a izmjeri i **CPU skripti headless** (minimum od više naizmjeničnih prolaza, s referentnim poslom), ne samo GPU bench. Headless `-s` test koji pukne skriptnom greškom poslije `await` nikad ne pozove `quit()` — pokreći ga s vremenskim ograničenjem (`Start-Process` + `WaitForExit`).

## #45 — smoke test zavisi od stanja na računaru (Reduce motion, pravi save)

**Datum:** 2026-10-20

**Simptom:** 7 smoke testova pada isto i na čistom HEAD-u, a kod igre je ispravan:
- `muncher_rig_smoke` („expected m_frozen, got m_freeze"), `pip_rig_smoke` („cape loop should play while idle");
- `fixes_1016_smoke` (napomena „Kept" u nadogradnjama prazna), `home_basket_picker_smoke` (zaključana bundeva postane loadout), `season_meadow_smoke` (polje ne raste na povratku, 13 → 13);
- `loot_logic_smoke` (Loot Burst se ne dodijeli), `merge_arena_smoke` (bez poruke).

**Uzrok:** testovi i igra dijele `user://` (#25). Na laptopu je u `settings.cfg` uključen **Reduce motion**, pa se klipovi Nibbsa i petlja ogrtača preskaču. Testovi čitaju i **pravi save**: Frost nadogradnje na max (nema „can", nema napomene), velik `lifetime_seeds_collected` (prvi pickup otključa lanac do bundeve), pun `star3_grown` (polje već puno 13 / 13). `loot_logic_smoke` je očekivao staro ponašanje Loot Bursta (nagrada na restore), a MEAD-4 ga je prebacio na `consume_purchase`; `merge_arena_smoke` je prolazio, ali nije ispisivao „OK".

**Rješenje:** `CampSmokeUtil.backup_save()` u memoriji gasi Reduce motion (ne snima settings.cfg); `pip_rig_smoke` to radi sam (ne koristi backup). Testovi resetuju stanje koje provjeravaju: Frost red u `season_upgrades`, `lifetime_seeds_collected`, `crystal_stash_domain.grown`. `loot_logic_smoke` ima lažni billing klijent (consume odmah uspije) i provjerava novo pravilo: nagrada tek poslije consume-a, bez tokena nema nagrade, svaki token jednom. `merge_arena_smoke` ispisuje „OK".

**Prevencija:** test postavlja **svako** stanje koje provjerava, i ono koje „obično" stoji na nuli (nivoi po sezoni, lifetime brojevi, uzgojeno). Postavke iz `settings.cfg` (Reduce motion, zvuk) nikad ne smiju odlučivati ishod testa. Kad padne test, prvo ga pokreni na čistom HEAD-u (worktree): pad i tamo = test / okruženje, ne nova izmjena. Svaki test ispisuje „<ime> OK".

## Brza dijagnostika (kad nešto "ne radi")

1. **Otvori Debugger/Output panel** u Godotu — greška je skoro uvijek tu.
2. Pokreni **headless smoke-test** ([[dev-workflow|dev-workflow]]) — vidiš greške bez GUI-a.
3. "Radi X ali ne Y?" → vjerojatno je nešto u `_ready()` puklo pa je Y neinicijaliziran.
4. Node reference `null`? → kriva putanja `$Path` ili tip u `@onready`.
5. Kolizija ne radi? → [[fizika-kolizije|fizika-kolizije]] layer/mask tablica.

## Povezano

- [[scene-node-pravila|scene-node-pravila]]
- [[dev-workflow|dev-workflow]]
- [[_index|← Godot priručnik]]
