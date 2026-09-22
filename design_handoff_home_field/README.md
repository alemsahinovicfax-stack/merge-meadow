## Merge Meadow — HOME: polje sezone

Redizajn ekrana polja sezone. Jedan dizajn, bez varijanti.
Artboard 1080 × 1920; polje je 1080 × 1597 između zadatog headera (143) i
footera (180). Sve mjere su u px te baze i prenose se 1:1.

| fajl | šta je |
| --- | --- |
| `HomeField.dc.html` | ekran, 8 stanja kroz prop `scene` + `season` (svih 8 sezona) |
| `HomeField Specs.dc.html` | mjere po bloku, livada u svih 8 sezona, prelaz iz kartice, tabela animacija, assets, mapa slojeva |
| `HubScreen.dc.html` | zadati header + footer, nepromijenjen |
| `godot/field_export.json` | tokeni, layout, stanja, animacije, EN tekstovi, mapa na nodove, smoke testovi |
| `godot/ui_home_field.gd` | `UiHomeField` — StyleBoxFlat fabrike i tween helperi |
| `godot/README.md` | prenos u 7 koraka i šta obrisati |
| `flowers/`, `icons/` | postojeći assets (8 placeholdera cvijeća, Pip, lock, seed, chrome ikone) |

### Ideja

Livada je **uokvireni prozor** (1032 × 605) na tamnoj stranici, a ne svijetla pozadina preko
cijelog ekrana. Okvir je namjerno ista geometrija kao aktivna kartica sezone na
biranju — 1032 široko, radius 26, rim 6 px `#FFF6D6` — pa je ulazak u polje
jedan tween na istom panelu, bez nove scene.

Boju sezone nosi **samo** livada. Sve oko nje (naslovni red, korpa, nadogradnje,
Play) je sezonski neutralni tamni chrome, pa jedno pravilo kontrasta vrijedi za
svih 8 sezona — i za Moonlit Warren `#3D3A6B`, Starfall Glade i Ember Fen.

### Šta je riješeno (§3.1)

1. **Pozadina.** Cijela stranica je `#2E4733`, ista kao Home i Camp. Pastel je
   unutar okvira livade, gdje i treba biti.
2. **Napredak.** Livada ima 13 mjesta. Svaka od 6 vrsta sezone ima dva
   (na ≥ 1 i ≥ 5 cvijeta u `garden_crystal_stash`), a ★3 vrsta i treće na ≥ 10.
   Bliža mjesta traže manje, pa livada raste od igrača prema horizontu. Prazno
   mjesto je mrlja zemlje, ne blijedi cvijet. Čip gore lijevo piše `6 / 13 grown`.
   Novi igrač vidi praznu livadu s jednom rečenicom; stari vidi punu.
3. **Nadogradnje.** Kartica od 192 px nosi nivo (`Lv 1 / 4` + 4 segmenta),
   efekat sad → sljedeće (`Pull radius 88 px → 136 px`, `Run loot ×1.0 → ×1.25`),
   cijenu s crtežom i imenom cvijeta (`2 × Meadow Clover`), a kad blokira i
   koliko ih imaš. Dugme piše `Need 1`, ne sivo `Upgrade`. Max je `Maxed` i
   `Nothing left to buy`.
4. **Veličine.** Tekst 38+, brojevi 44+, ime sezone 56, Play 64. Sve interaktivno
   je 124 px ili više (Play 176, dugmad nadogradnje 154, redovi pickera 148).
5. **Hijerarhija.** Play 656 × 176 peach, Endless 360 × 176 lavanda s podnaslovom
   `Hard · no finish line`, Seasons tihi pill 300 × 124 gore lijevo — vidljiv i
   prije tutoriala.

### Stanja (prop `scene`)

`main` sredina igre · `basket` korpa odabrana · `picker` bottom sheet otvoren ·
`broke` nema dovoljno cvijeća · `maxed` nadogradnja na 4 / 4 · `upgrading`
trenutak poslije kupovine · `newbie` prije tutoriala (korpa zaključana, bez
Endlessa, hint) · `dark` tamna premium sezona.
Prop `season` forsira bilo koju od 8 sezona u bilo kojem stanju.

### Odlučeno

- **Livada je prozor, ne pozadina.** Sezona zadržava svoju svijetlu pastelnu
  boju, a ekran i dalje izgleda kao isti hub kao Home, Camp i Arena.
- **Boju nosi samo livada.** Jedno pravilo kontrasta za svih 8 sezona; tamne
  sezone ne traže poseban slučaj.
- **13 mjesta s pragovima 1 / 5 / 10.** Napredak mora biti vidljiv, a podaci već
  postoje u `garden_crystal_stash` — nema nove mehanike, samo prikaz. Ako se
  prijedlog ne prihvati, svih 13 su uvijek izrasla i ekran radi isto.
- **Prazno mjesto je zemlja.** Blijedi cvijet se čita kao „imam ga malo”, a
  mrlja kao „ovdje još ništa nije izraslo”.
- **Koliko cvjetova imaš piše samo kad blokira.** Kad je nadogradnja dostupna,
  cijena je dovoljna; kad nije, treba i razlog.
- **Razlog stoji na dugmetu** (`Need 1`), jer odbija dugme, a ne tooltip.
- **Nazad je tih.** Hijerarhija je Play > Endless > Seasons, ali izlaz postoji
  od prve sekunde.
- **Endless ima podnaslov.** Ime samo po sebi ne kaže šta je, a težina je fiksna.
- **Picker je bottom sheet.** Dolazi s iste strane kao palac i ostavlja livadu
  vidljivom iznad sebe.
- **Ime sezone je Label, ne čip.** Nikad nije reagovalo na tap, pa ne smije
  izgledati kao dugme.
- **Pip je 190 px, u prednjoj traci.** Na 72 px je bio dekor; ovdje je stanovnik.
- **Prelaz je jedan rect tween** na istom shellu, plus `bg_color` iz mood boje u
  ground — zato su kartica i okvir livade namjerno iste geometrije.
- **Pulsira samo prazna korpa.** Jedan loop na ekranu; 29 pulsirajućih elemenata
  je na emulatoru palo na 10 fps.
- **Ground ostaje postojeći `home_field_tint()`.** Ručno birane vrijednosti su
  bolje od formule; `lerp(mood, #FFF8F0, 0.45)` je samo fallback za novu sezonu.
- **Rarity je pips** (`★★☆`), ne boja — čita se i u grayscaleu.
- **Pip sprite je kopiran kao `icons/pip_idle.svg`**, da folder ostane tačno po §7.2.

### Nije dirano

Biranje sezone (samo prelaz iz kartice), brojevi i mehanika, header i footer,
run, crtanje cvijeća i Pipa. Bez horizontalnih gesti u polju — livada propušta
swipe, pa se hub i dalje lista lijevo/desno. Fair F2P: nigdje u polju nema
kupovine pravim novcem ni reklame.

### Ideje van zadatka

Nisu dio ovog dizajna; navedene jer su se pojavile uz njega.

1. **Cvijet daje mali pasivni bonus na livadi.** Npr. svaka izrasla ★3 vrsta
   daje +1 % šanse za svoj tip. Daje livadi mehaničku svrhu, ali je nova
   mehanika i mijenja balans runa.
2. **Sezonski trofej.** Kad sva 13 mjesta izrastu, livada dobija jedan ukras
   (vijenac na okviru) i Camp to pokaže. Vidljiv cilj bez novih brojeva.
3. **Pip nosi zadnji plijen.** Pip u ruci drži cvijet koji je zadnji pao u runu —
   veže polje i run bez ijednog novog ekrana.
4. **Poređenje nadogradnji.** Jedan red iznad obje kartice koji pokazuje šta
   sljedeći nivo znači u plijenu po runu, da igrač zna koju prvu.
5. **Livada kao ulaz u Journal.** Tap na izrasli cvijet otvara njegovu stranicu
   u Journalu. Jeftino, ali traži da polje ima navigaciju koju sad namjerno nema.
