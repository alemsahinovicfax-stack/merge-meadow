---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, playtest, telefon, bugfix, plan]
povezano:
  - plan-telefon-playtest-1111
  - telefon-playtest-1111-izvjestaj
  - CHECKPOINT
ai_sažetak: "FIX-TEL-2 plan (2026-11-12): drugi krug prijava s telefona (build 11) — run (kontakt glavom, vjetar ×5, odbrojavanje poslije pauze, Endless Pace 10 s), Home (ormar: katanac, izrezani skinovi, glatki sheetovi, Basket desno), Camp trejd bez štekanja, Journal učitavanje po sezoni, Arena cap 200 sjemenki po rundi. Plan je unaprijed odobren; izvršava se po fazama A–F."
---

# FIX-TEL-2 — drugi krug poslije playtesta na telefonu (build 11)

> Roditelj: [[06-production/_index|06-production]] · Prethodni krug: [[plan-telefon-playtest-1111|plan-telefon-playtest-1111]] · 2026-11-12
> **Status: URAĐENO isti dan** — izvještaj: [[telefon-playtest-1112-izvjestaj|telefon-playtest-1112-izvjestaj]]. Plan je bio odobren unaprijed („planove unaprijed prihvatam") — izvršava se odmah, faza po faza.

## Prijave i uzroci (nađeno u kodu)

| # | Prijava | Uzrok u kodu | Faza |
|---|---------|--------------|------|
| 1 | Run: glava Pipa pređe preko sjemena / coina / prepreke prije nego što se „pikne" | Kolizija Pipa je kvadrat 56 × 56 oko sredine tijela; crtež je 150 px — glava viri ~45 px ispred kolizije | A |
| 2 | Vjetar se skoro ne osjeti | Trzaj svijeta je 10 px, isti na svakom levelu, i vrati se nazad | A |
| 3 | „Keep running" odmah nastavlja igru | Pauza se zatvori i stanje odmah pređe u trčanje | A |
| 4 | Endless: Pace svakih 20 s | `ENDLESS_TIER_SEC = 20` | A |
| 5 | Ormar: katanac proziran kao i skin | Katanac se crta ISPOD Pipa (rig ima viši z), a Pip je na 45 % | B |
| 6 | Ormar: skinovima odsječene uši / glava | Okvir sličice je 150 px visok, Pip se skalira po tijelu, ne po ušima / kapi | B |
| 7 | Ormar, Boosts i Basket se otvaraju s trzajem | Sadržaj se gradi u istom frejmu u kojem animacija kreće, pa prvi frejmovi propadnu | B |
| 8 | Basket dugme desno ispod Boostova | Sada je lijevo ispod poklona (24, 220) | B |
| 9 | Camp: trejd šteka dok novčić leti | Svaki trejd: novi stilovi dugmeta, puno osvježavanje kartice sezone i bedževa taba, tween + prsten po novčiću | C |
| 10 | Journal: sezone se učitavaju s trzajem | Svaki red mijenja visinu liste (cijela lista se ponovo raspoređuje); nema oznake da se sezona učitava | D |
| 11 | Arena: najviše 200 sjemenki po merge rundi | Nema granice — runda traje dok ima sjemenki u vreći | E |

## Faze

### Faza A — Run
1. **Kontakt glavom:** izmjeriti stvarne granice crteža Pipa (pogled odozgo), pa koliziju produžiti naprijed do vrha glave (uši ne broje — fer prema igraču). Vrijedi za pickupe, grm i prepreke. Pickup nestaje na prvom dodiru, pa glava više ne prelazi preko njega.
2. **Vjetar ×5 i po levelu:** trzaj 10 px → 50 px na osnovnoj brzini, množi se s trenutnom brzinom staze (viši level / viši Pace = jači). Umjesto „naprijed pa nazad" postaje kratak nalet koji stazu stvarno gurne prema Pipu (nema povratka, pa nema ni lažnog sudara). Jače linije i naginjanje Pipa.
3. **Odbrojavanje poslije pauze:** „Keep running" (i Android back) zatvori meni, na sredini 3 → 2 → 1, tek onda igra krene. Pauza usred odbrojavanja ga prekida.
4. **Endless Pace 10 s:** stepenica svakih 10 s. Pace N je iste težine kao do sada (težina stiže duplo brže) — jedna konstanta ako se pokaže preteško.

### Faza B — Home
5. **Katanac:** pun (neproziran) bedž u uglu sličice, iznad Pipa.
6. **Skinovi u okviru:** Pip u sličici se skalira prema stvarnoj visini skina (uši, kapa, kaciga), s rezervom.
7. **Glatki sheetovi (Ormar, Boosts, Basket):** sadržaj se izgradi, pa animacija krene frejm kasnije; Ormar ne gradi mrežu ponovo ako se ništa nije promijenilo.
8. **Basket desno ispod Boostova;** oblačić tutoriala i zabranjene zone polja prate.

### Faza C — Camp trejd
9. Mjerenje (`camp_trade_bench`), pa: letači novčića kao u runu (bazen `Sprite2D`, jedan `_process`, bez tweenova i `Control` čvorova), trejd dira samo brojeve (stilovi i kartica sezone samo kad se stanje promijeni).

### Faza D — Journal
10. Sezona odmah zauzme punu visinu; dok se redovi grade, na njihovom mjestu su „kosturi" redova s oznakom **Loading…**; redovi se pojavljuju jedan po jedan s blagim fade-om. Lista se više ne raspoređuje ponovo za svaki red.

### Faza E — Arena
11. **Cap 200 po rundi:** runda dolijeva najviše 200 sjemenki; ostatak ostaje u vreći za sljedeću. Pilula iznad vreće: ispod praga `N / 50`, od praga naviše `N / 200` (mint, oznaka, blagi puls = „možeš igrati"); tokom runde pokazuje koliko je od 200 potrošeno.

### Faza F — Provjera
12. Novi / dopunjeni smoke testovi po fazi, `smoke-all`, GUT, slike na 20:9, pa `release-check.ps1` (novi AAB, version code 12). Izvještaj: `telefon-playtest-1112-izvjestaj.md`.

## Šta svjesno NE ulazi

- CD redizajn Journala (harmonika) — prvo vidjeti da li kosturi + stabilna visina rješavaju trzaj.
- Tableti: ukrasne strane; Home kartica na visokom ekranu (ostaju otvoreni iz prvog kruga).

## Povezano

- [[plan-telefon-playtest-1111|plan-telefon-playtest-1111]]
- [[CHECKPOINT|CHECKPOINT]]
