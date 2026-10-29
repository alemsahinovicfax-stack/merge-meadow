# Store assets — Merge Meadow

Gotov Play Store paket od Claude Designa (round 3, 2026-10-29). Hook: **Run. Merge. Bloom.**

## Za upload u Play Console

| Play polje | Fajl | Veličina |
|---|---|---|
| App icon | `app-icon-512.png` | 512×512, 32-bit PNG |
| Feature graphic | `feature-graphic.png` (svijetla, Country Bloom) | 1024×500, bez alfe |
| — rezerva | `feature-graphic-dark.png` (tamna, Starfall Glade) | 1024×500, bez alfe |
| Phone screenshots | `screenshots/01_…08_*.png`, redom po broju | 1080×1920, bez alfe |
| (nije Play polje) | `promo-1200x630.png` | testeri, GitHub stranica, privacy page |

Tekst (short / full description): `docs/06-production/store-listing-en.md`.

## Folder

```
marketing/store/
├── README.md
├── app-icon-512.png        ← make_app_icons.gd kopira iz design/source/icon/icon_512.png
├── feature-graphic.png
├── feature-graphic-dark.png
├── promo-1200x630.png
├── screenshots/            ← 01_run_merge_bloom … 08_no_energy_no_timers
└── design/
    ├── store_preview.html  ← sve + simulacija Play listinga, otvori u browseru
    ├── CD-README.md        ← CD-ov opis: hook, naslovi, boje, Play provjera, round 2 i 3
    ├── review/icon_review.png
    └── source/
        ├── Store Assets v3.dc.html   ← izmjenjivi izvor svih artboarda (fg-light, fg-dark, ss-01…08, promo)
        ├── icon/            ← MASTER ikone (512 + adaptivni fg / bg / mono 432) — izvor za igru
        ├── hero_pip/        ← hero Pip PNG + SVG (s krugom i bez), samo za marketing
        └── ref/, sprites/, game/, fonts/, brand/   ← ulazi za HTML
```

## Ikona u igri

Ikone u `game/assets/branding/` se prave iz `design/source/icon/`:

```powershell
& "$env:USERPROFILE\Desktop\Godot_v4.7-stable_win64.exe" --headless --rendering-driver opengl3 --path game --script res://scripts/dev/make_app_icons.gd
.\scripts\godot-import.ps1
.\scripts\android-export.ps1 -Preset Aab
```

## Novi kadrovi iz igre

`game/scripts/dev/store_capture.gd` snima sirove kadrove u `docs/04-experience/design-drafts/store-assets-ref/` (bogat save samo u kopiji APPDATA). Brief za CD: `docs/04-experience/design-drafts/store-assets-cd-brief.md`.
