---
type: iskustvo
status: aktivan
milestone: M8
tags: [iskustvo, audio, zvuk, muzika, sfx]
povezano:
  - art-direction
  - zvuk-izvjestaj
  - muzika-brief
  - muzika-sezone
  - performanse
ai_sažetak: "Zvuk igre: AudioManager + katalog sounds.json, 59 efekata i 24 sezonske teme (8 sezona × home / arena / run, privremena sinteza do pravog zvuka), mapa događaja, glasnoća po kategoriji, kako se zamijeni pravim zvukom bez izmjene koda."
---

# Audio direction

## Sažetak

Mekan, „cozy" zvuk: drvo, staklo, zvonca, mjehurići, harfa — ništa oštro, metalno ni kazneno. Svaki dodir ima odgovor, nagrade zvone (lanac penje ton kad ih je više zaredom), greške su mekan pad. Muzika je tiha pozadina (lo-fi / akustično), u runu skoro samo ambijent (igra se i u javnom prevozu).

**Stanje 2026-10-14:** sistem je u igri i spojen svuda. Svih 59 efekata i 24 teme (8 sezona × home / arena / run) su **privremeni** — sintetizovani skriptom (`scripts/audio/`). Pravi zvuk ide fajl po fajl, bez izmjene koda (§ Zamjena pravim zvukom). Izvještaj: [[zvuk-izvjestaj|zvuk-izvjestaj]] · brief za muziku: [[design-drafts/muzika-brief|muzika-brief]].

## Kako radi

| Dio | Gdje | Šta radi |
|-----|------|----------|
| `AudioManager` (autoload) | `game/scripts/autoload/audio_manager.gd` | Pool 12 playera za efekte (bus `SFX`), 2 za muziku (bus `Music`, crossfade). Po zvuku: cooldown, najviše glasova, grupa, slučajan pitch, lanac tona. Muzika: pamti mjesto svake teme, duck, pauza za reklamu i kad je app u pozadini. Sve učitava u pozadinskom threadu |
| `Sfx` | `game/scripts/visual/sfx.gd` | Statički ulaz iz bilo koje klase: `Sfx.play(id)`, `Sfx.music(id)`, `Sfx.haptic(ms)`. AudioManager traži u toku igre (ne statički) — greske-katalog #21 |
| Katalog | `game/data/audio/sounds.json` | Svaki zvuk: fajlovi (varijante), kategorija, `db` (pomak do ciljne glasnoće), pitch, cooldown, max, grupa, lanac, duck; `source`: `synth` / `real` |
| Busovi | `game/default_bus_layout.tres` | `Music` i `SFX` → `Master` s limiterom (−1 dB) |
| Settings | `UiSettings.apply` | Music / Sound effects slider + mute na busovima (default 80 / 100), Vibration za haptiku |
| Dugmad | `HubPressable`, `UiClickButton`, `WardrobePressable`, `_Tap` u Settingsu | `tap_sfx` (default `ui_tap`; tabovi `ui_tab`; `""` = tiho kad zvuk daje sama radnja) |
| Pip | `ui_pip.gd` `emit_event` | Događaji `sfx:<x>` iz `data/pip/animations.json` → `pip_<x>`; poziran Pip (`still`) i nevidljiv Pip su tihi |

## Muzika

**Svaka sezona ima svoje tri teme** — `<sezona>_home` (hub i loot ekran), `<sezona>_arena` (stranica Arena), `<sezona>_run` (run) — ukupno 24. Svaka sezona je žanr (svoji instrumenti, ritam melodije, harmonija, tempo, soba): [[muzika-sezone|muzika-sezone]].

| Nivo | Gdje svira | Karakter | Loop | U igri |
|------|-----------|----------|------|--------|
| `home` | hub (Home, Camp, Shop, Album), loot ekran | glavna tema sezone, melodija u prvom planu | 8–32 takta, 30–62 s | ~−25 LUFS |
| `arena` | stranica Arena | razigranije, forma po žanru (jig A + B, pitanje–odgovor, gradnja pa „drop"), home motiv u taktovima 5–8 | 16 taktova, 23–45 s | ~−25 LUFS |
| `run` | run (sve vrste) | skoro ambijent s vlastitim tempom i ritamskim potpisom + okolina sezone, home motiv citiran | 6–16 taktova, 29–37 s | ~−28 LUFS |

- Kod bira samo nivo: `Sfx.music_level("home" | "arena" | "run")`; `AudioManager.play_level` uzme temu **aktivne sezone** (nema li je — Country Bloom).
- Promjena sezone (Home, kupovina, otključavanje, Dev reset): `AudioManager` provjerava `GameState.active_season_id` svakih 0,25 s i sam pretopi na temu nove sezone.
- Prelaz tema: crossfade 0,9 s; svaka tema **nastavlja gdje je stala** (Arena → hub ne kreće ispočetka).
- Duck (muzika se utiša pa vrati): T3 spajanje, kupovina, otključavanje sezone, čišćenje polja, kraj runa, revive.
- Reklama: muzika stoji dok traje (`AdManager` → `Sfx.set_ad_playing`); app u pozadini: stoji.
- Prva tema (home aktivne sezone) se traži u threadu čim se igra upali; ostale kad zatrebaju (stara počne da se gasi odmah, nova uđe frejm-dva kasnije). U memoriji su najviše 4 teme.
- **Generator** (`scripts/audio/`, privremena muzika):
  - `theory.py` — akordi, voicing, mjere, zapis melodije (klizanja, predudari, vezane note, triole), `--lint` harmonije;
  - `instruments.py` — instrumenti, udaraljke i ambijenti;
  - `fx.py` — soba: reverb, eho, chorus, nagib boje, sidechain, zasićenje;
  - `season_songs.py` — kompozicije (+ „feel" izvođenja);
  - `music_gen.py` — aranžman, miks, loop, render;
  - `music_report.py` — koliko su sezone različite: zvuk, `--structure`, `--melody`, `--harmony`.

## Efekti — mapa događaja

Kategorija = ciljna glasnoća (§ Miks). `×N` = varijante fajla; „lanac" = ton se penje dok se ponavlja.

### UI (svuda)

| Zvuk | Kad | Karakter |
|------|-----|----------|
| `ui_tap` | dugme, pločica, kartica (default svakog dugmeta) | kratak drveni „tik" |
| `ui_back` | Back, Close, X | isti tik, niži |
| `ui_tab` | tab (hub footer, Shop, Ormar, Home Free / Premium, Camp stash) | drveni tik + zvonce |
| `ui_swipe` | swipe stranice huba, izbor sezone na Homeu | mekan „whoosh" (tab ga preduhitri — ista grupa `nav`) |
| `ui_open` / `ui_close` | modal, sheet, Settings, Ormar | dvije note harfe gore / dolje + whoosh |
| `ui_toggle_on` / `ui_toggle_off` | prekidač u Settingsu, izbor u korpi | dvije note gore / dolje |
| `ui_slider` | slider glasnoće, na svakih 5 (ton prati vrijednost) | sitan tik |
| `ui_denied` | nema dovoljno, zaključano, nema mjesta | mekan dvostruki „bup", nije kazna |
| `ui_toast` | toast, oblačić tutoriala, cue u Areni | mekan pop |
| `ui_play` | Play (Home), dugme Play u Shopu | uzlazni zvižduk + zvonca |

### Home i ekonomija

| Zvuk | Kad | Karakter |
|------|-----|----------|
| `field_open` / `field_close` | polje sezone se otvori / zatvori | whoosh + dvije note harfe |
| `coin` | coin u runu, prodaja u Campu, combo coin u Areni | „plink" B5 → E6, lanac (700 ms, do +7) |
| `coins_spend` | kupovina za coine (Shop) | zveket + akord zvona |
| `purchase_ok` / `purchase_fail` | kupovina pravim novcem (sve preko `IAPManager` signala), Restore | arpeđo el. klavira + iskre (duck) / dvije silazne note; odbijeno od UI-ja (busy, već tvoje) je tiho |
| `unlock` | otključana sezona (Home, Camp link) | velika fanfara, duck |
| `gift` | dnevni poklon | šuš trake + zvonca |
| `reward_tick` | svaki coin / sjemenka iz nagradnog grma koji uleti u čip | sitan trzaj, lanac (penje se) |
| `wear` | obučen skin / kozmetika (Ormar, Shop) | „šuš" tkanine + zvonce |
| `upgrade` | nadogradnja kupljena | uzlazni arpeđo |

### Arena

| Zvuk | Kad | Karakter |
|------|-----|----------|
| `pour` | tap na korpu — sjemenke se prospu | zrna koja se prorjeđuju + šuš |
| `seed_land` ×3 | svaka sjemenka sleti (najviše 3 odjednom) | sitan „tik" |
| `seed_pick` / `seed_drop` | uzmeš / spustiš sjemenku | kratak „pip" / tup |
| `seed_wobble` | spuštena na krivo mjesto, vrati se | gumeni „boing" |
| `merge` | spajanje T2 | sočan pop, lanac po combou (do +9) |
| `merge_t3` | spajanje T3 | veliko zvono + iskre, duck, haptika 40 ms |
| `crystal_fly` | kristal T3 leti | staklasti sweep |
| `vacuum` | ostatak se usisa | kratki sweep |
| `field_clear` | polje prazno | glissando zvona + iskre, duck |
| `gate_open` | vrata Arene se otvore | dvije note el. klavira + iskre |

### Muncher (Nibbs)

| Zvuk | Kad | Karakter |
|------|-----|----------|
| `muncher_wake` | izađe iz rupe / probudi se | iskoči + cik + zemlja |
| `muncher_awake` | prvo buđenje u sesiji (baner „Muncher's awake!") | trilac + lukavo „njeh" |
| `muncher_chomp` ×2 | svaki zalogaj (dva po sjemenki) | hrskanje |
| `muncher_hmph` | sjemenka mu pobjegne (spojena prije njega) | „hmph" |
| `muncher_freeze` / `muncher_thaw` | T3 ga zaledi / odmrzne se | led se zatvori / puca |
| `muncher_yawn` | polje prazno, zaspi | tihi silazni zijev |

### Pip

`pip_land`, `pip_pop`, `pip_sneeze`, `pip_bonk`, `pip_thump`, `pip_cough`, `pip_blow` — iz događaja animacija (`sfx:land` …). Novi `sfx:<x>` događaj u animaciji traži zvuk `pip_<x>` u katalogu (`audio_smoke` to provjerava).

### Run, loot, Journal

| Zvuk | Kad | Karakter |
|------|-----|----------|
| `run_go` | start runa | uzlazni „go" |
| `lane` | promjena trake | kratak whoosh |
| `run_seed` | sjemenka pokupljena | trzaj + pop, lanac (step 2) |
| `bush` | nagradni grm | šuš lišća + zvonce |
| `run_hit` | udarac u prepreku | mekan „bonk", haptika 60 ms |
| `run_fail` / `run_finish` | kraj runa (pad / cilj) | tri silazne note / fanfara; duck |
| `revive` | revive | uzlazni glissando zvona |
| `loot_reveal` | svaki chip nagrade na kraju runa | zvonce, lanac (step 2) |
| `loot_double` | ×2 nagrada | dupli „plink", haptika |
| `discover` | nov cvijet u Albumu | tri note zvona + iskre |

### Haptika

Uz zvuk, poštuje Settings → Vibration (Android dozvola `VIBRATE` u `export_presets.cfg`): kupovina pravim novcem 35 ms, otključavanje 40, T3 40, cilj runa 40, udarac u runu 60, ×2 loot 30, poklon 30, nadogradnja 25, kupovina za coine 25.

## Miks

| Kategorija | Cilj (najglasnijih 150 ms, K-ponderisano) | Primjeri |
|------------|-------------------------------------------|----------|
| `ui` | −23 dB | tap, tab, slider, seed_land |
| `soft` | −21 dB | denied, Pip, vacuum |
| `game` | −18 dB | merge, coin, pour, muncher |
| `reward` | −16 dB | kupovina, wear, upgrade, revive |
| `big` | −15 dB | unlock, T3, field_clear, cilj runa |

- `db` u katalogu = pomak do cilja (generator ga računa, `--measure` za prave fajlove); ručne korekcije poslije mjerenja miksa iz igre su u `TRIM` (sfx_gen.py).
- Muzika: u katalogu do −24 LUFS (home, arena) / −27 (run), mjereno na mono fajlu; bus Music na default 80 je −3,9 dB, a mono fajl svira na oba kanala (+3 dB stereo), pa u igri ~−25 / −28 LUFS. Snimak miksa iz igre: hub −23…−24, Arena −26,5, run −26 (kratki isječci). Efekti stoje 2–10 dB iznad muzike (momentary), velike nagrade −12…−15.
- Cijeli snimljeni miks (gust, mnogo efekata): −20,3 LUFS, true peak −0,7 dBTP. Za mobilne igre preporuka je ~−18 LUFS za cijeli miks (ASWG) — ako je na telefonu pretiho, digni sve ciljeve (`TARGET` u sfx_gen.py, `TARGET_LUFS` u music_gen.py) za isti broj dB i pokreni oba `--measure`.
- Slider glasnoće (Settings) ima kvadratnu krivu: 80 → −3,9 dB, 50 → −12, 25 → −24 (linearna amplituda je na pola zvučala skoro kao puna).
- Master limiter −1 dB; najglasniji trenutak snimljenog miksa −1,4 dBFS.
- Mobilni zvučnik ne nosi bas ispod ~200 Hz — svaki zvuk mora imati „tijelo" iznad toga (provjeriti na telefonu).

## Zamjena pravim zvukom

**Efekat:**
1. Fajl istog imena u `game/assets/audio/sfx/` — WAV (mono, 44,1 / 48 kHz, 16-bit) ili OGG. Varijante: `seed_land_1.wav`, `seed_land_2.wav` … (i lista `files` u katalogu).
2. U `game/data/audio/sounds.json` za taj id: `"source": "real"` (generator ga više ne dira).
3. `python scripts/audio/sfx_gen.py --measure` — izmjeri sve i upiše `db` (do cilja kategorije).
4. `.\scripts\godot-import.ps1`, pa `audio_smoke`.

**Muzika:** OGG `<sezona>_<nivo>.ogg` u `game/assets/audio/music/` (mora loopati bez šava), `"source": "real"`, pa `python scripts/audio/music_gen.py --measure` i import. Može sezona po sezona. Specifikacija za kompozitora: [[design-drafts/muzika-brief|muzika-brief]].

**Novi zvuk:** red u katalogu (ili funkcija + red u `sfx_gen.py` `SOUNDS`), poziv `Sfx.play("id")` u kodu. `audio_smoke` pada ako zvuk iz kataloga nigdje nije pozvan.

## Izvori i licence

| Šta | Izvor | Licenca |
|-----|-------|---------|
| Efekti (prvi korak) | Kenney — Interface Sounds, UI Audio, Impact Sounds, Digital Audio | CC0 (bez obaveze, ali lijepo u Credits) |
| Efekti (dopuna) | freesound.org — samo CC0; Sonniss GDC paketi | CC0 / royalty-free |
| Muzika | kompozitor (Fiverr / SoundBetter), gotov paket (itch.io, Humble), ili AI (Suno / Udio na plaćenom planu) | ugovor / licenca paketa — komercijalna upotreba u igri, bez Content ID-a |

Licencu svakog pravog fajla zapisati u Settings → Credits i ovdje.

## Otvorena pitanja

- [ ] Prava muzika — izvor (kompozitor / paket / AI): odluka korisnika
- [ ] Pravi efekti (Kenney CC0 kao prvi prolaz) — `source: real` + `--measure`
- [ ] Slušanje na telefonu (zvučnik + slušalice): glasnoća UI-ja, bas, umor od ponavljanja
- [x] Haptika uz zvuk (T3, kupovina, udarac) — 2026-10-14
- [x] Licenca: sinteza je naša (nema obaveza) — 2026-10-14

## Povezano

- [[_index|← Iskustvo]]
- [[zvuk-izvjestaj|zvuk-izvjestaj]]
- [[muzika-sezone|muzika-sezone]]
- [[design-drafts/muzika-brief|muzika-brief]]
- [[art-direction|art-direction]]
- [[../05-technical/performanse|performanse]]
- [[../05-technical/arhitektura|arhitektura]]
