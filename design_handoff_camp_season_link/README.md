# Camp — kartica sljedeće sezone (SeasonLinkCard)

Brief: `docs/04-experience/design-drafts/camp-season-link-cd-brief.md`. Mijenja se samo kartica na vrhu Campa: igrač sada vidi **ikonu i puno ime** ★3 cvijeta koji skuplja, uz `N / 20`.

## Šta otvoriti

- `design/SeasonLink.dc.html` — kartica u Camp stranici (header, kartica, vrh sekcije, footer). Prop `scene`: `short` (1 · Fali), `ready` (2 · Spremno), `peony` (3 · Drugi cvijet), `unlocking` (4 · Trenutak otključavanja). `burst` bira trenutak tweena, `guides` pokazuje visinu, razmak 20 i budžet imena.
- `design/SeasonLink Specs.dc.html` — sva 4 stanja, mjere djece (rect-ovi), vertikalni budžet, širina imena.
- `godot/` — `season_link_export.json`, `season_link_tree.txt`, `README.md` (red prenosa).

## § Odlučeno

- **Nova visina kartice: 318 px (bila 276, +42).** Ikona 128 i ime ne staju u stari red od 86 px, pa `SeasonProgress` raste na 128; `StashSection` pada na 1247 (−42), razmak 20 ostaje, stranica 1633 se ne preliva.
- **FlowerArt = okvir chipa iz liste (128, crtež 108, r 28, rub 3).** Igrač isti cvijet već poznaje iz taba Flowers, pa ga na kartici prepoznaje po istom okviru.
- **Okvir bez tamnog wella.** Današnja kartica i `CampArtFrame` crtaju cvijet direktno na zlatu (inset 0), pa to ostaje.
- **Ime iznad brojača, desno od ikone (kao ime iznad pillova na chipu).** "Harvest Pumpkin" i "20 / 20" u jednom redu ne staju sigurno u kolonu od 471 px u Godot fontu.
- **Asimetrične kolone: coini 310 px, cvijet 619 px.** Samo cvijet nosi ime, a "500 / 500" staje u 310.
- **Ime 42 px / 800, brojevi ostaju 48 / 900.** Broj je napredak, ime je oznaka (isti stil kao TradeName), i oboje je iznad 34 px.
- **Budžet imena 471 px, pravilo pada 42 → 38 → 34, nikad ellipsis.** Najduže današnje ★3 ime (Harvest Pumpkin) zauzima oko 70 % budžeta, pa pravilo služi samo za buduća imena.
- **Coin ikona 48 → 56 i poravnata s redom brojača.** Tako "260 / 500" i "0 / 20" stoje u istom redu, a obje trake ostaju u istom redu.
- **Trake počinju ispod broja, ne ispod ikone.** Obje kolone imaju isti obrazac: ikona lijevo, broj i traka desno.
- **Boje traka ostaju iz `ui_camp.gd` (podloga #1A1A14 @ 20 %, coini #FFD56B, cvijeće #FFF8F0).** §6 kaže "isto što Camp već koristi", a bijela @ 35 % i #7DCEA0 iz liste ne postoje u kodu, pa ih ne uvodim.
- **Harvest Pumpkin = `pumpkin_t3.svg` iz igre, izrezan na vidljivi crtež kao `draw_cropped_plant`.** Fajl nije mijenjan; rez je samo u mockupu.
- **Crystal Peony nema SVG, pa mockup crta proceduralni fallback igre (`_draw_crystal`).** Boja dolazi iz `SeedVisualConfig` i približna je (±0,04 nijanse zbog hasha); nema novog arta.
- **Stanje 3 ima 380 / 500 coina.** Brief traži samo Crystal Peony 4 / 20, a djelimična coin traka pokazuje i drugi tint.
- **Stanje 4 pokazuje tween na t = 0,35, "Unlocked" i pune vrijednosti.** Tako igra već radi (`_show(def, coins_cost, t3_required)`); prsten je ispod djece, pa ime i ikona ostaju čitljivi.
- **Header i footer su iz hub chrome v2 (143 / 144, kao u igri), ne iz v1 `HubScreen` (footer 180).** Samo tako budžet od 1633 odgovara igri.
- **`%SeasonLinkFlowerName` se vraća kao novi label.** Smoke provjera "captions must be gone" sada traži da ime postoji i glasi "Harvest Pumpkin".
- **Ikone u `design/icons/` su kopije iz `game/assets/ui/chrome/` i `game/assets/sprites/flowers/`.** Mockup ih mora učitati; ništa nije novo.

## § Šta se ne dira

Header, footer, tabovi Seeds | Flowers, lista, Trade, prazno stanje, Home, Run, Arena, Shop, Journal. Cijena 500 + 20 i pravilo "★3 prethodne besplatne sezone". Tap na karticu = Home bez trošenja. Unlock: jedna riječ, 300 × 120, lokot dok fali, zlato kad je spremno. Burst tween (0,42 s + 0,45 s). Tintovi sezona. Nema teksta "Details", "Next free season" ni rečenice uputstva.

## § Ideje van zadatka (nisu urađene)

- Crystal Peony i Midnight Lotus zaslužuju pravi SVG — proceduralni fallback je prepoznatljiv lošije od bundeve.
- Kvačica uz ispunjen uvjet (npr. 500 / 500 dok cvijeća još fali), da se vidi koji uvjet je gotov i bez čitanja brojeva.
- Tint sezone na `ReservedBadge` ("Kept · N / 20") i na FlowerCount mogao bi vizuelno povezati karticu i chip u listi.
- Ako se dodaju nove besplatne sezone s dužim ★3 imenom, provjeriti ga u Specs (fit tabela) prije prenosa.
