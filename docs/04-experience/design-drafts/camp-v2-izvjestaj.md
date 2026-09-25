---
type: iskustvo
status: aktivan
milestone: M8
tags: [dizajn, ui, camp, claude-design, izvjestaj]
povezano:
  - camp-v2-cd-brief
  - camp-cd-brief
  - shop-izvjestaj
  - changelog
ai_sažetak: "Izvještaj o prenosu paketa design_handoff_camp_v2 u Godot 2026-09-24: manje teksta, kartica sezone 276 px, sekcija prikovana uz nju, veći art u karticama, manja dugmad i držanje koje se vidi."
---

# Camp pass 2: izvještaj o prenosu

> Roditelj: [[04-experience/_index|04-experience]] · brief: [[camp-v2-cd-brief]] (§ Implementacija) · datum: 2026-09-24

## Ukratko

Camp je prestao da objašnjava. Sve što si tražio je unutra, plus nekoliko stvari koje su same pale kad je tekst otišao.

- **Rupe u sredini više nema.** Sekcija sa sjemenkama stoji tačno 20 px ispod kartice sezone i uvijek je iste visine (1253 px, odnosno 1549 kad nema kartice). Prije je razmak rastao s 215 na 375 px kad bi sadrzaja bilo manje.
- **Kartica sezone je pala s 422 na 276 px.** Nema „Next free season" ni „Details ↗", a Unlock je sada pilula 300 × 120 desno od imena — jedna riječ, s lokotom dok fali.
- **Red tabova je samo Seeds | Flowers**, bez „Merge" prečice i bez podnaslova. Ime lijevo, broj tipova uz desni rub.
- **Crtež sjemenke i cvijeta je porastao za ~45 %** (okvir 104 → 128, crtež 66 → 96), a kartica je ostala ista: 489 × 176.
- **Trade traka je tiša:** nema „★☆☆ · 1 coin each" ni „hold 10 / s", dugme je 300 × 120 s jednom riječju.

## Šta se vidi na ekranu

| Dio | Izgled |
|---|---|
| **Kartica sezone** | ime sezone i Unlock u istom redu; ispod dvije trake (coini i cvijeće) bez natpisa „Coins" i „{cvijet} ★★★". Tap bilo gdje i dalje vodi na Home. |
| **Unlock** | „Unlock" + lokot dok fali (blijeda pilula), puno zlatna kad može, „Unlocked" u trenutku otključavanja. |
| **Tabovi** | 120 px visoki, aktivan peach, neaktivan puna krem boja (bez prozirne podloge). |
| **Kartica predmeta** | veliki art u okviru 128 px, ime 38, ★★☆, pa pilula s brojem komada i zlatna pilula s cijenom — bez riječi „each". |
| **Rezervisano cvijeće** | badge „Kept · 12 / 20" stoji u redu gdje inače stoje zvjezdice, pa je kartica i dalje 176 px (bila 244). Na granici badge postaje amber, tekst se ne mijenja. |
| **Trade traka** | crtež, ime predmeta i dugme. Prazan izbor = prazan obris i dugme bez teksta o razlogu. |
| **Držanje** | dugme se puni onoliko koliko si prodao od gomile; na svaki tik novčić 44 px odleti do coin chipa u headeru i chip dobije prsten. Jedan tap kratko napuni i isprazni traku — tako igrač sam otkrije da se može držati. |
| **Prazno stanje** | ikona, naslov i dugme („Play a run ↗" / „Merge in Arena ↗"), bez rečenice objašnjenja. |

## Šta testirati u igri

1. Otvori Camp s jednom vrstom sjemena, pa s osam — sekcija se ne pomjera ni za piksel.
2. Drži Trade: traka se puni, novčići lete u header, „+N" raste; pusti — coini su na brojaču.
3. Tapni Trade jednom: traka kratko skoči pa se vrati (to je nagovještaj da se može držati).
4. Idi na Flowers i izaberi cvijet koji sljedeća sezona traži: badge „Kept · N / M", strip iznad reda i ružičasto dugme s lokotom kad bi prodaja dirala rezervisano.
5. Spusti ga na granicu: držanje stane, dugme pređe u „Sell 1" s ikonom, badge postane amber.
6. Isprazni torbu: prazno stanje bez rečenice, Trade traka ostaje na dnu sekcije.
7. Otključaj sezonu kad skupiš 500 + 20: dugme kaže „Unlocked", burst, pa Home.

## Odstupanja od paketa (namjerna)

- **Duga imena se i dalje skraćuju** u Seeds tabu („Harvest Pumpk…"). Paket računa s Nunitom; naš default font je širi na 38 px. U Flowers tabu ime staje cijelo.
- **`FONT_BTN_SUB` je ostao** u `UiCamp` jer `CampButton` dijeli Shop, gdje podnaslov i dalje postoji.
- **Prsten oko coin chipa prati stvarni čvor** (+6 px) umjesto fiksnog pravougaonika iz paketa — safe-area pomjera header.
- **„+N" pilula je ostala na staroj kotvi** (−16, −20) umjesto (−16, −42).
- **Auto prelaz na sljedeći tip** javlja novo ime u traci (fade 0,2 s); mint pločica „empty — switched here" je obrisana.

## Testovi

- Novi **`camp_section_fixed_smoke`**: visina sekcije i razmak od 20 px za 0, 1, 8 i 14 tipova, sa stripom upozorenja i bez kartice sezone.
- Ažurirani **`camp_layout_smoke`** (kartica 276, sekcija 1253/1549, tab 489, dugme 300 × 120, obrisani čvorovi), **`camp_season_link_smoke`** (jedna riječ, bez captiona), **`camp_trade_select_smoke`**, **`camp_hold_floor_smoke`** („Sell 1", badge ostaje „Kept · 20 / 20", chip 176), **`camp_trade_hold_smoke`**, **`camp_crystal_select_smoke`** i zajednički **`camp_smoke_util`**.
- Suite **52/52**, GUT **33/33**.

## Poznata ograničenja i sljedeći koraci

- Paket `design_handoff_camp_v2/` je u korijenu repoa, uz ostale CD pakete.
- `icon_merge_arrow.svg` i `icon_reserved.svg` više nemaju korisnika u redu tabova — `icon_reserved` i dalje stoji na badgeu rezervisanog cvijeta, `icon_merge_arrow` je ostao neiskorišten.
- Art cvijeća je i dalje proceduralni crtež; pravi art čeka [[seeds-flowers-cd-brief]].
