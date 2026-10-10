# design_handoff_run_hud_v2 — Run: header, traka napretka, nagradni grm

Brief: `docs/04-experience/design-drafts/run-hud-v2-cd-brief.md`. Artboard 1080 × 1920.

## Šta otvoriti
- `design/RunScreen.dc.html` — cijeli run. Propovi: `mode` (level / endless / tutorial), `season` (8), `progress` (0–1), `bush` (none / idle / cross / burst / fly / missed), `reward` (coin / seed), `bushSeam` (405 / 675), `level`, `difficulty`, `coins`, `seeds`, `diamondPop`.
- `design/RunHud Specs.dc.html` — sva stanja iz §8.1 + tabela mjera.
- `godot/run_hud_export.json` — tokens, layout, animacije, `bush` pravila, `godot_map`, `decisions`.
- `godot/ui_run.gd` — konstante i helperi (samo izmjene). `godot/run_hud_tree.txt` — stablo + red prenosa.

Pip u runu je u mockupu samo okvir mjesta (crtkani kvadrat); u igri ostaje rig iz `design_handoff_pip/`.

## § Odlučeno
- **Header**: jedan red na y 60 — LevelChip (x 40) · CoinChip (x 520) · SeedChip (x 716) · PauseButton (x 912, 128 × 128).
- **Tutorial run**: slot kaže **„Practice"** sa zastavicom. Igrač zna da je ovo vježba, a traka ima stvaran cilj (45 / 60 s).
- **Endless**: tekst „Endless · Easy/Normal/Hard", **traka napretka sakrivena**. Nema cilja; distanca ili rekord bi tražili podatak koji igra danas nema.
- **Traka lijevo** (x 24–140): pauza je gore desno, desni palac ostaje slobodan; lijevi pojas ne dira kragnu (od x 150).
- **Upozorenje „malo vremena"** ostaje, ali na traci: punjenje mint → peach kad ostane < 17 %.
- **ProgressPip**: glava iz `pip_hud_classic.svg` u krem krugu 92 px.
- **Dijamant**: pop „+1" na mjestu pickupa, 0,5 s; dijamant i dalje ide u wallet.
- **Grm**: pravila iz §7 prihvaćena; dodano `first_after_s: 6` da prvi grm ne padne u početni talas prepreka. Hitbox 120 × 160 ostaje.
- **Nagrada u letu**: najviše 4 sprite-a bez obzira na 3–5 coina; broj u čipu dobije pun iznos.

## § Šta se briše
`CompanionChip` (Pip portret + „Pip"), `BasketBadge`, `PickupBar/DiamondChip`, `TimerChip/Ring`, `TimerChip/Seconds`, i konstante `TIMER_RING_*`, `TIMER_SECONDS_*`, `COMPANION_CHIP_*`, `BASKET_BADGE_*`, `DIAMOND_CHIP_*`. `TimerChip` postaje `LevelChip`.

## § Performanse
- Header: brojevi su `Label`, mijenjaju se samo pri pickupu. Nema crtanja svaki frejm.
- Traka: `ProgressPip` se pomjera samo kroz `position.y`; `RailFill` mijenja `size.y`; boja se mijenja jednom (prag 17 %).
- Grm: **3 dijela** (back, reward, front) + Area2D. Mirovanje = **jedan Tween loop** na korijenu (rotacija ±5°, scale.y 1.04, 0,9 s).
- Burst: **11 spriteova** (prsten + 6 listova + ≤ 4 nagrade) ≤ 12; **0,6 s** ukupno (0,25 burst + 0,35 let).
- Na ekranu najviše **1 grm** (pool 1), DiamondPop pool 1.
- SVG: **26 novih fajlova** (8 × back/front/leaf + zastavica + start). Sam crtež: **17,8 KB ukupno** (≤ 60 KB). Na disku svaki fajl nosi i potpisani `<metadata>` blok porijekla (~7,6 KB po fajlu, ~215 KB ukupno) — Godot ga ignoriše pri importu u teksturu; ako se broje sirovi bajtovi, skinuti ga SVG optimizerom.

## § Samoprovjera (§8.4)
1. Header je jedan red, bez Pip portreta, prstena, sekundi, dijamant čipa i korpe — **da**
2. Radi u level modu, Endlessu i tutorial runu — **da**
3. Pauza 128 × 128; brojevi 56 px; tamni tekst na krem čipu (12,6 : 1) na svim sezonama — **da**
4. Traka x 24–140, širina 116; ne dira staze (od 170), kragnu (od 150) ni pickupe — **da**
5. Traka 0 / 50 / 90 / 100 % i odluka za Endless (sakrivena) — **da**
6. Grm na šavu 405 / 675, 120 široko → viri 25 px u svaku traku; svjetliji od prepreke i trese se — **da**
7. Mirovanje, pokupljen i promašen; 8 sezona — **da**
8. Coin i sjemenka iz grma lete do novih čipova; dijamant ima pop — **da**
9. Budžet iz §8.3 ispunjen i napisan — **da** (crtež 17,8 KB; vidi napomenu o metadata bloku)
10. Nigdje blur, glow ni gradijent — **da** (samo ravne boje i jedna tvrda sjena)

## § Ideje van zadatka
- Prvi pokupljeni grm može jednom pokazati PickupFeed „Bush bonus!" — samo ako testovi pokažu da igrači ne skreću po grm.
