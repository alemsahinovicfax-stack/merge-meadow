---
status: draft
tags: [iskustvo, art]
---

# Art direction

## Sažetak

**Flat 2D gameplay + pixel UI** u pastelnom cute stilu — brzo za solo dev, dovoljno distinct za store i TikTok hook.

## Stil

| Sloj | Stil | Razlog |
|------|------|--------|
| Gameplay (lane, orbs, prepreke) | Flat 2D, soft shadows | Brza produkcija, čitljivost |
| UI ikone, ljubimci (portret) | Pixel art accent | Charm, store thumbnail |
| Kamp pozadina | Flat illustracija, parallax 1–2 sloja | Cozy bez 3D scopea |

- **Perspektiva:** Side-scroll lane (Subway Surfers lite), top-down kamp grid
- **Mood:** Cozy meadow, vedro, satisfying — vidi [[../03-content/svijet-i-lore|svijet-i-lore]]

## Paleta

| Uloga | Boja | Hex (draft) |
|-------|------|-------------|
| Primary | Mint green | `#A8E6CF` |
| Secondary | Lavender | `#D4A5FF` |
| Background (kamp) | Warm white | `#FFF8F0` |
| Background (lane) | Soft sky | `#B8E0F5` |
| Accent / CTA | Peach | `#FFB88C` |
| Orb T1 | Pastel yellow | `#FFEAA7` |
| Orb T2 | Pastel pink | `#FFCCD5` |
| UI text | Soft charcoal | `#4A4A4A` |

**Kontrast:** lane pozadina tamnija od orbs; orbs uvijek čitljivi (accessibility).

## Silueta i čitljivost

- Ljubimac u runu: **velika silueta**, min 64×64 pt na ekranu
- Prepreke: jasno razlikovne od orbs (tamniji outline, drugačiji oblik)
- Merge pop: scale 1.0→1.3→1.0, čestice u accent boji
- **Store screenshot #1:** Pip u runu + orb shower + “×2” badge

## Asset pipeline (draft)

| Alat | Uporaba |
|------|---------|
| Aseprite / LibreSprite | Pixel ljubimci, UI ikone |
| Figma / Excalidraw | Flat shapes, paleta, wireframe |
| Godot/Unity | Placeholder primitives u greyboxu |

**Rezolucija:** Base 1080×1920 portrait; export @1x @2x za iOS/Android.

## Animacije (v1)

| Asset | Pristup |
|-------|---------|
| Ljubimac run | 4–6 frame pixel cycle ili squash-stretch flat |
| Orb pickup | Tween fly-to-HUD |
| Merge | Scale bounce + particles (code-driven) |
| Kamp | Idle blink 2 frame |

Frame-by-frame samo za ljubimca; ostalo tween/VFX.

## Vertical slice asset lista (draft)

| Kategorija | Broj (v1) |
|------------|-----------|
| Ljubimci playable | 1 (Pip) + 1 unlock |
| Orb tierovi | 3 |
| Prepreke | 3 varijante |
| Kamp tileset | 1 set |
| UI kit | 1 (pixel icons + flat buttons) |

## Audio vizualni par (vidi audio-direction)

- Pickup: soft “pop”
- Merge: satisfying “ding” + haptic medium
- Fail: gentle “thud”, ne kazna

## Otvorena pitanja

- [ ] Finalni pixel density (16px vs 32px grid)
- [ ] Custom font ili system font za UI

## Povezano

- [[../03-content/svijet-i-lore|svijet-i-lore]]
- [[ui-ux|ui-ux]]
- [[audio-direction|audio-direction]]
- [[../01-vision/konkurencija-i-inspiracija|konkurencija]]
