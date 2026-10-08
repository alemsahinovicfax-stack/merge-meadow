---
type: iskustvo
status: aktivan
milestone: M8
tags: [dizajn, pip, skinovi, animacija, claude-design, izvjestaj]
povezano:
  - pip-cd-brief
  - wardrobe-cd-brief
  - art-direction
  - changelog
  - CHECKPOINT
ai_sažetak: "Izvještaj o prenosu CD paketa design_handoff_pip u Godot 2026-10-07: cutout rig, tri skina, 77 animacija, jedan UiPip na svim površinama."
---

# Pip redizajn — izvještaj o prenosu

> Roditelj: [[04-experience/_index|04-experience]] · paket: `design_handoff_pip/` · datum: 2026-10-07

## Ukratko

Pip više nije jedan `pip_idle.svg` s recolorom. U igri je **cutout rig**: dijelovi + overlayi + FX, atlas po skinu, dva AnimationPlayera. Classic / Blossom / Sky ostaju isti ID-jevi i cijene (0 / 250 / 200). Mehanika se ne mijenja.

- **Jedan čvor `UiPip`** crta Pipa na kartici (230, `card_idle`), polju (190, hop / idle / sniff / sleep), Areni (150, `arena_idle` + combo / T3), runu odozgo (150, galop + traka / pickup / pad), HUD-u (88, crop glave) i Shop / Ormar (3/4, poza ili `stage_idle`).
- **Novi skin = zapis** u `game/data/pip/skins.json` (7 tokena + overlayi). Dijelovi ostaju u Classic hexovima; recolor je isti mehanizam kao u Ormaru.
- **Stari `pip_idle.svg` / poze** ostaju u projektu kao rezerva (PipAssets, Mochi put, Camp biranje lika 80 px, stari smokeovi). Polje, kartica, run, Arena, HUD, Shop i Ormar više ih ne crtaju za Pipa.

## Po površini

| Površina | Pogled | Kutija | Loop / događaji |
|---|---|---|---|
| Home kartica (TravelPip) | front | 230 → 190 | `card_idle` |
| Home polje | front / side (hod) | 190 | `hop` 95 px/s · `idle` · `sniff` · `fall_asleep`/`sleep` · `apply` |
| Arena | front | 150 | `arena_idle` · `combo_hop` / `combo_big` · `merge_t3` |
| Run | top | 150 | `run_gallop` (`speed_scale = scroll/400`) · traka · pickup · `fail` 0,46 s → `fail_dizzy` · `finish` |
| Run HUD | front, crop 176 | 88 | `hud_idle` · go / happy / wow / hit / proud |
| Shop Looks | three_q | ~240 | poza skina, tap = potpis |
| Ormar pozornica | three_q | ~240 | `stage_idle`, izbor = `stage_hop` |
| Ormar sličica | three_q | ~126 | poza, mirno |

## Nalazi

1. **CD `ui_pip.gd` nije radio 1:1.** Atlas je keširan po pogledu, overlay čvorovi su ispušteni na Classicu pa animacije nisu imale putanje. Sada se svi čvorovi iz riga prave uvijek, a sprite overlaya samo ako ga skin ima. Rest poze se čitaju iz `rig.json`, ne s prve instance.
2. **`GameState.reduce_motion` postoji** (sezone faza 2, 2026-10-06); Settings ekran još nema prekidač. `UiPip.reduce_motion()` čita taj flag kad je GameState u stablu. Magnet prsten u runu ostaje skalirani čvor iz faze 2, ne Sprite2D.
3. **SVG fajlovi nose C2PA metapodatke** (~8 KB po fajlu), isto kao cvijeće iz sezona. U igri ne smeta (raster se peče u atlas).
4. **Brief `pip-cd-brief.md` i `pip-ref/` su na masteru** (commit 2026-10-07, povučen prije prenosa). CD je radio po kodu i chatu jer brief tada nije bio na grani s koje je slao paket.

## Još nije u ovoj rundi (u paketu postoji)

Ovo je namjerno ostavljeno za playtest / sljedeći prolaz, da prvo stigne lik na sve ekrane:

- Tap eskalacija na polju (`tap_giggle` → `flop`) — Pip i dalje `MOUSE_FILTER_IGNORE`, da ne krade dodir s cvijeća i Looks pločice.
- 16 sezonskih interakcija s rekvizitom (leptir, maslačak, mjesec…).
- Arena look-at dok vučeš sjemenku.
- HUD `hud_worried` pri malo vremena.
- Brisanje `pip_idle.svg` / `pip_sniff.svg` / `pip_sleep.svg` / pečenih wardrobe SVG-a i `PipDraw` rezerve.

## Testovi

- `pip_rig_smoke` — 77 animacija, 3 skina, 5 pogleda, atlas 1024, `apply` kreće.
- `wardrobe_smoke` — recolor ključevi se provjeravaju na `body_f.svg`; ApplyMoment i dalje `play_apply()`.

## Odluke koje čekaju tebe

1. Je li novi lik OK na 88 px HUD-u i u runu odozgo, ili treba pecati portret (`pip_hud_*.svg` su već u paketu)?
2. Hoćeš li odmah sezonske interakcije i tap na polju, ili poslije playtesta?
3. ~~`pip-cd-brief.md` — upisati u repo?~~ Riješeno: brief i `pip-ref/` su na masteru.
