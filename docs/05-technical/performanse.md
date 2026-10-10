---
status: aktivan
tags: [tehnicko, performanse]
---

# Performanse

## Sažetak

Ciljevi za mid-range Android i iPhone — Godot 2D na slabijem laptopu za dev.

## Ciljevi (v1)

| Metrika | Cilj | Test |
|---------|------|------|
| FPS (gameplay) | 60 (min 30 na starijem) | Android emulator + iPhone |
| RAM | < 150 MB | Godot profiler |
| Cold start | < 3 s | Emulator |
| APK veličina | < 80 MB | Launch build |
| Baterija | Nema beskonačnog loopa u pozadini | Manual |

## Optimizacije (Godot)

- Object pooling za orbs i čestice
- Atlas spriteovi za UI
- OGG umjesto WAV za muziku
- Ograniči `_process` na aktivne nodeove
- Jedan tileset za lane pozadinu

## Mjerenje animacija (benchmarkovi)

Pokretanje BEZ `--headless` (treba renderer), na laptopu s OpenGL-om:

| Šta | Komanda | Mjeri |
|-----|---------|-------|
| Arena | `godot --path game --rendering-driver opengl3 -s res://scripts/dev/arena_perf_bench.gd` (`MM_FRAMES`) | mirno polje, muncher lovi, combo, **sipanje 30 sjemenki**; primitivi i draw pozivi po dijelu |
| Run | `godot --path game --rendering-driver opengl3 -s res://scripts/dev/run_perf_bench.gd` (`MM_SECONDS`, `MM_SEASONS`) | prosjek i najgori frejm po sezoni; pozadina / svijet / Pip / HUD: primitivi, draw pozivi, ms |
| **Cijela igra** | `godot --path game --rendering-driver opengl3 -s res://scripts/dev/perf_suite_bench.gd` (`MM_ONLY=arena,run…`, `MM_ROOT=1`, `MM_VSYNC=1`) | 30 scenarija (hub, swipe, Home, Camp, Journal, Shop, Arena, run, loot): prosjek, p95/p99, najgori, preskočeni frejmovi, draw pozivi, CPU/GPU rendera |
| Run HUD v2 | `godot --path game --rendering-driver opengl3 -s res://scripts/dev/run_hud_perf_bench.gd` | grm u mirovanju i burst |

- **`MM_ROOT=1 MM_VSYNC=1`** = kao igra na laptopu (prozor 540 × 960, 60 Hz): kolona `>20ms` su stvarno preskočeni frejmovi — to je „štekanje". Bez toga (SubViewport 1080 × 1920, vsync off) mjeri se propusnost.
- Sa vsyncom iGPU spušta takt, pa je `gpu` kolona tada viša nego stvarna cijena — GPU porediti bez vsynca.

- **Igra mora biti zatvorena** dok bench radi (dijeli GPU, pa daje lažne skokove od 30–280 ms).
- Bench gasi vsync i `max_fps`, pa je frejm stvarna cijena, ne čekanje na 60 fps.
- Pokreni bar dvaput: prvi prolaz uključuje učitavanje tekstura i keš shadera.
- Budžet: 16,6 ms po frejmu (60 fps) s rezervom za slabiji Android; laptop mora biti ispod ~8 ms.

## Rezultati 2026-10-06 (HP laptop, AMD iGPU, GL Compatibility)

| Mjesto | Prije | Poslije | Šta je urađeno |
|--------|-------|---------|----------------|
| Arena, sipanje 30 sjemenki | prosjek 7,96 ms, **najgori 28,8 ms** | prosjek 6,0 ms, **najgori 14,6 ms** | sjemenka crta u dijete i u letu se pomjera samo dijete (ranije ~30 sjemenki × 5 StyleBoxova crtano iznova svaki frejm); crtež sjemenke skriven dok ne dođe njen red; StyleBox `corner_detail` 16 → 10 (primitivi sjemenki 34 471 → 18 480); razmicanje pri spawnu staje kad ništa ne pomjeri, bez korijena za daleke parove (spawn 9,5 → 3,6 ms) |
| Run, prosjek po sezoni | 4,8–5,8 ms | 3,5–3,8 ms | pozadina u slojevima-djeci nacrtanim jednom, skrol pomjera slojeve (0,6–1,45 → 0,25–0,66 ms); magnet prsten oko Pipa nacrtan jednom, puls je skala (0,9–1,4 → 0,2–0,4 ms) |
| Journal, prvi ulazak | ~740 ms u 8 frejmova | prvi ekran ~76 ms, prve 3 sezone ~160 ms (najgori frejm ~19 ms) | punjenje po 3 sezone, budžet 6 ms po frejmu, dijeljeni StyleBoxovi |

## Rezultati 2026-10-09 — FPS pregled cijele igre (`perf_suite_bench.gd`)

Isti laptop, `MM_ROOT=1 MM_VSYNC=1` (prozor 540 × 960, 60 Hz). „Kasni" = frejm > 20 ms (preskočen vsync). Prije = stanje prije ovih popravki (isti dan).

| Mjesto | Prije | Poslije | Šta je urađeno |
|--------|-------|---------|----------------|
| **Arena, merge** (8 s, merge svakih 0,35 s) | 40 kasnih od 435, 11 > 33 ms; frejm posle mergea 28–46 ms | 1 kasni od 480, 0 > 33 ms; frejm posle mergea 14–15 ms | osnova sjemenke (4–6 AA StyleBoxova ≈ 0,7 ms) iscrtana jednom u teksturu (`ArenaChipBake`, 8 varijanti); prsten pulsa / partnera / mergea u svom sloju (puls = `modulate`); korpa crta samo na promjenu stanja (2–4 ms po mergeu); arena save kroz `save_player_save_soon()` (1,6–3,9 ms van frejma mergea); rasuti elementi livade u svom sloju; muncher u slojevima |
| Arena, skripta jednog mergea | 2–19 ms | 1–1,8 ms | isto |
| Arena + 30 sjemenki, bez vsynca | GPU 2,13 ms · CPU rendera 2,32 ms · 263 draw | GPU 1,63 · CPU 1,59 · 179 draw | isto |
| Muncher u lovu (dodatak po frejmu) | ~1,0 ms | ~0,65 ms | glava je Node2D (transform), gradi se samo na pozu / pogled; tijelo krugovi |
| **Home, kartica sezone bez cvijeća** (Ember Fen) | 1313 draw poziva, 8,1 ms/frejm | 79 draw poziva, 3,3 ms | isprekidan rub jednim `draw_multiline` (bio AA `draw_polyline` po crtici) |
| Home, listanje sezona (6 s) | 11 kasnih, 6 > 33 ms | 4 kasna, 2 > 33 ms (samo prvi prikaz sezone) | isto + Ember frejmovi prelaza 25 → 5 ms |
| **Camp, ulaz** | `refresh` 18 ms + 10 ms prvog frejma | 2,3 + 4 ms | grid se gradi samo kad se stavke promijene (potpis) |
| Journal, skrol | 6 kasnih, 2 > 33 ms | 0 | budžet gradnje redova 6 → 3 ms |
| Swipe između stranica | 4 kasna, max 46 ms | 2 kasna, max 33 ms | stranice van ekrana zamrznute (`process_mode`), ostale stranice se učitavaju u pozadinskom threadu i instanciraju kad pager stoji |
| Hub, hladni start | 2,6 s | 2,6 s | isto (sve stranice odjednom bi bilo 3,9–4,7 s — odbačeno) |
| Run, loot, Home polje, Ormar, Shop | 0–2 kasna | 0–1 kasni | već glatki; run: traka napretka bez `clip_children` |

**Ostaje:**
- ~~Prvi prikaz svake sezone na Home kartici: jedan kasni frejm (~25–30 ms)~~ — riješeno 2026-10-10 (cvijeće u pozadini), vidi niže.
- Prvi ulaz na stranicu (hub): ~1 kasni frejm (`refresh_for_meta_hub` + prvo crtanje).
- Mjerenje na telefonu (cilj 60 fps u Areni i runu).

## Rezultati 2026-10-10 — start huba, prvi prikazi, Pip u runu

Isti laptop. Vremenska linija starta huba = frejm po frejm prvih 5 s, koja stranica je dodana kad (`hub_boot_5s` u benchu).

| Mjesto | Prije | Poslije | Šta je urađeno |
|--------|-------|---------|----------------|
| **Start huba, Shop u pozadini** (~1 s posle otvaranja, igrač gleda Home) | jedan frejm **466–498 ms** | frejm dodavanja ~17 ms, pa 4 frejma od 11–18 ms (bez vsynca) | Pip atlasi Shopa (3 skina × ~130 ms rasterizacije SVG-a) u `WorkerThreadPool` (`UiPip.request_atlas`), pregled dobije Pipa kad je atlas gotov; Shop u hubu gradi jednu karticu po frejmu (`_build_steps`), ulaz / tab / getteri dovrše ostatak odmah |
| Shop `_build_looks` | 473 ms | 36 ms | isto |
| Prvi Pip po pogledu (Shop, Ormar, run, Home) | 45–50 ms | ~2 ms | animacija se pretvara iz JSON-a kad se prvi put pusti (bila cijela biblioteka od 75); putanje čvorova keširane |
| **Prvi prikaz sezone na Home kartici** | najgori frejm 47–75 ms | 5–26 ms | cvijeće (tier 3) svih sezona se učitava u pozadini frejm posle starta (`FlowerAssets.prefetch_rosters`), prije Shopa i Arene |
| **Home, swipe sezone** (već viđena sezona, vsync) | prvi frejm prelaza do 31 ms — preko 20 ms u 5 od 8 prelaza | preko 20 ms u 2 od 8 (21–23 ms) | fokus trake i „band" su snimali save na disk 2× po swipeu → `save_player_save_soon()`; livada svake sezone je svoj sloj kartice nacrtan jednom (`HomeV3Card`), swipe samo mijenja vidljivi sloj |
| **Run, Pip** | 45 draw poziva (14 AA lukova magneta ≈ 3 poziva svaki) | 4 | isprekidan prsten = jedna mreža trouglova s mekim rubom (`_draw_dash_ring`); cijeli run frejm 73 → 32 draw poziva |

**Bench posle svih izmjena** (`MM_ROOT=1 MM_VSYNC=1`, laptop bez drugog opterećenja): `hub_boot_5s` 7–11 kasnih od ~290 (najgori 37–55 ms, nema više frejma od pola sekunde); `home_season_cards` 3 kasna (bilo 5–7); `arena_merges` 0–1; `run_play` 37–39 draw poziva (bilo 76–82); ostali scenariji 0–3 kasna, osim prvog ulaza u Journal (7) i swipea stranica (8) — naizmjenični A/B bez vsynca (stara / nova kartica) daje isti ili bolji prosjek (swipe 4,3–4,6 vs 4,5–5,2 ms), pa je to šum laptopa. Dva prolaza dok je drugi program trošio ~46 % procesora dala su 5–25 kasnih i u scenama koje se nisu mijenjale (run, loot) — mjeri na mirnom laptopu.

## Pravila za animacije (iz ovih popravki)

1. **Ne crtaj iznova ono što se samo pomjera.** Crtež ide u dijete, a animacija mijenja `position` / `scale` / `modulate` (sjemenka u letu, slojevi run pozadine, magnet prsten). `queue_redraw()` svaki frejm je skup kad crtež ima StyleBoxove ili mnogo oblika.
2. **Ne gradi sve u jednom frejmu.** Ono što se pojavljuje redom (sipanje) ostaje skriveno do svog reda, a liste se grade po vremenskom budžetu (Journal).
3. **Mali zaobljeni oblici:** StyleBox `corner_detail` ≤ 10; 16 je nevidljivo bolje, a geometrija je ~1,6×.
4. **O(n²) petlje** (razmicanje, sudari) prekidaj kad prolaz ništa ne promijeni; za daleke parove poredi kvadrat udaljenosti.
5. **Svaki CD paket:** prije „gotovo" izmjeri njegove animacije postojećim benchom (ili dodaj fazu u bench) i zapiši brojeve u izvještaj.
6. **Statičan crtež od mnogo AA oblika → tekstura jednom** (`ArenaChipBake`): `draw_style_box` sa zaobljenim AA StyleBoxom je ~0,15 ms CPU po pozivu.
7. **Mnogo crtica / linija → jedan `draw_multiline`**, ne `draw_line` / `draw_polyline` po komadu (svaki AA poziv je draw poziv).
8. **Ne radi na disku u frejmu interakcije:** save iz čestih događaja ide kroz `save_player_save_soon()`.
9. **Refresh bez promjene ne gradi UI iznova** — usporedi potpis podataka (Camp grid, korpa u Areni).
10. **Stranice van ekrana ne smiju vrtjeti `_process`** — hub ih zamrzava; nova stranica s petljom to ne treba rješavati sama.
11. **Stranica koja se gradi u pozadini ne smije sve u jednom frejmu** — dok je igrač na drugoj stranici, i 100 ms je vidljiv zastoj. Gradi po komad u frejmu (Shop `_build_steps`), a teško (rasterizacija SVG-a) u thread.
12. **Red pozadinskog učitavanja je FIFO** (`greske-katalog.md` #30): ono što UI uskoro crta traži prije velikih scena; `load_threaded_get` čeka sve ispred.
13. **Isprekidan krug / luk = jedna mreža trouglova** (`RenderingServer.canvas_item_add_triangle_array`), ne AA luk po crtici; `draw_multiline` s poluprozirnom bojom daje pruge na spojevima.

## Plan (još nije urađeno)

- [x] **Arena, pulsirajući hint:** prsten je zaseban sloj, puls kroz `modulate.a` (2026-10-09).
- [x] **Run, Pip: ~45 draw poziva** → 4 (2026-10-10, prsten kao jedna mreža).
- [x] **Run HUD: 10–14 draw poziva**, 0,25–0,5 ms (provjereno 2026-10-10) — dobitak od spajanja bi bio ispod 0,2 ms, ostavljeno. Arena HUD nije posebno mjeren.
- [ ] **Arena, prvo dodavanje u hubu:** frejm boota ~32 ms (korpa ~12 ms, prvi crteži) + frejm prvog rendera ~23 ms, jednom po pokretanju dok je igrač na Homeu.
- [ ] **Mjerenje na uređaju:** Android emulator / telefon, cilj 60 fps u sipanju i runu. Laptop nije mjerodavan za GPU telefona.

## Slab laptop (dev)

- Zatvori druge aplikacije pri exportu
- Koristi **debug** build za iteracije
- Release export samo za test distribuciju

## Otvorena pitanja

- [ ] Min spec uređaj za službeni test (npr. Android API 24)

## Povezano

- [[engine-odluka|engine-odluka]]
- [[platforme|platforme]]
