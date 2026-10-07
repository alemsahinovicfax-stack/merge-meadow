---
type: iskustvo
status: aktivan
milestone: "—"
tags: [dizajn, sezone, cvijece, home, shop, arena, run, claude-design, izvjestaj]
povezano:
  - seasons-cd-brief
  - merge-arena-cd-brief
  - home-v3-izvjestaj
  - changelog
  - CHECKPOINT
ai_sažetak: "Izvještaj o prenosu CD paketa design_handoff_seasons (faza 1: Country Bloom + Moonlit Warren) u Godot 2026-10-05: šta je u igri po površini, nalazi, odstupanja od paketa, mjerenja, testovi i odluke koje čekaju korisnika prije faze 2."
---

# Sezone, faza 1: izvještaj o prenosu

> Roditelj: [[04-experience/_index|04-experience]] · brief: [[seasons-cd-brief]] · paket: `design_handoff_seasons/` · datum: 2026-10-05 · popravke poslije prenosa: § Popravke poslije playtesta (isti dan)
> **Faza 2 (svih 8 sezona) je u igri 2026-10-06:** [[seasons-faza2-izvjestaj]]. Otvorene odluke ispod su prenesene tamo, uz objašnjenja.

## Ukratko

**Country Bloom** i **Moonlit Warren** sada izgledaju kao dva stvarna mjesta na svim površinama koje je CD nacrtao, a ne više kao tri trake i tint. Country Bloom je pašnjak s brežuljcima, ogradom na grebenu, pokošenim prugama i balama sijena. Moonlit Warren je noć: veliki mjesec, humke s jazbinama i mahovina s rosom.

- **Novi jedinstveni renderer pozadine** (`SeasonBackdrop`) crta isti recept na polju, na kartici izbora i na Shop kartici, pa se prelaz kartica → polje ne vidi: kadar na u = 0,999 je isti kao na u = 1.
- **36 novih crteža cvijeća** (18 obnovljenih za Country Bloom i 18 novih za Moonlit). Kodom crtani krug za 6 Moonlit tipova je nestao svuda: polje, kartica, Shop, Journal, Camp, Arena i run.
- **Polje živi**: latice na vjetru (CB, 14) i zvijezde koje trepere s mrvicama mjesečine (MW, 18). Pip ima tri poze: hod s poskakivanjem, njušenje uz naklon cvijeta i polen, te spavanje sa „z z z". Novo izraslo mjesto naraste uz mali odskok.
- **Run** ima tlo, stazu, daljinu i blizinu sezone. Prepreke su prave: bala sijena i kapija ograde za CB, humka s jazbinom i oboreno deblo za MW. Kamen s tintom za ove dvije sezone više se ne crta.
- **Arena** je usklađena s poljem: CB dobija pokošene pruge i dvije bale, MW nijanse kita.
- Ostalih 6 sezona izgleda tačno kao prije (trake i tint), dok ne stignu faze 2 i 3.

Slike „poslije" su u `design-drafts/seasons-faza1/` (01–05), a „prije" su i dalje u `seasons-ref/`.

## Status: sezona × površina

| Sezona | Home kartica | Home polje | Shop | Arena | Run | Cvijeće |
|---|---|---|---|---|---|---|
| Country Bloom | ✅ kit | ✅ kit + ambijent + poze | — (besplatna) | ✅ kit | ✅ kit + 2 prepreke | ✅ 18 obnovljeno |
| Moonlit Warren | ✅ kit | ✅ kit + ambijent + poze | ✅ panorama | ✅ kit | ✅ kit + 2 prepreke | ✅ 18 novo |
| Frost · Lantern · Amber | trake (faza 2) | trake | — | Arena v2 | tint | proceduralno |
| Coral · Starfall · Ember | trake (faza 3) | trake | trake | Arena v2 | tint | proceduralno |

## Po zadatku iz briefa (§3)

| # | Zadatak | Presuda | Napomena |
|---|---|---|---|
| 1 | Season Kit za CB i MW | ✅ | `game/data/seasons/seasons_kit.json` = CD-ov `seasons_export.json`, bez izmjena. Nova sezona = novi red podataka. |
| 2 | Cvijeće 36 crteža | ✅ | `game/assets/sprites/flowers/`, uz uvezene `.import` fajlove. Raster je podignut na 256 px (vidi Nalaz 3). |
| 3a | Home kartica | ✅ | Minijatura polja s istim receptom. Imena cvijeća i ime sezone su u boji kita (krem na noći). |
| 3b | Home polje | ✅ | Recept, 13 mjesta iz kita (MW pomjera neka na humke), ambijent, poze, rast cvijeta. |
| 3c | Shop (MW) | ✅ | Panorama 1024 × 356 unutar ruba: mjesec izlazi između imena i dugmeta. Sva stanja dugmeta su ista kao prije. |
| 3d | Arena | ✅ | Recept kita se spaja preko Arene v2 jednom po sezoni (`UiArenaV2.field`). |
| 3e | Run | ✅ | Tlo, materijal staze (CB pruge, MW kamenčići), daljina 0,35×, blizina 1,0×, ambijent i 2 prepreke. Kolizija je i dalje 64 × 64. |
| 4 | Kartica = polje | ✅ | Cvijeće u prelazu stoji na svojoj pruzi (živi u rectu kartice), a na u = 1 su pikseli isti. |
| 5 | Animacije | ✅ | Ambijent je jedna petlja (≤ 18), Pip bob / njušenje / spavanje, naklon i polen, rast. |
| 6 | Samoprovjera | ✅ CD | Rezultati su u CD-ovom README. Ja sam dodatno mjerio perf i provjerio pikselima prelaz i stvarni prikaz u igri. |

## Nalazi

1. **Prepreke su se crtale kao bijeli pravougaonici.** Uzrok je bio `load()` u `_draw()`: teksturu niko nije držao, pa se oslobađala odmah poslije crtanja. Sada je drži statički keš u `obstacle_visual.gd`. Upisano u `greske-katalog.md`.
2. **CD crta cvijeće na polju izrezano** (vidljivi crtež popuni mjesto, dno uz dno), a igra ga je crtala cijelim platnom 256, pa je bilo oko dva puta sitnije. Za sezone s kitom sada je kao u maketi (`SeasonFieldFlower.crop_fill`). Ostale sezone su ostale kakve su bile.
3. **Raster cvijeća je bio 128 px**, a najveće mjesto na polju je 168, Home disk 172, a loot 204. Sitno cvijeće se zato vidno mutilo kad se rastegne. Za 36 crteža kita stavio sam `svg/scale = 2.0` (256 px). Polje je sada oštro, a čipovi u Areni (oko 80 px) nemaju nazubljene ivice. Memorija je oko 9 MB ako je svih 36 učitano odjednom.
4. **Maskiranje uglova**: kartica i Shop kartica crtaju livadu kao mrežu trokuta, pa se zaobljeni uglovi rade maskom u boji stranice, a sjena je „sjena minus tijelo". `clip_children` u GL Compatibility namjerno ne koristim.
5. **Pip zona**: CD-ov `seasons_export.json` ima `pip_zone_feet` širine 778, što bi Pipa pustilo ispod pločice Looks. Ostavio sam postojeću zonu (151, 1306, **614**, 131) iz Ormara.
6. **SVG fajlovi nose C2PA metapodatke** (oko 8 KB base64 po fajlu, „content credentials"). Zato su 9–19,7 KB umjesto CD-ovih ≤ 12 KB. U igri to ne smeta (raster se peče pri importu), ali APK je oko 0,3 MB veći. Nisam ih skidao jer je to oznaka porijekla (vidi Odluke).
7. **Prelaz swipeom između kartica** (0,22 s, alpha 0,4 → 1): dok je kartica providna, slojevi livade se kratko vide jedan kroz drugi. Prije toga su bile tri trake, pa se nije primjećivalo. Popravak bi bio CanvasGroup (dodatni buffer) ili swap bez alphe za kartice s kitom.
8. **`seasons.json` hookovi** (`run_bg_path`, `obstacle_theme_id`) ostali su prazni. Kit se veže direktno po id-u sezone, pa nisu potrebni (mogu se obrisati u fazi 4).
9. **Rast cvijeta** se pamti samo za ovu sesiju igre. Prvo otvaranje polja posle pokretanja ne pušta rast za sve odjednom, nego samo za mjesta koja pređu prag dok igra radi. Ako se igra ugasi između runa i otvaranja polja, rast se ne vidi.

## Popravke poslije playtesta (2026-10-05)

Ti si poslije prvog igranja našao šest stvari. Stanje:

| # | Šta si vidio | Uzrok | Popravka |
|---|---|---|---|
| 1 | Pri biranju sezone na Homeu pozadina kartice ide izvan okvira | Recept kita ide do −2 / 102 / 101 % recta (tlo, rub grebena). Polje to sakrije ivicama stranice, ali kartica nema čime: GL Compatibility na laptopu ne reže crtanje, ni `clip_contents` (izmjereno, `greske-katalog` #24). | `SeasonBackdrop` sada reže geometriju: slojevi u % na [0, 100] jednom pri gradnji, a oblik koji viri preko recta pri crtanju, trokut po trokut. Ništa više ne izlazi iz kartice. Snimke ivica prije i poslije su provjerene. |
| 2 | Isto u Shopu (Moonlit Warren kartica) | Isti uzrok | Ista popravka (isti renderer) |
| 3 | Cvjetovi u runu ne izgledaju isto kao u ostatku igre | Crtež je isti (run, Arena, Journal, Camp, Shop, Home kartica crtaju isti SVG i isti rez). Razlika koju si vidio dolazi iz #4: Camp i Arena su pokazivali Country Bloom sjemenke iz test-vreće, a run je davao Moonlit sjemenke. Jedino su korpa na polju i lista za biranje korpe crtale cijelo platno 256 umjesto reza, pa je cvijet tamo bio sitniji. | Korpa i lista za biranje sada koriste isti rez kao ostatak igre. Svi tierovi svih cvjetova su isti crtež kroz cijelu igru. |
| 4 | Cvijeće iz runa se ne pojavi u Campu ni u Areni | Vreća ima soft cap 40, a tvoja je imala **100** sjemenki od dev skripte `grant_test_seeds_and_flowers.gd` (ona zaobilazi cap). Pravilo „višak se ne prima" je bacilo cijeli plijen bez ikakve poruke. Drugi gubitak: **Retry** na kraju runa nije spuštao plijen u vreću, pa ga je sljedeći run pregazio. | Kraj runa (R5) sada piše „Bag full · X of Y seeds fit" kad vreća ne prima sve (isti ModalNote kao kod poklona). Svjež run (Retry ili Play) prvo spusti neuzeti plijen u vreću. Pravilo kapaciteta je ostalo isto. **Tvoj save i dalje ima 100 / 40 u vreći**: dok to ne smanjiš (potroši u Areni ili traži da ga skratim), nijedno sjeme iz runa neće stati. |
| 5 | Polje sezone se ne osvježi poslije cvijeća iz runa | Polje raste od ★3 cvjetova spojenih u Areni (pragovi 1 / 5 / 10), ne od sjemenki iz runa. Lanac je run → vreća → Arena (spoji do ★3) → polje. Pravi bug: kad je polje ostalo otvoreno, a ti spojio ★3 u Areni i vratio se na Home, polje se nije ponovo čitalo. | Povratak na otvoreno polje sada ponovo pročita ★3 i pusti rast novih mjesta. `season_meadow_smoke` provjerava baš to i bez popravke pada. |
| 6 | Merge Hint ostaje vidljiv u Areni kad završiš spajanje i sesiju | Oslobođena sjemenka je u Godotu 4.7 `== null`, pa je „sakrij" izgledalo kao „isti cilj" i zagrade su ostajale (`greske-katalog` #23). | Hint prati svoje stanje sam, sakrije se kad nestane meta, a na kraju sesije i pri izlasku sa stranice se gasi odmah. `arena_session_end_smoke` provjerava spoj para i kraj sesije. |

Testovi poslije popravki: 57 od 58 smoke testova prolazi. `ui_button_click_smoke` pada na staroj grešci kompajliranja (`SceneRouter` u `--script` modu), koja nije vezana za ove izmjene. Nekoliko starih smoke testova (`season_iap`, `season_unlock`, `season_run`, `save_persistence`, `home_basket_picker`) prepisuje `player_save.json` i ne vraća ga. Save je vraćen iz kopije napravljene prije testova.

## Mjerenja

| Šta | Vrijednost |
|---|---|
| Gradnja mreže polja (jednom po sezoni) | CB 21,6 ms (uključuje prvo čitanje JSON-a), MW 4,6 ms |
| Mreža polja | CB 3 540 verteksa / 3 014 trokuta / 4 dijela (2 linije); MW 1 690 / 1 466 / 3 dijela |
| Tačke jednog kadra prelaza (CPU) | CB 0,23 ms, MW 0,14 ms |
| Ambijent | CB 14, MW 18 čestica, jedan draw poziv po frejmu |
| Arena bench (CB s kitom) | pozadina 3 draw poziva / 4 792 primitiva; čipovi 132 / 42 286. Kit ne utiče na frame. |
| Run | daljina, blizina i kamenčići su statične mreže koje se samo pomjeraju po frejmu |

## Testovi

- Headless start čist. Smoke: `season_meadow`, `season_home`, `home_field_overlay`, `season_run`, `season_unlock`, `season_iap`, `camp_season_link`, `arena_v2_fields`, `arena_feel_a`, `arena_nav_lock`, `shop`, `shop_open`, `shop_nav`, `meta_hub_flow`, `loot_camp_nav`, `save_persistence` — svi prolaze. GUT suite prolazi.
- Jedina greška koja se pojavila (triangulacija maske ugla kad radius pri kraju prelaza padne skoro na nulu) popravljena je: maska ispod 2 px se ne crta.
- `scripts/dev/seasons_capture.gd` sada prima `MM_SEASONS=country_bloom,moonlit_warren` i za sezone s kitom snima kadrove prelaza (u = 0,5 / 0,999 / 1) i Pipove poze.

## Šta je novo u kodu

| Fajl | Šta |
|---|---|
| `scripts/visual/ui_seasons.gd` | Pristup kitu (iz CD-ovog fajla; kontrast sada radi sRGB → linearno kao u JS-u) |
| `scripts/visual/season_backdrop.gd` + `season_backdrop_view.gd` | Recept → mreža jednom; crtanje u bilo kojem rectu; maske uglova |
| `scripts/visual/season_ambient.gd` | Ambijent polja (R2 niz, jedna petlja, fade 0,3 s poslije prelaza) |
| `home_v3_card.gd`, `season_stage.gd`, `home_v3_marks.gd`, `home_v3_card_content.gd` | Kartica crta kit, a stranica, ime i imena cvijeća su u boji kita |
| `season_field.gd`, `season_field_flower.gd`, `season_field_pip.gd`, `pip_assets.gd` | Polje: kit, mjesta u rectu, poze (skin iz Ormara radi i na pozama), naklon, polen, rast |
| `season_pack_card.gd` | Shop panorama |
| `ui_arena_v2.gd`, `arena_meadow_bg.gd` | Spajanje Arena recepta s kitom; oblik `bale` iz kita |
| `lane_background.gd`, `obstacle_visual.gd`, `obstacle.gd` | Run kit, prepreke kita, bez tinta za sezone s kitom |
| `export_presets.cfg` | `pip_sniff.svg` i `pip_sleep.svg` idu u APK kao izvor (recolor skina) |

## Odluke koje čekaju tebe

- [ ] **Odigraj polje CB i MW**: da li su ambijent i Pipove poze u redu po tempu? Da li je cvijeće prave veličine?
- [x] **CD-ovo otvoreno pitanje 2** (2026-10-06: ostaje T3): polje pokazuje T3 (kristal) na svih 13 mjesta. Da li polje treba pokazivati T2, s kristalom samo na kruni?
- [x] **C2PA metapodaci u SVG-ovima** (2026-10-06: ostaju): ostaviti (oznaka porijekla crteža, „content credentials") ili skinuti? Ispravka u fazi 2: ne ulaze u APK (cvijeće ide kao tekstura), samo u repo.
- [ ] **Swipe između kartica** (Nalaz 7): prihvatiti kratko „providno" ili popraviti?
- [x] **Raster 256 px** (2026-10-06: ostaje, mjeri se na uređaju) (Nalaz 3): ostaviti i za faze 2–3 (144 crteža × 256 KB ≈ 37 MB ako je sve učitano) ili praviti 192 px?
- [x] **Prije faze 2**: brief, `seasons-ref/`, `seasons-faza1/`, ovaj izvještaj i paket faze 1 su na `master`. Faza 2 je sada svih 6 preostalih sezona odjednom, prompt je u brief §12.0.
- [ ] **Vreća 100 / 40 u tvom saveu** (od dev skripte): smanjiti je na 40 da run opet puni vreću, ili je potrošiti u Areni?
- [x] **Scope**: sezone su v1.1 track (`scope-i-granice.md`, SEZ-01). Odlučeno 2026-10-06: faza 2 (svih 6 preostalih) ugrađena odmah.

## Povezano

- [[seasons-cd-brief]] — brief (§10 faze, §12 promptovi, §13 red prenosa)
- [[merge-arena-cd-brief]] · [[home-v3-izvjestaj]] · [[../../07-meta/changelog|changelog]] · [[../../06-production/CHECKPOINT|CHECKPOINT]]
