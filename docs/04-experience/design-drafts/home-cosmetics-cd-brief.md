---
type: dizajn
status: aktivan
milestone: "—"
tags: [dizajn, ui, home, polje, kozmetika, skinovi, claude-design, mockup]
povezano:
  - home-field-v2-cd-brief
  - home-v3-cd-brief
  - shop-cd-brief
  - art-direction
  - pristupacnost
  - CHECKPOINT
ai_sažetak: "Inventar kozmetike — nova pločica dolje desno na polju sezone otvara tab preko ekrana s Pip skinovima, tintom livade i okvirom albuma. Tab mora biti raspored po pravilu, ne ručno složen, jer kozmetike stiže još; izbor se primjenjuje kroz cijelu igru. Prompt za Claude Design je §9."
---

# Inventar kozmetike — Claude Design brief

> **Status 2026-09-30: čeka CD** — šalji prompt iz [[#9. Prompt za Claude Design|§9]]. Novi paket: `design_handoff_cosmetics/`.

Igra već ima kozmetiku u Shopu: **Pip skinove, tint livade u runu i okvir albuma**. Kupljena kozmetika se odmah nosi, ali igrač je poslije **nigdje ne vidi na jednom mjestu** i ne može je mijenjati bez odlaska u Shop. Ovaj zadatak dodaje **inventar** — mjesto na kojem igrač vidi šta ima i bira šta nosi.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | cijeli fajl (§1–§8) | Zašto, mjere polja, sadržaj kozmetike, MORA i SMIJEŠ, isporuka |
| **Ti** | §9 | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §3, §6, §10 | Tačne mjere, model podataka i mapa „CD sloj → Godot" |

**Prije slanja prompta: commitaj i pushaj na `master`.** CD čita fajlove po tačnoj putanji, ali ne može listati foldere — zato su sve putanje u promptu ispisane do kraja.

---

## 1. Zašto

Kozmetika je jedina stvar koja se u igri kupuje za coine i **jedini način da igrač pokaže da je nešto postigao** — Fair F2P znači da se snaga ne kupuje ([[../../01-vision/design-pillars|design-pillars]], Pillar 2). Ako je kozmetika nevidljiva poslije kupovine, gubi smisao.

Danas: kupiš Pip skin u Shopu, on se odmah obuče, i to je to. Nema mjesta gdje vidiš svoju kolekciju, nema načina da se vratiš na prethodni skin osim da ponovo uđeš u Shop i tapneš stari.

Inventar to rješava i **priprema teren** — kozmetike će biti znatno više nego danas pet komada.

---

## 2. Pravila koja ostaju FIKSNA

- **Polje sezone se ne redizajnira.** Livada, Gift, korpa, nadogradnje, ime sezone, Pip i donji red (Seasons · Play · Endless) ostaju tačno kakvi jesu. Dodaje se **jedna pločica** i **jedan tab**.
- **Kozmetika je samo izgled.** Nijedan predmet ne daje prednost u igri. Ništa u ovom tabu ne smije davati ni nagovještaj da nešto pomaže u runu.
- **Coini se troše u Shopu.** Inventar je mjesto gdje biraš šta nosiš, ne drugi put do trošenja (vidi §4, SMIJEŠ — ako predlažeš kupovinu odavde, mora imati potvrdu i vodi u isti tok kao Shop).
- **Jedan predmet po slotu.** Slot je „mjesto na tijelu": Pip skin, tint livade, okvir albuma. Ne mogu dva Pip skina odjednom.
- Tekst **≥ 34 px**, dodir **≥ 120 px**, kontrast **≥ 4,5 : 1** ([[../pristupacnost|pristupačnost]]).
- Flat cartoon, pastel, meki outline, bez blura, glowa i gradijenata ([[../art-direction|art-direction]]).

---

## 3. Šta se traži

| # | Zahtjev |
|---|---|
| **R1** | **Ulazna pločica** na polju sezone, **dolje desno, iznad Endlessa**. Ikona mora značiti „skinovi i kozmetika" bez teksta. |
| **R2** | **Tab preko ekrana** koji ta pločica otvara — inventar kozmetike: Pip skinovi, tint livade, okvir albuma. |
| **R3** | **Raspored mora biti pravilo, ne ručno složena slika.** Kozmetike stiže još; dodavanje predmeta (i cijelog novog slota) ne smije tražiti novi dizajn. |
| **R4** | **Izbor se primjenjuje kroz cijelu igru.** Kad igrač izabere kozmetiku i vrati se na polje, promjena se vidi — i tu i u runu i u Journalu, gdje god taj slot živi. |

### 3.1 Polje danas (mjere iz koda)

Stranica je **1080 × 1633** (između headera 143 i footera 144). Polje je cijela stranica.

| Element | Mjera |
|---|---|
| Gift | `Rect2i(24, 24, 180, 180)` — gore lijevo |
| Korpa (sjeme) | `Rect2i(24, 220, 180, 180)` — ispod Gifta, isti okvir |
| **Nadogradnje** | `Rect2i(876, 24, 180, 180)` — **gore desno; nova pločica je njen par dolje** |
| Ime sezone | `Rect2i(228, 36, 624, 56)`, čip ispod na y 112 |
| Donji red | `Seasons Rect2i(70, 1477, 236, 124)` · `Play Rect2i(324, 1461, 432, 140)` · **`Endless Rect2i(774, 1477, 236, 124)`** |
| Pločica | `TILE 180`, ikona u njoj `TILE_ICON 84` |
| Trake livade | nebo 0–32 %, daljina 32–68 %, prednja 68–100 % |

**Keepout zone** (chrome ih pokriva; ni cvijet ni Pip ne smiju u njih):

```
Rect2i(8, 8, 212, 408)       Gift + korpa
Rect2i(860, 8, 212, 212)     Nadogradnje
Rect2i(212, 20, 656, 184)    ime sezone + čip
Rect2i(54, 1445, 972, 188)   donji red
```

**Dvije stvari koje nova pločica dira** — riješi ih i napiši kako:

1. **Pip šeta tuda.** Pipova zona stopala je `Rect2i(151, 1306, 778, 131)`, a Pip je **190 px visok**, pa mu tijelo zauzima otprilike y 1116–1437 na x 151–929. Pločica 180 iznad Endlessa (dakle iznad y 1445) sjeda tačno u taj ugao. Ili je pomjeri tako da Pipu ne smeta, ili reci da se Pipova zona skrati zdesna — i za koliko.
2. **Livada ima 13 mjesta za cvijeće** (`MEADOW_SPOTS`), zadata u procentima širine i visine. Nova keepout zona može izbaciti jedno mjesto. Reci koje, ili pokaži da nijedno ne pada.

### 3.2 Kozmetika danas (iz koda)

Tri **slota**, pet predmeta. Ovo je cijeli sadržaj — i zato je §3.3 važniji od ovog spiska.

| Slot | Naslov u Shopu | Gdje se vidi | Predmeti danas |
|---|---|---|---|
| `pip_skin` | „Pip skin" | **u runu** (Pip) | **Pip Blossom** 250 coina (roze) · **Pip Sky** 200 (plavo) |
| `meadow_bg` | „Meadow tint" | **pozadina runa** | **Sunset Meadow** 150 (toplo zlatno) · **Lavender Meadow** 180 (meko ljubičasto) |
| `journal_frame` | „Album frame" | **Journal stranica** | **Golden Album** 120 (zlatni akcenti) |

Svaki predmet ima `title`, `description`, `coin_cost` i `slot`. Stanja po predmetu: **nije kupljen** · **kupljen, ne nosi se** · **kupljen i nosi se**.

Pazi: **tri slota se vide na tri različita mjesta u igri** — Pip skin i tint u runu, okvir u Journalu. Igrač mora znati gdje šta djeluje, inače bira naslijepo.

### 3.3 Proširivost — ovo je srce zadatka

Danas pet predmeta. Sutra ih može biti trideset, i doći će **novi slotovi** kojih danas nema (skin za korpu, okvir za karticu sezone, boja traga u runu…).

Dizajn zato mora biti **recept**:

- **Sekcija po slotu**, a sekcije se prave iz podataka — ne ručno poslagane.
- **Predmet je uvijek ista kartica**: iste mjere, isto mjesto za sliku, naslov, stanje. Ne „ova tri izgledaju ovako, a ovaj drugačije".
- Reci **koliko ih stane u red** i **šta se dešava kad ih bude 7, 20, 40** — lista se skrola.
- Pokaži **kako izgleda četvrti slot** kojeg danas nema, s dva izmišljena predmeta. Ako za to treba nov dizajn, pravilo nije dovoljno dobro.
- Pokaži **sekciju s jednim jedinim predmetom** — ne smije izgledati pokvareno.
- Naslovi predmeta su različite dužine („Pip Sky" 7 znakova, „Lavender Meadow" 15). Reci šta radiš s dužim.

---

## 4. MORA i SMIJEŠ

### MORA

- **Pločica je u porodici s ostalim chromeom polja** — isti okvir kao Gift, korpa i nadogradnje (180). Ikona bez teksta, jasna i kad je mala.
- **Pločica ne pokriva Pipa ni cvijeće** — vidi §3.1, tačke 1 i 2.
- **Tab pokriva ekran** i ima očigledan izlaz. Isti jezik kao dva sheeta koja polje već ima (korpa 1326 px visine, nadogradnje 922).
- **Svaki predmet nosi svoje stanje**: nije kupljen · kupljen · nosi se. Razlika mora biti vidljiva **i bez boje**.
- **Svaki predmet kaže gdje djeluje** („u runu", „Journal") — slotovi žive na tri mjesta.
- **Mora postojati povratak na osnovni izgled.** Ovo je rupa u igri danas: kad jednom obučeš Pip skin, **ne postoji način da skineš skin** i vratiš običnog Pipa. Inventar mora imati „bez kozmetike" po slotu.
- **Prazan inventar mora imati svoje stanje** — igrač koji nije kupio ništa mora vidjeti šta postoji i gdje se kupuje.
- **Ne kupuje se snaga.** Nigdje ni riječi koja bi nagovijestila prednost u igri.
- Tekst ≥ 34, dodir ≥ 120, kontrast ≥ 4,5 : 1. Bez blura i gradijenata.

### SMIJEŠ (odluči i obrazloži u § Odlučeno)

- **Koja je ikona za kozmetiku.** Vješalica, majica, paleta, četkica, zvjezdica — tvoj izbor, ali mora se razlikovati od ikone nadogradnji gore desno.
- **Kako izgleda tab**: pun ekran ili sheet koji klizi, sekcije jedna ispod druge ili tabovi po slotu, mreža ili red.
- **Kako izgleda kartica predmeta** i koliko ih ide u red.
- **Kako se vidi šta predmet radi** — mali portret Pipa sa skinom, uzorak boje, ikona; ti biraš.
- **Kupovina iz inventara.** Danas se kupuje samo u Shopu. Ako misliš da nekupljeni predmet treba imati dugme „kupi" i ovdje, uzmi to — **ali onda mora imati potvrdu i voditi u isti tok kao Shop**, i napiši zašto je bolje nego poslati igrača u Shop.
- **Kad izbor stupa na snagu.** U kodu se predmet obuče čim ga tapneš i to se odmah snimi. Ako želiš da se biranje „potvrđuje" na izlazu, reci tačno kako (i šta ako igrač zatvori tab bez potvrde).

---

## 5. Paleta i tokeni

Ista paleta kao ostatak igre — [[../art-direction|art-direction]] + `ui_palette.gd`.

| Uloga | Hex |
|-------|-----|
| Warm white | `#FFF8F0` |
| Outline / ink | `#2D3436` |
| Mint (potvrda, „nosi se") | `#A8E6CF` |
| Peach (glavni potez) | `#FFB88C` |
| Coin gold | `#FFD56B` |
| Lavanda | `#D4A5FF` |
| Hub chrome | `#2A2233` |

**Postojeći tokeni koje vrijedi ponoviti** (Shop, sekcija kozmetike): visina kartice 284, razmak 24, okvir pregleda 440 × 284 radius 20, naslov slota 46, padding 20. Ako uzmeš druge brojeve — reci zašto.

Radius 12 / 20 / 26 · rub 2–4 px, ~20 % tamniji od ispune · jedna tvrda sjena (bez blura).

---

## 6. Tehnička ograničenja (Godot 4.7, OpenGL, slabiji Android)

- Artboard **1080 × 1920**, sve mjere u px te baze. Stranica polja je 1080 × 1633 (od y 143).
- Paneli = ravna boja + radius + rub + jedna sjena (`StyleBoxFlat`). **Bez blura, glowa, gradijenata.**
- Animacije su tweenovi: pozicija, skala, alpha, boja, rotacija.
- Lista se skrola — računaj da će biti duža nego ekran.
- Slika predmeta: ili crtež koji igra već ima (Pip se crta kodom, tint je množenje boje), ili **mali** SVG/PNG. Cijeli sadržaj igre je danas 0,44 MB od ~26 MB downloada — nemoj planirati galeriju velikih slika.
- Ikone koje igra već ima: `icon_coin`, `icon_seed`, `icon_flower`, `icon_lock`, `icon_settings`, `pip_idle` i tabovi huba.

---

## 7. Isporuka

Novi paket: **`design_handoff_cosmetics/`** — cijeli folder u **zipu**.

| Fajl | Sadržaj |
|---|---|
| `design/CosmeticsSheet.dc.html` | Inventar, interaktivno. Prop `owned` (ništa · nešto · sve), `equipped`, `slots` (3 kao danas i **4 s izmišljenim slotom**), `count` (1 · 5 · 20 · 40 predmeta) |
| `design/FieldEntry.dc.html` | Polje sezone s novom pločicom na mjestu — pokaži da ne pokriva Pipa ni cvijeće |
| `design/Cosmetics Specs.dc.html` | anatomija kartice predmeta (tri stanja jedno pored drugog), anatomija sekcije, pločica, prazan inventar, sekcija s jednim predmetom, sekcija s 40 |
| `godot/cosmetics_export.json` | tokeni + **pravilo rasporeda** (koliko u red, visine, razmaci, kako se pravi sekcija) |
| `godot/ui_cosmetics.gd` | iste vrijednosti kao JSON |
| `godot/cosmetics_tree.txt` | stablo čvorova i red prenosa |
| `README.md` | § Odlučeno · § Šta se briše · § Samoprovjera · § Ideje van zadatka |

**§ Samoprovjera** (popuni prije zipa, svaka stavka da/ne, provjereno u browseru — ne po sjećanju):

1. Pločica je na polju dolje desno iznad Endlessa, u istom okviru kao Gift / korpa / nadogradnje, i **ne pokriva Pipa ni jedno od 13 mjesta za cvijeće** (ili je napisano šta se pomjera).
2. Ikona pločice se ne može zamijeniti s ikonom nadogradnji.
3. Tab pokazuje sva tri slota, i svaki predmet ima jasno stanje: nije kupljen · kupljen · nosi se — **razlučivo i u crno-bijelom**.
4. Svaki predmet kaže gdje djeluje (run / Journal).
5. Postoji „bez kozmetike" u svakom slotu i vidi se kad je ono izabrano.
6. Prazan inventar ima svoje stanje i upućuje na Shop.
7. **Četvrti slot s dva izmišljena predmeta radi bez ijedne promjene dizajna** — pokazan je u Specs.
8. Sekcija s **jednim** predmetom i sekcija s **40** izgledaju ispravno; lista se skrola.
9. Najmanji tekst je ≥ 34 px, najmanji dodir ≥ 120 px, kontrast ≥ 4,5 : 1.
10. Nigdje blur, glow ni gradijent.

---

## 8. Ne tražimo

- Redizajn polja sezone, huba, Shopa ni Journala.
- Nove kozmetičke predmete (art) — dizajniraj **mjesto** za njih, ne njih.
- Ekonomiju: cijene, popuste, pakete, „sezonske" kozmetike.
- Više varijanti za biranje. Jedan dizajn; dileme rješavaš i upisuješ u § Odlučeno.

---

## 9. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj na `master`.**

```
Novi zadatak: INVENTAR KOZMETIKE za Merge Meadow.

Pročitaj po ovim tačnim putanjama (repo, master):
  docs/04-experience/design-drafts/home-cosmetics-cd-brief.md   (cijeli, ovo je zadatak)
  game/scripts/monetization/cosmetic_catalog.gd   (svi predmeti i slotovi)
  game/scripts/economy/cosmetics.gd               (owned / equipped model)
  game/scripts/visual/ui_home_field.gd            (mjere polja sezone)
  game/scripts/visual/ui_shop.gd                  (kako kozmetika izgleda u Shopu)
  design_handoff_home_field_v2/                   (polje sezone, prethodni paket)

ŠTA SE PRAVI:

R1 — ULAZNA PLOČICA. Na polju sezone, DOLJE DESNO IZNAD ENDLESSA, pločica
180 x 180 u istom okviru kao Gift (24,24), korpa (24,220) i nadogradnje
(876,24). Ikona znači „skinovi i kozmetika", bez teksta, i mora se
razlikovati od ikone nadogradnji gore desno.

R2 — TAB PREKO EKRANA. Pločica otvara inventar kozmetike. Polje već ima dva
sheeta (korpa 1326 px visine, nadogradnje 922) — isti jezik.

R3 — RASPORED MORA BITI PRAVILO, NE RUČNO SLOŽENA SLIKA. Ovo je srce
zadatka. Danas su tri slota i pet predmeta; sutra ih je trideset i doći će
slotovi kojih danas nema. Sekcija po slotu pravi se iz podataka, predmet je
uvijek ista kartica, i moraš reći koliko ih ide u red i šta biva na 7, 20 i
40. U Specs POKAŽI: četvrti slot s dva izmišljena predmeta koji radi BEZ
ijedne promjene dizajna, sekciju s jednim jedinim predmetom, i sekciju s 40.

R4 — IZBOR SE PRIMJENJUJE KROZ CIJELU IGRU. Kad igrač izabere kozmetiku i
vrati se na polje, promjena se vidi — i tu i u runu i u Journalu.

SADRŽAJ DANAS (cijeli):
  pip_skin      „Pip skin"     vidi se U RUNU        Pip Blossom 250, Pip Sky 200
  meadow_bg     „Meadow tint"  POZADINA RUNA         Sunset Meadow 150, Lavender Meadow 180
  journal_frame „Album frame"  JOURNAL STRANICA      Golden Album 120
Jedan predmet po slotu. Stanja: nije kupljen · kupljen · nosi se.
Tri slota se vide na TRI RAZLIČITA MJESTA u igri — igrač mora znati gdje šta
djeluje, inače bira naslijepo.

DVIJE STVARI KOJE MORAŠ RIJEŠITI:
1. Pip šeta baš tuda. Njegova zona stopala je Rect2i(151, 1306, 778, 131), a
   Pip je 190 px visok, pa mu tijelo zauzima oko y 1116–1437 na x 151–929.
   Pločica iznad Endlessa (dakle iznad y 1445) sjeda u taj ugao. Ili je
   pomjeri, ili reci da se Pipova zona skrati zdesna i za koliko. Livada ima
   i 13 mjesta za cvijeće — reci pada li koje.
2. U igri DANAS NE POSTOJI način da se skine kozmetika. Kad jednom obučeš
   Pip skin, običnog Pipa više ne možeš vratiti. Inventar mora imati „bez
   kozmetike" u svakom slotu.
Uz to: prazan inventar (igrač nije kupio ništa) mora imati svoje stanje i
uputiti na Shop.

GRANICE: polje sezone se ne redizajnira — dodaje se jedna pločica i jedan
tab. Kozmetika je samo izgled, nigdje ni nagovještaj prednosti u igri
(Fair F2P). Coini se troše u Shopu; ako predlažeš kupovinu iz inventara,
mora imati potvrdu i ići u isti tok kao Shop, i napiši zašto je to bolje.

TEHNIČKI (Godot 4.7, OpenGL, slabiji Android): artboard 1080 x 1920, stranica
polja 1080 x 1633 od y 143. Paneli = ravna boja, radius, rub, jedna tvrda
sjena. BEZ blura, glowa i gradijenata. Animacije su tweenovi. Lista se skrola.
Tekst >= 34 px, dodir >= 120 px, kontrast >= 4,5:1. Flat cartoon, pastel,
meki outline. Slike predmeta drži male — cijeli sadržaj igre je danas 0,44 MB
od ~26 MB downloada.
Postojeći tokeni kozmetike u Shopu, ponovi ih ili reci zašto ne: kartica 284
visine, razmak 24, okvir pregleda 440 x 284 radius 20, naslov slota 46,
padding 20.

ISPORUKA (§7): novi folder design_handoff_cosmetics/, CIJELI FOLDER U ZIPU:
CosmeticsSheet.dc.html (prop owned, equipped, slots 3 i 4, count 1/5/20/40),
FieldEntry.dc.html (polje s novom pločicom — pokaži da ne pokriva Pipa ni
cvijeće), Cosmetics Specs.dc.html (tri stanja kartice jedno pored drugog,
anatomija sekcije, pločica, prazan inventar, sekcija s 1 i sa 40, četvrti
slot), godot/cosmetics_export.json (tokeni + PRAVILO rasporeda),
godot/ui_cosmetics.gd, godot/cosmetics_tree.txt, README.md sa § Odlučeno i
§ Samoprovjerom (10 stavki iz §7, svaka da/ne, provjerene u browseru).

NE RADI: redizajn polja, huba, Shopa ni Journala; nove kozmetičke predmete
(dizajniraj MJESTO za njih, ne njih); ekonomiju i cijene; više varijanti za
biranje. Jedan dizajn, dileme rješavaš i upisuješ u § Odlučeno.
```

---

## 10. Prenos u Godot (referenca za agenta — CD može preskočiti)

| CD sloj | Godot |
|---|---|
| Pločica na polju | nova pločica uz `GiftChest` / `BasketButton` / `UpgradesButton`; nov unos u `UiHomeField.KEEPOUT`; provjeriti `PIP_BASE_ZONE` i `MEADOW_SPOTS` |
| Tab / sheet | isti obrazac kao korpa i nadogradnje (`SHEET_BASKET_H`, `SHEET_UPGRADES_H`) |
| Sekcija po slotu | `CosmeticCatalog.SLOT_*`, red kao `ShopScreen.SLOT_ORDER` |
| Kartica predmeta | `CosmeticCatalog.get_item()` — `title`, `description`, `coin_cost`, `slot` |
| Stanja | `GameState.owns_cosmetic()`, `GameState.get_equipped_cosmetic(slot)` |
| Tap = obuci | `GameState` fasada → `Cosmetics.equip()` (odmah snima) |
| **„bez kozmetike"** | **ne postoji u kodu** — `Cosmetics.equip()` samo postavlja slot. Treba dodati skidanje (prazan slot) i migraciju nije potrebna jer se prazno već tretira kao „ništa" u `get_equipped` |
| Primjena | `pip_draw.gd` / `pip_visual.gd` (Pip), `lane_background.gd` (tint runa), `collection_journal.gd` (okvir albuma) |

## Odluke

- **Nov fajl umjesto dopune polja** — ovo je nov ekran s vlastitim paketom, kao i svi dosadašnji handoffi; polje sezone ostaje u [[home-field-v2-cd-brief|home-field-v2]].
- **Inventar ne kupuje** (prijedlog): Shop ostaje jedino mjesto trošenja, da ne postoje dva toka za isti novac. CD smije predložiti drugačije uz obrazloženje.

## Otvorena pitanja

- **Skidanje kozmetike ne postoji u kodu.** Treba ga dodati prije nego inventar ima smisla — inače „bez kozmetike" u dizajnu nema šta da pozove.
- Da li Journal okvir uopšte pripada ovdje, kad se vidi na sasvim drugoj stranici. Zasad da — sve na jednom mjestu.

## Povezano

- [[home-field-v2-cd-brief|home-field-v2-cd-brief]] — polje sezone, chrome i sheetovi
- [[shop-cd-brief|shop-cd-brief]] — Shop i sekcija kozmetike
- [[home-v3-cd-brief|home-v3-cd-brief]] — biranje sezone i prelaz u polje
- [[../../06-production/CHECKPOINT|CHECKPOINT]]
