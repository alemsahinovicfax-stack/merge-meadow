---
type: iskustvo
status: aktivan
milestone: M8
tags: [dizajn, ui, shop, monetizacija, claude-design, izvjestaj]
povezano:
  - shop-cd-brief
  - journal-izvjestaj
  - home-season-select-izvjestaj
  - changelog
ai_sažetak: "Izvještaj o prenosu CD paketa design_handoff_shop u Godot 2026-09-24: šta se promijenilo na Shopu, šta testirati, odstupanja, testovi i šta slijedi."
---

# Shop: izvještaj o prenosu

> Roditelj: [[04-experience/_index|04-experience]] · brief: [[shop-cd-brief]] (§ Implementacija) · datum: 2026-09-24 · **ništa nije commitano**

## Ukratko

Shop je bio posljednja stranica huba po starom: svijetloplava pozadina, lavanda paneli i Godot default dugmad. Sada izgleda kao ostatak igre i, što je važnije, kaže šta kupuješ.

- **Četiri sekcije u jednom skrolu:** Looks (coini) → Seasons → Boosters → Support. Gore stoji red od 4 chipa koji skače na sekciju i sam se pali dok skrolaš.
- **Kozmetika se vidi prije kupovine.** Svaka kartica ima pregled podijeljen na „Now“ i „With it“: Pip u svojoj paleti, staza u tintu, stranica Albuma sa zlatnim ramom.
- **Kupovina za coine ide u dva tapa:** „Buy & wear“ → „Spend 150 coins? You’ll have 30 left.“ → „Buy for 150“. Kupljeno se odmah nosi.
- **Poruke stoje na predmetu**, a ne u jednoj liniji na dnu ekrana.
- **Boja govori čime plaćaš:** zlatno dugme = coini, lavanda = pravi novac.

## Šta se vidi na ekranu

| Dio | Izgled |
|---|---|
| **Looks** | tri krem kartice po slotu (Pip skin · Meadow tint · Album frame). Red: pregled 440 × 284, ime, opis, pa cijena i dugme. |
| **Nema dovoljno coina** | dugme je mutno i piše „Need 240 more · earn in runs“. Nema polja za kupovinu coina. |
| **Kupljeno** | „Wearing“ značka i rečenica šta to mijenja („Pip wears this in runs.“). Kupovina zasvijetli pregled i pošalje −N ispod coin brojača u headeru. |
| **Seasons** | kartica u boji sezone, roster od 6 mjesta, tagline i sitni tekst „6 flowers for your Album · same runs, same rewards“. Kupljena sezona nudi „Play it on Home ↗“, Ember Fen ima „COMING SOON“ i nema cijenu. |
| **Boosters** | disk s ikonom, „You have N“, pa „Use one“ i cijena. Aktivan Merge Hint mijenja dugme u „Go to Arena ↗“, a pun bag blokira Loot Burst („Bag is full · trade seeds in Camp first“). |
| **Support** | Remove Ads i Starter Pack (sadržaj kao tri chipa: +15 coins · +8 seeds · +1 Merge Hint), pa Restore i fair note na dnu. |
| **Kupovina pravim novcem** | aktivno dugme pulsira „Waiting for store…“, ostala padnu na 50 % uz „one purchase at a time“. Otkazano u storeu = roze poruka na kartici, pending = žuta. |

## Šta testirati u igri

1. Otvori Shop (prvi tab) i tapni chipove Seasons i Support — lista skače, chip se pali sam kad skrolaš.
2. Tapni „Buy & wear“ na nečemu što možeš platiti: pojavi se potvrda. „Back“ je poništava, druga kupovina je preuzima.
3. Potvrdi kupovinu: coini padnu, predmet se nosi, a pregled ostane u jednoj slici.
4. Provjeri predmet koji ne možeš platiti: dugme je mutno i kaže koliko fali.
5. Kupi sezonu (u dev buildu stub traje ~1 s): kartica dobije „YOURS“ i dugme „Play it on Home ↗“, koje te vodi na Home s tom sezonom u fokusu.
6. Boosteri: „Use one“ na Merge Hintu pa ponovo pogledaj karticu — nudi Arenu umjesto drugog trošenja.
7. Restore se u dev buildu (stub store) ne vidi — to je namjerno.

## Odstupanja od CD paketa (namjerna)

- **„−N“ iznad coin brojača crta hub**, jer je Shop stranica klipovana i ne može crtati preko headera. Polazi ispod coin chipa umjesto s fiksne tačke iz paketa.
- **Kartica kozmetike naraste na ~290 px** (dizajn kaže 284) kad se opis prelomi u dva reda — naš font je širi od Nunita.
- **Roster sezone su tačke u tamnom wellu**, dok ne bude arta za svih 42 cvijeta. Tako je i u paketu.
- **Pip skin u runu** je i dalje proceduralni Pip, ne slojeviti sprite.

## Popravljeno usput

Pri prenosu je chip za sekciju skakao prekratko poslije prvog skoka (`ScrollContainer` pomjera svoje dijete, pa je cilj gubio već preskrolanu visinu) — popravljeno i upisano u katalog grešaka kao #20.

`shop_nav_smoke` je godinama padao i **vješao Godot proces** u suiteu: statička referenca na `GameState` u `--script` testu. Sada koristi literal putanju i prolazi.

## Testovi

- Novi **`shop_booster_guard_smoke`**: Use se ne vidi bez zalihe, aktivan Merge Hint vodi u Arenu, pun bag blokira Loot Burst.
- Prepisani **`shop_open_smoke`** (4 sekcije, chipovi, 5 kozmetika, 4 sezone s rosterom, Ember Fen bez cijene, Restore skriven u stubu) i **`shop_cosmetic_buy_smoke`** (dva tapa, prvi ne troši coine).
- **`meta_hub_flow_smoke`** prati nove kartice; `season_iap_smoke`, `meta_hub_smoke` i `shop_smoke` prolaze bez izmjena.

## Poznata ograničenja i sljedeći koraci

- **Dijamanti** i dalje nemaju gdje da se potroše; CD je to ostavio kao ideju van zadatka.
- **Art cvijeća** u rosteru sezone i slojeviti Pip skin čekaju [[seeds-flowers-cd-brief]].
- Paket `design_handoff_shop/` je u korijenu repoa, uz ostale CD pakete.
- Ovim je **cijeli hub redizajniran** (chrome, Arena, Camp, Home, polje sezone, Journal, Run, Shop).
