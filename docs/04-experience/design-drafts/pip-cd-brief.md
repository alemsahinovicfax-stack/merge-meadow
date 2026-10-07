---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, lik, pip, animacija, kozmetika, shop, home, arena, run, claude-design]
povezano:
  - wardrobe-cd-brief
  - shop-v2-cd-brief
  - seasons-cd-brief
  - merge-arena-cd-brief
  - run-cd-brief
  - art-direction
  - likovi
  - performanse
  - design-pillars
  - CHECKPOINT
ai_sažetak: "Brief za Claude Design: potpuni redizajn Pipa (lik, tri skina Classic / Blossom / Sky) i njegovih animacija na svim mjestima — Shop i Ormar kao izlog, Home kartica i polje s ponašanjem i interakcijom s prirodom po sezoni, Arena s reakcijama, run iz ptičije perspektive (trk, prelaz trake, pad, cilj). Isporuka je cutout rig sa SVG dijelovima i animacijama kao podacima za Godot, uz budžet performansi."
---

# Pip — redizajn lika i animacija — Claude Design brief

> **Status 2026-10-07: brief spreman, čeka CD.** Prompt je u §11. Paket se vraća kao `design_handoff_pip/` (zip). Slike današnjeg stanja: `pip-ref/` (19 slika iz igre).

**Pip** je zec i lice igre. Vidi se na svakom ekranu: u Shopu kao kozmetika koja se kupuje, na Homeu na kartici i na polju sezone, u Areni u uglu i u runu kao lik kojim igrač upravlja. Ovaj brief traži **novog Pipa od nule** (lik, tri skina, sve animacije) i to **u formatu koji Godot može vrtiti bez gubitka FPS-a**.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | §1–§10 + slike u `pip-ref/` | Šta mora, šta smije, kako Pip izgleda danas, šta se isporučuje |
| **Ti** | **§11** | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §4, §5, §6 | Današnje vrijednosti iz koda, format riga i animacija, budžet performansi |

**Prije slanja prompta: commitaj i pushaj na `master`.** CD čita fajlove iz repoa po tačnoj putanji.

## 1. Zašto

Današnji Pip je ~20 elipsi u jednom SVG-u od 2 KB (`pip_idle.svg`). Ima jedan pogled (sprijeda), tri statične poze (stoji, njuši, spava) i nijedan dio koji se pomjera sam za sebe. Sva „animacija" je skaliranje, nagib ili skok **cijele slike**. Posljedice:

- **Shop.** Pip Blossom (250) i Pip Sky (200) su isti crtež s dvije-tri zamijenjene boje (`pip-ref/13`). Ne izgledaju kao nešto vrijedno coina.
- **Home.** Na polju sezone Pip klizi lijevo-desno s poskakivanjem slike, njuši i spava (`pip-ref/04–07`). Ne reaguje ni na sezonu, ni na cvijeće, ni na igrača.
- **Arena.** Pip sjedi u uglu i na merge samo pulsira (skala 1,18; `pip-ref/08–10`). Muncher u istoj Areni (ljubičasta gusjenica, 6 stanja) je izražajniji od glavnog lika.
- **Run.** Prepreke i staze su crtane odozgo, a Pip je sprijeda, bez nogu u pokretu, i klizi trakama (`pip-ref/11–12`). Ne trči, ne prelazi traku, ne pada. Kod pada se slika samo nagne za −13°.

Korisnikov sud: Pip „izgleda kao da ga je neko dijete nacrtalo za dvije minute". Cilj je lik s privlačnošću (appeal) koju bi igrač prepoznao na ikoni u Store-u, s ličnošću koja se vidi u svakom pokretu, i skinovi za koje igrač **želi** platiti coinima.

## 2. Pravila koja ostaju FIKSNA

| Pravilo | Vrijednost |
|---|---|
| Ko je Pip | **Zec**, ime Pip, podrazumijevani ljubimac. Prvi suputnik u tutorialu. Lik, proporcije, oblici i detalji su **potpuno slobodni** — traži se redizajn, ne dorada. |
| Stil igre | Flat 2D cartoon, pastelno, cozy, mekan obrub (`docs/04-experience/art-direction.md`). Flat cel sjenčenje (ravne plohe tona) je **dozvoljeno i poželjno**. **Bez gradijenata, blura, glowa, SVG filtera i maski.** |
| Boja Classic Pipa | ostaje u **mint porodici** (danas `#A8E6CF`). Mint je i boja branda u UI-ju (chrome, Shop). Tačnu nijansu biraš ti. |
| Pillar 2 | skin je **samo izgled**, nikad snaga, loot ni magnet. Nijedan tekst ni animacija ne smije sugerisati prednost. |
| Katalog i cijene | `pip_blossom` 250, `pip_sky` 200, slot `pip_skin`, Classic je besplatan Default. ID-jevi i cijene se ne mijenjaju (save ih drži po `id`). Starter Pack (Support tab) sadrži Pip Blossom. |
| Gameplay runa | promjena trake je tween pozicije **0,12 s**; swipe prag 50 px; kolizija Pipa **56 × 56**; Pip stoji na y = 0,82 × 1920 = **1574**; trake x **270 / 540 / 810**, širina 200. Udarac u prepreku završava run. Ovo se ne mijenja. |
| Tajminzi kraja runa | pad i cilj imaju fiksne vremenske trake (§4.5). Animacija mora stati u njih. Zadnji kadar se snima i postaje pozadina Loot ekrana. |
| Rasporedi površina | zone i veličine iz §4.2 ostaju: polje (zona stopala, pločica Looks), kartica sezone, ugao Arene (+ keepout za sjemenke), HUD čip runa, pozornice Shopa i Ormara. Smiješ promijeniti veličinu Pipa unutar svoje kutije (±15 %), ali ne i kutiju. |
| Ostatak igre | header, footer, UI pop-upovi, sezone, Muncher, prepreke i pickupi se ne diraju. |
| Drugi ljubimci | Mochi (mačka, `companion_config.gd`) i Bramble (lisica, post-launch) se ne redizajniraju. Format riga mora biti takav da ga kasnije mogu koristiti i oni. |
| Reduce motion | igra ima postavku `GameState.reduce_motion` (već gasi ambijent). Svaka animacija mora imati mirnu varijantu (§5.5). |

## 3. Šta se traži

Tačke 1–8 su **obavezne**. Izgled, ličnost, pokreti i koreografija su tvoja odluka. Jedan dizajn.

**Kvalitet.** Ovo je najvažniji vizuelni element igre i ne smije biti jednostavan ni generičan. Odvoji vrijeme na dizajn lika prije animacija:
- jezik oblika (šta Pipa čini Pipom u siluetu);
- proporcije u „glavama";
- linija (debljina, gdje se prekida, gdje je unutrašnja linija);
- sjenčenje u 2–3 ravna tona;
- detalji koji se čitaju i na 88 px (krzno na obrazima, vrh ušiju, jastučići šapa, pahuljasti rep);
- ličnost kroz pokret. Koristi principe animacije: anticipacija, squash & stretch, overlap i follow-through ušiju i repa, arcs, secondary action.

Pravi zečevi imaju divna ponašanja koja možeš koristiti:
- **binky** — skok s okretom od sreće;
- **flop** — baci se na bok kad je opušten;
- **thump** — lupne zadnjom nogom kad se trgne;
- **periscope** — stane na zadnje noge i gleda okolo;
- **grooming** — umiva lice šapama;
- trzanje nosa i okretanje ušiju prema zvuku.

1. **Novi lik — model sheet.**
   - **Turnaround:** sprijeda, 3/4, profil, odostraga i **odozgo (ptičija perspektiva)** za run.
   - **Izrazi:** najmanje 12 (sretan, oduševljen, radoznao, pospan, iznenađen, uplašen, tužan / razočaran, ponosan, ošamućen, odlučan, smijeh, „ouch").
   - **Test siluete:** crna silueta na 64 px mora se čitati kao zec i kao Pip.
   - **Kratka biblija lika u README:** ličnost u 3–4 rečenice i kako se vidi u pokretu, jezik oblika, proporcije, paleta kao tokeni, pravila linije i sjenčenja.
2. **Tri skina: Classic (Default), Blossom (roza), Sky (plava).**
   - Paleta je **tokeni** (tijelo, sjena tijela, svijetli ton, unutrašnjost ušiju, obrazi, nos, šape, oči, obrub…). Skin = nova vrijednost tokena.
   - Plaćeni skinovi moraju izgledati **vrijedno coina**: pored boje, svaki ima **najmanje jedan prepoznatljiv detalj** — šaru, dodatak, vrh ušiju, rep ili mali FX u boji skina (npr. latice za Blossom, oblačić za Sky). Detalj se vidi u **svakom pogledu i svakoj animaciji**, i na 88 px.
   - Novi skin kasnije mora biti **zapis u podacima** (paleta + opcionalni dodatni dijelovi), ne novi crtež cijelog Pipa ni novi kod.
3. **Shop i Ormar — Pip kao izlog.**
   - **Looks kartica** (pozornica 984 × 300): Pip mora izgledati kao proizvod. Poza za izlog po skinu, kadriranje, tlo ili postolje unutar postojeće pozornice. Pokaži stanja: nije kupljen, kupljen, nošen.
   - Tap na karticu (ili kupovina) pokreće **potpisni pokret skina**: jednokratna animacija ≤ 1,5 s.
   - **U listi Shopa Pipovi stoje mirno** (statična poza za izlog); animira se samo kartica koju je igrač dodirnuo.
   - **Pozornica Ormara** (1032 × 300) smije imati idle loop. Sličice Ormara 210 × 150.
   - **Starter Pack** pločica (~152 px visine, Pip Blossom) i Pip u praznom Boosters tabu („All set here").
   - Opcionalno nova ikona slota / sekcije Pip (`slot_pip.svg`) da prati novu siluetu.
4. **Home — kartica sezone i prelaz.**
   - Pip na kartici (230 px) ima „živ" idle: disanje, treptanje, uši, pogled.
   - Pri prelazu kartica → polje (Pip putuje 230 → 190 px) Pip **skoči na polje** umjesto da klizi kao slika.
   - Kad se igrač vrati iz runa ili Arene, Pip ga **pozdravi**.
5. **Home — polje sezone: ponašanje i interakcija s prirodom.** Ovo je srce Homea. Traži se:
   - **Kretanje kao zec**: hop ciklus (ne hod), okret lijevo / desno, zaustavljanje s anticipacijom.
   - **Idle varijante** (najmanje 6): disanje, treptaj, okretanje ušiju, periscope, grooming, češanje uha zadnjom nogom, protezanje, zijevanje, binky, flop.
   - **Cvijeće**:
     - njuši cvijet (danas: cvijet se nakloni i pusti polen);
     - kihne od polena;
     - divi se cvijetu koji je upravo izrastao.
     - **Ne jede igračevo cvijeće.**
   - **Spavanje**: sklupča se ili flop, „Zzz" je dio animacije. Danas se ambijent smiri dok Pip spava — to ostaje.
   - **Interakcija sa sezonom** — za **svaku od 8 sezona najmanje 2 interakcije** vezane za njen ambijent ili motiv (§4.6). Primjeri (tvoj izbor):
     - svitac sleti na uho i Pip ga prati pogledom;
     - pahulja padne na nos pa kihne;
     - list mu padne na glavu pa ga strese;
     - zaroni u jazbinu i izviri na drugoj;
     - pukne mjehurić nosom;
     - prati meteor pogledom;
     - odmahuje dim šapom.
   - **Tap na Pipa**: najmanje 3 reakcije. Ponovljeni tapovi eskaliraju (smijeh → binky → „dosta" s osmijehom). Tap ne smije pokvariti vodoravni swipe huba.
   - **ApplyMoment** (novi skin iz Ormara): Pip pokaže novi izgled. Danas je to skok 1,18 / 280 ms i krem prsten.
   - Sve to opisano kao **sistem ponašanja** (§5.4): stanja, težine po sezoni, trajanja, okidači, cooldown, šta prekida šta.
6. **Arena — Pip kao navijač.** Pip ostaje u svom uglu (§4.2) i ne napušta kutiju. Reakcije:
   - **idle**: sjedi i posmatra polje;
   - **prati pogledom** sjemenku koju igrač vuče (glava i zjenice prema meti, proceduralno);
   - merge T1 → T2 (mala radost), T2 → T3 (velika);
   - combo „hop" i „big" (danas 0,28 / 0,36 s; tajming smiješ zadržati ili predložiti novi);
   - **Muncher se probudi** (trgne se, thump);
   - **Muncher pojede sjemenku** (razočaran, uši padnu);
   - **T3 zamrzne Munchera** (likuje);
   - korpa dobije nove sjemenke (oduševljen);
   - „You need more seeds!" (slegne ramenima, pogleda u prazne šape);
   - dugo nema unosa (zijevne pa zadrijema, budi se na prvi dodir).
7. **Run — ptičija perspektiva.** Pip je nacrtan **odozgo** i trči **prema vrhu ekrana**, kao što su staze i prepreke već crtane. Animacije:
   - **trk**: zečji galop, zadnje noge doskoče ispred prednjih, uši se vijore, rep poskakuje. Ciklus je **vezan za brzinu svijeta** (§4.5): napiši dužinu koraka u px i formulu `speed_scale = scroll_speed / 400`, tako da stopala ne klize ni na 400 ni na 600 px/s;
   - **prelaz trake** lijevo i desno: nagib tijela u smjeru, uši i rep kasne. Glavni pokret je unutar **0,12 s**, smirivanje smije trajati do 0,2 s poslije, bez uticaja na koliziju;
   - **pokupi** coin, sjemenku, dijamant: kratke, različite reakcije (≤ 0,3 s, ne prekidaju trk);
   - **magnet aktivan**: igra crta prsten oko Pipa (ne diraj ga). Pip smije imati mali znak (npr. uši gore);
   - **start** runa: iz stojećeg u sprint;
   - **pad**: udari u prepreku, prevrne se ili posrne naprijed, raširi se, ošamućen (zvjezdice), uši padnu. Mora stati u vremensku traku pada, a **zadnji kadar se čita** jer postaje pozadina Loot ekrana;
   - **cilj** („Time!"): uspori sa svijetom (0,30 s) i proslavi. Zadnji kadar se čita;
   - **ustajanje** poslije Revive (reklama, max 1 po runu): Pip ustane i nastavi trk ≤ 0,5 s.
   - **Sjena** ispod tijela odozgo. Kod skoka i pada razmak sjene pokazuje visinu.
   - **Tijelo bez ušiju odozgo pokriva otprilike kvadrat kolizije 56 × 56**, da udarac djeluje pošteno.
   - **HUD portret** (88 × 88 u čipu gore lijevo): bista ili lice. Izraz se mijenja na događaj (pokupi → sretan, udarac → „ouch", malo vremena → odlučan). Zamjena kadra, ne loop.
8. **Skin svuda.** Svaki pogled, dio, izraz, FX i HUD portret radi u sva tri skina, preko tokena (§5.3).

## 4. Današnje stanje (mjere iz koda)

### 4.1 Art danas

| Fajl | Šta je |
|---|---|
| `game/assets/sprites/pip_idle.svg` | 2 KB, viewBox 256. ~20 elipsi, jedan pogled sprijeda. Boje: tijelo `#A8E6CF`, unutrašnjost / trbuh `#D4F5E4`, obrazi `#FFB88C` (opacity 0,32), obrub `#2D3436` 3 px, oči `#4A4A4A` |
| `game/assets/sprites/pip_sniff.svg`, `pip_sleep.svg` | ~10 KB svaki, iste boje (Season Kit poze na polju) |
| `game/data/cosmetics/cosmetics.json` | skin = `look.recolor` (mapa hex → hex). Blossom: `#A8E6CF→#FFD3DE`, `#D4F5E4→#FFF0F3`, `#FFB88C→#FF94AE`. Sky: `#A8E6CF→#C2E2FA`, `#D4F5E4→#EAF5FE` |
| `game/scripts/visual/pip_assets.gd` | zamijeni boje u SVG tekstu, rasterizuje 2× (512 px) preko `Image.load_svg_from_string`, kešira po skinu |
| `game/scripts/visual/pip_draw.gd` | proceduralna rezerva (krugovi) kad tekstura ne postoji — ide u brisanje |

### 4.2 Gdje se Pip vidi

Sve mjere su u px. Hub stranica je 1080 × 1633 (od y = 143), Arena 1080 × 1633, run 1080 × 1920.

| Mjesto | Fajl | Veličina i položaj | Šta radi danas |
|---|---|---|---|
| Home — kartica sezone | `game/scripts/visual/ui_home_v3.gd` | kutija 230, gornji lijevi ugao `PIP_CARD_POS` (425, 1027); sjena `[45, 8, 140, 30]` (left, bottom, w, h) | statičan |
| Home — prelaz kartica → polje | `ui_home_v3.gd` (`pip_field_pos`, `pip_shadow_at`) | 230 → 190, ease in-out cubic | slika putuje i skalira se |
| Home — polje sezone | `game/scripts/ui/season_field_pip.gd`, FSM u `game/scripts/ui/season_field.gd` | kutija **190**, stopala 19 iznad dna kutije; zona stopala `PIP_BASE_ZONE` **(151, 1306, 614, 131)**; pločica Looks (876, 1265, 180 × 180) je keepout; sjena `[35, 6, 120, 26]` | hod 50 % (70 px/s, 2,2–5,5 s, poskok slike 0,42 s / −7 px / 0,97 × 1,03), njuškanje 25 % (`pip_sniff.svg`, nagib ±7°, 0,7–1,4 s, cvijet se nakloni), spavanje 25 % (`pip_sleep.svg`, 1,04 × 0,94, tri „z" 26/32/38 px, 2–5 s, ambijent se smiri na 0,35). ApplyMoment: skok 1,18 / 280 ms + krem prsten 500 ms |
| Arena | `game/scripts/visual/pip_placeholder_control.gd`, `game/scripts/camp/merge_arena_controller.gd`, `game/scripts/visual/ui_arena.gd` | kutija **150**, dolje lijevo, odmak (30, 26) od lijevog ruba i dna; keepout za sjemenke = kutija + (120, 97) na svaku stranu | samo puls skale: merge / T3 1,18 / 0,28 s; combo `hop` 1,18 / 0,28, `big` 1,26 / 0,36 (`ui_arena_v2.gd` `COMBO_PIP`) |
| Run — lik | `game/scripts/visual/pip_visual.gd` (Sprite2D), `game/scripts/run/player.gd` | visina prikaza **112** (`CompanionConfig.RUN_DISPLAY_HEIGHT`), centar trake, y 1574; kolizija 56 × 56; dijete `MagnetRing` (ispuna + isprekidan prsten) | slika sprijeda klizi između traka (0,12 s); pad = rotacija −13° |
| Run — HUD | `game/scenes/run/run_scene.tscn` → `HUD/TopHud/CompanionChip/Row/PipPortrait` | **88 × 88** u čipu s imenom „Pip" | ista slika, umanjena |
| Shop — Looks | `game/scripts/ui/item_preview.gd` (vrsta `companion`), `game/scripts/visual/ui_shop_v2.gd` | pozornica **984 × 300** (radius 24): trake livade aktivne sezone + Pip u sredini + sjena | statičan |
| Shop — Support | `game/scripts/ui/shop_support_card.gd` | pločica Starter Pack, Pip Blossom ~152 visine | statičan |
| Shop — Boosters | `game/scripts/ui/shop_screen.gd` („All set here") | Pip iznad teksta | statičan |
| Ormar | `game/scripts/ui/wardrobe_sheet.gd`, `game/scripts/visual/ui_wardrobe.gd` | pozornica **1032 × 300** (skok 1 → 1,12 → 1 / 0,28 s, y −11 %); sličica **210 × 150** | statičan + skok pri izboru |
| Ikona slota / sekcije | `game/assets/ui/wardrobe/slot_pip.svg` | ikona u Ormaru i naslovu sekcije Shopa | — |

Skin se već primjenjuje svuda (`applies_to`: field, season_card, arena, run, run_hud, camp, shop) i mijenja se bez restarta (`GameState.cosmetics_changed`).

### 4.3 Slike iz igre (`docs/04-experience/design-drafts/pip-ref/`)

| Slika | Šta pokazuje |
|---|---|
| `00a_pip_today_skins_poses.jpg` | tri skina × tri poze, izbliza |
| `00b_pip_today_sizes_silhouette.jpg` | današnje veličine (230 / 190 / 150 / 112 / 88 / 64) i crna silueta |
| `01`, `02` | Home kartica — Country Bloom (svijetla), Moonlit Warren (tamna) |
| `03` | prelaz kartica → polje (pola puta) |
| `04`, `05` | polje sezone — svijetla i tamna |
| `06`, `07` | njuškanje (svijetla), spavanje (tamna, „z") |
| `08`, `09`, `10` | Arena — Country Bloom, Starfall Glade (tamna), combo 5 |
| `11`, `12` | run s preprekama — Country Bloom, Starfall Glade (tamna) |
| `13` | Shop Looks — Pip Blossom i Pip Sky kartice |
| `14` | Shop Support — Starter Pack s Pip Blossom |
| `15` | Shop Boosters — „All set here" |
| `16`, `17` | Ormar — pozornica s Pipom; ApplyMoment na polju |

### 4.4 Ponašanje danas (FSM polja)

`season_field.gd`: stanja `WALK / SNIFF / SLEEP`, težine 0,50 / 0,25 / 0,25. Najmanji pomak 80 px, njuškanje traži cvijet bliže od 72 px. Između stanja nema prelaza, poza se samo zamijeni. Sezone bez kita imaju samo hod.

### 4.5 Run — činjenice za animaciju

| Stvar | Vrijednost |
|---|---|
| Brzina svijeta | 400 px/s na startu (neki nivoi × 1,05), +5 % svakih 15 s (`run_controller.gd`). U običnom runu do ~510 px/s, u Endlessu raste dalje (~600 px/s poslije 2 min) |
| Trajanje runa | 45–60 s (tutorial 45 / 60, nivoi 50–60 s, `game/data/run_levels/`); Endless bez kraja |
| Prepreke | `stone`, `stump`, `hay`. Tijelo 176 × 150 + „kragna" izgažene trave 240 × 52 (`ui_run.gd`) |
| Pickupi | coin, sjemenka (po sezoni), dijamant; magnet ih privlači u radijusu |
| Traka pada | udarac → 0,20 s zamrznuto → Pip nagnut, žetoni se rasipaju, trese se 0,24 s (14 px), banner „Ouch" drži 0,55 s → bijeli bljesak na 0,32 s → **snimak zadnjeg kadra na ~0,75 s** → Loot |
| Traka cilja | banner „Time!" (drži 1,0 s) + prsten 0,32 s; svijet staje za 0,30 s; ukupno 0,62 s → **snimak zadnjeg kadra na ~1,0 s** → Loot |
| Revive | poslije pada, reklama, max 1 po runu → run se nastavlja |

### 4.6 Sezone — ambijent i motivi za interakcije

Izvor: `game/data/seasons/seasons_kit.json` (ključ `kits`). Ambijent su generičke čestice (`game/scripts/visual/season_ambient.gd`). **Interakcija ne upravlja česticama ambijenta** — donosi svoj rekvizit (npr. jedan svitac kao dio animacije), a ambijent radi dalje.

| Sezona | Mjesto | Ambijent | Motivi |
|---|---|---|---|
| Country Bloom | pašnjak, ograda na grebenu, pokošene pruge | latice (drift) | ograda, bale sijena |
| Frost Orchard | zaleđeni voćnjak, snijeg | pahulje (fall) | redovi voćki, zaleđeni ribnjak |
| Lantern Meadow | livada u sumrak | svici (float) | girlanda fenjera, visoka trava |
| Amber Canopy | šumsko tlo pod krošnjom | lišće (fall) + tačke (float) | krošnja, dva debla, snopovi svjetla |
| Moonlit Warren | zečje brdo noću (tamna) | iskre (twinkle) + tačke (rise) | veliki mjesec, **humke s jazbinama** |
| Coral Tide Garden | plićak i pijesak | odsjaji (twinkle) + mjehurići (rise) | obala, školjke, zvjezdače |
| Starfall Glade | proplanak u jelama (tamna) | iskre + meteori + padajuće iskre | prsten jela, zvjezdano nebo |
| Ember Fen | močvara u sumrak vatre (tamna) | žar (rise) + dim (drift) | lokve, rogoz |

## 5. Animacioni sistem — MORA

CD crta u HTML-u, a igra je u Godotu. Zato isporuka nije video ni sprite sheet, nego **rig i animacije kao podaci** koje agent 1 : 1 pretvara u Godot `AnimationPlayer`.

### 5.1 Cutout rig

- Svaki pogled (sprijeda, 3/4, profil, odozdo — koje ti trebaju) je **skup SVG dijelova**: glava, uši (preporuka: 2 segmenta po uhu za overlap), tijelo, trbuh, prednje šape, zadnje noge, rep, lice. Lice ima zamjenjive kadrove: oči (otvorene, treptaj, zatvorene, sretne ^ ^, iznenađene, ošamućene), obrve, usta, nos.
- Za svaki dio u `rig.json` napiši:
  - `id`, `file` i `parent` (hijerarhija);
  - `pivot` (tačka rotacije u px dijela);
  - mirujuću poziciju, rotaciju i skalu;
  - `z` (z se smije mijenjati po ključu);
  - `swap_group` za zamjenjive kadrove.
- Sidro cijelog Pipa je **sredina stopala** (kao danas), da se postojeći rasporedi ne pomjere.
- Flip lijevo / desno = `scale.x = -1` na korijenu, ne novi crtež.

### 5.2 Animacije kao podaci (`animations.json`)

Za svaku animaciju:
- `id`, `view` i `length` (s);
- `loop`;
- `tracks[]`: `part` + svojstvo (`position`, `rotation`, `scale`, `visible`, `z`, `frame` za zamjenu, `modulate:a`) + ključevi `{t, value, ease}`;
- `events[]`: npr. `contact_l` / `contact_r` za korake, `fx:<id>`, `sfx:<ime>` (samo kuke, zvuk ne tražimo);
- pravila: šta prekida ovu animaciju, u šta se vraća, `priority`.

**Easing mora postojati u Godotu:** `linear`, `ease_in`, `ease_out`, `ease_in_out` s eksponentom. Godot ključ ima `transition` (1 = linear, > 1 ease-in, < 1 ease-out, < 0 in-out). Bez CSS cubic-bezier krivulja koje se ne mogu prenijeti.

**Proceduralni slojevi** su kod, ne ključevi. Za svaki napiši parametre:
- `look_at` (glava ± stepeni, zjenice ± px, brzina praćenja) — Arena praćenje sjemenke i polje;
- `blink` (nasumično svakih N–M s);
- brzina trk-ciklusa (`speed_scale`);
- nagib pri prelazu trake vezan za napredak tweena.

### 5.3 Skinovi kao podaci (`skins.json`)

- **Tokeni boja.** Svaki token je jedinstven hex koji se u SVG dijelovima koristi **samo za taj token**. Igra mijenja boje zamjenom hexa, isto kao danas (`look.recolor`).
- `skins.json` po skinu ima:
  - `id` (isti kao u katalogu);
  - `palette {token: hex}`;
  - `overlays[]` — dodatni dijelovi za prepoznatljivi detalj: `part`, `file`, `parent`, `z`, u kojim pogledima;
  - `fx_tint` — boja FX-a za potpisni pokret.
- Novi skin = novi zapis. Predloži kako `look` u `cosmetics.json` upućuje na skin, uz **iste `id`, `slot` i cijene**.

### 5.4 Ponašanje kao podaci (`behaviors.json`)

- **Polje:** stanja i animacije, težine (globalno + po sezoni), trajanja (min–max), okidači:
  - tap;
  - povratak s runa ili iz Arene;
  - novi cvijet izrastao;
  - ApplyMoment;
  - interakcija sezone svakih N–M s.

  Pored okidača napiši cooldown, zabranu ponavljanja iste animacije zaredom i ko koga prekida. Pip ostaje u zoni stopala (§4.2) i ne prolazi kroz pločicu Looks.
- **Arena:** mapa događaj → animacija (§3/6), prioriteti kad se dva događaja poklope (npr. combo dok Muncher jede).
- **Run:** mapa događaj → animacija (§3/7). Trk je osnovni loop, a sve ostalo je jednokratno preko njega ili umjesto njega.

### 5.5 Reduce motion

Za svaku animaciju napiši ponašanje kad je `reduce_motion` uključen: `same` (ostaje), `short` (kraća, bez skokova i tresenja) ili `pose` (samo krajnja poza). Trk u runu ostaje (to je gameplay), ali bez dodatnog tresenja.

## 6. Performanse — MORA

Igra cilja slabiji Android, a razvija se na laptopu s AMD integrisanom grafikom (Godot 4.7, GL Compatibility). Animacije su već jednom oborile FPS (sipanje sjemenki u Areni: 28,8 ms najgori frejm prije popravke). Zato je budžet dio zadatka, ne naknadna misao.

| Pravilo | Budžet |
|---|---|
| Crtanje | **samo transformacije čvorova** (pozicija, rotacija, skala, vidljivost, kadar). Nijedan dio se ne crta iznova po frejmu. Današnji Pip na polju to radi i to se mijenja |
| Teksture | svi dijelovi jednog skina u **jednom atlasu** (GL Compatibility tada crta Pipa u 1–3 draw poziva); atlas ≤ **1024 × 1024** po skinu, na 2× najveće veličine na ekranu |
| Dijelovi | ≤ **30 po pogledu** (uključujući zamjenjive kadrove lica i dodatak skina) |
| SVG izvor | svi dijelovi svih pogleda + FX ≤ **250 KB**; bez filtera, maski, teksta, CSS-a i ugrađenih slika |
| Loop | **jedan loop po Pipu** u isto vrijeme (idle, hop ili trk); sve ostalo je jednokratno. U listi Shopa Pipovi stoje mirno |
| FX | ≤ **12 spriteova** živih po Pipu u isto vrijeme (Zzz, zvjezdice, latice, prašina); svaki nacrtan jednom, animiran transformom |
| Cijena | cilj ≤ **0,3 ms CPU** po frejmu po Pipu na dev laptopu. Agent mjeri benchom; ti u README napiši brojeve koje znaš: dijelovi po pogledu, broj traka i ključeva po animaciji, najveći broj istovremenih čvorova, veličina atlasa, KB |
| Skin | samo opremljeni skin se gradi u igri, ostali na zahtjev (Shop, Ormar). Ako predlažeš pečenje atlasa u PNG (build korak), novi skin i dalje mora biti zapis u podacima |

Današnji brojevi za poređenje (`docs/05-technical/performanse.md`): run prosjek 3,5–3,8 ms po frejmu; Arena sipanje najgori frejm 14,6 ms. Novi Pip ih ne smije primjetno povećati.

## 7. Paleta i tehnika

Postojeći tokeni igre: warm white `#FFF8F0`, ink `#2D3436` (obrub UI-ja i današnjeg Pipa), peach `#FFB88C`, coin gold `#FFD56B`, mint `#A8E6CF`. Izvori: `game/scripts/visual/ui_palette.gd`, `ui_shop_v2.gd`, `ui_home_field.gd`.

- **Obrub**: tvoja odluka (ink ili tamniji ton tijela, promjenljiva debljina kao oblik). Mora se čitati na svih 8 sezona, posebno na tamnim (Moonlit Warren, Starfall Glade, Ember Fen, Lantern Meadow; `pip-ref/07`, `09`, `12`).
- **Sjenčenje**: ravne plohe, najviše 3 tona po materijalu (osnova, sjena, svjetlo).
- **Sjena na tlu**: danas pilula `rgba(26, 26, 20, .14)`. Smiješ je redizajnirati; ostaje ravna boja s alfom.
- Godot rasterizuje SVG preko ThorVG-a. Koristi samo `path`, `circle`, `ellipse`, `rect`, `polygon`, `g` s `transform`, `fill`, `stroke`, `opacity`.

## 8. Isporuka

### 8.1 Stanja i animacije

**A. Lik**

| # | Šta |
|---|---|
| 1 | Model sheet: turnaround (sprijeda, 3/4, profil, odostraga, odozgo), proporcije, jezik oblika |
| 2 | Izrazi (≥ 12) i zamjenjivi kadrovi lica |
| 3 | Tri skina u svim pogledima + test siluete (64 px, crno) + kontrast na svih 8 sezona |

**B. Animacije** — svaka pokrenuta u pregledaču, u sva 3 skina

| Mjesto | Najmanje |
|---|---|
| Shop / Ormar | poza za izlog po skinu (statična), potpisni pokret po skinu, idle za pozornicu Ormara, ApplyMoment |
| Home kartica | idle, pozdrav pri povratku, skok na polje (prelaz) |
| Polje | hop ciklus + okret + stop, ≥ 6 idle varijanti, njuškanje + kihanje, divljenje novom cvijetu, spavanje (ulaz, loop, buđenje), ≥ 3 reakcije na tap, **≥ 2 interakcije po sezoni × 8** |
| Arena | idle, look-at (parametri), mala i velika radost, combo hop / big, trzaj + thump (Muncher budan), razočaranje (Muncher jede), likovanje (Muncher zamrznut), oduševljenje (nove sjemenke), slijeganje ramenima („need more seeds"), drijemanje i buđenje |
| Run | trk (sa `speed_scale`), prelaz lijevo i desno, 3 reakcije na pickup, magnet znak, start, pad (cijela traka do snimka), cilj (cijela traka do snimka), ustajanje (Revive), HUD portret ≥ 4 izraza |

**C. U kontekstu** — kadrovi na pravim ekranima, u px igre

- Shop Looks s dvije kartice (nije kupljen / nošen);
- Starter Pack;
- „All set here";
- Ormar (pozornica + sličice);
- Home kartica (svijetla i tamna sezona);
- polje za svih 8 sezona (po jedan kadar interakcije);
- Arena (idle, look-at, combo big, Muncher budan);
- run (trk na svijetloj i tamnoj sezoni, prelaz trake, pad — 4 kadra, cilj — 3 kadra);
- HUD čip.

### 8.2 Paket

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_pip/
  README.md                 šta otvoriti · § Biblija lika · § Odlučeno ·
                            § Rig · § Animacije (tabela: id, mjesto, okidač,
                            trajanje, loop, prekida / vraća u, reduce_motion) ·
                            § Ponašanje · § Skinovi · § Performanse (budžet
                            i brojevi iz §6) · § Šta se briše · § Samoprovjera
                            · § Ideje van zadatka
  design/
    Pip Character Sheet.dc.html   turnaround, izrazi, skinovi, silueta; prop skin
    Pip Animations.dc.html        plejer za SVAKU animaciju: prop anim, skin,
                                  speed, loop, reduce_motion; scrub po vremenu
    Pip In Context.dc.html        svi kadrovi iz §8.1 C; prop surface, season,
                                  skin, state
    Pip Specs.dc.html             anatomija riga (dijelovi, pivoti, z), grafici
                                  tajminga, dijagram ponašanja, tabela budžeta
    support.js
  assets/pip/
    parts/<view>/*.svg      jedan SVG po dijelu, boje samo iz tokena
    overlays/<skin>/*.svg   dodaci skinova
    fx/*.svg                Zzz, zvjezdice, latice, prašina, rekviziti
                            interakcija (svitac, pahulja, list…)
    hud/*.svg               HUD portret ako je zaseban crtež
    icons/slot_pip.svg      (opcionalno) nova ikona slota / sekcije
  godot/
    pip_export.json         meta · tokens · views · surfaces (kutija, sidro,
                            skala po mjestu iz §4.2) · godot_map · decisions
    rig.json                §5.1
    animations.json         §5.2
    behaviors.json          §5.4
    skins.json              §5.3 — classic, pip_blossom, pip_sky
    ui_pip.gd               konstante (veličine, sidra, tajminzi); isti nazivi
                            gdje postoje (PIP_SIDE, PIP_CARD_SIZE, PIP_SIZE…)
    pip_tree.txt            stablo čvorova PipRig scene + red prenosa po
                            mjestima (preporuka: rig + skinovi → Shop/Ormar →
                            Home → Arena → run)
```

**Imena slojeva:**
- korijen: `PipRig`, `PipShadow`, `Body`, `Belly`, `Head`, `Face`;
- uši: `EarL`, `EarL2`, `EarR`, `EarR2`;
- lice: `EyeL`, `EyeR`, `BrowL`, `BrowR`, `Nose`, `Mouth`, `Cheeks`, `Whiskers`;
- udovi: `PawL`, `PawR`, `FootL`, `FootR`, `Tail`;
- dodaci: `SkinOverlay`, `FX`, `HudPortrait`.

### 8.3 Samoprovjera (u README, svaka stavka da/ne, provjereno u pregledaču)

1. Crna silueta na 64 px se čita kao zec i kao Pip — sprijeda i odozgo.
2. Pip se čita na svih 8 sezona, i na svijetlim i na tamnim.
3. Svaka animacija iz §8.1 B postoji, radi u sva 3 skina, a loop se vrti bez trzaja.
4. Glavni pokret prelaza trake je ≤ 0,12 s; pad i cilj staju u svoje trake (§4.5); zadnji kadar oba se jasno čita.
5. Trk na 400 i 600 px/s — stopala ne klize (`speed_scale`).
6. Tijelo odozgo (bez ušiju) pokriva ~56 × 56.
7. Plaćeni skinovi imaju prepoznatljiv detalj koji se vidi na 88 px; novi skin je samo zapis u `skins.json`.
8. Samo ravne boje: nigdje gradijent, blur, glow, filter ni maska.
9. Budžet iz §6 je ispunjen, a brojevi su u README § Performanse.
10. Najviše jedan loop po Pipu; u listi Shopa Pipovi stoje mirno.
11. Pip ostaje u svojim zonama (polje, Looks keepout, kutija Arene).
12. Svaka animacija ima `reduce_motion` ponašanje.
13. Nijedan tekst ni pokret ne sugeriše da skin daje prednost (Pillar 2).

## 9. Ne tražimo

- Redizajn Mochija ili Bramblea.
- Nove skinove za prodaju, nove cijene, novu valutu ili nove mehanike.
- Promjene gameplay tajminga, kolizije, brzine runa ili Arena mehanike.
- Nove rasporede ekrana, header, footer, pop-upove, Munchera, prepreke, pickupe ni sezone. Mijenja se samo Pip unutar postojećih okvira, uz opcionalnu novu `slot_pip.svg`.
- Zvuk (kuke `sfx:` u događajima su dobrodošle).
- Video, GIF ili sprite sheet kao jedini izvor animacija — mora postojati rig + `animations.json`.
- Više varijanti — jedan dizajn.

## 10. Scope

Launch lista M8 sadrži Pipa kao podrazumijevanog ljubimca i Pip skinove u Shopu za coine (Shop v2, Ormar). Ovo je **art i animacija postojećeg sadržaja**: bez nove ekonomije i bez novih mehanika, a skinovi su samo izgled, pa Pillar 2 ostaje netaknut. Paket je najveći dosad, pa ga agent prenosi u fazama (red iz `pip_tree.txt`) i za svaku fazu mjeri FPS (`arena_perf_bench.gd`, `run_perf_bench.gd`, novi bench za polje).

## 11. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj na `master`.** Priloži i ovaj `.md` fajl.

```
Ovo je REDIZAJN LIKA: Pip, zec i lice igre — novi lik, tri skina i SVE
njegove animacije na svim mjestima u igri. Mehanika i ekonomija se ne
mijenjaju.

Pročitaj po ovim tačnim putanjama (repo, master):
  docs/04-experience/design-drafts/pip-cd-brief.md
    -> §2 (fiksno), §3 (šta se traži), §4 (mjere iz koda), §5 (rig i
       animacije kao podaci — NAJVAŽNIJE za prenos), §6 (performanse —
       MORA), §7 (tehnika), §8 (stanja, paket, samoprovjera)
  docs/04-experience/design-drafts/pip-ref/        (19 slika današnjeg Pipa,
                                                    00a–17, popis u §4.3)
  docs/04-experience/art-direction.md              (stil igre)
  game/assets/sprites/pip_idle.svg, pip_sniff.svg, pip_sleep.svg
  game/data/cosmetics/cosmetics.json               (skinovi = recolor)
  game/data/seasons/seasons_kit.json               (8 sezona: ambijent, motivi)
  game/scripts/visual/pip_assets.gd, pip_visual.gd, ui_home_v3.gd,
    ui_arena.gd, ui_arena_v2.gd, ui_run.gd, ui_wardrobe.gd, ui_shop_v2.gd
  game/scripts/ui/season_field_pip.gd, season_field.gd, item_preview.gd
  game/scripts/run/player.gd, run_controller.gd
  game/scripts/camp/merge_arena_controller.gd, arena_pest.gd (Muncher)
  design_handoff_seasons/, design_handoff_arena_v2/, design_handoff_run/,
  design_handoff_shop_v2/, design_handoff_wardrobe/   (tvoji paketi)

KVALITET: Pip danas izgleda kao da ga je dijete nacrtalo za dvije minute
(~20 elipsi, jedan pogled, sva animacija je skala cijele slike). Ovo je
najvažniji vizuelni element igre — NE SMIJE biti jednostavan ni generičan.
Odvoji vrijeme na dizajn lika prije animacija: jezik oblika, proporcije,
linija, flat cel sjenčenje u 2–3 tona, detalji koji se čitaju na 88 px,
ličnost u pokretu (anticipacija, squash & stretch, overlap ušiju i repa).
Koristi prava zečja ponašanja: binky, flop, thump, periscope, grooming.

ŠTA TRAŽIM:

1. NOVI LIK: turnaround (sprijeda, 3/4, profil, odostraga, ODOZGO za run),
   >= 12 izraza, test siluete na 64 px, biblija lika u README. Classic
   ostaje u mint porodici.

2. TRI SKINA: Classic (Default), Blossom (roza, 250), Sky (plava, 200).
   Paleta kao tokeni. Plaćeni skinovi moraju izgledati VRIJEDNO COINA:
   pored boje, svaki ima prepoznatljiv detalj (šara, dodatak, rep, mali
   FX) vidljiv u svakom pogledu i na 88 px. Novi skin = zapis u podacima.

3. SHOP I ORMAR — Pip kao izlog: poza za izlog po skinu na Looks kartici
   (984 x 300), potpisni pokret skina na tap (<= 1,5 s), stanja nije
   kupljen / nošen; pozornica Ormara (1032 x 300) s idle loopom, sličice
   210 x 150, Starter Pack, "All set here". U listi Shopa Pipovi stoje
   mirno.

4. HOME: živ idle na kartici sezone (230), skok na polje pri prelazu,
   pozdrav pri povratku. NA POLJU (190): hop ciklus kao zec, >= 6 idle
   varijanti, njuškanje / kihanje od polena, divljenje novom cvijetu,
   spavanje, >= 3 reakcije na tap (eskaliraju), ApplyMoment, i za SVAKU
   od 8 sezona >= 2 interakcije s prirodom (svitac, pahulja, list,
   jazbine, mjehurić, meteor, dim…). Sve kao sistem ponašanja
   (behaviors.json). Interakcija donosi svoj rekvizit, ne upravlja
   česticama ambijenta.

5. ARENA (150, ugao dolje lijevo, ne napušta kutiju): idle, prati
   pogledom sjemenku koju igrač vuče (look-at), radost na merge T2 i T3,
   combo hop / big, reakcije na Munchera (budi se, jede, zamrznut),
   nove sjemenke, "need more seeds", drijemanje bez unosa.

6. RUN IZ PTIČIJE PERSPEKTIVE: Pip nacrtan ODOZGO trči prema vrhu.
   Zečji galop vezan za brzinu svijeta (400 px/s, +5 % / 15 s;
   speed_scale = scroll/400, stopala ne klize), prelaz trake lijevo /
   desno (glavni pokret <= 0,12 s), reakcije na coin / sjemenku /
   dijamant, start, PAD (udar, prevrtanje, ošamućen — mora stati u
   traku pada, zadnji kadar postaje pozadina Loot ekrana), CILJ, ustajanje
   poslije Revive, HUD portret 88 s izrazima. Tijelo odozgo pokriva
   koliziju 56 x 56.

7. FORMAT ZA GODOT (§5): cutout rig — SVG dio po dijelu, rig.json
   (parent, pivot, z, swap_group), animations.json (trake po dijelu,
   ključevi s easingom koji postoji u Godotu, događaji), behaviors.json,
   skins.json (tokeni + overlays). Video ili sprite sheet nije izvor.

FIKSNO: Pillar 2 — skin je samo izgled. ID-jevi i cijene (250 / 200).
Gameplay runa (0,12 s, 56 x 56, trake 270/540/810, y 1574) i trake pada /
cilja. Zone i kutije Pipa iz §4.2. Mochi, Muncher, UI, sezone se ne diraju.

PERFORMANSE (MORA, §6): samo transformacije čvorova, nijedan redraw po
frejmu; jedan atlas po skinu <= 1024 x 1024; <= 30 dijelova po pogledu;
SVG ukupno <= 250 KB; jedan loop po Pipu; FX <= 12 spriteova; cilj
<= 0,3 ms po Pipu. Brojeve napiši u README § Performanse.

TEHNIČKI (Godot 4.7, GL Compatibility, slabiji Android): sve u px igre.
Ravne boje, max 3 tona po materijalu. BEZ gradijenata, blura, glowa,
filtera i maski. Svaka animacija ima reduce_motion ponašanje.

ISPORUKA (§8): novi folder design_handoff_pip/, CIJELI U ZIPU za
preuzimanje u chatu:
  design/Pip Character Sheet.dc.html, Pip Animations.dc.html (plejer za
  SVAKU animaciju), Pip In Context.dc.html, Pip Specs.dc.html, support.js
  assets/pip/parts, overlays, fx, hud
  godot/pip_export.json, rig.json, animations.json, behaviors.json,
  skins.json, ui_pip.gd, pip_tree.txt
  README.md sa § Biblija lika, § Odlučeno, § Rig, § Animacije, §
  Ponašanje, § Skinovi, § Performanse, § Šta se briše i § Samoprovjera
  (13 stavki iz §8.3, svaka da/ne, provjereno u pregledaču PRIJE nego
  pošalješ zip).

NE RADI: Mochi, Bramble, nove skinove za prodaju, nove cijene ili
mehanike, promjene gameplay tajminga, nove rasporede ekrana, više
varijanti. Jedan dizajn, tvoj izbor — neka Pip bude lik koji igrač voli.
```

## Povezano

- [[../../06-production/CHECKPOINT|CHECKPOINT]] — traka PIP-01
- [[wardrobe-cd-brief|Ormar]] — skin na pravom artu, ApplyMoment
- [[shop-v2-cd-brief|Shop v2]] — Looks kartica, Starter Pack
- [[seasons-cd-brief|Sezone]] — ambijent i motivi po sezoni, poze Pipa na polju
- [[merge-arena-cd-brief|Arena]] — ugao Pipa, Muncher
- [[run-cd-brief|Run]] — staze, prepreke, HUD
- [[../art-direction|art-direction]] — stil
- [[../../03-content/likovi/_index|Likovi]] — Pip, Mochi, Bramble
- [[../../05-technical/performanse|performanse]] — benchovi i pravila
- [[../../01-vision/design-pillars|design-pillars]] — Pillar 2
