---
type: dizajn
status: zatvoreno
milestone: M8
tags: [dizajn, run, leveli, endless, tezina, balans, sezone, claude-design]
povezano:
  - level-path-cd-brief
  - run-hud-v2-cd-brief
  - run-pickups-cd-brief
  - popups-cd-brief
  - seasons-cd-brief
  - balans-ciklus-1-izvjestaj
  - design-pillars
  - CHECKPOINT
ai_sažetak: "Brief za Claude Design: kako izgleda nova težina — leveli 1–20 svake sezone sve teži (duži, brži, više prepreka i parova, više plijena), Endless bez tajmera koji kreće lagano i stepenicama postaje teži dok Pip ne padne, Endless se otključava poslije levela 15 sezone. CD planira prikaz: oznake težine na Level Pathu, uvod i ubrzanje u runu, par prepreka po sezoni, cilj kroz koji Pip prođe na kraju levela, sanduk koji čeka nagradu (bez pilule Claim), zaključan / otključan Endless, Endless HUD, kraj Endlessa i rekord. Brojeve je agent već ugradio (balans ciklus 1)."
---

# Leveli koji rastu + Endless · Claude Design brief

> **Status 2026-10-21: spremno za slanje** (dopuna poslije playtesta: cilj na kraju levela A6, sanduk na putu C, magnet krug prozirniji). Slike: `leveli-endless-ref/` (e01–e12) + postojeće `level-path-izvjestaj-ref/` (p01–p10). Prompt je u §9.
>
> **Prije slanja: commitaj i pushaj na `master`.** CD čita repo samo po tačnim putanjama s mastera.

Agent je već uradio **brojke i logiku** (balans ciklus 1 — [[../../02-design/balans-ciklus-1-izvjestaj|balans-ciklus-1-izvjestaj]]):

- Leveli 1–20 svake sezone više **nisu iste težine**: svaki je **duži** (60 s → 120 s), **brži** (400 → do ~690 px/s), ima **više prepreka**, od levela 6 dolaze i **parovi** (prepreka u dvije staze odjednom, treća slobodna) — ali donosi i **više plijena**, a rijetko sjeme (★2 / ★3) postaje češće.
- **Endless** više nema tajmer ni Easy / Normal / Hard: kreće lagano i **svakih 20 s** („stepenica") postaje teži — brži, gušći, više prepreka i parova — dok Pip ne udari ili igrač ne izađe. Plijen ostaje **cijeli** (nema „Kept half"). Svaka sezona pamti **rekord** (najduže preživljeno vrijeme).
- **Endless se otključava poslije levela 15** svake sezone (posebno za svaku sezonu) — isti trenutak kad nagrada 15 na Level Pathu postane spremna.
- Sjeme se bira **po rijetkosti** (★1 često, ★2 rjeđe, ★3 rijetko) — ranije je zlatno sjeme padalo jednako često kao ★1.

Poslije prvog playtesta (2026-10-21) agent je još: ugasio spawn pred kraj levela (ranije je ispred Pipa ostajao plijen koji se nije stigao pokupiti — zadnje ~2,5–4 s staza je sad prazna), uklonio pilulu „Claim" ispod spremnog sanduka na putu (dodir je hvatao samo sanduk) i dao sanduku privremeni skok + klimanje, i spustio alfu magnet kruga 0,6 → 0,32 (veći domet = veći krug, previše se vidio).

**Sve to danas radi, ali izgleda privremeno:** težina se nigdje ne vidi prije runa, Endless dugme je samo prigušeno kad je zaključano, čip u Endlessu je običan tekst „Endless · 1:23", a kraj Endlessa je isti Loot ekran s drugim naslovom. **Traži se plan kako sve ovo izgleda** — da igrač osjeti i vidi da leveli rastu, i da Endless bude svoj mod.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | §1–§7 + slike u `leveli-endless-ref/` i `level-path-izvjestaj-ref/` | Šta je danas, šta mora, šta se isporučuje |
| **Ti** | **§9** | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §2, §4, §5, §8 | Brojevi iz koda, prenos, FPS |

## 1. Pravila koja ostaju FIKSNA

| Pravilo | Vrijednost |
|---|---|
| Stil | isti kao run, Run HUD v2, pickupi, Level Path i popupi (`design_handoff_run/`, `design_handoff_run_hud_v2/`, `design_handoff_run_pickups/`, `design_handoff_level_path/`, `design_handoff_popups/`, `design_handoff_seasons/`): flat, pastel, tamni obrub (ink `#2D3436`), ravne boje, jedna tvrda sjena. **Bez blura, glowa, gradijenata i maski** |
| Engine | Godot 4.7, GL Compatibility, slabiji Android, 60 FPS. Artboard 1080 × 1920, sve u px te baze |
| Mehanika runa | 3 staze (centri x 270 / 540 / 810, razmak 270), Pip na y ≈ 1574, prepreka se sudara 64 × 64 po stazi, swipe lijevo / desno. **Ne mijenja se** |
| Brojevi težine i plijena | **fiksni** — tabela u §4 (već u igri, `game/data/run_levels/levels.json`). Dizajn ih prikazuje, ne mijenja |
| Endless pravila | bez tajmera; stepenica svakih **20 s**; plijen ostaje cijeli; otključan poslije levela **15** te sezone; rekord po sezoni |
| Run HUD v2 | jedan red na y 60: LevelChip (200–464 × 128) · CoinChip · SeedChip · Pauza 128; traka napretka lijevo (sakrivena u Endlessu); grm na šavu staza. Raspored ostaje — mijenja se samo sadržaj LevelChipa u Endlessu i ono što tražimo u §3 |
| Level Path | `design_handoff_level_path/` — 20 kamenova, nagrade 5 / 10 / 15 / 20, Pip, donji red **‹ Field · Play · Endless**. Play dugme isto i na istom mjestu |
| Donji red polja / puta | Seasons (ili ‹ Field) 236 × 124 · Play 432 × 140 · **Endless 236 × 124** (ljubičasto, „rings" glif). Mjesto i veličina Endless dugmeta ostaju |
| Sezone | 8 livada (4 besplatne, 4 plaćene), svijetle i tamne — sve što crtaš mora se čitati na svih 8 (≥ 4,5 : 1 za tekst) |
| Pillar 2 | ništa od ovoga se ne kupuje; nema „preskoči level", nema reklame za otključavanje Endlessa. Revive (reklama) ostaje kakav je |
| Magnet krug | tačkice iz `design_handoff_run_pickups/`, alfa **0,32** (bilo 0,6), poluprečnik 40 + 55 × nivo (max 260) — ne mijenja se |
| Kraj levela | run staje tačno na trajanju levela (§4); posljednjih ~2,5–4 s ništa se ne stvara (sve što se stvori stiže do Pipa prije kraja). Postojeći završetak: traka napretka podiže zastavicu, baner „Time!" + „Nothing lost", svijet uspori i stane |

## 2. Danas (slike `e01`–`e12`, `p01`–`p10`)

**Run (`leveli-endless-ref/`):**
- `e01_level01_country_bloom` — level 1 pred kraj: rijetke prepreke (često nijedna u kadru), sporo, grm.
- `e02_level10_frost_orchard` — level 10: češće prepreke.
- `e03_level20_lantern_meadow` — level 20: brzo, gusto, **par** (kamen + lampion u istom redu, jedna staza slobodna); magnet krug već na novoj alfi 0,32.
- `e04_endless_start_amber`, `e05_endless_3min_amber` (par panj + deblo, rupa u sredini), `e06_endless_7min_amber` (dva para jedan iza drugog) — Endless na startu / ~3 min / ~7 min. Čip je privremeni tekst „Endless · m:ss". Na snimkama Pip stoji (bez igrača), pa je plijen mali.
- `e10_pause_endless_amber` — pauza u Endlessu: brojevi su cijeli, ali ikona „Quit to camp" je još „pola".
- `e09_loot_endless` — kraj Endlessa: isti Loot ekran, naslov „Endless · 2:34" (ili „Best! 2:34"), zelena varijanta, bez „Kept half".
- `e11_level_end_frost_orchard` — kraj levela danas: prazna staza ispred Pipa (nema više nedohvatljivog plijena), baner „Time!", zastavica na traci. Nema cilja kroz koji Pip prođe.

**Home (`leveli-endless-ref/`):**
- `e07_field_endless_locked` — polje sezone (Country Bloom, level 7): Endless dugme prigušeno + toast „Finish level 15 to unlock Endless".
- `e08_path_endless_locked` — isto na Level Pathu.
- `e12_path_chest_ready` — Level Path, sanduk 5 čeka nagradu: bez pilule „Claim", privremeni skok + klimanje (snimka je jedan kadar animacije).

**Level Path (`level-path-izvjestaj-ref/`, postojeće):** `p03_path_country_bloom`, `p04_path_moonlit_warren`, `p05_path_starfall_glade` (putevi), `p06_complete_amber_canopy`, `p07_locked_toast`, `p08_reward_popup`.

**Kod:**
- `game/data/run_levels/levels.json` — 20 levela + Endless ključevi (tabela §4).
- `game/scripts/run/run_level_library.gd` — `get_level(n)`, `get_endless_config_at(sec)`, `endless_tier(sec)`, `ENDLESS_TIER_SEC = 20`.
- `game/scripts/run/run_controller.gd` — spawn (parovi: `_try_spawn`, `RunBalance.pair_lane`), brzina (`speed_ramp` svakih 15 s), Endless stepenice (`_update_endless_tier`), čip (`_update_hud`), pauza (`_fill_pause`).
- `game/scripts/run/run_balance.gd` — rijetkost sjemena, par prepreka.
- `game/scripts/run/obstacle_visual.gd`, `game/scripts/visual/ui_run.gd` — izgled prepreka (kamen / panj, sezonska boja), mjere HUD-a, `mode_text`, `endless_clock`.
- `game/scripts/economy/level_path.gd` — `ENDLESS_UNLOCK_LEVEL = 15`, `is_endless_unlocked`, `record_endless` (rekord po sezoni).
- `game/scripts/ui/main_menu.gd` — Endless dugme (`_refresh_endless_button`, `_on_endless_play_pressed`, privremeni toast).
- `game/scripts/ui/loot_screen.gd` — kraj runa (Endless naslov, `is_endless`).
- `game/scripts/ui/level_path_view.gd`, `game/data/level_path/*.json` — Level Path (`_animate_ready` — privremena animacija spremnog sanduka, `_tap` — dodir sanduka i trake ispod njega).
- `game/scripts/run/run_progress_rail.gd`, `game/scripts/ui/popup/run_banner.gd` — traka napretka i baner „Time!" na kraju levela; `run_controller._play_finish_beat`, `_spawn_reaches_pip`.

**Šta fali:** težina se ne vidi (svi kamenovi isti, run počinje bez najave), ubrzanje se ne osjeća, par prepreka je samo dvije obične prepreke, kraj levela nema cilj (run samo stane), spremni sanduk na putu nema svoj „pozovi me" trenutak, Endless nema svoj izgled (zaključan, otključan, HUD, kraj, rekord).

## 3. Šta se traži

### A. Leveli — težina koja se vidi

**A1. Pojasevi težine.** 20 levela podijeli u **4 pojasa** po 5 (1–5, 6–10, 11–15, 16–20) — tvoj prijedlog imena i oznake (npr. „Stroll · Brisk · Wild · Storm", 1–4 listića / trna / plamička). Pojas se vidi:
- na **Level Pathu** — na kamenovima (sva stanja: `done`, `current`, `locked`) i/ili kao trake / natpisi uz put kad se ulazi u novi pojas;
- u **LevelChipu** u runu („Level 14" + oznaka pojasa), bez promjene visine čipa.
- Nagradni kamenovi 5 / 10 / 15 / 20 su kraj pojasa — mogu biti „vrh" pojasa (veći trenutak).

**A2. Najava levela (run start).** Kratka kartica / traka na početku runa (≤ 1,2 s, ne blokira swipe): broj levela, pojas, trajanje (npr. „Level 14 · Wild · 1:42"). Isto i za ponovni level 20 kad je put završen.

**A3. Ubrzanje.** Brzina raste u koracima svakih **15 s** (§4). Prijedlog kako se osjeti bez teksta: kratki „nalet" (linije vjetra uz ivice staze, uši Pipa zalepršaju, lagani trzaj pozadine) ≤ 0,5 s. Mora raditi na 690 px/s i u Endlessu na 900+ px/s.

**A4. Par prepreka.** Od levela 6 prepreka ponekad zatvori **dvije staze u istom redu** (treća uvijek slobodna). Danas su to dvije obične prepreke (kamen + panj). Dizajniraj **izgled para po sezoni** — npr. srušeno deblo preko dvije staze, ograda s rupom, dvije bale, led, lampioni… — tako da se na prvi pogled vidi **gdje je prolaz**. Sudar ostaje 64 × 64 po stazi (dvije prepreke u kodu); crtež može biti jedan širi sprite ili dva povezana. Lijevo-sredina, sredina-desno i lijevo-desno (rupa u sredini) — sve tri varijante.

**A5. (opcionalno) Raznolikost po pojasu.** Ako stigneš: jedna dodatna varijanta obične prepreke po pojasu (npr. pojas 3–4 dobija treći oblik), u Season Kit stilu. Bez nove mehanike.

**A6. Cilj na kraju levela (playtest 2026-10-21).** Run danas samo stane kad istekne vrijeme. Treba **cilj na vrhu staze** koji dolazi prema Pipu i kroz koji Pip **prođe tačno u trenutku kraja** — pa animacija završetka:
- izgled cilja **po sezoni** (npr. kapija od cvijeća, traka koju Pip prekine, zastavice, luk od lampiona, ledena kapija…) preko **sve 3 staze**; ne smije ličiti na prepreku (nema sudara);
- cilj se pojavi na vrhu kad do kraja ostane `1654 px / brzina` (L1 ~3,9 s, L20 ~2,5 s) i putuje istom brzinom kao staza — to je baš onaj prazan dio staze bez spawna;
- trenutak prolaska (≤ 1,2 s): npr. traka pukne / konfeti / Pip skok — i kako se to veže s postojećim „Time!" banerom, zastavicom na traci napretka i usporavanjem svijeta (može ih zamijeniti ili dopuniti; tvoj prijedlog);
- isto i na padu? **Ne** — cilj je samo za uspješan kraj levela. Endless nema cilj.

### B. Endless — svoj mod

**B1. Zaključan Endless.** Dugme Endless (236 × 124, isto mjesto) u polju i na Level Pathu dok level 15 te sezone nije pređen: katanac + „Lv 15" ili napredak („Level 9 / 15") — tvoj prijedlog. Tap → kratka poruka (toast u stilu `design_handoff_popups/`). Mora se razlikovati od dugmeta koje samo „čeka".

**B2. Trenutak otključavanja.** Kad igrač pređe level 15, na Level Pathu se uz skok Pipa i nagradu 15 desi i „Endless unlocked!" — dugme se otključa (animacija na dugmetu, ≤ 1,2 s), možda oblačić / baner. Samo jednom po sezoni.

**B3. Endless HUD.** Umjesto „Endless · 1:23" u LevelChipu: **sat** (preživljeno vrijeme), **stepenica** (npr. „Pace 4" ili 1–N tačkica / plamenova) i **rekord** sezone (npr. mali „Best 3:12" ili oznaka kad ga pređeš). Bez trake napretka (nema cilja). Raspored reda (LevelChip · coin · seed · pauza) ostaje; LevelChip smije biti širok do 464.

**B4. Nova stepenica.** Svakih 20 s: kratak znak da je teže (npr. „Pace 5!" pilula ispod HUD-a ≤ 1 s + mali nalet iz A3). Mora ostati čitljivo i na 7+ minuta (900+ px/s, gusto).

**B5. Novi rekord u runu.** Trenutak kad igrač pređe svoj rekord sezone (jednom po runu, ≤ 1 s, ne pokriva staze ispred Pipa).

**B6. Kraj Endlessa.** Varijanta R5 (Loot ekran, `design_handoff_popups/`) za Endless: preživljeno vrijeme veliko, stepenica do koje je stigao, rekord (i „New best!" pečat), plijen **cijeli** (bez precrtanog i bez „Kept half"). Dugmad: Double (reklama), Revive (reklama — nastavlja Endless), Retry, To Camp — kao danas. Pad i izlazak iz pauze vode u isti ekran.

**B7. Pauza u Endlessu.** R3 (pauza) u Endlessu: „If you quit" pokazuje **cijeli** plijen — ikona dugmeta „Quit to camp" ne smije biti „pola" (`icon_half`); predloži zamjenu.

**B8. Rekord na Homeu.** Gdje igrač vidi rekord sezone van runa — npr. mala oznaka na Endless dugmetu u polju („Best 3:12") ili na Level Pathu. Tvoj prijedlog, bez novih ekrana.

### C. Level Path — sanduk koji čeka nagradu (playtest 2026-10-21)

Pilula „Claim" ispod spremnog sanduka (`reward_ready`) je **izbačena** — izgledala je kao dugme, a nije reagovala. Sad se tapne sam sanduk (ili traka ispod njega) → popup nagrade kao do sad. Treba dizajn **spremnog sanduka koji sam zove**: skakuće, klima se, poklopac se odškrine / zaviri sjaj, iskrice — tvoj prijedlog ritma (npr. skok, doskok, klimanje, pauza ~1,8 s, sanduci u različitoj fazi). Uz to:
- da li se na spremnom sanduku vidi šta je unutra (npr. mali „2 ★3 · 200" kao na zaključanom, ali da ne liči na dugme);
- nagrada 20 (veliki sanduk) živahnija od 5 / 10 / 15;
- `reduce motion`: miran sanduk + iskrice bez pokreta.
Do paketa radi privremena animacija agenta (skok 26 px, squash, klimanje ±8°, ciklus 1,8 s).

### D. (opcionalno) Formacije

Ako stigneš: prijedlog **formacija** po pojasu — mali uzorci koji se slažu na stazu (npr. luk od 5 coina koji vodi kroz rupu para, sjemenka „iza" prepreke, cik-cak prepreka s coinima). Daj ih kao podatke (§6.2 `formations.json`: staza, pomak y u px, vrsta), ali **u okviru brojeva iz §4** (pickupa i prepreka u minuti ± 10 %, uvijek bar jedna slobodna staza u svakom redu, ≥ 400 px između redova koji traže promjenu staze). Agent ih ugrađuje i provjerava simulacijom.

## 4. Podaci (fiksno — već u igri)

**Leveli 1–20** (ista težina u svakoj sezoni; „prolaz", coini i sjeme po prolazu su iz simulacije za prosječnog igrača bez nadogradnji):

| Level | Trajanje | Brzina px/s (start → kraj) | Prepreka / min | Parova | Prolaz (casual · average · skilled) | Coina / prolaz | Sjemena / prolaz | ★3 u sjemenu |
|---|---|---|---|---|---|---|---|---|
| 1 | 1:00 | 400 → 424 | 1.6 | 0 % | 98 · 100 · 100 % | 21 | 7.1 | 3.1 % |
| 2 | 1:04 | 408 → 443 | 2.0 | 0 % | 98 · 99 · 99 % | 22 | 7.6 | 3.3 % |
| 3 | 1:06 | 412 → 449 | 2.3 | 0 % | 97 · 99 · 100 % | 23 | 7.7 | 3.5 % |
| 4 | 1:10 | 420 → 458 | 2.5 | 0 % | 97 · 99 · 100 % | 23 | 8.5 | 3.7 % |
| 5 | 1:12 | 424 → 464 | 3.1 | 0 % | 95 · 98 · 99 % | 25 | 8.9 | 4.0 % |
| 6 | 1:16 | 432 → 486 | 3.6 | 4 % | 96 · 98 · 98 % | 26 | 9.5 | 4.2 % |
| 7 | 1:18 | 436 → 493 | 4.2 | 5 % | 93 · 96 · 98 % | 28 | 9.9 | 4.4 % |
| 8 | 1:22 | 444 → 505 | 5.0 | 7 % | 88 · 97 · 97 % | 29 | 10.7 | 4.6 % |
| 9 | 1:26 | 452 → 514 | 5.6 | 9 % | 88 · 95 · 97 % | 30 | 11.4 | 4.8 % |
| 10 | 1:28 | 456 → 521 | 6.5 | 11 % | 86 · 94 · 96 % | 31 | 11.3 | 5.0 % |
| 11 | 1:32 | 464 → 548 | 7.5 | 12 % | 85 · 91 · 93 % | 33 | 12.2 | 5.0 % |
| 12 | 1:34 | 468 → 556 | 8.7 | 14 % | 78 · 89 · 96 % | 34 | 12.8 | 5.2 % |
| 13 | 1:38 | 476 → 565 | 9.5 | 16 % | 76 · 89 · 95 % | 35 | 13.4 | 5.4 % |
| 14 | 1:42 | 484 → 578 | 10.8 | 18 % | 69 · 82 · 92 % | 36 | 14.4 | 5.6 % |
| 15 | 1:44 | 488 → 586 | 12.2 | 20 % | 62 · 81 · 93 % | 37 | 14.2 | 5.7 % |
| 16 | 1:48 | 496 → 618 | 13.8 | 22 % | 62 · 79 · 88 % | 38 | 15.2 | 5.9 % |
| 17 | 1:50 | 500 → 628 | 15.3 | 24 % | 59 · 74 · 87 % | 39 | 15.8 | 6.1 % |
| 18 | 1:54 | 508 → 638 | 16.7 | 26 % | 53 · 67 · 85 % | 41 | 16.3 | 6.3 % |
| 19 | 1:56 | 512 → 647 | 19.0 | 28 % | 41 · 67 · 80 % | 41 | 16.3 | 6.5 % |
| 20 | 2:00 | 520 → 662 | 20.6 | 30 % | 39 · 61 · 74 % | 42 | 17.5 | 6.7 % |

**Endless** (vrijednosti po stepenici; između ključeva se interpolira, poslije 8 min brzina raste +4 % po stepenici bez kraja; prepreke ≤ 45 %, parovi ≤ 45 %):

| Vrijeme | Stepenica | Brzina px/s | Spawn / min | Prepreke | Parovi | ★3 u sjemenu |
|---|---|---|---|---|---|---|
| 0:00 | 0 | 400 | 32 | 8 % | 0 % | 3.7 % |
| 1:00 | 3 | 460 | 38 | 16 % | 6 % | 4.8 % |
| 2:00 | 6 | 540 | 45 | 24 % | 15 % | 6.2 % |
| 3:00 | 9 | 620 | 53 | 30 % | 24 % | 7.5 % |
| 5:00 | 15 | 760 | 62 | 36 % | 32 % | 9.5 % |
| 8:00 | 24 | 920 | 70 | 40 % | 38 % | 11.1 % |

| | Vrijednost |
|---|---|
| Stepenica Endlessa | svakih 20 s (`ENDLESS_TIER_SEC`) — 0 na startu, 9 na 3:00, 21 na 7:00 |
| Endless prosjek (simulacija) | casual ~3:17, average ~4:25, skilled ~5:28 preživljeno (medijan) |
| Otključavanje | poslije pređenog levela 15 te sezone (Pip na kamenu 16) |
| Rijetkost sjemena | ★1 = 1, ★2 = 0,40 → 0,60, ★3 = 0,12 → 0,30 (težina tipa, level 1 → 20); Endless ★3 0,15 → 0,55 (uvijek rjeđi od ★2) |
| Za mock | Country Bloom level 7 (Endless zaključan), Frost level 16 (upravo otključan), Lantern complete (rekord 3:12), Amber Endless 7:00 stepenica 21 |

## 5. Performanse (MORA, u README)

| | Budžet |
|---|---|
| Najava levela (A2) | ≤ 1,2 s, ≤ 6 sprite-ova, samo transformi; ne blokira input |
| Ubrzanje / nova stepenica (A3, B4) | ≤ 0,5 s / ≤ 1 s, ≤ 8 sprite-ova istovremeno, **bez** crtanja po frejmu (`_draw`) i bez novih čvorova po događaju (bazen) |
| Par prepreka (A4) | ≤ 2 sprite-a po paru (+ sjena), isti broj draw poziva kao danas dvije prepreke ± 1 |
| Endless HUD (B3) | tekst se mijenja **najviše jednom u sekundi**; bez StyleBox / čvorova po frejmu |
| Otključavanje / rekord (B2, B5) | ≤ 1,2 s, ≤ 12 sprite-ova |
| Kraj Endlessa (B6) | u budžetu R5 iz `design_handoff_popups/` |
| Oznake pojasa na putu (A1) | crtaju se jednom s putem (put se ne crta po frejmu) — ≤ +8 oblika po sezoni |
| SVG | ukupno ≤ 150 KB za sve nove assete |
| Gustina | run na levelu 20 i Endless 7:00 mora i dalje 60 FPS na slabom Androidu — **nijedan efekat ne smije rasti s gustinom** (npr. linija po prepreci) |
| Cilj na kraju levela (A6) | ≤ 4 sprite-a za cilj (+ ≤ 16 za trenutak prolaska, ≤ 1,2 s); cilj se kreće kao staza (pozicija), ništa po frejmu |
| Spremni sanduk (C) | samo transformi (pozicija, rotacija, skala, frejm poklopca), ≤ 4 sanduka + 3 iskre svaki istovremeno, kao danas |

U README napiši stvarne brojeve.

## 6. Isporuka

### 6.1 Stanja (sve živo u pregledaču)

- Level Path s oznakama 4 pojasa (bar Country Bloom + jedna tamna sezona), kamen u svakom stanju.
- Run: najava levela (pojas 1 i 4), ubrzanje, par prepreka sve tri varijante × bar 3 sezone (jedna tamna), LevelChip s pojasom, cilj na kraju levela (dolazak + prolazak, bar 3 sezone).
- Level Path: spremni sanduk (mali i veliki 20) u petlji, tap → popup; `reduce motion` varijanta.
- Endless: dugme zaključano / otključano / s rekordom; trenutak otključavanja na putu; HUD (sat, stepenica, rekord), nova stepenica, novi rekord u runu; kraj Endlessa (običan i „New best!"); pauza u Endlessu.
- Prekidači: sezona, level (1…20), Endless vrijeme (0:00 / 3:00 / 7:00), „usporeno ×4".

### 6.2 Paket

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_leveli_endless/
  README.md                 šta otvoriti · § Odlučeno · § Performanse · § Samoprovjera
  design/
    LevelBands.dc.html      Level Path s pojasevima, kamenovi po stanju, 8 sezona
    RunDifficulty.dc.html   najava levela, ubrzanje, parovi prepreka, LevelChip s pojasom
    EndlessHud.dc.html      zaključano / otključavanje / HUD / nova stepenica / rekord
    EndlessEnd.dc.html      kraj Endlessa (R5 varijanta) + pauza (R3 varijanta)
    LevelFinish.dc.html     cilj na kraju levela po sezoni, prolazak Pipa
    ChestReady.dc.html      spremni sanduk na Level Pathu (5 / 10 / 15 i veliki 20)
    Specs.dc.html           mjere, vremena, krive, budžeti
    (formations.dc.html     ako radiš dio D)
  assets/
    bands/*.svg             oznake pojasa (kamen, čip)
    obstacles/*.svg         par po sezoni (3 varijante), dodatne varijante (A5)
    endless/*.svg           katanac / otključavanje, stepenica, rekord, ikona pauze
    fx/*.svg                nalet ubrzanja, pilula stepenice
    finish/*.svg            cilj po sezoni, traka / konfeti prolaska
    chest/*.svg             frejmovi spremnog sanduka (npr. poklopac), sjaj
  godot/
    level_bands.json        pojas po levelu (ime, oznaka, boje po sezoni)
    run_difficulty.json     najava levela, ubrzanje (vremena, krive, sprite-ovi)
    obstacle_pairs.json     par po sezoni: sprite-ovi, sidra, sjena, varijante
    endless_ui.json         dugme (stanja), otključavanje, HUD, stepenica, rekord, kraj, pauza
    level_finish.json       cilj po sezoni (sprite-ovi, širina, sidro), prolazak (vremena, krive)
    chest_ready.json        petlja spremnog sanduka (ključevi transformi, faze, reduce motion)
    (formations.json        ako radiš dio D)
```

### 6.3 Samoprovjera (u README, svaka stavka da / ne, provjereno u pregledaču)

1. 4 pojasa težine se vide na Level Pathu i u LevelChipu; nagradni kamenovi 5 / 10 / 15 / 20 su kraj pojasa.
2. Najava levela ≤ 1,2 s i ne blokira swipe; pokazuje level, pojas i trajanje iz §4.
3. Ubrzanje i nova stepenica se osjete i na 900+ px/s, bez crtanja po frejmu.
4. Par prepreka: na prvi pogled se vidi slobodna staza; sve 3 varijante × 8 sezona; sudar ostaje 64 × 64 po stazi.
5. Zaključan Endless se jasno razlikuje od otključanog; tap daje poruku; otključavanje je jedan trenutak na putu poslije levela 15.
6. Endless HUD: sat, stepenica, rekord — tekst se mijenja ≤ 1 / s; LevelChip ≤ 464 i ne mijenja visinu.
7. Kraj Endlessa pokazuje vrijeme, stepenicu, rekord i CIJELI plijen; pauza u Endlessu nema ikonu „pola".
8. Svi brojevi u mocku su iz §4 (ništa nije izmišljeno).
9. Budžeti iz §5 su ispunjeni i napisani.
10. Nigdje blur, glow, gradijent ni maska; čita se na svih 8 sezona.
11. Cilj na kraju levela prelazi Pipa tačno na kraju (dolazi `1654 / brzina` s prije), ne liči na prepreku, postoji za svih 8 sezona.
12. Spremni sanduk na putu sam privlači pažnju bez pilule „Claim"; animacija samo transformima; `reduce motion` miran.

## 7. Ne tražimo

- Promjenu brojeva težine, plijena, cijena ni pravila Endlessa (to je balans — agent, ciklus 2 po playtestu).
- Promjenu mehanike (3 staze, swipe, sudar 64 × 64, magnet, grm), pickupa (`design_handoff_run_pickups/`) ni Level Path puta (samo dodatne oznake pojasa).
- Nove ekrane, valute, kupovine, reklame ili „preskoči level"; leaderboard (nema servera u v1).
- Zvuk (agent ga veže: `run_go`, `run_finish`, `ui_toast`…).

## 8. Napomena za agenta (prenos)

- **Pojasevi:** `level_bands.json` → `LevelPathKit` / `level_path_view.gd` (kamenovi crtani jednom s putem) + LevelChip u `run_controller._apply_mode`. Pojas = `ceil(level / 5)` ako CD ne odluči drugačije.
- **Najava levela / ubrzanje / stepenica:** novi čvor iz bazena u `FlyLayer`; okidači: `start_run()`, promjena `int(elapsed / RAMP_EVERY)`, `_update_endless_tier()`.
- **Par prepreka:** `_try_spawn` danas zove `_spawn_obstacle_at_lane` dvaput — dodati `set_pair(variant, side)` na `obstacle_visual.gd` (ili jedan širi vizual na prvoj prepreci, druga bez crteža); kolizija ostaje po stazi. Sezonska boja: `apply_season_tint`.
- **Endless dugme:** `main_menu._refresh_endless_button` (danas `modulate.a` 0,55) → stanja iz `endless_ui.json`; trenutak otključavanja na `level_path_view.play_hop` kad `to == ENDLESS_UNLOCK_LEVEL + 1` (jednom po sezoni — dodati „viđeno" u save).
- **HUD / rekord:** `UiRun.mode_text` + `GameState.endless_best_sec(season)`; novi rekord u runu: `elapsed > best` jednom.
- **Kraj / pauza:** `loot_screen.gd` (`is_endless()`, `GameState.last_endless_sec`, `last_endless_new_best`), `run_controller._fill_pause` (ikona dugmeta).
- **Cilj na kraju levela:** novi čvor u `World` kad `_spawn_reaches_pip()` prvi put postane `false` (tad je do kraja tačno put / brzina) — pomjera ga `_shift_world` kao i sve ostalo; trenutak prolaska u `_play_finish_beat` (traka, baner). Endless i pad: bez cilja.
- **Spremni sanduk:** `chest_ready.json` → `level_path_view._animate_ready` (danas privremeni skok + klimanje); dodir već hvata sanduk i traku ispod (`CHEST_TAP_H`).
- **Formacije (ako stignu):** `formations.json` → spawn u `_try_spawn` umjesto pojedinačnog; provjera `economy_sim.gd` (pickupi / prepreke u minuti) i `economy_balance_smoke.gd`.
- **Testovi:** `economy_balance_smoke`, `run_hud_v2_smoke`, `run_redesign_smoke`, `level_path_smoke`, `season_meadow_smoke`; FPS: `run_perf_bench.gd` na levelu 20 i Endless 7:00 prije / poslije (pravilo CD paketa).

## 9. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj na `master`.** Priloži i ovaj `.md` fajl.

```
Nastavak za mobilnu igru Merge Meadow (portrait, flat pastel cartoon, zeko
Pip trči kroz 3 staze u 8 sezona-livada): LEVELI KOJI RASTU + ENDLESS.

Pročitaj po ovim tačnim putanjama (repo, master):
  docs/04-experience/design-drafts/leveli-endless-cd-brief.md
    -> §1 (fiksno), §2 (danas), §3 (šta se traži), §4 (brojevi),
       §5 (performanse), §6 (stanja, paket, samoprovjera)
  docs/04-experience/design-drafts/leveli-endless-ref/:
    e01_level01_country_bloom.jpg   level 1 — rijetko, sporo
    e02_level10_frost_orchard.jpg   level 10
    e03_level20_lantern_meadow.jpg  level 20 — brzo, gusto, parovi
    e04_endless_start_amber.jpg     Endless start
    e05_endless_3min_amber.jpg      Endless ~3 min
    e06_endless_7min_amber.jpg      Endless ~7 min
    e07_field_endless_locked.jpg    polje: Endless zaključan (privremeno)
    e08_path_endless_locked.jpg     Level Path: Endless zaključan
    e09_loot_endless.jpg            kraj Endlessa (privremeno)
    e10_pause_endless_amber.jpg     pauza u Endlessu
    e11_level_end_frost_orchard.jpg kraj levela danas (bez cilja)
    e12_path_chest_ready.jpg        spremni sanduk (bez „Claim")
  docs/04-experience/design-drafts/level-path-izvjestaj-ref/:
    p03_path_country_bloom.jpg, p04_path_moonlit_warren.jpg,
    p05_path_starfall_glade.jpg, p06_complete_amber_canopy.jpg,
    p07_locked_toast.jpg, p08_reward_popup.jpg
  docs/02-design/balans-ciklus-1-izvjestaj.md  (zašto i koji brojevi)
  game/data/run_levels/levels.json             (20 levela + Endless)
  game/scripts/run/run_level_library.gd, game/scripts/run/run_balance.gd
  game/scripts/run/run_controller.gd   (_try_spawn, _update_endless_tier,
    _update_hud, _fill_pause)
  game/scripts/run/obstacle_visual.gd, game/scripts/visual/ui_run.gd
  game/scripts/economy/level_path.gd   (ENDLESS_UNLOCK_LEVEL, rekord)
  game/scripts/ui/main_menu.gd         (_refresh_endless_button)
  game/scripts/ui/loot_screen.gd, game/scripts/ui/level_path_view.gd
    (_animate_ready, _tap)
  game/scripts/run/run_progress_rail.gd, game/scripts/ui/popup/run_banner.gd
  game/data/seasons/seasons_kit.json, game/data/level_path/*.json
  design_handoff_run/, design_handoff_run_hud_v2/,
    design_handoff_run_pickups/, design_handoff_level_path/,
    design_handoff_popups/, design_handoff_seasons/, design_handoff_pip/
    (tvoji paketi)

DANAS (već u igri, brojevi FIKSNI): leveli 1–20 svake sezone sve teži —
duži (60 -> 120 s), brži, više prepreka, od levela 6 parovi (dvije staze
zatvorene, treća slobodna), više plijena. Endless bez tajmera: kreće lagano,
svakih 20 s stepenica teže, dok Pip ne padne; plijen ostaje cijeli; rekord
po sezoni; otključan poslije levela 15 te sezone. Ali ništa od toga se ne
VIDI: kamenovi isti, run bez najave, Endless samo prigušen / običan tekst.

TRAŽI SE (plan kako izgleda):
A1. 4 pojasa težine (1–5, 6–10, 11–15, 16–20): ime + oznaka, vidi se na
    Level Pathu (kamenovi) i u LevelChipu u runu.
A2. Najava levela na startu runa (<= 1,2 s, ne blokira swipe).
A3. Osjećaj ubrzanja svakih 15 s (nalet, bez teksta).
A4. Par prepreka po sezoni — jasno gdje je prolaz; 3 varijante (rupa
    lijevo / sredina / desno); sudar ostaje 64 x 64 po stazi.
A6. CILJ na kraju levela: dolazi s vrha preko sve 3 staze i Pip prođe kroz
    njega tačno na kraju (pa animacija završetka, veži s „Time!" i trakom);
    po sezoni; nije prepreka; samo za uspješan kraj levela.
B1. Zaključan Endless (dugme 236 x 124, isto mjesto) + poruka na tap.
B2. Trenutak otključavanja na Level Pathu poslije levela 15.
B3. Endless HUD: sat, stepenica, rekord (LevelChip <= 464, tekst <= 1/s).
B4. Nova stepenica svakih 20 s (kratko, čitljivo i na 900+ px/s).
B5. Novi rekord u runu (jednom, <= 1 s).
B6. Kraj Endlessa: R5 varijanta — vrijeme, stepenica, rekord, CIJELI plijen.
B7. Pauza u Endlessu: bez ikone „pola".
B8. Rekord sezone na Homeu (npr. na Endless dugmetu).
C. Level Path: spremni sanduk BEZ pilule „Claim" — sam skakuće, klima se,
   zaviri sjaj; tap na sanduk = popup (kao danas); reduce motion miran.
D. (opcionalno) formacije po pojasu kao podaci, u okviru brojeva iz §4.

PERFORMANSE (MORA, §5): ništa ne crta po frejmu; efekti <= 8 sprite-ova i
<= 1 s; par <= 2 sprite-a; nijedan efekat ne raste s gustinom; SVG <= 150 KB.
Brojeve napiši u README.

TEHNIČKI (Godot 4.7, GL Compatibility, slabiji Android, 60 FPS): artboard
1080 x 1920. Stil kao run, Run HUD v2, Level Path i popupi: ravne boje,
obrub, jedna tvrda sjena. BEZ blura, glowa, gradijenata i maski.

ISPORUKA (§6): novi folder design_handoff_leveli_endless/, CIJELI U ZIPU
za preuzimanje u chatu (design/LevelBands, RunDifficulty, EndlessHud,
EndlessEnd, LevelFinish, ChestReady, Specs .dc.html; assets/bands,
obstacles, endless, fx, finish, chest; godot/level_bands.json,
run_difficulty.json, obstacle_pairs.json, endless_ui.json,
level_finish.json, chest_ready.json; README sa § Odlučeno, § Performanse
i § Samoprovjera — 12 stavki iz §6.3, svaka da/ne, provjereno u
pregledaču PRIJE nego pošalješ zip).

NE RADI: brojeve težine / plijena / cijena, mehaniku, pickupe, put Level
Patha (osim oznaka pojasa), nove ekrane, kupovinu, reklame, leaderboard,
zvuk. Jedan dizajn, tvoj izbor, neka bude sočno i prelijepo.
```

## Povezano

- [[../_index|04-experience]]
- [[../../06-production/CHECKPOINT|CHECKPOINT]]
- [[../../02-design/balans-ciklus-1-izvjestaj|balans-ciklus-1-izvjestaj]] · [[../../02-design/ekonomija-brojevi|ekonomija-brojevi]]
- [[level-path-cd-brief|Level Path]] · [[run-hud-v2-cd-brief|Run HUD v2]] · [[run-pickups-cd-brief|Run pickupi]] · [[popups-cd-brief|Popupi]]
- [[../../01-vision/design-pillars|design-pillars]] — Pillar 2
