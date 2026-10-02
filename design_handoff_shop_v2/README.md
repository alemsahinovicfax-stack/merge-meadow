# Shop v2 — handoff

Brief: `docs/04-experience/design-drafts/shop-v2-cd-brief.md`. Jedan dizajn.

**Ideja:** Shop je tezga na livadi. Tenda s mint/krem prugama (iste boje kao ikona Shop taba u footeru) drži četiri taba, ispod je topli pergament `#FBEDD7`, a roba su bijele kartice s ink rubom i tvrdom sjenom — isti jezik kao Home v3 i Ormar. Zelena `#2E4733` je izbačena.

## Sadržaj

```
design/
  ShopScreen.dc.html      ekran — props: tab, scene, price, coins, starter (+ slot, storeResult, frozen)
  ArenaMergeHint.dc.html  Merge Hint u Areni — props: season, frame; prevuci prst da vidiš praćenje
  Shop Specs.dc.html      sva stanja §9.1, anatomija, boje, živa samoprovjera §9.3
  BuyButton.dc.html       jedno dugme, 8 stanja
  FlowerPortrait.dc.html  portret = UiHomeV3.draw_flower()
  MergeHintMark.dc.html   oznaka (4 kutne zagrade)
  ItemPreview / ArenaField / SeedChip   kopije iz Ormara i Arene v2 (ItemPreview dobio prop paperBg)
  shop_v2_data.js         sezone, cijene, Loot Burst cilj, paleta portreta (djb2 kao Godot String.hash)
  support.js, icons/, ref/   ref/cosmetics.json = game/data/cosmetics/cosmetics.json
godot/
  shop_v2_export.json  ui_shop_v2.gd  shop_tree.txt  cosmetics.json
```

## § Odlučeno

1. **Četiri taba = četiri ScrollContainera.** Neaktivni su `visible = false`, ne brišu se → svaki pamti skrol dok si u Shopu. Izlazak resetuje.
2. **Redoslijed: Seasons · Looks · Boosters · Support.** Seasons fiksno prvi. Looks drugi: najčešća kupovina bez pravog novca i cilj „More in Shop“ iz Ormara; Seasons i Looks su oba „kako livada izgleda“. Boosters treći — male pomoći. Support zadnji — račun i Restore, rijetko se traži.
3. **Ulaz:** footer → uvijek Seasons, skrol 0. Ormar „More in Shop“ (slot X) → Looks, skrol na zaglavlje slota X, zaglavlje bljesne `#FFF6D6` 1,2 s. Tab se mijenja samo tapom; vodoravni swipe ostaje hub pageru.
4. **Tab bar = tenda** (1080 × 172, iznad skrola). 4 taba 249 × 120, bijeli s rubom 3; aktivan = peach klizač s rubom 4 i tvrdom sjenom 6, klizne 0,2 s. Sadržaj počinje na y 196.
5. **Prelaz taba:** stari blijedi 1 → 0, novi 0 → 1 i klizi ±48 → 0 px (smjer po indeksu), 0,2 s cubic-out.
6. **Kraj taba:** Looks → dugme *Wardrobe* (Shop prodaje, Ormar oblači). Support → *Restore purchases* kao podvučen link. Boosters bez ponude → Pip + „All set here“. Seasons → zadnja kartica + 64 px.
7. **Jedno dugme po kartici koja prodaje** — nosi cijenu i kupuje. Valuta po boji i ikoni: coini = zlatno + coin ikona; pravi novac = lavanda + store string, bez ikone.
8. **Coin kupovina u dva tapa na istom dugmetu.** Prvi tap obrne dugme (ink pozadina, zlatna ✓ i cijena); drugi kupuje i oblači; 3 s bez tapa → nazad.
9. **Nema dovoljno coina:** dugme ravno (bez sjene), `#F1EAE0`, cijena `#555C5E`. Tap = drhtaj dugmeta + puls coin chipa u headeru. Bez rečenice.
10. **Kupljeno / nosiš = Ormar:** kartica `#FFF6D6`, EquippedBadge ✓ na pregledu, dugme postane mint tag „Wearing“ / „Owned“. Pip skoči u pregledu; „−200“ odleti iz coin chipa.
11. **Looks se gradi iz `cosmetics.json`:** `slots[]` po `order` (ikona, naslov, `preview`), stavke gdje je `source == "shop"`. Pregled je ItemPreview iz Ormara iste vrste. Nova stavka u JSON-u → nova kartica, bez dizajna.
12. **Seasons kartica 1032 × 364** na trakama sezone (Home v3). Šest portreta: 5 × 148 + ★3 172, pravi crteži `draw_flower()`. Kupljena → peach „▶ Play“ vodi na Home. Ember Fen → crteži 50 %, „Coming soon“, bez cijene i dugmeta.
13. **Merge Hint = jednokratna kupovina.** Kartica s vinjetom Arene (polje + sjemenke + oznaka); kupljen → „Yours“, kartica ostaje.
14. **Loot Burst** daje +5 ★3 cvijeta sezone koja otključava `next_locked_free_id()`; kartica pokazuje taj cvijet, ime sljedeće sezone i traku have / 20 (+5 isprekidano). Kad su sve besplatne otključane — kartica se ne crta.
15. **Starter Pack:** 100 coina · Pip Blossom · 10 × clover, daisy, buttercup, tulip, sunflower — tri pločice, bez Merge Hinta. Chip „6d left“ (zadnji dan u satima). Istekao → siv veo 84 % + katanac + „Expired“, veo guta tap. Ako je Pip Blossom već tvoj, na pločici je ✓.
16. **Store greške** su mali status ispod imena (Cancelled / Didn’t go through / Pending); dugme opet kupuje, nestaje na sljedeći tap. Toast samo za ono što se mijenja van kartice.
17. **Jedan loop:** tri tačke dugmeta koje čeka store. Sve ostalo su jednokratni tweenovi.
18. **Default Seasons (§9.1/1):** u Specs pregledniku (frozen) Starfall čeka store pa je Moonlit prigušen — pravilo jedne IAP kupovine u isto vrijeme. U samostalnom ShopScreenu ništa ne čeka: sva dugmad kupuju, a čekanje se vidi kad ga pokreneš.

## § Šta se briše

- Pozadina `#2E4733`, jedna duga stranica, JumpChip skokovi na sekcije i scroll-spy.
- `PriceTag` kao zaseban element; svaki drugi CTA pored cijene („Get …“, „Buy 1“, „Buy & wear“, „Use one“).
- Tekstovi iz §4: „6 flowers for your Album · same runs, same rewards“, „yours to keep“, „one-time“, „everywhere / run background · wear one“, „Journal page“, „for coins · looks only“, „Need N more / earn in runs“, „You have N“, „+1 to your stock“, „each“, „Bag is full / trade seeds in Camp first“, „optional helpers…“, „for good, on this account“, „once per account“, dugi opis Remove Ads, opisi kozmetike.
- `BoosterCount`, `UseButton` i „Go to Arena“ (Merge Hint više nije potrošan; Loot Burst se daje odmah).
- `SeasonRoster` s tačkama od 96 px.
- Starter Pack sadržaj „+15 coins / +8 seeds / +1 Merge Hint“.
- U Areni: oblačić „Hint: merge two … seeds.“.
- `ui_shop.gd` v1 tokeni koje v2 ne koristi (JUMP_*, SECTION_*, ACCENT_*, COUNT_*, ROSTER_*).

## § Stanja dugmeta

Jedan čvor `BuyButton`, h 120, min 280, radius 60, rub 4 ink; raste sa sadržajem.

| stanje | izgled | tap |
|---|---|---|
| `coins.buy` | `#FFD56B`, coin 60 + cijena 52, sjena 0 8 0 | → `coins.confirm` |
| `coins.confirm` | `#2D3436`, zlatna ✓ + coin + cijena | kupi + obuci |
| `coins.short` | `#F1EAE0`, ravno, coin 55 %, cijena `#555C5E` | drhtaj + puls coin chipa |
| `money.buy` | `#D4A5FF`, store string 52 (44 ako > 7 znakova) | otvori store |
| `money.busy` | `#EAD2FF`, spušteno 8 px, bez sjene, 3 tačke (loop) | — |
| `money.dim` | `#EAD2FF`, rub ink 30 %, cijena `#555C5E` | — |
| `play` | `#FFB88C`, ▶ Play | Home, fokus na sezonu |
| `owned` | `#A8E6CF`, ✓ + Yours / Wearing / Owned / Ads off / Claimed, bez sjene | — |

Pritisak: y +4, sjena 8 → 4, 0,08 s. Promjena stanja: scale 1 → 1,06 → 1, 0,22 s.

## § Merge Hint u Areni

- **Kad:** igrač ima Merge Hint i drži sjemenku.
- **Šta:** najbliža sjemenka istog tipa **i** tiera (centar–centar) dobije `MergeHintMark`. Ostale iste i dalje imaju današnji zlatni puls (`#F2D940`, prsten 12); magnet partner zadržava svoj prsten (`#FFD56B`, 14).
- **Oblik:** četiri kutne zagrade (L), okvir 156, krak 40 — ink traka 18 px `#2D3436`, preko nje svijetla traka 10 px `#DCF5EC`. Puls i magnet su prstenovi, oznaka nije → razlika je u obliku. Bez glowa.
- **Kontrast (pravilo dvostrukog ruba Arene v2):** na svakoj boji polja bar jedna ivica ≥ 3 : 1. Dokaz √((L traka + 0,05)/(L ink + 0,05)) = 3,33. Izmjereno: Country Bloom min 3,77, Moonlit Warren 5,78, svih 8 livada min 3,36.
- **Kretanje:** histereza 24 px. Ulaz scale 1,35 → 1 + alpha, 0,18 s back-out. Prelaz na novu najbližu 0,14 s cubic-out. Izlaz 0,12 s. Nema loopa.
- **Godot:** `UiShopV2.merge_hint_target()` i `UiShopV2.draw_merge_hint()`; čvor u overlayu iznad SeedChipa, ispod držane sjemenke.

## Potrebne izmjene ekonomije (van dizajna)

- `booster_merge_hint`: consumable → non-consumable.
- `booster_loot_burst`: daje 5 × ★3 cvijeta (umjesto +5 sjemenki).
- `starter_pack`: novi sadržaj + prozor 7 dana od `first_launch_unix`.
- Cijene i SKU-ovi su nepromijenjeni.

## § Samoprovjera (§9.3)

Pokrenuto u browseru 2026-10-02 na `Shop Specs.dc.html` (sekcija 8). Provjera prolazi kroz svih 24 stanja u pregledniku i mjeri DOM.

1. **da** — Četiri taba, svaki svoj ekran sa svojim skrolom; footer otvara Seasons. *4 ShopTab · 4 TabPage, svaki overflow-y auto · aktivan pri ulazu: seasons.*
2. **da** — Svaka kartica koja prodaje ima tačno jedno dugme koje nosi cijenu. *42 prodajne kartice kroz 24 stanja, 0 odstupanja (dok čeka store isto dugme nosi tačke).*
3. **da** — Nema izbačenog teksta iz §4. *24 obrasca × 24 stanja, 0 pogodaka.*
4. **da** — Portreti sezona su pravi crteži, svih 6, veći od 96 px. *24 SeasonCard, svaka 6 FlowerPortrait s crtežom; najmanji disk 148 px.*
5. **da** — Looks iz `cosmetics.json`. *Izvor ref/cosmetics.json, identičan game/data/cosmetics/cosmetics.json; slotovi pip_skin, meadow_bg, journal_frame.*
6. **da** — Starter Pack istekao: veo + katanac, nije dodirljiv; sadržaj 100 coina + Pip Blossom + 5 × 10, bez Merge Hinta. *Veo prekriva dugme i prima tap, dugme data-tappable=no; sadržaj tačan.*
7. **da** — Merge Hint oznaka se razlikuje oblikom, ima taman rub, ≥ 3 : 1 na obje livade. *16 šipki = 4 zagrade; Country Bloom 3,77, Moonlit Warren 5,78.*
8. **da** — Dug store string stane; tekst ≥ 34 (ime i cijena ≥ 44), dodir ≥ 120, kontrast ≥ 4,5 : 1. *0 rezanih cijena, 5 dugih na 44 px; 0 tekstova < 34; najmanje ime 52; dugme i tab min 120; najmanji kontrast 4,92 : 1.*
9. **da** — Nema blura, glowa ni gradijenta; najviše jedan loop; nema `#2E4733`. *0 / 0 / 0 mekih sjena / 0; beskonačne animacije samo na jednom elementu (tri tačke dugmeta koje čeka store).*

Napomena: Specs stranica je teška (24 živa stanja + Arena); prvo učitavanje i samoprovjera traju ~60–90 s.
