---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, merge, pest, muncher, scratch]
povezano:
  - ideje-arena
  - ideje-arena-pitanja
  - ideje-arena-ciljevi
  - merge-arena-pest
  - merge-arena-v1.1
ai_sažetak: "ARENA-01 pest — Muncher ostaje pritisak; combo-break i extra freeze po A3/A16; igračka/cozy nisu default."
---

# IDEJE — ARENA-01 pest (Muncher + combo)

> [[ideje-arena|ARENA-01 hub]]. Kanon: [[../02-design/merge-arena-pest|merge-arena-pest]] MA-01b. Kod: [`arena_pest.gd`](../../game/scripts/camp/arena_pest.gd). ARENA-01 **ne** redesajnira Munchera osim hookova koje freeze A3 / A16 / A17 / A1 izaberu.

## Što Muncher jest danas

| Pravilo | Vrijednost |
|---------|------------|
| Spava | Nest vrh playfielda dok nema chipova |
| Wake | Pour s ≥1 chipom, delay `ARENA_PEST_WAKE_DELAY` 0.3 s |
| Jede | T1 i T2 na polju, ne bag, ne T3 (T3 ionako nestaje) |
| Eat | Radius 36, duration 0.5 s, speed 85 |
| Freeze | T3 merge → 2.0 s (`ARENA_PEST_T3_FREEZE`) |
| Prazno polje | Spava gdje je stao |
| Exit | Reset na nest |

Tutorial: *Pour seeds — watch the muncher! Merge to T3 to freeze it.* Flag `arena_pest_tutorial_shown`.

To je **jedini** izvor pritiska u areni. Bez njega je cozy sandbox. S njim je „požuri“, ali nakon učenja: jede sporije nego što vješt palac mergea, pa postane pozadinska animacija — ili smetnja kad pojede T2 koji si čuvao za T3.

Monotonija: pest se **ne mijenja** s tvojim skillom. Combo to može popraviti (nagrada freeze, ili kazna eat).

## Muncher vs combo (A16)

| Opcija | Pest u ARENA-01 kodu | Combo |
|--------|----------------------|-------|
| **A** pritisak; eat lomi combo ako A3 B/C | Hook `on_eat` → combo = 0 | Pest ima zube na streak |
| **B** T3 freeze + combo freeze se slažu | Extra freeze iz A1 B/D | Visoki combo = duži predah |
| **C** pest ne dirati | Nula izmjena `arena_pest.gd` | Combo čisti HUD |

A i B nisu isključivi: eat-break (A3) + extra freeze (A1 D) mogu zajedno. A16 C = „ne diraj pest FSM“ čak i ako A1=D — tada extra freeze **ne može** u isti slice. Freeze mora biti konzistentan: ako A1=D, A16 ne smije biti C.

### Extra freeze draft (ako A1 B ili D)

- Combo 2–4: +0.5 s
- Combo 5–7: +1.0 s
- Combo 8+: +2.0 s cap
- Stack s T3 freeze: `max(t3_freeze, combo_bonus)` ili **zbroj s capom** npr. 4 s. Draft: **zbroj, cap 4 s** da T3+combo 8 nije 2+2=4, a ne 10.

Ne freeze na svaki T1 merge — samo T3 (postojeće) + bonus iz combo **razine u trenutku T3**, ili trajni „combo freeze meter“. Jednostavnije: bonus primijeni **na T3 event** prema current combo. Eat-break nuluira prije T3 = nema bonusa. To je čitljivo.

## Što lomi combo (A3) — pest kut

Eat bilo kojg chipa = prekid ako B ili C.  
Jest T1 koji nije dio tvog para = „nije fer“ osjećaj. Jest T2 koji si čuvao = fer pritisak.

Ako A3=A (samo timeout), pest je vizualni šum za combo. I dalje jede ekonomiju (gubitak sjemena). Pillar 3: gubitak sjemena **nije** fail runa, ali boli. Ne mijenjati eat pravila u ARENA-01 osim A17.

## Muncher kao igračka (A17)

Katalog C. Default preporuka: **A ne sada**.

| Opcija | Što | Zašto čekati |
|--------|-----|----------------|
| **A** ne sada | — | Track je ciljevi, ne novi verb „feed“ |
| **B** nahrani 1 T1 namjerno → sitni bonus | Drag na pest = eat by player | Hit-test vs magnet; bonus (1 coin?) cap; nije P2W ako je slabo |
| **C** cozy: pest spava dok „challenge“ on | Settings / toggle | Dva moda arene; tutorial; save flag |

C dijeli publiku (cozy vs arcade). Veliki QA. Ne u A–C promptovima.

B: ako postoji, **ne** smije biti jedini način freezea. Core T3 freeze ostaje free.

## Rewarded freeze (A28)

Monetizacija uz ciljeve, ne pest redesign.

- **A** ništa novo. Daily/combo free.
- **B** rewarded „freeze pest 5 s“ na **prirodnoj pauzi** (prazno polje ili prije Done), nikad mid-drag.
- **C** IAP combo shield — **ne**. Osjeća se pay-to-merge.

Ako B: AdMob already u shop/loot. Arena ad = novi placement. Scope + policy. Parkirati osim eksplicitnog da. Pillar 2: merge radi bez ad.

## Cozy vs arcade (veza A2 / A21)

Kratki combo prozor + eat-break + pest speed 85 = arcade.  
Dugi prozor + A16 C + A21 bez tajmera = cozy s animiranim crvom.

Korisnik je izabrao **goals_on_top**, ne „ugasiti pest“. Pest ostaje dok A17 C ne kaže.

## Pip (A18) vs pest

Dva lika na playfieldu = šum. Ako A18=B (Pip na rubu), Pip **nije** kolizija, nije eat target, ne prekriva nest. Pest z-index iznad chipova, Pip ispod HUD-a.

## Tutorial (A26) vs pest tutorial

Pest tutorial već postoji. Combo tutorial (A26 A/B) **ne** smije prepisati pest rečenicu u istoj sesiji. Redoslijed: pest prvi pour (postojeće); combo toast nakon prvog streak 2. Dva flaga.

## Što pest doc **ne** mijenja bez freezea

- `ARENA_PEST_SPEED`, eat radius, wake delay — kanon `ekonomija-brojevi` / GameState.
- Nest pozicija.
- Eat T1/T2 (osim A10 B: T2 nestaje s polja pa pest jede samo T1).
- Reset na Done.

## Kod hookovi (kad dođe)

| Event | Combo | Freeze |
|-------|-------|--------|
| `on_t3_created` (već) | — | 2 s + bonus |
| `_pest_eat_chip` | combo=0 ako A3 B/C | — |
| combo timeout | combo=0 | ne dira pest |
| Done | combo=0 | `reset_to_nest` (već) |

Smoke: eat while combo 3 → 0; T3 at combo 5 → freeze ≥ 2 s (točno prema A1).

## Povezano

- [[ideje-arena|hub]] · [[ideje-arena-pitanja|A3 A16 A17 A18 A28]]
- [[../02-design/merge-arena-pest|MA-01b kanon]]
- [[ideje-arena-ciljevi|combo nagrada]]
- [[ideje-arena-bloom|T2 na polju = hrana]]
