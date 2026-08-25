---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, merge, feel, juice, ux, scratch]
povezano:
  - ideje-arena
  - ideje-arena-ciljevi
  - ideje-arena-pitanja
  - merge-arena-v1.1
ai_sažetak: "ARENA-01 feel — pair pulse, sort, clutter/pour, juice; D0-P overlap na SFX; nije prvi kod osim A12/A33."
---

# IDEJE — ARENA-01 feel (pulse, sort, clutter, juice)

> [[ideje-arena|ARENA-01 hub]]. Prioritet **B**: podržava combo da nije slijep lov. U prvi kod ulazi samo ako A12 / A13 / A33 to kažu. Juice (čestice, ding) se **ne** miješa s combo HUD PR-om — D0-P / kasniji slice.

## Dijagnoza „slabi juice“ i „clutter“

Dva različita bola, često se miješaju.

**Juice:** merge **se dogodi**, ali tijelo ne dobije „pop“. Chip samo promijeni tier. Nema lanca zvuka, nema punch kamere, Pip ne reagira. Combo bez juicea je broj na labeli.

**Clutter:** do **40** chipova (`ARENA_MAX_CHIPS`), random mix tipova, magnet pomaže samo u radiusu. Lov na drugi Clover u hrpi je posao, ne igra. Combo prozor (1.5–2.5 s) **umire** ako par nije vidljiv.

ARENA-01 track A (ciljevi) **ne rješava** clutter sam. Ako freeze ostavi 40 + random pour, combo će biti težak. Zato A14/A15/A12 postoje.

## Pair pulse (A12)

Dok je chip u drag-u, svi drugi s **istim `type_id` + `tier`** trepere (scale ili outline). Magnet već vuče najbližeg; pulse pokazuje **sve** kandidate, i one izvan radiusa.

| Opcija | Kad kodirati | Zašto |
|--------|----------------|-------|
| **A** isti track kao combo | Combo A slice | Combo bez vida je timeout-hell |
| **B** zaseban mali slice | Nakon combo HUD | Manji PR, lakši smoke |
| **C** ne | — | Clutter ostaje; osloni se na magnet |

Implementacija (kad dođe): `arena_seed_chip.gd` signal `drag_started` → controller označi partnere `_can_merge_chips`. Ne mijenjati magnet math. Pulse **nije** auto-merge.

Merge Hint (A23 B): booster smije uključiti isti pulse bez draga — „evo para“. To je feel, ne nova cijena.

## Sort by type (A13)

Otvoreno u [[../02-design/merge-arena-v1.1|merge-arena-v1.1]] od MA-01. Nije u kodu.

| Opcija | Gesto | Rizik |
|--------|-------|-------|
| **A** gumb Sort | Igrač bira kad; grozdovi po tipu, lagani tween | Gumb u footeru (Done/Back već tu) |
| **B** auto-sort na pour | Nula UI | Gubi „rasuto playground“ fantaziju; pest path predvidljiviji |
| **C** ne u ovom tracku | — | Clutter ostaje problem comba |

Sort **ne** mergea. Samo raspored. Pest i dalje jede. Magnet i dalje radi.

Draft layout: lijevo-desno po `type_id` order (isti kao bag/almanac), unutar tipa slobodno. Ne grid slotovi — i dalje physics-lite separation (`CHIP_SEPARATION` 102).

## Clutter / pour količina (A14)

| Opcija | Cap | Feel |
|--------|-----|------|
| **A** ostavi 40 | Status quo | Kasni game bag-full; lov težak; combo težak |
| **B** ~24 | Stari spec draft | Čitljivije; višak ostaje u bag (već postoji `ARENA_MAX_CHIPS` logika) |
| **C** valovi 8–12 | Tap again | Svaki pour je mini-set; bliže A24 „prvi pour zadovoljava“ |

C je kompatibilan s A21 C (pour = runda), ali A21 default je bez tajmera — valovi i dalje sandbox.

Višak iznad capa **već** ostaje u bagu. Smanjenje capa nije gubitak sjemena.

## Pour sadržaj (A15)

Danas: `spawn_arena_from_bag` / pour uzima iz baga (prioritet u GameState — ne mijenjati bez freezea). Vizualno na polju = mix.

| Opcija | Ponašanje | Fair F2P |
|--------|-----------|----------|
| **A** random mix | Status quo | Neutralno |
| **B** preferiraj tipove koji već imaju 1 na polju | Manje lova, više mergea | Nije P2W; i dalje isti bag |
| **C** igrač bira tip iz vreće | Camp-like select | Više kontrole, sporiji pour, novi UI na bagu |

C je skoro nova mehanika (bag chip select u areni). Veći od „feel“. Ako da, zaseban slice, ne combo PR.

B je jeftin: pri pouru, ako polje ima orphan Clover T1 i bag ima Clover, sljedeći chip = Clover. Ne garantira par ako bag nema.

## Juice (nije A-pitanje osim A27)

Popis kad **ne** ide u ARENA-01 A kod:

- Scale bounce na merge (chip već može imati mali set; pojačati).
- Čestice / „pollen burst“ na T2, veći na T3.
- Screen punch 2–4 px na combo ≥3.
- SFX: A27 A pitch-up ding po combu; B isti merge SFX; C odgodi audio (track samo HUD).

D0-P je točno art/SFX pass. **Ne** otvarati audio bus u combo sliceu ako A27=C.

Pip (A18): A nema Pipa u areni; B mali Pip na rubu na combo/T3; C Pip drži vreću. B/C su art + node, ne cilj-sloj.

BG (A19): A statičan playfield; B tint „livada cvjeta“ s brojem T3 u sesiji; C trajni kamp vizual, arena playground. B je feel, lagani modulate, ne nova mapa.

## Audio (A27)

| Opcija | Kad |
|--------|-----|
| **A** pitch-up | Ako postoji merge SFX u D0-P ili odmah uz combo |
| **B** isti SFX | Combo ostaje vizual |
| **C** odgodi | Ovaj track = broj + cliff + daily logika |

Preporuka uz goals_on_top: **C ili B** u prvom kodu, A kad D0-P SFX postoji. Combo se testira headless bez zvuka.

## Mythic vizual (A30)

Spec: zlatni outline, merge samo mythic↔mythic istog tipa.  

- **A** status quo (isti playfield).
- **B** outline + mythic **ne ulazi u combo** (odvojeni „wow“).
- **C** ne dirati u ovom tracku.

C je najčistiji za prvi kod. B mijenja combo pravila po rarity — treba jasno u freezeu.

## Odnos prema combo tempu

Tablica za freeze (čitaj uz A2 prozor):

| Clutter odluka | Pulse | Sort | Preporuka prozora |
|----------------|-------|------|-------------------|
| 40 + mix, bez pulse | — | — | A2 C dugo, ili combo će rijetko >2 |
| 40 + pulse A | da | ne | A2 B srednje |
| 24 ili valovi | opcija | opcija | A2 A kratko postaje igrivo |
| auto-sort pour | manje potreban | B | arcade OK |

A33 B = „pulse obavezan u prvi kod“ je odgovor na ovu tablicu.

## Što feel **nije**

- Novi magnet algoritam.
- Auto-merge svih parova (to je A22 chain, ciljevi).
- Particle budget koji ruši HP AMD / low-end Android — kad kod, cap emittera.
- Reduce-motion Settings (nema u ovom tracku, kao HOME-04 P57).

## Kod (kad dođe, ne P0)

| File | Dir |
|------|-----|
| `arena_seed_chip.gd` | Pulse flag, maybe merge bounce |
| `merge_arena_controller.gd` | Sort layout, pour prefer, pulse fan-out |
| `GameState.ARENA_MAX_CHIPS` | Samo ako A14 B, i tada **ekonomija-brojevi** sink |
| `arena_seed_bag.gd` | Samo A15 C |

Smoke: pulse partner count == matching chips; sort ne mijenja `_chip_data` ids; pour B ne uzima locked/ununlocked tipove.

## Povezano

- [[ideje-arena|hub]] · [[ideje-arena-pitanja|A12–A15 A18 A19 A27 A30 A33]]
- [[ideje-arena-ciljevi|ciljevi]] — combo slijep bez pulse
- [[../02-design/merge-arena-v1.1|MA-01]] Sort otvoreno
