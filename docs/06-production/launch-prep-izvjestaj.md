---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, launch, izvjestaj, billing, admob, release]
povezano:
  - launch-prep-plan
  - play-console-sutra
  - CHECKPOINT
  - d0-prelaunch-checklist
ai_sažetak: "Izvještaj LAUNCH-PREP 2026-10-23: release build + keystore, Billing 3.3.0, AdMob + UMP + blagi interstitial, politika, ikone/splash, Play papiri — šta je gotovo, šta nije testirano, šta čeka korisnika (BiH nije merchant zemlja)."
---

# LAUNCH-PREP — izvještaj (2026-10-23)

> Roditelj: [[06-production/_index|06-production]] · Plan: [[launch-prep-plan|launch-prep-plan]] · Papiri: [[play-console-sutra|play-console-sutra]]

## Najvažnije prvo

1. **Bosna i Hercegovina nije podržana zemlja za Google Play merchant.** Igru možeš objaviti i zarađivati od reklama, ali **in-app kupovine ne možeš prodavati** s payments profilom iz BiH. Treba odluka: v1 samo s reklamama, ili payments profil u podržanoj zemlji (HR, RS, MK…). Detalji i opcije: [[play-console-sutra|play-console-sutra]] § 0.
2. **Target API 36** je obavezan za nove aplikacije od 31. 8. 2026 — preseti su već na 36.
3. **Upload keystore** je napravljen: `game/export_credentials/merge_meadow_upload.keystore`, lozinka u `docs/00-personal/credentials.local.md`. **Napravi kopiju van laptopa.** (Play App Signing drži pravi ključ; izgubljen upload ključ se može resetovati, ali to traje.)

## Šta je gotovo

| Blok | Šta | Commit |
|------|-----|--------|
| A | Gradle release build: preseti Debug APK / Release APK / **Release AAB**, min SDK 24, target SDK 36, Internet + Access network state; stari ravni `game/android/` obrisan; `scripts/android-export.ps1`; upload keystore (gitignore) | `2b4eef0` |
| B | **GodotGooglePlayBilling 3.3.0**: pravi Play tok (katalog → kupovina → acknowledge/consume → grant), reconnect, pending, restore, „već kupljeno", timeout; nikad besplatno na Androidu s pluginom; 2 skrivena buga popravljena (#54 ClassDB, #57 PackedStringArray); GUT 11 testova | `f96f0fa` |
| C | **Poing AdMob 5.1.0 + UMP**: forma pristanka (EEA/UK/CH), rewarded (nagrada samo kad je odgledano), interstitial s **blagim ograničenjem** (1 na 3 Retry-ja, 3 min, ne u tutorijalu / prvoj sesiji, Remove Ads gasi), *Privacy choices*, dev dugmad; test ID-evi + prazan blok PRODUCTION IDS; politika privatnosti usklađena; GUT 9 testova | `21c2600` |
| D | Ikone iz Pip portreta (launcher, adaptivna fg/bg/mono, store 512) + splash značka | `6e0c843` |
| E | `play-console-sutra.md` — Data safety, IARC, ciljna publika, Advertising ID, 9 proizvoda, closed test + poziv EN/BS, payments profil, AdMob GDPR poruka, app-ads.txt | `aac07fe` |
| F | Provjera (ispod), docs, `smoke-all.ps1` | (zadnji commit) |

## Provjera

| Šta | Rezultat |
|-----|----------|
| GUT (`scripts/gut-run.ps1`) | **107 / 107** (od toga novo: 11 billing, 9 AdMob) |
| Smoke (`scripts/smoke-all.ps1`, 4 radnika, svaki svoj APPDATA) | **79 / 79** (prvi run 77: `shop_smoke` piše „shop smoke OK" — runner popravljen; `arena_leftover_d_smoke` je čitao tvoj dev prekidač „Test seeds: off" — radnici sad dobiju default) |
| Release AAB | **68,6 MB**, `BUILD SUCCESSFUL`, potpisan upload ključem (`CN=Merge Meadow`); `aapt2`: targetSdk 36, minSdk 24, `BILLING`, `AD_ID`, INTERNET, AdMob `APPLICATION_ID` = test ID |
| Release APK na emulatoru `Pixel_4_API33` | Release APK: start, Home, tutorijal — bez crasha; billing bez Play Storea → „unavailable", bez crasha. Debug Gradle APK: run → loot ekran s Double / Revive → **Googleova test rewarded reklama** → „Reward granted" → Revive vraća Pipa u run |

## Popravljeno tokom provjere na emulatoru

- **Prvi tap na Double:** „No ad now". Preload reklame se nije ponavljao poslije neuspjeha, a novo učitavanje je na zagušenom emulatoru trajalo ~18 s (limit 8 s). Sad: neuspjeli preload se ponavlja za 30 s, a zahtjev koji stigne dok se reklama već učitava dobije isti rezultat (ranije je ostajao bez odgovora). Razlog neuspjeha ide u log.
- **Billing na uređaju bez Play billinga** (kod 3) više ne pokušava vezu svakih 60 s zauvijek — opet tek na resume ili kad igrač tapne kupovinu.
- **Export:** visio je jer Gradle daemon drži Godotov izlaz (#59), falio je tačan NDK za strip (#59), a ponovna instalacija templatea je znala oboriti export (#55). Sve u `android-export.ps1`.
- Dozvole `WAKE_LOCK`, `FOREGROUND_SERVICE`, `READ_BASIC_PHONE_STATE` dodaju Googleove biblioteke (AdMob / WorkManager). Ako Play Console pita za foreground service tipove: igra ih sama ne koristi.

## Šta NIJE testirano

- **Prava Play kupovina** — u Play Consoleu još nema proizvoda (ni naloga). Tok je pokriven GUT testovima s lažnim klijentom koji šalje iste tipove kao plugin. Test plan s license testerima: [[../05-technical/godot/iap-billing-setup|iap-billing-setup]] § 5.
- **UMP forma** — prikazuje se samo kad u AdMob konzoli postoji objavljena GDPR poruka (tvoj korak). Dev prekidač „Consent as EU" je spreman za test.
- **Interstitial na uređaju** — pacer traži 3 Retry-ja, 3 min i ne-prvu sesiju; pokriven GUT-om (`test_ad_manager`), na emulatoru nije odgledan.
- **Double Loot nagrada na uređaju** — reklama je prikazana preko Revive (isti kod, drugi placement); Double sam vidio samo kao „No ad now" prije popravke preloada.
- **Pravi telefon** — FPS / baterija s AdMob SDK-om nisu mjereni.
- **Produkcijske reklame** — dok nema tvojih ID-eva, release koristi Googleove test jedinice (export skripta upozori).

## Šta čeka tebe

Lista s kvadratićima: [[launch-prep-plan|launch-prep-plan]] § Šta radim ja. Ukratko: odluka o IAP-u (BiH) → Play nalog → AdMob nalog (+ GDPR poruka) → pošalji mi AdMob ID-eve → forme iz `play-console-sutra.md` → feature graphic → 12+ testera, 14 dana.

## Odluke donesene usput

- **Interstitial:** blago ograničenje (tvoj izbor 2026-10-23).
- **AdMob ID-evi u gitu:** nisu tajne (vide se u svakom APK-u) — `sigurnost.md` ažuriran; tajne su samo keystore i lozinka.
- **Reklame samo za sve uzraste (G)** — kako je `privacy-policy-draft.md` već preporučio (crtani stil privlači i mlađe).
- **app-ads.txt** nije u `privacy/`: crawler ga traži na `alemsahinovicfax-stack.github.io/app-ads.txt` (GitHub user site), ne u projektnom folderu.
- **Pending kupovina** koristi postojeću „Pending" poruku u Shopu (bez novog UI-ja); kupovina koja stigne kasnije dobije normalan toast.

## Povezano

- [[../05-technical/godot/admob-setup|admob-setup]] · [[../05-technical/godot/iap-billing-setup|iap-billing-setup]]
- [[../05-technical/godot/greske-katalog|greske-katalog]] #54–#58
- [[d0-prelaunch-checklist|d0-prelaunch-checklist]]
