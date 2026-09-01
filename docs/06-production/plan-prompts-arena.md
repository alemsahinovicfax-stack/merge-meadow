---
type: produkcija
status: aktivan
milestone: "v1.1+"
tags: [produkcija, arena, merge, combo, plan, prompt]
povezano:
  - ideje-arena
  - ideje-arena-grupe
  - ideje-arena-pitanja
  - ideje-arena-ciljevi
  - ideje-arena-feel
  - ideje-arena-bloom
  - ideje-arena-pest
  - plan-prompts-arena-leftover
  - plan-prompts-arena-sort
  - CHECKPOINT
ai_sažetak: "Copy-paste Plan-mode promptovi ARENA-01 — COMB-A → FLOW-A → FLOW-B → DAILY-A → FEEL-A → FEEL-B."
---

# Plan promptovi — ARENA-01 Merge Arena zabavnija

> **Kako:** novi chat → mode **Plan** → zalijepi **jedan** prompt → odobri → Agent.  
> **Redoslijed:** **COMB-A ✅ → FLOW-A ✅ → FLOW-B ✅ → DAILY-A ✅ → FEEL-A ✅ → FEEL-B ✅**  
> **Grupe:** [[../03-content/ideje-arena-grupe|ideje-arena-grupe]] · freeze [[../03-content/ideje-arena-pitanja|pitanja]] · hub [[../03-content/ideje-arena|ideje-arena]]

**COMB-A ✅** (2026-08-25, grana `ARENA`) — Combo HUD od 2, prozor 1.4 s, 2 coins na pragu 5 + dnevni cap 10, pair pulse.

**FLOW-A ✅** (2026-08-26, grana `ARENA`) — nema bloom panela; leftover T2 → 2× T1; T2 ostaje dok ima para u runu.

**FLOW-B ✅** (2026-08-26, grana `ARENA`) — auto-pour kad polje ≤10 do 40/praznog baga; pour preferira orphan tip (1 na polju).

**DAILY-A ✅** (2026-08-26, grana `ARENA`) — jedan arena zadatak / local day (`merge_t2` 3 / `make_t3` 1 / `combo_5` 1); n/N u areni; Home chest tap za streak badge bez coina/sjemena; `SAVE_VERSION` 12.

**FEEL-A ✅** (2026-08-26, grana `ARENA`) — mali Pip na rubu playfielda (nije kolizija/eat); bounce na combo ≥2 ili T3; sesijski livada tint po T3, reset na Done/Back.

**FEEL-B ✅** (2026-08-26, grana `ARENA`) — clear-field VFX kad nema legalnog para (odd leftover OK); jednom po pouru; bez coina; Done i pour i dalje rade. ARENA-01 prompti gotovi.

## Freeze (sažetak za agente)

G1 Combo: A1 C coins na 5+ + cap; A2 A prozor 1.2–1.6 s; A3 A samo timeout; A12/A33 pulse u COMB-A; A16 pest ne lomi combo, nema extra freeze; A20 nema score; A22 ručno; A26 nema tutorial; A31 `Combo`.

G2 Field: A10 T2 ostaje; A11 leftover T2→2×T1; A11c nema bloom panela; A14 cap 40 auto-refill na 10; A15 prefer orphan; A25 T1 na Done.

G3 Daily: A6 jedan zadatak; A7 badge bez loota; A8 progress areni, claim Camp.

G4 Feel: A9 clear-field VFX; A18 Pip; A19 tint; A27 audio **nije** ovdje.

G5: Sort ne, cliff samo Camp, nema tajmera/ads/IAP/mythic/pay-to-merge. Kanon spec ne prepisivati dok „dodaj u scope“.

Ne dirati (svi sliceovi): Home dual-band, sezone, Shop Select, AdMob, unique seeds, pest FSM (speed/eat/T3 freeze 2 s), energy, fail u areni, hub pager, `seed_type_ids`.

---

## Prompt — COMB-A (Combo HUD + coins + pulse)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow ARENA-01 COMB-A — Combo HUD, kratki prozor, coins na 5+, pair pulse.

Freeze G1: A1 C vizual + 1–2 coins kad combo dosegne 5, dnevni cap (imenovana konstanta, npr. 10 coins/local day — nije put do upgradea). A2 A prozor 1.2–1.6 s. A3 A lomi SAMO timeout; pest eat i prazan drag NE resetiraju combo; Done/Back gase. A12 A + A33 B pair pulse u ISTOM PR-u (dok držiš chip, isti type_id+tier treperi). A16 A nema extra Muncher freeze. A20 A nema score/best save. A22 A nema auto-chain. A26 C nema tutorial toast. A31 A HUD copy "Combo". Sakrij HUD na combo 1, pokaži od 2.

Kod: merge_arena_controller.gd _on_chip_released; arena_seed_chip.gd drag/draw pulse; game_state.gd wallet + novi save key za dnevni combo-coin cap uz migrate; merge_arena_smoke.gd i/ili arena_combo_smoke.gd.

U planu: timer/combo state; grant coins jednom na prijelazu na 5 (ne svaki merge 6,7,… osim ako cap logika to eksplicitno treba — default jednom po streaku na pragu 5); pulse fan-out na drag_started; pest _pest_eat_chip ne dira combo.

Smokes: dva mergea unutar 1.4 s → combo 2; wait 2 s → 0; peti merge u nizu wallet+; eat chip dok je combo 3 → combo ostaje 3; dragging clover pulsea druge clover T1.

Headless --rendering-driver opengl3. Ne paliti GUI Godot usred COMB-A. Na kraju sesije jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne godot-watch.

Ne dirati: bloom panel (FLOW-A), auto-refill (FLOW-B), daily, Pip/tint, Sort, pest FSM, Home, IAP, AdMob, SAVE_VERSION osim novog cap keya, merge-arena-v1.1.md kanon.

Relevantno: docs/03-content/ideje-arena-grupe.md G1, ideje-arena-ciljevi.md, ideje-arena-feel.md pulse, ideje-arena-pitanja.md A1 A2 A3 A12 A16 A20 A22 A26 A31 A33, plan-prompts-arena.md.

Acceptance: HUD "Combo N" od 2 naviše unutar ~1.5 s; timeout gasi; combo 5 daje 1–2 coins unutar dnevnog capa; pulse partnera dok držiš; Muncher ne kida streak.
```

---

## Prompt — FLOW-A (Nema bloom panela; leftover T2 → 2× T1)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow ARENA-01 FLOW-A — ukloni Donate/Album/Basket panel; leftover T2 recycle.

Freeze G2 (ovaj slice): A10 A T2 ostaje za T2→T3. A11 D auto-riješi T2 kad NEM A šanse za par u ovom runu (drugi T2 istog tipa na polju ILI dovoljno T1 tog tipa na polju+u bagu za još jedan T2; ako bag još može pourati taj tip, NE recycle). A11b E leftover T2 → 2× T1 istog tipa u seed_bag. A11c B u areni NEM A bloom panela; T3 i dalje garden stash / crystal; Camp i dalje smije donate/album/basket. A25 A odd T1 ostaju do Done.

Ukloniti BloomActionPanel, _on_bloom_tapped / _show_bloom_panel i tap-spend na T2. Ne dirati COMB-A combo math.

Leftover check nakon merge/eat/pour. Recycle: ukloni T2 chip, bag[type_id] += 2.

Ažurirati arena_odd_t2_smoke (stari ugovor recycle T2 kao 1 seed — sada 2 T1). merge_arena_smoke: tap T2 ne otvara panel.

Headless OpenGL. Na kraju jednom .\scripts\godot-run.ps1 (block_until_ms 0). Ne watcher.

Ne dirati: combo HUD/pulse/coins, auto-refill na 10 (FLOW-B), daily, Pip, pest FSM, Home, IAP, kanon spec markdown.

Relevantno: ideje-arena-grupe.md G2 FLOW-A, ideje-arena-bloom.md, A10 A11 A11b A11c A25, merge_arena_controller.gd _setup_bloom_panel _on_chip_released, game_state seed_bag, arena_odd_t2_smoke.gd.

Acceptance: nema Donate/Album/Basket overlaya; T2+T2 → T3 crystal; T2 bez para u runu nestane i bag +2 T1; T1 leftover i dalje Done.
```

---

## Prompt — FLOW-B (Auto-refill na 10 + prefer orphan)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow ARENA-01 FLOW-B — auto-pour kad polje padne na 10; preferiraj orphan tipove.

Freeze: A14 D ARENA_MAX_CHIPS ostaje 40; kad broj chipova na polju <= 10 i bag > 0 i ima slota, vreća se SAMA istrese do 40 ili praznog baga (ciklus dok ima sjemena). Nije ručni tap za svaki val. A15 B pour (auto i ručni tap bag) preferira type_id koji već ima 1 chip na polju ako bag to ima. A24 C Done uvijek OK — auto-refill ne tera igrača da ostane do praznog baga.

Ne dirati combo math (COMB-A). Ne dirati leftover T2 pravila (FLOW-A mora biti gotov).

Hook: nakon merge/remove/eat, ako size <= 10, pour. Izbjegni reentrancy/spam pour u istom frameu.

Smokes: 11 chipova, merge na 10 → bag se smanji i polje raste; prefer: 1 clover na polju + bag clover+daisy → sljedeći pour clover ako clover ostaje u bagu.

Headless OpenGL. Na kraju jednom godot-run.ps1. Ne watcher.

Ne dirati: combo, bloom panel (već uklonjen), daily, Pip, Sort, pest FSM, Home, IAP.

Relevantno: ideje-arena-grupe.md G2 FLOW-B, A14 A15 A24, merge_arena_controller _on_bag_clicked _spawn_poured_chips GameState pour pick.

Acceptance: polje padne na 10 → auto-pour bez tappa vreće; novi chipovi guraju orphan tipove; Done i dalje radi usred refill petlje.
```

---

## Prompt — DAILY-A (Jedan arena zadatak; progress areni, badge Camp)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow ARENA-01 DAILY-A — jedan dnevni arena zadatak, badge bez loota.

Freeze G3: A6 A jedan zadatak / local day (prvi DG-01 slice, NE trijada run+donate+arena). A7 C nagrada samo vizualni badge/streak — BEZ coins, BEZ sjemena (combo coins su COMB-A). A8 C mali progress u areni npr. "2/5"; Claim/badge na Camp daily chest duhu. Ne blokirati Done. Ne auto-otvarati arenu u ponoć.

Generator (jedan od, unlocked types only): merge 3× T2 / napravi 1 T3 / dosegni combo 5 jednom. Persist novi day key (ne gutati last_daily_chest_day). Claim 1×/dan u Campu.

UI: arena jedan red progress; Camp pokaži complete/badge. Ne cliff rečenica u areni (A5 C).

Ovisi o COMB-A (combo 5) i FLOW-A (T2 još postoji na polju).

Headless OpenGL. Smoke: novi dan novi target; progress raste na merge; claim u camp ne dodaje wallet; drugi claim isti dan no-op.

Na kraju jednom godot-run.ps1. Ne watcher.

Ne dirati: combo math osim čitanja combo za zadatak, pour, bloom panel, Pip, Home, IAP, puna DG-01 trijada, ekonomija-brojevi kanon dok dodaj u scope.

Relevantno: ideje-arena-grupe.md G3, ideje-arena-ciljevi.md daily, A6 A7 A8, camp_controller daily chest UI, game_state save.

Acceptance: arena pokazuje n/N; Camp badge kad je  N/N; nula coina s dailya; sutra reset.
```

---

## Prompt — FEEL-A (Pip na rubu + livada tint)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow ARENA-01 FEEL-A — mali Pip + sesijski BG tint.

Freeze G4: A18 B Pip na rubu playfielda, reakcija na combo (npr. >=2 ili T3); NIJE kolizija, NIJE pest eat target, z-index ispod HUD iznad praznog BG. A19 B lagani livada tint raste s brojem T3 u OVOJ sesiji; reset na Done/Back. A27 pitch-up SFX NIJE ovaj slice.

Ne dirati combo math, pour, leftover T2, daily logiku — samo slušaj postojeće evente (merge/T3/combo).

Placeholder grafika OK (Godot primitive / postojeći Pip asset ako već ima). Ne novi shop IAP.

Headless: node postoji; tint modulate mijenja se nakon T3; Done vraća default.

Na kraju jednom godot-run.ps1. Ne watcher.

Ne dirati: Home, pest FSM, bloom, Sort, AdMob, clear-field VFX (FEEL-B).

Relevantno: ideje-arena-grupe.md G4 FEEL-A, A18 A19, merge_arena.tscn Playfield, ideje-arena-feel.md.

Acceptance: Pip vidljiv na rubu; T3 ili combo bump = kratka reakcija; BG zeleniji/cvjetniji s T3 u sesiji; Done resetira tint.
```

---

## Prompt — FEEL-B (Clear-field VFX)

```
MODE: Plan only — ne implementiraj. Napravi detaljan i opširan plan.

Projekt: Merge Meadow ARENA-01 FEEL-B — clear-field celebration, samo VFX.

Freeze: A9 B kad na polju NEM A legalnog para (isti type+tier count >= 2), odd leftover OK — mali VFX. BEZ coina (combo coins ostaju COMB-A). Nije fail. Nije zvono za Done. Bag još smije imati sjeme (pour again OK). Sesijski, ne spam svaki frame — jednom kad stanje postane "nema para" dok nije već celebrirano ovaj pour.

Ovisi o FLOW-A (nema panela koji laže "ima akciju"). COMB-A ne dirati.

Headless teško za VFX — smoke: helper is_clear_of_pairs true kad 3 različita T1; false kad 2 ista T1; flag ne grant-a wallet.

Na kraju jednom godot-run.ps1. Ne watcher.

Ne dirati: Pip/tint (FEEL-A), combo, daily, pest FSM, Home, IAP, A27 audio.

Relevantno: ideje-arena-grupe.md G4 FEEL-B, ideje-arena-ciljevi.md clear-field, A9.

Acceptance: kad ostane samo nespareno sjeme, jedan vizualni beat; wallet ne raste; Done i pour i dalje rade.
```

---

## Redoslijed i ovisnosti

1. **COMB-A** prvo (A32 / A33).  
2. **FLOW-A** prije **FLOW-B**.  
3. **DAILY-A** nakon COMB-A (i FLOW-A ako daily broji T2).  
4. **FEEL-A** pa **FEEL-B** zadnje.  
5. Ne spajati COMB i FLOW u jedan prompt.  
6. G5 nema prompta.

## Povezano

- [[../03-content/ideje-arena|hub]] · [[../03-content/ideje-arena-grupe|grupe]] · [[../03-content/ideje-arena-pitanja|pitanja]]
- [[plan-prompts-arena-leftover|ARENA-02 leftover]] LEFTOVER-P0 → A → B ✅ · C-P0 ✅ · C ✅ · D ✅ · E-P0 ✅ · E ne
- [[plan-prompts-arena-sort|ARENA-03 sort]] SORT-P0 ✅ A ✅ B ✅ VAC-A ✅ VAC-F ✅ VAC-L ✅
- [[plan-prompts-home-lockflow|HOME-10]] · [[plan-prompts-home-barfit|HOME-11]] · [[plan-prompts-home-cardfit|HOME-09]] (isti Plan-only obrazac)
- [[CHECKPOINT|CHECKPOINT]]
