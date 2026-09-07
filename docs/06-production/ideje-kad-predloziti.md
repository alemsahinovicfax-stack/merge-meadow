---
type: produkcija
status: aktivan
milestone: M7
tags: [produkcija, ideje, workflow, agent]
povezano:
  - ideje-roadmap-implementacije
  - ideje-prvo-iskustvo
  - ideje-gameplay-ekonomija
  - ideje-home-paid
  - ideje-home-glide
  - ideje-home-focus
  - ideje-home-unlock
  - ideje-home-incard
  - ideje-home-cardfit
  - ideje-home-lockflow
  - ideje-home-barfit
  - ideje-home-meadow
  - ideje-seed-pool
  - ideje-home-meadow-chrome
  - ideje-home-meadow-life
  - ideje-home-meadow-dock
  - ideje-home-meadow-field
  - ideje-home-unlock-poster
  - ideje-home-poster-fit
  - ideje-arena
  - ideje-arena-leftover
  - ideje-arena-sort
  - ideje-camp
  - ideje-camp-cliff
  - ideje-camp-link
  - ideje-camp-read
  - ideje-camp-row
  - ideje-camp-fill
  - CHECKPOINT
ai_sažetak: "Kad agent predlaže scratch ideju iz vaulta — triggeri, format, backlog UX-01+ / CAMP-06 / CAMP-05 / CAMP-04 / HOME-18 / HOME-17 / HOME-16 / CAMP-03 / ARENA / CAMP-01."
---

# Ideje — kad predložiti (agent + ti)

> **Scratch ideje** žive u `docs/03-content/ideje-*.md` i [[ideje-roadmap-implementacije|roadmap]].
> **Ne implementirati** bez potvrde (scope guard). Ovdje: **kada** ih ponuditi i **kako**.

## Pravilo (1 ideja po prilici)

Agent **može** ponuditi **najviše jednu** ideju kad trigger odgovara trenutnom poslu. Format:

```
💡 IDEJA [ID] — kratak naslov

Zašto sada: [1 rečenica veza s trenutnim korakom]
Što: [1–2 bulleta]
Effort: S / M / L · Milestone: M7 / v1.1 / v1
Primjeniti sada, odgoditi, ili preskočiti?
```

- **Ne** spamati svaku sesiju.
- **Ne** predlagati OUT scope (vidi `scope-i-granice.md`).
- **Da** predložiti kad CHECKPOINT korak i trigger tablica se poklapaju.

## Triggeri (kontekst → pogledaj ideje)

| Kad radimo… | CHECKPOINT / fajl | Predloži iz… | Primjer ID |
|-------------|-------------------|--------------|------------|
| Camp UI, navigacija, gumbi | `camp_*`, F4–F5, F8 shop | ideje-prvo-iskustvo, roadmap F8 | **UX-04** Hub carousel |
| Camp toast, Seeds/Flowers, companion picker, Sprinkler/Loot donate | `camp_controller`, `camp_scene`, upgrade kartice | [[../03-content/ideje-camp\|ideje-camp]] | **CAMP-01** |
| Seeds rupa, „Bag seeds are“, tekst između naslova i broja | `GardenCliff`, `_garden_cliff_text` | [[../03-content/ideje-camp-cliff\|ideje-camp-cliff]] | **CAMP-02** (kod → CAMP-03 A) |
| Seeds 0/40, Flowers nisu kao Seeds, nema next-lock u kampu | `BagLabel`, `crystal_stash_chip`, kamp Content | [[../03-content/ideje-camp-link\|ideje-camp-link]] | **CAMP-03** |
| Run feel, spawn, HUD | `run_controller`, F2–F5 | [[../03-content/ideje-gameplay-ekonomija\|gameplay ekonomija]] R1–R7 | R3 zlatni grm |
| Loot / fail / rewarded | `loot_screen`, F3 | prvo iskustvo, monetizacija M1–M2 | — |
| Ekonomija, shop, novčići | `game_state`, F8 | [[../02-design/ekonomija-brojevi\|brojevi]], ideje §6 shop | Shop stub |
| Tutorial, onboarding | `tutorial_*`, F6–F7 | [[../03-content/ideje-prvo-iskustvo\|prvo iskustvo]] | — |
| Art / placeholder zamjena | CHECKPOINT C2 | roadmap F8, ideje launch scope | Pip sprite |
| Retention, dnevni loop | poslije F7 gate | ideje T1–T4, K5 pasivni | Daily chest |
| Home Stage / Shop IAP / post-launch tema | Home polish, shop packs, v1.1 | [[../03-content/ideje-sezone\|ideje-sezone]] | **SEZ-01** |
| Home layout, Panel chrome, season strip | `main_menu`, `season_stage` | [[../03-content/ideje-home-polish\|HOME-01]] | **HOME-01** |
| Home strip swipe mrtav na karticama | `season_stage` gui_input, paneli | [[../03-content/ideje-home-hit-targets\|HOME-02]] | **HOME-02** |
| Home chrome, Endless Hard, strip slide | `main_menu`, Endless, `season_stage` tap/tween | [[../03-content/ideje-home-chrome\|HOME-03]] | **HOME-03** |
| Shop season packs / paid vs free na Homeu | `shop_screen`, `season_stage` dual-band | [[../03-content/ideje-home-paid\|HOME-04]] | **HOME-04** |
| Home L/R glajd, vertikalni band swipe, outline | `season_stage` slide/swipe | [[../03-content/ideje-home-glide\|HOME-05]] | **HOME-05** |
| Home L/R cut, invert swipe, Browser ne fokusira, Theme badge | `season_stage`, `season_browser`, `PlayThemeBadge` | [[../03-content/ideje-home-focus\|HOME-06]] | **HOME-06** |
| Swipe dolje select, next-lock Unlock, 48 roster cvjetova | `season_stage`, `game_state`, `seasons.json` | [[../03-content/ideje-home-unlock\|HOME-07]] | **HOME-07** |
| Roster/Unlock nisu u prozoru sezone, premalo se vidi | `season_stage` CenterSlot, roster/gate overlay | [[../03-content/ideje-home-incard\|HOME-08]] | **HOME-08** |
| Unlock nije na Amberu / ime nije na sredini / roster isti na svim sezonama | `TEST_LOCK` amber, CenterTitle, roster frame | [[../03-content/ideje-home-cardfit\|HOME-09]] | **HOME-09** |
| Roster biježi lijevo / ellipsis / boja kasni na swipe / locked = ime+barovi+zlatni Unlock | `FreeRoster` clip, `UnlockGate` kut, `seasons.json` cost | [[../03-content/ideje-home-lockflow\|HOME-10]] | **HOME-10** |
| Barovi prekrivaju 🔒+ime / suvišan gate okvir / treba 500c za test Unlock | `UnlockGate` `anchor_top`, `make_frame`, debug wallet | [[../03-content/ideje-home-barfit\|HOME-11]] | **HOME-11** |
| Uđi u sezonu, polje na Homeu, Pip šeta, Seasons natrag, apply_season | `season_stage`, `main_menu` Play, SeasonField | [[../03-content/ideje-home-meadow\|HOME-12]] | **HOME-12** |
| Basket u polju, Endless samo u sezoni, full-bleed tint, Pip van, natrag s karusela | `BasketCard`, `EndlessPlayButton`, `PipPortrait`, `MeadowPip`, `SeasonsButton` | [[../03-content/ideje-home-meadow-chrome\|HOME-13]] | **HOME-13** |
| Play na locked/paid → run; nejednaki PlayRow; malo cvijeća; Pip skriven u polju | `_on_play_pressed`, `PlayRow`, `FLOWER_SLOTS`, `MeadowPip` | [[../03-content/ideje-home-meadow-life\|HOME-14]] | **HOME-14** |
| Basket u PlayRow; picker bez ★3; T1/T2 vs T3 mismatch; chip zatvara polje; Daily arena streak | `BasketCard`, `PickerList`, `SeasonNameChip`, Daily caption | [[../03-content/ideje-home-meadow-dock\|HOME-15]] | **HOME-15** |
| Daily overlay eho; picker scroll; hub swipe mrtav u polju; Sprinkler u kampu | `RewardOverlay`, `PickerScroll`, `block_hub_swipe`, `UpgradeCards` | [[../03-content/ideje-home-meadow-field\|HOME-16]] | **HOME-16** |
| Locked gate ružan; basket krije sjeme; chest/basket ne zovu tap | `UnlockGate`, `SeasonLinkCard`, `BasketCard`, Daily | [[../03-content/_archive/ideje-home-unlock-poster\|HOME-17 (arhivirano)]] | **HOME-17** |
| Ime/katanac gore; coin+flower jedan blok; watermelon u basketu a ne na rosteru | `CenterTitle`, `UnlockGate` `anchor_top`, `season_unlock_progress`, `seasons.json` | [[../03-content/ideje-home-poster-fit\|HOME-18]] | **HOME-18** |
| Camp Unlock uži od Exchange; coin/flower nečitljivi; chip 68 ime+★ u jednoj liniji | `SeasonLinkInset`, `season_unlock_progress`, `seed_bag_chip`, `crystal_stash_chip` | [[../03-content/_archive/ideje-camp-read\|CAMP-04 (arhivirano)]] | **CAMP-04** |
| Sve sezone otključane; nema Camp linka; chip 176 previsok; T1 ★☆☆ | `debug_playtest_two_free`, `seed_bag_chip`, `rarity_stars` | [[../03-content/ideje-camp-row\|CAMP-05]] | **CAMP-05** |
| Pip's Garden + vanjski scroll; link vline do pola; chip ime/count vertikalno | `CampTitle`, `MainScroll`, `season_unlock_progress`, chips | [[../03-content/ideje-camp-fill\|CAMP-06]] | **CAMP-06** |
| Frost spawna clover, album nema snowdrop, T1–T3 svih sezona, camp imena | `seasons.json` seed_type_ids, CHAIN, camp_plant_draw, journal | [[../03-content/ideje-seed-pool\|SEED-01]] | **SEED-01** |
| Merge UX, slot overflow | kamp playtest, pre-launch | [[../02-design/merge-arena-v1.1\|merge-arena-v1.1]] | **MA-01** Merge Arena |
| Arena monotonija, combo, cliff, daily u areni | `merge_arena_controller`, Muncher, post-MA-01 playtest | [[../03-content/ideje-arena\|ideje-arena]] | **ARENA-01** |
| Odd T1 na polju, pour ostatak, vreća s 1–3, „trebam još sjemena“, overlay ostaje nakon Camp | `pull_seeds_to_arena`, `NeedMoreSeedsOverlay`, `ensure_dev_unlocked_seeds`, post-ARENA-01 playtest | [[../03-content/ideje-arena-leftover\|ideje-arena-leftover]] | **ARENA-02** |
| Muncher ostavi 3 T1, pour miješa tipove, daisy pa sljedeći, vacuum kad nema T3 | `_build_arena_pour_queue`, `_pest_eat_chip`, leftover-A floor-4, post-ARENA-02 playtest | [[../03-content/ideje-arena-sort\|ideje-arena-sort]] | **ARENA-03** |
| Daily retention | post-launch metrika | merge-arena-v1.1 § DG-01 · ARENA-01 daily slice | **DG-01** Daily Goals |

## Backlog — UX / flow (prioritet za predlaganje)

| ID | Ideja | Trigger (kad ponuditi) | Effort | Milestone |
|----|-------|------------------------|--------|-----------|
| **UX-01** | **Main menu gumb u kampu** | Camp navigacija | **S** | ✅ M7 2026-07-05 |
| **UX-04** | **Hub carousel** (Clash Royale swipe) — Shop · **Main Menu (centar)** · Camp · Arena · Collection | F8 shop, C2 art, meta UI | **L** | v1.1.0 |
| **MA-01b** | **Arena Muncher** — pest jede T1/T2, freeze na T3 | MA-01 playtest | **M** | v1.1.0 |
| UX-02 | Progress traka umjesto countdown tajmera | Run HUD / C2 art pass | M | v1.1 |
| UX-03 | Reset tutorial (dev) u settings | Debug, QA tutoriala | S | dev only |
| **MA-01** | **Merge Arena** (zamjena gredica) | Slot overflow, merge feel | **L** | v1.1.0 |
| **DG-01** | **Daily Goals** (3 task + bonus) | Retention, daily loop | **M** | v1.1.1 |
| **SEZ-01** | **Sezone / teme** (free linear + paid IAP; Home Stage) | Home, Shop IAP, post-launch | **L** | v1.1+ · prompti [[plan-prompts-sez-01\|plan-prompts-sez-01]] **P0–E ✅** |
| **HOME-01** | **Home polish** — ukinuti Panel; 3-slot free swipe | `main_menu`, Season Stage | **M** | v1.1+ · prompti [[plan-prompts-home-polish\|plan-prompts-home-polish]] **P0–C ✅** |
| **HOME-02** | **Hit targets** — swipe+tap preko kartica | `season_stage` paneli gutaju input | **S** | v1.1+ · [[plan-prompts-home-hit-targets\|plan-prompts-home-hit-targets]] **HIT-A ✅** |
| **HOME-03** | **Home chrome** — 2 gumba, Browser samo C, Endless Hard, slide | `main_menu`, Endless, strip tween | **M** | v1.1+ · [[plan-prompts-home-chrome\|plan-prompts-home-chrome]] **P0–C ✅** |
| **HOME-04** | **Paid dual-band + shop packs** — bez Select; 2-col; 20/80 paid/free | Shop packs, Home paid vs free | **L** | v1.1+ · [[plan-prompts-home-paid\|plan-prompts-home-paid]] **P0–C ✅** |
| **HOME-05** | **Glide + katalog** — full-slot L/R; vertikalni swap; Play outline; +1 free +2 paid | Home swipe, nove sezone | **M** | v1.1+ · [[plan-prompts-home-glide\|plan-prompts-home-glide]] **P0–C ✅** |
| **HOME-06** | **Focus korekcija** — L/R bez cuta; invert swipe; Browser fokus; outline; test-lock; bez badgea | L/R cut, Browser, Theme: label | **M** | v1.1+ · [[plan-prompts-home-focus\|plan-prompts-home-focus]] **P0–C ✅** |
| **HOME-07** | **Unlock + roster** — swipe dolje select; next-lock Unlock; 48 T3 cvjetova | Select, lantern test, roster | **M** | v1.1+ · [[plan-prompts-home-unlock\|plan-prompts-home-unlock]] **P0–C ✅** |
| **HOME-08** | **In-card chrome** — roster+Unlock u hero-centar prozoru; veći tip; Lantern gate na kartici | Overlay vs prozor, čitljivost | **S** | v1.1+ · [[plan-prompts-home-incard\|plan-prompts-home-incard]] **P0–B ✅** |
| **HOME-09** | **Cardfit** — Amber off TEST_LOCK; naslov sredina; roster kontrast+širina | Unlock „nije napravljen“, ime gore, isti tamni roster | **S** | v1.1+ · [[plan-prompts-home-cardfit\|plan-prompts-home-cardfit]] **P0–B ✅** |
| **HOME-10** | **Lockflow** — locked poster 500/20 gold; roster desno bez ellipsisa; wash | Roster clip lijevo, `...`, swipe glitch boje, Unlock nije ime+barovi | **S** | v1.1+ · [[plan-prompts-home-lockflow\|plan-prompts-home-lockflow]] **P0–B ✅** |
| **HOME-11** | **Barfit** — gate niže ispod 🔒+ime; bez okvira; debug 500c | Barovi prekrivaju ime/katanac, wash panel suvišan, Unlock se ne da testirati | **S** | v1.1+ · [[plan-prompts-home-barfit\|plan-prompts-home-barfit]] **P0–A ✅** |
| **HOME-12** | **Meadow** — jedno SeasonField, sve playable; tap/Play → polje; Play na polju → run; Seasons natrag | Dual-band umjesto svijeta; Play odmah run; 8 scena | **M** | v1.1+ · [[../03-content/ideje-home-meadow\|ideje-home-meadow]] **MEADOW-P0 ✅** · [[plan-prompts-seed-meadow\|plan-prompts-seed-meadow]] 4–6 ✅ |
| **HOME-13** | **Meadow chrome** — Basket/Endless u polju; full-bleed; Pip van; name-chip natrag | Basket na karuselu; Endless krivi spawn; Seasons gumb na cvijeću | **M** | v1.1+ · [[../03-content/ideje-home-meadow-chrome\|ideje-home-meadow-chrome]] **CHROME-P0 ✅ A–E ✅** · [[plan-prompts-home-meadow-chrome\|plan-prompts-home-meadow-chrome]] |
| **HOME-14** | **Meadow life** — Play 3-koraka; jednaki PlayRow; 12–14 cvjetova u safe zoni; Pip hod/njuh/spavanje | Play na paid/locked = run; nejednaki gumbi; cvijeće pod chromeom; Pip off | **M** | v1.1+ · [[../03-content/ideje-home-meadow-life\|ideje-home-meadow-life]] **LIFE-P0 ✅ A ✅ B ✅** · [[plan-prompts-home-meadow-life\|plan-prompts-home-meadow-life]] C–D |
| **HOME-16** | **Meadow field** — Daily overlay body; basket no-scroll; hub swipe u polju; Magnet+Loot na polju | Overlay eho; PickerScroll; field blokira hub; Sprinkler u kampu | **M** | v1.1+ · [[../03-content/ideje-home-meadow-field\|ideje-home-meadow-field]] **FIELD-P0 ✅** · [[plan-prompts-home-camp-field\|plan-prompts-home-camp-field]] A–D |
| **HOME-17** | **Unlock poster + basket roster + attention** — coin+★3; sva sjemena; blink+shake | Locked gate tekst; picker krije locked; prazan basket / daily | **M** | v1.1+ · [[../03-content/_archive/ideje-home-unlock-poster\|ideje-home-unlock-poster (arhivirano)]] · [[_archive/plan-prompts-home-unlock-poster\|plan-prompts-home-unlock-poster]] (title-TOP / gate 0.26 / watermelon ★2 **superseded** HOME-18) |
| **HOME-18** | **Poster fit + drop watermelon** — 🔒+ime sredina; poster dolje; divider; coin 40 / flower 92; Bloom 6 tipova | Ime gore; coin+flower jedan blok; watermelon nije na rosteru | **S** | v1.1+ · [[../03-content/ideje-home-poster-fit\|ideje-home-poster-fit]] · [[plan-prompts-home-poster-fit\|plan-prompts-home-poster-fit]] ✅ |
| **SEED-01** | **Seed pool** — jedan type_id; run/journal/arena/camp po sezoni; T1–T3 fallback | Roster ≠ spawn; CHAIN-only journal; Frost = clover | **M** | v1.1+ · [[../03-content/ideje-seed-pool\|ideje-seed-pool]] **SEED-P0 ✅** · [[plan-prompts-seed-meadow\|plan-prompts-seed-meadow]] 1–3 |
| **ARENA-01** | **Arena zabavnija** — combo+pulse, auto-refill, leftover T2→2×T1, daily badge | Arena dosadna, Muncher, T2 chore | **M** | v1.1+ · [[../03-content/ideje-arena\|ideje-arena]] **freeze ✅** · kod COMB-A…FEEL-B ✅ · [[plan-prompts-arena\|plan-prompts-arena]] |
| **ARENA-02** | **Leftover ÷4** — pour ×4; refill 12; overlay n/4 tap→Camp; hide+naslov; debug 100 | Odd T1 na polju; overlay ostaje na tab return | **S** | v1.1+ · [[../03-content/ideje-arena-leftover\|ideje-arena-leftover]] **P0 ✅ A ✅ B ✅ C-P0 ✅ C ✅ D ✅ E-P0 ✅** · E kod ne · [[plan-prompts-arena-leftover\|plan-prompts-arena-leftover]] |
| **ARENA-03** | **Sort + vacuum** — pour sav T1 po CHAIN; skip &lt;4; vacuum t1_eq &lt; 4; overlay ostaje | Muncher 3 T1; pour miješa tipove; leftover-A floor-4 | **M** | v1.1+ · [[../03-content/ideje-arena-sort\|ideje-arena-sort]] **SORT-P0 ✅ A ✅ B ✅ VAC-A ✅ VAC-F ✅ VAC-L ✅** · [[plan-prompts-arena-sort\|plan-prompts-arena-sort]] |
| **CAMP-01** | **Kamp chrome + Flowers upgrade** — Seeds/Flowers; bez toast/companion; 2 T3 po Upgrade | Toast, Garden ime, donate in Arena, companion picker | **M** | v1.1+ · [[../03-content/ideje-camp\|ideje-camp]] **CAMP-P0 ✅ A ✅ B ✅** · [[plan-prompts-camp\|plan-prompts-camp]] |
| **CAMP-02** | **Seeds cliff** — prazna rupa između Seeds i `Seeds: n` | „Bag seeds are T1…“ | **S** | v1.1+ · [[../03-content/ideje-camp-cliff\|ideje-camp-cliff]] **CAMP2-P0 ✅** · A superseded · [[plan-prompts-camp-cliff\|plan-prompts-camp-cliff]] |
| **CAMP-03** | **Kamp link** — Seeds/Flowers naslov +10%; Flowers = Seeds; next-lock → Home | `0/40`, bijeli flower chipovi, nema sezonskog progresa | **M** | v1.1+ · [[../03-content/ideje-camp-link\|ideje-camp-link]] **CAMP3-P0 ✅ A–C ✅** · [[plan-prompts-home-camp-field\|plan-prompts-home-camp-field]] (scroll 280 / uski Unlock / chip 68 **superseded** CAMP-04) |
| **CAMP-04** | **Camp read** — split SeasonLink; Unlock = Exchange; chip stack + 3-slot zvijezde; scroll 420 | Unlock uži; coin/flower nečitljivi; chip ime+★ | **M** | v1.1+ · [[../03-content/_archive/ideje-camp-read\|ideje-camp-read (arhivirano)]] · [[_archive/plan-prompts-camp-read\|plan-prompts-camp-read]] ✅ (chip 176 / 3× `☆` **superseded** CAMP-05) |
| **CAMP-05** | **Camp row** — two-free fixture; chip red + filled ★; SeasonLink = Garden dimenzije | Sve sezone otključane; nema linka; chip previsok | **S** | v1.1+ · [[../03-content/ideje-camp-row\|ideje-camp-row]] · [[plan-prompts-camp-row\|plan-prompts-camp-row]] ✅ (MainScroll+420 **superseded** CAMP-06) |
| **CAMP-06** | **Camp fill** — thirds; no Pip's Garden; link symmetry; chip name+count | Vanjski scroll; vline; chip stack | **M** | v1.1+ · [[../03-content/ideje-camp-fill\|ideje-camp-fill]] · [[plan-prompts-camp-fill\|plan-prompts-camp-fill]] |

### UX-01 — Main menu u kampu (detalj)

**Problem:** Nakon tutorijala hub je **Play + Camp** na main menuu, ali iz kampa jedini izlaz je **Play** — treba ugasiti Godot da vidiš hub.

**Rješenje:** Gumb u `camp_scene` (npr. ispod Play ili u headeru): **Main Menu** → `SceneRouter` → `main_menu.tscn`. Ne dira save; `tutorial_complete` ostaje.

**DoD:** Jedan tap iz kampa → main menu s Play + Camp; headless smoke prolazi.

**Povezano:** [[../03-content/ideje-prvo-iskustvo#nakon-tutorijala--main-menu-hub-odlučeno-2026-07-04|post-tutorial hub]]

### UX-04 — Hub carousel (Clash Royale meta) — odobreno v1.1.0 (2026-07-29)

**Koncept:** Jedan meta-layer s **swipe L/R** između 5 full-screen stranica. **Default landing = Main Menu (centar).**

| # | Stranica | Svrha |
|---|----------|--------|
| 0 | **Shop** | Kozmetika, IAP, coins sink |
| 1 | **Main Menu ★** | Play, Endless, Camp/Shop shortcuti (trenutni hub) |
| 2 | **Camp / Garden** | Upgrade kartice, daily, Play/Merge footer |
| 3 | **Merge Arena** | MA-01 + MA-01b Muncher |
| 4 | **Collection / Journal** | Album, ★★★ preview |

**Run / loot** ostaju odvojene scene (ne dio carousela).

**Kod:** `game/scenes/meta/meta_hub.tscn`, `swipe_pager.gd`, `meta_hub_controller.gd`.

**Effort:** L — implementirano u v1.1 paket.

## Agent checklist (po sesiji)

1. Pročitaj CHECKPOINT `sljedeci_korak` + aktivnu datoteku.
2. Pogledaj tablicu triggera gore — ima li **točan** match?
3. Ako da → jedna `💡 IDEJA` prije zatvaranja sesije **ili** na početku sljedećeg koraka (ne usred bugfixa).
4. Ako korisnik kaže **primjeni** → provjeri scope → implementiraj → ažuriraj roadmap/changelog.
5. Ako **odgodi** → ostavi u ovom docu; ne briši.

## Povezano

- [[ideje-roadmap-implementacije|build order F0–F9]]
- [[../03-content/ideje-prvo-iskustvo|prvo iskustvo]]
- [[../03-content/ideje-gameplay-ekonomija|gameplay ekonomija]]
- [[../03-content/ideje-sezone|SEZ-01 sezone]]
- [[../03-content/ideje-arena|ARENA-01 Merge Arena]]
- [[plan-prompts-arena|plan-prompts-arena]] — COMB-A→FEEL-B ✅
- [[../03-content/ideje-arena-leftover|ARENA-02 leftover]]
- [[../03-content/ideje-arena-leftover-field|ARENA-02 field leftover T1]] (E kod ne)
- [[plan-prompts-arena-leftover|plan-prompts-arena-leftover]] — P0→A→B ✅ · C-P0 ✅ · C ✅ · D ✅ · E-P0 ✅ · E ne
- [[../03-content/ideje-arena-sort|ARENA-03 sort]]
- [[plan-prompts-arena-sort|plan-prompts-arena-sort]] — SORT-P0 ✅ A ✅ B ✅ VAC-A ✅ VAC-F ✅ VAC-L ✅
- [[../03-content/ideje-home-lockflow|HOME-10 Lockflow]]
- [[../03-content/ideje-home-barfit|HOME-11 Barfit]]
- [[../03-content/ideje-home-meadow|HOME-12 Meadow]]
- [[../03-content/ideje-home-meadow-chrome|HOME-13 Meadow chrome]]
- [[../03-content/ideje-home-meadow-life|HOME-14 Meadow life]]
- [[../03-content/ideje-home-meadow-dock|HOME-15 Meadow dock]]
- [[../03-content/ideje-home-meadow-field|HOME-16 Meadow field]]
- [[../03-content/_archive/ideje-home-unlock-poster|HOME-17 Unlock poster]] (arhivirano)
- [[_archive/plan-prompts-home-unlock-poster|plan-prompts-home-unlock-poster]] (arhivirano)
- [[../03-content/ideje-home-poster-fit|HOME-18 Poster fit]]
- [[plan-prompts-home-poster-fit|plan-prompts-home-poster-fit]]
- [[../03-content/ideje-seed-pool|SEED-01 seed pool]]
- [[plan-prompts-seed-meadow|plan-prompts-seed-meadow]] — 1 SEED-A … 6 MEADOW-C
- [[plan-prompts-home-meadow-chrome|plan-prompts-home-meadow-chrome]] — CHROME-P0 ✅ A–E ✅
- [[plan-prompts-home-meadow-life|plan-prompts-home-meadow-life]] — LIFE-P0 ✅ A ✅ B ✅ → C–D
- [[plan-prompts-home-meadow-dock|plan-prompts-home-meadow-dock]] — DOCK-P0 ✅ A–D ✅
- [[plan-prompts-home-camp-field|plan-prompts-home-camp-field]] — FIELD-P0 ✅ CAMP3-P0 ✅ → A–D / A–C
- [[../03-content/ideje-camp|CAMP-01 kamp]]
- [[plan-prompts-camp|plan-prompts-camp]] — P0 ✅ A ✅ B ✅
- [[../03-content/ideje-camp-cliff|CAMP-02 Seeds cliff]]
- [[plan-prompts-camp-cliff|plan-prompts-camp-cliff]] — CAMP2-P0 ✅ · A superseded
- [[../03-content/ideje-camp-link|CAMP-03 kamp link]]
- [[../03-content/_archive/ideje-camp-read|CAMP-04 Camp read]] (arhivirano)
- [[_archive/plan-prompts-camp-read|plan-prompts-camp-read]] (arhivirano)
- [[../03-content/ideje-camp-row|CAMP-05 Camp row]]
- [[plan-prompts-camp-row|plan-prompts-camp-row]]
- [[../03-content/ideje-camp-fill|CAMP-06 Camp fill]]
- [[plan-prompts-camp-fill|plan-prompts-camp-fill]]
- [[../03-content/ideje-home-cardfit|HOME-09 Cardfit]]
- [[plan-prompts-sez-01|plan-prompts-sez-01]] — P0→E
- `.cursor/rules/ideje-kad-predloziti.mdc`
