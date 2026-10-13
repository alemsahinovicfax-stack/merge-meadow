---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, ui, settings, journal, ormar, shop, pip, claude-design, mockup]
povezano:
  - journal-cd-brief
  - pip-cd-brief
  - hub-chrome-v2-cd-brief
  - popups-cd-brief
  - design-pillars
  - CHECKPOINT
ai_sažetak: "Brief za Claude Design: zlatni okvir Albuma koji radi sa skrolom, Classic Pip kao pravi skin svuda, novi Pip umjesto starog crteža u Shopu (Starter Pack, All set) i pun Settings ekran (muzika, SFX, vibracija, pokreti, kupovine, privatnost, podrška, dev sekcija)."
---

# Ispravke + Settings — Claude Design brief

> **Status 2026-10-12: paket stigao i prenesen u igru** — vidi [[ispravke-settings-izvjestaj]]. Paket: `design_handoff_settings_fixes/`.
>
> ~~Status 2026-10-12: brief spreman, čeka CD.~~ Prompt je u §9. Slike današnjeg stanja: `ispravke-settings-ref/`.

Četiri stvari u jednom paketu:
- **A.** Zlatni okvir Albuma (Journal) ne radi sa skrolom.
- **B.** Classic Pip (zeleni, zadani) mora biti pravi skin svuda.
- **C.** U Shopu je ostao stari crtež Pipa.
- **D.** Settings: dugme postoji, ekran ne postoji.

Komunikacija sezona između Homea, polja, Arene, Campa, runa i Shopa **nije za CD** — to su bile greške u kodu, popravljene 2026-10-12 (`season_sync_smoke.gd`).

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | §1–§8 + slike u `ispravke-settings-ref/` | Šta je pokvareno, šta mora, šta se isporučuje |
| **Ti** | **§9** | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §3–§6 | Današnje mjere iz koda i kako se prenosi |

**Prije slanja prompta: commitaj i pushaj na `master`.** CD čita fajlove iz repoa po tačnoj putanji.

## 1. Pravila koja ostaju FIKSNA

| Pravilo | Vrijednost |
|---|---|
| Artboard | 1080 × 1920, portret; sve mjere u px te baze |
| Hub | header gore (čipovi coini / sjemenke / cvijeće + zupčanik), footer dolje **144 px** s 5 tabova; stranica je između njih |
| Stil | flat, pastel, ravne boje, radius, rub, jedna tvrda sjena. **Bez blura, glowa i gradijenata** |
| Tekst | ≥ 34 px, brojevi ≥ 56 px, kontrast ≥ 4,5 : 1 |
| Dodir | svaka kontrola ≥ 120 × 120 (red u listi ≥ 120 visine) |
| Pip | art, poze i animacije su iz `design_handoff_pip/` (rig: `game/data/pip/rig.json`, skinovi `game/data/pip/skins.json`) — ne crta se novi Pip |
| Pillar 2 | ništa se ne prodaje novo; Classic Pip je besplatan i uvijek tvoj |
| **Rezanje** | GL Compatibility na slabijem Androidu i na laptopu **ne reže crtanje** (ni `clip_contents` ni ScrollContainer — `greske-katalog.md` #24). Sve što skrol gura van svog prozora mora pokriti **neproziran** element (traka, rub, header). Ne oslanjaj se na masku |

## 2. Šta se traži

Sve četiri stavke su **obavezne**. Izgled je tvoja odluka. Jedan dizajn.

### A. Album — zlatni okvir koji radi sa skrolom

**Danas** (`01–03`):
- Zlatni okvir (`journal_gold`, kupuje se u Shopu) je jedan rub preko cijele stranice Albuma: 12 px od ivice, ukupno 13 px (3 tamni + 7 zlatni + 3 tamni), radius 38. Iznad je zlatna pločica „Bloom Album".
- Lista sezona i cvijeća skroluje ispod okvira.
- **Greška:** donji dio okvira prelazi preko redova (`02`). Redovi izlaze ispod donje ivice okvira, između okvira i footera, jer se ništa ne reže.
- Bez okvira („Plain Album") isti višak ode ispod footera i ne vidi se.

**Mora:**
1. Okvir ima jasan **prozor** za listu: gore pločica + sažetak, dolje neproziran završetak okvira (traka, polica, ukras — tvoj izbor) ispod kojeg redovi nestanu.
2. Na vrhu skrola, u sredini i na dnu (zadnji red cijelo vidljiv iznad donjeg dijela okvira) — tri stanja.
3. Ništa iz liste se ne vidi van okvira, ni dok skrol odskoči.
4. Isto pravilo za Plain Album (bez zlata), da oba izgledaju završeno.
5. Mjere prozora liste i neprozirnih dijelova u px (agent ih prenosi 1:1).

### B. Classic Pip — pravi skin

**Danas** (`04`, `05`):
- U Ormaru, slot Pip, prva kartica je **„Classic Pip"** (zeleni). Tehnički je to „Default": tap skida kupljeni skin.
- Igrač ga ne doživljava kao skin: misli da zeleni Pip ne postoji.
- U Shopu (Looks) su samo Pip Blossom i Pip Sky — **tako i ostaje**, Classic se ne prodaje.

**Mora:**
1. Classic Pip je **ravnopravna kartica skina**: ista veličina, ista poza na pregledu (iz `design_handoff_pip/`), ime „Classic Pip" i oznaka da je besplatan / uvijek tvoj (npr. „Free" ili „Original" — tvoj izbor teksta).
2. Stanja kartice: nošen (kvačica „Wearing"), nije nošen, tap. Isto kao Blossom i Sky.
3. **List površina** gdje se vidi skin (`applies_to` u `game/data/cosmetics/cosmetics.json`):
   - polje;
   - kartica sezone;
   - Arena;
   - run (odozgo);
   - HUD runa (glava na traci napretka);
   - Camp;
   - Shop pregledi.

   Za svaku površinu pokaži Classic, Blossom i Sky jedan pored drugog. Ako neka površina danas nema pravi izgled za neki skin, nacrtaj ga.
4. Shop: Classic se nigdje ne nudi na prodaju.

### C. Stari Pip u Shopu

**Danas** (`06`, `07`):
- **Starter Pack** (Shop › Support) crta „Pip Blossom" starim crtežom zeca (`pip_idle.svg` s promjenom boje), a ne novim rigom. Isto je i u stanju „Expired".
- **Boosters › „All set here"** (kad nema ponude) crta istog starog Pipa u nošenom skinu.

**Mora:**
1. Pločica Starter Packa s Pipom u **Blossom** skinu iz riga (poza po tvom izboru, kao na Looks kartici).
2. „All set here" s Pipom iz riga u **nošenom** skinu (Classic / Blossom / Sky).
3. Stanja: dostupno, kupljeno, isteklo (Starter Pack).

### D. Settings — pun ekran

**Danas** (`08`): zupčanik gore desno u headeru huba pokaže toast „Settings coming soon".

**Mora — ulaz i oblik:**
- Otvara se zupčanikom iz bilo koje stranice huba. Zatvara se X-om, Android Back-om i (ako je sheet) tapom van.
- Pun ekran ili visok sheet — tvoj izbor. Mora stati u 1920 sa skrolom kad je potrebno, i poštovati safe area.

**Mora — sekcije i opcije** (copy na engleskom; tačan tekst je tvoj):

| Sekcija | Opcija | Kontrola | Napomena |
|---|---|---|---|
| **Sound** | Music | slider 0–100 + mute | Zvuk još ne postoji u igri — slider mora raditi i bez njega (vrijednost se pamti) |
| | Sound effects | slider 0–100 + mute | Pri puštanju slidera kratak „tick" (kad SFX stigne) |
| | Vibration | toggle | Haptika na merge / pickup (kasnije) |
| **Gameplay** | Reduce motion | toggle | Već postoji u kodu (`GameState.reduce_motion`): manje treskanja i skokova |
| **Purchases** | Restore purchases | dugme | Stanja: spremno, radi, gotovo, greška. Već postoji u Shop › Support — ovdje je isto |
| | Remove Ads | red sa statusom | „Active" ako je kupljeno; inače link na Shop |
| **Privacy & help** | Privacy choices | dugme | Ponovo otvara izbor pristanka za reklame (AdMob, EU) |
| | Privacy policy | link | Otvara web stranicu |
| | Contact support | link | E-mail `mergemeadow.support@gmail.com` |
| | Credits | red | Mali ekran ili sheet |
| | Version | tekst | npr. „v1.0.0 (42)" |

**Opcionalno — tvoja odluka, napiši zašto:**
- „Replay tutorial" ili „How to play" (mala pomoć).
- **Reset progress** s dvostrukom potvrdom (opasna zona).

**Dev sekcija** (samo u debug buildu, ne ide u store, može biti skromna):
- unlock all seasons;
- reset seasons to S1 + S2;
- +1000 coins;
- reset tutorial.

Do 2026-10-12 hub je to radio sam pri svakom otvaranju i brisao pravi napredak. Sada mora biti samo ručno.

**Mora — komponente i stanja:**
- Slider (prazan, sredina, pun, mute, dok se vuče), toggle (on / off / pritisnut), red-link, red s vrijednošću, dugme s radnjom i njegova stanja.
- Dijalog potvrde (ako crtaš Reset): pitanje, „Cancel" i crveno / upozoravajuće dugme.
- Toast posle radnje (npr. „Purchases restored").
- Promjena se primjenjuje odmah (nema „Save").

## 3. Današnje stanje (iz koda)

| Šta | Gdje | Mjere / vrijednosti |
|---|---|---|
| Album stranica | `game/scenes/ui/collection_journal.tscn`, `game/scripts/ui/collection_journal.gd` | `RootVBox` (PageHead + `ListScroll`), zlatni okvir = `GoldenFrameEdge` (12 px od ivice, rub 13, radius 38) + `GoldenFrameGold` (15 px, rub 7, radius 35), oba z 4 preko svega; zaglavlje sa zlatom 219 visine, lijevi pad 44 |
| Boje okvira | `game/scripts/visual/ui_journal.gd` | `COIN_GOLD #FFD56B`, `GOLD_EDGE #D6A82F`, stranica `#FFF8F0` |
| Ormar | `game/scripts/ui/wardrobe_sheet.gd`, `item_card.gd`, `item_preview.gd` | slot Pip: `allow_default`, `default_title` „Classic Pip"; kartica 240 × 272 |
| Skinovi | `game/data/pip/skins.json` | `classic`, `blossom`, `sky` (+ `showcase_anim`, `signature_anim`) |
| Starter Pack | `game/scripts/ui/shop_support_card.gd` | pločice: 100 coina · Pip Blossom · 5 sjemenki × 10; Pip = stari `PipAssets.get_texture` |
| All set | `game/scripts/ui/shop_screen.gd` (`_AllSet`) | Pip 180 px, stari crtež |
| Zupčanik | `game/scripts/meta/meta_hub_controller.gd` (`_on_settings_pressed`) | danas samo toast |
| Reduce motion | `game/scripts/autoload/game_state.gd` | `reduce_motion` |
| Reklame | `game/scripts/monetization/ad_manager.gd` | rewarded (×2 loot, revive) |
| Privatnost | `docs/05-technical/privacy-policy-draft.md` | URL na GitHub Pages |

## 4. Kako će se ugraditi (da export odgovara)

- Postavke se pamte odvojeno od napretka (`user://settings.cfg`), pa ih reset napretka ne briše.
- Zvuk: audio busovi `Music` i `SFX`; slider 0–100 se mapira na glasnoću busa, mute = bus mute.
- Settings je nova stranica ili sheet u hubu; zupčanik ga otvara umjesto toasta.

## 5. Isporuka

### 5.1 Stanja

1. **Album sa zlatom:** vrh, sredina, dno skrola. Isto za Plain Album.
2. **Ormar, slot Pip:**
   - nošen Classic;
   - nošen Blossom;
   - nošen Sky;
   - samo Classic (ništa kupljeno).
3. **Classic / Blossom / Sky** na svakoj površini iz §2.B.3.
4. **Starter Pack:** dostupno, kupljeno, isteklo. **All set here** u sva tri skina.
5. **Settings:**
   - cijeli ekran, gore i dole skrolovano;
   - svaka komponenta u svim stanjima;
   - Restore u sva 4 stanja;
   - Dev sekcija;
   - (opcionalno) Reset s potvrdom.

### 5.2 Paket

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_settings_fixes/
  README.md                 šta otvoriti · § Odlučeno · § Šta se briše ·
                            § Performanse · § Samoprovjera · § Ideje van zadatka
  design/
    Album.dc.html           okvir + skrol (prop frame: gold / plain, scroll: top / mid / end)
    Wardrobe Pip.dc.html    Classic kao pravi skin + površine
    Shop Pip.dc.html        Starter Pack + All set
    Settings.dc.html        cijeli ekran, sva stanja
    Specs.dc.html           anatomija i mjere svega gore
    support.js · icons/
  assets/                   novi SVG-ovi (ikone settingsa, ukrasi okvira…)
  godot/
    settings_export.json    meta · tokens · layout · components · states ·
                            strings_en · godot_map · decisions
    ui_settings.gd          konstante za Settings
    ui_journal.gd           samo izmjene za okvir (isti nazivi gdje postoje)
    settings_tree.txt       stablo čvorova + red prenosa
```

**Imena slojeva:** `SettingsScreen`, `SettingsSection`, `SettingRow`, `VolumeSlider`, `ToggleSwitch`, `RestoreButton`, `DevSection`, `AlbumFrame`, `AlbumListWindow`, `AlbumFrameFoot`.

### 5.3 Performanse (MORA, u README)

- Ništa se ne crta iznova svaki frejm: slider pomjera ručicu transformom, toggle je tween pozicije / boje.
- Okvir Albuma se ne crta iznova dok se skroluje (neproziran dio je statičan, iznad liste).
- Animacije ≤ 0,3 s; ukupno novih SVG-ova ≤ 60 KB. Brojeve napiši u README.

### 5.4 Samoprovjera (u README, svaka stavka da/ne, provjereno u pregledaču)

1. Ništa iz liste Albuma se ne vidi van okvira, na vrhu, u sredini i na dnu skrola; isto za Plain Album.
2. Classic Pip je kartica skina kao Blossom i Sky, s oznakom da je besplatan; nije u Shopu.
3. Classic, Blossom i Sky su prikazani na svakoj površini iz §2.B.3.
4. Starter Pack i All set koriste Pipa iz riga, ne stari crtež.
5. Settings ima sve obavezne opcije iz §2.D i Dev sekciju.
6. Slider, toggle, Restore i dijalog imaju sva stanja.
7. Sve kontrole ≥ 120 × 120; tekst ≥ 34 px; kontrast ≥ 4,5 : 1.
8. Nigdje blur, glow ni gradijent; nigdje se ne oslanjaš na rezanje (maska / clip).
9. Budžet iz §5.3 je ispunjen i napisan u README.

## 6. Ne tražimo

- Zvukove, muziku ni SFX (to je zaseban posao) — samo kontrole.
- Novi Pip, nove skinove ili nove proizvode u Shopu.
- Jezike (EN only), cloud save, nalog, leaderboard.
- Promjene ostatka Journala, Ormara i Shopa osim gore navedenog.
- Više varijanti — jedan dizajn.

## 7. Scope

Settings ekran, ispravke okvira Albuma, Classic Pip i novi Pip u Shopu idu u launch (M8) — upisano u `scope-i-granice.md` 2026-10-12 na zahtjev. Ništa se ne prodaje novo, pa Pillar 2 ostaje netaknut.

## 8. Napomena za agenta (prenos)

- Okvir: neproziran donji dio iznad liste, `ListScroll` završava iznad njega; provjera snimkom na vrhu / sredini / dnu (kao `ispravke-settings-ref/01–03`).
- Classic: kartica u `wardrobe_sheet.gd` / `item_card.gd`; površine provjeriti postojećim capture skriptama.
- Starter Pack i `_AllSet`: `ItemPreview` / `UiPip` umjesto `PipAssets.get_texture`.
- Settings: `user://settings.cfg`, busovi `Music` / `SFX`, Dev sekcija samo `OS.is_debug_build()`; benchmark animacija po pravilu CD paketa (`performanse.md`).

## 9. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj na `master`.** Priloži i ovaj `.md` fajl.

```
Radim paket ispravki + novi Settings ekran za mobilnu igru Merge Meadow
(portrait, flat pastel cartoon). Četiri stvari, sve obavezne, jedan dizajn.

Pročitaj po ovim tačnim putanjama (repo, master):
  docs/04-experience/design-drafts/ispravke-settings-cd-brief.md
    -> §1 (fiksno), §2 (šta se traži, A–D), §3 (današnje stanje iz koda),
       §5 (stanja, paket, performanse, samoprovjera)
  docs/04-experience/design-drafts/ispravke-settings-ref/  (8 slika danas)
  game/scenes/ui/collection_journal.tscn
  game/scripts/ui/collection_journal.gd, game/scripts/visual/ui_journal.gd
  game/scripts/ui/wardrobe_sheet.gd, item_card.gd, item_preview.gd
  game/data/cosmetics/cosmetics.json, game/data/pip/skins.json
  game/scripts/ui/shop_support_card.gd, game/scripts/ui/shop_screen.gd
  game/scripts/meta/meta_hub_controller.gd
  design_handoff_journal/, design_handoff_wardrobe/, design_handoff_pip/,
  design_handoff_shop_v2/, design_handoff_hub_chrome_v2/,
  design_handoff_popups/                      (tvoji paketi)

ŠTA TRAŽIM:

A. ALBUM — ZLATNI OKVIR SA SKROLOM: danas je okvir jedan rub preko cijele
   stranice, a lista skroluje ispod njega pa redovi izlaze ispod donje
   ivice okvira (slika 02). Napravi okvir s jasnim prozorom za listu i
   NEPROZIRNIM donjim završetkom ispod kojeg redovi nestanu. Vrh, sredina,
   dno skrola. Isto pravilo za Plain Album. VAŽNO: igra ne reže crtanje
   (GL Compatibility), pa sve van prozora mora pokriti neproziran element.

B. CLASSIC PIP KAO PRAVI SKIN: zeleni Classic Pip je danas „Default"
   kartica u Ormaru i igrač misli da ne postoji. Napravi ga ravnopravnom
   karticom skina (ista poza i veličina kao Blossom i Sky, oznaka da je
   besplatan / uvijek tvoj, stanje Wearing). Pokaži Classic / Blossom / Sky
   na svim površinama: polje, kartica sezone, Arena, run (odozgo), HUD
   runa, Camp, Shop pregledi. U Shopu se Classic NE prodaje.

C. STARI PIP U SHOPU: Starter Pack (Support) i „All set here" (Boosters)
   još crtaju stari crtež zeca. Zamijeni Pipom iz riga (design_handoff_pip):
   Starter Pack u Blossom skinu (dostupno / kupljeno / isteklo), All set u
   nošenom skinu.

D. SETTINGS — PUN EKRAN: zupčanik u headeru huba danas samo kaže „coming
   soon". Napravi cijeli ekran (ili visok sheet), zatvara se X / Back.
   Sekcije: Sound (Music i Sound effects: slider 0–100 + mute; Vibration
   toggle), Gameplay (Reduce motion), Purchases (Restore purchases s
   4 stanja, Remove Ads status), Privacy & help (Privacy choices za
   reklame, Privacy policy, Contact support, Credits, Version). Dev sekcija
   samo za debug build (unlock all seasons, reset seasons, +1000 coins,
   reset tutorial). Opcionalno: How to play, Reset progress s dvostrukom
   potvrdom — odluči i napiši zašto. Zvuk još ne postoji: kontrole moraju
   raditi i bez njega. Promjena se primjenjuje odmah.

FIKSNO: header i footer huba (144), Pip art i animacije iz Pip paketa,
ništa novo se ne prodaje (Pillar 2), EN tekst.

PERFORMANSE (MORA, §5.3): ništa se ne crta iznova svaki frejm; slider i
toggle transformom; okvir Albuma statičan dok se skroluje; animacije
<= 0,3 s; novi SVG <= 60 KB ukupno. Brojeve napiši u README.

TEHNIČKI (Godot 4.7, GL Compatibility, slabiji Android): artboard
1080 x 1920, sve u px te baze. Ravne boje, radius, rub, jedna tvrda
sjena. BEZ blura, glowa, gradijenata i maski. Tekst >= 34 px, brojevi
>= 56 px, kontrole >= 120 x 120, kontrast >= 4,5:1.

ISPORUKA (§5): novi folder design_handoff_settings_fixes/, CIJELI U ZIPU
za preuzimanje u chatu:
  design/Album.dc.html, Wardrobe Pip.dc.html, Shop Pip.dc.html,
  Settings.dc.html, Specs.dc.html, support.js, icons/
  assets/ (novi SVG)
  godot/settings_export.json, ui_settings.gd, ui_journal.gd (izmjene),
  settings_tree.txt
  README.md sa § Odlučeno, § Šta se briše, § Performanse i § Samoprovjera
  (9 stavki iz §5.4, svaka da/ne, provjereno u pregledaču PRIJE nego
  pošalješ zip).

NE RADI: zvukove ni muziku, nove skinove ili proizvode, jezike, cloud
save, ostatak Journala / Ormara / Shopa. Jedan dizajn, tvoj izbor, neka
bude lijep.
```

## Povezano

- [[../_index|04-experience]]
- [[../../06-production/CHECKPOINT|CHECKPOINT]]
- [[journal-cd-brief|Journal]] · [[pip-cd-brief|Pip]] · [[hub-chrome-v2-cd-brief|Hub chrome v2]] · [[popups-cd-brief|Popups]]
- [[../../05-technical/godot/greske-katalog|greske-katalog]] — #24 (rezanje u GL Compat)
- [[../../01-vision/design-pillars|design-pillars]] — Pillar 2
