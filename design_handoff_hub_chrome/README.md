# Handoff: Hub chrome — header + footer

Dizajn iz Claude Designa za prenos u `meta_hub.tscn`. Prati §9 iz
`docs/04-experience/design-drafts/hub-header-footer-cd-brief.md`.

## Šta je ovo

**Fidelity: hi-fi.** Boje, mjere, radiusi, fontovi i stanja su finalni i mjereni u
bazi 1080×1920 px — prenos je 1:1, bez preračunavanja.

HTML fajlovi u paketu su **dizajn referenca, ne kod za kopiranje**. Cilj je
rekonstruisati ih u Godotu postojećim obrascima projekta (`StyleBoxFlat`,
`UiClickButton`, `ui_palette.gd`), ne portovati HTML.

Odabran je **smjer B — tamni livadski chrome**. Smjer A (svijetli) je u
dizajn fajlu kao odbačena alternativa, sa obrazloženjem.

## Sadržaj paketa

| Fajl | Šta je |
|------|--------|
| `ui_chrome.gd` | **Paste-ready.** Boje, mjere, `chrome_style()`, `chip_style()`, `tab_style()`, `format_count()`. Ide u `game/scripts/visual/`. |
| `icons/*.svg` | 10 ikona, jednobojne `#2D3436`, viewBox 128×128. Tint iz koda preko `modulate`. |
| `Hub Chrome Redesign.dc.html` | Svi artboardi: spec sheetovi, 6 ekrana, edge case, ikone. Otvara se u browseru. |
| `HubScreen.dc.html` | Parametrizovan chrome (tema, stranica, aktivan tab, badge, lock, swipe, safe area). |

## Prenos — 4 koraka

### 1. Assets

Kopiraj `icons/` u `game/assets/ui/chrome/`, pa pokreni
`scripts/godot-import.ps1` i commituj `.import` fajlove (CLAUDE.md § Novi asset).

`icon_diamond.svg` zamjenjuje proceduralni placeholder u
`pickup_assets.gd::get_diamond_texture()`. `icon_coin.svg` i `icon_seed.svg`
su **chrome siluete** — `coin.png` i `seed.png` ostaju za pickupe u runu.

### 2. `ui_chrome.gd`

Kopiraj u `game/scripts/visual/ui_chrome.gd`. Dvije nove konstante treba dodati
i u `ui_palette.gd` ako ih koristi još neko:

```gdscript
const CHROME_DEEP := Color("#1A241E")   # tamnija varijanta #1F2B24
const PEACH_DEEP := Color("#E8A374")    # tamnija varijanta #FFB88C
```

### 3. Header — `RootVBox/TopBar`

| Sloj | Node | Vrijednost |
|------|------|-----------|
| `Header` | `TopBar` → **PanelContainer** | `UiChrome.chrome_style(true)` · sadržaj 140 px + rub 3 px. Pozadina mora biti **iza** safe-area margine (inače tamna traka iznad notcha). |
| `CoinChip` | `Panel/HBox/CoinChip` | 296 × 100 · r 20 · fill `COIN_GOLD #FFD56B` |
| `SeedChip` | " | 296 × 100 · fill `MINT #A8E6CF` |
| `DiamondChip` | " | 296 × 100 · fill `LAVENDER #D4A5FF` |
| ikone chipova | `TextureRect` | 56 × 56 · `modulate = OUTLINE #2D3436` |
| brojevi | `Label` | 48 px, weight 800, `#2D3436`, **desno poravnato**, tabular, max 190 px |
| `SettingsButton` | novi `UiClickButton` na mjestu `Spacer` | 100 × 100 · r 20 · fill `WARM_WHITE @ 10 %` · border 2 px `WARM_WHITE @ 38 %` · ikona 54 px `WARM_WHITE` · **hit-zona 140** (custom_minimum_size.y = 140) |

Horizontalni lanac (zbir = 1080): `20 · 296 · 16 · 296 · 16 · 296 · 20 · 100 · 20`.
HBox `gap = 16`, SettingsButton dodatno `+4` lijevo.

Brojevi u `refresh_top_bar()` idu kroz `UiChrome.format_count()`:
```gdscript
coins_label.text = UiChrome.format_count(GameState.wallet_coins)
```

**Uklanjanje duplog Settingsa** (§9 brief): `SettingsButton` iz `main_menu.tscn`,
pa ažurirati `main_menu.gd` (FieldUpgradeStack ~l. 325–332),
`season_field.gd` (~l. 171 meadow safe rect),
`meta_hub_flow_smoke.gd` (l. 195–200 provjerava obrnuto!), `season_meadow_smoke.gd`.

### 4. Footer — `RootVBox/PageIndicator/NavPanel`

Visina: `PageIndicator.custom_minimum_size.y = 180` (+ safe area).
Panel: `UiChrome.chrome_style(false)` — rub 3 px na **gornjoj** strani, sjena `offset (0,−6)`.

Vertikalni lanac (zbir = 180): `rub 3 · 5 · ActiveIndicator 8 · 4 · tile 152 · 8`.
Horizontalno: 5 × slot 216 · tile 196 · gutter 10. **Hit-zona je cijeli slot 216 × 180.**

`_build_tabs()` više ne može koristiti generički `UiClickButton` (treba ikona +
badge + lock) — napravi `game/scripts/ui/hub_tab.gd`:

| Stanje | Style | Ink |
|--------|-------|-----|
| neaktivan | `tab_style("inactive")` — bez fill i bordera | `WARM_WHITE @ 82 %` |
| aktivan | `tab_style("active")` — peach `#FFB88C` | `OUTLINE #2D3436`, label weight 800 |
| pritisnut | `tab_style("pressed")` — `WARM_WHITE @ 12 %` + `scale 0.96` | `WARM_WHITE @ 82 %` |
| aktivan pritisnut | `tab_style("active_pressed")` — `PEACH_DEEP #E8A374` | `OUTLINE` |

Ikona 52 px iznad labele 40 px, gap 10. Label je **uvijek vidljiva** na svih 5 tabova.

`ActiveIndicator` — 196 × 8 · r 4 · peach, `position.x = 10 + index * 216`.
Tween za tap (0,28 s cubic ease-out, isto kao snap).
Za praćenje prsta treba novi signal u `swipe_pager.gd`, npr.
`scroll_progress(f: float)` iz `_pages_host.position.x` → `x = 10 + f * 216`.

`TabBadge` — min 44 × 44 · r 22 · fill `#FFCCD5` · border 3 px `CHROME_DEEP` ·
tekst 26 px weight 800 `#2D3436` · pozicija tile top-right `(−8, +2)`.
Izvor: `GameState.count_collection_journal_news()`, refresh u `_on_page_changed`.
Stari Camp `collection_badge` postaje suvišan.

`NavLockPill` — **novi sloj**. h 64 · r 20 · `y = −36` od gornjeg ruba footera
(Control s negativnim offsetom; u VBoxu se footer crta poslije pagera pa je z-order OK).
Fill `CHROME_DEEP` · border 2 px `GOLD #E8C44A @ 85 %` · ikona 30 px + tekst
"ROUND IN PROGRESS" 26 px weight 800 `GOLD`, letter-spacing 0,08em.

`set_nav_locked(true)` sada radi tri stvari umjesto jedne:
1. gornji rub footera → `GOLD @ 85 %` (`chrome_style(false, true)`)
2. `NavLockPill` `visible = true`
3. neaktivni tabovi `modulate.a = UiChrome.LOCKED_TAB_ALPHA` (**0.6**, ne 0.45 —
   na 0.45 labela pada na 3,3:1, ispod 4,5:1 iz pristupačnosti)

Aktivan tab **ostaje pun peach** da igrač ne izgubi orijentaciju.

## Kontrast — provjereno

| Šta | Prema | Ratio |
|-----|-------|-------|
| Traka `#1A241E` | Journal `#FFF8F0` | 15,2:1 |
| " | Shop `#B8E0F5` | 11,4:1 |
| " | Home polje `#E6F2DB` | 13,8:1 |
| " | Moonlit Warren `#B8BDFF` | 8,9:1 |
| Rub `#FFF8F0 @ 55 %` | Camp `#2E4733` | 4,2:1 |
| " | Arena `#293D2E` | 4,6:1 |
| " | Home karusel `#243329` | 4,9:1 |
| Cifre `#2D3436` | coin gold / mint / lavanda | 9,0 / 9,0 / 6,4:1 |
| Ink aktivnog taba | peach `#FFB88C` | 7,5:1 |
| Ink neaktivnog taba | traka | 10,6:1 |
| Lock pill gold | traka | 9,4:1 |

Tijelo trake nosi svijetle stranice, rub od 3 px nosi tamne — jedna boja, oba slučaja.

## Font

Predlog: **Nunito** (OFL, weights 700/800/900). Tabular cifre rade u Godot Labelu.
Nije obavezno — bez custom fonta sve mjere ostaju iste, samo se cifre malo šire.
Ako se uzima, ide za cijelu igru, ne samo chrome.

## Gotovo kad

- [ ] Isti header i footer na svih 5 stranica (screenshot: svih 5 + Home polje u Country Bloom i Moonlit Warren)
- [ ] Settings samo u headeru; Home bez duplog Settingsa; FieldUpgradeStack i meadow dekor se ne sudaraju
- [ ] Brojevi do 6 cifara bez rezanja, `format_count()`
- [ ] Aktivan tab prepoznatljiv na **grayscale** screenshotu (4 signala: peach fill, puna visina tile-a, obrnut ink, indikator)
- [ ] Hit-zona tabova 216 × 180 i Settingsa 140 × 140
- [ ] Zaključana navigacija: gold rub + NavLockPill + 60 % dim
- [ ] Chrome se produžava u safe area bez tamne "rupe"
- [ ] Smoke: `swipe_snap_smoke`, `meta_hub_smoke`, `meta_hub_flow_smoke`, `arena_nav_lock_smoke`

## Van zadatka — nije u dizajnu

- Tap na chip → Shop: ne bih; chip je informacija, ne put do kupovine (Pillar 2).
- Count-up broja (0,25 s tween + scale 1,0→1,08→1,0 na ikoni) — jedina animacija koju predlažem u headeru.
- Badge i za Camp kad je daily spreman; boja ostaje `#FFCCD5` da badge znači "novo", ne "akcija".
- Gumeni otpor na krajevima: ActiveIndicator se rastegne 8 px na Shop/Arena ivici.
