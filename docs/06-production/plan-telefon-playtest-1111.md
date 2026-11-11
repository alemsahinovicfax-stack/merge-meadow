---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, playtest, telefon, bugfix, export, plan]
povezano:
  - CHECKPOINT
  - greske-katalog
  - journal-cd-brief
  - play-internal-test
ai_sažetak: "FIX-TEL (2026-11-11): plan ispravki poslije prvog playtesta na telefonu (internal test, AAB 1.0.1 code 10). Tri uzroka pokrivaju većinu prijava: (1) u AAB-u nema nijednog sirovog .svg pa Pip skinovi i Nibbs ne postoje, (2) visoki ekran 1080 × 2400 a stranice su rađene za fiksnih 1633 px, (3) dugmad pojedu dodir pa Shop ne skrola. Sadrži /plan prompt za sutra i CD prompt za Journal."
---

# Plan ispravki poslije playtesta na telefonu (FIX-TEL)

> **Status 2026-11-11: urađeno isti dan** — rezultat, otvorene stavke i lista za provjeru na telefonu su u [[telefon-playtest-1111-izvjestaj|telefon-playtest-1111-izvjestaj]].
>
> Roditelj: [[06-production/_index|06-production]] · Stanje: [[CHECKPOINT|CHECKPOINT]] · Napisano 2026-11-11 poslije prijave vlasnika (internal test, AAB 1.0.1, version code 10). Agent ovo **predlaže na početku sljedeće sesije**.

## 1. Zašto telefon ima bugove kojih na kompjuteru nema

Tri uzroka pokrivaju većinu prijava. Prva dva su provjerena u fajlovima, treći u kodu.

| # | Uzrok | Dokaz | Šta kvari |
|---|-------|-------|-----------|
| **U1** | **U buildu nema sirovih `.svg` fajlova.** Pip rig, skinovi (recolor) i Nibbs se grade iz SVG **teksta** (`FileAccess.get_file_as_string`). Godot u export stavlja samo uvezenu `.ctex` teksturu i `.import`; `include_filter` u `export_presets.cfg` ne pomaže za fajl koji ima `.import`. | `unzip -l game/export/android/merge_meadow.aab` → **0** fajlova `.svg` (isto u release APK-u od 27.10. i debug APK-u od 23.10. — u exportu ovo nikad nije radilo). JSON-ovi (`data/pip`, `data/muncher`) jesu unutra. | Stari Pip umjesto novog, nema skinova u Shopu / Ormaru / runu, Nibbs nevidljiv u Areni |
| **U2** | **Visok ekran.** Od 2026-11-10 (`_apply_tall_screen`, aspect expand) viewport na telefonu 20:9 je 1080 × 2400, a stranice huba su crtane za fiksnih 1080 × 1633 (`PAGE_H`). Na kompjuteru je prozor 9:16 pa se ne vidi. | 2400 − 1920 = 480 px = **tačno 20 %** ekrana, koliko je bijela traka na Level Pathu. `UiCamp.section_height()` vraća fiksnu visinu. | Bijela traka na Level Pathu, korpa (inventar) na Homeu nije dolje desno, polje za trejd u Campu ne ide do dna |
| **U3** | **Dugmad pojedu dodir.** `UiClickButton` na dodir odmah pozove `accept_event()` i okine klik na *pritisak*, pa `ScrollContainer` nikad ne vidi povlačenje. `ItemPreview` (prozor skina) radi isto. | `game/scripts/ui/ui_click_button.gd:398`, `game/scripts/ui/shop_buy_button.gd:161`, `game/scripts/ui/item_preview.gd:182` | Shop skrola samo između kartica |

Zato je **prvi korak sutra da kompjuter pokaže isto što i telefon**: igra pokrenuta iz exportovanog paketa (bez sirovih fajlova) u prozoru 1080 × 2400 s dodirom. Bez toga se popravlja naslijepo.

## 2. Sve prijave i gdje je popravak

| # | Prijava | Uzrok / mjesto u kodu | Blok |
|---|---------|------------------------|------|
| 1 | Stare slike Pipa, novih nema | U1 — `game/scripts/visual/pip_assets.gd:75` i `:144`, `game/scripts/visual/ui_pip.gd:362` | A |
| 2 | Skinova nema (Shop, inventar, run) | U1 — isto | A |
| 3 | Nibbs se ne vidi u Areni ni dok spajam | U1 — `game/scripts/camp/muncher_rig.gd:134` | A |
| 4 | Level Path: ~20 % ekrana dolje bijelo | U2 — `game/scripts/ui/level_path_view.gd`, `game/scripts/visual/level_path_kit.gd:18` (`PAGE_H`, `SCROLL_MAX`) | B |
| 5 | Home: inventar gore prema sredini | U2 — `game/scripts/visual/ui_home_field.gd:49`, `game/scripts/ui/field_basket_button.gd`, `game/scripts/ui/season_field.gd` | B |
| 6 | Camp: polje za trejd staje na ~20 % | U2 — `game/scripts/visual/ui_camp.gd:249` (`section_height`), `game/scripts/camp/camp_controller.gd:304` | B |
| 7 | Shop: skrol ne radi preko kartica i dugmadi | U3 | C |
| 8 | Obrub na coinima u headeru neprecizan (i na kompjuteru) | `game/scripts/meta/meta_hub_controller.gd:558` — prsten ima fiksni radius 26 i +12 px, ne prati oblik čipa | C |
| 9 | Arena: sjeme skoči gore lijevo kad ga spustim na par | Sumnja: `game/scripts/camp/arena_seed_chip.gd:259` — `global_position = drag.position − offset`, a `drag.position` je u `_gui_input` **lokalna** koordinata; miš ide drugim putem (`get_global_mouse_position`) pa kompjuter radi. Potvrditi reprodukcijom. | D |
| 10 | Merge runda nema oznaku kraja kad Nibbs sve pojede | `game/scripts/camp/merge_arena_controller.gd:850` (`_end_session_if_settled`) tiho zatvori sesiju | D |
| 11 | Poslije pređenog levela piše „Retry" umjesto „Continue" | `game/scripts/ui/loot_screen.gd:238`, `game/scripts/visual/ui_popups.gd:348` | D |
| 12 | Camp: trejd animacija coina šteka | `game/scripts/camp/camp_trade_bar.gd`, `game/scripts/camp/camp_controller.gd` (hold 10 trejdova / s) | E |
| 13 | Camp: zastarjela ikona u dugmetu „Open meadow" | `game/scripts/camp/camp_controller.gd:297` — to je znak „↗" u tekstu; telefon ga crta svojim fontom | E |
| 14 | Journal šteka pri svakom ulasku | `game/scripts/ui/collection_journal.gd` — na izlasku skrati listu (`on_meta_page_left` → `_trim_groups`), na ulasku gradi iznova; red = ~25 Control čvorova | F |
| 15 | Home šteka pri ulasku (manje) | `game/scripts/ui/main_menu.gd`, `game/scripts/ui/season_stage.gd` (`refresh_for_meta_hub`) | F |

## 3. Prompt za agenta (kopiraj kao poruku sutra)

```
/plan Uradi FIX-TEL po docs/06-production/plan-telefon-playtest-1111.md. Poštuj CLAUDE.md (OpenGL skripte, headless smoke prije "gotovo", Godot GUI jednom na kraju). Redoslijed je bitan: prvo reprodukcija, pa uzroci U1–U3, pa pojedinačni bugovi.

BLOK 0 — Kompjuter kao telefon (prije ijedne ispravke)
1. Napravi skriptu scripts/phone-like-run.ps1: exportuj paket Android preseta (--export-pack) i pokreni igru IZ PAKETA (--main-pack) u prozoru 1080 × 2400 (skalirano), s emulacijom dodira iz miša. Potvrdi da se tada na kompjuteru vide isti bugovi: nema skinova, nema Nibbsa, bijela traka na Level Pathu.
2. Napravi smoke phone_export_smoke koji iz istog paketa provjerava: atlas Pipa i Nibbsa ima teksture, svaki skin iz cosmetics.json daje teksturu, i snimi sliku svih 5 stranica huba + Level Path na 1080 × 2400. Mora PASTI prije ispravki i proći poslije.

BLOK A — Sirovi SVG-ovi u buildu (U1: skinovi, novi Pip, Nibbs)
3. Popravi da tekst SVG-ova stigne u build. Preporuka: generator (tools/ ili scripts/dev) spakuje sve SVG-ove koje kod čita kao tekst u jedan paket (npr. res://data/svg_bundle.json ili .res) koji export uvijek nosi; pip_assets.gd, ui_pip.gd i muncher_rig.gd čitaju iz paketa kad sirovog fajla nema. Generator se zove iz android-export.ps1 prije exporta, pa paket ne može zastariti.
4. Pregledaj cijeli game/scripts za druga čitanja fajlova kao teksta (FileAccess, DirAccess listanje res://) koja u exportu ne rade — popravi sve, ne samo ova tri.
5. Čuvar u android-export.ps1: poslije builda otvori AAB / APK i provjeri da je paket unutra; ako nije, export pada s jasnom porukom.
6. Očisti include_filter u export_presets.cfg od stavki koje ništa ne rade. Unos u greske-katalog.md.

BLOK B — Visok ekran 1080 × 2400 (U2)
7. Level Path: pozadina i put do dna ekrana, bez bijele trake; skrol računa stvarnu visinu.
8. Home: korpa / inventar dolje desno na svakoj visini ekrana; provjeri i ostale plutajuće kontrole (Ormar, Upgrades, Play, hint oblačići s Rect2(…, 1633)).
9. Camp: sekcija stasha i Trade bar se rastežu do dna.
10. Prođi SVE stranice i popupe (Shop, Journal, Arena, run HUD, loot ekran, Settings koji ulazi s y 1920, Ormar) na cijeloj matrici omjera: 16:9 (1080 × 1920), 19,5:9 (1080 × 2340), 20:9 (1080 × 2400), 21:9 (1080 × 2520), tablet 16:10 (1200 × 1920) i tablet 4:3 (1440 × 1920). Visoki ekrani: stranica raste u visinu, kontrole vezane za vrh / dno. Široki ekrani (tableti): igra ostaje portrait stupac 1080 u sredini, s trakama sa strana (stanje 2026-11-11; ukrasne strane su otvorena stavka, vidi izvještaj § 3). Sve mora ostati isto na 1080 × 1920.
10a. Odluka vlasnika 2026-11-11: igra mora biti prilagodljiva svim telefonima i tabletima — nijedna mjera ne smije zavisiti od jednog modela.

BLOK C — Shop
11. Skrol na dodir preko cijele stranice ispod tabova: kartice, prozori skinova i dugmad za kupovinu. Dugme unutar ScrollContainera okida tap tek na PUŠTANJE i samo ako se prst pomjerio manje od 12 px; povlačenje prosljeđuje skrolu (DragScroll već postoji). Isto pravilo provjeri u Ormaru, Journalu, Campu i Homeu. Dva tapa za kupovinu i hold-to-trade u Campu moraju i dalje raditi.
12. Prsten oko coina u headeru: oblik, radius i debljina iz stvarnog stila čipa, centriran i dok čip pulsira. Koriste ga Shop, Home i Camp.

BLOK D — Arena i run
13. Arena: sjeme koje spustim na par ne smije skočiti gore lijevo. Reprodukuj dodirom u BLOK 0 okruženju; prvo provjeri arena_seed_chip.gd:259 (lokalna vs globalna koordinata dodira). Dodaj smoke s pravim InputEventScreenTouch / ScreenDrag.
14. Kraj merge runde kad Nibbs pojede sve: jasna oznaka kraja (kratak baner + šta je spojeno u rundi) prije povratka na vreću. Koristi postojeće popup dijelove, bez novog dizajna.
15. Loot ekran: poslije PREĐENOG levela dugme piše "Continue" (ide na sljedeći level); "Retry" ostaje kad level nije pređen i u Endlessu.

BLOK E — Camp
16. Trejd animacija coina (od dugmeta do čipa gore lijevo) bez štekanja i kad držim dugme: izmjeri, pa ograniči broj coina u letu / koristi pool, bez novog čvora i tweena po trejdu.
17. "Open meadow ↗" i "Merge in Arena ↗": strelica kao SVG ikona iz assets/ui/chrome, ne znak u tekstu. Nađi i ostale specijalne znakove u tekstu dugmadi (↗ ✓ ★ − ‹) i provjeri da su u fontu igre.

BLOK F — Štekanje Journala i Homea (vlasniku VEOMA bitno)
18. Prvo izmjeri u BLOK 0 okruženju i na telefonu (debug build, zapis najdužih frejmova pri promjeni stranice u user://). Bez brojeva nema ispravke. Ponovi mjerenje poslije BLOKA A — nedostajući atlas možda sam pravi dio zastoja.
19. Journal: ne ruši i ne gradi listu pri svakom ulasku — izgrađeni redovi ostaju, osvježi se samo ono što se promijenilo. Sezone kao harmonika: aktivna otvorena, ostale samo zaglavlje, redovi se grade tek na tap. Red kao jedan čvor s vlastitim crtanjem umjesto ~25 Control čvorova. Teksture se učitavaju u pozadini.
20. Home: ulazak ne gradi ništa što već postoji; ostatak po važnosti (prvo polje i Play, pa kartice, pa ukrasi) uz kratko pojavljivanje.
21. Cilj: promjena stranice na telefonu bez frejma dužeg od 33 ms, ni prvi put ni deseti. Ako Journal i poslije ovoga ne prolazi → CD redizajn (§ 5 plana), ne dalje krpljenje.

BLOK G — Novi build
22. GUT + smoke-all + phone_export_smoke zeleni. Version code 11, novi AAB, provjera sadržaja AAB-a.
23. Izvještaj docs/06-production/telefon-playtest-1111-izvjestaj.md na bosanskom: šta je bilo, šta je popravljeno, šta vlasnik provjerava na telefonu (lista po ekranima). Ažuriraj CHECKPOINT i changelog.
```

## 3a. Kapija prije svakog uploada (BLOK H — zahtjev vlasnika 2026-11-11)

Nove verzije će izlaziti često, pa nijedan AAB ne ide na Play dok ne prođe **jedna skripta**: `scripts/release-check.ps1`. Ona pravi AAB i pada na prvoj grešci; upload ide samo kad na kraju piše `RELEASE OK`.

| # | Provjera | Koju grešku hvata |
|---|----------|-------------------|
| 1 | `sync-svg-src.ps1` + `svg_source_smoke` | SVG tekst fali ili je zastario (U1) |
| 2 | GUT + `smoke-all.ps1` iz projekta | Obične regresije logike |
| 3 | Export paketa, pa **smoke testovi pokrenuti IZ PAKETA** (`phone-like-run.ps1 -Smoke …`) | Sve što radi u editoru a ne u buildu: fajl koji nije u exportu, čitanje sirovih fajlova |
| 4 | `screen-matrix.ps1` + `screen_layout_smoke` na 6 omjera (16:9, 19,5:9, 20:9, 21:9, tablet 16:10, tablet 4:3) | Raspored koji radi samo na jednom ekranu (U2) |
| 5 | Dodir: smoke s pravim `InputEventScreenTouch` / `ScreenDrag` (skrol preko dugmadi, drag u Areni) | Stvari koje rade mišem, a ne prstom (U3) |
| 6 | Čuvar sadržaja AAB-a (broj `.svgsrc`, svi `data/*.json`, nema `test/` ni `addons/gut`) | Paket bez potrebnih fajlova |
| 7 | `version/code` veći od zadnjeg uploadanog (zapis u `docs/06-production/play-uploads.md`) | Play odbije upload / zabuna koja je verzija |
| 8 | Lista „provjeri rukom na telefonu" (10 stavki, 5 min) ispisana na kraju | Ono što automat ne vidi |

Pravila uz kapiju:

- **Novi bug s telefona → prvo test koji ga hvata na kompjuteru, pa ispravka.** Ako se bug ne može reprodukovati u `phone-like-run`, popravlja se okruženje, ne nagađa se.
- **Svako čitanje fajla iz `res://` kao teksta ide kroz jedno mjesto** (`SvgSource` za SVG; JSON preko postojećih kataloga) — novi direktni `FileAccess` na `res://` asset hvata lint u koraku 2.
- Svaki upload dobije red u `play-uploads.md`: datum, version code, šta je popravljeno, rezultat kapije.

## 4. Šta treba od vlasnika

- **Model telefona i rezolucija ekrana** (Settings → About phone). Plan pretpostavlja 1080 × 2400.
- Poslije novog builda: upload AAB-a (code 11) na internal test i prolaz po listi iz izvještaja.
- Ništa drugo — sve ostalo agent radi sam.

## 5. Journal i Claude Design

**Preporuka: ne sada.** Štekanje je posao koda (lista se ruši i gradi pri svakom ulasku, red ima previše čvorova), a harmonika po sezonama se može napraviti s postojećim zaglavljem sezone. CD ima smisla tek ako mjerenje poslije BLOKA F ne prođe cilj, ili ako harmonika u igri ne izgleda dobro. Tada šalješ ovaj prompt (prije slanja: commit + push na `master`, CD čita repo samo po tačnim putanjama).

```
Radimo na igri Merge Meadow (Godot 4, portrait 1080 × 1920, telefoni do 1080 × 2400). Repo: master grana, čitaj fajlove po tačnim putanjama ispod.

ZADATAK: redizajn stranice Journal (Bloom Album) tako da bude LAGAN za crtanje na telefonu. Današnji Journal šteka pri ulasku jer odjednom gradi duge liste redova s po tri cvijeta.

PROČITAJ PRVO
- docs/04-experience/design-drafts/journal-cd-brief.md (prvi brief, šta je Journal)
- docs/04-experience/design-drafts/journal-izvjestaj.md (šta je preneseno)
- docs/06-production/plan-telefon-playtest-1111.md (zašto se ovo traži)
- game/scripts/ui/collection_journal.gd, game/scripts/ui/collection_journal_row.gd, game/scripts/visual/ui_journal.gd (današnja izvedba i mjere)
- game/data/seasons/seasons.json (8 sezona, cvijeće po sezoni)

IDEJA VLASNIKA (polazna, smiješ predložiti bolje)
Svaka sezona je svoj red / kartica (harmonika). Zatvorena pokazuje samo ime, boju sezone i napredak (npr. 7 / 13). Na tap se raširi i pokaže cvijeće te sezone. Otvorena je najviše jedna; pri ulasku je otvorena aktivna sezona.

FIKSNO
- Stranica 1080 × 1633 između headera (143) i footera (144); na višim ekranima raste u visinu.
- Sadržaj reda cvijeta ostaje: ime, zvjezdice rijetkosti, tri stepena (sjeme → pupoljak → cvijet), stanje zaključano / otkriveno / NEW.
- Stil igre: ravne boje, radius, rub, jedna tvrda sjena. Bez blura, glowa, gradijenata, maski.
- Font i boje iz game/scripts/visual/ui_palette.gd i ui_journal.gd.

PERFORMANSE (MORA, u README)
- Na ekranu najviše ~12 redova cvijeća odjednom; zatvorena sezona = jedan jeftin crtež.
- Otvaranje sezone: animacija koja se može graditi red po red (redovi ulaze jedan za drugim), ne sve odjednom.
- Bez animacija koje traju dok igrač ništa ne radi, osim NEW oznake.
- Za svaku animaciju navedi trajanje, easing i šta se mijenja (samo pozicija / scale / alpha).

ISPORUKA
- Paket design_handoff_journal_v2: README (mjere u px baze 1080 × 1920, sva stanja, tajminzi), HTML pregled sa svim stanjima živo (zatvoreno, otvoreno, zaključana sezona, NEW, zlatni okvir, prazan album, 1080 × 2400), SVG-ovi bez rgba() i bez crteža van viewBoxa.
- Samoprovjera u README: svaka stavka da / ne.

NE TRAŽIMO: nove cvjetove, promjenu podataka, promjenu headera / footera huba.
```

## Povezano

- [[CHECKPOINT|CHECKPOINT]]
- [[../05-technical/godot/greske-katalog|greske-katalog]]
- [[../04-experience/design-drafts/journal-cd-brief|journal-cd-brief]]
- [[play-internal-test|play-internal-test]]
