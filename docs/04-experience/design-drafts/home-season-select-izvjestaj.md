---
type: iskustvo
status: aktivan
milestone: M8
tags: [dizajn, ui, home, sezone, claude-design, izvjestaj]
povezano:
  - home-season-select-cd-brief
  - camp-cd-brief
  - spec-vertical-slice
  - changelog
ai_sažetak: "Izvještaj o prenosu CD Home paketa (smjer 1a Season Trail) u Godot 2026-09-21: šta se promijenilo, šta testirati u igri, odstupanja od dizajna, poznata ograničenja i šta slijedi."
---

# Home — biranje sezone: izvještaj o prenosu

> Roditelj: [[04-experience/_index|04-experience]] · brief: [[home-season-select-cd-brief]] (§ Implementacija) · datum: 2026-09-21 · **ništa nije commitano**

## Ukratko

CD-ov paket `design_handoff_home/` (smjer **1a Season Trail**) je prenesen u igru. Home više nema dvije trake s tri kartice i skrivenim gestama. Umjesto njih ima **jednu vertikalnu kolonu kartica sezona**: uvijek je jedna otvorena, a tap na drugu je otvara (harmonika).

- **Tvoje 4 odluke (sve po preporuci):** Browser obrisan · pozadina `#2E4733` kao Camp · Ember Fen kao „Coming soon“ kartica · Shop zadržava svoju karticu.
- **Play** sada **odmah pokreće run** u aktivnoj sezoni. Na dugmetu je čip s imenom sezone („Play · Frost Orchard“).
- **Polje sezone** (livada, Pip, korpa) se otvara samo s kartice: tap na otvorenu aktivnu karticu ili na „Open meadow ↗“.
- Na Home **ništa više ne blokira hub swipe**: lijevo/desno uvijek mijenja tab, a gore/dolje lista sezone.

## Šta se vidi na ekranu

| Dio | Izgled |
|---|---|
| **Gornji red** | Daily gift (zlatna kutija s trakama, „Tap to open“ / „Back tomorrow“) + „**2 / 4** free seasons“ sa 4 segmenta. Prije kraja tutoriala gift se ne vidi, pa napredak zauzima cijeli red. |
| **Besplatni put** | Country Bloom → Frost Orchard → Lantern Meadow → Amber Canopy, redom. |
| **Otvorena aktivna sezona** | „Playing now“, ime, tagline, 6 cvjetova u zlatnim okvirima s ★☆☆ i dugme „Open meadow ↗“. |
| **Sljedeća zaključana (next lock)** | Kompaktna kartica: „Next free season“, šta fali („Need 180 more coins and 20 more Harvest Pumpkin“) i dvije trake (coini i ★3 cvijet). Tap je otvara u **puni poster** s velikim Unlock dugmetom. |
| **Unlock dugme** | Mutno dok ne skupiš oboje; **zlatno** kad može („spends 500 coins and 20 …“). Tap troši odmah, zasvijetli prsten, dugme pređe u coin gold („… unlocked“), a nakon ~1 s kartica postaje otvorena sezona s mint čipom **„New“** (~3 s). |
| **Iza next locka** | Tamnije kartice s katancem („Opens after Frost Orchard“). Tap samo trepne. |
| **Premium sezone** | Tihi red „Premium seasons · Free path never needs them“ s 4 tačkice boja i „4 ↓“. Tap otvara listu: svaka premium kartica ima cijenu, a otvorena pokazuje 6 cvjetova i „Get Coral Tide Garden · €3.49 · one-time, no subscription“. Tokom kupovine piše „Purchasing…“; kupljena sezona postaje aktivna i dobija „New“. Ember Fen: katanac, „Coming soon · not for sale yet“. |
| **Play** | Veliko peach dugme preko cijele širine, ikona + „Play“ lijevo, čip sa sezonom desno. |
| **Tutorial** | Žuti oblačić iznad Playa: „First run: tap Play. Seeds you bring back become flowers in the Arena.“ |

## Šta testirati u igri

1. **Home kao novi igrač:** otvorena Country Bloom, Frost kao kompaktni next lock, ostalo zaključano. Lista stane bez skrolanja.
2. **Tap na Frost** → puni poster. Tap na Country Bloom → opet otvorena Bloom (aktivna).
3. **Tap na otvorenu aktivnu karticu** (ili „Open meadow ↗“) → polje sezone. U polju: Seasons · Play · Play Endless kao ranije, korpa gore lijevo. „Seasons“ vraća kolonu.
4. **Play** na biranju sezone → odmah run u sezoni s čipa.
5. **Otključavanje:** skupi 500 coina + 20 Harvest Pumpkin, pa u posteru Unlock → prsten, pa „New“. Header coini odmah padaju.
6. **Iz Campa:** Unlock u Campu → prebaci na Home → sezona već otključana i otvorena s „New“, bez drugog prstena.
7. **Premium:** tap na „Premium seasons“ → lista. Tap na Coral → pregled. „Get …“ → u dev buildu stub kupovina traje ~1 s → kupljena i aktivna. Tap na strelicu „↑“ zatvara listu.
8. **Swipe:** na Home povuci lijevo/desno bilo gdje → tab se mijenja. Gore/dolje → kolona se lista kad je duža od ekrana (npr. otvoren premium).

## Odstupanja od CD dizajna (namjerna)

- **Cvijeće u rosteru** crta igra. Samo Country Bloom ima prave ilustracije; ostale sezone za sada pokazuju isti proceduralni cvijet (isto kao u Campu i Journalu).
- **Prsten otključavanja** crta se jednom i samo se skalira i blijedi, umjesto CD-ove PNG slike iz testa. Izgled je isti, a nema novog asseta.
- **Play** koristi postojeću ikonu umjesto znaka „▶“, koji font nema.
- **Otvorena premium lista** pokazuje „↑“ za zatvaranje (CD je crtao „↓“).
- **Duži tekst u našem fontu:** npr. „Need … Harvest Pumpkin“ ide u dva reda, jer je naš font širi od CD-ovog Nunita. Kartica tada malo naraste, a otvorena kartica se smanji (manji okviri cvijeća) da sve stane bez skrolanja. Kad kolona ionako mora skrolati, otvorena kartica zadržava punu visinu.
- **„New“** se pojavljuje tek poslije prstena, kako je u CD storyboardu (kadar 3).
- **Daily gift je sada samo na biranju sezone.** U polju sezone ga nema, a korpa je zato gore lijevo. To je jedina promjena polja; njegov redizajn čeka poseban brief.

## Šta je obrisano

Browser (overlay „Seasons“) · mrtav `SeasonUnlockSheet` · stari unlock gate i progress (s mrtvim „split“ režimom iz starog Campa) · stari roster panel · brežuljci u uglovima · nevidljivi `PipPortrait`, `Tagline`, `PlayThemeBadge`.

## Testovi

- Novi **`season_home_smoke`** pokriva:
  - raspored (TopRow 130, napredak 420, Play 1032 × 156, padding 24, pozadina);
  - novog igrača, next lock, odbijanje iza next locka, poster;
  - spremno stanje, trenutak otključavanja i „New“;
  - izbor sezone, otvaranje i zatvaranje polja;
  - premium listu, pregled, kupovinu i Coming soon;
  - dolazak iz Campa, sve 4 free, daily gift i tutorial.
- Ažurirani su `season_meadow_smoke` (Play = run, polje s kartice) i `camp_season_link_smoke` (Home otvara poster).
- `season_home_smoke` i `season_meadow_smoke` sada **čuvaju i vraćaju tvoj pravi save**; `season_meadow_smoke` ga je ranije brisao.
- **Cijeli suite: 43/47.** Nema novih padova. Tri se vode kao pad jer ne ispisuju „OK“ (`menu_play_smoke`, `merge_arena_smoke`, `shop_smoke`), a `shop_nav_smoke` je stara poznata greška.
- **Vizuelno:** 10 stanja provjereno screenshotovima u kratkom automatskom pokretanju igre.

Usput nađen i popravljen bug koji bi srušio igru: red „Premium seasons“ se svakim osvježavanjem širio, što je u hubu pravilo beskonačnu petlju i pad. Upisano kao greske-katalog #16.

## Poznata ograničenja i sljedeći koraci

- **Ilustracije cvijeća za 7 sezona** još ne postoje ([[seeds-flowers-cd-brief]]).
- **Sezonske ilustracije** (slot 996 × 340) postoje samo u alternativnom smjeru 1b. Nisu prenesene.
- **Polje sezone** je sljedeći brief (livada, Pip, korpa, Magnet / Loot Boost, Play Endless).
- Paket `design_handoff_home/` je u korijenu repoa, kao i paketi hub/arena/camp.
- **Commit:** kad pregledaš igru, reci „commitaj“.
