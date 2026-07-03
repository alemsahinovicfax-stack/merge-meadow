---
status: draft
tags: [tehnicko, platforme]
---

# Platforme

## Sažetak

**Android-first** razvoj na HP Windowsu; **jedan Godot projekt** → kasnije export na iOS. Portrait, EN store, oba storea na launchu.

## Strategija razvoja (Android-first)

| Pitanje | Odgovor |
|---------|---------|
| Jedna igra ili dvije? | **Jedna** — isti `game/` folder |
| Razvijamo oba odjednom? | **Ne** — prvo Android dok loop ne radi |
| Kada iOS? | M7 (CHECKPOINT C4) — export istog projekta preko Maca/CI |
| Uloga iPhonea sad? | Čekanje — koristi se kad imaš iOS build |
| Uloga Androida? | **Primarni** — emulator svaki dan + stariji telefon za fizički test |

iOS i Android dijele ~95% koda u Godotu; razlike su export preset, safe area, store IAP/ads SDK setup.

## Target platforme

| Platforma | v1 launch | Min verzija | Napomena |
|-----------|-----------|-------------|----------|
| Android | ✅ Da | API 24 (Android 7.0+) | Primarni test uređaj / emulator |
| iOS | ✅ Da | iOS 15+ | Finalni build zahtijeva Mac ili cloud CI |

## Orijentacija

- **Portrait** — fiksno (vidi [[../02-design/kontrole-i-input|kontrole-i-input]])
- Landscape — OUT v1

## Store

| Store | Jezik | Monetizacija |
|-------|-------|--------------|
| Google Play | EN (primarno) | AdMob + Google Play Billing |
| App Store | EN (primarno) | AdMob + StoreKit IAP |

**Kategorija (draft):** Games → Casual / Puzzle  
**Age rating:** Everyone / 3+ (bez nasilja, cute tema)

## Permissions (minimalno)

| Permission | Razlog |
|------------|--------|
| Internet | Ads, IAP validacija |
| Vibrate (opcionalno) | Haptic feedback |

**Ne treba:** lokacija, kamera, kontakti, mikrofon.

## Tablet

- Phone layout scaled — **nema dedicated tablet UI u v1** (OUT)

## Dev okruženje (HP Windows + uređaji)

### Tvoj setup (potvrđeno)

| Komponenta | Status | Uloga |
|------------|--------|-------|
| HP laptop, Windows | ✅ | Godot editor, kod, Android APK export |
| Android emulator (AVD) | ✅ Pixel_4 | **Primarni test svaki dan** |
| Stariji Android telefon | — (opcionalno) | Nije potreban za M6 — emulator dovoljan |
| iPhone | ✅ imaš | iOS test u **M7** — ne blokira Android dev |

### Android emulator (HP)

**Preporuka:** Android Studio + jedan AVD — dovoljno za cijeli M6/M7 dok ne nabaviš Android telefon.

| Postavka | Vrijednost | Zašto |
|----------|------------|-------|
| Alat | [Android Studio](https://developer.android.com/studio) | SDK + AVD Manager |
| Uređaj | Pixel 4 (ili Pixel 5) | Standardni phone aspect |
| API level | **30** (Android 11) ili **28** (Android 9) | Blizu starijeg telefona |
| ABI | x86_64 | Brže na laptopu (ako CPU podržava HAXM/Hyper-V) |
| RAM emulatora | 2–3 GB | Ne ubij HP laptop |
| Grafika | Hardware - GLES 2.0 | Godot 2D friendly |

**Koraci (jednom):**
1. Instaliraj Android Studio → SDK Platform + Platform Tools
2. Device Manager → Create Virtual Device → Pixel 4 → API 30 x86_64
3. U Godot: Editor → Export → Android → podesi SDK putanje
4. Deploy: Run Project → odaberi emulator (ili `adb install` APK)

**Godot export na Windows:** Project → Install Android Build Template → Export APK → pokreni na emulatoru.

### Godot editor — HP AMD (obavezno)

Vulkan (default) **ne otvara projekte** na ovom laptopu. Uvijek:

- Skripta: `scripts/godot-open.bat` ili `scripts/godot-open.ps1`
- Flag: `--rendering-driver opengl3`
- Detalji: [[godot-dev-setup|godot-dev-setup]]

Novi projekti: renderer **Compatibility** (`gl_compatibility`).

**Kad nabaviš stariji Android:** Settings → Developer options → USB debugging → Godot deploy na uređaj (pouzdaniji od emulatora za FPS).

### Što Windows može / ne može

| Akcija | Windows (HP) | Mac | iPhone |
|--------|----------------|-----|--------|
| Godot development | ✅ | ✅ | — |
| Android APK export | ✅ | ✅ | — |
| Android emulator test | ✅ | — | — |
| iOS IPA export | ❌ | ✅ | — |
| Instalacija na iPhone | ❌ direktno | ✅ (Xcode) | prima build |
| Testiranje igre | emulator | — | ✅ nakon IPA |

### Preporučeni workflow (Android-first)

1. **Svaka sesija (M6+):** Godot na HP → debug APK → **emulator**
2. **Povremeno:** isti APK na **starijem Android telefonu** (kad ga imaš)
3. **M7:** kad Android loop radi → iOS export (Mac/CI) → test na **iPhoneu**
4. **Launch:** Google Play internal → TestFlight → production oba

### iOS bez vlastitog Maca — opcije

| Opcija | Cijena | Napomena |
|--------|--------|----------|
| Mac na fakultetu / biblioteci | Besplatno | Ograničeno vrijeme |
| Poznaj nekoga s Macom | Varijabilno | Xcode + Apple ID |
| GitHub Actions Mac runner | ~besplatno/minimalno | Automatizirani iOS build |
| MacinCloud / najam | $20–50/mj. | Ako često treba iOS |
| **Launch samo Android prvo** | $25 Play fee | Plan B iz [[../06-production/rizici|rizici]] |

### Godot export preset (plan)

- **Android:** debug APK za emulator; release AAB za Play
- **iOS:** export na Macu → Xcode → device ili TestFlight
- Detalji u [[CHECKPOINT|CHECKPOINT]] sekcija B/C

## Launch strategija

1. **Interni test** — Android APK (brži iteracije na slabom laptopu + emulator)
2. **Closed test** — Google Play internal / TestFlight
3. **Production** — oba storea kad monetizacija radi u testu

## Otvorena pitanja

- [ ] Google Play account ($25) + Apple Developer ($99) — budget plan
- [ ] Točan model starijeg Android telefona (za min API test)
- [ ] Mac pristup za iOS — fakultet / prijatelj / GitHub Actions

## Povezano

- [[engine-odluka|engine-odluka]]
- [[performanse|performanse]]
- [[../04-experience/ui-ux|ui-ux]]
