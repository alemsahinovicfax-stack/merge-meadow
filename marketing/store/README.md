# Store assets — Merge Meadow

PNG-ovi za Google Play i App Store. **Ne commitaj** draftove s osobnim podacima.

## Folder

```
marketing/store/
├── README.md
├── app-icon-512.png          ← generiše game/scripts/dev/make_app_icons.gd (Pip HUD portret, 2026-10-23)
├── feature-graphic.png       ← 1024×500, Figma — JOŠ NE POSTOJI (Play ga traži)
└── screenshots/
    ├── 01-run-lane.png       ← 1080×1920
    ├── 02-loot-double.png
    └── ...
```

## Docs

- Copy: `docs/06-production/store-listing-en.md`
- Capture plan: `docs/06-production/store-screenshots.md`

## Quick start

```powershell
# 1. Rich save for pretty camp/run HUD
& "$env:USERPROFILE\Desktop\Godot_v4.7-stable_win64.exe" --headless --rendering-driver opengl3 --path "game" --script "res://tools/setup_store_screenshot_state.gd"

# 2. Play on emulator, capture each scene
.\scripts\capture-store-screenshot.ps1 -Name "01-run-lane"
```
