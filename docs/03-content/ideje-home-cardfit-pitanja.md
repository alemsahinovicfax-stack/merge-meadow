---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, pitanja, roster, unlock, sezone, scratch]
povezano:
  - ideje-home-cardfit
  - plan-prompts-home-cardfit
  - ideje-home-incard-pitanja
  - ideje-home-unlock-pitanja
ai_sažetak: "HOME-09 pitanja P103–P114 — Amber off TEST_LOCK; gate na next-lock free; naslov sredina; roster kontrast+širina; Ember paid lock."
---

# IDEJE — HOME-09 pitanja (P103–P114)

> [[ideje-home-cardfit|hub]]. Freeze 2026-08-25.  
> P1–P102 ostaju osim overridea označenih dolje (P84 Amber, P90/P94 frame, P100 naslov).

P81–P83, P85–P89, P91–P99, P101–P102 (select, bounce, next-lock cycle, inline gate, Seeds = T3, 48 stubova, paid bez coin Unlock, parent u kartici, L/R in-place, `seed_type_ids`) **ne dirati**. Ovdje: **Amber TEST_LOCK**, **naslov**, **kontrast**, **širina**.

| # | Pitanje | Odluka |
|---|---------|--------|
| **P103** | Na kojoj sezoni Unlock gate? | Na **svakoj sljedećoj zaključanoj free** kad je ona hero-centar. Nije hardkod Lantern. Ovaj save: **Amber**. Novi save: Frost. Debug skip Lantern: Lantern. |
| **P104** | Amber TEST_LOCK? | **Skida se.** Amber = kao Lantern: selectable, `can_unlock_free` (220c / 12 T3 iz JSON), Unlock sivo→primary. Override P84 za free id. |
| **P105** | Ember? | **Ostaje** paid TEST_LOCK / IAP. Nema coin Unlock. Override P84 samo za `amber_canopy`, ne za `ember_fen`. |
| **P106** | Skače li lanac? | **Ne.** `can_unlock_free` i dalje traži prethodnu free otključanu. Further-lock bounce. |
| **P107** | Naslov sezone? | **Sredina** kartice (full-rect, H+V CENTER). Override P100 (gore). Roster/gate overlay; ne gurati ime na vrh. |
| **P108** | Roster pozadina? | **Po sezoni** iz `_mood_color`. Svijetle kartice → tamni frame + cream tekst. Tamne (Moonlit, Starfall) → svijetli frame + tamni tekst. Gate isti jezik. Override P90/P94 „jedan tamni okvir“. |
| **P109** | Širina rostera? | **~0.42–0.50** širine kartice, min **~320px** (danas 260). Ellipsis samo fallback. `clip_contents` ostaje. |
| **P110** | Gate layout? | Donji **desni** kut, `z_index` iznad rostera. Unlock `STOP` samo kad `can_unlock_free`. `_ignore_hits` ne smije ostaviti gumb mrtvim nakon refresh. |
| **P111** | Debug unlock? | `debug_unlock_all` i dalje skipa **Lantern i Amber** (i Ember). Playtest uvijek ima locked free karticu. Ne grantati Amber. |
| **P112** | Što ne dirati? | Band 20/80, L/R in-place, Shop Select, AdMob, SAVE_VERSION, inline IAP, hub pager, `seed_type_ids`. |
| **P113** | Paid roster? | Isti kontrast i širina. **Bez** Unlock gatea. |
| **P114** | Milestone? | **v1.1+**, nije launch blocker. |

## Zašto ove odluke

### P103 / P104 — gate nije „fali kod“, fali Amber

INCARD-B widget živi u `CenterFill`. `refresh_gate` traži `next_locked_free_id()` **i** `is_free_selectable`. Amber je `TEST_LOCK_FREE_ID` → selectable false → bounce → `visible = false`. U saveu s otključanim Lanternom igrač **nema** unlock UI nigdje. Playtest: „napravi to za svaku trenutno zaključanu sezonu, npr. Amber Canopy.“

Nije: gate na Bloomu dok gledaš Bloom. Nije: gate na desnom 20% previewu. Nije: coin Unlock na svim paid. Jest: koja god free sezona **sada** bude next-lock, njen **prozor** nosi trake i Unlock.

### P105 — Ember

Fair F2P + P54/P89. Ember je paid pack, `coins_cost` 0. Coin Unlock bi bio zaobilaznica IAP. TEST_LOCK paid ostaje da se grant ne desi iz debug/shop greške.

### P106 — sequential

„Svaka zaključana“ ≠ „otključaj koju hoćeš.“ Amber gate postoji kad je Lantern već playable. Dok je Lantern next-lock, Amber je further → bounce, bez gatea. `previous_free_id` ostaje.

### P107 — naslov

P100 je bio agentov kompromis da roster ne prekrije ime. Playtest je odbio kompromis. Ime je identitet kartice i stoji u sredini kao prije HOME-08.

### P108 / P109 — kontrast i širina

P90 „tamni okvir, krem tekst“ je čitljiv na Bloomu i nečitljiv/nelogičan na Moonlitu; nije „boja sezone“. Playtest traži **drugu sezonu, drugu pozadinu prikaza**. Širina 260px je matematički preuska za font 22 + ikona 52 + zvijezde.

### P111 — debug i dalje skipa Amber

Ako debug grant-a Amber čim skinemo TEST_LOCK, editor playtest opet nema locked free karticu (samo Ember paid). Skip Lantern **i** Amber po id-u, ne preko TEST_LOCK (jer TEST_LOCK više ne uključuje Amber).

## Otvoreno (ne blokira CARDFIT-A/B)

Ova pitanja agent **ne** mora pitati da krene. Ako u B treba izbor, koristi preporuku.

1. **Hex vs algoritam.** Preporuka: `darkened`/`lightened` iz `_mood_color`, ne ručni hex po id-u. Ručni hex samo ako luminance threshold krivo klasificira Ember.
2. **Naslov font_color na tamnim karticama.** Preporuka: cream na Moonlit/Starfall, tamni na ostalima. Smije u B; nije fail ako ostane tamni tekst jedan pass.
3. **Luminance threshold.** Nema magičnog broja u freezeu. Agent bira prag koji Bloom/Frost/Lantern/Amber/Coral tretira kao „svijetle“, Moonlit/Starfall kao „tamne“. Ember darken+cream.
4. **Smanjiti `ROW_H` na kratkom hero slotu.** Samo ako clip reže 6. red; prvo širina. Ne vraćati naslov gore.
5. **🔒 u naslovu next-lock.** Ako već postoji, ostaviti. Ne dodavati novi lock badge u HOME-09.

## Nije otvoreno (namjerno)

- Coin Unlock na paid / Ember.
- Gate na L/R ili preview.
- Follow-finger, wrap, band 20/80, Shop Select, AdMob, SAVE_VERSION, inline IAP, hub pager.
- Mijenjanje 48 imena / rarity / `seed_type_ids`.
- Vraćanje Stage overlaya.
- Grant Lantern ili Amber kroz `debug_unlock_all`.

## Override mapa (brzi lookup)

| Staro | Novo |
|-------|------|
| P84 Amber TEST_LOCK | P104 Amber **nije** TEST_LOCK; P105 Ember **jest** |
| P90 / P94 jedan `1A1A14` frame | P108 per-season contrast |
| P100 naslov gore | P107 naslov sredina |
| P96 / P99 „Lantern gate“ kao primjer | P103 next-lock **bilo koja** free, uključujući Amber |
| P99 debug skip lantern (+ TEST_LOCK amber) | P111 skip lantern **i** amber po id-u |

## Povezano

- [[ideje-home-unlock-pitanja|P81–P91]]
- [[ideje-home-incard-pitanja|P92–P102]]
- [[../06-production/plan-prompts-home-cardfit|prompti]]
