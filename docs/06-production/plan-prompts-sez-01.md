---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, sezone, plan, prompt]
povezano:
  - ideje-sezone
  - ideje-home-polish
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi SEZ-01 — P0 scope → B data → C Home → D run → E paid IAP."
---

# Plan promptovi — SEZ-01 Sezone

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri plan → tek onda Agent implementacija.
> **Redoslijed:** **P0 → B → C → D → E** — **track zatvoren (P0–E ✅)**. Home layout/swipe dalje: [[plan-prompts-home-polish|HOME-01]].
> **Ideje:** [[../03-content/ideje-sezone|ideje-sezone]] · [[../03-content/ideje-sezone-pitanja|pitanja]] · [[../03-content/ideje-sezone-data-model|data-model]]

## Freeze defaulti (2026-08-19)

| # | Odluka |
|---|--------|
| P1 | Radimo **sada** kao **v1.1 feature** |
| P2 | **Hibrid:** S1 = postojeći seed ID-evi (Country Bloom pool); S2+ novi ID-evi kasnije |
| P3 | Free S2: **5** T3 flowers, **check-only** (ne troši stash) |
| P4 | Coins **rastu**: S2=`80`, S3=`150` |
| P5 | Paid **smije** prije free S2 |
| P6 | Paid Browser = **horizontal scroll** cards |
| P7 | Clear rabbit = **kozmetika** (ne Pip swap u prvoj rundi) |
| P8 | Journal = **globalni** album |
| P9 | Katalog: **3 free + 2 paid** (S1 playable; S2–S3 + paid stub) |
| P10 | **Shared levels** + seasonal spawn pool + BG hook |
| P11 | Tap next-free teaser → **Unlock sheet samo** (ne Browser) |
| P12 | **Auto-switch** active na unlock **i** na paid purchase |
| P13 | Diamonds **ne** za free unlock |
| P14 | Season names **EN** u UI |
| P15 | Enemies/obstacles: **art reskin only** |

Fair F2P: paid = tema/kozmetika, **ne** snaga (loot %, magnet).

---

## Prompt — SEZ-P0 (Scope + design freeze) — prvi

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, SEZ-01 sezone — scope freeze.

SEZ-P0:
Dodaj SEZ-01 u v1.1 scope (ne v1 launch IN). Sink dokumentaciju prije game/ koda.

Relevantno: scope-i-granice.md, verzije-nakon-launcha.md, ideje-sezone*.md, ideje-sezone-pitanja.md, CHECKPOINT.md, changelog.md.

Default freeze (već u plan-prompts-sez-01 / pitanja):
- P1 v1.1 sada; P2 hibrid seeds; P3 5 T3 check-only; P4 coins 80/150; P5 paid prije S2 OK
- P6 horizontal paid; P7 rabbit kozmetika; P8 global journal; P9 3 free+2 paid; P10 shared levels
- Fair F2P; S1 id = country_bloom

U planu:
- Ažuriraj scope-i-granice + verzije-nakon-launcha (SEZ-01 IN v1.1)
- Potvrdi freeze odgovore u ideje-sezone-pitanja ako treba
- CHECKPOINT sljedeci_korak → Plan mode SEZ-B
- Acceptance: docs sync; Nema game/ code u P0
- Ne dirati SeasonDef / Home Stage (to je B/C)
```

---

## Prompt — SEZ-B (Data + GameState)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, SEZ-01 data layer.

SEZ-B:
SeasonDef katalog + GameState active/unlocked/owned + free unlock API + save migrate + headless smoke.

Relevantno: game_state.gd (SAVE_VERSION, wallet_coins, garden_crystal_stash), novi data/seasons ili JSON, ideje-sezone-data-model.md, ideje-sezone-content.md.

Default:
- S1 country_bloom free order=1, cost 0, seed_type_ids = postojeći 7 tipova (clover…watermelon)
- S2 frost_orchard free order=2, coins=80, t3_req=5 check-only
- S3 lantern_meadow free order=3, coins=150, t3_req=8 (ili 5 ako uskladiš — prefer 8 draft iz content)
- Paid stubs: moonlit_warren, coral_tide (iap ids season_pack_*)
- API: active_season_id, unlocked_seasons, owned_paid_seasons, can_unlock_free, unlock_free, set_active_season, is_season_playable (free unlocked OR paid owned)
- unlock_free / grant paid → **auto-switch** active (P12)
- Paid playable prije free S2 (P5)

U planu:
- SeasonDef schema + loader; GameState helpers; save migrate
- Smoke: new game S1 only; unlock S2 with mocked coins+T3; cannot S3 before S2; set active
- Ne Home UI, ne run BG, ne IAP purchase UI
```

---

## Prompt — SEZ-C (Home Stage + Browser free)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, SEZ-01 Home UX.

SEZ-C:
Home Season Stage (thumbnail + next-free teaser) + swipe među playable sezonama + Season Browser (free lane + unlock sheet). Paid red može biti placeholder disabled.

Relevantno: main_menu.tscn / main_menu.gd, meta hub SwipePager, ideje-sezone-ux-home.md, GameState season API iz SEZ-B.

Default:
- Stage: ime, mood placeholder, seed peek, clear rabbit art stub
- Desno: next locked free sivo + katanac
- Swipe L/R: samo playable (unlocked free + owned paid)
- Browser gore: free linear; locked → unlock sheet (X coins + Y T3)
- Tap next-free teaser (Home) → **Unlock sheet samo** (P11), ne Browser
- Na uspješan unlock → **auto-switch** active na tu sezonu (P12)
- Gesture: Stage swipe ne smije mijenjati hub page index

U planu:
- Scene/nodes + controller; unlock sheet; smoke Home select/unlock
- Acceptance: S1 visible; teaser S2; unlock S2 updates Stage
- Ne run spawn/BG (D); ne real IAP (E)
```

---

## Prompt — SEZ-D (Run theme hook)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, SEZ-01 run wiring.

SEZ-D:
Play koristi active_season_id: seed spawn pool = SeasonDef.seed_type_ids ∩ unlocked seeds; minimal BG/theme hook; shared levels (P10).

Relevantno: run_controller.gd, game_state spawn/unlock, SeasonDef, level select / endless entry.

Default:
- Shared 100 levels + endless; samo pool + BG path iz def
- S1 pool = existing types; **art reskin only** za obstacles (P15)
- Fair: nema loot% boost po sezoni

U planu:
- Hook na start runa; placeholder BG OK; smoke active season affects spawn set
- Ne IAP / Shop paid rows (E)
```

---

## Prompt — SEZ-E (Paid IAP + Shop + Browser paid)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow, SEZ-01 paid seasons.

SEZ-E:
IAP non-consumable season packs (stub OK na Windows) + Shop rows + Browser paid horizontal scroll; own → select active. Restore purchases.

Relevantno: iap_manager.gd, shop_screen.gd, season browser iz C, SeasonDef iap_product_id, ideje-sezone-ekonomija.md.

Default:
- P5 paid prije S2; P6 horizontal cards; Fair F2P no power
- Product ids: season_pack_moonlit_warren, season_pack_coral_tide
- Owned / kupnja → **auto-switch** active (P12); unowned → buy
- Art reskin only za enemies (P15); season names EN (P14)

U planu:
- IAP stub grant owned_paid_seasons; Shop UI; Browser paid row live
- Smoke: mock purchase → playable → active
- Ne mijenjaj free unlock math (B); ne full final art
```

---

## Povezano

- [[../03-content/ideje-sezone|ideje-sezone]] hub
- [[../03-content/ideje-sezone-ux-home|UX]] · [[../03-content/ideje-sezone-ekonomija|ekonomija]] · [[../03-content/ideje-sezone-content|content]] · [[../03-content/ideje-sezone-data-model|data-model]]
- [[plan-prompts-bug-029-032|plan-prompts-bug-029-032]] — šablon
- [[CHECKPOINT|CHECKPOINT]]
