---
type: meta
status: aktivan
milestone: "—"
tags: [claude-design, test, pipeline, performanse, izvjestaj]
povezano:
  - cd-capability-test-brief
  - cd_response
  - merge-arena-cd-brief
  - greske-katalog
ai_sažetak: "Izvještaj Claude Codea za korisnika o CD capability testu: šta je CD isporučio, šta je provjera pokazala (glTF ✅, .tscn ✅, SurfaceTool mesh obrnut, CD-ove hipoteze o performansama netačne), glavni nalaz (pulsiranje arena chipova = 10 fps na emulatoru) i odluke koje čekaju korisnika."
---

# CD capability test — izvještaj

> Roditelj: [[04-experience/_index|04-experience]] · brief: [[cd-capability-test-brief]] · odgovor za CD: [[cd_response]] (+ `cd_response.json`)
> Datum: 2026-09-16 · Ništa nije commitano.

## Ukratko

1. **CD je bio iskren i uglavnom tačan.** Sve što je označio kao „nisam mogao provjeriti“ je stvarno imalo grešaka, a ono što je označio ✅ je prošlo. To je najvažnija osobina za ovakav rad.
2. **Godot fajlovi rade.** 3D model iz `.gltf` i `.obj` učitao se ispravno (408 trouglova, tačna visina i origin), a `.tscn` scena bez ijedne greške. Tri stvari ipak ne bi prošle u igri: model napravljen kodom (`seed_bag_mesh.gd`) bi u Godotu bio **iznutra-van**, boje u glTF-u su izblijedjele, a toast ima dupli razmak i znak ✦ koji font nema.
3. **Njegove pretpostavke o performansama su netačne**, ali je mjerenje otkrilo pravi problem u igri. Sjene i broj animacija ne koštaju ništa mjerljivo. Kad povučeš chip, a na polju je još 29 istog tipa, oni pulsiraju tako da se svaki frejm cijeli ponovo crta: **na emulatoru igra pada na 10 fps** (inače 49), a na laptopu na 84 (inače 490).
4. **CD-ova tvrdnja „Godot kod nije na GitHubu“ je netačna**: kod jeste na remoteu. Iza nje se krije stvarni rizik: **sav rad od Arene naovamo nije commitan** (50 izmijenjenih fajlova, 40 novih skripti, 80 novih asseta), pa nema backupa.
5. Paket je u sandboxu (`game/_cd_sandbox/`, `docs/_cd_sandbox/`) i ne dira igru; svi smoke testovi prolaze kao i prije.

## Šta sam uradio

| # | Korak | Rezultat |
|---|---|---|
| 1 | Pročitao sve fajlove iz zipa, uključujući `install.ps1` | skripta je bezbjedna (samo kopira, ne briše, nema mreže) |
| 2 | `install.ps1` dry-run | plan: 25 fajlova, 0 preskočenih |
| 3 | `install.ps1 -Apply` | **blokirao ga je Claude Code sigurnosni sistem** (pokretanje tuđe skripte), pa sam istih 25 fajlova kopirao ručno |
| 4 | Godot import + nezavisna provjera modela Python parserom | glTF validan; OBJ: 3 bezopasna upozorenja |
| 5 | Headless provjera: model, toast, sprite sheet, timing | `game/_cd_sandbox/_cc_verify/cd_verify_smoke.gd` |
| 6 | Popravljena kopija CD-ovog benchmarka + 2 scenarija s **pravim chipovima iz igre** | original netaknut, izmjene označene `CC-FIX` |
| 7 | Benchmark na laptopu (jedino GUI pokretanje Godota) | ~3 min |
| 8 | Benchmark na emulatoru Pixel_4_API33 | APK izvezen s privremeno promijenjenom glavnom scenom; `project.godot` odmah vraćen i provjeren hashom |
| 9 | Pune smoke testove | 43/47, isto kao prije (3 poznata lažna pada + stari `shop_nav_smoke`) |
| 10 | Odgovor za CD u njegovom formatu | `cd_response.md` + `cd_response.json` |

## Ocjena po zadatku

| Zadatak | CD je rekao | Provjera | Ocjena |
|---|---|---|---|
| **T0** inventar alata | zna šta ima, a šta nema | tačno | ✅ |
| **T1** 3D vreća | ⚠️ glTF provjeren u three.js | glTF i OBJ **rade u Godotu**. Model iz koda (`.gd`) ima obrnut redoslijed vrhova, pa bi bio prozirna vreća. Tu grešku je CD ispravio za three.js, ali Godot koristi suprotnu konvenciju. glTF boje su izblijedjele (sRGB upisan kao linearni) | ⚠️ tačno označeno |
| **T2** `.tscn` toast | ⚠️ format neprovjeren | scena se učitava **bez ijedne greške**, i bez `uid`. Godot pri ponovnom snimanju mijenja samo 3 reda. Skripta radi (nestaje za ~0,86 s), ali ima dupli razmak u tekstu, ✦ nije u fontu, a širina je fiksna pa se duža imena ne uklapaju | ✅ scena / ⚠️ skripta |
| **T3** animacija | ✅ | sheet je 2048×256 i proziran, ali je **zadnji frejm prazan**, a brzina (25 fps = 0,32 s) ne odgovara njegovoj tabeli (680 ms). Pisao je za staru Arenu: u kodu T3 trenutak traje 0,74 s i leti u brojač u HUD-u | ⚠️ (rekao ✅) |
| **T4** mehanika + detalj | ✅ | promišljeno, s brojkama i samokritikom. „Dew Pair“ se oslanja na premisu „uvijek ostane neparno sjeme“, a Arena već vakuumira ostatke nazad u vreću (ARENA-03). „Pogled“ se preklapa s postojećim wobble efektom | ✅ kao dizajn, ⚠️ premisa |
| **T5** performanse | ⚠️ bez mjerenja | budžet i Low FX su lijepo razrađeni, ali **obje glavne hipoteze pale su na mjerenju**. U benchmark skici je 6 logičkih grešaka (npr. bljesak iz S4 curi u S5, nedostaje S1b) | ⚠️ |
| **T6** protokol | ✅ | HANDOFF/REPORT/TEMPLATE su odlični i ovo mi je bio najlakši handoff do sada. Jedina mana: installer šalje model na mjesto gdje ga 3D preview ne nalazi | ✅ |

## Najvažniji nalazi

### 1. Pulsiranje chipova u Areni je stvarni performance problem (za igru, ne za CD)

| scenario | laptop fps (p95) | emulator fps (p95) |
|---|---|---|
| 30 pravih chipova, mirno | 490 (2,1 ms) | 49 (21 ms) |
| 30 pravih chipova, 29 pulsira | **84 (13 ms)** | **10 (108 ms)** |

Kad držiš chip, svi chipovi istog tipa+tiera pulsiraju. Svaki od njih tada **svaki frejm ponovo crta cijeli sebe**: sjenu, rim, well, prsten (s novim StyleBoxom svaki put) i cvijet. Na početku igre polje je puno clovera, pa je ovo **normalna situacija**, ne rijedak slučaj. Emulator nije pravi telefon, ali je pad 5× na obje mašine.

**Preporuka:** popravak je u kodu Arene i ne treba novi dizajn. Pulse prsten treba crtati kao poseban lagani sloj koji ne tjera cijeli chip da se ponovo crta. Za to sam pripremio poseban task (dugme u Claude Code) da ne miješam s ovim testom.

### 2. Nije commitano ni pushano

CD je mislio da Godot kod nije na GitHubu, a jeste: `origin/master` ima 284 skripte. Zato ne vidi `ui_arena.gd` i brief ovog testa: oboje je samo lokalno. Na remoteu Arena i dalje ima stare brojke (kod 40/100/130, doc 24/120/48). **Ako laptop crkne, gubiš redizajn Arene, hub chrome i Campa.** Commit je tvoja odluka, a CLAUDE.md kaže da commitam samo kad ti kažeš.

### 3. Hipoteze o performansama iz CD-ovog budžeta ne stoje

| CD hipoteza | Mjereno |
|---|---|
| Sjena na chipu je najskuplja stvar | bez mjerljive razlike (laptop 566 vs 552 fps; emulator 50 vs 47, unutar šuma) |
| 30 pulsirajućih tweenova je skupo, budžet ≤ 12 | 30 vs 12: bez razlike |
| Draw calls ≤ 90 je PASS granica | prava Arena ima 122 i nema nikakav trošak od toga |

Low FX koji gasi sjene i ograničava tweenove ne bi riješio ništa. Rješenje je u tački 1.

### 4. Emulator nije mjerilo za „60 fps“

Na emulatoru ni najprostija scena ne prelazi ~52 fps (trošak emulatora). Dobar je za poređenje „prije/poslije“, ali za konačnu odluku treba pravi slabiji Android telefon.

## Kako CD radi kao alat (zaključak testa)

**Jak je u:** dizajnu s brojkama, iskrenom označavanju nesigurnosti, tekstualnim Godot formatima (`.tscn` je bio bajt-tačan) i protokolu predaje.
**Slab je u:** svemu što zavisi od stvarnog ponašanja enginea (winding, boje, font, performanse) i od aktuelnog koda koji ne vidi. Zato je dio T3/T4 pisao za staru Arenu.
**Podjela koja radi:** CD dizajnira i piše spec i skice → Claude Code provjerava, mjeri i vraća brojke. 3D (T1) je za nas slijepa ulica: „3D grafika“ je na OUT listi, a i CD sam preporučuje 2D.

**Predloženi kanal „commit `cd_response.json` + ti kažeš sync“** ima smisla tek kad je rad commitan. Uz to, CD mora potvrditi da uopšte vidi `.gd` fajlove na GitHubu (pitanje CC-01 u odgovoru).

## Odluke koje čekaju tebe

- [ ] **Commit i push necommitanog rada** (Arena, hub chrome, Camp, briefovi, ovaj izvještaj). Preporučujem što prije.
- [ ] **Poslati odgovor CD-u.** Jednostavnije je zalijepiti `cd_response.md` u CD chat. „Sync“ kanal radi tek nakon commita i ako CD vidi te fajlove.
- [ ] **Popraviti pulse performanse u Areni** (task je spreman). Spada u M8 polish/bugfix.
- [ ] **„Dew Pair“ mehanika:** nije u M8 IN scopeu. Odgodi, ili je zapiši u ideje za kasnije.
- [ ] **„Pogled“ detalj:** ~1 h polisha, ali se preklapa s wobble efektom. Da ili ne?
- [ ] **Sandbox foldere** (`game/_cd_sandbox/`, `docs/_cd_sandbox/`) po briefu ne commitati. Kad završiš s CD-om: obrisati ih ili dodati u `.gitignore`?

## Šta je gdje

| Fajl | Šta |
|---|---|
| `docs/04-experience/design-drafts/cd_response.md` / `.json` | odgovor za CD (njegov format) |
| `game/_cd_sandbox/t1_3d … t5_perf/` | CD fajlovi, netaknuti |
| `game/_cd_sandbox/_cc_verify/cd_verify_smoke.gd` | headless provjera paketa |
| `game/_cd_sandbox/_cc_verify/benchmark_arena_cc.gd` / `.tscn` | popravljen benchmark (+ pravi chipovi) |
| `docs/_cd_sandbox/_cc_results/` | CSV rezultati (laptop, emulator) i logovi |
| `docs/05-technical/godot/greske-katalog.md` #14, #15 | SurfaceTool winding; Android ne prima scenu s komandne linije |

**Napomene:**
- Na emulatoru je sada instaliran **benchmark build** pod paketom igre. `scripts/android-launch-game.ps1` instalira `game/merge_meadow_debug.apk`, a to je stari build iz jula; za aktuelnu igru na emulatoru treba novi Android export.
- Umjesto pokretanja igre ovaj put je jedino GUI pokretanje Godota bio benchmark.
