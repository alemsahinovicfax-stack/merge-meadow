# Pop-ups — handoff

Brief: `docs/04-experience/design-drafts/popups-cd-brief.md`. Ovo je jedan dizajn: sistem od pet vrsta pop-upa, a u njemu su nacrtana svih 22 ID-a iz §4. Brief kaže „21“, ali kad se prebroje ID-ovi H1–H8, X1–X3, S1, C1, A1–A4 i R1–R5, ima ih 22. Mehanika, iznosi i uslovi ostaju isti.

**Ideja:** svaki pop-up je ista „naljepnica“ kao pločice polja, kartice Shopa i Ormar: krem, ink rub i jedna tvrda sjena. Vrste se razlikuju **oblikom**, pa igrač zna kako se pop-up zatvara prije nego išta pročita:
- **Modal** ima pločicu s naslovom na gornjem rubu.
- **Sheet** ima ručku.
- **Oblačić** ima rep.
- **Toast** je tamna pilula.
- **Leteća poruka** je broj s ink obrubom.

## Šta otvoriti
- `design/PopupsScreen.dc.html` — artboard 1080 × 1920. Propovi:
  - `popup` — ID iz §4,
  - `state` — stanja iz §9.1, nabrojana ispod u § Popis,
  - `zone` — `auto | home | hub | shop | camp | arena | run`; `auto` uzima zonu iz ID-a,
  - `season` — boja livade na Homeu i u Areni,
  - `still` — bez ulaznih tweenova (za sličice).

  Na R5, dugme Double se može pritisnuti i prolazi kroz učitavanje do duplanog loota.
- `design/Popup Specs.dc.html`:
  1. Sistem: tokeni, table s komponentama na 50 %, anatomija, kretanje, zatvaranje.
  2. Prije → poslije za svaki ID. Lijevo je slika iz igre, desno je svako stanje živo iz PopupsScreena.
  3. Samoprovjera koja mjeri DOM (dugme **Run self-check** ili `#selfcheck` u URL-u, ~30 s). Isti ispis ide u konzolu kao `SELFCHECK …`.
- `design/icons/` — **novi asseti:** `icon_video.svg` (oznaka reklame) i `icon_half.svg` (½), zajedno manje od 1 KB. Ostalo su nepromijenjene kopije iz `design_handoff_hub_chrome_v2` (chrome ikone), `design_handoff_arena_v2` (crteži sjemena i cvijeća `icons/flowers/*_t1|t3.svg`, Pip) i `design_handoff_wardrobe`.
- `design/ref/before/` — 21 slika iz `popups-ref/`, služe samo za poređenje.
- Pozadine se ne diraju; to su kopije postojećih DC-ova:
  - run: `RunScreen.dc.html` iz design_handoff_run,
  - Arena: `ArenaField`, `SeedBasket`, `Muncher` + `arena_v2_data.js` iz design_handoff_arena_v2,
  - Ormar: `Wardrobe`, `ItemCard`, `ItemPreview` + `wardrobe_data.js` iz design_handoff_wardrobe,
  - polje Homea: markup iz `FieldWithWardrobe.dc.html`,
  - header i footer: markup iz chrome v2.

  Shop v2 i Camp su prikazani kao označena prazna stranica, jer se njihov sadržaj ne mijenja.
- `godot/`:
  - `popups_export.json` — meta, tokens, components, popups, animations, strings_en, godot_map, decisions,
  - `ui_popups.gd` — konstante, StyleBox fabrike i tweenovi; imena su ista kao u UiHomeField gdje postoje,
  - `popups_tree.txt` — stablo čvorova i red prenosa,
  - `cosmetics.json` — kopija, treba je samo Ormar u mockupu.

## § Odlučeno
- **Vrsta svakog pop-upa:**
  - Modal: H3, A3, R3, R5, i R4 kao „banner“ (pločica bez panela).
  - Sheet: H4, H5, H6.
  - Oblačić: H1, H2, A1, A2, R1.
  - Toast: H7, H8, X1, S1. X3 je statusna pilula u tokenima toasta.
  - Leteća poruka: X2, A4, C1, R2.
- **Scrim** `#1A161E` 55 %, ravna boja, isti u hubu i u runu. U hubu pokriva samo stranicu, pa header i footer ostaju čitljivi. U runu pokriva cijeli ekran.
- **Pločica s naslovom modala** (h 112) kaže ton. Zlatna = poklon, mint = run završen, roze = pao / pola, krem rim = odluka (pauza, need seeds). Tako se tekst naslova nikad ne boji u crveno ili zeleno, a kontrast ink na pločici je ≥ 9 : 1.
- **Modal** je 984 široko (x 48), radius 48, rub 4. Širina je takva da kod pada u jedan red stanu tri chipa „18 → 9“.
- **Dugmad:** jedna porodica, h 132 i radius 36. Primary je peach, secondary bijelo, disabled ravno bez sjene, loading ima tri tačke, done je mint. **Reklama** je lavanda s video oznakom i uvijek **h 120**, u svom redu iznad Retry / To Camp, pa nikad nije veća od njih. Svaki status reklame vidi se na dugmetu: „Double •••“, „Doubled ✓“ i „No ad now“. Red s teksom statusa više ne postoji.
- **Kraj runa** ima isti modal za pad i za kraj. Prikazuje se **preko zamrznutog runa**, a ne na crnoj sceni. Kod pada je svaki broj precrtan i prepolovljen (18 → 9), uz pečat „Kept half“. Revive se pojavljuje samo kod pada i prije Double. U tutorialu i bez reklama ostaju samo Retry i To Camp. Retry je secondary, To Camp primary.
- **Pauza:** tray „If you quit“ pokazuje šta nosiš, precrtano na pola, a dugme Quit nosi ikonu ½.
- **Need more seeds:** umjesto liste je mreža pločica koja se prelama (HFlowContainer). Tako se bug s jednim redom ne može ponoviti. Svaka pločica ima crtež i 4 tačke. Jedno dugme, samo za Camp.
- **R1** više ne pokriva staze ispred Pipa. Rep pokazuje na brojač coina koji tekst objašnjava.
- **H1:** oblačić je lijevo od Pipa. Prsten oko Play je jedini loop na Homeu i staje na Play.
- **H2:** oblačić je u postojećem `HINT_RECT`, s ikonom Arene.
- **H4:** pločice 328 × 410 s okvirom korpe s polja (zlato + tamni bunar) i pravim crtežom 134. Ime je 40, zvjezdice 38 `#7A4A28`. Zaključana pločica ima katanac u sivom okviru. Izabrana ima rim i mint ✓. Clear je secondary s ikonom korpe i onemogućen je kad ništa nije izabrano.
- **H5:** dugme JE cijena: crtež cvijeta (T3) i „×2“. Kad fali cvijeća, piše „Need 1“, na maksimumu „Max“. Kupovina traje 0,4 s: kartica dobije rim, novi segment prelazi iz zlatne u mint, a dugme pokaže „Done“. „Lv“ ne piše, nivo pokazuju segmenti.
- **H3 „Back in 7h“** — potvrđeno 2026-10-02. Samo prikazuje vrijeme do sljedećeg resetovanja; agent ga izračuna, pravilo se ne mijenja.
- **R4 „Ouch!“ kod pada** — potvrđeno 2026-10-02. ≤ 1 s, bez dugmeta, pa odmah R5.
- **R5 preko zamrznutog runa** — potvrđeno 2026-10-02. Loot scena dobija snimak zadnjeg kadra runa ispod scrima umjesto crne pozadine.
- **Crteži sjemena i cvijeća** su iz igre: T1 je sjeme, T3 cvijet (`ArenaChipDraw`). U mockupu se koristi roster Country Bloom za sve sezone.

## § Šta se briše
- H1: „The card opens your meadow.“
- H2: „Merge your first flower in the Arena to unlock the basket.“ (zamjena: „Your first Arena merge unlocks it“)
- H3: „Daily chest: +8 coins and +3 … seeds!“, „(bag almost full!)“ (zamjena: „Bag almost full“), „Come back tomorrow“, „Daily chest already opened today.“, OK kao jedino obojeno dugme
- H4: ime od 22 px, zaključani red „samo posivljen“
- H5: „Levels stay for every run. Paid in flowers.“, „Lv 0 / 4“, „2 × Meadow Clover“ kao tekst, „Upgrade“ (dugme sad nosi cijenu), „Spent 2 × …“, „Nothing left to buy“ (zamjena: „Max“)
- X3: „ROUND IN PROGRESS“ velikim slovima (zamjena: „Round in progress“)
- A1: jedna rečenica „Tap the bag to pour seeds. Drag matching seeds together.“ (zamjena: dva reda sa slikama)
- A3: „Every type needs 4 seeds to reach T3. Run again to collect more.“ (zamjena: „Every type needs 4“), „1/4“ kao tekst
- R1: providna traka preko staza
- R3: „Quitting keeps half of what you carry. No revive is used.“
- R4: „Full basket — nothing lost“ (zamjena: ikona korpe i „Nothing lost“)
- R5:
  - „+9 Coins / +3 Meadow Clover / …“
  - „Obstacle hit — kept 50%: …“
  - „Hit an obstacle? …“
  - „Full rewards — Pip reached the finish!“
  - „Run complete. Head to camp or try again!“
  - „(test stub ~1s)“
  - „Revive — continue run“ (zamjena: „Revive“)
  - red statusa „Loading rewarded ad… / Loot doubled! / Could not double loot. / Revive not available. / Ad not available — try again later. / Loading…“ (sve je sad na dugmetu)
  - crveni / zeleni tekst naslova
  - dugmad od 72 px
- Stari izgledi: tamni loot panel, poklon 400 × 320, bijeli toast za postavke, tamna traka s imenom sjemena u runu, NavLockPill u plum/gold boji.

## § Sistem
| Komponenta | Mjere (px, 1080 × 1920) |
|---|---|
| PopupScrim | `#1A161E` 55 %. Hub: stranica (0, 143, 1080, 1633). Run: cijeli ekran. Fade 220 ms. |
| PopupModal | w 984, krem, rub 4 ink, radius 48, sjena 0 14 0 rgba(20,14,26,.45), padding 92/48/48, gap 36. ModalPlate h 112, radius 56, naslov 56/900, centriran na gornji rub. |
| RewardTray / RewardChip | Tray: rim `#FFF6D6`, rub 3 ink 18 %, radius 36. Chip: h 132, bijeli, rub 3, crtež 92, broj 56. Varijanta „pola“: stari broj 40 precrtan. Varijanta „×2“: zlatni tag. |
| PopupSheet | h 922 / 1326, rub 4 gore, radius 36. SheetHandle 120 × 12. Naslov 56. Close je secondary 132. Povlačenje > 160 zatvara. |
| CoachBubble | Krem, rub 4, radius 32, padding 26/34, tekst 44/800 (vodeći red 48/900), disk ikone 72, max 760. Rep 52 × 32 u 4 smjera ili bez repa. Sjena na runu je tamnija (rgba(10,14,12,.55)). |
| Toast | Ink pilula h 100, radius 50, krem rub 3, tekst 44/900 krem, disk 60, bez sjene. Trake: y stranice 1110 / 1250, 24 ispod headera, Shop 1600. Red: max 2, korak 116. |
| FloatPop | 64/900 s ink obrubom 10. Zarada je zlatna i ide gore do brojača, potrošnja roze i pada dolje. Sjeme: 56 + ime 44. |
| PopupButton / AdButton | 132 / 120, radius 36, rub 4, sjena 0 8 0. Pritisak: y +6, sjena 2. |
| Nove boje | `#EAD2FF`: svjetlija LAVENDER (reklama se učitava, već u Shop v2). `#7A4A28`: tamnija od `#9E6645` za zvjezdice (4,5 : 1 i na rimu). |
| Ormar (H6) | Rub sheeta 3 → 4. Grabber 120 × 10 → SheetHandle 120 × 12. Close: krem radius 28 bez sjene → PopupButton secondary. Raspored nepromijenjen. |
| Kretanje | Modal: 0,9 → 1 + alpha, 220 ms back-out. Sheet: y, 320 / 280 ms. Oblačić: 0,85 → 1 iz vrha repa, 180 ms. Toast: y 24 + alpha, 180 ms. Nagrada: chipovi 240 ms, razmak 90 ms. Loopovi: samo prsten Play (H1) i tri tačke dugmeta koje čeka. Nikad nisu zajedno na ekranu. |
| Zatvaranje | Sheet: scrim, Close, povlačenje, back. Poklon: dugme ili tap van. R3 / R5 / A3: samo dugme (back na R3 = Keep running). Oblačići ne blokiraju unos. Toast i leteće poruke imaju `mouse_filter IGNORE`. Jedan modal ili sheet u isto vrijeme. |

## § Popis (ID → komponenta · stanja)
| ID | Komponenta | Stanja (`state`) |
|---|---|---|
| H1 | CoachBubble ↓ + PlayRing | default |
| H2 | CoachBubble ← | default, tap |
| H3 | GiftModal (reward) | claimed, near_full, tomorrow |
| H4 | BasketSheet 1326 · SeedTile | none, one, locked |
| H5 | UpgradesSheet 922 · UpgradeCard | both, short, max, buy |
| H6 | WardrobeSheet (tokeni sistema) | default |
| H7 | Toast (y 1110) | default, queue |
| H8 | Toast (y 1250) | unlocked, yours |
| X1 | Toast (ispod headera) | default |
| X2 | FloatPop | spend, earn |
| X3 | NavLockPill (tokeni toasta) | default |
| S1 | Toast (Shop) | default |
| C1 | FloatPop | hold, fly |
| A1 | CoachBubble ↓ | default (`season` country_bloom / moonlit_warren) |
| A2 | CoachBubble ↑ (muncher) | default |
| A3 | NeedSeedsModal · NeedSeedTile | five, one |
| A4 | FloatPop (= X2 earn) | default |
| R1 | CoachBubble ↑ (tamna traka) | default |
| R2 | FloatPop + ime | default, two |
| R3 | PauseModal | default |
| R4 | FinishBanner | time, ouch |
| R5 | RunEndModal · AdButton | fail, fail_noads, fail_tutorial, complete, loading, doubled, many, retry_loading |

## § Samoprovjera (§9.3)
Provjereno 2026-10-02 u Chromiumu na `design/Popup Specs.dc.html` (Run self-check). Provjera mjeri DOM svih 46 živih stanja u sloju pop-upa.
1. **da** — Nacrtana su sva 22 ID-a, kroz 46 stanja; 0 nedostaje i 0 starih izgleda.
2. **da** — Svaki ID pripada jednoj vrsti i svaka vrsta ima svoju oznaku oblika:
   - ModalPlate: 16 stanja,
   - SheetHandle: 8,
   - CoachTail: 8,
   - Toast: 6,
   - FloatPop: 8.
3. **da** — Poklon i kraj runa pokazuju nagradu chipovima sa crtežom (H3: 2, R5: 3–7). Nijedna rečenica s iznosima.
4. **da** — „You need more seeds!“: korpa s 5 tipova daje 5 pločica, svih 5 cijelih u vidnom polju; korpa s 1 tipom daje 1. Jedno dugme, 0 ponuda kupovine.
5. **da** — Reklama je visoka 120, a Retry / To Camp 132. Video oznaka je na svakoj reklami. U tutorialu: 0 reklama i 2 glavna dugmeta.
6. **da** — Pauza: pečat „If you quit“ s ½, precrtano 12 → 6 i 5 → 2, a Quit nosi ½.
7. **da** — 14 izbačenih obrazaca × 46 stanja = 0 pogodaka.
8. **da** — Najmanji tekst 36, najmanji naslov 56, najmanji tekst dugmeta 44, najmanji dodir 120. Najniži kontrast je 5,71 : 1 (INK_SOFT na DISABLED). Na tamnoj traci runa: krem panel, ink 12 : 1.
9. **da** — 0 gradijenata, 0 blura, 0 mekih sjena. Najviše 1 loop po ekranu. Header i footer su markup chrome v2, a HUD runa je `RunScreen.dc.html` nepromijenjen. Mijenja se samo stil pilule X3, kako brief dozvoljava.

**Budžet:** novi asseti su 2 SVG-a, ukupno < 1 KB (≤ 120 KB), bez PNG pozadina.

## Napomena za prenos
- Specs je težak, jer u njemu živi 46 punih ekrana. Sličice se zato učitavaju kad dođu u vidno polje.
- Koordinate u `popups_export.json` su px artboarda, a `ui_popups.gd` koristi ista imena.
- Red prenosa je u `godot/popups_tree.txt`. Prvo ide R5, jer je tu najveća razlika (dugmad 72 → 132).

## § Ideje van zadatka
- Na „Kept half“ bi se izgubljena polovina mogla vidjeti kao chipovi koji izblijede (300 ms), umjesto samo precrtanog broja.
- „Back in 7h“ na Gift pločici polja (mali sat umjesto tačke), da igrač ne mora otvarati poklon.
