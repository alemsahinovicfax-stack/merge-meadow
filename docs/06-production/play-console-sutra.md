---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, launch, play-console, data-safety, iarc]
povezano:
  - launch-prep-plan
  - CHECKPOINT
  - play-internal-test
  - privacy-policy-draft
  - iap-billing-setup
ai_sažetak: "Gotovi odgovori za Play Console (Data safety, IARC, ciljna publika, closed test + poziv testerima, app-ads.txt) — korisnik samo prepisuje. v1 izlazi samo s reklamama (odluka 2026-10-26: BiH nije merchant zemlja; IAP stvari za coine, Billing plugin isključen); IAP proizvodi i payments profile tek kad se vrati merchant."
---

# Play Console — odgovori za prepisati

> Roditelj: [[06-production/_index|06-production]] · Plan: [[launch-prep-plan|launch-prep-plan]] · Napisano 2026-10-23 prema onome što igra **stvarno radi** (provjereno u kodu, ne pretpostavljeno); 2026-10-26 prebačeno na v1 bez kupovina (§ 0, § 4, § 5).

## 0. Prvo pročitaj — BiH i prodaja

**Bosna i Hercegovina nije podržana zemlja za Google Play merchant** ([lista zemalja](https://support.google.com/googleplay/android-developer/answer/9306917): BiH ima ✔ za developer nalog, ✘ za merchant). To znači:

| Šta | Iz BiH |
|-----|--------|
| Developer nalog (25 USD), objava besplatne igre | ✅ radi |
| AdMob reklame i isplata zarade od reklama | ✅ poseban program, ne treba Play merchant (provjeri da AdMob isplaćuje na BiH račun) |
| In-app kupovine (Remove Ads, sezone, Sir Pip…) | ❌ ne može bez payments profila u podržanoj zemlji |

**Odluka (2026-10-26): v1 izlazi samo s reklamama.** U kodu je `const IAP_ENABLED := false` (`game/scripts/monetization/monetization_config.gd`):
- Stvari koje su se prodavale pravim novcem kupuju se **coinima iz igre** (isti grant kao Play): teme Moonlit / Coral / Starfall, Sir Pip, Merge Hint i Loot Burst — Shop · Seasons / Looks / Boosters, Home · Premium, Camp poslije besplatnih sezona. Cijene: [[../02-design/ekonomija-brojevi#Coin cijene bez kupovina (v1, 2026-10-26)|ekonomija-brojevi]].
- **Remove Ads** i **Starter Pack** se ne nude (reklame su jedina zarada; paket daje coine i ima tajmer), nema taba Support ni Settings → Purchases / Restore.
- **Billing plugin je isključen** (Project Settings → Plugins → GodotGooglePlayBilling), pa AAB nema dozvolu `com.android.vending.BILLING` — inače Play obično na listingu pokaže „In-app purchases" iako proizvoda nema. Billing se ne spaja.
- U Play Consoleu **ne pravi** IAP proizvode (§ 6) ni payments profile (§ 9); Data safety i IARC odgovaraj po varijanti bez kupovina (§ 4, § 5).

**Kad se jednom riješi merchant** (firma ili prebivalište u podržanoj zemlji — npr. Hrvatska, Srbija, Sjeverna Makedonija; payments profil na pravno lice / osobu iz te zemlje): uključi plugin, `IAP_ENABLED := true`, napravi proizvode (§ 6), promijeni odgovore u § 4 i § 5 na varijantu s kupovinama, novi AAB. Što je igrač kupio coinima ostaje njegovo (Play restore ništa ne oduzima, prikazuje se kao Owned).

❌ **Tuđi nalog / tuđi payments profil** — ne. Google to tretira kao lažno predstavljanje i gasi nalog.

---

## 1. Postavljanje aplikacije

| Polje | Vrijednost |
|-------|-----------|
| Ime aplikacije | Merge Meadow |
| Zadani jezik | English (United States) |
| Aplikacija ili igra | Igra |
| Besplatna ili plaćena | Besplatna |
| Package name (iz AAB-a) | `com.mergemeadow.game` |
| Kategorija | Casual (ili Puzzle) |
| Kontakt email | mergemeadow.support@gmail.com |
| Web stranica (Developer website) | vidi § 8 app-ads.txt — mora biti domena na kojoj je `app-ads.txt` |
| Politika privatnosti | `https://alemsahinovicfax-stack.github.io/merge-meadow/` |
| Play App Signing | **Uključeno** (Google drži ključ aplikacije; ti uploaduješ s upload ključem iz `game/export_credentials/`) |

Store tekst i 8 screenshotova: [[store-listing-en|store-listing-en]], `marketing/store/screenshots/`. Store ikona 512×512: `marketing/store/app-icon-512.png`. Feature graphic 1024×500: `marketing/store/feature-graphic.png` (tamna rezerva `feature-graphic-dark.png`). Sve od Claude Designa, 2026-10-29.

## 2. App content → Ads i Advertising ID

- **Contains ads:** Yes (AdMob — rewarded i interstitial).
- **Advertising ID:** *Does your app use advertising ID?* → **Yes**; svrhe: Advertising or marketing, Analytics, Fraud prevention, security, and compliance. (AdMob SDK sam dodaje dozvolu `com.google.android.gms.permission.AD_ID` — bez ove deklaracije Play odbija upload.)

## 3. App content → Target audience and content

- **Ciljne grupe:** 13–15, 16–17, 18+. **Ne** označavaj ništa ispod 13 — to uvlači igru u *Families* program (posebna pravila za reklame, certificirani ad SDK, strože provjere).
- **„Could your store listing unintentionally appeal to children?"** — iskreno: crtani stil (Pip) može privući djecu. Ako Google procijeni da igra cilja djecu, tražiće Families pravila. Ako odgovoriš „Yes", objasni: igra nema chat, nema prikupljanja ličnih podataka, reklame su ograničene na sadržaj za sve uzraste (`max_ad_content_rating = G` u kodu) i UMP pristanak je uključen.

## 4. App content → Data safety

Igra **nema server ni nalog**. Napredak je samo na telefonu (`user://player_save.json`). Jedini SDK koji šalje podatke je **Google Mobile Ads (AdMob)**. v1 nema kupovina — Billing plugin nije u buildu (§ 0). Googleova lista podataka koje AdMob skuplja: [Play data disclosure](https://developers.google.com/admob/android/privacy/play-data-disclosure).

**Opšta pitanja**

| Pitanje | Odgovor |
|---------|---------|
| Does your app collect or share any of the required user data types? | **Yes** |
| Is all of the user data collected by your app encrypted in transit? | **Yes** (AdMob koristi TLS) |
| Do you provide a way for users to request that their data is deleted? | **Yes** — email podrške (u politici privatnosti) + deinstalacija briše sav lokalni napredak; advertising ID igrač resetuje/briše u Android postavkama |

**Tipovi podataka** (za svaki: Collected = Yes, Shared = Yes (s Googleom za reklame), Processed ephemerally = No, Required)

| Kategorija → tip | Zašto | Svrhe (označi) |
|------------------|-------|----------------|
| Location → **Approximate location** | AdMob iz IP adrese procjenjuje približnu lokaciju | Advertising or marketing; Fraud prevention, security, and compliance |
| App activity → **App interactions** | pokretanja, dodiri i pregledi reklama | Advertising or marketing; Analytics |
| App info and performance → **Diagnostics** | AdMob dijagnostika SDK-a | Analytics; Fraud prevention, security, and compliance |
| Device or other IDs → **Device or other IDs** | advertising ID, app set ID | Advertising or marketing; Analytics; Fraud prevention, security, and compliance |

**Ne označavaj:** ime, kontakte, fotografije, poruke, preciznu lokaciju, zdravlje.

**Granični slučajevi** (Play definicija: „collected" = aplikacija šalje podatak s uređaja):
- *Financial info → Purchase history* — **v1: ne označavaj** (nema kupovina ni Billinga; coini iz igre nisu finansijski podatak). *Kad se IAP vrati:* kupovinu obrađuje Google Play, igra token čuva samo lokalno i nikome ga ne šalje → po definiciji nije „collected"; sigurnija varijanta je Collected = Yes, Shared = No, svrha *App functionality*.
- *Personal info → Email address* — igrač piše podršci iz svoje email aplikacije, ne iz igre → ne označavaj. (Ako jednom dodaš formular za podršku u igri, onda da.)

> Ako kasnije dodaš analitiku, crash reporting ili cloud save → ovaj formular **i** politika se moraju ažurirati.

## 5. App content → Content rating (IARC upitnik)

| Pitanje | Odgovor |
|---------|---------|
| Kategorija | Game |
| Nasilje (bilo koje vrste) | No — Pip skuplja sjemenke, „muncher" jede sjemenke u Areni (bez ozljeda, krvi, borbe) |
| Strah / horor | No |
| Seksualni sadržaj, golotinja | No |
| Psovke, grub jezik | No |
| Droga, alkohol, duhan | No |
| Kockanje (pravi novac / simulirano) | No |
| Korisnici međusobno komuniciraju / dijele sadržaj | No (nema chata, naloga ni dijeljenja) |
| Dijeli lokaciju korisnika s drugim korisnicima | No |
| Digitalne kupovine | **No** — v1 nema kupovina pravim novcem; teme, Sir Pip i boosteri se kupuju coinima zarađenim u igri (coini se ne prodaju) |
| Nasumični predmeti za pravi novac (loot box) | **No** — ništa se ne prodaje za pravi novac (Loot Burst je za coine i daje određene ★3 cvjetove) |

Očekivano: PEGI 3 / ESRB Everyone, **bez** oznake In-Game Purchases.

*Kad se IAP vrati:* Digitalne kupovine = **Yes**; nasumični predmeti = **Yes (sigurniji odgovor)** — Loot Burst kad nema cilja daje 5 nasumičnih sjemenki (stari saveovi) → oznaka „In-Game Purchases (Includes Random Items)". IARC upitnik se tada ponovo ispunjava.

## 6. Monetize → Products → In-app products (one-time)

> **Tek kad se vrati merchant** (§ 0: plugin uključen + `IAP_ENABLED := true`). Za v1 ovdje ništa ne pravi — Play bez payments profila to ni ne dozvoljava.

Play više nema tip „consumable" na proizvodu — igra sama odlučuje (`consume_purchase` za Loot Burst, `acknowledge` za ostalo). **Product ID mora biti tačno ovakav** (kod: `game/scripts/monetization/monetization_config.gd`). Cijene ispod su rezervne cijene iz igre — unesi iste EUR iznose (ili ih promijeni na oba mjesta).

| Product ID | Ime | Opis (EN) | Cijena | Ponašanje u igri |
|------------|-----|-----------|--------|------------------|
| `remove_ads` | Remove Ads | Turn off interstitial ads between runs. Rewarded videos stay optional. | €3.99 | trajno |
| `starter_pack` | Starter Pack | 1,000 coins, Pip Blossom and 10 of each first five seeds. | €1.99 | trajno, jednom |
| `booster_merge_hint` | Merge Hint | Marks the closest match while you hold a seed in the Arena. Yours for good. | €0.99 | trajno |
| `booster_loot_burst` | Loot Burst | +5 ★3 flowers toward the next free season. | €0.99 | **potrošno** (više puta) |
| `season_pack_moonlit_warren` | Moonlit Warren | Unlock the Moonlit Warren theme. Cosmetic only. | €2.99 | trajno |
| `season_pack_coral_tide` | Coral Tide Garden | Unlock the Coral Tide Garden theme. Cosmetic only. | €3.49 | trajno |
| `season_pack_starfall_glade` | Starfall Glade | Unlock the Starfall Glade theme. Cosmetic only. | €2.99 | trajno |
| `season_pack_ember_fen` | Ember Fen | Unlock the Ember Fen theme. Cosmetic only. | €3.49 | trajno — **aktiviraj tek kad Ember izađe** |
| `pip_knight` | Sir Pip | Meadow Knight armour for Pip. Looks only — no gameplay effect. | €3.99 | trajno |

Napomena (Pillar 2): bez popusta, tajmera i „limited" u opisima. Starter Pack u igri se nudi 7 dana — u Play opisu to ne piši kao pritisak.

**License testeri** (Setup → License testing): dodaj svoj Gmail i Gmailove testera. Oni kupuju bez naplate (test kartica).

## 7. Testiranje → Closed testing (obavezno prije produkcije)

Za lične naloge napravljene poslije 13. 11. 2023: **najmanje 12 testera, neprekidno prijavljenih 14 dana**, tek onda smiješ tražiti produkciju ([pravilo](https://support.google.com/googleplay/android-developer/answer/14151465)).

1. Testing → Closed testing → Create track „closed-1".
2. Testers → Email list (Google grupa ili lista Gmailova) — **minimum 12, uzmi 15–20** (neko uvijek odustane).
3. Upload AAB: `game/export/android/merge_meadow.aab` (pravi ga `scripts/android-export.ps1 -Preset Aab`).
4. Pošalji poziv (tekst ispod) s **opt-in linkom** iz Play Consolea.
5. Prati 14 dana; svaki tester mora ostati prijavljen. Poslije: Production → Apply for production (Google pita šta si naučio iz testa — zapisuj feedback).
6. **Mjerenje (RET-01):** igra sama broji dane igranja. **Ne podsjećaj testere da igraju** — tek 15. dan ili kasnije pošalji poruku za kraj testa (ispod) i kratku anketu. Red sa ekrana statistike ide u `testeri.csv` → `python scripts/analytics/retention_forecast.py cohort --csv testeri.csv`. Cijeli protokol: [[testiranje#Closed test — mjerenje (RET-01)|testiranje § Closed test]].

**Poziv testerima — EN**

> Hi! I'm making a cozy mobile game called **Merge Meadow** — you run through a meadow with Pip, collect seeds and merge them into flowers. I need **12+ testers for 14 days** before Google lets me publish it.
> 1. Open this link on your Android phone and tap **"Become a tester"**: [OPT-IN LINK]
> 2. Install Merge Meadow from the Play Store link on that page.
> 3. Keep it installed for 14 days and play a few minutes when you feel like it.
> Any feedback — bugs, what felt hard or boring — is gold. After the 14 days I'll ask you for one short survey and one line of stats from the game (it takes a minute). Thank you! 🌼

**Poziv testerima — BS**

> Hej! Pravim opuštenu igru za mobitel, **Merge Meadow** — trčiš livadom s Pipom, skupljaš sjemenke i spajaš ih u cvijeće. Google traži **bar 12 testera kroz 14 dana** prije nego što je smijem objaviti.
> 1. Na Android telefonu otvori ovaj link i klikni **„Become a tester"**: [OPT-IN LINK]
> 2. Instaliraj Merge Meadow s Play Store linka na toj stranici.
> 3. Drži je instaliranu 14 dana i igraj par minuta kad ti se da.
> Svaki komentar — bug, šta je teško ili dosadno — puno pomaže. Poslije 14 dana zamolit ću te za kratku anketu i jedan red statistike iz igre (traje minut). Hvala! 🌼

**Poruka za kraj testa (15. dan ili kasnije) — EN**

> Thanks for testing Merge Meadow! Last step (1 minute): open the game → ⚙️ Settings → scroll to the bottom → tap the version line **5 times** → **Copy for the developer** → paste that line into this form: [FORM LINK]. The line only has play days and counts — nothing personal. Even if you stopped playing on day 1, your line helps a lot. 🌼

**Poruka za kraj testa (15. dan ili kasnije) — BS**

> Hvala što si testirao/la Merge Meadow! Zadnji korak (1 minut): otvori igru → ⚙️ Settings → skroz dolje → tapni red s verzijom **5 puta** → **Copy for the developer** → zalijepi taj red u ovu formu: [FORM LINK]. U redu su samo dani igranja i brojevi — ništa lično. I ako si prestao/la igrati prvi dan, tvoj red puno pomaže. 🌼

## 8. AdMob + app-ads.txt

1. AdMob → Apps → Add app → Android, „Is the app listed on a supported app store?" → No (dok nije na Playu), ime Merge Meadow.
2. Napravi 2 ad unita: **Rewarded** i **Interstitial**.
2b. **Privacy & messaging → European regulations (GDPR)** → Create message → izaberi Merge Meadow, jezik EN, link na politiku privatnosti → Publish. Po želji i **US state regulations**. Bez objavljene poruke UMP forma pristanka se **ne prikazuje ni u EU** (kod je spreman, forma dolazi iz AdMob konzole).
3. Pošalji agentu: App ID (`ca-app-pub-…~…`), oba ad unit ID-a (`ca-app-pub-…/…`), publisher ID (`pub-…`). Nisu tajni.
4. **app-ads.txt** — AdMob crawler gleda samo **hostname** iz polja „Developer website" na Playu i traži `https://<hostname>/app-ads.txt`. Za GitHub Pages to znači:
   - polje `https://alemsahinovicfax-stack.github.io/merge-meadow/` → crawler traži `https://alemsahinovicfax-stack.github.io/app-ads.txt` (**user site**, ne projektni folder);
   - zato treba **novi repo `alemsahinovicfax-stack.github.io`** s fajlom `app-ads.txt` u korijenu (ili vlastita domena).
   - Šablon fajla: `docs/06-production/app-ads/app-ads.txt` — agent upiše tvoj publisher ID i objavi kad ga dobije.
5. Crawl traje do 24 h; status u AdMob → Apps → app-ads.txt.

## 9. Payments profile (tek kad se vraćaju kupovine — § 0)

1. Play Console → Setup → Payments profile → Create (ili poveži postojeći Google payments profil).
2. Tip: Individual ili Business, zemlja = **podržana merchant zemlja**.
3. Ime i adresa = iz te zemlje, bankovni račun (IBAN) za isplate.
4. Porez: obrazac **W-8BEN** (fizičko lice, nisi US) ili **W-8BEN-E** (firma). Bez toga Google zadržava 30 % US poreza na prodaju u SAD-u.
5. Verifikacija identiteta (lična karta / pasoš) — traje par dana.

## Povezano

- [[launch-prep-plan|launch-prep-plan]] — tvoj dio liste
- [[play-internal-test|play-internal-test]] — internal test runbook
- [[../05-technical/privacy-policy-draft|privacy-policy-draft]] — šta politika kaže
- [[../05-technical/godot/iap-billing-setup|iap-billing-setup]] — billing u kodu
