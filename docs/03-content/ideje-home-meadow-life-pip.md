---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, sezone, meadow, pip, scratch]
povezano:
  - ideje-home-meadow-life
  - ideje-home-meadow-life-pitanja
  - ideje-home-meadow-life-layout
  - ideje-home-meadow-pip
  - plan-prompts-home-meadow-life
ai_sažetak: "HOME-14 D — MeadowPip u polju: hod, njuh, spavanje; anti-repeat; clamp na chrome-safe rect. Portrait ostaje off."
---

# IDEJE — HOME-14 Pip (hod / njuh / spavanje)

> [[ideje-home-meadow-life|hub]] · freeze P187–P189, P196.  
> **Kod:** **LIFE-D ✅** 2026-09-01. Ovisi o C (safe rect + cvijeće). Override P160. Ne dirati run Pip.

## Override CHROME-A / MEADOW-C

HOME-13 je sakrio `%MeadowPip` i ugasio flower-index Tween. UniqueName i [`season_field_pip.gd`](../../game/scripts/ui/season_field_pip.gd) (`PipDraw.draw_pip`, IGNORE) ostaju.

D: u **otvorenom** polju Pip je **visible**. Close / karusel: hide + stop FSM. Jedan node; Frost reuse `instance_id`. Ne `pip_visual.gd`. `%PipPortrait` **ostaje hidden** (P189).

## Stanja

Ne hodati 0→1→2→3 po slotovima (to je repetitivno).

| Stanje | Što |
|--------|-----|
| **Hod** | Sporo, ease in-out, destinacija random u **safe rectu** ili prema cvijetu. |
| **Njuh** | Kratko kod cvijeta; **ne** isti cvijet kao zadnji njuh. |
| **Spavanje** | Duži idle (jitter 2–5 s), točka u safe rectu (smije biti pored cvijeta). |

Sljedeće stanje: weighted random **bez odmah istog**. Cilj: opušten, prirodan, bez vidljive A-B-A petlje. Jitter trajanja. Smije flip facing ako already postoji u draw-u — ne novi sprite sheet.

Clamp sve točke na isti chrome-safe helper kao C. `z_index` ispod Play/Daily.

`_hide_pip_and_stop` više **nije** jedini path na `apply_season` / rebuild — open restarta FSM; rebuild cvijeća ažurira targete (ne hoda prema freed nodeovima).

## Što D **ne** radi

- Klik na Pipa. Run companion API. Drugi Pip tscn po sezoni. Portrait na karuselu. Play routing. PlayRow size. Flower **count** (to je C).

## Smoke (P196)

[`season_meadow_smoke.gd`](../../game/scripts/dev/season_meadow_smoke.gd):

- Bloom/Frost open: MeadowPip **visible**, IGNORE, točno 1, isti `instance_id` na Frost. `is_pip_alive` ili wander/FSM running (ne `should not wander` iz CHROME-A).
- Close: hidden, tween/FSM off.
- Karusel: hidden.
- **Ne** assertirati točan sniff frame ni redoslijed stanja.

CHROME-A assertovi „Pip hidden / ne wander“ u meadow smoke **zamijeniti** ovim. Home smoke: PipPortrait i dalje hidden.

## Acceptance D

- U polju Pip živi: šeta, njuši, spava; ne ide pod gumbe.
- Na karuselu nema MeadowPip ni portraita.
- Run Pip netaknut.
