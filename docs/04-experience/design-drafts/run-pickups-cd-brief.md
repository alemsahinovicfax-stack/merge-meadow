---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, run, pickup, animacije, pip, camp, sezone, claude-design]
povezano:
  - run-cd-brief
  - run-hud-v2-cd-brief
  - pip-cd-brief
  - seasons-cd-brief
  - camp-season-link-cd-brief
  - design-pillars
  - CHECKPOINT
ai_sažetak: "Brief za Claude Design: (A) puni redizajn pickupa u runu — sjemenka i coin na stazi, privlačenje magnetom, dodir sa Pipom (coin, sjeme ★1–★3, twin +2, niz coina), Pip reakcije i let „+1"; (B) Camp link kartica za 4 plaćene sezone u istom Season Kit stilu kao besplatne (recept „camp" + stanja s cijenom). Budžeti za slab Android."
---

# Run pickupi + kartice plaćenih sezona u Campu · Claude Design brief

> **Status 2026-10-20: paket stigao i u igri — vidi [[run-pickups-izvjestaj|run-pickups-izvjestaj]].** Ranije (2026-10-16): spremno za slanje. Slike: `run-pickups-ref/` (r01–r05, dio A) i `camp-paid-card-ref/` (c01–c06, dio B). Prompt je u §9.
>
> **Prije slanja: commitaj i pushaj na `master`.** CD čita repo samo po tačnim putanjama s mastera.

Dvije stvari:
- **A.** Run je srce igre, a pokupljanje je najčešći trenutak u njemu (svakih ~1–2 s). Danas pickup samo nestane, pa iskoči bijeli prsten — nema osjećaja da je Pip nešto uzeo. Treba **puni redizajn**:
  - kako sjemenka i coin stoje na stazi;
  - kako ih magnet privlači;
  - šta se desi u trenutku dodira;
  - kako Pip reaguje.
- **B.** Camp link kartica za besplatne sezone ima sezonski crtež (Season Kit recept „camp": voćnjak, lampioni, lišće). Od 2026-10-16 ista kartica, kad su sve besplatne otključane, nudi **plaćenu** sezonu sa cijenom — ali plaćene sezone nemaju recept, pa je kartica samo obojena podloga. Treba ih nacrtati **u istom stilu kao besplatne**.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | §1–§8 + slike u `run-pickups-ref/` i `camp-paid-card-ref/` | Šta je danas, šta mora, šta se isporučuje |
| **Ti** | **§9** | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §2, §4, §5, §8 | Mjere iz koda, kako se prenosi i mjeri FPS |

## 1. Pravila koja ostaju FIKSNA

| Pravilo | Vrijednost |
|---|---|
| Stil | isti kao Pip, Run i Season Kit (`design_handoff_pip/`, `design_handoff_run/`, `design_handoff_run_hud_v2/`, `design_handoff_seasons/`): flat, pastel, tamni obrub (ink `#2D3436`), ravne boje, jedna tvrda sjena. **Bez blura, glowa, gradijenata i maski** |
| Engine | Godot 4.7, GL Compatibility, slabiji Android, 60 FPS. Artboard 1080 × 1920, sve u px te baze |
| Run | pogled odozgo; 3 staze; Pip odozgo ~150 px, stoji na y ~1570; svijet klizi naniže 400 px/s (do ~1,5× na težim nivoima) |
| Kolizija | sjemenka r 26, coin r 18 (ne mijenja se) |
| Magnet | isprekidan krug oko Pipa, radijus 40 + 48 × nivo (nivo 0–4 → 40–232 px), po sezoni. Sve što uđe u krug je pokupljeno — pravilo ostaje, mijenja se samo kako to izgleda |
| Sezone | 8 livada, svijetle (Country Bloom, Amber) i tamne (Starfall, Moonlit, Ember) — pickup mora da se čita na svim |
| HUD | Run HUD v2: CoinChip i SeedChip gore desno (paket `design_handoff_run_hud_v2/`); traka napretka lijevo; grm između staza ostaje kakav jeste |
| Camp kartica | 1032 × 318, padding 22, rub 3 `#2D3436`, radius CTA, jedna tvrda sjena 0 8 0; recept se crta UNUTAR ruba i ništa ne izlazi van (GL Compat ne reže, katalog grešaka #24) |
| Pillar 2 | čisto vizuelno — nikakva promjena vrijednosti, šansi, magneta ni cijena; plaćena sezona je tema, ne snaga |

## 2. A — Run pickupi: danas (slike `r01`–`r05`)

### 2.1 Na stazi (`r01` Country Bloom, `r04` Starfall)

| | Sjemenka | Coin |
|---|---|---|
| Crtež | odrezana sadnica cvijeta sezone, 120 px; rijetkost = broj kružića (pips 22 px) iznad sadnice (★1 / ★2 / ★3) | `icon_coin.svg`, 96 px (ista ikona kao u headeru) |
| Kretanje | gore-dolje ±5 px, 2,4 rad/s | gore-dolje ±5 px, 2,6 rad/s |
| Sjena | elipsa 64 × 18, crna 30 % | isto |
| Kod | `game/scripts/run/seed_visual.gd` | `game/scripts/run/coin_visual.gd` |

### 2.2 Dodir (`r02` sjeme, `r03` coin, `r05` sjeme na tamnoj livadi — 12 frejmova po 0,05 s oko Pipa)

1. Pickup **nestane odmah** (`collect()` → `queue_free`).
2. Bijeli prsten se širi 18 → 64 px i nestaje za 0,22 s (`run_ring_fx.gd`).
3. Pilula „+1" (ikona + broj; kod sjemena i ime) leti do brojača u HUD-u: 0,32 s, skala 0,7, alfa 0,35. Brojač se trzne (`run_pickup_feed.gd`).
4. Za sjeme iskoči i poruka „[sjeme] +1 Ime" ispod SeedChipa: 1,4 s, najviše 2 odjednom.
5. Pip (overlay, pogled odozgo):
   - `pickup_coin` 0,22 s: pop 1,07, „sretne" oči;
   - `pickup_seed` 0,36 s: pop 1,1, glava lijevo-desno, osmijeh.
   - Podaci: `game/data/pip/animations.json`.
6. Zvuk: `coin` (ton raste u nizu), `run_seed`.
7. Twin nadogradnja: sjeme ponekad daje +2. Vidi se samo u brojaču.

**Šta ne valja:**
- dodir ne izgleda kao da ga je Pip uzeo — stvar nestane, pa bljesne prsten;
- coin i sjeme imaju isti trenutak;
- ★2 / ★3 i +2 se ne osjete;
- magnet „krade" pickup iz daljine bez ikakvog leta (pickup samo nestane na rubu kruga);
- niz od 5 coina u sekundi izgleda kao 5 istih bljeskova.

## 3. A — Run pickupi: šta se traži

1. **Pickupi na stazi (idle).**
   - Sjemenka i coin dobijaju živ, čitljiv idle — nešto što privuče pogled, ali ne smeta preprekama:
     - coin se vrti / blješti;
     - sjemenka se njiše, ima zemljicu / kapljicu.
   - **Rijetkost se vidi bez brojanja kružića:** ★2 i ★3 imaju jasno drugačiji idle (npr. iskrice, oreol od latica — ravni oblici, bez glowa).
   - Čita se na svih 8 livada (svijetle i tamne). Sezonski detalj je dozvoljen, ali nije obavezan.
2. **Magnet privlačenje.**
   - Pickup koji uđe u magnetni krug **doleti do Pipa** (luk, 0,12–0,2 s, ubrzava), pa tek onda „uđe" u Pipa.
   - Pravilo se ne mijenja (pokupljeno je čim uđe u krug); mijenja se samo prikaz.
   - Krug magneta možeš redizajnirati (danas isprekidan krug), ako ostaje diskretan.
3. **Trenutak dodira — sa Pipom, ne umjesto Pipa.**
   - **Coin:** Pip ga „ulovi", coin se okrene / sabije u njega; „+1" ide u CoinChip.
   - **Sjeme:** sadnica se iščupa i skoči Pipu u šape / ruksak; „+1 Ime" ide u SeedChip.
   - **★2 / ★3:** veći, zadovoljniji trenutak (ali i dalje ≤ 0,4 s).
   - **Twin +2:** jasno „dvije" (npr. dvije sadnice ili ×2 pečat).
   - **Niz coina:** svaki sljedeći coin u nizu (≤ 0,6 s razmaka) malo pojača efekat, kao što ton raste u zvuku. 5 coina u sekundi mora izgledati dobro, ne kao šum.
4. **Pip reakcije** (pogled odozgo, `top`): nove ili poboljšane animacije:
   - `pickup_coin`, `pickup_seed`;
   - `pickup_seed_rare` (★2 / ★3);
   - `pickup_twin`.
   - Samo transformi i zamjena frejma (oči, usta…) — isti format kao `animations.json`.
   - Ne smiju prekinuti trčanje ni skretanje (overlay sloj).
5. **Let u HUD.** „+1" do brojača i trzaj brojača, u istom stilu. Poruka „[sjeme] +1 Ime" može ostati; ako je mijenjaš, ostaje čitljiva i ne pokriva traku napretka.

## 4. B — Camp kartica plaćene sezone

### 4.1 Danas (slike `c01`–`c06`)

- **Besplatne (c01 Frost, c02 Lantern, c03 Amber):**
  - recept `kits[id].camp` iz `game/data/seasons/seasons_kit.json` (7–9 slojeva: trake, greben, red drveća / lampioni / lišće; 1032 × 318);
  - ime sezone + dugme **Unlock** (300 × 120; sa lokotom kad fali);
  - ispod: coini „320 / 500" sa trakom | linija | ★3 cvijet prethodne sezone u zlatnom okviru 128 + ime + „20 / 20" sa trakom;
  - stanja `short` / `ready` / `burst` (`surfaces.camp` u kitu).
- **Plaćene (c04 Moonlit Warren, c05 Coral Tide, c06 Starfall Glade; Ember Fen je trenutno test-zaključan, ali treba i njega):**
  - `kits[id].camp` je **null** → kartica je samo obojena podloga (boja livade sezone);
  - ime sezone + zlatno dugme sa **cijenom** (€2,99 / €3,49);
  - ispod: potpisni ★3 cvijet sezone u zlatnom okviru, „Premium season", „6 new flowers";
  - kupovina ide kroz trgovinu (Google Play / App Store), pa isti „burst" i skok na Home.

### 4.2 Šta se traži

1. **Recept `camp` za sve 4 plaćene sezone** (Moonlit Warren, Coral Tide, Starfall Glade, Ember Fen):
   - isti format i isti nivo detalja kao Frost / Lantern / Amber (trake, oblici iz `shapes`, redovi motiva sezone);
   - motivi iz kita sezone (npr. mjesec i jazbine, školjke i talasi, zvijezde i meteori, žar i trska);
   - 1032 × 318, ≤ 12 slojeva, ništa van ruba.
2. **Čitljivost na tamnim sezonama.**
   - Tekst kartice je danas jedna boja (`#3D3D33`).
   - Ako je recept taman (Starfall, Moonlit, Ember), predloži svijetlu boju teksta po sezoni (polje `ink` u receptu) sa kontrastom ≥ 4,5:1 — ili drži recept svijetlim.
3. **Raspored plaćene kartice — samo cijena, bez coina i ★3:**
   - gore: ime sezone + dugme sa cijenom (zlatno kao „zlatna cijena" premium sezona na Homeu, ili tvoj prijedlog), bez lokota;
   - ispod: šta se dobija — potpisni ★3 cvijet, „Premium season", „6 new flowers" (ili bolje: mali red cvjetova sezone) — slobodno predloži;
   - mora se razlikovati od besplatne na prvi pogled (npr. oznaka „Premium" kao u Shopu), ali ostati ista porodica.
4. **Stanja:**
   - `price` (dostupno);
   - `buying` (čeka trgovinu — npr. tri tačke na dugmetu);
   - `burst` (kupljeno: isti prsten kao kod besplatne, pa Home);
   - `failed` (kupovina otkazana → nazad na `price`, bez poruke ili s kratkom).
5. **Tap na karticu** (ne na dugme) vodi na Home na tu sezonu bez kupovine — kao kod besplatne.

## 5. Performanse (MORA, u README)

| | Budžet |
|---|---|
| A · po dodiru | ≤ 8 sprite-ova, ≤ 0,4 s |
| A · istovremeno | do 3 dodira odjednom (niz coina) → ≤ 24 sprite-a |
| A · idle na stazi | do ~10 pickupa na ekranu; idle samo transformima (pozicija, rotacija, skala, frejm), **ništa se ne crta po frejmu** |
| A · teksture | jedan atlas ≤ 512 × 512 za sve pickup efekte (ili postojeći Pip fx atlas) |
| A · SVG | ukupno ≤ 60 KB |
| A · Pip | ≤ 4 nove animacije, ≤ 0,4 s, samo overlay sloj |
| B · recept | ≤ 12 slojeva po kartici, crta se jednom (statično, bez animacije), ništa van ruba |

U README napiši stvarne brojeve.

## 6. Isporuka

### 6.1 Stanja (sve živo u pregledaču)

- **A:**
  - staza sa sjemenkama ★1 / ★2 / ★3 i coinima na svijetloj (Country Bloom) i tamnoj (Starfall Glade) livadi;
  - magnet nivo 0, 2 i 4 (radijus 40 / 136 / 232) — privlačenje;
  - dodir: coin, sjeme ★1, ★2, ★3, twin +2, niz od 5 coina;
  - prekidač „usporeno ×4" za svaki dodir;
  - Pip reakcije same i u sceni;
  - let „+1" do CoinChipa i SeedChipa (HUD iz `design_handoff_run_hud_v2/`).
- **B:**
  - sve 4 plaćene kartice u stanjima `price`, `buying`, `burst`, `failed`;
  - uz njih Frost / Lantern / Amber (besplatne) radi poređenja — ista porodica;
  - na stranici Campa (`design_handoff_camp_v3/`), iznad sekcije Seeds · Flowers.

### 6.2 Paket

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_run_pickups/
  README.md                 šta otvoriti · § Odlučeno · § Performanse · § Samoprovjera
  design/
    RunPickups.dc.html      staza, magnet, dodiri, usporeno, prop season / magnet / rarity
    CampPaidCards.dc.html   4 plaćene + 3 besplatne kartice, sva stanja, na stranici Campa
    Specs.dc.html           mjere, vremena, krive, budžeti
    support.js · pip_*.js · seasons_kit.js (ako koristiš runtime iz svojih paketa)
  assets/
    pickups/*.svg           sjemenka (dijelovi), coin (frejmovi), rijetkost
    fx/*.svg                efekti dodira, magnet, let
  godot/
    pickup_fx.json          po događaju: sprite-ovi, vremena, krive, z
    pickup_idle.json        idle sjemenke / coina po rijetkosti
    animations_additions.json  Pip pickup_* (isti format kao game/data/pip/animations.json)
    seasons_kit_camp.json   kits[id].camp za moonlit_warren, coral_tide, starfall_glade, ember_fen
                            (isti format kao u game/data/seasons/seasons_kit.json, + ink ako treba)
    camp_paid_card.json     raspored i stanja plaćene kartice (tekstovi, boje, dugme, oznaka)
```

### 6.3 Samoprovjera (u README, svaka stavka da / ne, provjereno u pregledaču)

1. Dodir izgleda kao da ga je Pip uzeo — pickup ne nestane prije reakcije.
2. Coin i sjeme imaju različit trenutak; ★2 / ★3 i twin +2 se jasno razlikuju.
3. Magnet: pickup doleti do Pipa (≤ 0,2 s); pravilo „u krugu = pokupljeno" ostaje.
4. Niz od 5 coina u sekundi izgleda dobro i raste u intenzitetu.
5. Čitljivo na svijetloj i tamnoj livadi; ne pokriva prepreke ni grm.
6. Pip reakcije ne prekidaju trčanje ni skretanje.
7. Sve 4 plaćene sezone imaju recept `camp` u istom stilu i nivou detalja kao besplatne; ništa ne izlazi van ruba.
8. Plaćena kartica: samo cijena (bez coina i ★3), sva 4 stanja; tekst čitljiv (≥ 4,5:1) i na tamnim sezonama.
9. Budžeti iz §5 su ispunjeni i napisani.
10. Nigdje blur, glow, gradijent ni maska; ništa se ne crta po frejmu.

## 7. Ne tražimo

- Nove vrste pickupa, promjenu vrijednosti, šansi, magneta ili twina.
- Prepreke, grm, traku napretka i ostatak HUD-a (Run HUD v2 je gotov).
- Promjenu besplatnih kartica (Frost / Lantern / Amber), cijena sezona ni sekcije Seeds · Flowers.
- Zvuk (agent ga veže na nove trenutke).
- Promjenu Pip riga ili postojećih animacija trčanja.

## 8. Napomena za agenta (prenos)

- **A:**
  - `seed_pickup.gd` / `coin.gd`:
    - `collect()` više ne radi `queue_free` odmah — pickup prelazi u stanje „leti / ulazi", a kolizija se gasi;
    - signal `collected` ide u trenutku dodira, kao danas, pa brojanje ostaje isto.
  - `player.gd`: magnet (`MagnetField`) pokreće let umjesto trenutnog `collect`.
  - `seed_visual.gd` / `coin_visual.gd`: idle iz `pickup_idle.json`.
  - `run_pickup_feed.gd`: let „+1" i trzaj brojača po paketu.
  - `run_ring_fx.gd`: zamjena efektima iz paketa.
  - `run_controller.gd`:
    - `_on_coin_collected` / `_on_seed_collected` biraju efekat (rijetkost, twin, niz coina);
    - Pip animacije idu kroz `_pip_play`.
- **B:**
  - `seasons_kit_camp.json` → `kits[id].camp` u `game/data/seasons/seasons_kit.json`, i `surfaces.camp.seasons` dobija 4 plaćene;
  - `season_link_card.gd` (`_show_paid`, `_apply_card_look`) crta recept i stanja;
  - `ink` po sezoni ide u `_apply_card_look`.
  - Test: `camp_season_link_smoke` (plaćeni dio).
- **Provjera:**
  - `perf_suite_bench.gd` (`run_play_*`) prije / poslije;
  - pravilo CD paketa iz `performanse.md` (FPS po animaciji);
  - `run_smoke`, `run_hud_v2_smoke`, `camp_season_link_smoke`;
  - veličina pck.

## 9. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj na `master`.** Priloži i ovaj `.md` fajl.

```
Dvije stvari za mobilnu igru Merge Meadow (portrait, flat pastel cartoon,
zeko Pip trči odozgo kroz 3 staze i kupi sjemenke i coine).

Pročitaj po ovim tačnim putanjama (repo, master):
  docs/04-experience/design-drafts/run-pickups-cd-brief.md
    -> §1 (fiksno), §2–§3 (A: pickupi), §4 (B: Camp kartice plaćenih
       sezona), §5 (performanse), §6 (stanja, paket, samoprovjera)
  docs/04-experience/design-drafts/run-pickups-ref/  (dodir = 12 frejmova
    po 0,05 s oko Pipa; *_full = cijeli ekran s „+1" u letu):
    run-pickups-ref/r01_lane_country.jpg        staza Country Bloom
    run-pickups-ref/r02_seed_contact.jpg        dodir sjemena
    run-pickups-ref/r02_seed_contact_full.jpg
    run-pickups-ref/r03_coin_contact.jpg        dodir coina
    run-pickups-ref/r03_coin_contact_full.jpg
    run-pickups-ref/r04_lane_starfall.jpg       staza Starfall
    run-pickups-ref/r05_seed_contact_starfall.jpg   dodir na tamnoj livadi
    run-pickups-ref/r05_seed_contact_starfall_full.jpg
  docs/04-experience/design-drafts/camp-paid-card-ref/:
    camp-paid-card-ref/c01_free_frost.jpg          besplatna, recept „camp"
    camp-paid-card-ref/c02_free_lantern_ready.jpg  besplatna, spremna
    camp-paid-card-ref/c03_free_amber.jpg          besplatna
    camp-paid-card-ref/c04_paid_moonlit_warren.jpg plaćena danas (samo boja)
    camp-paid-card-ref/c05_paid_coral_tide.jpg     plaćena danas
    camp-paid-card-ref/c06_paid_starfall_glade.jpg plaćena danas
  game/scripts/run/seed_visual.gd, coin_visual.gd, seed_pickup.gd, coin.gd,
    player.gd, run_controller.gd, run_ring_fx.gd
  game/scripts/ui/run_pickup_feed.gd
  game/scripts/visual/ui_run.gd
  game/data/pip/animations.json  (pickup_coin, pickup_seed)
  game/data/pip/rig.json  (pogled top)
  game/data/seasons/seasons_kit.json  (kits[id].camp, shapes, surfaces.camp)
  game/scripts/camp/season_link_card.gd
  design_handoff_pip/, design_handoff_run/, design_handoff_run_hud_v2/,
    design_handoff_seasons/, design_handoff_camp_v3/  (tvoji paketi)

A. PICKUPI U RUNU. Danas pickup nestane, pa iskoči bijeli prsten i „+1"
   leti u brojač. Nema osjećaja da ga je Pip uzeo; coin i sjeme isto;
   ★2/★3 i +2 se ne osjete; magnet ga samo izbriše na rubu kruga. Traži se:
   1. Idle na stazi: coin i sjemenka živi i čitljivi na svih 8 livada;
      rijetkost ★2/★3 vidljiva bez brojanja.
   2. Magnet: pickup DOLETI do Pipa (luk, 0,12–0,2 s); pravilo „u krugu =
      pokupljeno" ostaje.
   3. Dodir SA Pipom: coin (okrene se / uskoči), sjeme (iščupa se i skoči u
      šape / ruksak), veći trenutak za ★2/★3, jasno „dvije" za twin +2, niz
      coina pojačava efekat (5 u sekundi mora izgledati dobro).
   4. Pip reakcije (pogled top): pickup_coin, pickup_seed, pickup_seed_rare,
      pickup_twin — overlay, ne prekidaju trčanje.
   5. Let „+1" do CoinChipa / SeedChipa i trzaj brojača.

B. CAMP KARTICE PLAĆENIH SEZONA. Besplatne kartice (Frost, Lantern, Amber)
   imaju sezonski crtež — Season Kit recept „camp". Kad su sve besplatne
   otključane, ista kartica nudi plaćenu sezonu sa cijenom, ali plaćene
   (Moonlit Warren, Coral Tide, Starfall Glade, Ember Fen) nemaju recept,
   pa su samo obojene. Traži se:
   1. Recept „camp" za sve 4, isti format i nivo detalja kao besplatni.
   2. Raspored plaćene kartice: ime + dugme sa CIJENOM, bez coina i ★3;
      ispod šta se dobija (cvijeće sezone, „Premium"); razlikuje se od
      besplatne, ali ista porodica.
   3. Stanja: price, buying, burst, failed. Čitljiv tekst i na tamnim
      sezonama (predloži ink po sezoni, ≥ 4,5:1).

PERFORMANSE (MORA, §5): A — ≤ 8 sprite-ova i ≤ 0,4 s po dodiru, ≤ 24
istovremeno, idle samo transformima, jedan atlas ≤ 512, SVG ≤ 60 KB.
B — ≤ 12 slojeva po kartici, statično, ništa van ruba. Brojeve napiši u
README.

TEHNIČKI (Godot 4.7, GL Compatibility, slabiji Android, 60 FPS): artboard
1080 x 1920, Pip ~150 px na y ~1570, svijet klizi 400 px/s; Camp kartica
1032 x 318. Stil kao Pip i Season Kit: ravne boje, obrub, jedna tvrda
sjena. BEZ blura, glowa, gradijenata i maski.

ISPORUKA (§6): novi folder design_handoff_run_pickups/, CIJELI U ZIPU za
preuzimanje u chatu (design/RunPickups.dc.html, CampPaidCards.dc.html,
Specs.dc.html, assets/pickups, assets/fx, godot/pickup_fx.json,
pickup_idle.json, animations_additions.json, seasons_kit_camp.json,
camp_paid_card.json, README sa § Odlučeno, § Performanse i § Samoprovjera
— 10 stavki iz §6.3, svaka da/ne, provjereno u pregledaču PRIJE nego
pošalješ zip).

NE RADI: nove pickupe, vrijednosti, magnet ili twin pravila, prepreke, grm,
traku napretka, ostatak HUD-a, besplatne kartice, cijene, zvuk. Jedan
dizajn, tvoj izbor, neka bude sočno i prelijepo.
```

## Povezano

- [[../_index|04-experience]]
- [[../../06-production/CHECKPOINT|CHECKPOINT]]
- [[run-cd-brief|Run]] · [[run-hud-v2-cd-brief|Run HUD v2]] · [[pip-cd-brief|Pip]]
- [[seasons-cd-brief|Season Kit]] · [[camp-season-link-cd-brief|Camp link kartica]]
- [[ispravke-1016-izvjestaj|ispravke-1016-izvjestaj]] — plaćena kartica u Campu (kod)
- [[../../01-vision/design-pillars|design-pillars]] — Pillar 2
