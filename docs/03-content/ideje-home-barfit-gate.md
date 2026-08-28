---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, unlock, gate, sezone, scratch]
povezano:
  - ideje-home-barfit
  - ideje-home-barfit-pitanja
  - ideje-home-lockflow-gate
  - ideje-home-cardfit-gate
ai_sažetak: "HOME-11 gate — spustiti UnlockGate ispod 🔒+ime; StyleBoxEmpty (nema wash okvira); debug wallet ≥ 500 i T3 ≥ 20 da Unlock bude zlatan."
---

# IDEJE — HOME-11 locked barovi (pozicija, bez okvira, debug 500c)

> [[ideje-home-barfit|hub]]. Widget, parent, sequential `can_unlock_free`, Seeds = T3, gold, hide roster, 500/20 JSON — **ostaju** iz [[ideje-home-lockflow-gate|HOME-10 gate]]. **Kod BARFIT-A ✅.**

Ovo nije novi poster. Poster je LOCKFLOW-A. Ovo je **geometrija + chrome + debug fixture** tog postera.

## Layout — spusti gate (P129)

Danas [`season_stage.tscn`](../../game/scenes/ui/season_stage.tscn) `%UnlockGate`:

```
custom_minimum_size = Vector2(280, 188)
anchor_left = 0.12
anchor_top = 0.48
anchor_right = 0.88
anchor_bottom = 1.0
offset_top = 8.0
offset_bottom = -12.0
grow_horizontal = 2
z_index = 1
```

Cilj: prvi sadržaj (Coins label) počinje **ispod** bloka `🔒` + ime. Naslov ostaje full-rect CENTER. Katanac ostaje prvi red naslova (`🔒\n%s`) — ne vadimo ga u poseban node.

### Preporučena sidra (agent bira točan broj u A, unutar raspona)

| Property | Danas | HOME-11 |
|----------|-------|---------|
| `anchor_top` | `0.48` | **~0.62** (raspon **0.58–0.70**) |
| `offset_top` | `8` | `0`–`12` (ne gurati natrag gore) |
| `anchor_left` / `right` | `0.12` / `0.88` | **ostaje** (centrirano, ne desni kut) |
| `anchor_bottom` | `1.0` | ostaje |
| `offset_bottom` | `-12` | ostaje (zrak od dna kartice) |
| `custom_minimum_size` | `(280, 188)` | visina smije **pasti** (~160–180) jer nestaje frame padding 10; širina 280 ostaje ili raste s sidrom |
| `z_index` | `1` | ostaje — iznad fill-a, ispod ničega važnog |
| `clip_contents` na `CenterSlot` | `true` | ostaje |

```
        [ 🔒 ]
        [ ime sezone — i dalje H+V CENTER, full-rect ]
                    ↓ praznina, ime se vidi
              Coins  n / 500     bar
              Seeds  n / 20      bar
                    [ Unlock ]
```

Ako `0.62` ostavi previše praznog između imena i Coins: spusti prema **0.58**, ne ispod **0.55** (tada opet jede ime). Ako gumb clipa dno: smanji VBox `separation` ili min height, **ne** diži `anchor_top` natrag na 0.48.

Horizontala: i dalje centrirano. Ne `anchors_preset = 3`. Smoke LOCKFLOW-A (`anchor_left >= 0.5` fail) ostaje; **dodati** `anchor_top >= 0.58`.

`grow_vertical` ostaje 0 (BEGIN / ne both) da min height ne raste **gore** u ime. Ako min.y + sidro opet guraju prema naslovu, spusti min.y prije nego vratiš 0.48.

L/R slotovi i preview 20% **bez** gatea — ne dirati.

## Frameless (P130)

[`season_unlock_gate.gd`](../../game/scripts/ui/season_unlock_gate.gd) `_apply_frame` danas zove `CONTRAST.make_frame(season_id, 10)` na **samom** `UnlockGate` PanelContaineru.

HOME-11: **nemoj** stavljati wash+border na gate.

Opcije (preporuka 1):

1. **`StyleBoxEmpty`** ili `StyleBoxFlat` s `bg_color.a = 0`, `border_width = 0`, **content margin** ~6–8 da label/gumb ne lijepi rub sidra.
2. Promijeniti `UnlockGate` iz `PanelContainer` u obični `Control` / `MarginContainer` — veći tscn diff, nije potreban ako empty StyleBox radi.

Tekst Coins/Seeds: i dalje `CONTRAST.text_color(season_id)` (cream na svijetlim karticama, ink na Moonlit — locked free su svijetle, cream ostaje čitljiv na mood fillu kartice **bez** tamnog wash panela). Ako cream na Bloom/Lantern padne bez panela: tint labele prema `TITLE_DARK` / luminance, **ne** vraćaj `make_frame` na gate.

`_apply_frame` smije ostati ime funkcije; tijelo postavlja empty box + ink na labele. Ne dirati `SeasonCardContrast.FRAME_ALPHA` globalno — to je roster.

ProgressBar: ostaje Godot default ili postojeći theme. To nije „okvir prikaza“.

Unlock gumb: i dalje `UiClickButton` subtle/gold. To nije gate panel.

## Debug 500 coins (P132, P133)

Playtest: „Daj 500 coinsa po defaultu da testiram dugme.“

| | Produkcija | Debug playtest (HOME-11) |
|--|------------|---------------------------|
| Novi igrač wallet | 0 | **max(trenutni, 500)** |
| `seasons.json` `coins_cost` | 500 | 500 (ne dirati) |
| T3 za gold gumb | igrač farm-a | **max(count, 20)** preporuka — inače gumb ostaje sivi |
| Persist | save | da, `save_player_save()` kao `debug_unlock_all` |
| `skip_debug_season_unlock` | n/a | **ne** grantaj (smokes ostaju deterministic) |

Gdje: isti uvjet kao postojeći debug unlock u [`main_menu.gd`](../../game/scripts/ui/main_menu.gd):

```
if OS.is_debug_build() and not GameState.skip_debug_season_unlock:
    GameState.debug_unlock_all_seasons()
    GameState.debug_grant_unlock_test_funds()   # novo, ime po agentu
```

Ponašanje helpera (debug-only, no-op u release):

1. `wallet_coins = maxi(wallet_coins, 500)` — **nikad** smanjiti 2000 na 500.
2. Ako `t3_flower_count() < 20`: dodaj clover (ili postojeći stash key) dok suma ne bude ≥ 20. Ne brisati druge kristale.
3. `save_player_save()`.
4. **Ne** grantati `lantern_meadow` / `amber_canopy`. `debug_unlock_all` i dalje skipa ta dva + Ember.
5. **Ne** SAVE_VERSION. **Ne** slijepo brisati save.

Zašto T3 uz coins: `can_unlock_free` je AND. Samo 500c → Coins bar pun, Seeds prazan, Unlock **sivi**. Playtest želi testirati **dugme** (zlato + tap). Fixture bez 20 T3 laže.

Headless smokes postavljaju `skip_debug_season_unlock = true` i **sami** setaju wallet 0 / 499 / 500. BARFIT grant se u smokeu **ne** pali. Asserti 499 → subtle, 500+20 → gold **ostaju**.

## Što ostaje iz LOCKFLOW-A (ne dirati)

- `refresh_gate` uvjeti (free hero, next-lock, selectable, not playable)
- Gold / subtle + STOP / IGNORE
- Roster hidden dok `unlock_gate.visible`
- Sequential `previous_free_id`
- JSON 500/20
- Ember TEST_LOCK; paid bez coin gatea
- CenterTitle full-rect CENTER
- `🔒\nime` string na locked slotu

## Tehnički (za BARFIT-A, ne P0 kod)

- [`season_stage.tscn`](../../game/scenes/ui/season_stage.tscn): `%UnlockGate` `anchor_top` ~0.62; min.y po potrebi; horizontala ista.
- [`season_unlock_gate.gd`](../../game/scripts/ui/season_unlock_gate.gd): `_apply_frame` bez `make_frame` wash/border; ink na labelama ostaje.
- [`game_state.gd`](../../game/scripts/autoload/game_state.gd): debug helper grant 500c + 20 T3 floor; no-op van debuga.
- [`main_menu.gd`](../../game/scripts/ui/main_menu.gd): poziv uz `debug_unlock_all_seasons`.
- Smoke [`season_home_smoke.gd`](../../game/scripts/dev/season_home_smoke.gd): `UnlockGate.anchor_top >= 0.58`; panel bg alpha ~0 ili empty StyleBox (nije opaque wash); `CenterTitle` i dalje sadrži `🔒` i ime; roster hidden na locked; 499/500 gold asserti ostaju; `skip_debug_season_unlock` i dalje true u smokeu.
- Headless OpenGL. `godot-run.ps1` jednom na kraju A. Ne watcher.

## Acceptance

- Locked Lantern (ili Frost na novom saveu) u hero-centru: **vidi se katanac**, **vidi se puno ime**, barovi **ispod**, nisu preko teksta.
- Nema drugog pravokutnog okvira/wash panela oko barova. Kartica sja kroz. Trake i Unlock gumb vidljivi.
- Debug play: wallet ≥ 500 i T3 ≥ 20 → Unlock **zlatni**, tap i dalje `unlock_free`.
- Nakon unlock: gate nestaje, roster te sezone (HOME-10).
- Amber kad je next-lock: isti niži frameless poster.
- Produkcijski (non-debug) starting coins i dalje 0. JSON i dalje 500/20.
- Ember / Coral: bez coin gatea.
