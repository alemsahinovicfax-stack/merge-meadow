---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, merge, bloom, t2, inbox, scratch]
povezano:
  - ideje-arena
  - ideje-arena-pitanja
  - ideje-arena-ciljevi
  - merge-arena-v1.1
ai_sažetak: "ARENA-01 bloom — T2 na polju vs inbox; Donate/Album/Basket friction; leftover; nije prvi kod osim A10/A11/A33 C."
---

# IDEJE — ARENA-01 bloom (T2, spend, leftover)

> [[ideje-arena|ARENA-01 hub]]. Spec [[../02-design/merge-arena-v1.1|merge-arena-v1.1]] preporučuje: T2+ **odmah u inbox**, arena = T1 playground. **Kod to ne radi.** T1+T1 ostavlja T2 na playfieldu; T3 ide u garden stash i skida chip. Tap T2 otvara Donate / Album / Basket.

To je namjerni ili slučajni drift od speca. ARENA-01 mora **odlučiti**, jer T2 na polju ubija combo tempo (moraš ili spojiti T2 ili otvoriti panel).

## Što kod radi danas

| Tier | Na polju | Nakon mergea | Spend |
|------|----------|--------------|-------|
| T1 | Da | 2×T1 → T2 **ostaje** | Ne |
| T2 | Da | 2×T2 → T3, chip se **uklanja**, crystal stash | Tap → panel |
| T3 | Ne | — | Nema T3 chipa; freeze pest 2 s |

`info_label` za odd T2: *Odd T2: tap for Donate/Keep/Basket, or merge another T2.*

Pest **jede T2** na polju (`tier <= 2`). T2 koji čeka spend je hrana. To je pritisak i frustracija.

Inbox node `InboxPanel` je **legacy hidden**. Bloom spend je overlay na chipu, ne donja traka iz speca.

## T2 na playfieldu (A10)

| Opcija | Arena postaje | Combo | Pest | Upgrade donate |
|--------|---------------|-------|------|----------------|
| **A** ostavi T2 | T1 i T2 playground; T2→T3 je igra | T2 merge hrani combo | T2 je meta | Panel kad hoćeš |
| **B** T2 odmah inbox | Samo T1 | Combo samo T1+T1; kraći lanac | Pest jede samo T1 | Spend van playfielda (traka ili Camp) |
| **C** T2 ~1 s pa fly | Kratki prozor za T2+T2 | Brzi igrači chainaju; spori gube T2 s polja | Uska trka | Hybrid |

**A** je status quo. T2 chore (panel) ostaje; A11 može smanjiti trenje.  
**B** je spec. Combo je plići (nema T2+T2 u nizu) ali čistiji. T3 crystal mora nastati **u inboxu** (2×T2 spend? ili auto-merge u traci?) — **rupu treba zatvoriti u freezeu** ako B: predložak *inbox 2×T2 tap merge* ili *auto T2+T2 u traci*. Bez toga B ubija T3.  
**C** je feel-heavy (tween fly). Ako igrač ne spoji T2 u 1 s, inbox. Pest može pojesti u toj sekundi.

A33 C = „T2 inbox obavezan u prvi kod jer chore ubija combo“. To vuče **B ili C**, i vjerojatno **odvojeni slice** od combo HUD-a (previše pravila u jednom PR-u).

### Rupa ako A10=B: gdje nastaje T3?

Draft za dokument, nije freeze:

1. **Inbox merge:** dva T2 ista tipa u traci, tap para → T3 crystal (malo UI).
2. **Auto:** drugi T2 istog tipa u inboxu odmah postaje T3 (nema T2+T2 skill).
3. **Camp:** T2 se troši samo Donate/Keep; T3 samo ako spojiš T2 na polju — **proturječi B**.

Ako korisnik izabere B, sljedeće pitanje u chatu mora biti ovaj pod-izbor (bilježi se pod A10).

## Bloom spend friction (A11)

Panel danas: tri `UiClickButton`, Donate disable kad upgrade max, Album disable kad već kept, Basket skoro uvijek on.

| Opcija | Brzina | Pogreška | Combo |
|--------|--------|----------|-------|
| **A** ostavi panel | Spor | Niska | Prekid tempa |
| **B** default jedan tap | Brzo | Donate kad si htio Album | Panel nestaje; treba undo? **Ne** u v1 ovog tracka |
| **C** swipe na T2 | Srednje | Uči gesto | Fancy; hub swipe lock već postoji — konflikt |

**B draft pravilo:** ako Donate nije disabled → Donate; else ako Album može upgrade → Album; else Basket. Igrač gubi izbor u jednom tapu. Dugotrajni Album hunters će protestirati.

**C:** gore Donate, dolje Album, long-press Basket. Arena page već `set_hub_nav_locked` tijekom sesije — vertikalni swipe na chipu ne bi trebao mijenjati hub page ako je lock on. Ipak: hit-test vs chip vs page. Scope M.

Long-press preview (spec accessibility) **nije** u kodu. A11 C bi mogao ukrasti taj slot.

## Odd leftover (A25) — bloom kut

T1 odd: Done → `commit_arena_chips_to_bag`.  
T2 odd: moraš tap spend ili ostaviti da pest jede / Done reciklira? (Bug-016 / `arena_odd_t2_smoke` — Done reciklira leftover T2 u bag kao sjeme. Provjeri kanon: smoke očekuje recycle.)

| Opcija | T1 | T2 |
|--------|----|----|
| **A** status quo | Done bag | Tap spend ili Done recycle |
| **B** 3 odd T1 → 1 coin u areni | Novi sink | Ne dira T2 |
| **C** odd T1 auto u bag | Manje Done | T2 i dalje ručno |

B je ekonomija (sitni coins). Dnevni cap ako postoji combo-coin (A1 C). Ne 3 T2 → coin (T2 je skup).

## Basket, Album, Donate — ne dirati pravila

ARENA-01 **ne** mijenja:

- `donate_bloom` / sprinkler vs multiplier po tieru
- `keep_bloom` / `collection_kept_tiers`
- `basket_bloom_type` loadout +5% spawn
- maxed Donate poruka

Samo **kako** igrač dođe do tih funkcija s playfielda (panel vs auto vs inbox).

## Clear-field vs T2 (A9)

Ako T2 stoji na polju i nema para, clear-field je **true** za merge, ali chipovi ostaju. Celebration ne smije gurati spend. Ako A10=B, clear-field = nema T1 para; inbox je van playfielda.

## Mitovi koje ne radimo ovdje

- T4.
- Mythic-only inbox.
- Bloom inbox max 12 toast (spec) — kod koristi stash/panel; ne oživljavati traku osim A10 B.
- Interstitial na spend.

## Kod (kad dođe)

| File | Dir |
|------|-----|
| `merge_arena_controller.gd` `_on_chip_released` | T2 fly vs stay |
| `_show_bloom_panel` / `_on_bloom_*` | A11 |
| `GameState.try_merge_arena_chips` / `stash_garden_crystal` | T3 izvor |
| `bloom_inbox_*` | Legacy; oživjeti samo za A10 B |
| `arena_odd_t2_smoke.gd` | Mora proći nakon A10 |

## Povezano

- [[ideje-arena|hub]] · [[ideje-arena-pitanja|A10 A11 A25 A33]]
- [[ideje-arena-ciljevi|combo tempo]]
- [[ideje-arena-pest|pest jede T2]]
- [[../02-design/merge-arena-v1.1|spec inbox]]
