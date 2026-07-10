---
type: tehnicko
status: aktivan
milestone: M7
tags: [tehnicko, godot, admob, monetizacija]
povezano:
  - CHECKPOINT
  - ../02-design/monetizacija
  - sigurnost
ai_sažetak: "Poing AdMob plugin — instalacija za Android rewarded test; AdManager autoload već spreman."
---

# AdMob setup (Godot 4.7)

> **C3:** `AdManager` autoload radi u **stub** modu na Windowsu. Za prave test oglase na Androidu instaliraj plugin.

## 1. Instaliraj plugin

1. Godot Asset Library → [AdMob by Poing Studios](https://store.godotengine.org/asset/poingstudios/admob/)
2. **Project → Project Settings → Plugins** → uključi **AdMob**
3. **Project → Tools → AdMob Manager → Android → Download & Install**

## 2. Test ad unit

Javni test ID (već u kodu):

```
ca-app-pub-3940256099942544/5224354917
```

Vidi `game/scripts/monetization/monetization_config.gd`.

## 3. Produkcijski ID-evi

- **Ne commitaj** prave App ID / ad unit ID u git
- Drži u `game/export_credentials/` (gitignore) ili lokalnom export presetu
- vidi [[sigurnost|sigurnost]]

## 4. Kod u projektu

| Fajl | Uloga |
|------|--------|
| `scripts/monetization/ad_manager.gd` | Rewarded ×2 + revive |
| `scripts/monetization/iap_manager.gd` | IAP production (billing D3) |
| `scripts/ui/loot_screen.gd` | Poziva `AdManager.request_rewarded()` |

Kad je `res://addons/admob` prisutan, `AdManager` prelazi na `admob_plugin` backend (rewarded load još treba dovršiti prema Poing docs).

## 5. Test plan (Android APK)

1. Završi run → loot ekran
2. **Double Loot** → test rewarded (ili stub poruka)
3. Fail run → **Revive** → nastavi run
4. Main menu → **Shop** → test IAP stub

## Povezano

- [[dev-workflow|dev-workflow]]
- [[../02-design/monetizacija|monetizacija]]
