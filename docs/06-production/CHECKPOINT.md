---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, checkpoint, operativa]
povezano:
  - scope-i-granice
  - plan-arhitektura-refaktor
ai_sažetak: "Operativni hub — jedini izvor istine za fazu/milestone; frontmatter prvo; prva [ ] u aktivnoj sekciji je sljedeći korak."
aktivna_sekcija: D
b0_aktivan: false
sljedeci_korak: "ADS-ONLY (2026-10-27): v1 samo s reklamama — IAP stvari za coine (Merge Hint 1500, Loot Burst 1000, teme 10000, Sir Pip 3000), ★3 sjeme ×2, Billing plugin isključen; commit + push pa CD brief docs/04-experience/design-drafts/ads-only-cd-brief.md (Shop tenda za 3 taba, Home Free / Premium, coin pilule) → Claude Design; playtest u debug buildu: Shop (Seasons / Looks / Boosters, dva tapa, „Need N more coins“), Home Premium tab, Camp kartica teme (Settings → Developer → Unlock all seasons + +1000 coins), Ormar Sir Pip — ads-only-coini-izvjestaj. RET-01 (2026-10-26): brojač aktivnosti + ekran „Your stats“ u igri (Settings → 5 dodira na verziju). Prije closed testa: playtest prvog iskustva sa 5–10 nepoznatih (testiranje.md); ODLUKA o analitici za javni launch (procjena-igraca § 8, preporuka Aptabase dnevni sažetak bez ID-a); u closed testu NE podsjećati testere — 15. dan ili kasnije poruka + anketa iz play-console-sutra § 7, redovi u testeri.csv → retention_forecast.py cohort. LAUNCH-PREP kod gotov 2026-10-23 (docs/06-production/launch-prep-izvjestaj.md). Na početku sesije podsjeti korisnika na NJEGOV dio (launch-prep-plan § Šta radim ja; IAP odluka riješena 2026-10-26 — v1 samo reklame, Play forme po varijanti bez kupovina): Play nalog 25 USD; AdMob nalog → App ID + 2 ad unita + publisher ID + GDPR poruka; backup upload keystorea; Play forme iz play-console-sutra.md; feature graphic 1024×500; 12+ testera za closed test 14 dana. Kad stignu AdMob ID-evi → monetization_config.gd PRODUCTION IDS + Project Settings admob app_id + app-ads.txt (GitHub user site). Paralelno otvoreno: BAL-01 (balans ciklus 1) — playtest u debug buildu: 10–15 runova kroz levele (osjeti li se da leveli rastu, nije li 16–20 preteško), Endless poslije levela 15 (lagan start, sve teže, rekord), nove cijene (sezone / nadogradnje / izgledi), ★3 sjeme rijetko; telemetrija u user://balance_log.csv → economy_sim --calibrate → ciklus 2; odluke u balans-ciklus-1-izvjestaj § Odluke. CD-LVL-END u igri — playtest izgleda težine i Endlessa (pojasevi, najava, nalet, par, cilj na kraju, zaključan / otključan Endless, HUD, rekord, kraj „All yours", spreman sanduk); Reduce motion u Settings mora biti isključen da se vide animacije (leveli-endless-izvjestaj § Otvoreno). Dalje D0-P / playtest: FIX-1016 (Settings u Areni, muncher u sredini i na najbližem sjemenu, Camp link s plaćenim sezonama, polje sezone, vreća bez limita, Shop štand — tura u ispravke-1016-izvjestaj); CD-RUN-PICK u igri — playtest pickupa u runu i plaćenih Camp kartica (run-pickups-izvjestaj § Odluke); CD-LVL-PATH u igri — playtest Level Patha (Play u polju → put → run → skok Pipa, Claim nagrada; odluke: stari level → aktivna sezona, ista težina u svim sezonama — level-path-izvjestaj); ZVUK-01 + MUZ-SEZ (drugi ciklus: slušati teme svih 8 sezona — da li svaka zvuči kao svoj žanr, i na telefonu; tura u zvuk-izvjestaj § Drugi ciklus; izabrati izvor prave muzike — muzika-brief), CD-MUNCH-PIP (Nibbs u Areni, Sir Pip — kupovina za coine, Ormar, run), FIX-1012, SET-01 (Settings, Album okvir, Classic Pip, Shop Pip), SEZ-SYNC, CAMP-08, PIP-01, RUN-HUD-02, PERF-02 čekaju playtest; pravi zvuk (Kenney CC0 efekti, muzika); UMP pristanak za reklame; mjerenje na telefonu."
zadnja_sesija: "2026-10-27 (drugi krug): teme 10000 C, ★3 sjeme ×2 uz ★3 tip uvijek rjeđi od ★2 tipa (levels.json, od L8 / Endless 1 min ★3 = ★2 − 0,01; BASE_RARE3 0,24; casual Frost 8,3 → 5,9 dana), Shop header za 3 taba popravljen, CD izvještaj + brief (ads-only-cd-izvjestaj / ads-only-cd-brief, 16 snimaka ads-only-ref). 2026-10-27: ADS-ONLY — IAP_ENABLED false, IAP stvari za coine kroz isti grant (IAPManager.buy_with_coins), dva tapa u Shopu / Homeu / Campu, „Need N more coins“, Remove Ads i Starter Pack sakriveni, Billing plugin off (AAB bez BILLING dozvole, 68,2 MB), coin_offer_sim.gd (Loot Burst 500 → 1000), Play forme / store tekst / politika bez kupovina; GUT 149/149. Ranije 2026-10-26: RET-01 — procjena igrača: ActivityLog (lokalni brojač dana 0–30, sesija, vremena, runova, napretka; save ključ activity; release build; ništa ne šalje), skriveni ekran Your stats + Copy red mm1, protokoli closed testa i playtesta prvog iskustva, procjena-igraca.md (formula, benchmarki, ciljevi, faze, odluka o analitici); simulator u danima (sadrzaj-trajanje-simulacija.md: average ~27 dana do kraja sadržaja na 25 min/dan, casual zid L15–20) i kalkulator scripts/analytics/retention_forecast.py; GUT 132/132, smoke 81/81, release APK na emulatoru. Ranije 2026-10-23: LAUNCH-PREP — Gradle release build (target SDK 36, upload keystore, AAB potpisan), GodotGooglePlayBilling 3.3.0 (reconnect, pending, restore, PackedStringArray product_ids, nikad besplatno na Androidu), Poing AdMob 5.1.0 + UMP (nagrada samo kad je odgledano, interstitial 1 na 3 Retry-ja / 3 min / ne u tutorijalu i prvoj sesiji, Privacy choices), politika usklađena, Pip ikone + splash, play-console-sutra.md (BiH nije merchant zemlja), smoke-all.ps1; GUT 107/107, smoke 79/79, AAB 68,6 MB, emulator: test rewarded → Revive radi; katalog #54–#59. Ranije 2026-10-22 (3): balans ciklus 1b — težina +5 levela, prepreke 3× svojim tokom (≥ 300 px, nikad na pickupu), Endless 60 s ispred, ★3 ×1,25; simulator (average L15 30 %, L20 3 %); katanac Endless centriran. Ranije (2): tutorijal = 2 vođena runa (Arena tek s 50 sjemenki), dev prekidač Test seeds. Ranije: paket design_handoff_leveli_endless u igri — pojasevi težine (kamenovi, zastavice, LevelChip), najava levela, nalet na stepenicu brzine, par prepreka kao jedan predmet, cilj na kraju levela (8 sezona, presiječe Pipa tačno na kraju), Endless dugme (zaključano s prstenom, trenutak otključavanja 15 → 16, rekord), Endless HUD (sat · Pace · Best), nova stepenica, novi rekord, pauza i kraj „All yours", spreman sanduk bez Claim; zastavica para bila odsječena (viewBox) i rgba() crne mrlje (#50); efekti kretali sami (Godot uključi _process, #51); čip drži level sa starta; rekord kroz Revive; run čita trajanje jednom po frejmu; test levels_endless_smoke, GUT 84/84, bench, snimke. Ranije 2026-10-21: balans ekonomije ciklus 1 — leveli 1–20 u levels.json sve teži (60 → 120 s, brži, više prepreka, parovi od L6, više plijena), sjeme po rijetkosti (★3 3–7 % umjesto 16,7 %), Endless bez tajmera sa stepenicama svakih 20 s, pun plijen, rekord po sezoni, otključan poslije levela 15; cijene sezona / nadogradnji / izgleda podignute (×5–13), dnevni poklon, combo, Starter Pack, magnet max dohvata susjednu stazu; simulator economy_sim.gd (prije / poslije, 3 profila × 3 politike), telemetrija runova (debug), economy_balance_smoke, GUT 78/78, 20 smoke testova čita cijene iz podataka; CD brief leveli-endless-cd-brief + slike. Ranije 2026-10-20 (2): paket design_handoff_level_path u igri — Play u polju otvara put sezone (20 kamenova iz kits[id].path, Pip na trenutnom levelu, skok poslije pređenog, complete), Play na putu = run, ‹ Field nazad; nagrade 5/10/15/20 (popup + let u bar), badge na Play i kartici, lokator Pipa; napredak po sezoni u saveu (stari run_level → aktivna sezona); FPS: put = polje ili brži, popup ~+1 ms; test level_path_smoke. Ranije 2026-10-20: paket design_handoff_run_pickups u igri — pickupi u runu (idle iz atlasa, let magnetom, dodir sa Pipom, niz coina, twin, 4 Pip reakcije, pilula „+1" do čipa, tačkasti magnet) i Camp kartice plaćenih sezona (recept, ink, PREMIUM + 6 cvjetova, stanja); FPS: CPU efekata 3,3 → 0,35 ms najgore, GPU A/B jednako ili brže, draw 72 → 45; testovi run_pickups_smoke, camp_paid_card_smoke. Ranije 2026-10-17: MEAD-2…11 — IAP grant poslije acknowledge, stub IAP/reklama zatvoreni na Android releaseu, Loot Burst consume, atomarni save, Pip atlas u threadu, GUT merge/wallet/IAP, checklist usklađen, obrisan UiShop. GUT 70/70. Ranije 2026-10-16: ispravke poslije playtesta — Settings iznad Arene (z 200) i zaključan zupčanik tokom runde, gnijezdo munchera u sredini polja i lov uvijek na najbližu sjemenku, Camp link nastavlja s plaćenim sezonama (samo cijena), rezervisano cvijeće zadnje, Home polje broji ukupno uzgojeno ★3 (star3_grown), čip „0 / 13 grown" uklonjen, vreća sjemena bez limita (plijen se gubio), Shop štand iznad kartica; nova politika privatnosti (13 sekcija); CD brief za pickupe u runu; test fixes_1016_smoke. Ranije 2026-10-15: muzika po sezoni, drugi ciklus — 24 teme ponovo, svaka sezona žanr: vlastiti instrumenti (101, 0 dijeljenih), ritam melodije, harmonija, tempo / mjera / soba i osjećaj izvođenja; music_report.py mjeri zvuk, melodiju i harmoniju; stroži lint. Ranije 2026-10-14 (3): muzika po sezoni — 24 teme (8 sezona × home / arena / run) s identitetom sezone, novi generator (teorija, ~35 instrumenata, ambijenti, lint harmonije), AudioManager.play_level prati aktivnu sezonu. Ranije 2026-10-14 (2): zvuk cijele igre — AudioManager + katalog, 59 efekata i 3 teme (privremena sinteza, scripts/audio), spojeno svuda (UI, Home, Shop, IAP, Ormar, Settings, Camp, Arena, Nibbs, Pip, run, loot, Album), duck / reklama / haptika, učitavanje u threadu (start huba bez zastoja), audio_smoke; brief za pravu muziku. Ranije 2026-10-14: paket design_handoff_muncher_premium_pip u igri — Nibbs (novi muncher, rig + 16 klipova, krtičnjak, baner) i Sir Pip (premium skin €3.99, Shop + Ormar + IAP); FPS: muncher 2–4 draw poziva umjesto 44–51. Ranije: 2026-10-12 (2): Dev reset sezona svuda, oblačić tutoriala Arene iznad pilule, Album bez sažetka, druga noga Pipa u three_q; brief za CD — muncher redizajn + premium Pip skin. Ranije 2026-10-12: sezone između sekcija popravljene + season_sync_smoke; brief i paket design_handoff_settings_fixes preneseni — Album prozor, Classic Pip skin, Pip iz riga u Shopu, pun Settings ekran (busovi Music / SFX spremni za zvuk). Ranije: Camp v3, Run HUD v2, bez dijamanata, FPS pregled."
zadnje_azurirano: 2026-10-27
spec_slice: "docs/02-design/spec-vertical-slice.md (source of truth) + ekonomija-brojevi.md"
dev_stroj: "HP laptop, Windows, AMD Radeon integrisana — Godot samo OpenGL"
godot_launch: "scripts/godot-open.ps1 (--rendering-driver opengl3)"
test_uredjaji:
  - "Android emulator Pixel_4_API33 (API 33, host GPU — primarni)"
  - "Android emulator Pixel_4 (API 30 — NE za Godot 4, samo GLES2 guest)"
  - "iPhone (iOS test — M7, C4)"
strategija_platforme: "android-first; iOS kad prikupi ~99 USD (Apple Developer)"
# --- Praćenje faza (agent + ti) ---
dokumentacija_zavrsena_do: "M5½ — CHECKPOINT Sekcija A (A1–A4)"
prva_faza_kodiranja: "M6 — CHECKPOINT Sekcija B (B1–B3) ✅"
sljedeca_runda_dokumentacije: "Prije store (D0/D4) — listing/ASO; inače samo sync uz kod"
---

# CHECKPOINT — operativni vodič

> **Otvori ovaj fajl na početku svake sesije.**  
> Redoslijed: `CHECKPOINT` → konkretni doc (`sljedeci_korak` link) → tek onda `game/`.
> `CHECKPOINT.md` je **jedini izvor istine** za fazu/milestone (RADIONICA-razvoj, milestone-i i roadmap su arhivirani u [[_archive/_index|_archive/]] — zamrznuti prije M7/M8, više se ne ažuriraju).

## Gdje smo

| Polje | Vrijednost |
|-------|------------|
| **Milestone** | **M8** — Launch prep (Sekcija D) |
| **Podfaza** | `d0-prelaunch` — **JOURNAL ✅**; CAMP-06 čeka playtest. Puna tablica traka: [[#Aktivne trake (feature ID)\|Aktivne trake]] niže. |
| **Igra** | Merge Meadow — hybrid casual lane run + merge kamp |
| **Engine** | Godot 4.x (HP laptop / Windows) |
| **Save** | Lokalni JSON (`user://player_save.json`) — **bez** server/baze u v1 |
| **Strategija** | **Android-first** — Play nakon D0 + **25 USD**; **iOS** kad ~**99 USD** |
| **Test** | Emulator (dnevno) → stariji Android (fizički) → iPhone (Faza 4) |

## Dokumentacija vs kod — kada što radiš

### Dokumentacija “faza 1” — **ZAVRŠENA**

| Do čega | Milestone | Checkpoint | Status |
|---------|-----------|------------|--------|
| Planiranje prije koda | **M5½** | **Sekcija A** (A1–A4) | ✅ **Gotovo** |

Od sada **ne pišeš** novu viziju, pitch, core loop ni scope osim ako nešto **svjesno mijenjaš** nakon playtesta (tada ažuriraj samo dotični doc + `otvorena-pitanja`). **Veliki docs refactor nije potreban** — samo sync uz kod.

### Kodiranje — **M8 / D0** (sada)

| Pitanje | Odgovor |
|---------|---------|
| **Do čega kodiram?** | **D0** (pre-launch) — funkcionalnost ✅, pa polish (D0-P) + monetizacija prod (D0-M) |
| **Što je gotovo?** | M6 greybox ✅ · M7 slice ✅ · D0 Blok A/B gameplay+sadržaj (većina) · D0-F F0–F4 ✅ |
| **Što slijedi?** | Bug lista → fix → 5-min playtest → **D0-P** (SFX, art, Settings) → D0-M → Play internal |
| **Je li ovo “verzija 1”?** | Još ne — v1 = D0 ✅ + Play naknada. Store listing draft već postoji (D4). |

```
M5½ docs ✅ → M6 ✅ → M7 ✅ → M8 D0-F ✅ → D0-P / D0-M → Play launch
                                         ↑ TI SI OVDJE
```

### Kada **nastaviti pisati** dokumentaciju (sljedeće runde)

| # | Kada (trigger) | Milestone | Checkpoint | Što ažurirati |
|---|----------------|-----------|------------|---------------|
| 1 | **Nakon M6 playtesta** | M6 | **B3** | ✅ urađeno |
| 2 | **Tijekom M7** | M7 | C1–C3 | ✅ urađeno (ekonomija, UI sitnice) |
| 3 | **Nakon M7 playtesta** | M7 | **C** exit | ✅ / po potrebi scope |
| 4 | **Prije store objave** | M8 | **Sekcija D** | store listing, ASO, screenshot plan (D4 draft ✅) |
| 5 | **Tjedno** (5 min) | — | — | `otvorena-pitanja` pregled |

**Pravilo:** dok traje D0 → uglavnom **kod + playtest**, docs samo sync. Nova ideja? Prvo `scope-i-granice` + pillari — ako nije IN, ne kodiraj.

### ⚠️ Scope guard (agent + ti)

Ako ti ili agent predložite nešto **izvan tablice “Scope po milestoneu”** u [[scope-i-granice|scope-i-granice]], agent **mora** ispisati upozorenje `⚠️ SCOPE` i ne nastaviti kod bez tvoje potvrde.

Cursor rule: `.cursor/rules/scope-guard.mdc`

**Ti možeš pitati:** “Je li ovo u scopeu?” — agent provjerava CHECKPOINT + milestone + OUT listu.

### Pregled cijelog puta

| Faza | Tip rada | Milestone | Checkpoint | Trajanje (okvirno) |
|------|----------|-----------|------------|-------------------|
| Planiranje | 📝 dokumentacija | M0–M5½ | A | ✅ gotovo |
| Greybox | 💻 prvi kod | M6 | B | ✅ gotovo |
| Ažuriranje | 📝 kratko | — | B3 | ✅ gotovo |
| Vertical slice | 💻 drugi kod | M7 | C | ✅ gotovo (C4 iPhone build još otvoren) |
| **Launch prep** | **📝 + 💻** | **M8** | **D** | **D0-F ✅ → D0-P / D0-M → Play** |

## Android-first — zašto i kako

**Jedna igra, jedan Godot projekt** — ne pišemo dvije verzije. Razlika je samo u **exportu** na kraju.

| Faza | Android | iOS |
|------|---------|-----|
| M6 greybox | ✅ svaki dan | ❌ preskoči |
| M7 slice | ✅ emulator + Android tel. | ⚠️ tek kad loop radi (Mac/CI) |
| Launch | ✅ Play prvi | ✅ App Store nakon |

**Ne radi oba paralelno na startu** — iOS s Windowsa ne možeš buildati; paralelno bi gubio vrijeme. Prvo dokazati loop na Androidu, pa **isti projekt** exportati na iOS.

## Tvoj setup (HP Windows + uređaji)

```
┌─────────────────┐     export APK      ┌──────────────────────┐
│  HP Laptop      │ ──────────────────► │ 1. Android emulator   │  ← svaki dan
│  Windows        │                     │ 2. Stariji Android tel│  ← kad imaš
│  Godot 4 editor │                     └──────────────────────┘
└────────┬────────┘
         │ isti projekt, export IPA (M7+)
         │ ⚠️ samo Mac ili cloud CI
         ▼
┌─────────────────┐                     ┌──────────────────────┐
│  Mac (kasnije)  │ ──────────────────► │  iPhone (tvoj)       │
└─────────────────┘                     └──────────────────────┘
```

| Korak | Gdje | Kada |
|-------|------|------|
| Dnevni dev | HP + Godot | uvijek |
| Brzi test | **Android emulator** | svaka sesija M6+ |
| Fizički Android | Stariji telefon (USB debug) | kad nabaviš — test performansi |
| iOS na iPhoneu | Mac/CI → IPA | **M7 (CHECKPOINT C4)** |
| Store | Play prvi, App Store drugi | Launch |

---

## Kako koristiti ovaj fajl

1. Nađi **prvu neoznačenu** stavku u aktivnoj sekciji (**D**).
2. Radi **jednu** stavku po sesiji (ili jednu malu grupu).
3. Označi `[x]` kad je gotovo u ovom fajlu + u ciljnom `.md`.
4. Ažuriraj `zadnje_azurirano` u frontmatteru.
5. Aktivna sekcija = **D** — ne vraćaj se na A/B osim bugfixa u starom kodu.

---

## Sekcija A — Dokumentacija detalji (PRIJE koda)

**Cilj:** Nijedan kritični doc ne smije biti prazan TBD kad otvoriš Godot.

### A1 — Vizija i dizajn (jezgro)

- [x] [[../01-vision/pitch|pitch]]
- [x] [[../01-vision/koncept|koncept]]
- [x] [[../01-vision/ciljana-publika|ciljana-publika]]
- [x] [[../01-vision/design-pillars|design-pillars]]
- [x] [[../01-vision/konkurencija-i-inspiracija|konkurencija]]
- [x] [[../02-design/core-loop|core-loop]]
- [x] [[../02-design/mehanike/_index|mehanike]] (3 fajla)
- [x] [[../02-design/progresija|progresija]]
- [x] [[../02-design/kontrole-i-input|kontrole-i-input]]
- [x] [[../02-design/gdd-overview|gdd-overview]] — executive index
- [x] [[../02-design/monetizacija|monetizacija]] — ads + IAP detalji
- [x] [[../02-design/ekonomija|ekonomija]] — valute, sinkovi, brojke draft

### A2 — Iskustvo i sadržaj

- [x] [[../03-content/svijet-i-lore|svijet-i-lore]]
- [x] [[../02-design/spec-vertical-slice|spec-vertical-slice]] (stari ui-ux arhiviran)
- [x] [[../04-experience/art-direction|art-direction]]
- [x] [[../04-experience/audio-direction|audio-direction]]
- [x] [[../04-experience/pristupacnost|pristupacnost]] — minimalni standardi
- [x] [[../03-content/likovi/_index|likovi]] — Pip + Mochi kartice
- [x] [[../03-content/nivoi/_index|nivoi]] — run level struktura (1–100)

### A3 — Tehničko i produkcija

- [x] [[engine-odluka|engine-odluka]]
- [x] [[platforme|platforme]] — uklj. Windows + iPhone workflow
- [x] [[scope-i-granice|scope-i-granice]]
- [x] [[arhitektura|arhitektura]] — Godot scene tree moduli
- [x] [[performanse|performanse]] — FPS, RAM ciljevi
- [x] [[rizici|rizici]] — top rizici + mitigacija
- [x] [[testiranje|testiranje]] — QA plan za greybox
- [x] [[../07-meta/glossary|glossary]] — run, session, merge termini

### A4 — Gate provjera (ponovno)

- [x] [[../00-home|00-home]] DoD 7/7
- [x] Svi A1–A3 checkboxovi gore = `[x]`
- [x] Nema kritičnih TBD u monetizacija / ekonomija / arhitektura

**Exit Sekcija A:** ✅ **2026-06-30** — dopušten `game/` folder kad kreneš M6.

---

## B0 — zatvoreno ✅ (2026-07-03)

- **Mood board** — `ref-01-lane-runner.png`, `ref-02-merge-camp.png` + [[../07-meta/reference/images/README|images/README]]
- **Privacy email** — `mergemeadow.support@gmail.com` u [[../05-technical/privacy-policy-draft|privacy-policy-draft]]
- **Narativ** OUT v1 · **ekonomija-balans.csv** predložak (ranije)

---

## Sekcija B — M6 Greybox (Godot prototip)

**Preduvjet:** Sekcija A ✅  
**Cilj:** Lane run igriv 60–90 s, placeholder art, Android APK na HP-u.

### B1 — Projekt setup

- [x] Instalirati **Godot 4.7** na HP Windows — pokretanje: `scripts/godot-open.bat` ([[../05-technical/godot-dev-setup|godot-dev-setup]])
- [x] Instalirati **Android Studio** (samo za SDK + emulator, ne za kod)
- [x] Kreirati AVD emulator — **Pixel_4** ([[../05-technical/platforme#Android emulator (HP)|platforme]])
- [x] Kreirati `game/` Godot projekt (portrait 1080×1920)
- [x] Git init + `.gitignore` za Godot (repo: `merge-meadow`)
- [x] Android export template + prvi debug APK na emulatoru (test: `Documents\new-game-projecttt`; export za `game/` — jednom u editoru)

### B2 — Lane run (prva mehanika)

- [x] Scena: Player + 3 lanea + auto-scroll
- [x] Swipe L/R input
- [x] Spawn orbova + jedna prepreka
- [x] Kraj runa → placeholder loot broj
- [x] 50% loot na fail
- [x] Start dugme + READY/RUNNING/ENDED state (jasan start/kraj) — nakon 1. playtesta
- [x] Fix: `loot_overlay` tip `CanvasLayer` (bug #1, `godot/greske-katalog`)

> **Godot kod:** prije izmjena u `game/` vidi [[../05-technical/godot/_index|Godot priručnik]].

### B3 — Playtest greybox

- [x] 5 min igre — editor + `godot-watch` (emulator preskočen, System UI freeze)
- [x] Bilješke u [[../07-meta/changelog|changelog]]
- [x] Odluka lanea: **3 fiksna lanea + tween 0.12 s**; fluid swerve → otvoreno M7 ako treba

**Exit M6:** ✅ greybox feel potvrđen u editoru (APK/vanjski feedback opcionalno kasnije).

---

## Sekcija C — M7 Vertical slice

**Preduvjet:** M6 ✅

> **Source of truth za slice:** [[../02-design/spec-vertical-slice|spec-vertical-slice]] (ponašanje po ekranu + DoD) i [[../02-design/ekonomija-brojevi|ekonomija-brojevi]] (sve konstante). **Prije kodiranja mehanike otvori spec — kod prati spec.**

### C1 — Kompletan loop (greybox → polish)

- [x] Loot ekran (×2 rewarded placeholder, revive, retry, kamp)
- [x] Kamp: merge 2→1 (min 2 tiera)
- [x] 1 upgrade linija (magnet)
- [x] Main menu → Play → run → loot → kamp → Play
- [x] Tutorial hint (prvi launch — main menu + run banner)
- [x] **Revive fix** — revive sada NASTAVLJA run (ne dira loot); Double+Revive više ne skaču broj

### C1½ — Build order (spec-driven, mali koraci)

> Svaki korak: otvori spec → kodiraj → headless smoke → 5 min test → `[x]`. Jedan korac po sesiji.

- [x] **Odluka: save na disk?** — **minimalni JSON v1** u M7 (`user://player_save.json`); F8.7 proširi
- [x] **Balans pass 1** — RUN **60 s** post-tutorial; spawn/magnet bez promjene ([[../02-design/ekonomija-brojevi|brojevi]] § pass 1)
- [x] **Fail/finish feedback** — loot ekran: boja trake/naslova + `X → Y` na failu
- [x] Prelazak na **C2 art pass** kad loop feel potvrđen

### C2 — Art pass (slice scope)

> **Operativni vodič:** [[../04-experience/ui-i-art-alati|ui-i-art-alati]] — flat cartoon; Krita/Figma (Pip) + Kenney flat UI.

- [x] Flat cartoon pickupe + pastel lane (art-direction paleta) — lane: `lane_background.png` Figma
- [x] Flat UI ikone (min set) — Kenney `game-icons` → `game/assets/ui/kenney/`
- [x] Pip flat cartoon sprite — **Figma Make** → `game/assets/sprites/pip_idle.svg`

### C3 — Monetizacija (test integracija)

- [x] AdMob rewarded test (test ad unit) — `AdManager` stub + plugin hook
- [x] IAP stub / test purchase flow (Android) — `IAPManager` + `shop_screen`

### C4 — iOS na iPhoneu

- [x] iOS export pipeline — `export_presets.cfg` + `.github/workflows/ios-xcode-export.yml` + [[../05-technical/godot/ios-export|ios-export]]
- [ ] Build na tvoj iPhone (TestFlight ili dev install) — **zahtijeva Mac ili GHA artifact**
- [ ] Test: run + merge na stvarnom uređaju

**Exit M7:** Vanjski playtester igra 5 min bez vođenja.

---

## Sekcija D — Launch prep (nakon M7)

> **Plan objave (2026-07-11):** [[troskovi-launcha|troskovi-launcha]] — **Faza 1** polish + sve v1 ideje (**0 USD**) → **Faza 2** Play **25 USD** (Android only) → **Faza 3** updates dok se ne prikupi **~99 USD** → **Faza 4** iOS.

### D0 — Pre-launch polish (prije store naknade)

> Detaljna tablica: [[d0-prelaunch-checklist|d0-prelaunch-checklist]] (postotak iz 2026-07-11 više nije operativan — lista je usklađena 2026-10-17).

**Blok A — gameplay (scope IN)**
- [x] Merge **T3** (MAX_MERGE_TIER 3)
- [x] Upgrade **množitelj** (Loot Boost Lv 4, ×2.0)
- [x] Spawn pool — **Seed Almanac** (lifetime unlock + coins shortcut)
- [x] **Kamp A+C** — vreća bez limita (cap 40 uklonjen 2026-10-16), auto-plant, Keep oslobađa gredicu, +3 gredice na max Sprinkler
- [x] **Daily chest** u kampu

**Blok B — sadržaj**
- [ ] Spriteovi sjemena/cvijeta po tipu (min 7, cilj 10) — 🟡 7 procedural — **odgođeno u D0-P**
- [x] **Mochi** ljubimac unlock (cosmetic) — kamp Lv 2, companion picker, run skin
- [x] **Dnevnik** kolekcije (zaseban ekran) — Bloom Album, 📖 u kampu, NEW badge
- [x] Shop: kozmetika + **booster consumables**

### D0-F — Funkcionalnost prije polish (sada)

> Redoslijed promijenjen 2026-07-29. Detaljna matrica: [[d0-functional-audit|d0-functional-audit]].

- [x] **F0** — CHECKPOINT + checklist + audit doc
- [x] **F1** — funkcionalni audit (meta hub matrica + headless smokes)
- [x] **F2** — debug (meta hub page slot, run HUD guard, settings placeholder)
- [x] **F3** — spec sync (`spec-vertical-slice` → merge arena + meta hub)
- [x] **F4** — balans pass 1 (`balance_snapshot`, `ekonomija-brojevi`); **5-min playtest** → ručno

**Blok C — polish** *(nakon F4 + playtest — D0-P)*
- [x] **SFX** (pickup, merge, fail) — ZVUK-01 (2026-10-14): svi događaji + muzika, privremena sinteza; pravi zvuk otvoren ([[../04-experience/audio-direction|audio-direction]])
- [ ] Art pass (kamp biljke, splash/branding) — splash + ikona ✅ 2026-10-23; kamp biljke i feature graphic ostaju
- [x] Settings ekran (sound, restore) — SET-01 (2026-10-12) + zvuk na busovima (ZVUK-01)
- [x] `DEBUG_DEV_RESOURCES` off (`game_state_debug.gd`, već `false`)
- [x] Release AAB test — 2026-10-23: `scripts/android-export.ps1 -Preset Aab`, potpisan upload ključem ([[launch-prep-izvjestaj|launch-prep-izvjestaj]])
- [ ] Vanjski playtest 5 min (M7 exit ponovno)

**Blok D — monetizacija production** *(nakon F4 — D0-M)*
- [x] **LAUNCH-PREP** — release build, Billing, AdMob + UMP, ikona, nacrti Play formi (2026-10-23) → [[launch-prep-izvjestaj|launch-prep-izvjestaj]]; korisnikov dio: [[launch-prep-plan|launch-prep-plan]]
- [x] Poing **AdMob + Billing** plugin na Androidu (2026-10-23; Billing netestiran s Playom — nema proizvoda)
- [ ] Production ad unit ID-evi (ne test) — čeka AdMob nalog; blok PRODUCTION IDS u `monetization_config.gd`
- [x] **ADS-ONLY** — v1 samo s reklamama: stvari koje su se plaćale pravim novcem kupuju se coinima (isti grant), Remove Ads / Starter Pack sakriveni, Billing plugin isključen, Play forme bez kupovina (2026-10-27) → [[ads-only-coini-izvjestaj|ads-only-coini-izvjestaj]]
- [x] **RET-01** brojač aktivnosti + ekran „Your stats" u release buildu (2026-10-26) → [[procjena-igraca|procjena-igraca]]
- [ ] **RET-01** odluka o analitici za javni launch (§ 8) — mora biti u prvom produkcijskom buildu

**Već gotovo (D0)**
- [x] 100 run level konfiguracija — **D1a** JSON 1–10 + **D1b** curve 11–100 (`RunLevelLibrary`)
- [x] Endless mode — **D2 stub** main menu, Easy/Normal/Hard (Lv 20/50/85 base, spawn ×0.9), odvojeno od kampanje 1–100
- [x] Shop: remove ads + starter pack — **D3** `IAPManager` billing hook, restore, shop UI, interstitial respects `ads_removed`
- [x] EN store listing + screenshots — **D4** 8× PNG u `marketing/store/screenshots/`, copy u `store-listing-en.md`
- [ ] Google Play internal test — **Faza 2** (nakon D0 + **25 USD**)
- [ ] Google Play production launch — **Faza 2**
- [ ] App Store Connect (iOS) — **Faza 4** (nakon ~**99 USD** + iOS prilagođavanje)
- [ ] €50–100 CPI test kampanja — **Faza 3** (nakon Android launcha)

---

## Sljedeća akcija (sada)

**Sada radimo:** D0-P / playtest — CAMP-06 čeka playtest; cijeli hub je redizajniran, a 2026-09-24/28 su očišćeni Arena, Camp (pass 2), hub chrome (pass 2), Home polje sezone (pass 2 — livada kao stranica) i Home biranje + prelaz (v3)

**Nakon playtesta:** D0-P (SFX, art, Settings) → D0-M → Play internal

**Ne** plaćati Play Console dok D0 nije ✅.

### Aktivne trake (feature ID)

| ID | Status | Napomena | Link |
|----|--------|----------|------|
| ADS-ONLY | ✅ čeka playtest | v1 samo s reklamama (2026-10-26/27, na zahtjev; BiH nije Google Play merchant zemlja). `MonetizationConfig.IAP_ENABLED = false`, `coin_price` u `IAP_PRODUCTS`, `IAPManager.buy_with_coins` (provjere → `_try_spend_coins` → isti `_grant_product` → isti signali). Shop: Seasons · Looks · Boosters, dva tapa, pilula „Need N more coins" (i Looks); Home Premium tab s temama za coine (dva tapa); Camp kartica teme (dva tapa, toast); Ormar Sir Pip; Support / Settings Purchases / Ember skriveni; coin kupovina svira coins_spend. Cijene: Merge Hint 1500, Loot Burst 1000 (sim: 500 → casual Frost 37 % ranije), Sir Pip 3000, teme **10000** (drugi krug 2026-10-27; prije 3000 / 3500). Drugi krug: ★3 sjeme ×2, Shop header za 3 taba, CD brief `ads-only-cd-brief` (redizajn Shop tende, Home Free / Premium, coin pilule) — čeka CD. Billing plugin isključen → AAB bez `BILLING`. Testovi GUT `test_coin_offers` (12), smoke `coin_offers_smoke`, `iap_off_smoke` (skener „€ / $ / Restore / Purchase cancelled / billing"); Play tok u 8 smokeova kroz `iap_override = 1` | [[ads-only-coini-izvjestaj\|ads-only-coini-izvjestaj]] · [[../02-design/coin-ponude-simulacija\|coin-ponude-simulacija]] |
| RET-01 | ✅ čeka odluku o analitici | Procjena i mjerenje igrača (2026-10-26, na zahtjev). **U igri:** `ActivityLog` — lokalni brojač u saveu (ključ `activity`, bez SAVE_VERSION): dani 0–30 po lokalnom datumu (kao dnevni poklon), sesije (povratak poslije 5 min = nova), vrijeme igre (tick 30 s, najviše 90 s po koraku), runovi, najdalji level, dan tutorijala / Endlessa, prvi merge u sekundama igre; radi i u release buildu, ništa ne šalje, isključen u headlessu. Skriveni ekran „Your stats" (Settings → 5 dodira na verziju za 3 s): D1 / D3 / D7 / D14 / D30, prvih 14 dana, ukupno, napredak, **Copy** red `mm1` za kalkulator. **Docs:** protokol closed testa (ne podsjećati; statistika i anketa 15. dan ili kasnije) i playtest prvog iskustva u `testiranje.md`, poruke testerima u `play-console-sutra.md` § 7. **Simulator u danima** (`economy_sim.gd --day-min / --parts / --day-mins`, `sadrzaj-trajanje-simulacija.md`): kraj besplatnog sadržaja average ~64 / 47 / 27 / 18 dana, skilled ~48 / 34 / 21 / 13 (10 / 15 / 25 / 40 min dnevno), casual zapne na L15–20 → novi sadržaj do ~3. sedmice od launcha. **Kalkulator** `scripts/analytics/retention_forecast.py` (forecast / scenarios / cohort, Wilson interval). Provjereno u release APK-u na emulatoru. Usput nađeno: na telefonu X u Settingsu (Credits / stats) okine dvaput (`HubPressable`) — predložena zasebna sesija. **Čeka odluku:** analitika za javni launch (preporuka Aptabase dnevni sažetak bez ID-a). Testovi GUT `test_activity_log` (19), `test_game_state_save_migration` (+2), smoke `activity_stats_smoke` | [[procjena-igraca\|procjena-igraca]] · [[testiranje\|testiranje]] |
| BAL-01 | ✅ čeka playtest | Balans ekonomije, ciklus 1 (2026-10-21). Run: leveli 1–20 (`data/run_levels/levels.json`) rastu — 60 → 120 s, start 400 → 520 px/s, ubrzanje 2 → 3,5 % / 15 s, prepreke 6 → 30 %, parovi (dvije staze) od levela 6, više plijena; sjeme po rijetkosti (`RunBalance`, ★3 3–7 %). Endless: bez tajmera, stepenica 20 s, pun plijen, rekord po sezoni, otključan poslije levela 15 (privremeni izgled do CD-LVL-END). Cijene: sezone 2500 / 4500 / 6500 + 22 / 26 / 30 ★3, nadogradnje 100–800 C + 2–3 ★3, izgledi 800–2500, dnevni poklon 75 C + 5, combo 5 (30/dan), Starter Pack 1000 C, magnet 40 + 55/nivo. Simulator `economy_sim.gd`, telemetrija `RunTelemetry` (debug), `economy_balance_smoke`, GUT `test_run_balance`. Poslije playtesta: odluke po preporuci (magnet ostaje), magnet krug alfa 0,32, pred kraj levela nema spawna koji ne stiže do Pipa, „Claim" pilula izbačena (sanduk skače i klima se) | [[../02-design/balans-ciklus-1-izvjestaj\|balans-ciklus-1-izvjestaj]] |
| CD-LVL-END | ✅ čeka playtest | Paket `design_handoff_leveli_endless` u igri (2026-10-22): 4 pojasa (kamenovi, zastavice, LevelChip), najava levela, nalet, par kao jedan predmet, cilj na kraju levela (8 sezona), Endless dugme (zaključano „N / 15", otključavanje 15 → 16, rekord), HUD sat · Pace · Best, nova stepenica, novi rekord, pauza / R5 „All yours", spreman sanduk bez „Claim". D (formacije) nije rađeno. `levels_endless_smoke`, bench, snimke `leveli-endless-izvjestaj-ref/` | [[../04-experience/design-drafts/leveli-endless-izvjestaj\|leveli-endless-izvjestaj]] · [[../04-experience/design-drafts/leveli-endless-cd-brief\|brief]] |
| HOME-24 | ✅ | Home v3 runda 4 — imena cvijeća 34/900, prelom 220, 12 ispod diska; kolone 276 / 516 / 756 istim korakom 240 u oba reda, drugi red na 560. Najmanji razmak između imena 36,4 px (bilo −46); pravilo za sadržaj: novo ime mora stati u 2 reda ≤ 234 px. Ime nosi svaki vidljivi cvijet (odstupanje od paketa, koji ga daje samo nenađenima) | `design_handoff_home_v3/` · [[../04-experience/design-drafts/home-v3-izvjestaj\|izvještaj § Runda 4]] |
| HOME-23 | ✅ | Home v3 runda 3 — kartica nosi svih šest cvjetova (dva reda po tri, `ROSTER6`); zaključana besplatna sezona je pod velom `#E3D9CC` s jednim katancem 120, a „Unlock" ga diže disk po disk (300 ms, +40 ms). `LOCK_BADGE` gore desno ukinut; premium bez vela (kupuje se, ne otključava) | `design_handoff_home_v3/` · [[../04-experience/design-drafts/home-v3-izvjestaj\|izvještaj § Runda 3]] |
| HOME-22 | ✅ | Home v3 — biranje u dva taba (Free / Premium), kartica 1032 × 1160 = minijatura livade (tri trake), strelice + swipe, tačke samo indikator, Play 520 × 180 u 3 koraka („Back" + disk); prelaz 560 / 440 ms jedan tween: ime, Pip i Play su JEDAN objekat, predaja kartica → livada 0 px razlike; dock tokena i Play 836 obrisani | `design_handoff_home_v3/` · [[../04-experience/design-drafts/home-v3-izvjestaj\|izvještaj]] |
| HOME-21 | ✅ | Home polje sezone pass 2 — livada je cijela stranica (bila 606 od 1633), chrome pluta: Gift + korpa 180 gore lijevo (isti okvir), nadogradnje gore desno u sheetu, donji red `Seasons 236 · Play 432 · Endless 236`; 13 mjesta u 4 dubine i Pip van keepouta | `design_handoff_home_field_v2/` |
| CHROME-02 | ✅ | Hub chrome pass 2 — dusk plum `#2A2233` umjesto zelene, footer 144 px bez teksta (dodir 216 × 141), treći chip broji cvijeće umjesto dijamanata; nove ikone coina / sjemena / cvijeta kroz cijelu igru (i pickup u runu); stranica 1597 → 1633 bez promjene kartica | `design_handoff_hub_chrome_v2/` |
| CAMP-07 | ✅ | Camp pass 2 — bez „Next free season", „Details", podnaslova tabova, Merge prečice, „1 coin each" i „hold 10/s"; kartica sezone 276, sekcija fiksno 1253 uz nju, art u karticama +45 %, Trade i Unlock 300 × 120 | `design_handoff_camp_v2/` |
| SEZ-SYNC | ✅ čeka playtest | Sezone između sekcija (2026-10-12, prijava „Home i polje jedna sezona, Arena druga; Camp link ne primijeni; kupljena premium sezona kasnije nije moja"). Uzroci: hub u debug buildu na svakom otvaranju (start, povratak iz runa) zvao `debug_playtest_two_free()` — brisao kupljene sezone, vraćao free na S1 + S2, aktivnu na Frost; kupovina u Shopu mijenjala aktivnu dok je polje na Homeu ostajalo na staroj; Shop „Play" kupljene sezone samo pomjerao fokus kartice. Popravljeno + `season_sync_smoke.gd` (12 koraka, sve sekcije + run + povratak + reload + Dev reset u Settingsu; pada na starom kodu). Dopuna 2026-10-12: Dev „Reset seasons" vraća prvu sezonu svuda (ranije samo Home) | `season_sync_smoke.gd` |
| SET-01 | ✅ čeka playtest | Paket `design_handoff_settings_fixes/` u igri (2026-10-12): Album = prozor + 4 neprozirna poklopca (ništa ne viri van okvira, zlatni i obični); Classic Pip kartica skina s „Free", nekupljeni Pip skinovi pod velom; Starter Pack i „All set" s Pipom iz riga; pun Settings ekran (Music / SFX na busovima, Vibration, Reduce motion, Restore 4 stanja, Remove Ads status, Privacy choices / policy, Contact, Credits, verzija, Dev sekcija u debug buildu), gradi se unaprijed u pozadini. Testovi `album_window_smoke`, `settings_screen_smoke` | [[../04-experience/design-drafts/ispravke-settings-izvjestaj\|ispravke-settings-izvjestaj]] |
| FIX-1016 | ✅ čeka playtest | Ispravke poslije playtesta (2026-10-16): Settings z 200 (Arena do z 60 je virila), zupčanik zaključan dok traje runda u Areni; gnijezdo munchera u centru polja (540, 795), lov uvijek na trenutno najbližu sjemenku (zamjena kad je bliža ≥ 24 px); Camp link kartica poslije svih besplatnih nudi plaćenu sezonu sa cijenom (IAP, burst, Home band „paid"), nestaje kad je sve kupljeno; rezervisano ★3 zadnje u Campu; Home polje raste po `star3_grown` (ne vene prodajom / otključavanjem; stari save iz Albuma); čip „0 / 13 grown" uklonjen; vreća sjemena bez limita (plijen se tiho gubio na 40, #41); Shop štand z 20 (Pip do z 15, oznaka 16, #40); nadogradnje na polju smiju potrošiti i Kept ★3 (bile blokirane kad je sve cvijeće čekalo sljedeću sezonu), sheet to javlja. Loot Boost na ukupno sjeme (ranije po tipu — 5 različitih × 1,25 = 5, sada 6), revive bez duplog boosta, zlatni pečat „Loot Boost ×… · N twins" na kraju runa; Twin Seeds provjeren (8 % po nivou, #42). Home polje puno kad je svih 6 tipova sezone ★3 (prag 1 na svih 13 mjesta; ranije 1 / 5 / 10). Testovi `fixes_1016_smoke` (novi), `loot_boost_twin_smoke` (novi), `camp_season_link_smoke` (plaćena sezona), `home_field_overlay_smoke`, `season_kit_all_smoke`, GUT seed bag + loot boost | [[../04-experience/design-drafts/ispravke-1016-izvjestaj\|ispravke-1016-izvjestaj]] |
| CD-RUN-PICK | ✅ čeka playtest | Paket `design_handoff_run_pickups/` u igri (2026-10-20). (A) Pickupi u runu: idle iz jednog atlasa (novčić se okreće, sadnica se njiše, ★2 / ★3 oreol + iskrice), let magnetom do Pipa, dodir po događaju (coin n1–n5, sjeme ★1–★3, twin +2), 4 Pip reakcije s prioritetom, pilula „+1 / +2" do čipa (broj raste po dolasku), magnet od tačkica 18°/s. (B) Camp kartica plaćene sezone: recept „camp" za 4 plaćene, ink po sezoni, PREMIUM + 6 cvjetova, stanja price / buying / burst / failed. FPS: CPU efekata 3,3 → 0,35 ms najgore (ispečene staze, bazen), GPU A/B jednako ili brže. Testovi `run_pickups_smoke`, `camp_paid_card_smoke` | [[../04-experience/design-drafts/run-pickups-izvjestaj\|run-pickups-izvjestaj]] |
| CD-LVL-PATH | ✅ čeka playtest | Paket `design_handoff_level_path/` u igri (2026-10-20). Play u polju sezone otvara put (4900 px, 20 kamenova, recept `kits[id].path` za 8 sezona, Pip na trenutnom levelu, skok ≤ 1 s poslije pređenog levela, complete sa zastavicom i trakom); isto Play pokreće run, ‹ Field nazad. Nagrade 5/10/15/20 (2/4/6/10 ★3 sezone + 200/400/600/1000) — popup + let u bar; zaključana → toast; badge na Play i kartici. Napredak po sezoni (`LevelPathDomain`, save `season_levels`); stari `run_level` → aktivna sezona; težina N ista u svim sezonama. FPS: put = polje ili brži. Test `level_path_smoke` | [[../04-experience/design-drafts/level-path-izvjestaj\|level-path-izvjestaj]] |
| FIX-1012 | ✅ čeka playtest | Sitnice poslije playtesta (2026-10-12): oblačić tutoriala u Areni iznad pilule sjemena; red sažetka Albuma izbačen (prozor 54 px gore); druga noga Pipa u three_q (`foot_R` z 3); bez starog crteža zeca u pregledu | changelog 2026-10-12 |
| CD-MUNCH-PIP | ✅ čeka playtest | Paket `design_handoff_muncher_premium_pip/` u igri (2026-10-14). **Nibbs, seed-mole** = novi muncher: `MuncherRig` (3 pogleda, 16 klipova, atlas 1024 × 840 u pozadini), krtičnjak (usna preko njega samo dok je u rupi), baner „Muncher's awake!" + m_awake pri prvom buđenju u sesiji, smjer lova (bočno / ← / naprijed / nazad), „hmph" kad mu sjemenka pobjegne, led s pucanjem u zadnjih 0,25 s; pravila ista. Muncher košta 2–4 draw poziva (bilo 44–51). **Sir Pip · Meadow Knight** = premium skin: zamjena dijelova + dodaci u 5 pogleda, ogrtač na sloju Skin, t3 / cilj / potpis / idle detalj, Shop premium kartica (€3.99, SKU `pip_knight`), Ormar „Premium" (nekupljen → tap u Shop). Testovi `muncher_rig_smoke`, `premium_pip_smoke` | [[../04-experience/design-drafts/muncher-premium-pip-izvjestaj\|muncher-premium-pip-izvjestaj]] |
| MUZ-SEZ | ✅ čeka playtest | Muzika po sezoni (2026-10-14, na zahtjev; **drugi ciklus 2026-10-15** „da nijedna sezona ne zvuči kao druga"): 8 sezona × 3 nivoa = 24 teme (`<sezona>_home` / `_arena` / `_run`). Svaka sezona je žanr — country / bluegrass, valcer / polka, japanski festival, keltski folk / jig, uspavanka / swing, bossa / calypso, elektronika, modalni world (7/8) — s vlastitim instrumentima (101, 0 dijeljenih), ritmom melodije, harmonijom, tempom / mjerom / sobom i osjećajem izvođenja. Sličnost se mjeri: `music_report.py` (zvuk, `--structure`, `--melody`, `--harmony`). `Sfx.music_level()` + `AudioManager.play_level()` biraju temu aktivne sezone i pretope kad se sezona promijeni. Generator `theory.py` / `instruments.py` / `fx.py` / `season_songs.py` / `music_gen.py` (`--lint` harmonije). OGG mono 24 kHz ≈ 5 MB | [[../04-experience/muzika-sezone\|muzika-sezone]] |
| ZVUK-01 | ✅ čeka playtest | Zvuk cijele igre (2026-10-14, na zahtjev): `AudioManager` (autoload) + katalog `data/audio/sounds.json`; 59 efekata (62 fajla) i 3 teme — `meadow` (hub, loot), `arena`, `run` (ambijent) — **privremeni**, sintetizovani (`scripts/audio/sfx_gen.py`, `music_gen.py`); pravi zvuk = isti naziv + `source: real` + `--measure`, bez koda. Spojeno svuda (dugmad preko `tap_sfx`, tabovi, swipe, Home, Shop, IAP, Ormar, Settings, Camp, Arena + combo lanac, Nibbs, Pip `sfx:` događaji, run, loot, Album, pop-upovi); crossfade + pamćenje mjesta teme, duck na velike trenutke, pauza za reklamu / pozadinu, haptika (dozvola VIBRATE uključena). Miks: kategorije −23 … −15, muzika ~−25 / −28 LUFS u igri, limiter −1 dB, slider glasnoće kvadratna kriva. Učitavanje u threadu, efekti po jedan (#37). `audio_smoke` | [[../04-experience/zvuk-izvjestaj\|zvuk-izvjestaj]] · [[../04-experience/audio-direction\|audio-direction]] · [[../04-experience/design-drafts/muzika-brief\|muzika-brief]] |
| RUN-HUD-02 | ✅ čeka playtest | Run HUD v2 u igri (2026-10-09, paket `design_handoff_run_hud_v2/`): header u jednom redu (Level / „Endless · X" / „Practice" · coini · sjemenke · pauza; bez Pip portreta, prstena, sekundi, dijamant čipa i korpe); traka napretka lijevo (x 24–140, Pip se penje, peach ispod 17 %, zastavica + mint prsten na 100 %, sakrivena u Endlessu); dijamanti izbačeni iz igre (pickup, pop, wallet, Pip animacije, ikona — Premium tab / dugme bez ikone); nagradni grm na šavu 405 / 675 (prvi posle 6 s, pa 8–12 s, jedan na ekranu, nije u tutorial runu 1, ±300 px bez prepreka; pokupi se samo prelazom, magnet ga ignoriše; 60 % 3–5 coina / 40 % 1–2 sjemena; burst ≤ 11 spriteova iz poola). Bench: frame isti kao prije (3,58 / 3,56 ms) | [[../04-experience/design-drafts/run-hud-v2-izvjestaj\|run-hud-v2-izvjestaj]] · `run_hud_v2_smoke.gd` · `run_hud_perf_bench.gd` |
| PERF-02 | ✅ čeka playtest | FPS pregled cijele igre (2026-10-09, na zahtjev „Arena šteka"): `perf_suite_bench.gd` (30 scenarija, `MM_ROOT=1 MM_VSYNC=1` = kao igra). Arena merge bez preskočenih frejmova (osnova sjemenke iz teksture, prsten u svom sloju, korpa samo na promjenu, odgođen save, livada i muncher u slojevima); Home kartica bez cvijeća 1313 → 79 draw poziva (isprekidan rub jednim pozivom); Camp ulaz bez gradnje grida; hub: stranice van ekrana zamrznute, ostale stranice u pozadinskom threadu; Journal budžet 3 ms. Nastavak 2026-10-10: start huba bez zastoja od ~0,5 s (Shop atlasi u threadu, Shop gradi karticu po frejmu), prvi Pip po pogledu ~2 ms (animacije na zahtjev), cvijeće sezona u pozadini (prvi prikaz sezone na Home 47–75 → 5–26 ms), Pip u runu 45 → 4 draw poziva, swipe sezona na Homeu bez save-a na disk i bez ponovnog crtanja livade. Ostaje: Arena boot u pozadini (~32 ms jednom), mjerenje na telefonu | [[../05-technical/performanse\|performanse]] · `perf_suite_bench.gd` |
| CAMP-08 | ✅ čeka playtest | Camp v3 u igri (2026-10-08, paket `design_handoff_camp_v3/`): stranica `#4E3F5A`, mergeable oznaka (stog ≥ 4) i linija ispod Tradea, vrata Arene od 50 mergeable sjemenki (brojač `N / 50` + modal), nadogradnje po sezoni (2 ★3 te sezone iznad Kept + coini 10/20/40/60) s trećim boostom Twin Seeds (8 % × nivo), korpa samo za sjeme skupljeno u runu. Playtest popravke: modal više nije iza brojača, Pip u Areni ima cijele uši, pločica nadogradnji ima 3 reda, ime Twin Seeds se vidi, ime sezone centrirano u pilulici boje sezone, ikona oznake importovana, natpis „Nothing has grown…" izbačen. Provjera paketa (2026-10-09): modal vrata se zatvara i tapom van / Back (paket: „tap scrim / dugme / back"), pilula `N / 50` prelazi u mint za 0,18 s i ima tvrdu sjenu, razmak 10 px | [[../04-experience/design-drafts/camp-v3-izvjestaj\|camp-v3-izvjestaj]] · `camp_v3_capture.gd` |
| PIP-01 | ✅ čeka playtest | Pip redizajn (2026-10-07, paket `design_handoff_pip/`): cutout rig umjesto `pip_idle.svg` recolora. Tri skina (Classic / Blossom 250 / Sky 200, isti ID), 77 animacija, atlas po skinu ≤ 1024. `UiPip` na kartici 230, polju 190 (hop 95 px/s, sniff, sleep, apply), Areni 150 (combo / T3), runu odozgo 150 (galop + traka / pickup / pad 0,46 s), HUD 88 (crop), Shop pozi + potpis, Ormar `stage_idle`/`stage_hop`. Tap eskalacija i sezonski rekviziti još nisu. Brief: [[../04-experience/design-drafts/pip-cd-brief\|pip-cd-brief]]. `pip_rig_smoke` | `design_handoff_pip/` · [[../04-experience/design-drafts/pip-izvjestaj\|izvještaj]] |
| SEZ-KIT-2 | ✅ čeka playtest | Sezone faza 2 (2026-10-06, paket `design_handoff_seasons/` faza 2, v1.1 track SEZ-01): svih 8 sezona su mjesta na svim površinama — SeasonBackdrop dobija row / poly / ellipse / line / ridge.up+tilt / shape-listu; Frost, Lantern, Amber, Coral, Starfall i Ember crtaju polje i karticu, Coral / Starfall / Ember Shop panoramu, Frost / Lantern / Amber Camp karticu (recept `camp`, tekst #3D3D33, tvrda sjena 0 8 0); generički ambijent (6 vrsta kretanja, ≤ 24, isti kod polje + run); njihanje cvijeća ±3°, Pip spava → ambijent 0,35, njuši → čestice oblika ambijenta; run: materijal staze iz kita (pruge / kamenčići / daske / trag sanki) + 16 prepreka; 108 cvjetova + 12 prepreka. Obrisani SeasonTheme tint, trake (kartica, polje, Shop), SEASON_HUE. Kontrast iz geometrije = CD samoprovjera; JS = Godot (GUT). Odlučeno 2026-10-06: polje T3, Reduce motion gasi i ambijent, raster 256 i C2PA ostaju. Čeka: cijene (iznosi + Play Console proizvodi + Billing plugin 3.x uz izmjenu `_try_init_billing`) | [[../04-experience/design-drafts/seasons-faza2-izvjestaj\|izvještaj faze 2]] · `season_kit_all_smoke` · GUT `test_season_kit_parity` |
| SEZ-KIT-1 | ✅ čeka playtest | Sezone faza 1 (2026-10-05, paket `design_handoff_seasons/`, v1.1 track SEZ-01): Season Kit kao red podataka (`data/seasons/seasons_kit.json`) + jedan renderer `SeasonBackdrop` za polje, karticu izbora (isti recept, prelaz bez šava) i Shop panoramu; CB i MW mjesta, ambijent ≤ 18, Pip poze (njuši/spava), naklon + polen, rast cvijeta; 36 crteža cvijeća (raster 256); run tlo/staza/daljina/blizina/ambijent + 2 prepreke po sezoni; Arena spaja kit. Ostalih 6 sezona nepromijenjeno; popravke playtesta 2026-10-05; CD faza 2 (svih 6 preostalih) — brief §12.0 | [[../04-experience/design-drafts/seasons-izvjestaj\|izvještaj]] · [[../04-experience/design-drafts/seasons-cd-brief\|brief §10]] |
| WARDROBE-01 | ✅ čeka playtest | Ormar u igri — pločica **Looks** (876, 1265, 180) na polju sezone otvara sheet 1326 (pozornica 1032 × 300 → tabovi slotova → mreža 4 × 240 → Close). Jedan tap = izbor, Default u svakom slotu, zatvaranje (Close / scrim / povlačenje > 160 / back) = snimanje, pa Pip skoči u novom skinu + prsten ili toast. Katalog je `game/data/cosmetics/cosmetics.json` (5 id / slot / cijena isti); Pip skin = recolor pravog `pip_idle.svg` svuda (polje, kartica sezone, Arena, Camp, run + HUD, Shop), PipDraw samo rezerva. `PIP_BASE_ZONE` → (151, 1306, 614, 131). `wardrobe_smoke` (8 slotova / demoN 1·5·30 samo podacima) + `wardrobe_capture.gd` + GUT `test_game_state_cosmetics` | `design_handoff_wardrobe/` · [[../04-experience/design-drafts/wardrobe-cd-brief\|brief §11]] |
| ARENA-05 | ✅ čeka playtest | Arena v2 u igri — muncher je ljubičasta gusjenica (glava r 50 + 3 segmenta koji prate put, 6 stanja pozom, gnijezdo s prednjim rubom, kocka leda), vreća je pletena korpa za piknik 300 × 280 s gomilom do 12 cvjetova (brojač ostaje), sjemenka ima SeedBase prsten 4 px, **svih 8 livada** crta se iz recepta po aktivnoj sezoni (0 PNG, R2 raspored, bujnost 0 → 4), combo živi na polju (×N, talas, svjetlo sezone, naklon od 4, zlatno + novčić na 5). Mehanika i ekonomija netaknute. `arena_v2_fields_smoke` + `arena_capture.gd` | `design_handoff_arena_v2/` · [[../04-experience/design-drafts/merge-arena-cd-brief\|brief §11–§12]] |
| ARENA-04 | ✅ | Prostor umjesto HUD-a — uklonjeni daily/stash pilule, traka s porukama, combo pilula i Done; polje 1553 px, muncher gore, vreća i Pip dolje; sesija se gasi kad polje ostane prazno | — |
| POPUP-01 | ✅ čeka playtest | Pop-upovi v1 u igri (2026-10-02, paket `design_handoff_popups/`): jedan sistem od pet vrsta — modal (pločica s naslovom na rubu, ton bojom), sheet (ručka, povlačenje > 160 zatvara), oblačić (rep u 4 smjera), toast (ink pilula s diskom, red od 2), leteća poruka (broj s ink obrubom) + PopupButton/AdButton (132 / reklama 120) i RewardChip. Svih 22 ID-a prebačeno: kraj runa preko zamrznutog kadra s plijenom kao chipovima i statusom reklame na dugmetu, pauza „If you quit" ½, „Time!"/„Ouch!", poklon s chipovima i „Back in Nh", korpa kao 3 × 2 pločice, nadogradnje s dugmetom-cijenom, „You need more seeds!" kao mreža pločica (bug jednog reda popravljen), svi toastovi i leteće poruke ujednačeni | [[../04-experience/design-drafts/popups-cd-brief\|brief]] |
| SHOP-02 | ✅ čeka playtest | Shop v2 u igri (2026-10-02, paket `design_handoff_shop_v2/`): četiri taba kao četiri ScrollContainera (Seasons prvi i podrazumijevani, tab pamti skrol), pergament `#FBEDD7` umjesto `#2E4733`, jedno dugme s cijenom (8 stanja, coin kupovina u dva tapa), 6 pravih portreta ≥ 148 po sezoni, Looks iz `cosmetics.json`. Merge Hint jednokratan + `MergeHintMark` na najbližoj istoj sjemenki u Areni; Loot Burst +5 ★3 za sljedeću besplatnu sezonu, nestaje kad je sve otključano; Starter Pack 7 dana (100 coina + Pip Blossom + 5 × 10), istekao = veo + katanac. Stara zaliha boostera migrira | [[../04-experience/design-drafts/shop-v2-cd-brief\|brief]] |
| SHOP | ✅ | Redizajn 1 dizajn — 4 sekcije u skrolu + sticky chipovi, pregled kozmetike „Now / With it“, kupovina za coine u 2 tapa, poruke na kartici, season kartice s rosterom | `design_handoff_shop/` |
| JOURNAL | ✅ | Bloom Album 1a — red 1032×200, poglavlja sezona, NEW cijelu posjetu, auto-scroll, Golden Album frame | `design_handoff_journal/` |
| HOME-20 | ✅ | Home Season Stage v2 — 1:1 po `SeasonStage.dc.html`: kartica 1032×1100, dock 1080×222, Play 836×180 + Gift 180; Nunito; razlika vs dizajn 2–3 % piksela | `design_handoff_home_v2/` |
| HOME-19b | 🔲 | Polje sezone još nije 1:1 s `design_handoff_home_field/` (kartice nadogradnji, korpa); redoslijed popravljen | `design_handoff_home_field/` |
| HOME-19 | ✅ | Home field CD — livada 1032×605, 13 mjesta, korpa 180, picker sheet, Seasons pill, Play 656×176 | `design_handoff_home_field/` |
| CAMP-06 | 🔲 čeka playtest | thirds fill, link symmetry, chip name+count; + swipe scroll bez trake, Trade 460px ×3, tap=1 / hold=6/s | — |
| CAMP-05 | ✅ (dio superseded CAMP-06) | camp row — two-free fixture, chip red+filled stars | — |
| CAMP-04 | ✅ arhivirano (superseded CAMP-05→06) | camp read | [[_archive/plan-prompts-camp-read\|freeze]] · [[../03-content/_archive/ideje-camp-read\|hub]] |
| CAMP-03 | ✅ | kamp link — Seeds/Flowers naslov, next-lock → Home | — |
| CAMP-02 | ✅ (A superseded CAMP3-A) | Seeds cliff | — |
| CAMP-01 | ✅ | Flowers upgrade | — |
| HOME-18 | ✅ | poster fit — 🔒+ime sredina, divider, coin 40/flower 92 | — |
| HOME-17 | ✅ arhivirano (superseded HOME-18) | unlock poster | [[_archive/plan-prompts-home-unlock-poster\|freeze]] · [[../03-content/_archive/ideje-home-unlock-poster\|hub]] |
| HOME-16 | ✅ | Meadow field — daily overlay, basket no-scroll | — |
| HOME-15 | ✅ | Meadow dock — DOCK P0–D | — |
| HOME-14 | ✅ | Meadow life — LIFE P0–D | — |
| HOME-13 | ✅ | Meadow chrome — CHROME P0, A–E | — |
| HOME-12 | ✅ | Meadow — MEADOW P0, A–C | — |
| HOME-11 | ✅ | BARFIT-A — gate niže ispod 🔒+ime | — |
| HOME-10 | ✅ | LOCKFLOW A–B — locked poster 500/20 gold | — |
| HOME-09 | ✅ | CARDFIT A–B — Amber gate | — |
| HOME-08 | ✅ | INCARD-B — Unlock gate u CenterSlot | — |
| HOME-04–07 | ✅ | PAID/GLIDE/FOCUS/UNLOCK | — |
| SEED-01 | ✅ | seed pool — jedan type_id | — |
| ARENA-01–03 | ✅ | combo/feel, leftover ÷4, sort+vacuum | — |
| Bug-006–032 | ✅ | zatvoreno | [[d0-functional-audit\|audit]] |

Star-3 unlock hub ✅ — Journal deferred swipe; free unlock 500c + 20 ★3 prethodne sezone; scroll 280.

## Povezano

- [[plan-arhitektura-refaktor|plan-arhitektura-refaktor]] — kod refaktor nakon CAMP-06 (GameState split, GUT, naming) — **gotov**, vidi doc
- [[_archive/RADIONICA-razvoj|RADIONICA-razvoj]] (arhivirano) — faze 0–7, historijski zapis
- [[_archive/milestone-i|milestone-i]] (arhivirano) — stari milestone sažetak
- [[_archive/roadmap|roadmap]] (arhivirano)
- [[_archive/plan-prompts-home-unlock-poster|HOME-17 unlock poster]] (arhivirano)
- [[../03-content/_archive/ideje-home-unlock-poster|HOME-17 hub]] (arhivirano)
- [[_archive/plan-prompts-camp-read|CAMP-04 camp read]] (arhivirano)
- [[../03-content/_archive/ideje-camp-read|CAMP-04 hub]] (arhivirano)
- [[../00-home|Home]]

> Scratch idea/prompt fajlovi za HOME-01…18 (osim arhiviranog HOME-17), ARENA-01…03, CAMP-01…06 (osim arhiviranog CAMP-04), SEZ-01 i SEED-01 su uklonjeni 2026-09-08 — svi featuri iz gornje tablice su isporučeni; `git log` ima puni trag ako ikad zatreba.
