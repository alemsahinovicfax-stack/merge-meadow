# design_handoff_leveli_endless — Leveli koji rastu + Endless

Brief: `docs/04-experience/design-drafts/leveli-endless-cd-brief.md` (repo master). Godot 4.7 · GL Compatibility · artboard 1080 × 1920.
Stil kao Run HUD v2 / Level Path / popupi: ravne boje, ink obrub, jedna tvrda sjena. Bez blura, glowa, gradijenata i maski.

## Šta otvoriti (design/, u pregledaču)
| Fajl | Šta pokazuje | Prekidači |
|---|---|---|
| `LevelBands.dc.html` | A1 pojasevi na Level Pathu (sva stanja kamena), zastavice pojasa, B1 zaključan Endless + tap/toast, B2 trenutak otključavanja 15 → 16, B8 rekord na dugmetu | livada, Pip na 1…20/✓, kadar po pojasu |
| `RunDifficulty.dc.html` | A1 LevelChip s pojasom, A2 najava (pojas 1 i 4, replay), A3 nalet, A4 parovi 3 varijante × 8 livada (live + mreža) | livada, level 1…20, scenarij, usporeno ×4 |
| `LevelFinish.dc.html` | A6 cilj: dolazak + prolaz, svih 8 ciljeva, vrijeme pojave po levelu | livada, level, usporeno ×4 |
| `EndlessHud.dc.html` | B3 HUD (sat, Pace, Best), B4 nova stepenica, B5 novi rekord | livada, Endless 0:00 / 3:00 / 7:00, trenutak, usporeno ×4 |
| `EndlessEnd.dc.html` | B6 R5 Endless (normalno + New best!), B7 pauza bez icon_half | — |
| `ChestReady.dc.html` | C spreman sanduk bez „Claim" (mali + 20), tap → popup, reduce motion | reduce motion, usporeno ×4 |
| `Specs.dc.html` | tabela §4 + pojas + pojava cilja, budžeti, veličine asseta | — |

`le_kit.js` = svi brojevi (§4 prepisano), pojasevi, tajming i SVG crteži; `run_stage.js` = mock run (DOM, samo transform). `ref/` = kopije postojećih asseta (kamenovi, sanduci, singl prepreke, fx) samo za mock.

## § Odlučeno
1. **Pojasevi (A1):** Stroll 1–5 · Jog 6–10 · Dash 11–15 · Sprint 16–20; `band = ceil(level/5)`. Oznaka = boja (mint / butter #FFD56B / #FF9F5A / #F27C8E) **i** 1–4 strelice (nikad samo boja). Pločica 72 × 30 na dnu svakog kamena (sva stanja); kamenovi 5/10/15/20 imaju pločicu 86 × 30 sa zvjezdicom = kraj pojasa = sanduk. Uz prvi kamen pojasa (1/6/11/16) zastavica s imenom; strana se bira tako da ne dira sanduk ni kamen.
2. **LevelChip:** `[zastavica] Level 14 [pločica pojasa]` — visina 128 ostaje, max 464.
3. **Najava (A2):** krem ploča kao R4 baner (h 180) „Level 14 + pločica" i pilula „Dash · 1:42"; za 1,12 s uleti u LevelChip (chip se trzne). Ne blokira swipe. Replay L20: „Replay · 2:00".
4. **Ubrzanje (A3):** nalet bez teksta — 5 krem linija niz šavove/ivice staza, Pip se spljošti (uši), svijet trzne 10 px; 0,42 s. Isto na 900+ px/s (linije su duge 240 px, putuju 900 px).
5. **Parovi (A4):** jedan predmet preko dvije staze s mint zastavicom na strani prolaza. L+S i S+D = isti široki sprite (flip_h); L+D = dva bočna dijela okrenuta ka sredini. Jedan zajednički ovratnik. Sudar ostaje 2 × 64 × 64.
6. **Cilj (A6):** 2 stuba + sezonski luk + mint traka (zajednička). Bez ovratnika/sjene → ne liči na prepreku. Pojava: kad **preostali put** do kraja = 1654 px (y −80 → 1574), integrisano sa stepenicama brzine — formula `1654 / v_kraj` griješi kad stepenica pada u zadnju dionicu (L6: 3,40 vs tačno 3,46 s). Prolaz: traka pukne na dvije polovine, luk poskoči, 10 konfeta, pa postojeći „Time!" + „Nothing lost", zastavica na traci, usporavanje.
7. **Endless dugme (B1/B8):** isto mjesto i veličina. Zaključano = **krem** + prsten napretka (pređeno / 15, mint) + zlatni katanac + „Endless / 9 / 15" — oblikom i bojom drugačije od otključanog **lavanda + prstenovi**. Tap na zaključano: tres + toast „Beat Level 15 to unlock Endless". Rekord sezone = krem pločica ispod dugmeta „🏆 3:12" (Home i Level Path), sakrivena dok rekorda nema. Zamjenjuje `modulate.a .55`.
8. **Otključavanje (B2):** poslije skoka 15 → 16 (jednom po sezoni): katanac zadrhti, karika gore, tijelo iskoči i nestane, krem → lavanda, prstenovi uskoče, prsten fx, oblačić „Endless unlocked!" 2,2 s.
9. **Endless HUD (B3):** LevelChip dva reda u 128 px: prstenovi + sat + pilula „Pace N" (boja po toplini: 0–2 · 3–5 · 6–8 · 9+) / trofej „Best 4:25". Bez trake napretka.
10. **Nova stepenica (B4):** pilula „⇈ Pace 9" ispod chipa 0,92 s + nalet; boja pojasa, 48/900 — čitljivo i kad je staza gusta.
11. **Novi rekord (B5):** jednom po runu, oko LevelChipa (gore lijevo, nikad preko staze ispred Pipa): prsten + trofej + 8 konfeta 0,9 s; red Best → mint „New best!" do kraja.
12. **Kraj Endlessa (B6):** R5: ploča „Endless" (lavanda) / „New best!" (zlatna + pečat), vrijeme 180/900, Pace, „Best 5:28" / „Was 4:25", tray CIJELI plijen s mint pečatom „All yours" (umjesto „Kept half"), Double · Revive (ad) · Retry · To Camp.
13. **Pauza (B7):** „If you quit · all yours" + pun plijen; „Quit to camp" nosi **icon_basket u mint disku** (kao „Nothing lost"), u levelu ostaje icon_half.
14. **Spreman sanduk (C):** bez pilule. Petlja 1,8 s (20: 1,5 s, jače), frejm „peek" (poklopac odškrinut, zlatnici, zrake), sjena odvojena; ravna pločica sadržaja ispod (bez sjene/ruba dugmeta). Reduce motion: zatvoren, miran, iskre stoje.
15. **D (formacije)** nije rađeno (opciono).

## § Performanse (stvarni brojevi iz mocka)
| Stvar | Budžet | Dizajn |
|---|---|---|
| A2 najava | ≤ 1,2 s · ≤ 6 | 1,12 s · 6 čvorova (ploča, tekst, pločica, pilula, disk, tekst) · input slobodan |
| A3 nalet | ≤ 0,5 s · ≤ 8 | 0,42 s · 5 sprite-ova + transform Pipa/Worlda |
| B4 stepenica | ≤ 1 s · ≤ 8 | 0,92 s · 3 (pilula, ikona, tekst) + 5 nalet = 8 |
| B5 rekord | ≤ 1,2 s · ≤ 12 | 0,90 s · 11 |
| B2 otključavanje | ≤ 1,2 s · ≤ 12 | 1,10 s · 9 |
| A4 par | ≤ 2 (+sjena) | široki 1 · bočni 2; ovratnik + sjena zajednički |
| A6 cilj | ≤ 4 + 16 · ≤ 1,2 s | 4 · prolaz 12 · 1,0 s |
| A1 pojasevi | ≤ +8 oblika / sezona | +8 na putu (4 zastavice + 4 natpisa); pločica kamena = 1 statični TextureRect po kamenu (crta se jednom) |
| B3 HUD | tekst ≤ 1/s | sat 1/s, Pace 1/20 s, Best jednom |
| C sanduk | ≤ 4 + 3 iskre | ≤ 2 u kadru, 3 iskre; pos/rot/scale + zamjena frejma |
| Gustina | ništa ne raste | broj fx-a fiksan; parovi = dvije prepreke kao danas |
| SVG novi | ≤ 150 KB | **102,6 KB / 61 fajl** (bands 7,3 · obstacles 38,3 · finish 47,2 · fx 0,6 · endless 3,2 · chest 6,0) |
Ništa se ne crta po frejmu (_draw); svi fx čvorovi su u bazenu (FlyLayer), stvaraju se jednom. FPS mjeriti `run_perf_bench.gd` na L20 i Endless 7:00 prije/poslije.

**C2PA:** alat dodaje `<metadata>` u svaki SVG (~8 KB). Prije commita:
`find design_handoff_leveli_endless -name '*.svg' -exec perl -0pi -e 's/<metadata>.*?<\/metadata>//gs; s/ xmlns:c2pa="[^"]*"//g' {} +`

## § Samoprovjera (§6.3) — provjereno u pregledaču
1. Pojasevi vidljivi na Level Pathu i u LevelChipu; 5/10/15/20 = kraj pojasa (★) — **da**
2. Najava ≤ 1,2 s (1,12), ne blokira swipe; level, pojas, trajanje iz §4 — **da**
3. Nalet i nova stepenica osjete se i na 900+ px/s (Endless 7:00 = 867 px/s, 8:00+ = 920+), bez crtanja po frejmu — **da**
4. Par: prolaz jasan (mint zastavica + otvoren kraj); 3 varijante × 8 livada; sudar 64 × 64 po stazi — **da**
5. Zaključan Endless jasno drugačiji (krem + katanac + prsten vs lavanda); tap daje poruku; otključavanje je jedan trenutak poslije 15 — **da**
6. Endless HUD: sat, stepenica, rekord; tekst ≤ 1/s; LevelChip ≤ 464, ista visina — **da**
7. Kraj Endlessa: vrijeme, stepenica, rekord, CIJELI plijen; pauza bez icon_half — **da**
8. Svi brojevi u mocku iz §4 (ništa izmišljeno; plijen R5 = 21,5 coina / 8 sjemena po minuti iz balans izvještaja) — **da**
9. Budžeti §5 ispunjeni i zapisani — **da**
10. Bez blura/glowa/gradijenata/maski; čitljivo na svih 8 livada (svijetle i tamne) — **da**
11. Cilj prelazi Pipa tačno na kraju (pojava = 1654 px preostalog puta), ne liči na prepreku, postoji za svih 8 — **da**
12. Spreman sanduk sam privlači pažnju bez „Claim"; samo transform; reduce motion miran — **da**

## Za agenta (§8)
- Pojas: `level_bands.json`; pločica kao dijete checkpointa u `level_path_view`; LevelChip u `UiRun` dobija TextureRect pločice.
- Najava/nalet/stepenica: FlyLayer bazen; okidači `start_run()`, promjena `int(elapsed / RAMP_EVERY)`, `_update_endless_tier()`.
- Par: `_try_spawn` → `obstacle_visual.set_pair(variant, side)`; prvi crta široki sprite, drugi ništa (`obstacle_pairs.json`).
- Cilj: čvor u Worldu kad `remaining_distance() <= 1654` (ne `_spawn_reaches_pip()` po brzini!), pomjera ga `_shift_world`; prolaz u `_play_finish_beat`.
- Endless: `main_menu._refresh_endless_button` + `level_path_view` po `endless_ui.json`; otključavanje u `play_hop` kad `to == 16` i `!endless_seen[season]`.
- HUD: `UiRun.mode_text` → dva reda; `GameState.endless_best_sec(season)`; novi rekord kad `elapsed > best` prvi put.
- Kraj: `loot_screen.gd` grana `is_endless()`; pauza: `run_controller._fill_pause` ikona.
- Sanduk: `level_path_view._animate_ready` po `chest_ready.json`; tap hvata sanduk + pločicu (CHEST_TAP_H).

## Otvoreno
- Iskre sanduka koriste postojeći `ready_spark.svg` iz design_handoff_level_path (nije dupliran).
- Formacije (D) nisu rađene.
