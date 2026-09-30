# Merge Arena v2 — handoff (redizajn 2)

Brief: `docs/04-experience/design-drafts/merge-arena-cd-brief.md` §11. Jedan dizajn, bez varijanti. Mehanika se ne mijenja.

## Šta otvoriti

- `design/ArenaScreen.dc.html` — cijela Arena 1080 × 1920. Prop `season` (8), `lush` (0–4), `combo` (0–8), `state` (`empty` · `full` · `hunting` · `eating` · `frozen` · `bag_empty`), `grayscale` (provjera). Tap na sjemenku = živi combo (prozor 1,4 s), tap na korpu = sipanje.
- `design/Arena Specs.dc.html` — 6 stanja munchera, 3 stanja korpe, svih 8 livada na nivou 0 i 4, combo stepenice, tabela kontrasta (računa se u browseru).
- `design/Arena Today.dc.html` — Arena danas, rekreirana iz koda (referenca „prije").
- `design/arena_v2_data.js` — jedini izvor brojeva; `godot/arena_v2_export.json` i `godot/ui_arena_v2.gd` su generisani iz njega.
- Djeca: `ArenaField`, `SeedChip`, `Muncher`, `SeedBasket` (`.dc.html`).

## § Odlučeno

### Opšte — pravilo dvostrukog ruba
1. **Svaki objekat igre na polju ima taman vanjski rub i svijetlu traku odmah do njega** (sjemenka, muncher, korpa, Pip). Za bilo koju boju polja jedna od te dvije ivice ima ≥ 3 : 1 — to je dokaz, ne podešavanje po sezoni: najgori slučaj je `√((L_svijetlo+0,05)/(L_ink+0,05))`. Sjemenka 3,47 · muncher 3,27 · korpa 3,21 · Pip 3,00.
2. Zato livade smiju biti i svijetle (Country Bloom, Frost, Coral) i tamne (noćne sezone) — kontrast ne ovisi o polju.

### Sjemenka
3. **SeedBase: tamni prsten 4 px `#2D3436` ispod krem rima** (T1 krug r 71,2; T2 zaobljen kvadrat r 42). Crta se prvi, ispod sjene. 4 px = (CHIP_MIN_DIST 142,8 − 134,4) / 2 — dvije baze se nikad ne preklapaju. Na tamnoj livadi se gotovo ne vidi, pa sjemenka izgleda kao danas.
4. Ostalo na sjemenci se ne mijenja (rim, well `#22342A`, T2 prsten, ★3 zlato, stanja).

### Korpa (R2)
5. **Vreća postaje pletena korpa za piknik** — igrač je već zove „korpa"; korpa ima otvor odozgo, pa se sjeme koje leži u njoj prirodno vidi.
6. **Dodir 300 × 280** (≥ 280 × 280 iz §11.7, strože od 280 × 250 iz §11.4). Centrirana, 40 px iznad dna polja → `y = polje − 40 − 280`. Keepout `Rect2(-185, -349, 370, 520)` ostaje (relativno na centar i dno korpe).
7. **Količina bez brojača: do 12 cvjetova u gomili, `vidljivo = count ≤ 0 ? 0 : clamp(round(count·12/40), 1, 12)`.** Tri reda (5 · 4 · 3): prvi red je utonuo iza ruba, treći viri do ručke. 40 sjemenki = gomila dodiruje ručku; ručka je „mjerna linija". Cvjetovi su pravi crteži (`FlowerAssets`, T1) tipova iz `preview_types`, redom po mjestima.
8. **Brojač ostaje** (krug r 42, 44 px, dolje desno) kao tačan broj — nije jedini signal.
9. **Tri stanja oblikom:** prazna = vidi se tamni otvor i prazna ručka, nema brojača · ima sjemena = gomila + klaćenje kao danas (≥ 2) · sipa = nagib −12° (0,1 s / 0,25 s back) oko dna, 2–3 cvijeta u letu iz otvora.
10. **Peach krpa preko prednjeg ruba** — korpa je glavno dugme Arene, pa nosi CTA boju (kao aktivan tab i Trade).
11. Boje: pleter `#C99A5F`, rub `#F0DDB4`, ink `#3A2A1B` (5 px), ručka `#B88A55`, otvor `#5A4230`, krpa `#FFB88C` / `#E8A374`. Usta korpe (`get_mouth_position`) = centar otvora (150, 146).

### Combo (R4)
12. **Combo broj živi na mjestu spajanja: „×N"** iznad nove sjemenke (−78 → −128 px), pop 0,18 s (back), drži 0,30 s, nestaje 0,25 s. Krem `#FFF8F0` s obrubom 8 px `#2D3436`; od 5 zlatan `#FFD56B`. Veličina 52 / 58 / 64 / 70 px za combo 2 / 3 / 4 / ≥ 5. Nema trake, nema pilule, nema odbrojavanja.
13. **Polje reaguje svjetlom, ne oblicima:** `ComboLight` = ravan pravougaonik boje sezone preko livade, ispod sjemenki. Alpha 0,04 / 0,07 / 0,10 / 0,13 za combo 2 / 3 / 4 / ≥ 5; ulaz 0,2 s (cubic out) na svaki merge, drži se dok combo živi, povratak na 0 za 0,35 s (cubic in-out) kad prozor od 1,4 s istekne.
14. **Talas:** svaki combo merge šalje prsten (10 px, alpha 0,55 → 0, 0,5 s) od mjesta spajanja: r 90 → 260 / 320 / 380. Crta se ispod sjemenki. Od combo 4 elementi livade u krugu talasa kratko se naklone (1 → 1,18 → 1, 0,3 s, kašnjenje po udaljenosti).
15. **Vrhunac je 5 i ne raste dalje.** Na 5: zlatan broj, novčić 56 px leti od spajanja do coin chipa (0,5 s), postojeći „+N" pop kod chipa, Pip veći skok (1,26 / 0,36 s). Iznos (+2) i limit (10/dan) se ne diraju; kad je limit potrošen, nema novčića, broj ostaje zlatan.
16. **Bujnost i combo se ne sudaraju jer ne diraju isto svojstvo:** bujnost (T3, trajno u sesiji) mijenja *oblike* — broj, rast i boju slojeva livade; combo (trenutno) mijenja samo *svjetlo i kretanje* — alpha preklopa, prstenovi, kratki naklon. Preklop se računa preko trenutne boje bujnosti, pa je promjena uvijek ista relativna. T3 merge u comboju: T3 burst zamjenjuje talas (jedan prsten, ne dva), bujnost kreće svoj crossfade 0,6 s ispod.

### Muncher (R1)
17. **Gusjenica** — najprepoznatljiviji „jede cvijeće" štetočina; lanac segmenata je druge siluete od okrugle sjemenke. Glava r 50 (centar = centar jedenja, usta unutar 36 px), segmenti r 38 / 32 / 26 prate putanju glave.
18. **Ostaje ljubičast** (jedina neprijateljska boja u igri) + **žute pjege `#FFEAA7` kao upozoravajuće boje** (osa, gusjenice u prirodi). Tijelo `#A275CD` (svjetlija varijanta `#8C61B8`), rub `#3E2856`. Pjege + taman rub = dvostruki rub.
19. **Stanja se čitaju pozom, ne bojom:** sklupčan „C" + zzz (u gnijezdu / bez njega) · rep gore + „!" + okrugle oči · ispružen + obrve V + iskežen · usta širom + „^ ^" + mrvice · kocka leda s ledenicama.
20. **Zzz ide desno i nisko** (vrh ~16 px od polja), antene do ~28 px — ništa se ne odsijeca ispod headera kad je gnijezdo na y 108.
21. **Gnijezdo 250 × 112: prsten od grančica s ukradenim laticama**; prednji rub se crta preko tijela, pa muncher „leži u" gnijezdu. Spawn keepout gnijezda se ne mijenja.
22. Bez zuba osim dva zaobljena krem „nokta", bez sline, bez crvene — cozy, ali jasno proždrljiv.

### Livade (R3)
23. **Svaka livada je drugo mjesto, ne druga boja:** Country Bloom — valoviti brežuljci i ograda · Frost Orchard — ravan horizont, dva reda stabala, nanosi · Lantern Meadow — visoka trava sa strana, girlanda fenjera · Amber Canopy — krošnja odozgo, dva debla, snopovi svjetla · Moonlit Warren — mjesec, humke, jazbine · Coral Tide — obala dijagonalno, voda gore, pijesak dolje · Starfall Glade — prsten jela oko čistine, zvijezde · Ember Fen — lokve, rogoz, dva pojasa dima.
24. **Recept, ne slika:** 3–4 sloja (poligoni u %), 4–6 vrsta rasutih elemenata (30 oblika iz 6 primitiva), broj na nivou 0 i 4, zone. **0 PNG**, 0 KB novih asseta.
25. **Raspored bez RNG-a: R2 niz** (plastični broj) — isti u JS i GDScriptu, pa port izgleda tačno kao mockup.
26. **Bujnost 0 → 4:** instanca i ima alpha `clamp(n0 + (n4−n0)·nivo/4 − i, 0, 1)` (kao današnje busenje), rast `grow`, boja sloja lerp base → lush; crossfade 0,6 s ostaje. Šta raste po sezoni: `fields[].lush` u JSON-u i u Specs §4.
27. **Polje je pozadina:** elementi su ±10–15 % svjetline od tla, bez obruba i bez ikakvog pokreta dok se igra (jedino kretanje je combo talas / naklon i crossfade bujnosti).
28. Gnijezdo, korpa i Pip imaju AVOID zone — rasuti elementi se tu ne crtaju.

## § Šta se briše

- `ArenaMeadowBg` crtež (brda, busenje, cvjetići u 4 boje) i `MEADOW_BASE/LUSH` → zamijenjeno receptom po sezoni (Arena više nije jedna livada).
- Muncher: krug r 52 s ušima, oči-tačke, pravougaona usta, heksagonalna ljuska.
- Vreća: tijelo 214 × 178 / 126, vrat 118 × 34, 3 cvijeta iz vrata.
- `BAG_HIT 280 × 250` → 300 × 280.

## § Runda 2

Prva runda (2026-09-12, smjer B) je dala sjemenku (krem rim + tamni well) i raspored; 2026-09-24 HUD i Done su obrisani. Ova runda ne dira sjemenku osim SeedBase prstena, ne vraća HUD ni Done i ne mijenja mehaniku ni ekonomiju.

## § Samoprovjera (mjereno u browseru, Arena Specs + ArenaScreen u svih 6 stanja na 6 sezona)

| # | Stavka | |
|---|---|---|
| 1 | Svih šest stanja munchera razlučivo i u crno-bijelom (Specs §1, drugi red je grayscale) | **da** |
| 2 | Muncher se ne može zamijeniti sa sjemenkom ni na jednoj od 8 livada (Specs §2) | **da** |
| 3 | Korpa: količina se vidi bez brojača (1 → 12 cvjetova); tri stanja jasna; dodir 300 × 280 ≥ 280 × 280 | **da** |
| 4 | Osam livada jedna pored druge — različita mjesta (8 različitih horizonata/struktura), ne ista slika u 8 boja (Specs §4) | **da** |
| 5 | Sjemenka ≥ 3 : 1 prema polju na svih 8, nivo 0 i 4 — najmanje 3,49 (Amber Canopy); bez SeedBase bi bilo 1,00–1,20 (Specs §5) | **da** |
| 6 | Nijedna livada nije PNG; sve su brojevi u `fields` | **da** |
| 7 | Combo se vidi na polju (×N, talas, svjetlo), nigdje trake ni pilule | **da** |
| 8 | Combo reakcija i bujnost rade istovremeno bez sudara (različita svojstva, Specs §6) | **da** |
| 9 | Nigdje blur, glow ni gradijent u dizajnu Arene (sjene su tvrde, prsten na coin chipu je ravan 0-blur rub; sjena headera/footera je postojeći hub chrome) | **da** |

## § Ideje van zadatka

- Muncher bi mogao nositi pojedenu sjemenku 0,3 s u ustima (vidljivo na tamnim livadama) — traži izmjenu tajminga jedenja, zato nije urađeno.
- Sezonski ton na `NavLockPill` (boja combo svjetla) povezao bi footer s livadom.
- Za plaćene sezone jedan mali PNG motiv ≤ 256 × 256 (npr. školjka za Coral Tide) mogao bi zamijeniti proceduralni oblik — budžet dozvoljava, recept ne traži.
- `SEASON_HUE` proceduralno cvijeće na tamnim livadama: vrijedi provjeriti well-kontrast za noćne sezone kad stigne pravi art (seeds-flowers brief).

