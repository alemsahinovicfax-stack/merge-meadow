---
type: tehnicko
status: aktivan
milestone: M7
tags: [tehnicko, godot, ios, export, c4]
povezano:
  - CHECKPOINT
  - ../platforme
  - admob-setup
ai_sažetak: "C4 iOS — export preset + GitHub Actions + Mac/Xcode koraci za iPhone test."
---

# iOS export (C4)

> **Windows HP ne može exportati IPA.** Pipeline je pripremljen u repou; build radi na **Macu** ili **GitHub Actions**.

## Što je već u repou

| Stavka | Putanja |
|--------|---------|
| Export preset **iOS** | `game/export_presets.cfg` (preset `iOS`) |
| Export preset **Android Debug** | isti fajl (preset `Android Debug`) |
| Safe area (notch) | `game/scripts/ui/safe_area_helper.gd` |
| CI workflow | `.github/workflows/ios-xcode-export.yml` |

**Bundle ID:** `com.mergemeadow.game` — promijeni ako imaš vlastitu domenu.

## Opcija A — GitHub Actions (preporuka bez Maca)

1. Push na `merge-meadow` repo
2. GitHub → **Actions** → **iOS Xcode Export** → **Run workflow**
3. Preuzmi artifact `ios-xcode-project`
4. Na Macu: otvori `.xcodeproj` u Xcode → odaberi svoj iPhone → Run

### Secrets (kad želiš potpuni IPA / TestFlight)

U GitHub repo **Settings → Secrets**:

| Secret | Što |
|--------|-----|
| `IOS_TEAM_ID` | Apple Developer Team ID |
| `IOS_BUNDLE_ID` | `com.mergemeadow.game` (ili tvoj) |

Provisioning profile i certifikati — vidi [Godot iOS export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html).

## Opcija B — Mac s Godotom

1. Kloniraj repo na Mac
2. Instaliraj Godot 4.7 + **iOS export templates** (Editor → Manage Export Templates)
3. Otvori `game/` projekt
4. **Project → Export → iOS**
5. Postavi **App Store Team ID** (ne ostavljaj `YOUR_TEAM_ID`)
6. **Export Project** → `export/ios/MergeMeadow.xcodeproj`
7. Xcode → Signing & Capabilities → tvoj Apple ID
8. Uključi iPhone → **Run** (dev install) ili **Archive → TestFlight**

## Test plan (C4 exit)

Na **fizičkom iPhoneu**:

- [ ] Main menu → Play → lane run (swipe)
- [ ] Završi run → loot (Double / Retry / Camp)
- [ ] Kamp → merge 2→1
- [ ] Shop IAP stub (opcionalno)
- [ ] HUD čitljiv (notch + home indicator)

## Safe area

`SafeAreaHelper` pomakne HUD na runu i Settings gumb na menuu. Ako nešto još siječe notch, dodaj poziv u `_ready()` scene.

## Plan B (ako iOS kasni)

Android-first launch — vidi [[../06-production/rizici|rizici]] Plan B. C4 ne blokira daljnji Android rad.

## Povezano

- [[../platforme|platforme]] — Windows vs Mac tablica
- [[admob-setup|admob-setup]] — rewarded na mobilnom
- [[dev-workflow|dev-workflow]]
