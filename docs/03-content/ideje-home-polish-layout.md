---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, layout, polish, scratch]
povezano:
  - ideje-home-polish
  - ideje-home-polish-carousel
  - ideje-home-polish-pitanja
  - ideje-sezone-ux-home
ai_sažetak: "HOME-01 layout — ukinuti centrirani Panel; otvoreni Home: chest/basket, swipe polje, Play."
---

# IDEJE — Home polish layout (ubiti prozor)

> [[ideje-home-polish|HOME-01]]. Freeze **P17**: ukinuti cijeli centrirani `Panel` u [`game/scenes/main_menu.tscn`](../../game/scenes/main_menu.tscn).

## Što je „veliki prozor“ (točno u sceni)

Home page (`main_menu.tscn`, često ugnježden u meta hub) trenutno ima:

1. **`HomeTopStack`** (van Panela) — Daily chest kartica + Basket kartica. To **ostaje**.
2. **`Panel`** (`StyleBoxFlat_panel`, anchori 0.5, offset otprilike −320/−360 … +320/+360) — **to je prozor**. Unutra `VBox`:
   - `PipPortrait`
   - `Title` „Merge Meadow“ (font 64)
   - `Tagline`
   - `TutorialHint`
   - instance **`SeasonStage`**
   - `PlayButton`
   - `EndlessSection`
3. Wallet / settings chrome (postojeći hub overlay) — **ostaje**, nije tema ovog doca osim da ne smije pasti ispod trake.

**P17 (2026-08-19):** ukinuti taj `Panel` kao vizualni okvir. Home je **full-bleed** stranica, ne dijalog.

Ne zamijeniti Panel drugim Panelom iste veličine. Ako treba blagi scrim iza trake radi kontrasta na BG, to je tanak sloj (**ne** 640×720 kartica).

## Ciljni z-order (gore → dolje na ekranu)

Portrait **1080×1920**, `stretch/aspect=keep`. Safe area: postojeći `SAFE_AREA` helperi.

```
┌─────────────────────────────────────┐
│  [Wallet / diamonds]     [Settings] │  postojeći hub chrome
│  Daily chest                        │  HomeTopStack
│  Basket                             │  HomeTopStack
│                                     │
│  (opc.) Pip + kratki naslov         │  P18 default: compact header
│                                     │
│     [S1]   [ S2 veći ]   [🔒S3]     │  HOME strip — sredina
│      L         C            R       │  posebno swipe polje
│                                     │
│              [ Play ]               │
│           Endless (ako treba)       │
│                                     │
│         hub page dots / peek        │  SwipePager, ne dirati logiku
└─────────────────────────────────────┘
```

Vertikalni ritam (draft px na 1080 širine):

| Zona | Draft visina | Note |
|------|----------------|------|
| Hub chrome + chest/basket | ~280–360 | već postoji; ne gurati preko trake |
| Compact header (Pip+title) | ~88–120 | manje od današnjeg 64pt title + 96 Pip |
| **Swipe polje** | **~280–340** | jedini „hero“; clip overflow peek |
| Spacer | 16–32 | |
| Play | ~96 | isti `UiClickButton` pattern |
| Endless block | postojeće | **ispod** Play, **van** trake (P24) |

Ovo su draft brojevi za HOME-A/B, ne final art spec.

## Što se događa s djecom Panela

### Daily chest + Basket

Ostaju u `HomeTopStack` **iznad** swipe polja. Ne ulaze u Panel (već nisu). HOME-A sme smjestiti TopStack + novi root `VBox` umjesto Panel+VBox.

### Pip + Title + Tagline + TutorialHint — **P18** (otvoreno, default predložen)

**Default za kod dok se ne overridea:** compact header **iznad trake**, bez okvira:

- Pip ~64×64 (ne 96).
- Naslov „Merge Meadow“ ~36–40, ne 64.
- Tagline **jedna linija** ili sakriti na uskom spaceu.
- `TutorialHint` vidljiv **samo** dok tutorial nije complete (postojeća logika ako je ima); nakon toga `visible = false` da ne gura traku dolje.

Ako header i dalje guši sredinu, HOME-C smije spustiti naslov u chrome ili ostaviti samo Pip.

### SeasonStage

Ne brisati node u HOME-A ako B još nije gotov — ali **vizualni okvir Stagea** (ActiveCard kao veliki tekst-panel visine 240) odlazi u **HOME-B**. HOME-A smije ostaviti Stage kao child flatten layouta (bez vanjskog Panel-a) da Play i dalje radi, zatim B zamijeni unutrašnjost 3-slot trakom.

Redoslijed u promptima namjerno: **prvo ubiti prozor (A), zatim traka (B)** da se layout i carousel ne miješaju u jednom PR-u.

### Play + Endless

- Play ostaje primarni CTA, **ispod** trake, puna širina s marginama (npr. 48px).
- Endless sekcija ostaje **ispod** Play (P24). Ne stavljati Endless u swipe polje.

## Posebno swipe polje (hit-test)

Traka je **Control** s `MOUSE_FILTER_STOP` i grupom `block_hub_swipe` (kao današnji Stage).

- Horizontalni drag **unutar recta trake** → carousel, **ne** hub page.
- Drag **izvan** trake (npr. na praznom BG, na Play) → hub pager smije reagirati po postojećim pravilima.
- Vertikalni scroll ako ikad treba na Homeu: traka ne smije gutati vertikalni drag namijenjen listi (danas Home nije ScrollContainer hero — OK).

Tehnički: `SwipePager.should_block_hub_swipe_at` već gleda grupu. HOME-A/B moraju zadržati group membership na traci, **ne** na cijelom Home pageu (inače se hub swipe ugasi).

## Background

Lane/meadow BG (ako Home već tint-a ili ima ColorRect) ostaje full screen **iza** UI-a. Ukinuće Panela znači da se vidi više BG-a lijevo/desno — to je željeni polish, ne bug. Ako kontrast naslova padne, scrim **lokalno** iza headera/trake, ne novi globalni prozor.

## Safe area i notch

- Gore: wallet + chest ne ulaze u notch (postojeći `SAFE_AREA.apply_top_margin` ako se koristi na hub rootu).
- Dolje: Play iznad home indicator; bottom margin kao shop/hub.
- Traka horizontalno: side cards smiju **clippati** uz rub (peek), ali centar nikad ne smije biti odrezan.

## Što HOME-A **ne** radi

- Ne mijenja Shop, Camp, Arena page.
- Ne mijenja IAP.
- Ne implementira 3-slot logiku (to je B) osim ako A ostavi stari Stage privremeno u flatten VBoxu.
- Ne dodaje nove fontove/asset packove.

## Acceptance (kad dođe kod — HOME-A)

- Nema centriranog Panel-okvira oko naslova+Play.
- Chest, Basket, Play, Endless, wallet i dalje rade.
- Hub swipe L/R i dalje mijenja stranice kad gesta **nije** na SeasonStage/traci.
- Headless: postojeći hub/home smoke i dalje loada scenu (update pathova nodeova ako Panel nestane).

## Rizici layouta

| Rizik | Mitigacija |
|-------|------------|
| Previše vertikalnog sadržaja, Play ispod folda | Compact header P18; sakrij tagline |
| Traka preuska pa side kartice nečitljive | Min visina ~280; side širina ≥ 22% viewporta |
| Cijeli Home u `block_hub_swipe` | Group samo na strip Control |
| Godot anchor lomi se kad se Panel obriše | HOME-A: novi root VBox full rect, test na 1080×1920 i uskom windowu |

## Povezano

- [[ideje-home-polish|hub]] · [[ideje-home-polish-carousel|carousel]] · [[ideje-home-polish-pitanja|pitanja]]
