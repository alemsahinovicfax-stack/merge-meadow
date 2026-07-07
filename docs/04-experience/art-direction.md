---
type: iskustvo
status: aktivan
milestone: M7
tags: [iskustvo, art, flat-cartoon]
povezano:
  - ui-i-art-alati
  - ui-ux
  - CHECKPOINT
ai_sažetak: "Flat 2D cartoon — pastel, soft outline, bez pixel grida; brzo za solo dev, store-friendly."
---

# Art direction

## Sažetak

**Flat 2D cartoon** u pastelnom cute stilu — **bez pixel art grida**. Brzo za solo dev, dovoljno distinct za store i TikTok hook.

> **Odluka 2026-07-05:** napuštamo hybrid „flat + pixel UI“. Cijela igra — likovi, pickupe, UI — **jedan flat cartoon jezik**.

## Stil

| Sloj | Stil | Razlog |
|------|------|--------|
| Gameplay (lane, pickupe, prepreke) | Flat cartoon, blaga sjena, **soft outline** | Čitljivost na pastel pozadini |
| Likovi (Pip) | Rounded cartoon, velika glava, velike oči | Silueta + store hook |
| UI (gumbi, ikone, HUD) | Flat rounded panels + jednostavne ikone | Godot `StyleBoxFlat` + PNG ikone |
| Kamp / hub pozadine | Flat illustracija, parallax 1–2 sloja | Cozy bez 3D scopea |

**Vizualni pravila:**

- **Outline:** tamniji od fill-a (~20% tamnije), 2–4 px pri exportu (skalira se u Godot)
- **Sjene:** jedna blaga drop shadow (offset 2–4 px, niska opacity) — ne realistično 3D
- **Bez:** pixel grid, dithering, retro CRT efekti
- **Perspektiva:** side-scroll lane (Subway Surfers lite), top-down kamp grid
- **Mood:** Cozy meadow, vedro, satisfying — vidi [[../03-content/svijet-i-lore|svijet-i-lore]]

## Lane run pozadina (v1)

**Sky + 3 ista puta** — putovi centrirani na gameplay laneove (25% / 50% / 75%), ne na trećine ekrana.

| Sloj | Boja | Kod |
|------|------|-----|
| Nebo | `#B8E0F5` | `Background` Polygon2D |
| Gornji fade | `#E2F2FA` | gornjih 35% |
| Lane put | `#A8E6CF` @ 18% | širina 30% ekrana, centar = lane X |
| Rub puta | `#2D3436` @ 8% | tanke linije lijevo/desno |

Implementacija: `game/assets/backgrounds/lane_background.png` (Figma Make) + `lane_background.gd` cover-scale. Proceduralni putovi uklonjeni kad je PNG aktivan.

## Paleta

| Uloga | Boja | Hex (draft) |
|-------|------|-------------|
| Primary | Mint green | `#A8E6CF` |
| Secondary | Lavender | `#D4A5FF` |
| Background (kamp) | Warm white | `#FFF8F0` |
| Background (lane) | Soft sky | `#B8E0F5` |
| Accent / CTA | Peach | `#FFB88C` |
| Pickup T1 (seed) | Pastel yellow | `#FFEAA7` |
| Pickup T2 (bloom feel) | Pastel pink | `#FFCCD5` |
| Coin gold | Soft gold | `#FFD56B` |
| UI text | Soft charcoal | `#4A4A4A` |
| Outline | Deep charcoal | `#2D3436` |

**Kontrast:** lane pozadina tamnija od pickupa; pickupe uvijek s outlineom (accessibility).

## Silueta i čitljivost

- Ljubimac u runu: **velika silueta**, min ~80 pt visine na ekranu
- Prepreke: tamniji fill + jasniji oblik od coin/seed
- Merge pop: scale 1.0→1.3→1.0, čestice u accent boji
- **Store screenshot #1:** Pip u runu + pickup shower + „×2“ badge

## Asset pipeline

| Alat | Uporaba |
|------|---------|
| **Krita** ili **Figma** | Pip, coin/seed, flat ilustracije — vidi [[ui-i-art-alati|ui-i-art-alati]] |
| **Kenney.nl** (CC0) | Flat UI pack — preuzmi, recolor po paleti |
| Godot + Cursor Composer | Scene, Theme, `StyleBoxFlat`, import PNG |
| LibreSprite | ❌ ne primarni — samo ako editiraš preuzeti PNG |

**Export:** PNG s transparentnom pozadinom; Pip ~**128–256 px** visina u sourceu; Godot skalira. Base viewport **1080×1920** portrait.

## Animacije (v1)

| Asset | Pristup |
|-------|---------|
| Ljubimac run | **Squash-stretch** + lagani bob (Godot tween) ili 3–4 flat framea |
| Pickup | Tween fly-to-HUD + scale pop |
| Merge | Scale bounce + particles (code-driven) |
| Kamp | Lagani idle scale/bob — ne pixel blink |

Frame-by-frame **opcionalno**; prefer **tween/VFX** za solo brzinu.

## Vertical slice asset lista (draft)

| Kategorija | Broj (v1) |
|------------|-----------|
| Ljubimci playable | 1 (Pip) + 1 unlock |
| Pickup tipovi | coin + 1–3 seed varijante (flat ikone) |
| Prepreke | 2–3 flat oblik |
| Kamp pozadina | 1 soft gradient + optional 1 layer |
| UI kit | 1 flat set (Kenney + Godot StyleBox) |

## Otvorena pitanja

- [ ] Custom font (rounded sans) ili system font
- [ ] Outline debljina na malim ikonama (16–24 px) — test na telefonu

## Riješeno ✅

- ~~Pixel UI accent~~ → **flat cartoon cijela igra** (2026-07-05)
- ~~Pixel density 16 vs 32~~ → n/a (nije pixel art)

## Povezano

- [[ui-i-art-alati|ui-i-art-alati]] — alati, C2 checklist, Cursor modeli
- [[../03-content/svijet-i-lore|svijet-i-lore]]
- [[ui-ux|ui-ux]]
- [[audio-direction|audio-direction]]
- [[../01-vision/konkurencija-i-inspiracija|konkurencija]]
