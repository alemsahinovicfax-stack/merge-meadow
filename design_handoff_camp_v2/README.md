# Camp v2 — handoff (druga runda čišćenja)

Brief: `docs/04-experience/design-drafts/camp-v2-cd-brief.md`. Prva runda: `design_handoff_camp/`. Jedan dizajn, bez varijanti.

## Šta otvoriti

- `design/CampScreen.dc.html` — cijeli ekran 1080 × 1920. Prop `scene` bira stanje: `seeds_full`, `seeds_few`, `seeds_empty`, `flowers_reserved`, `flowers_holdstop`, `trade_hold`, `season_ready`, `unlocking`, `no_season` (+ `flowers_empty`). Prop `tint` = frost / lantern / amber.
- `design/Camp Specs.dc.html` — svih 9 stanja na jednom kanvasu, spec komponenti (živi isječci), vertikalni budžet, animacije, 5 stanja Trade dugmeta.
- `design/HubScreen.dc.html` — zadati header/footer (kopija, nepromijenjena).
- `godot/` — `camp_v2_export.json`, `ui_camp.gd` (samo izmjene), `camp_tree.txt`, `README.md` (red prenosa).
- `assets/` — prazno: nema novih fajlova (vidi niže).

## Raspored ukratko

```
24  ┌ SeasonLinkCard 1032 × 276 ───────────────────────┐
    │ Frost Orchard 56                 [🔒 Unlock 300×120]
    │ 🪙 260 / 500  ▬▬▬   │   🎃 12 / 20  ▬▬▬            │
    └──────────────────────────────────────────────────┘
20  (fiksno)
    ┌ StashSection 1032 × 1253 (1549 bez kartice) ─────┐
    │ [ Seeds  8 ] [ Flowers  6 ]           120        │
    │ ┌ StashGrid (skrola) 913 ───────────────────────┐│
    │ │ [128 art | ime · ★★☆ · 🌱12 🪙1 ] × 2 kolone   ││
    │ └───────────────────────────────────────────────┘│
    │ [104 art | Meadow Clover        | Trade 300×120 ] 152 │
    └──────────────────────────────────────────────────┘
24
```

## § Odlučeno

1. **Unlock dugme ide u glavu kartice, desno od imena (300 × 120)** — tako kartica pada s 422 na 276 px i sekcija dobija 146 px više za listu.
2. **Uklonjeni i captioni "Coins" i "Harvest Pumpkin ★★★" ispod traka** — ikona novčića i crtež cvijeta u zlatnom okviru već kažu šta se broji, a ime cvijeta nosi rezervisani chip u Flowers tabu.
3. **U kratkom stanju Unlock nosi lokot 40 px** — razlika "nedostaje / spremno" ne ovisi samo o boji.
4. **U trenutku otključavanja dugme kaže "Unlocked"** — brief dozvoljava jednu riječ potvrde, a burst sam ne kaže šta se desilo.
5. **Sekcija ima fiksnu visinu 1253 (1549 bez kartice), lista unutra skrola** — prijedlog iz brifa; prazan prostor ostaje samo unutar krem panela liste, nikad između blokova stranice.
6. **Visina reda tabova 120 umjesto 132** — bez podnaslova nema šta nositi, a 120 je minimum dodira.
7. **Brojač tipova stoji uz desni rub taba** — ime lijevo, broj desno čita se kao etiketa bez razmišljanja.
8. **Neaktivan tab i disabled Trade su pune boje (#F1EBE4, #EAE4DD)** — isto pravilo kao kontrast audit v1: bez alpha podloga ispod teksta.
9. **Okvir arta 128, crtež 96 (sjeme) / 100 (cvijet)** — najveće što ostavlja 315 px za "Harvest Pumpkin" na 38 px bez skraćivanja.
10. **Ime na chipu 38 px (bilo 40)** — 2 px manje je cijena za +45 % crteža; i dalje iznad minimuma 34.
11. **"each" izbačen s cijene** — brief to dozvoljava; novčić + broj na zlatnoj pilulici već znači cijenu po komadu, a pilula je uz brojač komada.
12. **Rezervisan chip ostaje 176 (bio 244); ReservedBadge zauzima red pipsa** — rezervisano cvijeće je uvijek ★3 sezonski cvijet, pa zlatna rarity podloga i badge nose tu informaciju.
13. **Badge na granici i dalje piše "Kept · 20 / 20", samo prelazi u amber** — jedan tekst manje, a amber rub + amber strip iznad Trade reda kažu da je držanje stalo.
14. **Trade dugme 300 × 120 (bilo 430)** — jedna riječ na 46 px treba ~200 px; ostatak ide imenu predmeta.
15. **Stanja Trade dugmeta nose boja + ikona + jedna riječ** — mirno PEACH "Trade" · drži se tamni PEACH s fillom "Trading" · stalo HOLD_FREEZE + hold_stop "Sell 1" · dira rezervisano PINK + lokot "Trade" · nema ničega sivo "Trade".
16. **"Sell 1" umjesto "Tap to sell 1"** — kraće, a strip iznad objašnjava zašto.
17. **Fill = prodani dio gomile tokom držanja** — fill tako ima značenje (gomila se prazni) umjesto da samo trepće, i na granici se prirodno zamrzne.
18. **Tap kratko napuni fill pa ga isprazni** — prvi tap sam pokaže da se dugme puni, bez rečenice "hold".
19. **Signal držanja pojačan: novčić 44 px leti do coin chipa na svaki tick (max 3), chip dobije prsten** — +N pilula ostaje, ali put do headera se sada vidi; bez čestica.
20. **Strip za stalo držanje skraćen na "Hold stopped · Frost Orchard keeps 20"** — "of these" je suvišno jer strip stoji uz odabrani cvijet.
21. **Prazno stanje: ikona + naslov + CTA, bez rečenice objašnjenja** — CTA ("Play a run ↗" / "Merge in Arena ↗") već kaže odakle stvari dolaze.
22. **EmptyCta vizuelno 100 px unutar 120 px dodira** — manji nego danas (110) a dodir ostaje ≥ 120.
23. **Onemogućen Trade u praznom stanju: isprekidan okvir arta, bez imena, dugme "Trade"** — nema "Nothing selected / pick a type" ni "nothing to trade".
24. **Nema scroll pločice "N types"** — zadnji red koji viri (153 px od 176) je dovoljan znak da lista ide dalje.
25. **Seeds scena ima 8 tipova (4 reda, bez skrola); skrol je dokazan u stanju 9 (14 tipova)** — katalog sjemenki staje u 8, a cvijeće raste do 42.

## § Šta se briše

- Kartica sezone: "Next free season", "Details ↗", captioni "Coins" / "{cvijet} ★★★", podnaslovi Unlock dugmeta, "Unlock {sezona}" → "Unlock".
- Tabovi: "Arena fuel", "reward", "Merge ↗" prečica.
- Chip: "each"; tekst "Hold stops here" (badge ostaje "Kept · N / M"); visina 244 za rezervisani chip.
- Trade bar: "★☆☆ · 1 coin each", "hold 10 / s", "10 / s", "sells reserved", "no hold for this one", "Tap to sell 1", "Nothing selected", "pick a type to trade", "nothing to trade", "empty — switched here".
- Prazno stanje: rečenice objašnjenja ispod naslova.
- Raspored: StackGap koji raste (uzrok rupe 215–375 px).
- Ikone koje više ne trebaju: `icon_merge_arrow.svg`, `icon_reserved.svg` (nisu kopirane u `design/icons/`).

## assets/

Nema novih fajlova. Sve ikone postoje (`icon_coin`, `icon_seed`, `icon_crystal`, `icon_lock`, `icon_hold_stop`). `design/icons/flowers/` su placeholderi iz v1 — igra crta svoj art.

## Ideje van zadatka

- Long-press na chip (0,4 s) mogao bi otvoriti mali popover s rijetkošću i izvorom — samo ako testovi pokažu da igrači ne razumiju pipse.
- Header coin chip mogao bi brojati naviše (count-up) kao u Shopu, umjesto skoka broja.
- "Sell all but kept" ostaje odgođeno iz v1; s fill = dio gomile, prirodan kandidat je dvostruki tap na Trade.
- Kad su sve besplatne sezone otključane, na vrhu sekcije mogla bi stajati tanka traka s prvom plaćenom sezonom — to je Shop odluka, ne Camp.
