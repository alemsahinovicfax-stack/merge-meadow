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
ai_sažetak: "Gotovi odgovori za Play Console (Data safety, IARC, ciljna publika, IAP proizvodi, closed test + poziv testerima, payments profile — BiH nije merchant zemlja, app-ads.txt) — korisnik samo prepisuje."
---

# Play Console — odgovori za prepisati

> Roditelj: [[06-production/_index|06-production]] · Plan: [[launch-prep-plan|launch-prep-plan]] · Napisano 2026-10-23 prema onome što igra **stvarno radi** (provjereno u kodu, ne pretpostavljeno).

## 0. Prvo pročitaj — BiH i prodaja

**Bosna i Hercegovina nije podržana zemlja za Google Play merchant** ([lista zemalja](https://support.google.com/googleplay/android-developer/answer/9306917): BiH ima ✔ za developer nalog, ✘ za merchant). To znači:

| Šta | Iz BiH |
|-----|--------|
| Developer nalog (25 USD), objava besplatne igre | ✅ radi |
| AdMob reklame i isplata zarade od reklama | ✅ poseban program, ne treba Play merchant (provjeri da AdMob isplaćuje na BiH račun) |
| In-app kupovine (Remove Ads, sezone, Sir Pip…) | ❌ ne može bez payments profila u podržanoj zemlji |

**Opcije** (odluka je tvoja):
1. **v1 samo s reklamama** — igra izlazi besplatna, kupovine se sakriju dok ne riješiš merchant. **Prekidač postoji (2026-10-23):** u `game/scripts/monetization/monetization_config.gd` postavi `const IAP_ENABLED := false`, pa napravi novi AAB. Shop tada ima samo Looks (kozmetika za coine), nema Premium taba na Homeu, plaćene sezone u Campu, Sir Pipa ni Settings → Purchases, a Billing se ne spaja. Kad riješiš merchant: vrati na `true`, napravi proizvode u Play Consoleu (§ 6), novi AAB. U tom slučaju u Play Consoleu ne pravi IAP proizvode, a Data safety ostaje isti. Billing plugin i dalje dodaje dozvolu `BILLING` u manifest — to Play dozvoljava i bez proizvoda; ako ipak zatraži payments profil, isključi plugin (Project → Project Settings → Plugins → GodotGooglePlayBilling) i napravi novi AAB.
2. **Firma ili prebivalište u podržanoj zemlji** — npr. Hrvatska, Srbija, Sjeverna Makedonija su podržane. Payments profil mora biti na pravno lice / osobu iz te zemlje, s računom i poreznim podacima te zemlje.
3. ❌ **Tuđi nalog / tuđi payments profil** — ne. Google to tretira kao lažno predstavljanje i gasi nalog.

Dok merchant nije riješen, Play Console neće ni dozvoliti pravljenje IAP proizvoda (traži payments profil). Kod je spreman: kad proizvodi postoje, Shop sam povuče prave cijene.

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

Store tekst i 8 screenshotova: [[store-listing-en|store-listing-en]], `marketing/store/screenshots/`. Store ikona 512×512: `marketing/store/app-icon-512.png`. **Feature graphic 1024×500 još ne postoji** — Play ga traži za listing.

## 2. App content → Ads i Advertising ID

- **Contains ads:** Yes (AdMob — rewarded i interstitial).
- **Advertising ID:** *Does your app use advertising ID?* → **Yes**; svrhe: Advertising or marketing, Analytics, Fraud prevention, security, and compliance. (AdMob SDK sam dodaje dozvolu `com.google.android.gms.permission.AD_ID` — bez ove deklaracije Play odbija upload.)

## 3. App content → Target audience and content

- **Ciljne grupe:** 13–15, 16–17, 18+. **Ne** označavaj ništa ispod 13 — to uvlači igru u *Families* program (posebna pravila za reklame, certificirani ad SDK, strože provjere).
- **„Could your store listing unintentionally appeal to children?"** — iskreno: crtani stil (Pip) može privući djecu. Ako Google procijeni da igra cilja djecu, tražiće Families pravila. Ako odgovoriš „Yes", objasni: igra nema chat, nema prikupljanja ličnih podataka, reklame su ograničene na sadržaj za sve uzraste (`max_ad_content_rating = G` u kodu) i UMP pristanak je uključen.

## 4. App content → Data safety

Igra **nema server ni nalog**. Napredak je samo na telefonu (`user://player_save.json`). Jedini SDK koji šalje podatke je **Google Mobile Ads (AdMob)**; Google Play Billing obrađuje kupovine kod Googlea. Googleova lista podataka koje AdMob skuplja: [Play data disclosure](https://developers.google.com/admob/android/privacy/play-data-disclosure).

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

**Dva granična slučaja** (Play definicija: „collected" = aplikacija šalje podatak s uređaja):
- *Financial info → Purchase history* — kupovinu obrađuje Google Play, igra token čuva samo lokalno i nikome ga ne šalje → po definiciji nije „collected". **Sigurnija varijanta:** označi Collected = Yes, Shared = No, svrha *App functionality* — ništa ne gubiš, a pregled ne može reći da si nešto prešutio.
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
| Digitalne kupovine | **Yes** |
| Nasumični predmeti za pravi novac (loot box) | **Yes (sigurniji odgovor)** — Loot Burst daje određene ★3 cvjetove, ali kad nema cilja, daje 5 **nasumičnih** sjemenki. Oznaka će biti „In-Game Purchases (Includes Random Items)". |

Očekivano: PEGI 3 / ESRB Everyone, uz oznake In-Game Purchases.

## 6. Monetize → Products → In-app products (one-time)

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

**Poziv testerima — EN**

> Hi! I'm making a cozy mobile game called **Merge Meadow** — you run through a meadow with Pip, collect seeds and merge them into flowers. I need **12+ testers for 14 days** before Google lets me publish it.
> 1. Open this link on your Android phone and tap **"Become a tester"**: [OPT-IN LINK]
> 2. Install Merge Meadow from the Play Store link on that page.
> 3. Keep it installed for 14 days and play a few minutes when you feel like it.
> Purchases in the test are free (test card). Any feedback — bugs, what felt hard or boring — is gold. Thank you! 🌼

**Poziv testerima — BS**

> Hej! Pravim opuštenu igru za mobitel, **Merge Meadow** — trčiš livadom s Pipom, skupljaš sjemenke i spajaš ih u cvijeće. Google traži **bar 12 testera kroz 14 dana** prije nego što je smijem objaviti.
> 1. Na Android telefonu otvori ovaj link i klikni **„Become a tester"**: [OPT-IN LINK]
> 2. Instaliraj Merge Meadow s Play Store linka na toj stranici.
> 3. Drži je instaliranu 14 dana i igraj par minuta kad ti se da.
> Kupovine u testu su besplatne. Svaki komentar — bug, šta je teško ili dosadno — puno pomaže. Hvala! 🌼

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

## 9. Payments profile (kad riješiš zemlju — § 0)

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
