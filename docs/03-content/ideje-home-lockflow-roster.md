---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, roster, kontrast, sezone, scratch]
povezano:
  - ideje-home-lockflow
  - ideje-home-lockflow-pitanja
  - ideje-home-cardfit-roster
  - ideje-home-incard-roster
ai_sažetak: "HOME-10 roster — lijevi clip jer min 320 > anchor 0.48; širi desno ~0.78–0.88; puna imena bez ellipsisa; niska alpha wash + apply_season na morph midpoint."
---

# IDEJE — HOME-10 roster širina, imena, wash

> [[ideje-home-lockflow|hub]]. Parent, 6 redova, T3+★+ime, HIT-A IGNORE, L/R i preview bez rostera — ostaje [[ideje-home-incard-roster|HOME-08]] / [[ideje-home-cardfit-roster|HOME-09]]. **Docs LOCKFLOW-P0 ✅.** **Kod LOCKFLOW-B ✅** (A sakrije roster na locked).

## Što je krivo (nije „font je mali“)

CARDFIT-B je uradio tri stvari: per-season `SeasonCardContrast`, naslov sredina, `custom_minimum_size.x = 320` uz `anchor_right = 0.48`. Playtest: **prikaz i dalje nije dobar**.

### 1. Lijevi clip — math

`FreeRoster` / `PaidRoster` u [`season_stage.tscn`](../../game/scenes/ui/season_stage.tscn):

```
custom_minimum_size = Vector2(320, 348)
anchor_top = 1.0
anchor_right = 0.48
anchor_bottom = 1.0
offset_left = 8.0
offset_top = -356.0
offset_right = -8.0
offset_bottom = -8.0
grow_horizontal = 2
```

Dodijeljena širina = `0.48 * parent_width + offset_right - offset_left` ≈ **0.48w − 16**.

| Parent (CenterFill) | Sidro px | Min 320 | Overflow |
|---------------------|----------|---------|----------|
| 360 | ~157 | 320 | **~163 px lijevo** |
| 400 | ~176 | 320 | **~144 px lijevo** |
| 480 | ~214 | 320 | **~106 px lijevo** |

`CenterSlot.clip_contents = true` reže x < 0. Prvi child reda je **ikona 52 px** — nestaje prva. Igrač: „cvijeće se ne vidi, prikaz biježi lijevo.“

P109 je tražio min 320 **i** 0.42–0.50 kartice. Ta dva broja se **ne slažu** na hero slotu: 0.48 od 400 je 192, ne 320. Agent je podigao min bez sidra. HOME-10: **sidro prati širinu**, min ne smije biti veći od dodijeljenog pravokutnika.

Gate danas drži desni kut (`offset_left = -228`). Zato CARDFIT-B nije smio rasti desno. LOCKFLOW-A **skriva roster na locked** i **miče gate s desnog kuta**. Na unlocked kartici gate ga nema — roster **smije** ići desno (playtest: „raširi prikaz cvijeća malo još u desnu stranu“).

### 2. Ellipsis — nije fallback, to je fail

[`season_roster_panel.gd`](../../game/scripts/ui/season_roster_panel.gd):

```
name_l.size_flags_horizontal = SIZE_EXPAND_FILL
name_l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
```

Font 22 + ikona 52 + zvijezde 56 + separation + padding. Na **vidljivom** sliveru nakon lijevog clipa ostaje ~80–120 px za ime. `Paper Lantern Bloom`, `Golden Oak Bloom`, `Dusk Firefly Grass`, `Pearl Waterlily` idu u `...`.

P109: „ellipsis samo fallback.“ Playtest: **ne smije**. Puna imena. Ako 0.85 Filla još nije dosta na uskom desktop windowu: **autowrap 2 reda**, `OVERRUN_NO_TRIMMING` (ili maknuti overrun). Ne smanjivati font ispod 22 dok širina nije iscrpljena. Ne smanjivati ikonu 52.

### 3. Boja kasni — opaque naljepnica + kasni `apply_season`

[`season_card_contrast.gd`](../../game/scripts/ui/season_card_contrast.gd): `FRAME_ALPHA = 0.88`, svijetle sezone `mood.darkened(0.55)`. To je tamna ploča.

Morph: `_fill_free_slots()` na **midpointu** mijenja StyleBox kartice. `_refresh_roster()` je u `refresh()` na **kraju** tweenea (`_finish_free_morph`). Pola swipea: nova kartica, stari tamni roster. Playtest: „izgleda kao glitch.“

Smjer igrača: **blaga, transparentna pozadina**, da se već vidi slična boja (boja kartice sja kroz wash). Nije treća paleta. Isti `_mood_color` / `SeasonCardContrast.mood_color`. Samo **niža alpha** (preporuka **0.20–0.35**), manje `darkened` (ili wash = mood @ niska alpha bez 0.55 darken — kartica već daje kontrast).

Tekst (imena, zvijezde) i dalje mora biti čitljiv: luminance pravilo P108 ostaje. Na svijetloj kartici + blagi wash, cream na gotovo-prozirnom mintu može nestati — zato wash smije ostati malo tamniji od kartice **ili** tekst ink prati karticu (tamni na Bloomu, cream na Moonlitu). Agent u B bira: čitljivost > vjernost 0.55 darken.

Uz wash: zvati `apply_season` u `_apply_free_cycle` / `_apply_paid_cycle` (**midpoint**), ne čekati `_finish_*_morph`. Tada i da je alpha 0.5, boja se mijenja s karticom.

## Širina (P121)

Sidro i dalje **donji lijevi** kut (`anchor_top/bottom = 1`, `offset_left = 8`, `offset_bottom = -8`). `clip_contents` na slotu ostaje (redovi ne curu na L/R susjede).

| Danas (CARDFIT-B) | Cilj (B) |
|-------------------|----------|
| `anchor_right = 0.48` | **~0.78–0.88** (raspon; preferiraj ~0.85) |
| `offset_right = -8` | ostaje mali inset, **ne** gurati desni rub lijevo od sidra |
| `custom_minimum_size.x = 320` | **~380–420** **ili** min ≤ stvarno sidro (min ne smije pobijediti i rasti lijevo) |
| `grow_horizontal = 2` | `0` (begin) ili desni grow; **ne** both ako min > sidro |
| Gate dijeli desni kut | A: gate centriran donja polovica, roster hidden na locked → B slobodan desno |

Ikona 52 / font 22 / zvijezde 18 / red 56 **ostaju**. Visina 348 / 6×56 ostaje; ako clip reže 6. red na `HERO_MIN` 300, smanjiti `ROW_H` ~48 **nakon** širine. Ne vraćati naslov gore.

### Pravilo protiv lijevog overflowa

Prije smoke-a: `FreeRoster.position.x >= 0` na hero Bloom. `FreeRoster.size.x` ≈ `anchor_right * CenterFill.width` (nije 320 na uskom sidru 0.48). Ako min i sidro ratuju, **pobjeđuje sidro** (spusti min), ne clip.

## Imena (P121, nastavak)

- `text_overrun_behavior` → nema trim ellipsis.
- `autowrap_mode` = word wrapping, max 2 vizualna reda ako treba (`autowrap` + dovoljna visina reda, ili `ROW_H` malo gore samo za wrap).
- Smoke: na hero Bloom `Harvest Pumpkin` **točan** string u labelu (nema `…` / `...`). Na Lantern (nakon A unlock ili direktan apply) `Paper Lantern Bloom`. Na Amber `Golden Oak Bloom`. `has_entry` već postoji — proširiti da fail-a ako `text` sadrži ellipsis character.

48 stubova i `seed_type_ids` **ne dirati**.

## Wash + midpoint (P122)

`SeasonCardContrast`:

- `FRAME_ALPHA` s 0.88 → **~0.20–0.35** (otvoreno: točan broj; preporuka 0.28).
- `darkened(0.55)` na svijetlima smije pasti na **~0.15–0.25** ili nestati: wash = `mood` s niskom alphom. Ember i dalje treba čitljiv tekst na plamenu — ne oprati imena.
- Border @ 0.35 može ostati tanji / slabiji (wash nije „okvir naljepnice“).
- Radius 12, padding 12 ostaju.
- `apply_season` i dalje rebuilda StyleBox (CARDFIT-B). Gate na locked (A) smije isti wash da barovi nisu crna kutija na jantaru.

`season_stage.gd` `_apply_free_cycle` / `_apply_paid_cycle`: uz `_fill_*_slots` pozvati `_refresh_roster()` (i gate ako treba) **na midpointu**. `_finish_*_morph` i dalje `refresh()` — idempotentno.

Ne treća hex paleta.

## Paid (P123)

`PaidRoster` isto sidro, ista širina, isti wash, isti no-ellipsis. Coral / Moonlit / Starfall. **Bez** Unlock gatea. Ember TEST_LOCK: ako ikad u paid centru, roster da, coin Unlock ne.

## Što ne dirati u LOCKFLOW-B

- 500/20, gold variant, gate sidro, hide roster na locked (A)
- TEST_LOCK Ember, debug skip
- Band 20/80, L/R in-place **mehanika** (samo dodatni `apply_season` call)
- Shop Select, AdMob, SAVE_VERSION, `seed_type_ids`, 48 imena/rarity
- Naslov full-rect CENTER

## Tehnički (za LOCKFLOW-B, ne P0 kod)

- [`season_stage.tscn`](../../game/scenes/ui/season_stage.tscn): `FreeRoster` / `PaidRoster` `anchor_right` ~0.85, min usklađen, grow ne both-left.
- [`season_roster_panel.gd`](../../game/scripts/ui/season_roster_panel.gd): skinuti ellipsis; autowrap.
- [`season_card_contrast.gd`](../../game/scripts/ui/season_card_contrast.gd): niža alpha / blazi darken.
- [`season_stage.gd`](../../game/scripts/ui/season_stage.gd): `_refresh_roster` u morph midpoint.
- Smoke [`season_home_smoke.gd`](../../game/scripts/dev/season_home_smoke.gd): `FreeRoster.position.x >= 0`; `size.x` >> 260 i nije manji od ~0.7 Fill; Bloom vs Moonlit wash i dalje različit `bg_color` (alpha može biti ista, RGB ne); imena bez `...`; CenterTitle i dalje CENTER (regresija).

Headless OpenGL. `godot-run.ps1` jednom na kraju B. Ne watcher.

## Acceptance

- Country Bloom hero: lista cvijeća **u** kartici, ikone vidljive, nije odsječena lijevo; Harvest Pumpkin puni string.
- Roster ide **desno** (većina širine Fill-a), ne preko L/R susjeda (`clip` drži).
- Swipe Bloom → Frost: wash se mijenja **s** karticom, nema pola sekunde starog tamnog mint okvira na plavoj kartici.
- Lantern nakon Unlock (A): Paper Lantern Bloom, Dusk Firefly Grass puna imena.
- Amber roster (kad playable): Golden Oak Bloom bez `...`.
- Locked Lantern (A): roster **nije** vidljiv — ovaj slice to ne vraća.
- Moonlit paid-hero: isti širi panel, wash, tamni tekst čitljiv.
