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

## Pravila za animacije (iz ovih popravki)

1. **Ne crtaj iznova ono što se samo pomjera.** Crtež ide u dijete, a animacija mijenja `position` / `scale` / `modulate` (sjemenka u letu, slojevi run pozadine, magnet prsten). `queue_redraw()` svaki frejm je skup kad crtež ima StyleBoxove ili mnogo oblika.
2. **Ne gradi sve u jednom frejmu.** Ono što se pojavljuje redom (sipanje) ostaje skriveno do svog reda, a liste se grade po vremenskom budžetu (Journal).
3. **Mali zaobljeni oblici:** StyleBox `corner_detail` ≤ 10; 16 je nevidljivo bolje, a geometrija je ~1,6×.
4. **O(n²) petlje** (razmicanje, sudari) prekidaj kad prolaz ništa ne promijeni; za daleke parove poredi kvadrat udaljenosti.
5. **Svaki CD paket:** prije „gotovo" izmjeri njegove animacije postojećim benchom (ili dodaj fazu u bench) i zapiši brojeve u izvještaj.

## Plan (još nije urađeno)

- [ ] **Arena, pulsirajući hint:** sjemenka s pulsom crta cijeli crtež svaki frejm (samo zbog alfe prstena). Prsten u zasebno dijete, puls kroz `modulate.a`.
- [ ] **Run, Pip: ~45 draw poziva** (14 AA lukova magneta, sjena, Pip). Isprekidan prsten kao jedna mreža ili tekstura (1 draw poziv).
- [ ] **Run i Arena, HUD: 14–24 draw poziva**, labeli i paneli. Provjeriti batching (isti font i StyleBox).
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
