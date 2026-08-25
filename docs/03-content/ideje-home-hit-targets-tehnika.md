---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, godot, hit-targets, tehnika, scratch]
povezano:
  - ideje-home-hit-targets
  - ideje-home-hit-targets-gesta
  - ideje-home-hit-targets-pitanja
  - konvencije-koda
  - greske-katalog
  - scene-node-pravila
ai_sažetak: "HOME-02 tehnika — mouse_filter IGNORE na Row/slotovima; Stage STOP; ne dirati Browser/sheet; smoke ograničenja."
---

# IDEJE — HOME-02 tehnika (Godot hit-through)

> [[ideje-home-hit-targets|HOME-02 hub]]. Kod tek u **HIT-A**. Ovdje: zašto STOP lomi geste i točan popravak.

## Godot model (4.x Control)

`mouse_filter`:

| Enum | Int u `.tscn` | Značenje |
|------|----------------|----------|
| `MOUSE_FILTER_STOP` | `0` | Ovaj node je meta; roditelj **ne** vidi `gui_input` za tu točku |
| `MOUSE_FILTER_PASS` | `1` | Ovaj prima, pa **i** roditelj (rjeđe nam treba) |
| `MOUSE_FILTER_IGNORE` | `2` | Ovaj **nije** meta; picking ide na to što je „ispod“ / roditelj |

`SeasonStage` (`Control`, STOP) ima `gui_input` → `_on_stage_gui_input`. Djeca:

- `Row` (`HBoxContainer`) — default STOP
- `LeftSlot` / `CenterSlot` / `RightSlot` (`PanelContainer`) — u sceni **eksplicitno** `mouse_filter = 0`
- `*Title` (`Label`) — default STOP
- `%SeasonBrowser` / `%SeasonUnlockSheet` — overlayi, **STOP** kad hvataju klik

Dok su slotovi STOP, picking bira slot. Stage handler **šuti**. `_handle_tap` s `has_point` je mrtav kod za realne tapove na karticu.

`clip_contents = true` na `Row` **ne** objašnjava dead zone na **punoj** kartici (kartica je unutar clipa). Clip objašnjava samo peek rubove. Glavni bug = filter, ne clip.

## Preferirani popravak (HIT-A)

**Stage ostaje STOP** (mora biti meta za cijeli rect + `block_hub_swipe`).

**Sva vizualna djeca trake** (`Row` i potomci **osim** Browser/sheet) → `MOUSE_FILTER_IGNORE`.

Tada picking pada na Stage. Postojeći mouse+touch handler radi. `_handle_tap` `global_rect` na slotovima i dalje radi jer rect **postoji** bez obzira na filter.

### Zašto rekurzija u `_ready`, ne samo `.tscn`

Novi Label / ColorRect / TextureRect na kartici u kasnijem art passu opet bi bio STOP. `_ignore_hits(row)` na svakom `Control` childu drži invariant.

**Ne** zvati rekurziju na cijeli Stage: poklopio bi Browser i sheet.

```gdscript
func _ignore_hits(n: Control) -> void:
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		if c is Control:
			_ignore_hits(c as Control)
```

U `_ready`, **nakon** `@onready` (row postoji):

```gdscript
if row:
	_ignore_hits(row)
```

Scena: smije se uskladiti `mouse_filter = 2` na Row/slot/title radi čitljivosti u editoru; izvor istine i dalje `_ready`.

### Što ne IGNORE-ati

| Node | Filter | Zašto |
|------|--------|--------|
| `SeasonStage` | STOP | Handler + hub block |
| Browser root | STOP (kad visible) | Lista, paid red, close |
| Unlock sheet | STOP | P11 gumbi, dim |
| `PlayButton` (nije child Stagea) | ostaje | Play |

Ako Browser u sceni živi kao sibling ispod Row i dobije IGNORE greškom, **ne možeš** otvoriti listu niti zatvoriti overlay. P32 je tvrdi invariant.

## Fallback A — PASS na slotovima

Ako IGNORE + parent STOP u nekoj Godot 4.7 kombinaciji ne dostavi event (rijetko, ali katalog grešaka voli dokaz):

- Slotovi `PASS` + `gui_input` na svakom slotu koji zove **isti** `_on_stage_gui_input`.
- Rizik: double-fire ako i Stage primi (PASS). Tada Stage IGNORE? Ne — Stage mora ostati meta. Bolje: **samo** slotovi STOP + forward, Stage **ne** connect na sebi nego samo slotovi… ali tada **gap** (G) opet nema meta osim Stagea.

Zato je IGNORE-na-djeci + STOP-na-Stageu **jedini** čist model za gap+kartice zajedno. Fallback A koristiti samo ako playtest dokaže da IGNORE ne radi; tada Stage STOP + djeca IGNORE i dalje prvi pokušaj debug (da nije drugi node preko trake).

## Fallback B — nevidljivi puni hit Control

`HitCatcher` ColorRect `mouse_filter=STOP` preko cijelog Stagea, `z_index` iznad Row, `modulate.a=0`, djeca IGNORE. Handler na catcheru. Vizual ispod.

**Ne** kao prvi HIT-A: dupli sloj, lako pokrije Play ako krivi parent. Rezerva.

## Z-order provjera prije koda

U `main_menu.tscn`, `SeasonStage` je u `HomeColumn` **iznad** Play. Play je **ispod** trake, ne overlay. Chest je u `HomeTopStack` gore. Nema razloga da Play krade swipe trake.

Ako netko stavi full-screen `HomeColumn` STOP, hub swipe umire — to je HOME-A: Column IGNORE. HIT-A to **ne** mijenja.

## `_handle_tap` semantika — ne dirati osim buga

Redoslijed danas: L rect → R rect → else Browser. Centar **nije** poseban rect; pada u else. To je točno za **C i G** (P29).

Rijeđi edge: tap točno na granici L i C — `has_point` L prvi. Prihvatljivo.

Ne pretvarati slotove u `Button` / `gui_input` clicked: Button jede swipe.

## Tween / bounce

HOME-C bounce je `row.modulate.a`, ne `position.x` (HBox pregazi x). HIT-A ne dira tween. IGNORE ne smije pokvariti modulate.

## Smoke (ograničenje)

`season_home_smoke.gd` **ne** simulira prst na pixelu. Headless DoD:

1. Postojeći unlock / strip / badge asserti i dalje prolaze.
2. Opcionalno: nakon loada Home, `LeftSlot`/`CenterSlot`/`RightSlot` `mouse_filter == MOUSE_FILTER_IGNORE` (i npr. `Row`). Stage `== STOP`.
3. Ne forsirati InputEvent injekciju osim ako je već pattern u projektu (nije potreban za P0).

Čovjek: gesta skripta u [[ideje-home-hit-targets-gesta|gesta]] § playtest.

`skip_debug_season_unlock` ostaje na početku home smoke.

## Katalog grešaka (nakon HIT-A ako pukne)

Ako agent potroši vrijeme: novi unos u [`greske-katalog.md`](../05-technical/godot/greske-katalog.md):

**Simptom:** swipe sezona samo u rupama.  
**Uzrok:** child STOP.  
**Rješenje:** IGNORE na Row tree.  
**Prevencija:** ovaj doc + assert u smoke.

Ne dodavati unos u HIT-P0 (nema još potrošenog debug vremena na kod).

## Datoteke HIT-A (predviđeno)

| Fajl | Izmjena |
|------|---------|
| `game/scripts/ui/season_stage.gd` | `_ignore_hits(row)` u `_ready` |
| `game/scenes/ui/season_stage.tscn` | opcionalno `mouse_filter = 2` na Row/slot/title |
| `game/scripts/dev/season_home_smoke.gd` | assert filtera |
| Docs CHECKPOINT / changelog | HIT-A ✅ |

**Ne:** `game_state.gd` season math, Shop, `main_menu.tscn` Play, Browser skripta osim ako overlay slučajno IGNORE.

## OpenGL / Godot launch

Isto pravilo: headless `--rendering-driver opengl3`; na kraju `.\scripts\godot-run.ps1` jednom. Ne `godot-watch` dok agent edita.

## Povezano

- [`season_stage.gd`](../../game/scripts/ui/season_stage.gd)
- [`season_stage.tscn`](../../game/scenes/ui/season_stage.tscn)
- [[../05-technical/godot/dev-workflow|dev-workflow]]
