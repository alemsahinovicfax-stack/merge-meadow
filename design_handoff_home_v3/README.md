# Home v3 — handoff

Jedan dizajn Homea: biranje sezone (dva taba) i ulaz u polje te sezone. Hub header (143) i footer (144) su chrome v2, nedirnuti.

## Šta otvoriti
- `design/HomeScreen.dc.html` — biranje, interaktivno. Prop `scene` (free_active · free_locked · free_unlock · premium_buy · premium_owned · premium_soon), `tab` (free|premium), `openT` (0–1, zamrznut kadar prelaza). Klik: strelice, tabovi, Play, kartica, Unlock, cijena; na polju Seasons vraća nazad.
- `design/FieldScreen.dc.html` — polje. Prop `season` (8 ključeva), `scene` (gift · basket_empty · first), `reveal` (0–1).
- `design/Home Specs.dc.html` — sva stanja §6.1, kadrovi prelaza, tri koraka Playa, mjere, oba taba.
- `godot/` — export JSON, konstante, stablo čvorova, red prenosa.

## Stanja (§6.1)
1. Free, sezona u kojoj se igra — Pip na kartici, Play = ▶ Play → polje.
2. Free, zaključana — Play postaje „Back" + disk sezone u kojoj se igra; vraća karticu, ne pali run.
3. Sljedeća sezona — još fali: dva chipa (coin 320 / 500, ★3 14 / 20); može: jedno zlatno „Unlock · 500".
4. Premium — cijena ($4.99, zlatno), kupljena („Yours", mint), Ember „Coming soon" bez cijene.
5. Prelaz — kartica se otvara u svoju livadu, Seasons ga pušta unazad.
6. Polje — Amber #FFEBC7 i Moonlit #B8BDFF, Gift s roze tačkom, korpa +5 %, Play pali run.

## § Odlučeno
- **Jedna kartica + strelice, ne traka:** jedna velika livada po ekranu nosi mood bez ijedne rečenice, a strelice (120) su jasniji dodir od swipea koji mora ostati za hub.
- **Kartica je minijatura livade (tri trake iste svjetline):** tako prelaz nije efekt nego istina — kartica se samo raširi i već jeste polje te sezone.
- **Play je 520 × 180 pill u sredini, ne preko cijele širine:** centriran i odvojen od kartice čita se kao jedini glavni potez, a rupa lijevo/desno ostaje prazna zona za hub swipe.
- **Korak 1 mijenja natpis u „Back" + disk aktivne sezone:** igrač vidi kuda ga dugme vodi prije nego tapne; „Play" koji ne pokreće igru bi lagao.
- **Isto dugme putuje u donji red polja:** Play s biranja postaje FieldPlayButton, pa je treći korak (run) fizički isti prst na istom dugmetu.
- **Premium = zlatni tab + zlatni unutrašnji rub + zlatna cijena s draguljem:** zlato je jedini signal „kupuje se", bez objašnjenja.
- **Ember Fen: isprekidani chip „Coming soon", cvijeće na 50 %:** pokazuje da postoji, ali bez ikakvog dugmeta da nije kupovina.
- **Uslovi otključavanja kao dva chipa s brojem, mint kad je ispunjen:** ikone (coin, cvijet prethodne sezone + ★3) zamjenjuju rečenicu „Needs 500 coins + 20 flowers".
- **Cvijet koji fali = silueta u isprekidanom disku + ime:** jedini tekst na kartici osim imena sezone, kako brief dozvoljava.
- **Sezona u kojoj se igra = Pip na kartici + peach tačka u nizu:** Pip već znači „ti" na polju, pa ne treba natpis.
- **Tab se otvara na sezoni u kojoj se igra ako je u njemu, inače na prvoj:** nijedan tap na tab ne mijenja aktivnu sezonu.
- **Pozadina stranice = najsvjetlija nijansa mood boje:** sezona oboji cijeli ekran jednom ravnom bojom, bez gradijenta.
- **Swipe po kartici lista sezone, hub swipe živi na praznom pojasu y 1392–1633 lijevo/desno od Playa:** kontrole blokiraju hub swipe kako traži §2.
- **Jedini loop je ripple na praznoj korpi (polje):** biranje nema loop, pa limit od jednog ostaje.

## § Prelaz
- **Otvaranje** (Play na aktivnoj ili tap na otključanu karticu): 560 ms, ease in-out cubic, jedan Tween s paralelnim trakama.
  - 0–30 %: tabovi, strelice, tačke → alpha 0, y −24.
  - 0–40 %: ime, roster, status na kartici → alpha 0.
  - 0–100 %: SeasonCard rect (24,172,1032,1160) → (0,0,1080,1633); radius 48 → 0; border 4 → 0; sjena 12 → 0. Trake kartice (32.7 % / 36.3 % / ostatak) poklapaju trake livade (523 / 587 / 523).
  - 0–100 %: PlayButton (280,1413,520,180) → (324,1461,432,140), radius = h/2.
  - 55–85 %: FieldPage alpha 0 → 1 (iste boje ispod, pa se ne vidi šav).
  - 72–100 %: cvijeće scale .96 → 1, gornji chrome y −16 → 0, Seasons/Endless x ±254 → 0 (izlaze iza Playa).
- **Nazad** (SeasonsButton): isti Tween unazad, 440 ms — livada se skupi u istu karticu, tab i indeks se postave na aktivnu sezonu.
- **Promjena kartice** (strelice, Back, tab): 220 ms, x ±90 → 0, alpha .4 → 1.

## § Šta se briše
- Stari 836 × 180 Play s diskom i podnaslovom → novi PlayButton 520 × 180.
- Chest slot desno od Playa (rupa) — nema ga.
- Natpisi „FREE · 1 OF 4", „6 flowers · 3 shown", tagline, „Open meadow" + „field · upgrades", „PREVIEW · PREMIUM", „Get … Garden", „no price yet · preview the flowers", „Needs 500 coins + 20 flowers".
- Jedna zajednička traka svih 8 sezona → dva taba.
- Dock tokena (1080 × 222 na y 1327) nije na biranju — **potvrditi** da tokeni žive na polju/runu; ako moraju ostati na Homeu, mjesto je pojas iznad tačaka (kartica se skrati na 1000).

## Otvoreno
- Cijena $4.99 je placeholder; Coral Tide je u mocku „kupljen" samo radi stanja 4b.
- ★3 chip koristi crtež srednjeg cvijeta prethodne sezone kao ikonu — zamijeniti ako postoji ★3 ikona.

## § Ideje van zadatka
- Kratki „bloom" (scale 1 → 1.06 → 1, 300 ms) na disku cvijeta kad se na polju prvi put ubere taj cvijet — veza polje ↔ kartica.
- Na Premium kartici long-press na disk otvara pregled svih 6 cvjetova (sad se vide 3).
- Kad se sljedeća sezona može otključati, peach tačka na njenoj tački u nizu — da igrač zna bez listanja.
