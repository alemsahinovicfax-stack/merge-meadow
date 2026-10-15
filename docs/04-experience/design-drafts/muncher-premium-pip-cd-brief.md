---
type: dizajn
status: zatvoreno
milestone: M8
tags: [dizajn, arena, muncher, pip, skin, premium, iap, claude-design, animacije]
povezano:
  - pip-cd-brief
  - merge-arena-cd-brief
  - ispravke-settings-cd-brief
  - design-pillars
  - CHECKPOINT
ai_sažetak: "Brief za Claude Design: (A) potpuni redizajn munchera u Areni — novi lik, cutout rig kao Pip, sve animacije stanja (spava, budi se, lovi, jede, smrzne se, odmrzne, spava na mjestu) i gnijezdo; (B) prvi premium Pip skin za pravi novac — potpuno drugačiji dizajn i tema (ne recolor), vlastiti dijelovi, animacije, HUD glava i Shop / Ormar kartica."
---

# Muncher redizajn + Premium Pip — Claude Design brief

> **Status 2026-10-14: isporučeno i preneseno.** Paket `design_handoff_muncher_premium_pip/` („Character skin design 1.zip") je u igri — izvještaj [[muncher-premium-pip-izvjestaj]]. Prompt je u §8. Slike: `muncher-premium-pip-ref/`.
>
> **Prije slanja: commitaj i pushaj na `master`.** Prošli put CD nije mogao pročitati brief jer nije bio na masteru.

Dvije stvari, obje velike i obje sa svim animacijama:
- **A.** Muncher (štetočina u Areni) je nacrtan krugovima u kodu. Izgleda nekvalitetno i odudara od ostatka igre. Treba potpuni redizajn.
- **B.** Prvi **premium Pip skin**, koji se plaća pravim novcem. Mora se potpuno razlikovati od Classica, Blossoma i Skya (to su promjene boje + 1–3 sitna dodatka). Kvalitet mora opravdati cijenu.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | §1–§7 + slike u `muncher-premium-pip-ref/` | Šta je danas, šta mora, šta se isporučuje |
| **Ti** | **§8** | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §3, §4, §7 | Mjere i pravila iz koda, kako se prenosi i mjeri FPS |

## 1. Pravila koja ostaju FIKSNA

| Pravilo | Vrijednost |
|---|---|
| Stil | isti kao Pip (`design_handoff_pip/`): flat, pastel, tamni obrub (ink `#2D3436`), ravne boje, radius, jedna tvrda sjena. **Bez blura, glowa, gradijenata i maski** |
| Tehnika | cutout rig: SVG dijelovi → jedan atlas po liku / skinu, animacije su samo transformi dijelova (pozicija, rotacija, skala, vidljivost, zamjena frejma). Ništa se ne crta po frejmu |
| Engine | Godot 4.7, GL Compatibility, slabiji Android. Artboard 1080 × 1920, sve u px te baze |
| Arena | pozadina 1080 × 1633, igralište 1080 × 1589 (između headera i footera), sjemenke Ø ~140, korpa dolje u sredini, gnijezdo munchera gore u sredini |
| Pillar 2 | muncher ne smije biti „kazna za plaćanje" ni tjerati na kupovinu; premium skin je **samo kozmetika** — nikakva prednost u igri |
| Pip | rig (`game/data/pip/rig.json`), 75 animacija (`animations.json`) i postojeći skinovi se ne kvare |

## 2. A — Muncher, potpuni redizajn

### 2.1 Danas (slike `m00`–`m06`)

- Ljubičasta gusjenica sa žutim pjegama:
  - glava r 50 i tri segmenta (r 38 / 32 / 26) koji prate put glave;
  - antene s kuglicama, oči s pogledom, obrve.
- Crta se krugovima i linijama u kodu (`game/scripts/camp/arena_pest.gd`, boje i poze u `game/scripts/visual/ui_arena_v2.gd` → `MUNCHER_*`).
- Gnijezdo 250 × 112 (smeđe, latice).

**Stanja i pravila** (iz koda, ostaju):

| Stanje | Kada | Kako izgleda danas |
|---|---|---|
| Spava u gnijezdu | na ulazu u Arenu, dok nema sjemenki | sklupčan, zzz (26/32/38) |
| Budi se | igrač prospe sjeme; 0,3 s | „!" zvijezda, rep gore |
| Lovi | ide do najbliže sjemenke T1/T2 brzinom **85 px/s**, cilj se bira iznova svakih 0,25 s | ispružen, obrve V, segmenti talasaju |
| Jede | na **36 px** od centra sjemenke; **0,5 s** | usta širom, 2 griza (0,25 s), mrvice |
| Smrznut | igrač napravi T3 → **2 s** | kocka leda 200 × 170, plave boje |
| Odmrzne se | posle 2 s | nastavlja lov |
| Spava na mjestu | polje ostane prazno | sklupčan na tom mjestu, zzz |

Muncher se kreće **u svim pravcima** po polju (pogled odozgo / blago iskošen). Danas se glava samo okreće pogledom.

### 2.2 Šta se traži

1. **Novi lik.**
   - Vrsta, oblik i ime su tvoj izbor; može ostati gusjenica ili postati nešto drugo (puž, bubica, krtica…).
   - Na prvi pogled: **simpatična napast**, nestašan, ne strašan. Djeca i odrasli ga trebaju „voljeti mrziti".
   - Mora se jasno razlikovati od sjemenki i Pipa na svih 8 livada (svijetle i tamne sezone).
2. **Cutout rig kao Pip.**
   - Dijelovi su SVG, a animacije su podaci (isti format kao `game/data/pip/animations.json`).
   - Smjer kretanja: najmanje lijevo / desno (zrcaljenje) + gore / dolje, da kad ide prema sjemenki ne „klizi bočno".
3. **Sve animacije stanja iz §2.1:**
   - spava (loop);
   - budi se (pop + upozorenje);
   - lov (loop hoda / gmizanja u pravcu);
   - jede (loop griza + mrvice);
   - smrznut (led + drhtanje);
   - odmrzavanje (led puca);
   - zaspi na mjestu.

   Plus dva kratka trenutka:
   - „Muncher's awake!" (kad se prvi put probudi u sesiji);
   - reakcija kad mu sjemenka „pobjegne" (igrač je spoji prije nego što je pojede).
4. **Gnijezdo** u stilu novog lika; muncher u njemu spava, a gnijezdo ga djelimično pokriva.
5. **Led i efekti** (zzz, „!", mrvice, krhotine leda) u istom stilu, svi kao dijelovi ili sprite-ovi, bez crtanja po frejmu.
6. **Mjere:**
   - vizuelni radius ~50–60 (glava / tijelo);
   - centar jedenja = centar glave (usta);
   - ukupna dužina ≤ 260 px;
   - gnijezdo ≤ 280 × 130.

## 3. B — Premium Pip skin (pravi novac)

### 3.1 Danas (slika `p01`)

| Skin | Cijena | Šta je |
|---|---|---|
| Classic Pip | besplatan | baza: mint krzno, preklopljen vrh desnog uha, tri pramena na čelu |
| Pip Blossom | 250 coina | promjena 7 boja + grančica trešnje na uhu + rep od latica; potpis: okret s laticama |
| Pip Sky | 200 coina | promjena 7 boja + vrhovi ušiju od oblaka + rep od oblaka; potpis: skok na oblačićima |

Rig:
- **5 pogleda**, 27–35 čvorova po pogledu, 104 SVG dijela:
  - front — polje, kartica sezone, Arena, Camp;
  - three_q — Shop, Ormar;
  - side — hodanje po polju;
  - back;
  - top — run.
- 75 animacija, uključujući `pose_<skin>` i `sig_<skin>`.
- HUD glava po skinu: `game/assets/pip/hud/pip_hud_<skin>.svg`.
- Skinovi: `game/data/pip/skins.json`.

### 3.2 Šta se traži

1. **Potpuno drugačiji dizajn i tema** — ne promjena boje.
   - Vlastita priča i tema (tvoj izbor), vlastiti detalji siluete:
     - posebne uši, rep, krzno / šare;
     - dodaci kao ogrtač, kruna, šal, naočale…
   - Prepoznatljiv i na 88 px (HUD glava) i u runu odozgo na 150 px.
   - **Premium kvalitet:** više slojeva, više detalja, bolja izrada nego Blossom / Sky. To je stvar koju igrač kupuje pravim novcem.
2. **Smije zamijeniti dijelove** u svakom pogledu: vlastito tijelo, glava, uši, rep, šape, i dodati nove čvorove (dodatke). Pivoti moraju ostati isti, tako da **svih 75 postojećih animacija radi** bez izmjene.
3. **Vlastite animacije:**
   - `pose_<key>` (poza u Shopu / Ormaru);
   - `sig_<key>` (potpis na tap);
   - vlastiti idle detalj (npr. svaki 6–10 s);
   - posebna reakcija na T3 merge i na cilj runa.

   Opcionalno: trag u runu. Ako ga crtaš, tvrda pravila iz §4.
4. **Sve površine:**
   - polje (front 190);
   - kartica sezone (front 230);
   - Arena (front 150);
   - run (top 150);
   - HUD runa (glava 88, krop kao `pip_hud_*`);
   - Camp (front 150);
   - Shop / Ormar (three_q 126 i 246).
5. **Shop i Ormar:**
   - **Shop · Looks:** premium kartica s cijenom u novcu (ljubičasto dugme kao Remove Ads), veliki pregled, oznaka „Premium". Kupljeno: „Owned" / „Wearing".
   - **Ormar:** kartica s oznakom „Premium" (mjesto „Free" oznake na Classicu). Nekupljen je pod velom i vodi u Shop.
6. **Cijena i proizvod:**
   - predloži cenovni razred (npr. €2,99–€4,99) i ime proizvoda;
   - odluka o cijeni je moja (igrač), ti napiši prijedlog i zašto.
   - Pillar 2: nikakva prednost u igri.

## 4. Performanse (MORA, u README)

| | Muncher | Premium Pip |
|---|---|---|
| Atlas | 1 tekstura ≤ 1024 × 1024 | 1 tekstura po skinu ≤ 1024 × 1024 (kao danas) |
| Dijelovi | ≤ 24 čvora ukupno | ≤ 10 dodatnih čvorova po pogledu |
| Animacije | samo transformi / zamjena frejma; ništa po frejmu iz koda | isto |
| Efekti | ≤ 12 sprite-ova, ≤ 0,6 s | ≤ 12 sprite-ova, ≤ 0,6 s; trag u runu ≤ 6 sprite-ova na ekranu |
| SVG | ukupno ≤ 120 KB | ukupno ≤ 150 KB |

U README napiši stvarne brojeve.

## 5. Isporuka

### 5.1 Stanja (sve živo u pregledaču)

- **Muncher:**
  - svako stanje iz §2.1 + prelazi između njih;
  - kretanje u 4 pravca;
  - gnijezdo;
  - na svijetloj (Country Bloom) i tamnoj (Starfall Glade / Moonlit Warren) livadi.
- **Premium Pip:**
  - svih 5 pogleda;
  - poza, potpis, idle detalj, T3 i cilj;
  - sve površine iz §3.2.4 uz Classic za poređenje;
  - Shop kartica (dostupno / kupljeno / nošeno);
  - Ormar kartica (pod velom / kupljeno / nošeno).

### 5.2 Paket

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_muncher_premium_pip/
  README.md                 šta otvoriti · § Odlučeno · § Performanse · § Samoprovjera
  design/
    Muncher.dc.html         svi stanji + animacije, prop season / state / direction
    PremiumPip.dc.html      5 pogleda, animacije, površine, Shop i Ormar kartice
    Specs.dc.html           mjere, pivoti, budžeti
    support.js · pip_*.js (ako koristiš Pip runtime iz design_handoff_pip)
  assets/
    muncher/parts/*.svg · muncher/fx/*.svg · muncher/nest/*.svg
    pip/parts_<key>/*.svg · pip/overlays/*.svg · pip/fx/*.svg · pip/hud/pip_hud_<key>.svg
  godot/
    muncher_rig.json        čvorovi, pivoti, z, pogledi / pravci
    muncher_animations.json isti format kao game/data/pip/animations.json
    skins_<key>.json        unos za skins.json (+ mapa zamjene dijelova po pogledu)
    rig_additions.json      novi čvorovi za Pip rig (dodaci premium skina) po pogledu
    animations_additions.json  pose / sig / idle / reakcije premium skina
    shop_export.json        Shop i Ormar kartica (stanja, tekstovi, cijena — prijedlog)
```

### 5.3 Samoprovjera (u README, svaka stavka da/ne, provjereno u pregledaču)

1. Muncher je novi lik u stilu Pipa, simpatičan, ne strašan; čita se na svijetloj i tamnoj livadi.
2. Muncher ima sva stanja iz §2.1, prelaze i kretanje u 4 pravca.
3. Centar jedenja = usta; mjere iz §2.2.6.
4. Premium skin nije recolor: ima vlastite dijelove / dodatke u svih 5 pogleda.
5. Svih 75 postojećih Pip animacija radi sa skinom (isti pivoti).
6. Skin ima pozu, potpis, idle detalj, reakciju na T3 i cilj, i HUD glavu.
7. Skin je prepoznatljiv na 88 px i u runu odozgo.
8. Shop i Ormar kartice imaju sva stanja; Classic ostaje „Free", premium ima „Premium".
9. Budžeti iz §4 su ispunjeni i napisani.
10. Nigdje blur, glow, gradijent ni maska.

## 6. Ne tražimo

- Promjenu pravila munchera (brzina, jedenje, freeze) — samo lik i animacije.
- Nove valute, pakete ili boostere; premium skin je jedna kozmetika.
- Promjenu Classica, Blossoma i Skya.
- Zvuk.

## 7. Napomena za agenta (prenos)

- **Muncher:** `arena_pest.gd` prelazi s crtanja krugova na rig (kao `UiPip`: atlas + `AnimationPlayer`). Pravila stanja ostaju u kodu, a animacije se biraju po stanju. Poslije prenosa: `arena_perf_bench.gd` + `perf_suite_bench.gd` (`arena_muncher_eats`, `arena_merges`).
- **Premium skin:**
  - `skins.json` dobija mapu zamjene dijelova; `UiPip._raster` čita dijelove skina.
  - `cosmetics.json` dobija stavku sa `source: "iap"` i SKU-om.
  - IAP grant → `cosmetics.owned`; Shop Looks kartica s novcem.
  - Provjera: tabla svih pogleda, poza i skinova (kao `muncher-premium-pip-ref/p01`) i FPS po pravilu CD paketa (`performanse.md`).

## 8. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj na `master`.** Priloži i ovaj `.md` fajl.

```
Dvije velike stvari za mobilnu igru Merge Meadow (portrait, flat pastel
cartoon), obje sa svim animacijama.

Pročitaj po ovim tačnim putanjama (repo, master):
  docs/04-experience/design-drafts/muncher-premium-pip-cd-brief.md
    -> §1 (fiksno), §2 (muncher), §3 (premium Pip), §4 (performanse),
       §5 (stanja, paket, samoprovjera)
  docs/04-experience/design-drafts/muncher-premium-pip-ref/  (muncher danas
    m00–m06, sva tri Pip skina u 5 pogleda p01)
  game/scripts/camp/arena_pest.gd, game/scripts/visual/ui_arena_v2.gd
  game/data/pip/rig.json, animations.json, skins.json
  game/assets/pip/parts/, overlays/, hud/
  game/data/cosmetics/cosmetics.json
  design_handoff_pip/, design_handoff_arena_v2/, design_handoff_shop_v2/,
  design_handoff_wardrobe/, design_handoff_settings_fixes/  (tvoji paketi)

A. MUNCHER — POTPUNI REDIZAJN: danas je ljubičasta gusjenica nacrtana
   krugovima u kodu i odudara od igre. Napravi novi lik (vrsta i ime tvoj
   izbor): simpatična napast, ne strašna, čita se na svih 8 livada. Cutout
   rig kao Pip (SVG dijelovi + animacije kao podaci). Sva stanja: spava u
   gnijezdu, budi se („!"), lovi (kretanje u 4 pravca, 85 px/s), jede (0,5 s,
   2 griza, mrvice, usta = centar jedenja), smrznut (2 s, led), odmrzava se,
   zaspi na mjestu; plus „Muncher's awake!" i reakcija kad mu sjemenka
   pobjegne. Novo gnijezdo. Pravila ponašanja se ne mijenjaju.

B. PREMIUM PIP SKIN ZA PRAVI NOVAC: Classic / Blossom / Sky su promjena boja
   + sitni dodaci. Ovaj mora biti POTPUNO DRUGAČIJI: vlastita tema i priča,
   vlastiti dijelovi i dodaci u svih 5 pogleda (front, three_q, side, back,
   top), premium kvalitet koji opravdava cijenu. Isti pivoti — svih 75
   postojećih animacija mora raditi. Plus vlastita poza, potpis, idle detalj,
   reakcija na T3 i cilj, HUD glava. Prikaži ga na svim površinama uz Classic.
   Shop · Looks premium kartica s cijenom u novcu i Ormar kartica s oznakom
   „Premium" (sva stanja). Predloži cijenu i ime proizvoda. Samo kozmetika.

PERFORMANSE (MORA, §4): animacije samo transformima i zamjenom frejma,
ništa se ne crta po frejmu; 1 atlas ≤ 1024 po liku / skinu; efekti ≤ 12
sprite-ova; SVG muncher ≤ 120 KB, skin ≤ 150 KB. Brojeve napiši u README.

TEHNIČKI (Godot 4.7, GL Compatibility, slabiji Android): artboard
1080 x 1920. Stil kao Pip: ravne boje, obrub, jedna tvrda sjena. BEZ blura,
glowa, gradijenata i maski.

ISPORUKA (§5): novi folder design_handoff_muncher_premium_pip/, CIJELI U
ZIPU za preuzimanje u chatu (design/*.dc.html, assets/, godot/*.json,
README sa § Odlučeno, § Performanse i § Samoprovjera — 10 stavki iz §5.3,
svaka da/ne, provjereno u pregledaču PRIJE nego pošalješ zip).

NE RADI: pravila munchera, nove valute ili pakete, Classic / Blossom / Sky,
zvuk. Jedan dizajn za svaki, tvoj izbor, neka bude prelijepo.
```

## Povezano

- [[../_index|04-experience]]
- [[../../06-production/CHECKPOINT|CHECKPOINT]]
- [[pip-cd-brief|Pip]] · [[merge-arena-cd-brief|Arena]] · [[ispravke-settings-cd-brief|Ispravke + Settings]]
- [[../../01-vision/design-pillars|design-pillars]] — Pillar 2
