---
type: iskustvo
status: aktivan
milestone: M8
tags: [dizajn, ui, home, sezone, polje, prelaz, claude-design, izvjestaj]
povezano:
  - home-v3-cd-brief
  - home-field-v2-izvjestaj
  - home-season-select-izvjestaj
  - changelog
ai_sažetak: "Izvještaj o prenosu design_handoff_home_v3 u Godot: runda 2 (2026-09-28) — biranje sezone u dva taba, kartica kao minijatura livade, Play u tri koraka i prelaz u kojem su ime, Pip i Play po jedan objekat; runda 3 (2026-09-29) — svih šest cvjetova na kartici i zaključana sezona pod velom s jednim katancem; runda 4 (2026-09-30) — imena cvijeća prestala se preklapati."
---

# Home v3 — izvještaj o prenosu

> Roditelj: [[04-experience/_index|04-experience]] · brief: [[home-v3-cd-brief]] (§9–§12 runda 2, § Implementacija) · datum: 2026-09-28

## Ukratko

Home ima novo biranje sezone i nov prelaz u polje, 1:1 po paketu `design_handoff_home_v3/` (runda 2).

- **Dva taba, Free i Premium.** Premium se vidi po zlatnom tabu, zlatnom unutrašnjem rubu kartice i zlatnoj cijeni. Nema rečenice koja to objašnjava.
- **Jedna kartica 1032 × 1160, i ona je minijatura livade.** Ima tri trake iste svjetline kao polje: ime, tri cvijeta u diskovima i jedan status. Pozadina stranice je najsvjetlija nijansa boje sezone.
- **Strelice, swipe i tačke.** Strelice (120) i swipe po kartici (60 px) listaju sezone u tabu. Tačke su samo indikator: peach tačka je sezona u kojoj se igra.
- **Play 520 × 180 u tri koraka.** Na tuđoj kartici je „Back" + disk sezone u kojoj se igra i vraća karticu. Na sezoni u kojoj se igra otvara polje. Na polju pali run. Stari Play 836 × 180, dock tokena i daily chest na biranju su nestali.
- **Prelaz 560 / 440 ms, jedan tween `u`.** Kartica se raširi u livadu. **Ime, Pip i Play su po jedan objekat** od kartice do polja. Nijedan kadar nije prazan, a predaja na `u = 1` je pikselski ista.

## Šta se vidi na ekranu

| Dio | Izgled |
|---|---|
| **Tabovi** | Staza 1032 × 124 (rgba .10, radius 62). Izabrani tab je krem (Free) ili zlatni (Premium), s rubom 3 i sjenkom 0 6 0. Ikone sjemena i dijamanta 56, tekst 46/900. |
| **Kartica** | 1032 × 1160 na (24, 172), radius 48, rub 4 i sjenka 0 12 0. Trake su nebo / daljina / prednji plan, na `round(h·.32)` i `round(h·.68)`: iste funkcije boja kao livada (`UiHomeField.meadow_sky/near`, zaokruženo na 8 bita). |
| **Cvijeće** | Od runde 3 svih šest u dva reda po tri (vidi [[#Runda 3 (2026-09-29)|§ Runda 3]]). ~~Tri diska 260 · 330 · 260 (gap 36, bočni spušteni 70): ★1 lijevo, ★3 u sredini, ★2 desno.~~ Cvijet koji igrač još nema je silueta (crno .28) u isprekidanom disku, s imenom ispod. |
| **Status** | `active`: Pip na kartici. `open`: krem kapija 150 s peach lukom, bez teksta. `locked`: dva čipa (coin x / 500, ★3 prethodne x / 20), mint kad je uslov ispunjen. `unlock`: zlatno „Unlock · 500". `buy`: zlatna cijena s draguljem. `owned`: mint „Yours". `soon`: isprekidano „Coming soon". Lokot 96 gore desno za locked / unlock / buy, a na premium tabu zlatni unutrašnji rub. |
| **Strelice i tačke** | Krugovi 120 na (52, 852) i (908, 852). Tačke su na y 1352 (24 / 64 × 24, gap 22). |
| **Play** | Peach pilula, rub 4, sjenka 0 10 0 α .30, ▶ + „Play" 76/900. U modu „Back" to je disk 104 (boja livade aktivne sezone + njen ★3 cvijet) + ‹ + „Back" 66. |
| **Toast** | Tamna pilula na y 1250 („Unlocked", „Yours"), 1,4 s. |
| **Polje** | Isto kao field v2. Seasons i Endless sada nose crtani ‹ i dvostruki prsten uz tekst 38/900, kao u paketu. Pip i sjenka cvijeta su iz `pip_idle.svg` i pilule. |

## Prelaz (§ Prelaz u README-u paketa)

Jedan `tween_method(_set_u)`: 0 → 1 za 560 ms, 1 → 0 za 440 ms, linearno. Geometrija ide na `ease_t(u)` (in-out cubic), a blijeđenja na sirovom `u`.

| Objekat | Šta radi |
|---|---|
| Kartica, rub, FieldClip | Rect (24, 172, 1032, 1160) → cijela stranica. Radius 48 → 0, rub 4 → 0, sjenka 12 → 0. Livada i chrome polja su klipovani na rect kartice, pa nema duhova ivica. |
| Ime (`SeasonName`) | Top 244 → 36, 80 → 56 px. Crta se iz najbliže veće cijele veličine fonta i skalira, pa je glatko. |
| Pip (`TravelPip`) | 230 na (425, 1027) → 190, stopala na kući (756, 1404). Na zatvaranju kreće sa stopala gdje je odšetao. |
| Play | Rect, rub, sjenka, tekst, trokut, gap i margina se interpoliraju. Na `u = 1` je FieldPlayButton 432 × 140. |
| Tabovi, strelice, tačke | Alpha 1 → 0 (u .02–.30). Tabovi se dižu 24 px. |
| Sadržaj kartice | Alpha 1 → 0 (u .02–.40). |
| Cvijeće livade | Od u .20 + i · 12 ms: alpha za 100 ms, scale .9 → 1 za 200 ms (ease out, pivot dolje-sredina). |
| Gift, korpa, nadogradnje, čip | Alpha 0 → 1 i y −16 → 0 (u .60–.92, ease out). |
| Seasons / Endless | Izlaze iza Playa: x ±254 → 0 (u .60–.92). |
| Trake livade | Ne crtaju se dok je `u < 1` (kartica JESTE livada). Na `u = 1` preuzimaju iste piksele. |

Pip hoda tek kad je prelaz gotov. Prsten oko prazne korpe (jedini loop) kreće tek na `u = 1`. Dok prelaz traje, ni biranje (tabovi, strelice, kartica, Play) ni chrome polja ne primaju dodir.

## Kako je provjereno

- **Paket runde 2 testiran u browseru** (Chromium, pravi klikovi i kontrolisan sat). Strelice, swipe, zaključan unos, Pip samo na aktivnoj sezoni i prelaz bez rupe rade. U mocku je ostala jedna greška: `OpenTransition` je izgubio `pointer-events:none`, pa pokriva tabove. U igri je taj kontejner `MOUSE_FILTER_IGNORE`.
- **Godot pored dizajna** (Xvfb + OpenGL, `scripts/dev/home_capture.gd`), slike u `design-drafts/home-v3-test/`:
  - `godot-vs-design-states.png`: svih sedam stanja §6.1.
  - `godot-vs-design-open.png` / `-close.png`: prelaz na istim tačkama `u`.
- **Predaja izmjerena pikselima:** kadar `u = 0.99` i kadar `u = 1` razlikuju se u 0 piksela. Pip na predaji je isti (661, 1214, 190). Jedina razlika poslije predaje je prsten korpe, koji tek tada krene.
- **Mutacijski test:** kad se strelice ili zaključavanje tabova namjerno pokvare (kao u rundi 1), `season_home_smoke` pada.

## Šta testirati u igri

1. Tapni ‹ i › na sezoni u kojoj se igraš: kartica se promijeni, polje se **ne** otvara.
2. Swipe po kartici lijevo i desno lista sezone. Kratak pomak vrati karticu na mjesto.
3. Premium tab otvara prvu premium sezonu (ili onu u kojoj se igraš). Free tab vraća na sezonu u kojoj se igraš.
4. Na tuđoj kartici Play kaže „Back" i vraća karticu. Na tvojoj otvara polje, a na polju pali run.
5. Otvori polje i gledaj prelaz: ime, Pip i Play putuju. Kartica nikad nije prazna i nema dva Play dugmeta.
6. Pusti Pipa da odšeta pa tapni Seasons: Pip se vraća na karticu s mjesta gdje je stao.
7. Tapni tab ili strelicu usred prelaza: ne smije se ništa promijeniti.
8. Na otključanoj sezoni u kojoj se ne igraš tapni kapiju: otvori se njeno polje i ona postaje aktivna.
9. S 500 coina i 20 ★3 tapni „Unlock": toast „Unlocked", Pip se pojavi na kartici.
10. Swipe na praznom pojasu lijevo ili desno od Playa mijenja hub stranicu. Swipe po kartici to ne radi.

## Odstupanja od paketa (namjerna)

- **Klik kroz `OpenTransition`:** vidi „Kako je provjereno". U igri kontejner ne prima dodir, pa tabovi rade.
- **Cvijeće na kartici** je pravi roster sezone, ne placeholderi iz mocka. „Fali" znači da cvijet nikad nije ubran (nema ga u `discovered_blooms`, u albumu ni u zalihi). Od runde 3 ih je šest.
- **Ime nosi svaki vidljivi cvijet**, i onaj koji je igrač već našao. Paket crta ime samo ispod cvijeta koji fali, ali tako kartica govori samo šta igraču nedostaje, a ne šta u sezoni raste — a to je ono po čemu se sezona bira. Pod velom (zaključana sezona) i dalje nema nijednog imena.
- **Sezone bez SVG crteža** (sve osim Country Blooma) crtaju isti proceduralni cvijet kao livada, pa kartica i polje ostaju isti.
- **Duga imena cvijeća** (npr. „Paper Lantern Bloom") prelamaju se u dva uravnotežena reda do 300 px, da ne pređu na susjedni disk.
- **Daleke free sezone** (iza sljedeće) pokazuju iste čipove uslova kao sljedeća. Mock je crtao samo sljedeću.
- **„★3" se crta** (zvijezda + „3"), jer Nunito nema ★.
- **Toast** nosi „Unlocked" / „Yours", a širina raste s tekstom (min 600).
- **Stanje „pritisnuto"** (nema ga u paketu): sjenka se spusti 4 px na Playu, strelicama, Unlocku, cijeni i kapiji.
- **Tutorial hint prve sesije** (nema ga u paketu): prsten je oko novog Playa (pilula), a oblačić je centriran na y 836, između cvijeća i Pipa.
- **Pozadina stranice** mijenja boju odmah, kao u HTML-u runde 2. `home_tree.txt` spominje tween od 220 ms.
- **Dock tokena je uklonjen.** Paket traži potvrdu da tokeni žive na polju ili runu, a u igri nigdje drugo nisu bili potrebni. Vidi „Otvorena pitanja".

## Testovi

- **`season_home_smoke`** (nov za v3) čuva sljedeće:
  - raspored 1:1;
  - pravi klikovi na strelice i tabove (ne otvaraju polje);
  - swipe i snap;
  - statuse active / open / locked / unlock / buy / soon;
  - tri koraka Playa;
  - zaključan unos tokom prelaza;
  - svaki kadar prelaza u koracima 0,05 (ime, Pip i Play vidljivi; Play rect i ime na eased `t`; trake kartice `round(h·.32/.68)`; trake livade samo na `u = 1`);
  - predaju Pipa i povratak s odšetanih stopala;
  - kapiju, Unlock i hint prve sesije.
- **Ažurirani:** `season_meadow_smoke`, `home_field_overlay_smoke`, `home_basket_picker_smoke`, `meta_hub_flow_smoke`, `camp_season_link_smoke`.
- **Pun skup (56 smoke testova)** mora proći bez ijednog `SCRIPT ERROR`. Vidi [[../../05-technical/godot/greske-katalog|greske-katalog]] #21.

## Otvorena pitanja

- **Tokeni sezona:** dock je nestao s Homea. Ako trebaju negdje drugo (polje ili run), to je novi zadatak.
- **Crteži cvijeća** za sezone osim Country Blooma još ne postoje. Kartica i livada do tada koriste proceduralni cvijet.
- **Cijena premium sezona** dolazi iz `IAPManager` (lokalna valuta). $4.99 u mocku je placeholder.

## Runda 3 (2026-09-29)

Paket `design_handoff_home_v3/` je stigao ponovo, s dvije korekcije na kartici. Sve ostalo iz runde 2 je nedirnuto.

### Šta se promijenilo

- **Svih šest cvjetova sezone je na kartici**, u dva reda po tri. Gornji red je trojka iz runde 2 — prvi ★1 lijevo (180), potpisni ★3 u sredini (220, spušteni bočni 26), prvi ★2 desno (180). Donji red (180, vrh 552) nosi ostala tri. Razmak 48, sve centrirano u 1032.
- **Zaključana besplatna sezona je pod velom.** Preko svakog diska ide ravna siva ploha `#E3D9CC` (ista kao zaključana korpa na polju), crtež se ne crta, i nijedan cvijet se ne prepoznaje. Na sredini bloka stoji **jedan** katanac 120.
- **Tap na „Unlock" diže veo disk po disk** — 300 ms po disku, sljedeći kreće 40 ms kasnije. To je jedini trenutak kad se cvijeće te sezone prvi put vidi.
- **Lokot gore desno (`LOCK_BADGE` 96) je ukinut.** Kartica nikad ne nosi dva katanca: u stanju „unlock" katanac je na zlatnom dugmetu, u „locked" na bloku cvijeća.
- **Premium je namjerno drugačiji** — bez vela i bez katanca. Premium se kupuje, pa kartica pokazuje šta se kupuje: šest cvjetova u boji, a zlatni rub i cijena kažu „nije tvoje". Katanac znači „otključava se igrom", zlato „kupuje se". Ember Fen („coming soon") ostaje na 50 %.
- **Zaključano stanje potpuno zamjenjuje „missing".** Na zaključanoj kartici nema isprekidanih diskova ni imena cvijeća — to se crta samo na sezoni koja se može igrati. (Ovo je bila prva od dvije zamke koje je brief tražio da CD razriješi.)

### Mjere

| Token | Vrijednost |
|---|---|
| `ROSTER6` | `(178, 256, 180)` · `(406, 230, 220)` · `(674, 256, 180)` · `(198, 552, 180)` · `(426, 552, 180)` · `(654, 552, 180)` — px kartice |
| `ROSTER_EYE` / `ROSTER_DISC` | 220 / 180 |
| `ROSTER_GAP` / `ROSTER_SIDE_DROP` / `ROSTER_ROW2_TOP` | 48 / 26 / 552 |
| `LOCK_VEIL` | `#E3D9CC` |
| `ROSTER_LOCK` | `Rect2(456, 436, 120, 120)`, ikona 60, krem s rubom 4 i sjenkom 0 6 0 α .24 |
| `REVEAL_SEC` / `REVEAL_STAGGER` | 0,30 s / 0,04 s po disku |

Blok cvijeća ide od 230 do 732, imena do 826 — status red počinje na 830, a strelice su na y 680–800 uz same ivice (x ≤ 148 i ≥ 884), pa se ništa ne dodiruje. Kartica je i dalje tačno 1032 × 1160.

### Kako je izvedeno

Veo i katanac se crtaju u zasebnom čvoru `RosterVeil`, koji je **zadnje dijete** sadržaja kartice. Djeca se u Godotu crtaju poslije roditelja, pa bi veo nacrtan u `_draw()` samog sadržaja ostao **ispod** crteža cvijeća — ovako je zaista preko njih. Disk pod velom ostaje običan krem; isprekidani disk i ime pojave se tek kad veo padne, isto kao u mocku (`miss = playable && veil === 0`).

### Testovi

`season_home_smoke` je dopunjen za rundu 3:

- šest diskova, svaki tačno na mjeri iz `ROSTER6`;
- zaključana sezona: veo na svih šest, nijedan crtež, tačno jedan katanac;
- igriva sezona: šest crteža, bez vela i bez katanca;
- nijedan disk i nijedan red imena ne ulazi u strelice ni u status red (mjereno nad stvarnim okvirima teksta, ne nad procjenom);
- premium na prodaju i „coming soon": šest cvjetova, bez vela i katanca;
- „Unlock": veo se diže **redom** (prvi disk prije zadnjeg), a poslije 0,5 s nema vela i vidi se svih šest.

Pun skup: **56/56**.

## Runda 4 (2026-09-30)

Playtest runde 3 je našao da **imena cvijeća ulaze jedno u drugo**. Paket je stigao s ispravkom i prenesen je isti dan.

### Šta je bilo krivo

Ime se crtalo **38/900 centrirano ispod svog diska** i prelamalo tek na 300 px — a centri diskova su bili bliži nego što su imena široka: gornji red 248 px, donji samo **228**. Mjerenjem svih 48 imena u igri: **10 preklapanja na 7 od 8 sezona**, najgore **46 px** (Coral Tide, „Tide Anemone" ↔ „Pearl Waterlily"). Samo Ember Fen je slučajno bio čist.

### Šta je CD promijenio

| | Bilo | Sada |
|---|---|---|
| Veličina imena | 38/900 | **34/900** (donja granica iz §2) |
| Razmak ispod diska | 18 | **12** |
| Prelom | 300 px | **220 px** — jedan red ako stane, inače dva uravnotežena; tri nikad |
| Kolone | red 1 na 268 / 516 / 764, red 2 na 288 / 516 / 744 | **276 / 516 / 756 u oba reda**, korak 240 |
| Vrh drugog reda | 552 | **560** |

Korak 240 je najveći koji staje: najšire ime u krajnjoj koloni je **10,8 px** od strelica. Prelom na 220 = disk 180 plus 20 sa svake strane, pa ime i dalje očito pripada svom disku.

### Šta je time dobijeno

- **Najmanji razmak između dva susjedna imena je 36,4 px** (Starfall Glade, „Nova Bloom" ↔ „Aurora Tulip"), umjesto −45,8 px preklapanja.
- Ime ispod donjeg reda završava na **820**, status red počinje na 830 — 10 px umjesto 4.
- Ime ispod srednjeg (velikog) diska završava na **530**, donji red počinje na 560 — 30 px umjesto 8.
- **Nijedno ime se ne izbacuje.** Igrač i dalje vidi ime svakog cvijeta koji mu fali.

### Odstupanje: ime nosi svaki cvijet

Paket crta ime **samo ispod cvijeta koji igrač nije našao**. U igri ga nosi **svaki vidljivi cvijet**, i onaj već nađen: kartica se bira po tome šta u sezoni raste, a ne po tome šta igraču nedostaje. Raspored to podnosi bez ijedne promjene, jer je runda 4 ionako mjerena na najgorem slučaju — svih šest imena odjednom.

Zaključana sezona ostaje nedirnuta: pod velom nema ni imena ni isprekidanih diskova.

### Pravilo za sadržaj

CD je uz dizajn dao i pravilo koje mora vrijediti za buduće sezone: **svako novo ime cvijeta mora stati u dva reda od najviše 234 px na 34/900.** Danas je najšire „Paper Lantern / Bloom" — 234,4 px. Ovo je `MISSING_NAME_CONTENT_MAX_W` u kodu i smoke ga provjerava, pa se novo predugo ime vidi odmah, a ne tek u playtestu.

### Testovi

`season_home_smoke` sada prolazi **kroz svih 8 sezona** i za svaku uzima **najgori slučaj — svih šest imena odjednom** (to je stanje nove igre, jer se ime crta samo ispod cvijeta koji igrač nije našao). Za svaku sezonu provjerava:

- šest imena u najviše dva reda, nijedna linija šira od 234;
- nijedna dva imena se ne dodiruju, i najmanji razmak u cijeloj igri je ≥ 14 px;
- nijedno ime ne ulazi u disk, u strelice ni u status red;
- na zaključanoj sezoni nema nijednog imena, a na igrivoj ga nosi svih šest cvjetova (i nađeni).

Provjereno i mutacijom: kad se vrate vrijednosti runde 3 (38 / 300), smoke pada na prvoj sezoni („Meadow Clover" 285 > 234). Pun skup: **56/56**.
