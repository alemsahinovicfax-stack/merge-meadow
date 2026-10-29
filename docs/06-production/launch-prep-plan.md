---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, launch, play, billing, admob]
povezano:
  - CHECKPOINT
  - d0-prelaunch-checklist
  - iap-billing-setup
  - admob-setup
  - privacy-policy-draft
ai_sažetak: "LAUNCH-PREP (2026-10-23): gotov /plan prompt za sve što agent može uraditi bez Play Console/AdMob naloga (release build, Billing, AdMob+UMP, ikona, nacrti Play formi) + lista koraka koje korisnik radi sam."
---

# Launch prep — plan (LAUNCH-PREP)

> Roditelj: [[06-production/_index|06-production]] · Checklist: [[d0-prelaunch-checklist|d0-prelaunch-checklist]] · Dogovoreno 2026-10-23 — agent ovo **predlaže na početku sljedeće sesije**.

## Prompt za agenta (kopiraj kao poruku)

```
/plan Pripremi Merge Meadow za Google Play launch: sve što se može uraditi bez mog Play Console / AdMob naloga. Radi u game/ i docs/, poštuj CLAUDE.md (OpenGL skripte, Godot GUI samo jednom na kraju, headless smoke-test prije "gotovo").

BLOK A — Release build
1. Instaliraj Android build template, uključi Gradle build u export_presets.cfg, postavi target SDK na nivo koji Google Play trenutno traži za nove aplikacije (provjeri na webu) i razuman min SDK.
2. Napravi UPLOAD keystore (Play App Signing drži pravi ključ). Lozinku generiši sam i upiši u docs/00-personal/credentials.local.md. Provjeri da su keystore i lozinke u .gitignore i da NIŠTA od toga ne ide u git.
3. Release preset za AAB (i APK varijantu za emulator). Napravi AAB i potvrdi da se build završi bez greške.

BLOK B — Google Play Billing
4. Skini GodotGooglePlayBilling 3.3.0 sa službenog GitHub releasea u game/addons/ (dozvoljavam ovo preuzimanje) i uključi ga.
5. Prepravi iap_manager.gd (_try_init_billing, purchase) po README-u plugina 3.x: connect → query products → query purchases → purchase → acknowledge/consume (booster_loot_burst je consumable) → grant. Dodaj i pending kupovine, restore i grešku pri gubitku konekcije. Stub mora ostati na desktopu/editoru.
6. GUT testovi za tok kupovine s mock klijentom. Ažuriraj iap-billing-setup.md.

BLOK C — AdMob + UMP pristanak
7. Nađi AdMob plugin koji radi s Godot 4.7 (Poing Studios ili službeni); preuzimanje sa službenog GitHuba dozvoljavam. Poveži ad_manager.gd: rewarded (×2 loot, revive) i interstitial, uz poštovanje ads_removed.
8. Ostavi Googleove TEST ad ID-eve. Napravi jedno mjesto (config) za produkcijske ID-eve i AdMob App ID, s jasnim TODO-om za mene.
9. UMP pristanak na startu (EEA/UK/CH) i dugme "Privacy choices" u Settingsu. Uskladi s privacy/index.html; ako se nešto u politici ne poklapa, popravi tekst.
10. Pripremi app-ads.txt šablon u privacy/ (GitHub Pages), ali ga ne objavljuj dok ne dam publisher ID.

BLOK D — Ikona i splash
11. Adaptivna ikona (foreground/background) + 512×512 store ikona iz Pip asseta, branded splash. Importuj assete i commitaj .import fajlove.

BLOK E — Papiri za Play Console (samo nacrti u docs/06-production/)
12. Napravi play-console-sutra.md s odgovorima koje samo prepišem: Data safety (šta AdMob skuplja), IARC content rating upitnik, ciljna publika (13+), lista IAP proizvoda (ID, tip, cijena), tekst za closed test i poziv testerima (12 ljudi, 14 dana). Dodaj i korake za payments profile, uz napomenu da provjerim je li BiH podržana zemlja za merchant.

BLOK F — Provjera i dokumentacija
13. Headless smoke-testovi + svi GUT testovi, release export, pokretanje APK-a na emulatoru Pixel_4_API33 s test reklamama (billing će tamo biti nedostupan; potvrdi da ne puca).
14. Ažuriraj d0-prelaunch-checklist.md (statusi su iz jula), CHECKPOINT i changelog. Napiši kratak izvještaj na bosanskom: šta je gotovo, šta nije testirano, šta čeka mene.
15. Commit nakon svakog bloka (poruke na engleskom), push na master na kraju.

NE RADI: ne otvaraj naloge, ne unosi plaćanja, ne mijenjaj cijene ni gameplay/balans, ne diraj zvuk.
```

## Šta radim ja (korisnik)

> Gotovi odgovori za sve forme: [[play-console-sutra|play-console-sutra]].

- [x] **Odluka: BiH nije Google Play merchant zemlja** (provjereno 2026-10-23) — **2026-10-26: v1 samo s reklamama.** `IAP_ENABLED = false`, stvari koje su se plaćale pravim novcem kupuju se coinima, Remove Ads i Starter Pack sakriveni, Billing plugin isključen. Detalji: `play-console-sutra.md` § 0, [[ads-only-coini-izvjestaj|ads-only-coini-izvjestaj]]
- [ ] **Play Console nalog** (25 USD) + verifikacija identiteta
- [ ] **Payments profile** — ne treba za v1; tek kad se kupovine vraćaju (zemlja riješena); banka + porez (W-8BEN / W-8BEN-E)
- [ ] **AdMob nalog** — app + 2 ad unita (rewarded, interstitial); agentu dati App ID, ad unit ID-eve i publisher ID (nisu tajne)
- [ ] **AdMob → Privacy & messaging → GDPR poruka** (bez nje nema UMP forme ni u EU)
- [ ] **app-ads.txt** — GitHub repo `alemsahinovicfax-stack.github.io` (user site) ili vlastita domena; agent upiše publisher ID (`docs/06-production/app-ads/`)
- [ ] **Backup keystorea** (`game/export_credentials/merge_meadow_upload.keystore`) + lozinke (`credentials.local.md`) van laptopa (USB / cloud)
- [ ] Play Console: aplikacija, Advertising ID deklaracija, Data safety, IARC (varijanta bez kupovina), ciljna publika 13+, internal test (AAB: `game/export/android/merge_meadow.aab`); IAP proizvodi i license testeri tek kad se kupovine vrate
- [x] **Feature graphic 1024×500** za store listing — ✅ 2026-10-29: Claude Design round 3 u `marketing/store/` (feature graphic svijetla + tamna, 8 screenshotova, nova ikona u igri i store, promo 1200×630; izvještaj `docs/04-experience/design-drafts/store-assets-izvjestaj.md`). 2026-10-28: CD brief za cijeli store paket (feature graphic, 8 screenshotova s hookom, ikona, promo 1200×630) u `docs/04-experience/design-drafts/store-assets-cd-brief.md`, kadrovi `store-assets-ref/` (snima `game/scripts/dev/store_capture.gd`)
- [ ] Skupiti **12 testera** (bolje 15–20) za closed test od 14 dana — tekst poziva EN/BS u `play-console-sutra.md` § 7
- [ ] Test na pravom telefonu + otvoreni playtestovi iz CHECKPOINT-a

Kad AdMob ID-evi stignu: agent ih upisuje u config i objavljuje `app-ads.txt` (par minuta).
