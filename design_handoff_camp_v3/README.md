# Camp v3 — handoff (treća runda)

Brief: `docs/04-experience/design-drafts/camp-v3-cd-brief.md` — **fajl ne postoji na `master`**, pa je rađeno po promptu (§10 preskočen). Prethodno: `design_handoff_camp/`, `design_handoff_camp_v2/`. Jedan dizajn, bez varijanti.

## Šta otvoriti

- `design/CampScreen.dc.html` — Camp 1080 × 1920, raspored v2. Prop `scene`: `seeds_full` · `seeds_small` · `sell_mergeable` · `trade_hold` · `sell_dropped` · `seeds_few` · `seeds_empty` · `flowers_reserved` · `flowers_holdstop` · `season_ready` · `unlocking` · `no_season` · `flowers_empty`; `tint` frost / lantern / amber.
- `design/ArenaGate.dc.html` — Arena prije runde, polje se vidi. `scene`: `ok_53` · `short_49` · `short_48` · `short_tap` · `ok_50` · `empty_tap`. Tap na korpu ispod 50 otvara modal (živo). Polje, korpa i muncher su kopije iz `design_handoff_arena_v2` (`ArenaField`, `SeedBasket` + prop `hideCount`, `Muncher`, `arena_v2_data.js`).
- `design/UpgradesSheet.dc.html` — sheet na Homeu (livada nije nacrtana). `scene`: `fresh` · `mixed` · `short_flower` · `short_both` · `max` · `buy` · `new_season` · `returning`.
- `design/Camp Specs.dc.html` — sva stanja na jednom kanvasu, primjeri zbroja, oznaka vs katanac, 5 stanja dugmeta, budžet, animacije, pozadina.
- `design/HubScreen.dc.html` — header/footer chrome v2 (kopija, nepromijenjeno; `part` = header / footer / full).
- `assets/` — `icon_mergeable.svg` (jedini novi asset).
- `godot/` — `camp_v3_export.json` (uklj. `third_boost`, `basket`), `ui_camp.gd` (izmjene), `camp_tree.txt`, `README.md`.

## § Odlučeno

1. **Pozadina Campa je #4E3F5A „dusk heather"** — ista plum porodica kao chrome, ali svjetlija (1,6 : 1), pa traka uokviruje stranicu, a krem kartice drže 9,2 : 1.
2. **Sjene na stranici su plum rgba(20,14,26,.34)** — zelenkasta sjena v2 na plum podlozi izgleda prljavo.
3. **Sekcija 1289 (1585 bez kartice)** — Δ 36 iz chrome v2 ide u listu; kartica sezone 276 iz v2 ostaje.
4. **MergeableMark je mint pilula 64 × 42 s dva kruga koji se dodiruju** — krugovi su jezik Arene (tab, sjemenke), a mint, oblik pilule i odsustvo teksta je odvajaju od tint-kvadrata s katancem.
5. **Oznaka stoji u redu pipsa, desno** — taj red na Seeds tabu ima mjesta, a na Flowers ga zauzima ReservedBadge, pa se dvije oznake nikad ne sretnu.
6. **MergeableWarning je jedna linija 48 px ispod TradeRow, bez panela** — upozorenje rezervisanog je panel iznad; ovo je informacija, ne zabrana.
7. **Tekst linije: „Arena takes all N", a na 4 „Arena takes all 4 · sell 1 and none go" + amber disk** — samo na granici treba reći da sljedeća prodaja izbacuje cijeli stog.
8. **Prodaja ne staje na 4** — sjeme se smije prodati; prijelaz 4 → 3 samo skine oznaku i liniju (0,14 s).
9. **Arena gate je jedna pilula „N / 50" iznad korpe, polje ostaje vidljivo** — igrač mora vidjeti livadu; jedini novi podatak je broj sjemena koje se može spojiti.
10. **Korpa je i dalje dugme; ispod 50 tap otvara modal „Not enough seeds" (N / 50 + sitni tipovi s 4 tačke iz A3 + Back to Camp)** — objašnjenje dolazi tek kad zatreba, a ne prekriva polje unaprijed.
11. **Na 50 pilula postane mint i oznaka u njoj se upali** — isti znak kao na chipu u Campu, pa igrač poveže oznaku s otvaranjem.
12. **Naslov sheeta je ime sezone u tint pilulici, umjesto „Upgrades"** — dugme na Homeu već kaže šta je sheet; ime sezone kaže čiji su nivoi.
13. **UpgradeButton 340 × 132 nosi obje cijene (cvijet ×2 · coin N); ono što fali dobije pink pilulu** — jedan pogled kaže šta fali, bez „Need".
14. **Krivulja coina ostaje 10 / 20 / 40 / 60** — 130 coina po boostu ≈ 16 runova, sva tri ≈ 49, prvi nivo za 1–2 runa.
15. **Cvijet za nadogradnju troši se samo iznad Kept granice** — inače bi nadogradnja tiho jela cvijeće rezervisano za sljedeću sezonu.
16. **Treći boost: Twin Seeds — p = 8 % × nivo da pickup sjemena da +2** — pomaže baš novo pravilo (stog do 4, vreća do 50), a ne dira magnet, loot, fail, revive, trajanje, cap 40 ni valute.

## § Šta se ne vraća

„Next free season", „Details", podnaslov Unlock, Merge prečica, „Arena fuel" / „reward", „1 coin each", „hold 10 / s", „Need N", naslov „Upgrades".

## § Mora ostati (provjereno)

Trade 1 / 10 po s · cijene · Kept N / M + strip, držanje staje na granici · sezona 500 + 20 · cap 40 · header 143 / footer 144 #2A2233.

## Ideje van zadatka

- Long-press na GateStack (sitni) mogao bi skočiti u Camp s tim tipom odabranim.
- Twin „+2" u runu mogao bi imati kratki dvostruki pop (0,12 s) umjesto broja.
- Kad je N ≥ 50 dok je igrač u Campu, Arena tab bi mogao dobiti mint tačku umjesto pink badgea.
