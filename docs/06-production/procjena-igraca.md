---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, retencija, dau, analitika, launch]
povezano:
  - testiranje
  - play-console-sutra
  - troskovi-launcha
  - verzije-nakon-launcha
  - sadrzaj-trajanje-simulacija
  - sigurnost
ai_sažetak: "RET-01: kako procijeniti i mjeriti koliko ljudi igra (D1/D7/D30, DAU) — formula, benchmarki, ciljevi i stop signali, faze 0–3, lokalni brojač + ekran statistike, kalkulator, trajanje sadržaja, odluka o analitici (preporuka Aptabase dnevni sažetak bez ID-a), rutina poslije launcha."
---

# Procjena igrača — retencija i DAU (RET-01)

> Roditelj: [[06-production/_index|06-production]] · Protokoli: [[testiranje|testiranje]] · Closed test: [[play-console-sutra|play-console-sutra]] § 7 · Prihod: [[troskovi-launcha|troskovi-launcha]]

## Sažetak

Tačan broj igrača se ne zna prije launcha — sužava se u koracima: izmjeri retenciju na malom uzorku, ubaci u formulu, uporedi s benchmarkom. Od 2026-10-26 igra **sama broji** dane igranja, sesije, vrijeme i napredak (lokalno, ništa ne šalje); tester to pokaže na skrivenom ekranu i pošalje jedan red teksta. Kalkulator iz tog reda (ili iz bilo kojih D1/D7) računa krivu retencije i DAU. Za javni launch treba i analitika — odluka je u § 8.

## 1. Formula

**DAU ≈ instalacije po danu × prosječan broj dana koje jedan igrač odigra**

Tačnije: `DAU(T) = Σ instalacije(dan i) × R(T − i)`, gdje je `R(t)` udio igrača koji igraju t-ti dan poslije instalacije (`R(0) = 1`).

Kriva iz D1 i D7: `R(t) ≈ D1 · t^(−b)`, `b = ln(D1 / D7) / ln 7`. Iz nje se dobiju D30 i D90. Ovakva kriva obično **precijeni D30** (igre gube igrače brže kad im ponestane sadržaja) — kad stignu pravi D14 / D30, kalkulator ih uzme u obzir (najmanji kvadrati u log-log).

## 2. Benchmarki (GameAnalytics, svi žanrovi)

| Metrika | Slabija četvrtina | Medijan | Najboljih 25 % |
|---|---|---|---|
| D1 | ~10–11 % | — | ~27–30 % |
| D7 | — | ~3,5–4 % | ~6–8 % |
| D30 | — | ~0,7–0,8 % | ~1,6–1,8 % |
| Sesija | — | 5–6 min | 8–9 min |

Izvori: [GameAnalytics benchmarks 2025](https://gamedevreports.substack.com/p/gameanalytics-mobile-gaming-benchmarks) · [GameAnalytics benchmarks 2026 (podaci 2025)](https://gamedevreports.substack.com/p/gameanalytics-mobile-and-pc-game). Brojke su za sve žanrove zajedno; hybrid casual nije posebno izdvojen.

## 3. Ciljevi i stop signali

| | Cilj (najboljih 25 %) | Stop signal |
|---|---|---|
| D1 | ≥ 28 % | < 20 % |
| D7 | ≥ 7 % | < 3 % |
| D30 | ≥ 2 % | — |

**Stop signal** = prvo popraviti prvo iskustvo (tutorijal, prvih 10 min), tek onda trošiti na plaćene instalacije ili marketing.

## 4. Šta mjerimo i čime

| Izvor | Šta daje | Šta NE daje |
|---|---|---|
| **Lokalni brojač** (`ActivityLog`, od 2026-10-26) | po igraču: dani 0–30 (igrao / nije), sesije, minute, runovi, najdalji level, dan tutorijala / Endlessa, prvi merge | ništa dok tester sam ne pošalje red |
| Ekran „Your stats" (Settings → 5 dodira na verziju) | jedan screenshot + **Copy** red `mm1` za kalkulator | — |
| Play Console | instalacije, deinstalacije, „retained installers", Compare to peers | da li se igra (retained = još instalirano, ne igrano) |
| AdMob | prikazi reklama po danu | ko igra bez reklama |
| Analitika (§ 8) | retencija po kohorti, lijevak prvog dana — za sve igrače | — dok se ne odluči i ne ugradi |

Brojač ne šalje ništa sa uređaja → politika privatnosti i Data safety ostaju isti (podaci se ne „prikupljaju" u smislu Google Playa; tester sam bira da pošalje red).

Provjereno 2026-10-26 u **release APK-u** na emulatoru (Pixel_4_API33): ekran se otvara 5 dodira na verziju (3 ne otvaraju), povratak poslije 10 min u pozadini = nova sesija, pauza se ne broji u minute, podaci prežive update APK-a, Copy pokaže „Copied". Snimak: ![[procjena-igraca-ref/your-stats-release-emulator.png|300]]

## 5. Faze

| Faza | Kada | Uzorak | Šta dobijemo | Alat |
|---|---|---|---|---|
| **0** | sada | 5–10 nepoznatih | prvo iskustvo: prvi merge < 4 min, drugi run svojevoljno | [[testiranje#Playtest prvog iskustva (5–10 nepoznatih)\|playtest]] + ekran statistike |
| **1** | closed test, 14 dana | 12–20 testera | D1 / D3 / D7 / D14 (kvalitativno; 6/15 = 20–64 %) | brojač → `cohort` |
| **2** | prve sedmice produkcije + test kampanja 50–100 € | ~300+ instalacija | D1 ±5 %, D7 ±3 % → prava prognoza | analitika (§ 8) → `forecast` |
| **3** | mjesečno | sve kohorte | D30, DAU trend, ažurirana prognoza | `forecast` + Play / AdMob |

## 6. Scenariji

Množilac = očekivani broj aktivnih dana po instalaciji u prvih 90 dana (dan instalacije = 1). DAU uz stalan priliv instalacija:

| Retencija | D1 / D7 → D30 | Množilac | 5 inst./dan | 20 inst./dan | 50 inst./dan |
|---|---|---|---|---|---|
| Slaba | 15 % / 2,5 % → ~0,7 % | ×1,9 | ~10 DAU | ~38 | ~95 |
| Prosječna | 22 % / 4 % → ~1,1 % | ×2,4 | ~12 | ~48 | ~120 |
| Dobra | 25 % / 6 % → ~2 % | ×3,3 | ~17 | ~66 | ~165 |

Brojke daje `python scripts/analytics/retention_forecast.py scenarios` (prosječna tačno ×2,45 / 49 / 123). Slaže se s „realističnim" scenarijem u [[troskovi-launcha|troskovi-launcha]] (25–60 DAU). Organske instalacije poslije launcha opadaju, pa je DAU „nakon par mjeseci" ≈ tadašnje instalacije po danu × množilac + mala jezgra vjernih igrača. Ponovi s pravim brojkama: `python scripts/analytics/retention_forecast.py scenarios --d1 … --d7 …`.

## 7. Trajanje sadržaja (simulator)

Iz [[../02-design/sadrzaj-trajanje-simulacija|sadrzaj-trajanje-simulacija]] (`economy_sim.gd -- --runs=400 --reps=10`, politika boost, medijan). Model igrača je pretpostavka — kalibrisati čim stignu redovi testera.

**Kalendarskih dana do kraja besplatnog sadržaja** (4 sezone pređene + sve nadogradnje + svi izgledi za coine):

| Profil | 10 min / dan | 15 min / dan | 25 min / dan | 40 min / dan | Minuta igre ukupno |
|---|---|---|---|---|---|
| average | ~64 | ~47 | ~27 | ~18 | ~640–700 |
| skilled | ~48 | ~34 | ~21 | ~13 | ~480–520 |
| casual | ne stigne (1–3 od 10 putovanja) | ne stigne | ne stigne | ne stigne | zapne na L15–20 |

- Dani ≈ minute igre ÷ minute dnevno — ukupno trajanje sadržaja je ~10 h za prosječnog, ~8 h za vještog igrača.
- **Igrači koji ostanu do D30 su upravo oni koji igraju 25+ min dnevno — oni završe sav besplatni sadržaj za ~3–4 sedmice** (average ~27, skilled ~21 dan). Poslije toga ostaju Endless i plaćene sezone.
- **Zid za casual igrača: leveli 15–20** — prolaz pada sa 7 % (L15) na 0,5–0,8 % (L18–20), ~480 min pokušaja po sezoni samo za te levele. Nadogradnje u modelu ne smanjuju rizik prepreka, pa se zid ne može „kupiti". Ovo je mogući izvor pada D7 / D14 kod casual igrača → BAL-01 i lijevak `level_10 → endless_unlock` (§ 8).

## 8. Odluka o analitici za javni launch

**Status: čeka odluku.** Ne blokira closed test (brojač ga pokriva). Mora biti živa u **prvom produkcijskom buildu** — prve sedmice se ne mogu izmjeriti naknadno; najbolje ubaciti već u zadnji AAB closed testa (politika i Data safety ažurirani prije tog AAB-a).

| Opcija | Godot 4.7 Android | Privatnost / UMP | Politika + Data safety | Trud |
|---|---|---|---|---|
| Bez analitike | — | ništa | ništa | 0 — ali bez retencije poslije launcha |
| **Aptabase** (GDScript autoload, EU regija, 20 000 događaja / mj besplatno) | Godot 4.2+; Android nije izričito naveden → provjeriti test APK-om | bez ID-a uređaja; prodavac tvrdi da pristanak nije potreban | App interactions, nije vezano za identitet | S–M |
| Firebase Analytics ([godot-x/firebase](https://github.com/godot-x/firebase) 2.5.0, cilja Godot 4.7, traži Gradle build — već ga imamo) | da | Consent Mode v2 vezati za UMP (privacy-safe start isključen) | Device IDs + App interactions, dijeljeno s Googleom | M |
| GameAnalytics ([GA-SDK-GODOT](https://github.com/GameAnalytics/GA-SDK-GODOT), GDExtension, Godot 4.5+, Android naveden) | provjeriti na 4.7 | API za pristanak nije dokumentovan | Device IDs | M |
| Vlastiti endpoint | da | po izboru | po izboru | L + server (OUT: „bez servera u v1") |

**Preporuka: Aptabase s dnevnim sažetkom bez ID-a** ([aptabase.com/for-godot](https://aptabase.com/for-godot)).

- Jednom po aktivnom danu jedan događaj `day` sa svojstvima: `d` (dan od instalacije), `c` (datum instalacije = kohorta), `v` (verzija), `r` (runova), `m` (minuta), `lv` (najviši level tog dana), `se` (sezona), `ads` (odgledanih rewarded), `iap` (kupovina). Sve iz istog `ActivityLog`-a (+ dva brojača koja treba dodati: reklame, kupovine).
- Na dan 0 i lijevak: `first_open`, `tutorial_done`, `first_merge`, `level_5`, `level_10`, `endless_unlock`.
- **Retencija kohorte** = broj `day` s `d = N` / broj `day` s `d = 0` za isti `c` — bez ikakvog ID-a.
- Budžet: ~1–2 događaja po aktivnom danu → ispod 20 000 / mj do otprilike 400 DAU.
- Prije odluke provjeriti: radi li SDK na Androidu (INTERNET dozvola već postoji), može li dashboard grupisati po svojstvu (inače export / API).
- **Razlika prema Firebaseu:** tačan „level na kojem igrač zadnji put igra" traži ID po instalaciji (Firebase ga ima). Ovdje se vidi raspodjela levela po danu (gdje napredak stane), ne posljednji level po igraču.
- Pillar 2: analitika ne mijenja igru ni monetizaciju — ne krši ga.
- Rezerva ako Aptabase ne radi na Androidu: Firebase.

## 9. Rutina poslije launcha

**Sedmično (15 min):** instalacije (Play) · D1 i D7 nove kohorte (analitika) · AdMob prikazi po danu · nove recenzije.

**Mjesečno:** D30 kohorte od prije mjesec dana · `forecast` s izmjerenim D1 / D7 / D14 / D30 i trenutnim instalacijama → DAU za 3 mjeseca unaprijed · Play „Compare to peers" · ažuriraj ovaj dokument (§ 6) i [[troskovi-launcha|troskovi-launcha]].

**Okidači:**
- D1 < 20 % ili D7 < 3 % → stop plaćenim instalacijama, popravak prvog iskustva.
- Igrači koji igraju 25+ min dnevno stignu do kraja besplatnog sadržaja za ~3–4 sedmice (§ 7) → DG-01 Daily Goals i nova sezona (ili cilj u Endlessu) moraju biti spremni **do ~3. sedmice od launcha** ([[verzije-nakon-launcha|verzije-nakon-launcha]]). Kad stignu pravi podaci, ponovi `economy_sim.gd -- --parts=c` s kalibrisanim modelom (`--calibrate`).
- Lijevak: velik pad između `level_10` i `endless_unlock`, ili mnogo `day` događaja koji stoje na `lv` 15–20 → zid (simulator ga već vidi za casual, § 7) → BAL-01.
- D7 dobar, D30 loš → nedostaje dugoročni cilj (sadržaj, kolekcija), ne prvo iskustvo.

## 10. Alati

| Alat | Fajl |
|---|---|
| Brojač aktivnosti | `game/scripts/economy/activity_log.gd` (save ključ `activity`), kuke u `game/scripts/autoload/game_state.gd` |
| Ekran „Your stats" | `game/scripts/ui/activity_stats_view.gd`, `game/scripts/ui/settings_screen.gd` (5 dodira na verziju) |
| Copy red | `mm1,version,first_day,days,sessions,minutes,runs,season,level,tut_day,end_day,merge_sec,late_days,last_day` — `days` = 31 znak (1 igrao, 0 nije, - nepoznato) |
| Kalkulator | `scripts/analytics/retention_forecast.py` (`forecast`, `scenarios`, `cohort`) |
| Simulator | `game/scripts/dev/economy_sim.gd` (`--day-min`, `--parts`, `--day-mins`) → [[../02-design/sadrzaj-trajanje-simulacija\|sadrzaj-trajanje-simulacija]] |
| Testovi | GUT `test_activity_log.gd`, `test_game_state_save_migration.gd`; smoke `activity_stats_smoke.gd`; `python -m unittest discover scripts/analytics` |

## Povezano

- [[testiranje|testiranje]] — playtest prvog iskustva, protokol closed testa
- [[play-console-sutra|play-console-sutra]] — closed test, poruke testerima
- [[troskovi-launcha|troskovi-launcha]] — DAU → prihod
- [[verzije-nakon-launcha|verzije-nakon-launcha]] — DG-01, nove sezone
- [[../05-technical/sigurnost|sigurnost]] — analitika i GDPR
