---
type: iskustvo
status: aktivan
milestone: M8
tags: [dizajn, ui, run, hud, grm, traka-napretka, claude-design, izvjestaj]
povezano:
  - run-hud-v2-cd-brief
  - run-cd-brief
  - scope-i-granice
  - CHECKPOINT
  - changelog
ai_sažetak: "Prenos design_handoff_run_hud_v2 u Godot (2026-10-09): header runa u jednom redu (Level · coini · sjemenke · pauza), traka napretka lijevo (sakrivena u Endlessu) i nagradni grm na šavu staza s pravilima iz §7; frame vrijeme isto kao prije, burst grma iz poola. DiamondPop iz paketa je izbačen isti dan zajedno s dijamantima."
---

# Run HUD v2 — izvještaj o prenosu

> Roditelj: [[04-experience/_index|04-experience]] · brief: [[run-hud-v2-cd-brief]] · paket: `design_handoff_run_hud_v2/` · datum: 2026-10-09

## Ukratko

Run ima novi header, traku napretka i nagradni grm, 1:1 po paketu `design_handoff_run_hud_v2/` (Design 1.zip).

- **Header je jedan red na y 60** (visina 128):

  | Čip | x | Sadržaj |
  |---|---|---|
  | LevelChip | 40 | „Level N” 48 px, „Endless · Easy/Normal/Hard” 42 px ili „Practice” u tutorialu; zastavica 38 × 57 kad run ima cilj |
  | CoinChip | 520 | 180 × 128, ikona 52, broj 56 px |
  | SeedChip | 716 | 180 × 128, ikona 52, broj 56 px |
  | Pauza | 912 | 128 × 128 |

  Pip portret, prsten, sekunde, dijamant čip i korpa su obrisani iz scene.
- **Traka napretka lijevo** (x 24–140, y 200–1740):
  - Pip glava (`pip_hud_classic`) u krem krugu 92 se penje od starta (dolje) do zastavice (gore) po `elapsed / trajanje`.
  - Punjenje je mint, a kad ostane manje od 17 % vremena postaje peach. Tako je upozorenje „malo vremena” prešlo sa starog prstena na traku.
  - Na 100 % zastavica se podigne (1,18, −6°, 0,2 s), dobije mint prsten i dolazi „Time!”.
  - **U Endlessu je traka sakrivena** jer nema cilja. U tutorialu se vidi jer tutorial ima stvarno trajanje.
- ~~**Dijamant nema čip.** Na mjestu pickupa iskoči krem pilula „+1”.~~ **Isti dan (2026-10-09) dijamanti su izbačeni iz cijele igre** na tvoj zahtjev: nema pickupa, popa ni walleta (vidi changelog).
- **Nagradni grm** na šavu između staza (x 405 ili 675, 120 × 140, viri 25 px u svaku stazu). Lagano se trese (±5°, 0,9 s). Pokupi se kad Pip **pređe šav** dok je grm u njegovoj visini. Tada lišće pukne, nagrada odleti u čip i čip se kratko poveća.

## Pravila grma (§7 briefa + paket)

| Pravilo | U igri |
|---|---|
| Gdje | Šav 405 ili 675, nasumično |
| Kad | Prvi tek posle 6 s, pa svakih 8–12 s; najviše jedan na ekranu |
| Tutorial run 1 | Nikad |
| Fer | Nema prepreke ±300 px u stazama uz grm. Ako prepreka već stoji uz šav, grm ide na drugi šav ili čeka. Ako bi prepreka pala uz grm, umjesto nje ide običan pickup |
| Pokupi se | Samo prelazom (tijelo Pipa 56 × 56 dotakne hitbox 120 × 160 dok mijenja stazu); u svojoj stazi ga ne dira |
| Magnet | Ignoriše grm |
| Nagrada | 60 % 3–5 coina, 40 % 1–2 sjemena iz bazena sezone |
| Ne važi | Twin Seeds, korpa, magnet. Loot množitelj i cap vreće važe na kraju runa kao za sve |
| Pad | Nikad, grm nije prepreka |
| Endless | Isto kao level mod |

Sjeme iz grma broji se kao jedan pickup u lancu otključavanja, isto kao Twin „+2”.

## Datoteke

- **Novo:**
  - `run_progress_rail.gd`: traka napretka.
 - `reward_bush.gd`: grm, tri dijela + Area2D.
  - `run_bush_fx.gd`: burst i let nagrade (pool).
  - `run_hud_v2_smoke.gd` i `run_hud_perf_bench.gd`: test i benchmark.
- **Promijenjeno:**
  - `run_scene.tscn`: novi TopHud.
  - `run_controller.gd`: header, traka, grm.
  - `ui_run.gd`: konstante v2, bez starih.
  - `player.gd`: grm u `area_entered`.
  - `run_pickup_feed.gd`: toast ispod SeedChipa.
  - `run_pause_button.gd`: r 30, ikona 60.
- **Obrisano:** `run_timer_ring.gd`.
- **Asseti:** 26 SVG u `game/assets/run/bush/` i `game/assets/run/progress/`, ukupno 17,8 KB. Potpisani `<metadata>` blok je skinut, kao kod Camp v3 ikone. Original paketa je u `design_handoff_run_hud_v2/`.
- **Sjena čipova** se sada stvarno crta. `shadow_size 0` u Godotu ne crta sjenu, pa je 1 kao u `UiPopups._hard_shadow`.

## Kako je provjereno

- **Testovi:**
  - `run_hud_v2_smoke.gd` provjerava:
    - pozicije četiri čipa i da obrisani čvorovi ne postoje;
    - da tekst stane u LevelChip;
    - tekst, zastavicu i traku za level, Endless (sva tri nivoa) i tutorial;
    - traku na 0 / 50 / 90 / 100 % (pozicija Pipa, peach, mint prsten, reset);
    - da dijamanata više nema (pickup, pop, wallet, ikona);
    - pravila grma: šavovi, raspon nagrada, 6 s, razmak 8–12, jedan na ekranu, fer pravilo i da ga nema u tutorial runu 1.
  - Pravim prelazom staze test pokupi grm (+5 coina, burst 8–12 spriteova, sve počišćeno za 0,8 s). Magnet od 232 px ga ne vuče.
  - `run_redesign_smoke`, `run_smoke` i `season_run_smoke` su prebačeni na nove čvorove.
  - Cijeli skup: 66 smoke testova prolazi, GUT 44/44.
    - `arena_leftover_b_smoke` je prvo pao jer je tražio staro pravilo „modal samo dugmetom”. Prebačen je na Camp v3 pravilo.
    - Arena, Camp i run testovi su ponovo pušteni posle zadnjih izmjena: 36/36.
- **Snimci** (`run_hud_capture.gd`):
  - level s grmom;
  - Endless · Hard;
  - Starfall Glade sa sjemenkom u grmu;
  - 90 % (peach);
  - burst;
 - tutorial „Practice”.

  Prvi snimak je otkrio grešku koju test nije hvatao: `text_overrun_behavior` je labelu „Level 12” svodio na širinu 0, pa se tekst nije vidio. Popravljeno, a test sada provjerava širinu teksta.

## Performanse (laptop, AMD iGPU, GL Compatibility)

| Mjerenje | Prije (a5adf99) | Poslije |
|---|---|---|
| Run Country Bloom, prosjek frejma | 3,56 ms | 3,58 ms |
| Run Starfall Glade, prosjek frejma | 3,40 ms | 3,34 ms |
| Draw pozivi po frejmu | 83 / 79 | 81 / 81 |
| HUD primitivi | ~2 200–2 600 | ~5 000 (zaobljeni čipovi, traka i sjene; bez uticaja na vrijeme) |

| Animacija (`run_hud_perf_bench.gd`, run pauziran) | Prosjek | Najgori frejm |
|---|---|---|
| Prazno | 3,2 ms | 6,5–6,7 ms |
| Grm u mirovanju (1 Tween loop) | 3,2 ms | 5,6–6,5 ms |
| Burst svakih 0,6 s | 3,3–3,4 ms | 5,7–7,5 ms |
| Burst svakih 0,15 s (restart poola) | 3,4–3,8 ms | 7,2–8,5 ms |

Prva verzija bursta pravila je 11 čvorova u frejmu pickupa, pa je najgori frejm skakao na ~10–12,7 ms. **Popravka:** burst je pool koji se napravi na startu runa. Teksture grma te sezone se tada i učitaju. Skok je nestao. U igri grm dolazi svakih 8–12 s, pa je stvarna cijena zanemariva.

## Odluke koje čekaju tebe

- [ ] **Pip glava na traci je uvijek Classic** (statičan `pip_hud_classic.svg`, bez kape iz Ormara). Rig bi se animirao svaki frejm. Ako želiš kapu i skin, mogu dodati statičan snimak riga jednom po runu.
- [ ] **Prepreka koju blokira grm postaje običan pickup** (coin/sjeme po normalnoj tablici), pa gustina ostaje ista. Alternativa je prazan slot.
- [ ] **Grm u tutorial runu 2 je dozvoljen** (paket isključuje samo run 1).
- [ ] Ideja iz paketa, nije urađena: prvi pokupljeni grm jednom pokaže „Bush bonus!”, ali samo ako playtest pokaže da igrači ne skreću po grm.
