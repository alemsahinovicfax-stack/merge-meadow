---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, store, marketing, play-store, claude-design, launch]
povezano:
  - store-listing-en
  - store-screenshots
  - play-console-sutra
  - launch-prep-plan
  - art-direction
  - design-pillars
  - CHECKPOINT
ai_sažetak: "Brief za Claude Design: kompletan Play Store paket za Merge Meadow — feature graphic 1024×500, 8 screenshotova 1080×1920 s hook naslovima i okvirom, doradu ikone 512, promo baner 1200×630 i stil za GitHub stranicu. Sirovi kadrovi iz igre su u store-assets-ref/ (17 PNG, snimio store_capture.gd)."
---

# Play Store paket · Claude Design brief

> **Status 2026-10-28: spremno za slanje.** Kadrovi: `store-assets-ref/` (s01–s17). Prompt je u §9.
>
> **Prije slanja: commitaj i pushaj na `master`.** CD čita repo samo po tačnim putanjama s mastera.

Igra je spremna za Google Play: potpisan AAB i v1 samo s reklamama. Fale **materijali za store**. To je prvo što igrač vidi, i od toga zavisi hoće li uopšte instalirati igru. Traži se **profesionalan, uređen paket s jasnim hookom**, a ne goli screenshoti.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | §1–§7 + slike u `store-assets-ref/` | Šta je igra, šta je hook, šta se isporučuje |
| **Ti** | **§9** | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §6, §8 | Export, provjera dimenzija, upload checklist |

## 1. Igra u 3 rečenice (činjenice — ne izmišljati)

- **Run:** Pip (tirkizni zec) trči kroz 3 staze, skuplja coine i sjeme, izbjegava prepreke. Level traje 60–120 s.
- **Merge:** sjeme iz runova se istrese u **Arenu**, gdje se prevlače dvije iste sjemenke: T1 + T1 → T2 → T3 (kristalni cvijet). Muncher (krtica) pokušava pojesti sjeme, a T3 ga zamrzne.
- **Grow:** ★3 cvijeće raste na **Home polju** tvoje sezone i otključava sljedeću livadu.

Brojevi koje smiješ koristiti:

| Činjenica | Vrijednost |
|---|---|
| Sezone (livade) na launchu | **7** (Country Bloom, Frost Orchard, Lantern Meadow, Amber Canopy + teme Moonlit Warren, Coral Tide Garden, Starfall Glade) |
| Leveli | **20 po sezoni** = 140 |
| Endless | otvara se poslije levela 15 u sezoni, rekord po sezoni |
| Cvijeće | 6 vrsta po sezoni, ★1–★3; Bloom Album |
| Kupovine | **nema kupovina pravim novcem.** Sve se zarađuje igrom (teme, Sir Pip, boosteri za coine) |
| Reklame | samo opcione (Double loot, Revive) + rijetki interstitial |
| Energija / tajmeri | **nema** |

**Ne koristiti:** „100 levels", „Easy / Normal / Hard", „Remove Ads", „Starter Pack", „pets" (množina — postoji samo Pip), cijene u €.

## 2. Hook (traži se tvoj prijedlog — ovo je polazište)

Igrač u Play Storeu ima **~3 sekunde**: ikona + feature graphic + prva 2 screenshota. Hook mora u tom vremenu reći **šta radiš i zašto je ugodno**.

Kandidati (EN, store je engleski):

| # | Hook | Ugao |
|---|---|---|
| A | **Run. Merge. Bloom.** | tri glagola = cijela petlja |
| B | **Every run grows your meadow** | napredak koji se vidi |
| C | **Cozy runs, crystal blooms** | ugođaj + nagrada |
| D | **No energy. No timers. Just bloom.** | Fair F2P kao prednost (Pillar 2) |

Predloži **jedan glavni hook** (feature graphic + screenshot 1) i **naslove za ostalih 7 screenshotova** (≤ 4 riječi, veliki, čitljivi na sličici od 150 px širine). Ton: topao, razigran, bez uzvičnika u svakom redu i bez „BEST GAME EVER" stila.

## 3. Šta se traži

### A. Feature graphic — 1024 × 500 (OBAVEZNO)

- Format: PNG ili JPG, **bez prozirnosti**, ≤ 15 MB.
- Sadržaj: Pip u pokretu + nagovještaj merga (kristalni ★3 cvijet) + livada. **Naziv „Merge Meadow"** i hook.
- **Sigurna zona:** važni elementi u centralnih ~80 %, jer Play reže ivice na nekim mjestima (kartica, TV). Tekst ne ide uz ivicu.
- Mora se čitati i umanjen (mobilni prikaz ~360 × 176).
- Dvije varijante za izbor: **svijetla** (Country Bloom, dan) i **tamna** (Starfall Glade / Moonlit Warren, noć).

### B. Screenshoti telefona — 8 × 1080 × 1920 (portrait)

- PNG ili JPG 24-bit, bez prozirnosti.
- **Pravilo Googlea:** screenshot mora prikazivati **stvarnu igru**. Zato se kadrovi iz `store-assets-ref/` ne crtaju ponovo i ne mijenjaju (ne dodavati stvari kojih nema u igri). Smiješ:
  - staviti kadar u okvir (telefon ili zaobljeni rub), malo ga smanjiti, nagnuti;
  - dodati **naslov / hook traku** gore ili dolje;
  - dodati pozadinu u boji sezone, oblačiće, strelice, izreze („zoom" na detalj iz istog kadra);
  - spojiti 2 kadra u jedan screenshot (npr. „sjeme → kristalni cvijet").
- **Prva dva su najvažnija** (vide se u rezultatima pretrage bez otvaranja stranice).
- Predloženi redoslijed (možeš promijeniti, objasni zašto):

| # | Kadar(ovi) | Poruka |
|---|---|---|
| 1 | `s01_run_country_bloom` | Run — trči, skupljaj (hook) |
| 2 | `s12_arena_merge_drag` (+ `s11_arena_full`) | Merge — prevuci isto na isto |
| 3 | `s09_field_country_bloom` | Tvoje polje raste |
| 4 | `s02_run_starfall_glade` + `s04_run_moonlit_warren` + `s03_run_frost_orchard` | 7 livada, svaka svoj svijet |
| 5 | `s10_level_path_country_bloom` | 140 levela, nagrade na putu |
| 6 | `s05_endless_new_best_amber` | Endless — oboriš rekord |
| 7 | `s06_loot_country_bloom` / `s13_arena_combo` | Nagrade poslije svakog runa |
| 8 | `s16_shop_seasons` / `s17_shop_looks` / `s15_journal` | Teme i izgled za coine, bez kupovina |

Ako je kadar loš za store (npr. `s15_journal` je napola prazan, `s14_camp` / `s07` / `s08` su meni ekrani), slobodno ga ne koristi.

### C. Ikona — 512 × 512 (dorada, opcionalno)

- Danas: `game/assets/branding/icon_512.png` (+ adaptive `icon_adaptive_fg_432.png` / `icon_adaptive_bg_432.png`, mono `icon_mono_432.png`), izvor `game/icon.svg`.
- Provjeri da se čita na 48 px i u krugu / zaobljenom kvadratu (Android maske). Predloži doradu **samo ako je jasno bolja** (veći Pip, jači kontrast prema bijeloj / tamnoj pozadini Play Storea). Ako ostaje, napiši zašto.
- Play: 32-bit PNG, 512 × 512, ≤ 1 MB, **bez** zaobljenja i sjene (Google ih dodaje sam).

### D. Promo baner — 1200 × 630 (za link / GitHub stranicu / poziv testerima)

Isti motiv kao feature graphic, prilagođen formatu. Koristi se za poruku testerima (closed test, 12+ ljudi) i za `app-ads.txt` / politiku privatnosti stranicu.

### E. (opcionalno) Tablet screenshoti

Nisu obavezni. Ako ostane vremena: 2 kadra 1920 × 1200 ili 7" / 10" sa istim okvirom (kadar telefona centriran na pozadini sezone).

## 4. Stil (FIKSNO)

| Pravilo | Vrijednost |
|---|---|
| Stil igre | flat, pastel, tamni obrub ink `#2D3436`, ravne boje, jedna tvrda sjena (vidi `docs/04-experience/art-direction.md`) |
| Font | font igre (Nunito / isti kao u UI — vidi `game/assets/fonts/`) |
| Boje | iz sezona (Country Bloom zelena / krem, Starfall ljubičasta / noćna); akcent peach `#FFB88C` (Play dugme), coin žuta |
| Za store materijale smiješ | blagi gradijent pozadine i mekšu sjenu **samo u okviru oko kadra** (nije igra) — ali paket mora izgledati kao ista igra |
| Pip | iz rig dijelova `game/assets/pip/` (parts, overlays) ili `splash_pip.png`; ne mijenjati izgled lika |
| Tekst | engleski; kratko; ≥ 72 px visina slova na 1080 širini |

## 5. Ograničenja Play Storea (provjeri u README)

| Stvar | Pravilo |
|---|---|
| Screenshoti | 2–8 po uređaju; strana 320–3840 px; omjer najviše 2 : 1 |
| Feature graphic | tačno 1024 × 500 |
| Ikona | tačno 512 × 512 |
| Zabranjeno | rang / nagrade koje nemamo („#1", „Editor's choice"), cijene, „free" u velikom naslovu kao glavni hook, lažni UI, Google / Android logo, sadržaj kojeg nema u igri |
| Tekst na slici | dozvoljen, ali ne više od ~20 % površine screenshota |

## 6. Isporuka

- `design_handoff_store_assets/` (zip), unutra:
  - `feature_graphic_light_1024x500.png`, `feature_graphic_dark_1024x500.png`
  - `screenshots/01_….png` … `08_….png` (1080 × 1920)
  - `icon_512.png` (+ adaptive fg / bg 432 ako mijenjaš ikonu)
  - `promo_1200x630.png`
  - **izvorni fajlovi** (HTML / SVG) za kasnije izmjene teksta (npr. kad izađe Ember Fen → „8 meadows")
  - `README.md`: izabrani hook i zašto, naslovi svih screenshotova, fontovi, boje, šta je preuzeto iz kojeg `s##` kadra, provjera §5
- Pregled u pregledaču: sve slike na jednoj stranici + **simulacija Play Store prikaza** (rezultat pretrage: ikona + prva 3 screenshota; stranica igre: feature graphic + traka screenshotova), svijetla i tamna tema Play Storea.

## 7. Šta NE treba

- Video (promo video je opcion — kasnije).
- Novi likovi, novi ekrani, novi UI u igri.
- Tekst opisa igre (agent ga ažurira u `docs/06-production/store-listing-en.md`) — ali ako hook traži drugačiji short description (80 znakova), predloži ga u README.

## 8. Agent poslije (prenos)

1. Raspakovati u `marketing/store/` (feature graphic, screenshots, icon, promo).
2. Provjeriti dimenzije i alfa kanal (Play odbija feature graphic s prozirnošću).
3. Ako se ikona mijenja → `game/assets/branding/` + `make_app_icons.gd` + novi AAB.
4. Ažurirati `store-listing-en.md` (hook, short description) i `store-screenshots.md` (novi redoslijed); `store_capture.gd` ponovo snima kadrove kad se igra promijeni.

## 9. Prompt za Claude Design (copy-paste)

```
Hi! Merge Meadow is a cozy mobile game (Godot, Android) that is ready for Google Play. I need the full, professional Play Store asset package with a strong hook — this is what decides whether people install.

Please read, in this order (exact paths on master):
1. docs/04-experience/design-drafts/store-assets-cd-brief.md — the brief (facts about the game, hook candidates, deliverables, Play rules)
2. docs/04-experience/art-direction.md — visual style
3. Real in-game captures, 1080x1920 (use these, do not redraw gameplay):
   docs/04-experience/design-drafts/store-assets-ref/s01_run_country_bloom.png
   docs/04-experience/design-drafts/store-assets-ref/s02_run_starfall_glade.png
   docs/04-experience/design-drafts/store-assets-ref/s03_run_frost_orchard.png
   docs/04-experience/design-drafts/store-assets-ref/s04_run_moonlit_warren.png
   docs/04-experience/design-drafts/store-assets-ref/s05_endless_new_best_amber.png
   docs/04-experience/design-drafts/store-assets-ref/s06_loot_country_bloom.png
   docs/04-experience/design-drafts/store-assets-ref/s07_home_country_bloom.png
   docs/04-experience/design-drafts/store-assets-ref/s08_home_starfall_glade.png
   docs/04-experience/design-drafts/store-assets-ref/s09_field_country_bloom.png
   docs/04-experience/design-drafts/store-assets-ref/s10_level_path_country_bloom.png
   docs/04-experience/design-drafts/store-assets-ref/s11_arena_full.png
   docs/04-experience/design-drafts/store-assets-ref/s12_arena_merge_drag.png
   docs/04-experience/design-drafts/store-assets-ref/s13_arena_combo.png
   docs/04-experience/design-drafts/store-assets-ref/s14_camp.png
   docs/04-experience/design-drafts/store-assets-ref/s15_journal.png
   docs/04-experience/design-drafts/store-assets-ref/s16_shop_seasons.png
   docs/04-experience/design-drafts/store-assets-ref/s17_shop_looks.png
4. Brand assets: game/icon.svg, game/assets/branding/icon_512.png, game/assets/branding/icon_adaptive_fg_432.png, game/assets/branding/icon_adaptive_bg_432.png, game/assets/branding/splash_pip.png, game/assets/fonts/

Deliver (brief §3 and §6):
- feature graphic 1024x500, light and dark variant, no transparency, safe zone respected
- 8 phone screenshots 1080x1920: real captures in a frame + short big headline (≤4 words), first two carry the hook
- icon 512x512 review (improve only if clearly better, explain)
- promo banner 1200x630
- one preview page that simulates the Play Store (search result + store page, light and dark)
- design_handoff_store_assets.zip with PNGs, editable source files and a README (chosen hook and why, headlines, fonts, colors, which capture each screenshot uses, Play rules check from brief §5)

Rules: only real game content (Google policy), no prices, no "100 levels", no rankings or awards, no Remove Ads / Starter Pack (v1 has no purchases). Pick one main hook from brief §2 or propose a better one, and tell me why it fits.
```

## Povezano

- [[../../06-production/store-listing-en|store-listing-en]] — tekst opisa (ažurirati poslije CD-a)
- [[../../06-production/store-screenshots|store-screenshots]] — stari plan kadrova (zamijenjen ovim briefom)
- [[../../06-production/play-console-sutra|play-console-sutra]] — forme
- [[../art-direction|art-direction]]
- [[../../06-production/CHECKPOINT|CHECKPOINT]]
