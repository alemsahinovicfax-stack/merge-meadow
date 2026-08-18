---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, qa, audit, d0, functional]
povezano:
  - CHECKPOINT
  - d0-prelaunch-checklist
  - spec-vertical-slice
  - ekonomija-brojevi
ai_sažetak: "Radna matrica D0-F — ekran × očekivano ponašanje × status × bug ID; ažurirati tijekom F1–F4."
---

# D0 — funkcionalni audit

> **Ulaz:** `meta_hub.tscn` (main scene). **Izvor istine:** [[../02-design/spec-vertical-slice|spec-vertical-slice]] + [[../02-design/ekonomija-brojevi|ekonomija-brojevi]].

Legenda: ✅ OK · 🟡 djelomično / placeholder · ❌ broken · ⏸ odgođeno (D0-P/M)

**Zadnje ažuriranje:** 2026-08-16 (Bug-030 ✅ — rarity theme bg)

---

## F1 — Test matrica

| ID | Pod-blok | Provjera | Očekivano | Status | Bug |
|----|----------|----------|-----------|--------|-----|
| H1 | Hub | Boot meta hub | Main scene učitava, top bar coins/seeds | ✅ | — |
| H2 | Hub | Lazy load 5 stranica | Shop/Journal/Home/Camp/Arena bez crasha | ✅ | — |
| H3 | Hub | Tab navigacija | Tab → `go_to_page` | ✅ | — |
| H4 | Hub | Settings gumb | Placeholder poruka | 🟡 | D0-P puni ekran |
| R1 | Run | Fresh run | Timer, spawn, magnet, fail/finish | ✅ | — |
| R2 | Run | Endless | Easy/Normal/Hard start | ✅ | — |
| R3 | Run | Almanac spawn | Samo unlocked tipovi | ✅ | — |
| L1 | Loot | Fail 50% | `ceil(50%)` coins + seeds | ✅ | — |
| L2 | Loot | Double / Revive | Rewarded stub, 1× revive | ✅ | — |
| L3 | Loot | To Camp | Deposit + meta nav; **ne** auto-Play | ✅ | — |
| L4 | Loot | Retry | Fresh run (+ interstitial hook) | ✅ | — |
| C1 | Camp | Upgrades | Sprinkler + Loot Boost donate | ✅ | — |
| C2 | Camp | Exchange / daily | Seed trade, crystal exchange, chest | ✅ | — |
| C3 | Camp | Play / Merge footer | Run start; arena nav | ✅ | — |
| C4 | Camp | Settings gumb | Placeholder u `info_label` | 🟡 | D0-P |
| A1 | Arena | Merge T1→T3 | Lanac + pest | ✅ | — |
| A2 | Arena | Bloom inbox | Keep / Donate | ✅ | — |
| S1 | Shop | Open + scroll | Bez crasha (#10) | ✅ | — |
| S2 | Shop | Cosmetics / boosters | Buy, equip, use | ✅ | — |
| J1 | Journal | Bloom Album | Lista + NEW badge | ✅ | — |
| P1 | Save | `player_save.json` | Wallet, bag, upgrades perzistentni | ✅ | — |

---

## F2 — Bug lista

| Bug ID | Ekran | Simptom | Prioritet | Status | Fix |
|--------|-------|---------|-----------|--------|-----|
| Bug-004 | Meta hub | `move_child` index error kad se učitava str. 3 prije 0–2 | P0 | ✅ | `PageSlot_*` placeholderi u `_load_page` |
| Bug-005 | Run HUD | `_update_hud` null ref pri headless load | P1 | ✅ | Null guard na labelama |
| — | Loot → Camp | Dupli klik → Play (#8) | P0 | ✅ | SceneRouter block + nav lock |
| — | Shop scroll (#10) | Signal 11 crash | P0 | ✅ | Uklonjen width sync |
| Bug-001 | Hub Settings | Placeholder caption | P2 | 🟡 | D0-P Settings ekran |
| Bug-002 | Camp Settings | Placeholder u info | P2 | 🟡 | D0-P |
| Bug-003 | Main menu Settings | Placeholder hint | P2 | 🟡 | D0-P |

*(Dodaj korisničke bugove kao Bug-006+)*

---

## Korisnička bug lista — Bug-006+

> Playtest 2026-08-15. Plan mode: jedan prompt po stavci (vidi chat). Implementacija tek nakon odobrenog plana.

| Bug ID | Ekran | Simptom | Očekivano | Prioritet | Status |
|--------|-------|---------|-----------|-----------|--------|
| Bug-006 | Meta hub | Redoslijed swipe + page dots | Shop → Journal → Home → Camp → Arena; bez tačkica | P1 | ✅ |
| Bug-007 | Shop | Mali tekst; gornji „prozor“; Almanac/Cosmetics zbijeno | Veći tekst; top panel; veće sekcije + scroll | P1 | ✅ |
| Bug-008 | Camp | Nepregledan layout; daily chest | UX zone Daily→Garden→Upgrades→Run prep→Footer | P0 | ✅ |
| Bug-009 | Hub header | Dosadan top bar; nema ikona | Ikone coins/seeds | P2 | ✅ |
| Bug-010 | Merge Arena | Hub swipe/tabovi tijekom pour/pest lome arenu; povratak polu-mrtvo | Lock swipe+tabovi u aktivnoj sesiji; jasan resume/reset | P0 | ✅ |
| Bug-011 | Camp Garden | Trade 3→coins bez izbora tipa | Select tipa (count≥3) pa Trade; select ostaje dok ≥3 | P1 | ✅ |
| Bug-012 | Camp | Crystal exchange u istom bloku kao seed trade | Zaseban crystal panel + select + scroll | P1 | ✅ |
| Bug-013 | Shop | Seed Almanac suvišan | Ukloniti Almanac iz Shop UI (unlock ostaje u GameState) | P2 | ✅ |
| Bug-014 | Hub header | Ikone bez vidljivog broja | Čitljiv broj pored ikone | P0 | ✅ |
| Bug-015 | Run HUD | Coins/seeds counters poremećeni; gornji HUD zbrka | Top strip: timer/level, companion, counters, feed | P0 | ✅ |
| Bug-016 | Arena + Camp | Odd T2 bez jasnog izlaza | T2 tap Donate/Keep/Basket; Done recycle T2→T1 (bag T1-only) | P1 | ✅ |
| Bug-017 | Shop | Cosmetics dugmad ne skidaju coins | Buy → wallet−; Equip radi | P0 | ✅ |
| Bug-018 | Camp Garden | Nema izbora basket tipa; footer Merge/Play suvišan u hubu | Tap tip → loadout; sakrij Merge/Play u hub mode | P1 | ✅ |
| Bug-019 | Meta hub | Bottom caption sekcije oduzima prostor | Ukloniti CaptionLabel; tabovi+swipe ostaju | P2 | ✅ |
| Bug-020 | Wallet + Run | Nema dijamant valute / rare drop | Hub+run diamond chip; ~1/300 seed pickupa | P1 | ✅ |
| Bug-021 | Journal | Jedan vizual po tipu | T1/T2/T3 ikone; locked sivo, unlocked boja | P2 | ✅ |
| Bug-022 | Home | Camp/Shop CTA; Settings u headeru; chest u Campu | Home polish; Settings+DailyChest na Home | P0 | ✅ |
| Bug-023 | Home + Camp | Basket biranje u Campu | Basket picker na Home; ukloni camp basket UX | P0 | ✅ |
| Bug-024 | Home | Basket u središnjem Panelu | Kartica ispod DailyChest; prazna/filled korpa | P1 | ✅ |
| Bug-025 | Camp Garden | Nema default select; leftover 1–2 zaglavi; sort DESC | Default TL select; rarity ASC; trade 1–2 proporcionalno | P1 | ✅ |
| Bug-026 | Journal | T1 clip / slotovi zbunjuju (T2/T3 na krivim mjestima) | Slot 1=T1, 2=T2, 3=T3 čitljivo; caption | P1 | ✅ |
| Bug-027 | Meta hub | Ručni swipe ostavi ekran između stranica | Uvijek snap na punu page | P0 | ✅ |
| Bug-028 | Journal + Arena | T3 merge ne otključava Journal T3 | stash_garden_crystal → kept_tier=3 | P0 | ✅ |
| Bug-029 | Visual | T1 Album ≠ run/camp/arena | Uskladi T1 na Album look | P1 | ✅ |
| Bug-030 | Journal + Camp | Nema rarity bg theme | ★1 plava / ★2 ljubičasta / ★3 zlatna | P2 | ✅ |
| Bug-031 | Camp exchange | Flat 3→8 / crystal 10; nema cijene na chipu | Rate po rarity + cost label | P1 | ✅ |
| Bug-032 | Camp Garden/Crystal | Različit layout; isti icon; Crystal copy | Layout parity; T1 vs T3 icons; UI Flower | P1 | ✅ |

> Plan promptovi (copy-paste): [[plan-prompts-bug-010-014|plan-prompts-bug-010-014]] (✅) · [[plan-prompts-bug-015-019|plan-prompts-bug-015-019]] (✅) · [[plan-prompts-bug-020-023|plan-prompts-bug-020-023]] (✅) · [[plan-prompts-bug-024-027|plan-prompts-bug-024-027]] (✅) · [[plan-prompts-bug-029-032|plan-prompts-bug-029-032]]. Redoslijed **029–032:** **029 → 030 → 031 → 032**.

### Bug-008 — zone + UniqueName (Faza 0)

Kamp page (embedded u hub): Daily → Garden → Upgrades → Run prep → Footer. Wallet/Settings/Journal ostaju na hub chromeu.

| UniqueName | Zona |
|------------|------|
| `HomeButton`, `CampTitle`, `CollectionButton`, `SettingsButton`, `ResourceBar` | A chrome (standalone) |
| `StatusToast`, `StatusLabel` | A toast |
| `DailyChestCard`, `DailyTitle`, `DailyCaption`, `ChestVisual` | B daily |
| `GardenCliff`, `BagLabel`, `GardenStashLabel`, `CrystalExchangeButton`, `ExchangeButton` | C garden |
| `SprinklerLabel`, `SprinklerCaption`, `UpgradeButton`, `MultiplierLabel`, `MultiplierCaption`, `UpgradeMultiplierButton` | D upgrades |
| `LoadoutButton`, `CompanionTitle`, `CompanionHint`, `PipSlot`, `MochiSlot` | E run prep |
| `FooterBar`, `MergeButton`, `PlayButton` | F footer |
| `RewardOverlay`, `RewardBody`, `RewardOkButton` | Daily overlay |

Playtest (5 min): daily READY iznad folda; 1 tap → overlay +8 coins / +3 seeds; drugi tap isti dan bez payouta; Garden bag vs crystals vs trade; Upgrade caption objašnjava sivi gumb; Merge/Play iznad hub tabova; Loot → To Camp ne pokreće run.

---

## F1 — Headless smokes (automatski)

| Skripta | Rezultat |
|---------|----------|
| `meta_hub_smoke.gd` | ✅ OK |
| `meta_hub_flow_smoke.gd` | ✅ OK |
| `run_smoke.gd` | ✅ OK |
| `menu_play_smoke.gd` | ✅ OK |
| `merge_arena_smoke.gd` | ✅ OK |
| `shop_open_smoke.gd` | ✅ OK |
| `ui_button_click_smoke.gd` | ✅ OK |
| `collection_journal_smoke.gd` | ✅ OK |
| `loot_camp_nav_smoke.gd` | ✅ OK |
| `camp_layout_smoke.gd` | ✅ OK |
| `arena_odd_t2_smoke.gd` | ✅ OK (Bug-016 recycle) |
| `save_persistence_smoke.gd` | ✅ OK |
| `balance_snapshot.gd` | ✅ OK (avg ~8 coins/seeds sim) |

Pokretanje: `godot --headless --rendering-driver opengl3 --path game --script res://scripts/dev/<ime>.gd`

---

## F4 — Balans bilješke

| Metrika | Target (docs) | Measured | Napomena |
|---------|---------------|----------|----------|
| Run trajanje post-tutorial | 60 s | 60 s | `POST_TUTORIAL_RUN_DURATION` |
| Coins / run (sim 5×) | TBD | **~8** | `balance_snapshot.gd` |
| Seeds / run (sim 5×) | TBD | **~8** | alternirajući fail u simu |
| Vrijeme do prvog mergea | TBD | — | ručni test bez debug resursa |
| Shop prvi item (250 coins) | ~N runova | — | nakon vanjskog playtesta |

### 5-min vanjski playtest (gate prije D0-P)

Predaj igraču bez vođenja. Bilježi:

- [ ] Pronađe Merge / Arena u &lt; 2 min
- [ ] Razumije fail 50% loot
- [ ] Upgrade sprinkler ili multiplier dostižan u 1 sesiji
- [ ] Nema crasha na Shop swipe
- [ ] Jedna rečenica: „što je nejasno?“

Rezultat upiši u `changelog.md` + [[../07-meta/otvorena-pitanja|otvorena-pitanja]] ako treba odluka.

---

## Povezano

- [[CHECKPOINT#D0-F — Funkcionalnost prije polish (sada)|CHECKPOINT D0-F]]
- [[../05-technical/godot/greske-katalog|greske-katalog]]
- [[../05-technical/godot/dev-workflow|dev-workflow]]
