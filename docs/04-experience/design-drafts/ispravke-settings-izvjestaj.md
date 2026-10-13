---
type: iskustvo
status: aktivan
milestone: M8
tags: [dizajn, ui, settings, journal, ormar, shop, pip, claude-design, izvjestaj]
povezano:
  - ispravke-settings-cd-brief
  - journal-cd-brief
  - pip-cd-brief
  - scope-i-granice
  - CHECKPOINT
  - changelog
ai_sažetak: "Prenos design_handoff_settings_fixes u Godot (2026-10-12): Album ima prozor s četiri neprozirna poklopca (ništa ne viri van okvira), Classic Pip je kartica skina s oznakom Free, Starter Pack i All set imaju Pipa iz riga, a zupčanik otvara pun Settings ekran (zvuk na busovima Music / SFX, vibracija, pokreti, Restore, privatnost, podrška, Credits, Dev sekcija u debug buildu)."
---

# Ispravke + Settings — izvještaj o prenosu

> Roditelj: [[04-experience/_index|04-experience]] · brief: [[ispravke-settings-cd-brief]] · paket: `design_handoff_settings_fixes/` („Nastavi package updates.zip") · datum: 2026-10-12

## Ukratko

Sve četiri stavke iz paketa su u igri.

1. **Album (A) — zlatni okvir više ne prelazi preko redova.**
   - Lista skroluje samo unutar prozora. Oko prozora su četiri neprozirna poklopca, pa obrub prozora, pa okvir stranice.
   - Ništa se ne reže maskom: igra na GL Compatibility ne reže crtanje, pa poklopci pokrivaju sve što izlazi iz prozora.
   - Zlatni prozor: obrub 8 `#D6A82F`, r 30, na (44, 158, 992 × 1403) — 54 px više nego u paketu jer je red sažetka („Album: 10 bloom…") izbačen (2026-10-12, na zahtjev).
   - Obični („Plain Album"): obrub 3 `#E3DCD3`, r 26.
   - Grabber skrola je 8 px, unutar prozora.
2. **Classic Pip (B) je pravi skin.**
   - U Ormaru je prva kartica s oznakom **„Free"**, može biti „Wearing" kao Blossom i Sky.
   - Novi igrač u Pip slotu vidi sva tri Pipa: Blossom i Sky su pod velom (prigušeni, s katancem) dok ih ne kupi.
   - U Shopu se Classic ne prodaje (Looks i dalje nudi samo Blossom i Sky).
   - Glava Pipa na traci napretka u runu sada prati nošeni skin (ranije je uvijek bila classic).
3. **Shop (C) — nema više starog zeca.**
   - Starter Pack pokazuje Pip Blossom iz riga (three_q, 164, mirna poza).
   - „All set here" u Boosterima pokazuje Pipa u nošenom skinu (prednji pogled, nasmijan, 190).
4. **Settings (D).** Zupčanik u headeru otvara pun ekran koji klizi odozdo (0,24 s). X stoji tačno na mjestu zupčanika, a Android Back ga zatvara (sa Credits vraća na Settings). Sekcije:
   - **Sound:**
     - Music i Sound effects — slider 0–100 i dugme mute; broj 56 px, „Off" kad je utišano.
     - Vibration — kratko zavibrira kad se uključi.
   - **Gameplay:** Reduce motion.
   - **Purchases:**
     - Restore purchases u 4 stanja (spremno, radi s tri tačke, „✓ Restored" / „✓ Checked", „Didn't go through");
     - status Remove Ads („Ads on" / „✓ Ads off"). Settings ništa ne prodaje.
   - **Privacy & help:** Privacy choices, Privacy policy (web), Contact support (e-mail), Credits, verzija igre.
   - **Developer** (samo debug build): Unlock all seasons, Reset seasons (vrati igru na prvu sezonu svuda — Home, polje, Arena, run), +1000 coins, Reset tutorial. Ovo je sada jedini put do debug reseta sezona; ranije ga je hub radio sam pri svakom otvaranju.

Zvuk još ne postoji, ali **sve je spremno**:
- busovi `Music` i `SFX` su u `default_bus_layout.tres`;
- slider odmah mijenja glasnoću busa;
- vrijednosti se pamte u `user://settings.cfg`, odvojeno od napretka, i primijene se pri startu igre.

Muzika i efekti samo treba da idu na te busove.

## Odstupanja od paketa (i zašto)

| Paket | U igri | Zašto |
|---|---|---|
| Redovi Albuma 952 / 1002 s krugovima 112 + natpisi T1–T3 | Redovi 952 / 1002, krugovi **136** (obični) i **120** u zlatnom prozoru, bez T natpisa | Paket je red uzeo iz starog Journal paketa. Igra je u kasnijim rundama prešla na veće krugove bez natpisa. U zlatnom prozoru s krugovima 136 opis („Spotted in runs — merge to T2, then Keep in Album.") gubi kraj, pa su tamo krugovi 120 / razmak 10 / crtež 96 |
| `TIER_LABEL_FONT 34` | konstanta postoji, ali nema natpisa | Isto kao gore |
| Verzija „0.9.3 (412)" | „Merge Meadow · Version 0.1.0" | Verzija iz `project.godot` (`application/config/version`). Broj builda nije dostupan u igri pa je izostavljen |
| Privacy choices = UMP formular | Otvara politiku privatnosti dok AdMob plugin ne dobije formular za pristanak | `AdManager` još nema pristanak (UMP). Kad ga dobije, ekran ga sam pozove (`show_privacy_options`) |
| Settings se gradi pri otvaranju | Gradi se **unaprijed u pozadini**, jedan dio po frejmu, kad hub završi svoje stranice; zatvaranje ga samo sakrije | Gradnja cijelog ekrana je ~40–67 ms u jednom frejmu (zastoj pri otvaranju). Sada je otvaranje glatko |
| Nekupljeni skinovi pod velom | Veo + Pip prigušen na 45 % | Dijelovi Pip riga crtaju iznad vela (z do 11), pa bi Pip bio pun boje preko sivog vela |

## Datoteke

- **Novo:**
  - `game/scenes/ui/settings_screen.tscn` + `game/scripts/ui/settings_screen.gd`;
  - `game/scripts/visual/ui_settings.gd` (iz paketa, + URL politike, e-mail podrške, Credits, verzija);
  - `game/default_bus_layout.tres`;
  - 5 ikona u `game/assets/ui/chrome/` (`icon_close_light`, `icon_sound`, `icon_sound_off`, `icon_chevron`, `icon_external`). Uklonjen je ugrađeni metadata blok, pa su s ~8 KB pale na ~0,25 KB svaka.
- **Album:**
  - `collection_journal.tscn`: `ListScroll` izvađen iz `RootVBox`, dodani `ListPad`, `Grabber`, `CapTop/Bottom/Left/Right`, `WindowRim`; `HeadDivider` obrisan.
  - `collection_journal.gd`: `_layout_window`, `_update_grabber`, `_size_row`.
  - `collection_journal_row.gd`: `set_slot_size`, `row_width`.
  - `ui_journal.gd`: `list_window`, `window_rim_style`, `grabber_style`, kompaktni krugovi.
- **Ormar:**
  - `ui_wardrobe.gd`: Pip slot pokazuje i nekupljene skinove, oznaka „Free";
  - `item_card.gd`: FreeTag, oznake iznad riga;
  - `item_preview.gd`: prigušen Pip pod velom.
- **Shop:** `shop_support_card.gd` (StarterPip), `shop_screen.gd` (`_AllSet` s `UiPip`).
- **Run:** `run_progress_rail.gd` (glava po skinu iz `assets/pip/hud/pip_hud_<skin>.svg`).
- **Hub:**
  - `meta_hub_controller.gd`: zupčanik otvara Settings, gradnja unaprijed, osvježavanje stranice po zatvaranju;
  - toast „Settings coming soon" obrisan.
- **Android Back:** Home (polje), Ormar i Arena ga ignorišu dok je Settings otvoren, pa Back zatvara samo Settings.
- **GameState:** `vibration_enabled`; `UiSettings.apply(load_settings())` na startu.
- `project.godot`: `config/version="0.1.0"`.
- Paket je kopiran u `design_handoff_settings_fixes/`.

## Kako je provjereno

- **Novi testovi:**
  - `album_window_smoke.gd`: zlatni i obični prozor; poklopci + prozor = cijela stranica bez preklopa; poklopci neprozirni i iznad liste; nijedan red ne viri; grabber u prozoru.
  - `settings_screen_smoke.gd`: zupčanik otvara, X na mjestu zupčanika; sekcije; Music 30 → bus −10,5 dB; mute / unmute; toggle u GameState; Restore završi; Credits ↔ Settings; X i Back zatvaraju; `settings.cfg` sačuvan. Test vraća `settings.cfg`.
- **Izmijenjeni testovi:**
  - `wardrobe_smoke` (Pip slot pod velom, 12 skinova + Classic);
  - `hub_chrome_smoke` (Settings umjesto toasta);
  - `collection_journal_smoke` (nove putanje liste).
- **Snimci i poređenje s dizajnom:**
  - Album zlatni i obični: vrh, sredina, kraj;
  - Settings: vrh, mute, kraj s Dev sekcijom, Credits, Restore „failed";
  - Ormar: Classic nošen, novi igrač;
  - Shop: Starter Pack, All set.

## Performanse (laptop, AMD iGPU, GL Compatibility)

Bench `perf_suite_bench.gd` ima nove scenarije: `journal_scroll_gold`, `settings_open_close`, `settings_slider_drag` i `settings_scroll`.

| Scenarij | vsync (kasni > 20 ms) | bez vsynca (prosjek) |
|---|---|---|
| Album skrol, zlatni okvir | 0 | 4,3 ms (obični 3,9) |
| Settings otvori / zatvori | prije gradnje unaprijed: 1 frejm ~67 ms po otvaranju; sada najviše 1 frejm ~33 ms | 2,6 ms |
| Settings slider (vuče se svaki frejm) | 0 | 3,4 ms |
| Settings skrol | 0 | 3,1 ms |

- Slider i toggle se pomjeraju samo transformom (`Fill.scale.x`, `Thumb.position.x`, `Knob.position.x`); ništa se ne crta iznova.
- Jedini loop su tri tačke dok Restore čeka.
- Skrol Albuma mijenja samo listu i grabber; poklopci, obrub i okvir su statični.
- Pip u Shop listi je u mirnoj pozi (AnimationPlayer pauziran).
- Atlas skina se pravi u pozadinskom threadu, kao Looks pregledi.

## Odluke koje čekaju tebe

- **Privacy choices:** pravi formular za pristanak (UMP) treba doći s AdMob pluginom prije izlaska u EU. Do tada dugme otvara politiku privatnosti.
- **How to play / Reset progress:** paket ih namjerno nije dodao.
  - How to play: tutorial već uči na licu mjesta.
  - Reset progress: bez cloud savea je nepovratan, a kupovine bi ostale.
  - Ako ih ipak želiš, reci.
- **Broj builda u verziji:** igra ga ne zna u runtimeu; može se dodati ručno u `project.godot` uz svaki export.
