---
type: tehnicko
status: aktivan
milestone: M8
tags: [tehnicko, godot, admob, monetizacija, ump]
povezano:
  - CHECKPOINT
  - ../02-design/monetizacija
  - sigurnost
  - iap-billing-setup
  - play-console-sutra
ai_sažetak: "Poing AdMob v5.1.0 u game/addons/admob (od 2026-10-23): admob_backend.gd (UMP → MobileAds → rewarded + interstitial), AdManager pacer (1 na 3 Retry-ja, 3 min, nikad u tutorijalu / prvoj sesiji); test ID-evi dok korisnik ne upiše produkcijske u monetization_config.gd."
---

# AdMob setup (Godot 4.7)

> **Stanje 2026-10-23 (LAUNCH-PREP C):** Poing AdMob **v5.1.0** je u `game/addons/admob/` i uključen. Na Androidu radi prava reklama (Googleove **test** jedinice dok ne upišeš svoje), UMP pristanak i *Privacy choices*. Na desktopu / u editoru ostaje stub (1,2 s „reklame").

## 1. Plugin

| | |
|--|--|
| Izvor | [poingstudios/godot-admob-plugin v5.1.0](https://github.com/poingstudios/godot-admob-plugin/releases/tag/v5.1.0) (GMA Next-Gen SDK) |
| U repou | `game/addons/admob/` **bez** `csharp/`, `skills/` i `gdscript/sample/` (igra je GDScript; primjeri ne trebaju) |
| Android biblioteka | `addons/admob/android/bin/` iz `android-template-v4.7.0.zip` — **gitignore** (pluginov `.gitignore`); na novom računaru je headless editor sam skine pri prvom importu / exportu |
| iOS biblioteka | `addons/admob/ios/bin/` — isto, gitignore |
| Uslov | Gradle build u Android presetu (inače export javi grešku) |
| App ID | Project Settings → `admob/general/android/app_id` → plugin ga upiše u `AndroidManifest.xml`. Dok je jednak Googleovom test ID-u, plugin ga **ne snima** u `project.godot` (default) |

**Zašto ne `ClassDB`:** Poing klase (`MobileAds`, `RewardedAdLoader`…) su GDScript `class_name` — `ClassDB.class_exists` ih ne vidi. `AdManager` prepoznaje plugin po `res://addons/admob/plugin.cfg` i na Androidu učitava `admob_backend.gd` po putanji, pa desktop / smoke testovi nikad ne diraju plugin.

## 2. ID-evi — jedno mjesto

`game/scripts/monetization/monetization_config.gd`, blok **PRODUCTION IDS (TODO Alem)**:

| Konstanta | Sada | Upiši |
|-----------|------|-------|
| `ADMOB_APP_ID_ANDROID_PROD` | `""` | App ID (`ca-app-pub-…~…`) — **i** u Project Settings `admob/general/android/app_id` |
| `ADMOB_REWARDED_ANDROID_PROD` | `""` | Rewarded ad unit (`ca-app-pub-…/…`) |
| `ADMOB_INTERSTITIAL_ANDROID_PROD` | `""` | Interstitial ad unit |

- Debug build **uvijek** koristi test jedinice (`pick_ad_unit`) — svoje reklame ne klikaj.
- Release s praznim prod ID-em → test reklame + upozorenje (`AdManager` log i `scripts/android-export.ps1`).
- `test_ad_manager.gd` pada ako se App ID u Project Settings i u configu ne poklapaju.
- ID-evi **nisu tajni** (stoje u svakom APK-u) → smiju u git ([[sigurnost|sigurnost]]).

Test ID-evi (Google, javni): App `ca-app-pub-3940256099942544~3347511713`, rewarded `…/5224354917`, interstitial `…/1033173712`.

## 3. Tok u igri

1. **Start (Android + plugin):** `admob_backend.start()` → UMP `consent_information.update` → ako je `REQUIRED` i forma postoji → forma → `MobileAds.initialize` (`max_ad_content_rating = G`, ne under-age) → preload 1 rewarded + 1 interstitial.
2. Reklame se traže samo kad je pristanak `NOT_REQUIRED` ili `OBTAINED`; bez toga loot ekran sakrije ad dugmad (`can_request_rewarded() == false`).
3. **Rewarded** (×2 loot, revive): učitana → `show`; nije → load (8 s) ili `no_fill`. **Nagrada samo na `on_user_earned_reward`**; zatvorena prije kraja → `not_earned` (0,5 s grace za zakašnjeli callback). Muzika pauzirana (`Sfx.set_ad_playing`). Ostaje i poslije Remove Ads (Pillar 2).
4. **Interstitial** (Retry na loot ekranu) — `AdManager.take_interstitial_turn()` broji Retry i pita `InterstitialPacer`:
   - nikad prije završenog tutorijala ni u sesiji u kojoj je tutorijal završen;
   - najviše 1 na **3 Retry-ja**, najmanje **3 min** razmaka (i od starta igre);
   - Remove Ads ih gasi; brojači samo u memoriji.
   - Red je, a reklama nije učitana → naruči je, Retry ide odmah.
5. **Privacy choices** (Settings): UMP *privacy options* forma kad je potrebna (EEA/UK/CH, US države ako postoji poruka), inače politika privatnosti.
6. **Dev (debug build, Settings → Developer):** „Consent as EU" (UMP debug geografija EEA, od sljedećeg pokretanja; `user://ads_debug.cfg`), „Reset ad consent".

> **UMP forma dolazi iz AdMob konzole:** bez objavljene *European regulations (GDPR)* poruke u AdMob → Privacy & messaging, UMP kaže „nije potrebno" i forme nema ni u EU.

## 4. Kod

| Fajl | Uloga |
|------|--------|
| `scripts/monetization/ad_manager.gd` | autoload `AdManager`: rute, rewarded, pacer, privacy, dev prekidači |
| `scripts/monetization/admob_backend.gd` | adapter na Poing API (UMP, MobileAds, loaderi) — samo Android |
| `scripts/monetization/monetization_config.gd` | test + produkcijski ID-evi |
| `scripts/ui/loot_screen.gd` | `request_rewarded`, `take_interstitial_turn` + `show_interstitial` |
| `test/unit/test_ad_manager.gd` | GUT s lažnim backendom (nagrada, pacer, ID-evi) |

## 5. Test plan

### Desktop
- `scripts/gut-run.ps1` (`test_ad_manager`), `scripts/smoke-all.ps1 -Filter "loot|audio|settings"`.

### Android (emulator `Pixel_4_API33` ili telefon)
1. `scripts/android-export.ps1 -Preset Debug` (ili `Apk` za release) → `scripts/android-launch-game.ps1 -Apk <putanja>`.
2. Završi run → **Double Loot** → Googleova test reklama („Test Ad") → nagrada tek kad odgledaš.
3. Fail → **Revive** → isto.
4. Retry ×3 poslije 3 min (ne u prvoj sesiji) → test interstitial; Retry ide dalje i kad se zatvori.
5. Debug: Settings → Developer → „Consent as EU: on" → restart → UMP forma (treba GDPR poruka u AdMob konzoli).
6. Logcat: `adb logcat -s godot:*` — upozorenja „AdMob … failed" znače no-fill / mrežu.

## Povezano

- [[iap-billing-setup|iap-billing-setup]]
- [[dev-workflow|dev-workflow]]
- [[../02-design/monetizacija|monetizacija]]
- [[../../06-production/play-console-sutra|play-console-sutra]]
