---
type: iskustvo
status: aktivan
milestone: M7
tags: [iskustvo, ui, art, alati, workflow, c2, flat-cartoon]
povezano:
  - art-direction
  - ui-ux
  - CHECKPOINT
  - ../05-technical/godot/dev-workflow
ai_sažetak: "Flat cartoon workflow — Krita/Figma (Pip), Kenney flat UI, Godot StyleBox; Cursor modeli po situaciji."
---

# UI i art — alati i workflow (operativno)

> **Stil:** [[art-direction|flat cartoon]] — **bez pixel grida** (odluka 2026-07-05).  
> **CHECKPOINT C2** prati ovaj redoslijed.

## Sažetak — tri sloja

| Sloj | Alat | Ti radiš? |
|------|------|----------|
| **Logika + layout** | Godot 4.7 + Cursor | Cursor pomaže kod; ti testiraš F5 |
| **Likovi / pickupe** | **Krita** ili **Figma** | **1 hero** (Pip) — ti |
| **UI kit (gumbi, ikone)** | Kenney **flat** pack (CC0) | **Preuzmi**, ne crtaj od nule |

---

## Alati za UI (obavezni redoslijed)

### 1. Godot 4.7 — gdje UI živi

| Što | Gdje u projektu |
|-----|-----------------|
| Ekrani | `game/scenes/` (`main_menu.tscn`, `camp_scene.tscn`, …) |
| Klik gumbi | `UiClickButton` + `StyleBoxFlat` (rounded corners) |
| Boje | Theme / art-direction paleta |
| Asseti | `game/assets/sprites/`, `game/assets/ui/` |

**Pokretanje (HP AMD):** `scripts/godot-open.ps1`

**Import PNG (flat cartoon):** **Filter: On** (Linear), **Mipmaps: Off** za UI; likovi mogu Filter On za glatko skaliranje.

### 2. Krita ili Figma — flat cartoon asseti koje **ti** praviš

| Alat | Kad |
|------|-----|
| **[Krita](https://krita.org/)** (besplatno) | Crtaš Pip + pickupe raster/vektor, export PNG |
| **[Figma](https://figma.com)** (besplatno tier) | Brži vector Pip, export 2× PNG |

**Pravila crtanja:** soft outline (`#2D3436`), pastel fill, blaga sjena — vidi [[art-direction|art-direction]].

### 3. Kenney — **flat** UI kit (preuzmi)

- [kenney.nl/assets](https://kenney.nl/assets) — CC0
- Traži packove tipa **UI Pack**, **Game Icons** — **rounded flat**, ne retro pixel
- Jedan set → recolor u Krita ako treba

### 4. LibreSprite / Discord LibreSprite

- **Ne** primarni alat za ovaj projekt
- `LibreSprite/resources` na GitHubu = **teme editora**, ne game asseti
- Discord/Matrix = pomoć oko alata, ne sprite library

### 5. Gotovi game asseti (van LibreSprite)

| Izvor | Za što |
|-------|--------|
| [Kenney.nl](https://kenney.nl/assets) | UI, ikone |
| [itch.io](https://itch.io/game-assets/free/tag-2d) | flat character reference (provjeri licencu) |
| [OpenGameArt.org](https://opengameart.org/) | backup — CC0/CC-BY |

---

## Cursor modeli — kad koji

| Situacija | Model |
|-----------|--------|
| Import PNG, StyleBox, jedna scena | **Composer** |
| C2 — zamjena `PipDraw` → `Sprite2D` | **Composer** |
| Hub carousel (UX-04) | **Codex** / **Sonnet Thinking** |
| Spec prije refactora | **Thinking** |
| Debug Godot | **Sonnet Thinking** |
| **Crtanje spriteova** | ❌ ne Cursor — **Krita/Figma** |
| Mood / referenca | AI slika → Obsidian only |

---

## C2 plan: **1 ti praviš + 1 preuzimaš**

### A) Ti praviš — **Pip** (flat cartoon hero)

**Alat:** **Krita** (preporuka) ili Figma  
**Veličina source:** ~**128–256 px** visina, transparent PNG  
**Stil:** rounded cartoon žaba, velika glava, mint/teal tijelo, soft outline

**Koraci (~45–90 min):**

1. Novi dokument **256×256** (ili veći, export downscale)  
2. Slojevi: outline → fill → oči/highlight → opcionalna sjena  
3. Export `pip_idle.png` → `game/assets/sprites/`  
4. Cursor (Composer): uvezi u main menu + run HUD, zamijeni `PipDraw`  
5. Run animacija kasnije: **tween bob** u Godot — ne obavezno frameovi u C2

**DoD:** isti Pip PNG na main menuu i u runu.

### Figma → Godot (operativno)

| Korak | Tko | Što |
|-------|-----|-----|
| 1 | **Ti** | Figma / Figma Make — dizajn Pip frame 256×256, transparent |
| 2 | **Ti** | **Export PNG** (ne samo `.make`!) → `game/assets/sprites/pip_idle.png` ili reci agentu gdje je fajl |
| 3 | **Agent** | `godot-import.ps1` → uvezi u `pip_assets.gd` + scene → smoke-test |
| 4 | **Git** | commit asset + `*.import` |

**Figma Make `.make`:** agent može izvući SVG/raster iz ZIP-a (kao Pip 2026-07-06), ali **PNG export iz Figme je pouzdaniji**.

**Figma cloud link:** agent **ne može** uvijek direktno skidati — treba export na disk ili Figma MCP (ograničeno). Najbrže: ti export → folder → „dodaj u kod“.

### B) Preuzmi — **flat UI pack** (Kenney)

1. Download flat UI / game icons ZIP  
2. Odaberi ~10 PNG (settings, coin-like, panel slice ako ima)  
3. `game/assets/ui/kenney/` — samo korištene  
4. Zapiši licencu u `docs/07-meta/reference/`  
5. Godot: ikona pored walleta; `StyleBoxFlat` za panele u paleti

### C) Coin + seed — flat pickupe

| Opcija | Trud |
|--------|------|
| **Ti u Krita** — zlatni krug + `$`, zeleni list | 15–20 min ✅ |
| Kenney flat coin iz packa | 5 min |

---

## Folder struktura

```
game/assets/
├── sprites/
│   └── pip_idle.png          ← TI (Krita/Figma)
├── ui/kenney/                ← PREUZETO (flat only)
└── pickups/
    ├── coin.png
    └── seed_clover.png
```

---

## Checklist C2

- [x] `pip_idle.png` — flat cartoon, Krita/Figma (SVG: `pip_idle.svg`)  
- [x] Kenney **flat** UI subset  
- [x] Coin + seed flat PNG  
- [x] PipDraw → Sprite2D (main menu + run)  
- [x] Wallet/settings ikona  
- [x] Gumbi: `StyleBoxFlat` rounded u paleti (`ui_palette.gd`)

---

## Povezano

- [[art-direction|art-direction]]
- [[ui-ux|ui-ux]]
- [[../06-production/CHECKPOINT|CHECKPOINT]] — C2
- [[../05-technical/godot/dev-workflow|dev-workflow]]
