# Ispravke + Settings — handoff

Četiri stvari u jednom dizajnu: A prozor Albuma, B Classic Pip kao skin, C rig Pip u Shopu, D Settings ekran. Header i footer huba, Pip art i animacije, cijene i ID-jevi se ne mijenjaju. Ništa novo se ne prodaje.

> **Napomena o izvoru.** `docs/04-experience/design-drafts/ispravke-settings-cd-brief.md` i `ispravke-settings-ref/` ne postoje na `master` (provjereno 2026-10-12). Mjere su iz koda (`collection_journal.tscn/.gd`, `ui_journal.gd`, `shop_support_card.gd`, `cosmetics.json`, `skins.json`) i paketa `design_handoff_journal`, `_wardrobe`, `_pip`, `_shop_v2`, `_hub_chrome_v2`, `_popups`. Samoprovjera §5.4 je rekonstruisana iz briefa u chatu (9 stavki).

## Šta otvoriti

- `design/Album.dc.html` — A1–A3 Golden (vrh, sredina, kraj), A4–A5 Plain, A6 živo (točkić / povuci). Dugme **X-ray** pokaže redove ispod poklopaca.
- `design/Wardrobe Pip.dc.html` — B1–B3 Ormar (Classic nosiš, Blossom nosiš, novi igrač; tap mijenja), B4 tri skina × 7 površina.
- `design/Shop Pip.dc.html` — C1–C3 Starter Pack (dostupno / kupljeno / isteklo), C4–C5 „All set here“, C6 Looks · Pip (bez Classica). Tap na pregled u C6 = potpis.
- `design/Settings.dc.html` — D1–D5 živi ekrani (debug / tiho / kraj debug / kraj release / Credits), D6 četiri stanja Restore.
- `design/Specs.dc.html` — mjere, performanse i **živa samoprovjera** (konzola `SELFCHECK n/9`).
- `design/pip_*.js` — nepromijenjena kopija iz `design_handoff_pip` (jedini izvor Pipa).
- `assets/icons/` — 5 novih SVG ikona (Settings).
- `godot/` — `settings_export.json`, `ui_settings.gd` (novo), `ui_journal.gd` (izmjene), `settings_tree.txt`.

## § Odlučeno

1. **Album = prozor + četiri poklopca.** ListScroll je kvadratna rupa; oko nje četiri neprozirna `ColorRect` (#FFF8F0, z iznad liste), pa obrub prozora (`draw_center = false`), pa okvir stranice. Obrub pokriva vanjske uglove svoje kutije i crta zaobljene unutrašnje (r 22 / 23), pa je van zaobljenog prozora svaki piksel neproziran — bez clippinga. Provjereno mjerenjem: poklopci + rupa = 1080 × 1633 tačno, u svih 6 stanja.
2. **Golden:** obrub 8 `#D6A82F` r 30 na (44, 212, 992 × 1349); okvir stranice ostaje (edge 13 + gold 7). Plaketa i summary u gornjem poklopcu. **Plain:** obrub 3 `#E3DCD3` (= ink 10 % na kremu, ali neprozirno). HeadDivider se briše (vrh obruba ga zamjenjuje). Redovi 952 / 1002, visina 200 i razmaci isti.
3. **Tier labele i ★ 32 → 34** — jedini tekst ispod 34 u ekranima koje diram.
4. **Classic Pip = kartica skina iz `skins.json`** (key `classic`, `cosmetic_id ""`), ista poza `pose_classic`, ista sličica 210 × 150. Oznaka **„Free“** gore lijevo (mjesto NewTaga — Classic nikad nije „New“), uvijek tvoj, može biti Wearing. `cosmetics.json` se ne mijenja; Ormar za `pip_skin` više ne crta Default karticu.
5. **Shop:** Classic nema shop stavku → nema kartice u Looks. Starter Pack: `UiPip` three_q Blossom 164, `pose_blossom`, mirno. „All set here“: `UiPip` front 190, skin = nošeni, lice happy, mirno.
6. **Settings = pun ekran**, ne sheet: pet sekcija ne stane u sheet 1326, a pun ekran nema scrim ni povlačenje. X je tačno na mjestu zupčanika (palac ne putuje); Back zatvara; na Credits X vraća na Settings.
7. **Slider = dugme Mute + traka + broj.** Mute čuva vrijednost (unmute vraća 80, ne 100). Prevlačenje skida mute. Broj 56 px, kad je mute „Off“. Primjenjuje se odmah na busove `Music` / `SFX` (postoje i bez zvukova), sprema se pri puštanju.
8. **Toggle cijeli red** (≥ 120 visine) je dodir, ne samo prekidač. Vibracija pri uključivanju kratko zavibrira — jedina potvrda koja radi bez zvuka.
9. **Restore: 4 stanja** — idle, restoring (tri tačke, jedini loop), restored („✓ Restored“, ili „✓ Checked · Nothing to restore“), failed (roze, tap ponovo). Rezultat je na dugmetu i u redu ispod; nema toasta.
10. **Remove Ads** je samo status („Ads on“ / „✓ Ads off“). Nema dugmeta za kupovinu (Pillar 2: Settings ne prodaje).
11. **Developer** samo kad je `OS.is_debug_build()`: isprekidana / #F1EAE0 kartica + „Debug build“ oznaka; reset dugmad su roze.
12. **How to play — ne.** Tutorial već uči na licu mjesta (coach oblačići, popups H1/H2/A1/R1); poseban ekran bi trebao novi sadržaj i održavanje za 8 sezona, a „Reset tutorial“ ostaje u Dev za provjeru.
13. **Reset progress — ne.** Nema cloud savea, pa je brisanje nepovratno; kupovine bi ostale a sezone/Album nestali, što stvara support zahtjeve i ljute recenzije. Igrač koji baš želi može obrisati podatke aplikacije u OS-u. Ako se ikad doda: tek s cloud saveom, dvostruka potvrda (modal + upiši „RESET“).
14. **Credits** su kratka podstranica (igra, Godot MIT, Nunito OFL, hvala). Version je zadnji red liste.

## § Šta se briše

- Album: `GoldenFrameEdge` / `GoldenFrameGold` kao overlay preko liste (to je bio bug — lista je skrolovala ispod njih do ivice), `HeadDivider`, `root_vbox.offset_left/right` igra u `_apply_frame` (zamjenjuje `UiJournal.list_window()`).
- Ormar: Default kartica za `pip_skin` (`allow_default` / `default_title` se više ne crtaju za Pip slot), naslov „Default“.
- Shop: `PipAssets.get_texture(STARTER_PACK_COSMETIC)` + `draw_texture_rect` u `_Tiles._draw`, `pip_idle.svg` TextureRect u „All set here“, `assets/ui/wardrobe/pip_blossom.svg` / `pip_sky.svg` (već na listi Pip paketa).
- Hub: toast „Settings coming soon“ u `meta_hub_controller._on_settings_pressed()`.

## § Performanse (§5.3)

| | vrijednost | limit |
|---|---|---|
| `_draw()` / `queue_redraw` po frejmu | 0 (novih); `_Tiles._draw` više ne crta Pipa | 0 |
| Album dok se skroluje | mijenja se samo `List` (ScrollContainer) i `Grabber.position.y`; poklopci, obrub, okvir, glava statični | statično |
| Novih čvorova u Albumu | 5 (4 ColorRect + 1 Panel) | — |
| Slider / toggle | `Fill.scale.x`, `Thumb.position.x`, `Knob.position.x` | transform |
| Animacije | ulaz 0,24 · izlaz 0,20 · toggle 0,15 · pritisak 0,08 · rezultat 0,22 s | ≤ 0,3 s |
| Loopovi | 1 (tačke Restore dok čeka) | — |
| Pip u Shop listi | 0 AnimationPlayera u radu (mirna poza) | — |
| Novi SVG | 5 fajlova, 39,2 KB na disku (svaki nosi ~6,8 KB ugrađenog metadata bloka), 1,27 KB crteža | ≤ 60 KB |

## § Samoprovjera (§5.4)

Provjereno 2026-10-12 u pregledaču, `design/Specs.dc.html` (sekcija Self-check, mjeri DOM sva četiri dizajn fajla), konzola: `SELFCHECK 9/9`.

1. **da** — Album: četiri poklopca + rupa = 1080 × 1633 tačno, neprozirni (#FFF8F0), z iznad liste — u svih 6 stanja (Golden vrh / sredina / kraj, Plain vrh / sredina, živo).
2. **da** — Okvir statičan: poklopci, obrub, okvir i glava nisu djeca `List`; skrol mijenja samo `List.transform` i `Grabber.transform`.
3. **da** — Classic Pip: 3 kartice iste veličine 240 × 272, Pip u svakoj, „Free“, Wearing ✓, 0 Default kartica.
4. **da** — 21 / 21 ćelija: polje, kartica sezone, Arena, run odozgo, HUD runa, Camp, Shop / Ormar × Classic / Blossom / Sky.
5. **da** — Shop: 0 starih slika zeca; Starter Pack rig Pip 3 / 3 stanja; „All set“ rig Pip u nošenom skinu 2 / 2; Looks ima 2 kartice, Classic se ne prodaje.
6. **da** — Settings: Sound / Gameplay / Purchases / Privacy & help (+ Developer); Dev u debug da / release ne; 4 stanja Restore nacrtana.
7. **da** — Najmanji tekst 34 px, brojevi slidera 56 px.
8. **da** — Najmanji dodir 120 px.
9. **da** — 0 gradijenata / filtera / maski / blura, 0 tranzicija > 0,3 s, novi SVG 39,2 KB (≤ 60).

## Prenos (redoslijed)

1. `godot/ui_journal.gd` → `game/scripts/visual/`. U `collection_journal.tscn` izvadi `ListScroll` iz `RootVBox`, dodaj `CapTop/Bottom/Left/Right` + `WindowRim` (vidi `settings_tree.txt`); `_apply_frame()` postavi rectove iz `UiJournal.list_window(golden)`.
2. `wardrobe_sheet.gd` / `item_card.gd` / `item_preview.gd`: Pip slot iz `skins.json`, FreeTag, `UiPip` za sve tri.
3. `shop_support_card.gd`, `shop_screen.gd`: `UiPip` umjesto teksture.
4. `godot/ui_settings.gd` → `game/scripts/visual/`; nova scena `settings_screen.tscn`; busovi `Music` i `SFX` u `default_bus_layout.tres`; `UiSettings.apply(load_settings())` na startu.
5. Ikone `assets/icons/*.svg` → `game/assets/ui/chrome/`, pa `scripts/godot-import.ps1` i commit `.import` (CLAUDE.md § Novi asset).
6. Headless smoke: `hub_chrome_smoke` (SettingsButton otvara SettingsScreen), novi `album_window_smoke` (poklopci pokrivaju 1080 × 1633), `shop_booster_guard_smoke` (All set ima UiPip).

## Otvoreno

- Brief §1–§5 nije bio dostupan; ako §5.4 ima drugačijih 9 stavki, Specs ih mjeri na jednom mjestu (`TITLES` + `run()`).
- `GameState.vibration_enabled` / `reduce_motion` su nova polja (predlog imena); `UiPip` već čita reduce_motion po Pip paketu.
- Version string (`0.9.3 (412)`) je primjer — u igri iz `ProjectSettings application/config/version`.
