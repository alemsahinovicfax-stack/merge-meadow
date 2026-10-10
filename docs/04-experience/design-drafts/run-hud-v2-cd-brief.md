---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, ui, run, hud, lane-run, grm, claude-design, mockup]
povezano:
  - run-cd-brief
  - pip-cd-brief
  - seasons-cd-brief
  - popups-cd-brief
  - ideje-gameplay-ekonomija
  - design-pillars
  - CHECKPOINT
ai_sažetak: "Brief za Claude Design: novi header runa u jednom redu (Level, coini, sjemenke, pauza) za level mod i Endless, bez Pip portreta, prstena i sekundi; vertikalna traka napretka uz rub staze; nagradni grm između traka koji Pip pokupi kad prelazi traku."
---

# Run — novi header, traka napretka i nagradni grm — Claude Design brief

> **Status 2026-10-09: paket stigao i prenesen u igru** — vidi [[run-hud-v2-izvjestaj]]. Paket: `design_handoff_run_hud_v2/`.
>
> ~~Status 2026-10-08: brief spreman, čeka CD.~~ Prompt je u §11. Slike stanja prije v2: `run-hud-ref/`.

Run je već jednom dizajniran ([[run-cd-brief|run-cd-brief]], paket `design_handoff_run/`). Ovo je druga runda, ali samo za tri stvari:
- **header** (HUD na vrhu);
- **traka napretka** sa strane, umjesto sekundi;
- **nagradni grm** između traka.

Sve ostalo ostaje kako je: staze, prepreke, pickupi, Pip, kraj runa.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | §1–§10 + slike u `run-hud-ref/` | Šta mora, šta smije, kako izgleda danas, šta se isporučuje |
| **Ti** | **§11** | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §4, §6, §7 | Današnje mjere iz koda i nacrt pravila grma |

**Prije slanja prompta: commitaj i pushaj na `master`.** CD čita fajlove iz repoa po tačnoj putanji.

## 1. Zašto

**Header je pretrpan i u dva reda** (`run-hud-ref/01–03`):
- gore u sredini je pilula „Level 1 / 44s" s prstenom koji se prazni, a desno pauza;
- ispod su Pip čip (portret + „Pip"), coini, sjemenke i dijamanti (wallet), a ispod njih ponekad i značka korpe.

To je pet do sedam elemenata na vrhu ekrana koji igrač ne gleda dok trči.

**Odbrojavanje u sekundama se ne sviđa** (ideja iz 2026-07-04, `docs/03-content/ideje-gameplay-ekonomija.md` § „Ideje — UI run progress"). Igrač treba osjetiti da **trči prema cilju**, a ne da gleda sat.

**Run je ravan.** Prostor između traka je prazan. Grm s nagradom između traka je stara ideja (isti fajl, §7 i §8). Daje razlog za promjenu trake i bez prepreke.

## 2. Pravila koja ostaju FIKSNA

| Pravilo | Vrijednost |
|---|---|
| Staze | 3 trake, centri x **270 / 540 / 810**, širina **200**; razmak između traka 70 px (šav na x **405** i **675**); traka od x 170 do 910 |
| Pip | stoji na y **1574** (0,82 × 1920), kolizija **56 × 56**, promjena trake **0,12 s**, swipe 50 px. Art i animacije Pipa su iz `design_handoff_pip/` i ne diraju se |
| Prepreke | kolizija 64 × 64; tijelo 176 × 150 + „kragna" 240 × 52 (viri 20 px van trake) |
| Brzina | 400 px/s (neki nivoi × 1,05), +5 % svakih 15 s |
| Trajanje | tutorial 45 / 60 s, nivoi 50–60 s, Endless bez kraja |
| Kraj runa | pad i cilj (banner, snimak zadnjeg kadra, Loot) se ne mijenjaju |
| Pickupi | coin, sjemenka, dijamant, magnet — isti |
| Pauza | dugme ostaje, dodir ≥ 120 × 120; pauza-sheet se ne mijenja |
| Pillar 2 | grm je nagrada iz igre, nikad kupljena; ne prodaje se ništa |
| Stil | flat, pastel, ravne boje, radius, rub, jedna tvrda sjena. **Bez blura, glowa i gradijenata** |

## 3. Šta se traži

Tačke 1–3 su **obavezne**. Izgled, raspored unutar reda i animacije su tvoja odluka. Jedan dizajn.

1. **Header u jednom redu.**
   - Ostaju samo četiri stvari:
     - **Level** (u Endlessu: „Endless" + težina);
     - **coini** ovog runa;
     - **sjemenke** ovog runa;
     - **dugme pauze**.
   - **Izbacuje se:**
     - Pip portret i čip s imenom „Pip";
     - prsten koji se puni;
     - **sekunde**;
     - dijamant čip (wallet);
     - značka korpe.
   - Jedan red na vrhu, ispod safe area.
   - **Mora raditi u tri moda:**
     - level mod („Level 12");
     - Endless („Endless · Hard");
     - tutorial run, koji nema broj nivoa — odluči šta slot pokazuje (npr. ništa ili kratka riječ) i zapiši u § Odlučeno.
   - **Leteći pickupi** danas lete do čipova coina, sjemenke i dijamanta:
     - coin i sjemenka i dalje lete do svojih čipova;
     - za dijamant, koji više nema čip, nacrtaj kratku povratnu informaciju na mjestu pickupa (pop koji nestane). Dijamant i dalje ide u wallet.
2. **Traka napretka sa strane** (umjesto sekundi).
   - Vertikalna traka uz rub staze. **Dno** je start, **vrh** je cilj (zastavica ili linija cilja).
   - Mali znak Pipa se penje kako run teče: `elapsed / duration`. Koristi Pipov art iz `design_handoff_pip/` (npr. glava iz HUD kropa ili silueta odozgo); ne crtaj novog Pipa.
   - **Ne smije prekrivati staze, pickupe ni prepreke.** Slobodan pojas je samo uz traku:
     - desno od x 940 do ~1056;
     - ili lijevo od x 24 do ~140.
     - Kragna prepreke u krajnjoj traci ide do x 930 (odnosno od 150).
   - Zato je traka uska, **≤ 116 px**. Ideja je bila ~1/5 širine ekrana, ali to bi prekrilo traku 3, pa ostaje uz rub. Lijevo ili desno — tvoja odluka (pauza je gore desno).
   - Pokaži stanja:
     - početak (0 %);
     - sredina;
     - blizu cilja (npr. 90 %);
     - cilj (100 %) u trenutku kad dolazi banner „Time!".
   - **Endless nema cilj.** Odluči šta traka radi (sakrivena ili bez cilja) i zapiši zašto. Bez novog podatka koji igra danas nema.
   - Upozorenje „malo vremena" je danas bila narandžasta boja prstena ispod 17 %. Ako ga zadržavaš, neka bude na traci, ne u headeru.
3. **Nagradni grm između traka.**
   - Grm stoji **na šavu između dvije trake** (x 405 ili 675). Smije viriti najviše **25 px u svaku susjednu traku** (ukupno ≤ 120 px širine), visina ≤ 140.
   - Pip ga pokupi kad **prelazi iz trake u traku** preko tog šava dok je grm u njegovoj visini (§7).
   - Na prvi pogled mora biti jasno da je to **nagrada, ne prepreka**: grm se trese i iz njega viri coin ili sjemenka. Prepreke stoje mirno u traci i tamnije su.
   - **Stanja:**
     - mirovanje (trese se, viri nagrada);
     - pokupljen: lišće pukne, a nagrada iskoči i odleti do čipa coina ili sjemenke;
     - promašen: grm prođe ispod bez reakcije.
   - **Po sezoni:**
     - jedan oblik grma i paleta po sezoni (8 sezona iz `game/data/seasons/seasons_kit.json`);
     - smiješ dodati mali motiv sezone (snijeg na grmu u Frost Orchardu, svjetlo u Lantern Meadowu…);
     - grm se mora čitati na svijetlim i tamnim sezonama.

## 4. Današnje stanje (mjere iz koda)

### 4.1 Header danas

Izvor: `game/scenes/run/run_scene.tscn` (čvor `HUD/TopHud`), `game/scripts/visual/ui_run.gd`, `game/scripts/run/run_controller.gd`.

| Čvor | Rect (x, y, w, h) u px 1080 × 1920 | Šta je | Novo |
|---|---|---|---|
| `TimerChip` | (310, 60, 460, 156) | prsten 104 (debljina 14, mint → peach ispod 17 %) + „Level N" 38 px + sekunde 72 px | ostaje samo Level |
| `PauseButton` | (912, 74, 128, 128) | pauza | ostaje |
| `CompanionChip` | (40, 232, 268, 120) | Pip portret 88 + „Pip" 44 px | **van** |
| `BasketBadge` | (40, 364, 268, 76) | odabrano sjeme korpe | **van** |
| `PickupBar` | desno, y 232, čipovi 190 × 120 (dijamant 168 × 120), razmak 16 | coin · sjemenka · dijamant (wallet, plavi `#B8E0F5`) | coin i sjemenka ostaju, dijamant **van** |
| `PickupFeed` | toast y 386 | ime sjemena + „+1" / „+2" (Twin Seeds) | ostaje |

- **Tekst moda** (`UiRun.timer_lines`): „Level N" u level modu, „Endless · Easy / Normal / Hard" u Endlessu, prazno u tutorial runu.
- **Safe area** gore je 60. Stil čipa: krem `#FFF8F0`, rub `UiArena.RIM_EDGE`, sjena `rgba(18,28,22,.42)`.

### 4.2 Slike iz igre (`docs/04-experience/design-drafts/run-hud-ref/`)

| Slika | Šta pokazuje |
|---|---|
| `01_level_country_bloom.jpg` | level mod, svijetla sezona |
| `02_endless_country_bloom.jpg` | Endless |
| `03_level_starfall_glade.jpg` | level mod, tamna sezona |

Uz to `pip-ref/11` i `12` pokazuju run s preprekama.

### 4.3 Prostor oko staza

Traka je od x 170 do x 910. Lijevo i desno je pojas sezone (ivica, motivi iz Season Kita — npr. ograda u Country Bloomu, jele u Starfall Gladeu). Taj pojas je jedino mjesto za traku napretka.

Prepreka u krajnjoj traci sa kragnom ide od x 690 do 930 (traka 3), odnosno od 150 do 390 (traka 1).

## 5. Pickupi i HUD — šta mora ostati čitljivo

- Coin i sjemenka u letu moraju stići do svog čipa u novom redu (`run_pickup_feed.gd` → cilj je čip).
- Twin Seeds daje „+2" umjesto „+1"; to ostaje.
- Brojevi u čipovima ≥ 56 px kao danas.
- Kontrast ≥ 4,5 : 1 na svih 8 sezona, posebno na tamnim (Lantern Meadow, Moonlit Warren, Starfall Glade, Ember Fen).

## 6. Traka napretka — podaci

| Stvar | Vrijednost |
|---|---|
| Napredak | `elapsed / GameState.get_run_duration()` (0 → 1), ažurira se svaki frejm |
| Cilj | 1,0 = banner „Time!" (cilj runa) |
| Endless | `GameState.is_endless_mode()` — nema `duration` koji vrijedi kao cilj |
| Tutorial | `uses_run_level_config() == false` — trajanje 45 / 60 s, nema broja nivoa |

Znak Pipa se pomjera **transformom** (ne crta se iznova svaki frejm).

## 7. Grm — nacrt pravila (za kasniji prenos; CD crta, brojeve smije predložiti)

Brojevi su **nacrt**. Ako predložiš druge, upiši ih s razlogom u § Odlučeno.

| Pravilo | Nacrt |
|---|---|
| Gdje | šav x 405 ili 675, nasumično |
| Kada | najviše jedan grm na ekranu; razmak 8–12 s; nikad u tutorial runu 1 |
| Kako se pokupi | Pip prelazi preko tog šava (promjena trake) dok je grm u njegovoj visini: hitbox grma ≈ 120 × 160 oko šava, Pip 56 × 56 u pokretu |
| Fer | u obje susjedne trake nema prepreke ±300 px oko grma — skretanje po grm nikad ne vodi u prepreku |
| Nagrada | 60 % **3–5 coina**, 40 % **1–2 sjemenke** iz poola sezone (isti izbor kao obični pickup). Twin Seeds, korpa i magnet se ne primjenjuju na grm |
| Fail | grm nije prepreka; ne može oboriti Pipa |
| Endless | isto kao level mod |

Ovo se ne crta kao tekst u igri. Igrač mora shvatiti iz izgleda (grm se trese, viri nagrada) i iz prvog pokupljenog grma.

## 8. Isporuka

### 8.1 Stanja

1. **Header — level mod**, svijetla sezona (Country Bloom) i tamna (Starfall Glade). Brojevi 0 i veliki (npr. coin 128, sjemenke 47).
2. **Header — Endless** (Easy / Normal / Hard) i **tutorial run**.
3. **Traka napretka**: 0 %, 50 %, 90 %, 100 % (s bannerom „Time!"); Endless (tvoja odluka); tutorial.
4. **Grm** po sezoni (8) u mirovanju, na svijetloj i tamnoj sezoni u kadru runa.
5. **Grm pokupljen** — 3–4 kadra: Pip prelazi traku → grm pukne → coini / sjemenka odlete do čipa.
6. **Grm promašen** — prolazi ispod.
7. **Dijamant pickup** bez čipa (pop na mjestu).
8. **Cijeli ekran runa** s novim headerom, trakom i jednim grmom, na Country Bloomu i Starfall Gladeu.

### 8.2 Paket

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_run_hud_v2/
  README.md                 šta otvoriti · § Odlučeno · § Šta se briše ·
                            § Performanse (budžet animacija) · § Samoprovjera ·
                            § Ideje van zadatka
  design/
    RunScreen.dc.html       cijeli run; prop mode (level / endless / tutorial),
                            season, progress (0–1), bush (none / idle / burst)
    RunHud Specs.dc.html    header anatomija, traka napretka, grm po sezoni,
                            sva stanja iz §8.1
    support.js · icons/
  assets/
    run/bush/*.svg          grm (dijelovi za animaciju) + paleta po sezoni
    run/progress/*.svg      traka, zastavica, znak Pipa (ako nije iz Pip paketa)
  godot/
    run_hud_export.json     meta · tokens · layout · components · states ·
                            animations · strings_en · bush (pravila iz §7) ·
                            godot_map · decisions
    ui_run.gd               konstante (samo izmjene, isti nazivi gdje postoje)
    run_hud_tree.txt        stablo čvorova + red prenosa
```

**Imena slojeva:** `TopHud`, `LevelChip`, `CoinChip`, `SeedChip`, `PauseButton`, `ProgressRail`, `ProgressFlag`, `ProgressPip`, `RewardBush`, `BushBurst`, `DiamondPop`.

### 8.3 Performanse (MORA, u README)

Igra cilja slabiji Android; animacije su već jednom oborile FPS.
- Header i traka se **ne crtaju iznova svaki frejm**: brojevi su Label, znak Pipa se pomjera transformom.
- Grm u mirovanju je **jedan loop transformom** (rotacija / skala dijelova), bez ponovnog crtanja.
- Burst ≤ **12 spriteova**, ≤ 0,6 s.
- Na ekranu najviše jedan grm.
- U README napiši broj dijelova po grmu, broj spriteova u burstu i KB svih novih SVG-ova (≤ **60 KB** ukupno).

### 8.4 Samoprovjera (u README, svaka stavka da/ne, provjereno u pregledaču)

1. Header je jedan red: Level · coini · sjemenke · pauza; nigdje Pip portret, prsten, sekunde, dijamant čip ni korpa.
2. Header radi u level modu, Endlessu i tutorial runu.
3. Pauza ≥ 120 × 120; brojevi ≥ 56 px; kontrast ≥ 4,5 : 1 na svijetloj i tamnoj sezoni.
4. Traka napretka ne prekriva staze, prepreke (s kragnom) ni pickupe; širina ≤ 116 px.
5. Traka ima 0 / 50 / 90 / 100 % i odluku za Endless.
6. Grm je na šavu, viri ≤ 25 px u svaku traku, i na prvi pogled je nagrada, ne prepreka.
7. Grm ima mirovanje, pokupljen i promašen, za svih 8 sezona.
8. Coin i sjemenka iz grma lete do novih čipova; dijamant ima pop.
9. Budžet iz §8.3 je ispunjen i napisan u README.
10. Nigdje blur, glow ni gradijent.

## 9. Ne tražimo

- Novi izgled staza, prepreka, pickupa, Pipa, bannera, Loot ekrana ili pauza-sheeta.
- Grm-prepreku (trnovit grm koji obara) — samo nagradni grm.
- Nove nagrade, valute, power-upe ili kupovinu (Pillar 2).
- Promjenu tajminga, brzine, kolizije ili trajanja runa.
- Više varijanti — jedan dizajn.

## 10. Scope

Header, traka napretka i nagradni grm idu u launch (M8) — u `scope-i-granice.md` od 2026-10-09. Grm je nagrada iz igre, bez kupovine, pa Pillar 2 ostaje netaknut.

## 11. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj na `master`.** Priloži i ovaj `.md` fajl.

```
Radim drugu rundu RUNA u mobilnoj igri Merge Meadow (portrait, flat pastel
cartoon). Run si već radio (design_handoff_run/). Mijenjaju se samo tri
stvari: header, traka napretka sa strane i novi nagradni grm između traka.

Pročitaj po ovim tačnim putanjama (repo, master):
  docs/04-experience/design-drafts/run-hud-v2-cd-brief.md
    -> §2 (fiksno), §3 (šta se traži), §4 (mjere iz koda), §6 (traka),
       §7 (pravila grma — nacrt), §8 (stanja, paket, performanse,
       samoprovjera)
  docs/04-experience/design-drafts/run-hud-ref/   (3 slike današnjeg HUD-a)
  docs/04-experience/design-drafts/pip-ref/11_run_country_bloom.jpg,
    12_run_starfall_glade_dark.jpg
  docs/03-content/ideje-gameplay-ekonomija.md     (§7–§8 grmovi;
                                                   „Ideje — UI run progress")
  game/scenes/run/run_scene.tscn                  (HUD/TopHud)
  game/scripts/visual/ui_run.gd, lane_background.gd
  game/scripts/run/run_controller.gd, player.gd
  game/scripts/ui/run_pickup_feed.gd
  game/data/seasons/seasons_kit.json              (8 sezona, palete)
  design_handoff_run/, design_handoff_seasons/, design_handoff_pip/,
  design_handoff_popups/                          (tvoji paketi)

ŠTA TRAŽIM:

1. HEADER U JEDNOM REDU: samo Level (u Endlessu "Endless · Hard"), coini,
   sjemenke i pauza. IZBACI: Pip portret i čip "Pip", prsten koji se puni,
   SEKUNDE, dijamant čip i značku korpe. Mora raditi u level modu,
   Endlessu i tutorial runu (nema broja nivoa — odluči šta slot pokazuje).
   Coin i sjemenka i dalje lete do svojih čipova; dijamant (nema čip)
   dobije kratak pop na mjestu pickupa. Pauza >= 120 x 120.

2. TRAKA NAPRETKA SA STRANE umjesto sekundi: vertikalna, dno = start, vrh
   = cilj (zastavica). Mali znak Pipa (art iz design_handoff_pip/) se
   penje po elapsed / duration. NE SMIJE prekriti staze, prepreke (kragna
   do x 930 / od 150) ni pickupe: širina <= 116 px, desno x 940–1056 ili
   lijevo x 24–140. Stanja 0 / 50 / 90 / 100 %. Endless nema cilj — odluči
   šta traka radi i zapiši zašto.

3. NAGRADNI GRM između traka: stoji na šavu (x 405 ili 675), viri <= 25 px
   u svaku traku, visina <= 140. Pip ga pokupi kad prelazi traku preko tog
   šava. Na prvi pogled je NAGRADA, ne prepreka (trese se, viri coin ili
   sjemenka; prepreke su mirne i tamnije). Stanja: mirovanje, pokupljen
   (lišće pukne, nagrada odleti do čipa), promašen. Jedan oblik + paleta
   po sezoni za svih 8 sezona; mali motiv sezone smiješ dodati. Pravila
   (nagrada, razmak, fer raspored) su nacrt u §7 — brojeve smiješ
   predložiti s razlogom.

FIKSNO: staze 270/540/810 (š. 200), Pip y 1574, kolizija 56 x 56, prelaz
0,12 s, brzina, trajanje, kraj runa, pickupi, Pip art i animacije,
pauza-sheet. Pillar 2 — grm je nagrada iz igre, ništa se ne prodaje.

PERFORMANSE (MORA, §8.3): ništa se ne crta iznova svaki frejm; grm u
mirovanju = jedan loop transformom; burst <= 12 spriteova, <= 0,6 s;
najviše jedan grm na ekranu; novi SVG ukupno <= 60 KB. Brojeve napiši u
README.

TEHNIČKI (Godot 4.7, GL Compatibility, slabiji Android): artboard
1080 x 1920, sve u px te baze. Ravne boje, radius, rub, jedna tvrda
sjena. BEZ blura, glowa i gradijenata. Tekst >= 34 px, brojevi >= 56 px,
kontrast >= 4,5:1 na svijetlim i tamnim sezonama.

ISPORUKA (§8): novi folder design_handoff_run_hud_v2/, CIJELI U ZIPU za
preuzimanje u chatu:
  design/RunScreen.dc.html (prop mode, season, progress, bush),
  RunHud Specs.dc.html (sva stanja iz §8.1), support.js, icons/
  assets/run/bush/, assets/run/progress/
  godot/run_hud_export.json (uklj. objekat bush s pravilima), ui_run.gd,
  run_hud_tree.txt
  README.md sa § Odlučeno, § Šta se briše, § Performanse i § Samoprovjera
  (10 stavki iz §8.4, svaka da/ne, provjereno u pregledaču PRIJE nego
  pošalješ zip).

NE RADI: staze, prepreke, pickupe, Pipa, banner, Loot, pauza-sheet,
grm-prepreku, nove nagrade ili valute, promjene tajminga. Jedan dizajn,
tvoj izbor, neka bude lijep.
```

## Povezano

- [[../../06-production/CHECKPOINT|CHECKPOINT]] — traka RUN-HUD-02
- [[run-cd-brief|Run]] — prva runda, HUD i svijet
- [[pip-cd-brief|Pip]] — art i animacije Pipa u runu
- [[seasons-cd-brief|Sezone]] — palete i pojas uz staze
- [[../../03-content/ideje-gameplay-ekonomija|ideje-gameplay-ekonomija]] — grmovi (§7–§8), traka napretka
- [[../../01-vision/design-pillars|design-pillars]] — Pillar 2
