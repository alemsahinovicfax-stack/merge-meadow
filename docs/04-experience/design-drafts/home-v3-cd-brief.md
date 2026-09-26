---
type: dizajn
status: aktivan
milestone: "—"
tags: [dizajn, ui, home, sezone, claude-design, mockup]
povezano:
  - home-season-select-cd-brief
  - home-field-v2-cd-brief
  - hub-chrome-v2-cd-brief
  - camp-v2-cd-brief
  - art-direction
  - pristupacnost
  - CHECKPOINT
ai_sažetak: "Puni redizajn Homea: biranje sezona u dva taba (besplatne / premium), manje teksta, novo Play dugme, daily chest samo na polju, i tranzicija u polje sezone koju CD smije izmijeniti."
---

# Home — puni redizajn — Claude Design brief

> Biranje sezona je u igri od 2026-09-21 ([[home-season-select-cd-brief|Season Trail]]), polje sezone od 2026-09-25 ([[home-field-v2-cd-brief|pass 2]]). Ovo je **nova runda cijelog Homea**: biranje i ulaz u polje. Hub header i footer se ne diraju.

**Home** je stranica na kojoj igrač bira sezonu i odande ulazi u njenu livadu. Besplatne sezone se otključavaju igrom. Premium sezone se plaćaju.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | cijeli fajl (§1–§8) | Šta mora, šta smije, mjere i isporuka |
| **Ti** | §9 | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §3, §4, §10 | Današnje vrijednosti i mapa u Godot |

**Prije slanja prompta: commitaj i pushaj na `master`** — CD čita fajlove iz repoa po tačnoj putanji.

## 1. Zašto

Ekran radi, ali priča previše i Play na dnu ne izgleda kao glavni potez. Igrač treba da razumije besplatno i plaćeno bez uputstva, da prepozna cvijet, i da ulazak u livadu osjeti kao otvaranje, ne kao skok na drugi ekran.

Daily chest je **već skinut** s biranja sezona. Ostaje samo na polju, gore lijevo, kao Gift. Ne vraćaj ga na biranje.

## 2. Pravila koja ostaju FIKSNA

Brojevi i tok se **ne diraju**. Mijenja se kako izgledaju i kako se ulazi u polje.

| Pravilo | Vrijednost |
|---|---|
| Besplatne sezone | 4, redom: Country Bloom → Frost Orchard → Lantern Meadow → Amber Canopy. Sljedeća traži **500 coina + 20 ★3 cvjetova** prethodne. Daleka sezona se ne otvara dok prethodna nije otključana. |
| Premium sezone | 4, plaćaju se: Moonlit Warren, Coral Tide, Starfall Glade, Ember Fen (Ember je „coming soon“, bez cijene). Kupljena se odmah može igrati. |
| Sezona u kojoj se igra | jedna aktivna. Listanje kartica je ne mijenja. |
| Play, tri koraka | 1) kartica nije ta sezona → Play je **vrati** na nju. 2) na njoj, polje zatvoreno → Play **otvara polje**. 3) polje otvoreno → Play **pali run**. |
| Tap na otključanu karticu | i dalje smije otvoriti polje. |
| Polje | livada je cijela stranica. Pip, 13 mjesta, korpa (jedan slot, +5 % spawn, zaključana do prvog mergea), Magnet i Loot Boost (nivoi 0–4), Gift, donji red Seasons · Play · Endless. Endless tek kad je tutorial gotov. |
| Gift | samo na polju. Roze tačka dok dnevni poklon čeka. |
| Swipe | vodoravni swipe po praznom dijelu i dalje lista hub. Kontrole ga blokiraju. |
| Header / footer | chrome v2, 143 / 144, ne dirati. |

## 3. Šta se mijenja

Tačke 1–5 su **obavezne**. Sve ostalo na Homeu — raspored, oblik kartice, kako se sezona bira — tvoja je odluka. Jedan dizajn. Neka bude lijep.

1. **Dva taba: Free i Premium.** Besplatne i plaćene sezone više nisu jedna traka. Premium se vidi kao nešto što se kupuje, bez rečenice koja to objašnjava.
2. **Manje teksta.** Danas kartica nosi natpise tipa „FREE · 1 OF 4“, „6 flowers · 3 shown“, tagline, „Open meadow“ + „field · upgrades“, „PREVIEW · PREMIUM“, „Get … Garden“, „no price yet · preview the flowers“, „Needs 500 coins + 20 flowers“. Ostavi samo ono bez čega se igrač ne snađe. Ime sezone i ime cvijeta koji fali smiju ostati.
3. **Play na biranju.** Današnje dugme je 836 × 180, peach, na dnu, s diskom ▶ i podnaslovom. Igraču se ne sviđa. Napravi Play koji se osjeća kao glavni potez, a i dalje radi tri koraka iz §2. Ne širi ga preko cijele širine samo zato što chest više nije tu.
4. **Daily chest nije na biranju.** Na polju Gift ostaje (180 × 180, gore lijevo, ispod njega korpa istog okvira).
5. **Prelaz biranje → polje.** Danas se kartica (radius 36, rub 8) razvuče u cijelu livadu. Smiješ tu animaciju promijeniti. Mora se vidjeti da je livada **ta** sezona koja se otvara, i nazad (Seasons) da je povratak na biranje, ne drugi svijet. Polje samo: livada, Pip, cvijeće, Gift, korpa, nadogradnje, Seasons · Play · Endless — mehanika iz §2 ostaje; smiješ dotjerati kako prelaz izgleda.

Cvijet na kartici sezone već puni svoj krug odrezanim crtežom. Ne crtaj novi art cvijeta.

## 4. Današnji raspored (orijentacija, ne obaveza)

Stranica 1080 × 1633, od y = 143.

| Blok | Mjesto |
|---|---|
| Kartica sezone | 1032 × 1136 na (24, 167) |
| Dock tokena | 1080 × 222 na (0, 1327) |
| Play red | 1032 × 180 na (24, 1573). Play je 836 × 180. Chest je skriven, rupa desno ostaje dok je ti ne riješiš. |

Polje (kad je otvoreno) je cijela ta stranica. Chrome pluta: Gift + korpa gore lijevo (oba 180), nadogradnje gore desno, dolje Seasons 236 × 124 · Play 432 × 140 · Endless 236 × 124.

Boje livade po sezoni: `#E6F2DB` `#D1E6FF` `#EBD6FF` `#FFEBC7` `#B8BDFF` `#FFE0D6` `#DBCCFF` `#FFC79E`. Tri trake svjetline (nebo, daljina, prednji plan). Jedno rješenje za sve.

## 5. Paleta i tehnika

Postojeći tokeni: `game/scripts/visual/ui_stage.gd`, `ui_home_field.gd`. Warm white `#FFF8F0`, ink `#2D3436` / `#1A1A14`, peach `#FFB88C`, coin gold `#FFD56B`, mint `#A8E6CF`. Nova boja samo kao svjetlija ili tamnija varijanta, označena u README.

Artboard 1080 × 1920. Paneli = ravna boja, radius, rub, jedna sjena. Bez blura i 3D. Animacije = tween. **Najviše jedan loop** na ekranu. Tekst koji ostane ≥ 34 px. Dodir ≥ 120 px. Kontrast teksta ≥ 4,5:1.

## 6. Isporuka

### 6.1 Stanja

1. **Free, sezona u kojoj se igra** — Play vodi u polje.
2. **Free, listaš zaključanu** — vidi se da Play vraća na sezonu u kojoj se igra, ne da pali run.
3. **Free, sljedeća sezona se može otključati** i **još fali** (500 + 20).
4. **Premium tab** — kupovna sezona s cijenom, kupljena, i Ember „coming soon“ bez cijene.
5. **Prelaz** — biranje se otvara u polje, i Seasons vraća nazad. Dovoljna su 2–3 kadra ili opis trajanja u Specs.
6. **Polje** — Gift čeka (roze tačka), korpa, Play u donjem redu pali run. Dvije livade za kontrast: Amber `#FFEBC7` i Moonlit `#B8BDFF`.

### 6.2 Paket

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_home_v3/
  README.md                 šta otvoriti · § Odlučeno · § Prelaz (trajanje, šta se
                            animira) · § Šta se briše · § Ideje van zadatka
  design/
    HomeScreen.dc.html      biranje; prop scene i tab (free|premium)
    FieldScreen.dc.html     polje poslije prelaza; prop season
    Home Specs.dc.html      anatomija, tri koraka Playa, prelaz, oba taba
    support.js · icons/
  godot/
    home_v3_export.json     meta · tokens · layout · components · scenes ·
                            animations · strings_en · godot_map · decisions
    ui_home_v3.gd           nove/izmijenjene konstante, isti nazivi gdje postoje
                            (ui_stage.gd / ui_home_field.gd)
    home_tree.txt
    README.md               red prenosa
```

**Imena slojeva:** `SeasonSelect`, `FreeTab`, `PremiumTab`, `SeasonCard`, `SeasonRoster`, `PlayButton`, `FieldPage`, `Meadow`, `GiftChest`, `BasketButton`, `UpgradesButton`, `BottomRow`, `SeasonsButton`, `FieldPlayButton`, `EndlessButton`, `OpenTransition`.

## 7. Ne tražimo

- Hub header i footer.
- Camp, Journal, Shop, Arena, Run.
- Novi art cvijeta i Pipa.
- Daily chest na biranju.
- Vraćanje Playa na „odmah u run“ s kartice.
- Više varijanti za biranje — jedan dizajn.

## 8. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj** (vidi §0).

```
Radim PUNI redizajn HOME stranice mobilne igre. Home je mjesto gdje igrač
bira sezonu i ulazi u njenu livadu.

Igra: Merge Meadow — casual F2P merge/runner hibrid, portrait, flat pastel
cartoon (bez pixel-arta, bez 3D). Mood: cozy livada. Neka dizajn zaista
očara — ovo je ekran koji igrač vidi prvi.

Tvoja referenca je jedan fajl u repou (master), pročitaj ga po ovoj tačnoj
putanji:
  docs/04-experience/design-drafts/home-v3-cd-brief.md
Ako se ovaj prompt i fajl razlikuju, važi fajl. §10 briefa (ako ga vidiš
kao prenos) možeš preskočiti — mapa za agenta je u §6 i na dnu fajla nije
obavezna za tebe.

Kontekst, ne precrtavaj hub chrome:
  design_handoff_home_v2/design/SeasonStage.dc.html
  design_handoff_home_field_v2/design/FieldScreen.dc.html
  design_handoff_hub_chrome_v2/design/HubChromeScreen.dc.html
  game/scripts/visual/ui_stage.gd
  game/scripts/visual/ui_home_field.gd

TVOJ ZADATAK: Home priča previše, a Play na dnu ne djeluje kao glavni potez.
Besplatne i plaćene sezone moraju biti dva taba. Daily chest NIJE na biranju
— već je skinut; ostaje samo Gift na polju sezone.

JEDAN DIZAJN. Ne pravi smjerove ni varijante. Kad imaš dilemu, odluči sam i
napiši razlog u jednoj rečenici u README § Odlučeno. Imaš slobodu rasporeda,
oblika kartice i animacije. Obavezne su samo ove tačke (detalji u fajlu):

1. Dva taba: Free i Premium. Premium se plaća. Ember Fen je "coming soon",
   bez cijene. Bez rečenice koja objašnjava razliku — neka se vidi.
2. Manje teksta. Ime sezone i, kad fali cvijet, ime tog cvijeta smiju ostati.
   Natpisi tipa "FREE · 1 OF 4", "6 flowers · 3 shown", "field · upgrades",
   "no price yet · preview the flowers" nisu svetinja.
3. Play na biranju iznova. Danas je 836 x 180, peach, na dnu, s diskom i
   podnaslovom. Igraču se to ne sviđa. Tri koraka MORAJU ostati:
   - lista zaključanu ili premium karticu → Play vrati na sezonu u kojoj se igra
   - na toj sezoni → Play otvori polje (livadu)
   - na polju → Play upali run
4. Prelaz biranje → polje. Danas se kartica razvuče u livadu. Smiješ animaciju
   promijeniti. Mora se osjetiti da se otvara BAŠ ta sezona, i da Seasons
   vraća nazad. Uzmi u obzir i polje: livada je cijela stranica, Gift i korpa
   gore lijevo, nadogradnje gore desno, dolje Seasons · Play · Endless.

MORA OSTATI:
- 4 besplatne sezone redom, otključavanje 500 coina + 20 ★3 prethodne.
- 4 premium sezone, pravi novac, Ember bez cijene.
- Gift samo na polju, roze tačka dok poklon čeka. Korpa zaključana do prvog
  mergea, +5 % spawn. Endless tek poslije tutoriala.
- Header 143 i footer 144 (chrome v2).
- Tekst koji ostane >= 34 px, dodir >= 120 px.
- Cvijet crta igra — ne treba novi art.

TEHNIČKI (Godot 4, OpenGL, slabiji Android): artboard 1080 x 1920, stranica
između chromea je 1080 x 1633, sve u px te baze (prenos 1:1). Paneli = ravna
boja + alpha, radius, border, jedna sjena. Tween, najviše jedan loop.
Bez blura, gradijenata na panelima i 3D-a.

ISPORUKA (§6): stanja iz §6.1 i paket TAČNO po strukturi iz §6.2 —
design_handoff_home_v3/ s README.md, design/ (HomeScreen.dc.html,
FieldScreen.dc.html, Home Specs.dc.html, support.js) i godot/
(home_v3_export.json, ui_home_v3.gd, home_tree.txt, README.md).
Na kraju mi daj ZIP ZA PREUZIMANJE u chatu s cijelim folderom.

IMENA SLOJEVA: SeasonSelect, FreeTab, PremiumTab, SeasonCard, SeasonRoster,
PlayButton, FieldPage, Meadow, GiftChest, BasketButton, UpgradesButton,
BottomRow, SeasonsButton, FieldPlayButton, EndlessButton, OpenTransition.

NE RADI: hub header/footer, Camp, Journal, Shop, Arena, Run, novi art
cvijeta, daily chest na biranju, Play koji s kartice odmah pali run.
Ideje van zadatka navedi odvojeno na kraju README-a.
```

## Povezano

- [[home-season-select-cd-brief|home-season-select-cd-brief]] — biranje, Season Trail
- [[home-field-v2-cd-brief|home-field-v2-cd-brief]] — polje, livada kao stranica
- [[hub-chrome-v2-cd-brief|hub-chrome-v2-cd-brief]] — header i footer
- [[../../06-production/CHECKPOINT|CHECKPOINT]]
