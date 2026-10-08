# Pip — redizajn lika · handoff

Novi Pip, tri skina i sve njegove animacije na svim mjestima u igri. Mehanika, ekonomija, ID-jevi i cijene se ne mijenjaju. Jedan dizajn.

> **Napomena o izvoru.** `docs/04-experience/design-drafts/pip-cd-brief.md` i `pip-ref/` ne postoje na `master` (provjereno 2026-10-07). Mjere su uzete iz koda (`ui_home_v3.gd`, `ui_home_field.gd`, `ui_wardrobe.gd`, `ui_seasons.gd`, `ui_arena.gd`, `ui_arena_v2.gd`, `ui_run.gd`, `player.gd`, `run_controller.gd`, `season_field_pip.gd`, `item_preview.gd`, `cosmetics.json`) i iz briefa u chatu. Samoprovjera §8.3 je rekonstruisana iz tog briefa (13 stavki), jer §8.3 nije bio dostupan.

## Šta otvoriti

- `design/Pip Character Sheet.dc.html`: turnaround (sprijeda, 3/4, profil, odostraga, odozgo) × 3 skina, 24 izraza, test siluete na 64 px, Pip na 88 i 150 px, tokeni, biblija.
- `design/Pip Animations.dc.html`: plejer za **svih 77 animacija** (scrub, 0,25–1×, skin, reduce_motion, brzina svijeta za run, trake ključeva, događaji). Prop `start` / `skin` / `reduceMotion`.
- `design/Pip In Context.dc.html`: kartica sezone 230, polje 190 sa živim mozgom (behaviors.json, 8 sezona, tap eskalacija, ApplyMoment), Arena 150 s look-at (vuci sjemenku), run odozgo (← →, pickupi, pad → Loot, cilj, revive, HUD 88), Shop Looks kartice 984 × 300, pozornica Ormara 1032 × 300, sličice, Starter Pack, „All set here".
- `design/Pip Specs.dc.html`: rig s pivotima, pokrivenost kolizije 56 × 56, budžeti, dijelovi po pogledu, prelazi, sezone, **živa samoprovjera** (konzola: `SELFCHECK n/13 …`).
- `design/pip_art.js` · `pip_runtime.js` · `pip_anim.js`: jedini izvor. Art (tokeni, dijelovi, rigovi), player (isti model kao Godot: samo transformacije čvorova) + exporter, animacije i ponašanja. Svi JSON / SVG fajlovi su generisani iz njih.
- `assets/pip/parts` (41), `overlays` (5), `fx` (29 FX + rekviziti), `hud` (3 pečena portreta 88).
- `godot/`: `rig.json`, `animations.json`, `behaviors.json`, `skins.json`, `pip_export.json` (mjere, brojevi, provjere), `ui_pip.gd`, `pip_tree.txt` (stablo + gdje se šta mijenja).

## § Biblija lika

**Ko je Pip.** Mladi livadski zec koji čuva polje. Prvo radoznao, onda hrabar, malo dramatičan kad ga bockaš. Sve primijeti: novi cvijet dobije uzdah, leptir kihanje, mjesec dug pogled. Nikad dugo tužan.

**Jezik oblika.** Krugovi i meke kruške. Oštro je samo na tri mjesta: čuperak na čelu (tri pramena), vrhovi krzna na obrazima i pregib presavijenog uha. Ta tri detalja + **presavijen vrh desnog uha** su potpis siluete. Čitaju se i na 64 px.

**Proporcije (okvir 256, stopala na y 240).** Glava 128 × 104 (1,15 × širina tijela), tijelo 108 × 90, uši 0,7 visine glave, lijevo uho cijelo, desno = baza + vrh (odmor 122°). Stopala veća od šapa (zec stoji na stopalima). Oči 22 × 28 na y −47 od vrata, nos i usta na njušci, jedan zub.

**Linija i sjenčenje.** Ink `#2D3436`, 3 px na 256 (2,2 px na 190, 1,3 px na 88 portretu). Flat cel, tri tona po materijalu: `fur` / `fur_sh` (svjetlo gore lijevo, sjena dolje desno) / `fur_lt` (njuška, stomak, rep). Oko: rub irisa + ink + dva odsjaja. Bez gradijenata, blura, glowa, filtera i maski.

**Pokret.** Svaki pokret ima anticipaciju (čučanj prije skoka), squash pri slijetanju, stretch pri odrazu. Uši i presavijeni vrh kasne 1–2 kadra i pređu (overlap / follow-through). Pravi zečji vokabular: hop, binky, flop, thump, periscope, grooming, trzanje nosa.

**Izrazi (24).** neutral, happy, joy, curious, surprised, admire, love, sleepy, asleep, blink, squint, sneeze, dizzy, worried, sad, annoyed, determined, wink, proud, munch, yawn, blow, wish, cross. Izraz = 5 swap kadrova (`eye_L`, `eye_R`, `brow_L`, `brow_R`, `mouth`).

## § Odlučeno

1. **Cutout rig, ne sprite sheet.** 5 pogleda dijele iste ID-jeve čvorova, pa se ista animacija pušta u svakom pogledu (čvor koji ne postoji se preskače). Vrijednosti u animacijama su **delte od odmora**; `ui_pip.gd` ih pri izgradnji pretvara u apsolutne po pogledu.
2. **Prelazi su Godotovi.** Svaki ključ nosi Godot Animation `transition` (1 lin · 0 hold · 0,5 out · 2 in · −2 in-out · 0,33 / 3). Player u pregledaču koristi istu formulu `ease()`, pa je pregled 1:1. Back / elastic se rade dodatnim ključevima, ne krivuljom.
3. **Dva AnimationPlayera, disjunktni kanali.** `Body`: base, najviše jedan loop. `Overlay`: one-shotovi samo na `pip.rotation / scale / position`, `head.rotation`, swapovima i FX-u (lane lean, pickupi, combo hop, HUD). Provjereno u exportu: 0 prekršaja. Look-at je aditivan u `_process` i radi samo dok vučeš sjemenku.
4. **Run galop.** Korak 96 px po 0,24 s. Kontakt faze stopala su **linearne i tačno 400 px/s**, pa `speed_scale = scroll_speed / 400` drži stopala na tlu pri svakoj brzini (+5 % / 15 s).
5. **Prelaz trake.** `player.gd` i dalje pomjera x (0,12 s quad-out). Pip dodaje nagib i squash čiji je vrh na 0,06 s, a smiri se do 0,22 s.
6. **Pad = 0,46 s** (isto kao UiRun beat): udar 0–0,06, prevrtanje unazad 0,06–0,40 (+44 px u svojoj traci, x se ne mijenja), ošamućen. Zadnji kadar se drži i postaje pozadina Loot ekrana (`fail_dizzy` loop: zvjezdice + klimanje glavom). Cilj = 0,62 s: Pip sjedne, glava bliže kameri, uši u stranu.
7. **Odozgo:** zec trči prema vrhu, uši raširene preko boka (silueta), duga zadnja stopala, prednje šape kod brade. Tijelo ∪ glava pokrivaju 99 % uzorka 15 × 15 kolizije 56 × 56 (jedan ugaoni uzorak je na rubu obrisa; Specs).
8. **Skinovi vrijede coina.** Blossom (250): grančica trešnjinog cvijeta na korijenu lijevog uha + rep od pet latica; potpis = okret na mjestu koji prospe 6 latica (1,4 s). Sky (200): uši umočene u oblak + rep oblak; potpis = skok na dva oblačića i lagano spuštanje (1,5 s). Detalj se vidi u **svakom** pogledu (front: grančica / kape; odozgo: grančica na glavi / kape na ušima).
9. **Shop = izlog, ne pokret.** Na Looks kartici Pip stoji u pozi svog skina (`pose_*`, bez loopa); tap pusti potpis i vrati pozu. Ormar: pozornica ima `stage_idle` loop, izbor = `stage_hop` (1,12 / 0,28 s kao danas).
10. **ApplyMoment ostaje u brojevima Ormara.** Kašnjenje 40 ms, skok 1 → 1,18 → 1 / 280 ms, pivot stopala, + krem prsten 90 → 220 / 500 ms (sada je to sprite `fx_ring` koji se skalira, a ne `draw_arc`).
11. **Sezonske interakcije donose rekvizit.** 16 interakcija (2 × 8 sezona), svaka koristi čvorove `prop` / `prop2` / `fx_*` na rigu Pipa. Ne čitaju i ne upravljaju SeasonAmbient česticama.
12. **Sjena je dio riga** (`shadow`, alpha 0,14 polje / 0,22 run) i ostaje na tlu kad Pip skoči.

## § Rig

Stablo: `godot/pip_tree.txt`. Čvor = `[id, parent, rest pos, rest rot, rest scale, z (relativan), sprite | swap frames | overlay]`.

| pogled | okvir | dijelova (najgori skin) | FX / rekvizit čvorova |
|---|---|---|---|
| front | 256 | 19 | 10 |
| three_q | 256 | 21 | 10 |
| side | 256 | 19 | 10 |
| back | 256 | 13 | 10 |
| top (run) | 150 = px igre | 18 | 10 |

Skala po površini: `box / 256` (kartica 230 → 0,898 · polje 190 → 0,742 · Arena 150 → 0,586 · pozornica 0,82 × 300 → 0,96), top = 1:1. HUD 88 = front rig s isjekom glave `[40, 40, 176, 176]`.

## § Animacije

77 animacija, 10 loopova, 14 overlay. Pun spisak s opisom: `Pip Animations.dc.html` ili `godot/animations.json`.

- **Dijeljeno / Home:** idle, card_idle, idle_look, ear_twitch, groom, periscope, flop, binky, sniff, sneeze, thump, yawn, admire, sleep, fall_asleep, wake, hop (0,42 s = PIP_BOB_SEC), tap_giggle → tap_hop → tap_huff → tap_flop, apply, greet, card_jump.
- **Sezone:** cb_butterfly, cb_dandelion · fo_snowflake, fo_shake · lm_firefly, lm_eartip · ac_leafhat, ac_acorn · mw_burrow, mw_moon · ct_bubble, ct_shell · sg_wish, sg_petal · ef_smoke, ef_ember.
- **Arena:** arena_idle (+ look-at), merge_t2, merge_t3, combo_hop (1,18 / 0,28), combo_big (1,26 / 0,36), muncher_wake, muncher_eat, muncher_frozen, new_seeds, need_more_seeds, doze.
- **Run:** run_gallop, lane_left, lane_right, pickup_coin, pickup_seed, pickup_diamond, run_start, fail, fail_dizzy, finish, revive_getup · HUD: hud_idle, hud_go, hud_happy, hud_wow, hud_worried, hud_hit, hud_proud.
- **Shop / Ormar:** pose_classic / _blossom / _sky, sig_classic (1,3), sig_blossom (1,4), sig_sky (1,5), stage_idle, stage_hop.

**reduce_motion** (svaka animacija): `expr` = samo promjena izraza, bez pokreta i FX-a · `damp` = pokret × k, bez FX-a (`keep` čuva stopala galopa da ne klize) · `end` = odmah zadnji kadar (pad, cilj, poze).

## § Ponašanje (`behaviors.json`)

- **Polje 190:** zona stopala (151, 1306, 614, 131), hod = `hop` u profilu 95 px/s (okrenut po smjeru), idle pauza 3–7 s → težinski izbor od 8 varijanti (cooldown za binky / flop / thump), njuškanje cvijeta (< 120 px, 35 %) → kihanje (30 %), novi cvijet → `admire`, spavanje poslije 25 s bez događaja (budi ga tap, apply, promjena sezone, novi cvijet), tap eskalira u prozoru od 3 s, sezonska interakcija svakih 14–28 s s cooldownom po interakciji.
- **Kartica 230:** card_idle · otvori polje → card_jump · povratak → greet.
- **Arena 150:** arena_idle, look-at dok se vuče sjemenka, događaji → animacije, 20 s bez unosa → doze, unos → wake.
- **Run:** run_gallop + `set_scroll_speed()`, događaji → overlay, pad → fail (drži) → fail_dizzy iza Loota, revive → revive_getup. HUD 88 ima vlastiti mapu događaja.
- **Shop:** poza po skinu, tap → potpis, lista stoji mirno. **Ormar:** stage_idle, izbor → stage_hop, sličice = poza.

## § Skinovi (`skins.json`)

| skin | id / cijena | fur · fur_sh · fur_lt | ear_in · cheek · nose · iris | dodaci |
|---|---|---|---|---|
| Classic | — | #A8E6CF · #7CCBAE · #D4F5E4 | #FFCCD5 · #FFB88C · #F2899F · #3E7D69 | — |
| Blossom | pip_blossom · 250 | #FFD3DE · #F2AEC1 · #FFF0F3 | #FF9FB8 · #FF94AE · #E5678A · #8C4560 | ov_sprig, ov_btail |
| Sky | pip_sky · 200 | #C2E2FA · #96C3EC · #EAF5FE | #FFCDD6 · #FFB98D · #F2899E · #3B6A9B | ov_ctip_l, ov_ctip_r, ov_ctail |

Dijelovi su nacrtani u Classic hexovima; skin = `PipAssets.recolor_svg(part, classic → skin)` (isti mehanizam kao danas) + overlay čvorovi. Tijelo skina zadržava pravilo Ormara L(tijelo) ≥ L(#A8E6CF). **Novi skin = jedan zapis**: 7 tokena + `overlays[]` (+ opcionalno `showcase_anim`, `signature_anim`). Overlay = SVG + mjesto po pogledu (`attach`).

## § Performanse

| | vrijednost | limit |
|---|---|---|
| dijelova po pogledu (najgori skin) | 21 (three_q) | ≤ 30 |
| FX / rekvizit čvorova | 10 | ≤ 12 |
| atlas po skinu | 1024 × 810 pri rasteru 2× (1024 × 227 pri 1×) | ≤ 1024 × 1024 |
| SVG ukupno | 60 KB (89 fajlova) | ≤ 250 KB |
| loopova po Pipu | 1 (Body) | 1 |
| redraw po frejmu | 0: samo position / rotation / scale / modulate:a / visible / AtlasTexture swap | 0 |
| cijena po Pipu | ~20 čvorova × ≤ 3 trake + 0–1 overlay; JS proxy (sample + transform) 0,079 ms po ticku u Chromiumu | cilj ≤ 0,3 ms |

Atlas se pravi jednom po skinu (`Image.load_svg_from_string` s recolorom → shelf pack → jedna `ImageTexture`, `AtlasTexture` po dijelu), pri startu ili na `cosmetics_changed`. Na slabijem Androidu raster 1,5× daje 1024 × 435.

## § Šta se briše

- `pip_idle.svg`, `pip_sniff.svg`, `pip_sleep.svg`, `assets/ui/wardrobe/pip_blossom.svg`, `pip_sky.svg` (pečeni rezervni), `PipDraw` kao rezerva za Pipa.
- `PipAssets.get_pose_texture` / `POSE_PATHS`, `UiSeasons.PIP_TEX`, `PIP_BOB_*`, `PIP_SLEEP_SQUASH`, `SLEEP_ZZZ` crtanje u `season_field_pip._draw()` (zzz su sada FX čvorovi u `sleep`).
- `season_field_pip.gd` `_draw()` / `_process` + `queue_redraw` po kadru → `UiPip` dijete; FSM poza (walk / sniff / sleep) → `behaviors.json.field`.
- `pip_visual.gd`: tekstura i `_draw_ground_shadow` → `UiPip` (top); **magnet prsten ostaje**.
- `UiHomeV3.draw_pip`, `PIP_SHADOW_CARD / _FIELD` stylebox sjena → čvor `shadow`.
- `merge_arena_controller` `_pip_react_tween` (scale 1,18) → `combo_hop` / `merge_t2`.
- `item_preview._draw_creature` (Pip grana), `UiWardrobe.tween_field_hop` / `tween_ring` → `apply` animacija.

## § Samoprovjera

Provjereno 2026-10-07 u pregledaču, `design/Pip Specs.dc.html` (sekcija Self-check, mjereno iz podataka i DOM-a), konzola `SELFCHECK`.

1. **da**: 5 pogleda (front, three_q, side, back, top), 24 izraza, silueta 64 px za 15 kombinacija.
2. **da**: 3 skina kao tokeni. Blossom i Sky imaju overlay u svih 5 pogleda i vide se na 88 px.
3. **da**: Classic fur = #A8E6CF (mint).
4. **da**: 77 animacija u plejeru, svaka ima opis i reduce_motion.
5. **da**: Home: kartica idle / skok / pozdrav, hop, 8 idle varijanti, njuškanje + kihanje, divljenje, spavanje, 4 tap reakcije, ApplyMoment, 8 × 2 sezonske interakcije s vlastitim rekvizitom.
6. **da**: Arena: idle, look-at, T2 / T3, combo hop / big (1,18 / 0,28 · 1,26 / 0,36), Muncher wake / eat / frozen, nove sjemenke, need more, doze. Nema x kretanja van kutije.
7. **da**: Run odozgo, stopala 400 px/s linearno, vrh nagiba trake na 0,06 s, pad 0,46 s drži zadnji kadar, cilj 0,62 s, revive, HUD 88, kolizija pokrivena 99 %.
8. **da**: poza i potpis po skinu (1,3 / 1,4 / 1,5 s), stage_idle loop, sličice, Starter Pack, All set here, Shop lista mirna.
9. **da**: SVG dijelovi, rig.json, animations.json (Godot prelazi), behaviors.json, skins.json; novi skin = zapis.
10. **da**: 21 dio / pogled, atlas 1024 × 810, 60 KB SVG, 10 FX čvorova, 1 loop, 0 prekršaja kanala.
11. **da**: 0 gradijenata / filtera / maski / blura u svim spriteovima; ≤ 3 tona krzna po dijelu.
12. **da**: pip_blossom 250, pip_sky 200, 0,12 s, 56 × 56, trake 270 / 540 / 810, y 1574, zona (151, 1306, 614, 131), Arena 150 @ (30, 26).
13. **da**: paket kompletan (13 fajlova provjereno fetchom), zip ispod.

## Otvoreno

- §4 / §5 / §8.3 iz `pip-cd-brief.md` nisu bili dostupni. Ako se format riga razlikuje od ovog, exporter (`Pip.exportAll()`) je jedno mjesto za promjenu.
- `ui_pip.gd` nije pokrenut u Godotu (nema projekta ovdje). Logika je 1:1 s playerom u pregledaču; treba smoke test po uzoru na `run_redesign_smoke.gd`.
- Mochi i Muncher nisu dirani. Camp i Journal koriste `UiPip(front)` bez novih animacija.
