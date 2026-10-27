---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, monetizacija, iap, coini, izvjestaj]
povezano:
  - CHECKPOINT
  - scope-i-granice
  - play-console-sutra
  - ekonomija-brojevi
  - coin-ponude-simulacija
ai_sažetak: "v1 samo s reklamama (2026-10-26/27): IAP_ENABLED false, stvari koje su se plaćale pravim novcem kupuju se coinima kroz isti grant (Merge Hint 1500, Loot Burst 1000, teme 3000/3500, Sir Pip 3000), Remove Ads / Starter Pack sakriveni, Billing plugin isključen; šta je testirano, a šta nije."
---

# v1 samo s reklamama — IAP stvari za coine (izvještaj)

> Roditelj: [[_index|06-production]] · [[CHECKPOINT|CHECKPOINT]] (traka ADS-ONLY) · Cijene: [[../02-design/ekonomija-brojevi#Coin cijene bez kupovina (v1, 2026-10-26)|ekonomija-brojevi]] · Simulacija: [[../02-design/coin-ponude-simulacija|coin-ponude-simulacija]] · Play forme: [[play-console-sutra|play-console-sutra]] § 0, § 4, § 5

## Ukratko

BiH nije Google Play merchant zemlja, pa v1 izlazi **samo s reklamama**. `MonetizationConfig.IAP_ENABLED = false`. Sve što se prije prodavalo pravim novcem sada se kupuje **coinima iz igre**, osim Remove Ads i Starter Packa. Kupovina ide kroz **isti grant** kao Play kupovina (ista polja u saveu, isto otključavanje i isti signali), pa Shop, Home i Camp reaguju kao na IAP. Kad se merchant riješi: uključiš plugin, vratiš `IAP_ENABLED := true` i napraviš proizvode u Play Consoleu. Ono što je igrač kupio coinima ostaje njegovo.

> Napomena: kod je većim dijelom ušao u commit `bd3d677` (napravila ga je i pushala druga sesija 2026-10-27, zajedno s RET-01 i popravkom dvostrukog klika). Moj zaseban commit donosi konačne cijene, simulaciju i dokumentaciju.

## Šta je urađeno

| Gdje | Šta |
|------|-----|
| `monetization_config.gd` | `IAP_ENABLED := false`; polje `coin_price` u `IAP_PRODUCTS` (0 = ne prodaje se za coine); `coin_price()`, `sells_for_coins()`, `shows_paid_offer(owned, sku)` |
| `iap_manager.gd` | `buy_with_coins(sku)`: prvo sve provjere (ponuda, već tvoje, Loot Burst ima cilj), pa `GameState._try_spend_coins`, pa isti `_grant_product` (snima), pa `purchase_completed`. Bez dovoljno coina: `need_coins`, ništa se ne daje. Ako grant ipak ne uspije, coini se vraćaju. `get_coin_price`, `is_coin_offer` (Ember nije ponuda dok je test-zaključan). `get_price_label` bez IAP-a vraća "" (nikad „€") |
| Shop | Tabovi **Seasons · Looks · Boosters**. Support (Remove Ads, Starter Pack, Restore) postoji samo s IAP-om. Teme, Merge Hint, Loot Burst i Sir Pip imaju isto dugme kao kozmetika: `coins.buy` → `✓` potvrda (3 s) → kupljeno. Bez dovoljno coina: drhtaj, puls coin čipa i pilula **„Need N more coins"** (N = koliko fali); istu pilulu sad ima i Looks. Pilula nestaje kad coina ima dovoljno |
| Home | Tab **Premium** nudi teme za coine: zlatna pilula 🪙 + cijena (iste mjere kao coin dio dugmeta Unlock), blijeda kad fali; prvi tap = tamno „✓ 🪙 cijena", drugi kupuje → „Yours". Bez coina: toast koliko fali |
| Camp | Kad su sve besplatne sezone otključane, kartica nudi sljedeću temu za coine (🪙 + cijena, dva tapa, isti burst i skok na Home). Bez coina: pilula „Need N more coins"; „Purchase cancelled" se u coin režimu nikad ne pojavi |
| Ormar | Sir Pip se vraća (pod velom, oznaka „Premium", tap → Shop · Looks na njegovu karticu s cijenom). Ormar po dizajnu nikad ne pokazuje cijene |
| Settings | Bez izmjena — sekcija Purchases (Restore, Remove Ads) se ne gradi bez IAP-a |
| Zvuk | Kupovina za coine svira `coins_spend` (kao Looks), ne `purchase_ok` |
| Build | Billing plugin isključen u `project.godot` → AAB nema `.aar` ni dozvolu `com.android.vending.BILLING` (inače Play obično na listingu pokaže „In-app purchases") |

**Home tab Premium — zašto je prikazan, a ne sakriven.** Teme se prodaju na ista tri mjesta kao s IAP-om (Shop · Seasons, Home · Premium, Camp poslije besplatnih sezona), pa vrijedi jedno pravilo — mijenja se samo valuta. Besplatne sezone na Homeu već imaju zlatno dugme „Unlock | 🪙 N", pa zlatna pilula „🪙 3000" izgleda kao isti obrazac. Da je tab sakriven, pojavio bi se tek kad igrač kupi prvu temu u Shopu ili Campu, a to je nedosljedno.

## Konačne cijene i zašto

| Stvar | Coini | Zašto (simulacija, medijan od 10 putovanja, 25 min igre = 1 dan) |
|-------|-------|------------------------------------------------------------------|
| Merge Hint | **1500** | Ako mu je to prvi cilj, igrač ga može kupiti za 2,1 (casual), 1,5 (average) ili 1,2 (skilled) dana — cilj je bio „par dana" ✓. Kupljen odmah odgodi besplatne sezone za 3–8 % (casual), 11–20 % (average) ili 17–32 % (skilled), ali to je izbor igrača |
| Loot Burst | **1000** (prijedlog je bio 500) | Pri 500 C casual igraču coini za Frost Orchard stignu prije zadnjih ★3, pa jedan Burst zatvori manjak i sezona se otvori **37 % ranije** (8,3 → 5,3 dana). Pri 750 C to je još 27 %. Od **1000 C** ubrzanje je **0 %** za sva tri profila. Kupovanje Bursta „čim fali ★3" nikad ne ubrza, nego usporava za 23–115 % jer troši coine potrebne za sezonu. 200 C po ★3 je i dalje 10 × više od prodajne cijene ★3 (20 C) |
| Moonlit Warren · Starfall Glade · Sir Pip | **3000** | Igrač koji štedi samo za njih ima ih za 5,3 / 2,9 / 2,2 dana. U normalnoj igri (prvo besplatne sezone, nadogradnje i izgledi) stižu tek poslije svih besplatnih sezona: average oko **37.–42. dana**, skilled 28.–33., a casual 60+ dana (pola casual putovanja ne stigne do Sir Pipa za 2500 runova) — dakle dugoročni cilj ✓ |
| Coral Tide Garden · Ember Fen | **3500** | Isti omjer kao € cijene (€3,49 naspram €2,99). Ember ima cijenu, ali se ne nudi dok sezona nije u igri |
| Remove Ads · Starter Pack | — | Ne nude se: reklame su jedina zarada, a paket daje coine i ima 7-dnevni tajmer (Pillar 2) |

Teme imaju svoj Level Path (2200 C + 22 ★3 + Endless). Tema kupljena coinima zato igranjem vrati dio cijene — zbog toga nisu jeftinije od najskupljeg izgleda (2500). Granice u `economy_balance_smoke` (Merge Hint jeftiniji od prve sezone, teme i Sir Pip ≥ najskuplji izgled, Loot Burst ≥ 200 C po ★3) čuvaju da se ovo ne pokvari kad se cijene mijenjaju.

**Pillar 2:** nema popusta, tajmera, „limited" ponuda ni paketa coina — coini se samo zarađuju igranjem. Ostale cijene, balans runa, reklame i AdMob kod nisu dirani.

## Testovi i provjere

- **GUT 149/149**. Novi `test_coin_offers` (12 testova): tabela cijena; dovoljno coina → isto stanje kao Play grant i tačno umanjen wallet; premalo coina → ništa; trajna stvar se ne naplaćuje dvaput; Loot Burst 2× s ciljem (+10 ★3, računa se kao uzgojeno) i bez cilja (odbijen, coini ostaju; rezerva granta daje 5 sjemenki); Remove Ads / Starter Pack nisu ponude; Ember skriven; s IAP-om coin kupovina odbijena; prebacivanje on/off s lažnim Play klijentom (restore prazan i s drugim proizvodom) **ne oduzima** coin stvari, a `purchase()` kaže `already_owned`.
- **Smoke:** novi `coin_offers_smoke` (Shop, Home i Camp: dva tapa, premalo coina, Loot Burst toast, Sir Pip nošen) i prepisani `iap_off_smoke` (tabovi, ponude, Settings bez Purchases, Ormar, Camp, Billing se ne spaja + **skener teksta**: nigdje „€", „$", „Restore purchases", „Purchase cancelled" ni „billing"). Šest smokeova koji testiraju Play tok (`camp_paid_card`, `camp_season_link`, `premium_pip`, `season_iap`, `shop_booster_guard`, `shop_open`) rade s `iap_override = 1`, jer taj tok mora raditi kad se kupovine vrate. `season_home` i `settings_screen` prate režim.
- **Pun smoke run: 82/82** (`scripts/smoke-all.ps1`, svaki radnik ima svoj APPDATA). `season_sync_smoke` je prvo pao: kupovinu teme na Homeu i u Shopu je radio kroz stub Play. Sad prati režim (u v1 dva tapa za coine), pa prolazi. Bazni run prije izmjena: 75/81, s vremenski osjetljivim padovima pod opterećenjem.
- **Pravi save:** svi moji testovi i simulacije koristili su kopiju APPDATA-e. Save se ipak promijenio u 11:58 jer je neko igrao u GUI-ju: kupljen je Starfall Glade za 3000 coina (3437 → 437) i zabilježena je sesija u ActivityLogu. To nije došlo od testova.
- **Probni AAB:** `scripts/android-export.ps1 -Preset Aab` → 68,2 MB, potpisan upload ključem. U merged manifestu i u `base/manifest` nema `BILLING`. Još uvijek se koriste test AdMob ID-evi, pa ovo **nije** AAB za Play.
- Sesija za popravku dvostrukog klika je u release APK-u na emulatoru već prošla coin kupovinu sezone u dva tapa i „Need … more coins" (changelog 2026-10-26).

## Šta nije testirano

- Pravi telefon i Play Store. Bez kupovina Play nema šta provjeriti, ali listing (da nema oznake „In-app purchases") vidi se tek poslije uploada.
- Ručni pregled izgleda: zlatna / blijeda / tamna coin pilula na Homeu, tamno „✓ N" i pilula u Campu, pilula u Shopu. Za Camp coin karticu: Settings → Developer → *Unlock all seasons* i *+1000 coins*.
- Model igrača u simulaciji je pretpostavka (kalibracija iz `balance_log.csv` tek s playtestom).
- Godot editor kod nekoga ko otvori projekt s uključenim pluginom: plugin je u `project.godot` isključen, pa ga treba ponovo uključiti tek kad se IAP vraća.

## Otvoreno / sljedeće

- Feature graphic i ostale stavke iz [[launch-prep-plan|launch-prep-plan]] § Šta radim ja ostaju tvoje.
- Kad stignu AdMob ID-evi → konačni AAB za Play.
- U `store-listing-en.md` opis još spominje „100 campaign levels" i Endless „Easy, Normal & Hard" — to više nije tačno (20 levela po sezoni, Endless rampa). Nije vezano za kupovine, pa nije mijenjano.
- `test/unit/*.gd` ulazi u Android paket (export filter isključuje samo GUT addon) — sitnica za čišćenje.
