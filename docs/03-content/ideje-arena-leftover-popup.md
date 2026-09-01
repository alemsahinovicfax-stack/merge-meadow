---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, leftover, popup, camp, ux, scratch]
povezano:
  - ideje-arena-leftover
  - ideje-arena-leftover-math
  - ideje-arena-leftover-pour
  - ideje-arena-leftover-grant
  - ideje-arena-leftover-field
  - ideje-arena-leftover-pitanja
  - ideje-arena-sort
ai_sažetak: "ARENA-02 overlay You need more seeds — n/4 lista; tap = Camp; C gasi overlay i vraća čist Arena ekran; naslov svijetao u popup-u."
---

# IDEJE — ARENA-02 popup (You need more seeds)

> [[ideje-arena-leftover|hub]]. **LEFTOVER-B ✅.** **LEFTOVER-C ✅** (dismiss + restore + čitljiv naslov). Overlay `NeedMoreSeedsOverlay` u areni; `SeedBagChip.set_count_quota_display`.  
> Kamp lista: [`get_seed_bag_entries`](../../game/scripts/autoload/game_state.gd) + [`seed_bag_chip.gd`](../../game/scripts/camp/seed_bag_chip.gd). Arena Done: `_on_done_pressed` → commit chipova → `go_to_camp_hub`.  
> Freeze dismiss: [[ideje-arena-leftover-pitanja|L21–L25]]. Debug bag: [[ideje-arena-leftover-grant|grant]] (D, nije ovaj fajl).  
> **ARENA-03 nije overlay.** Sort/vacuum ne mijenja B+C copy, hide ni `n/4`. [[ideje-arena-sort|ARENA-03]].  
> **E nije overlay.** Field docs: [[ideje-arena-leftover-field|field]] (E-P0 ✅; E kod **ne** — vacuum u ARENA-03). B+C copy, hide i `n/4` ostaju.

## Zašto overlay, ne prazan tap

Igrač **vidi** sjeme u vreći (broj na bag UI, preview peek). Instinkt: tap. Ako tap ne radi, misli da je bug. Ako tap trese 3 daisy, vraća se leftover na polju.

Zato: vreća **ostaje klikabilna**. Funkcija se **mijenja** kad `pull_seeds_to_arena` ne može izvući nijedan T1 (nema tipa s ≥4 **ili** nema slota — slot full je postojeća poruka, nije ovaj overlay).

Stuck = **bag > 0** i **nema pourable ×4** i **ima slota** (inače full).

## Copy (mora biti u popup-u i čitljiva)

Naslov / prvi red, ENG kao ostali arena HUD (L9 / L24):

**You need more seeds!**

To **nije** `info_label` ispod vreće. To **nije** toast. To je **naslov unutar** `NeedMoreSeedsOverlay` panela, iznad `n/4` liste. Igrač koji otvori popup mora odmah pročitati rečenicu — lista objašnjava *koliko* fali (`3/4`), naslov objašnjava *što* treba.

Nema drugog tutorial pasusa (L6). Lista **je** drugo objašnjenje. Ne dodavati „Go to camp to collect more from runs and chests.“

Nije:

- „Come back tomorrow“
- „Watch an ad“
- „Buy pack“
- cliff rečenica
- IAP sheet

Fair F2P: jedini CTA je **ići u Camp** (run, daily chest, trade) — već postojeći loop.

### Zašto naslov danas nestaje (B bug, C fix)

Node **postoji** u [`merge_arena.tscn`](../../game/scenes/camp/merge_arena.tscn):

- `NeedMoreSeedsOverlay` — full-rect, `z_index` 30, default `visible = false`
- `Dim` — `Color(0.06, 0.08, 0.07, 0.72)` (tamni veo)
- `Panel` — `PanelContainer` (Godot default tema: tamna ploča)
- `NeedMoreSeedsTitle` — text `You need more seeds!`, font 28, autowrap

U `_ready` controller zove `TEXT_LAYOUT.section_title_scroll(need_more_title)`. Taj helper radi `ink(label)` → `UI_PALETTE.UI_TEXT` = **`#4A4A4A`** (tamnosiva tintana za *svijetli* kamp papir). Na tamnom dimu i tamnom panelu naslov je **u stablu, ali nečitljiv**. Playtest: „poruka treba biti u tom pop-upu“ — jest u tscn, nije na oku.

**C (L24):** ne koristiti `section_title_scroll` ink na ovom labelu. Svijetla boja (bijela ili meadow cream, visok kontrast na `#0F1412`-ish dimu). `clip_text = false`. Naslov `size_flags_vertical` shrink; `NeedMoreSeedsScroll` `SIZE_EXPAND_FILL` da lista skrola, naslov **ne** nestane iznad folda.

Smoke C: naslov `visible`, `modulate.a > 0.9`, `font_color` luminance jasno iznad panela (ne `#4A4A4A`).

## Lista

- **Isti** vizualni redovi kao Garden seed bag: ikona, ime, rarity sort.
- Count label: **`%d/4` % count**, ne goli count, ne coin pill za trade.
- `set_trade_eligible(false)` / tap na red **ne** selecta trade (L8). Cijeli overlay gutlja tap → Camp.
- Sakrij count 0 (L5). U stuck stanju svi prikazani imaju 1–3 (nakon D freeze-a, remainderi 1–3 plus tulip 0 se ne crta).
- Scroll ako ima puno tipova (7 u chainu; stuck max svih 7 s remainder).

Ne duplicirati layout u novom vizualnom jeziku. Reuse `SeedBagChip` + `apply(...)` + override count string **ili** tanki `count_display_mode` (`raw` vs `t3_quota`). Kamp ostaje `raw`. Chipovi u listi `mouse_filter = IGNORE` da tap padne na overlay.

## Tap bilo gdje → Camp (B ostaje; C dodaje hide)

Cijeli overlay (dim + panel + praznina): `gui_input` pressed → **isti side-effect kao Done**, **plus** hide:

1. **`_hide_need_more_overlay()`** — `visible = false`; skinuti djecu iz `NeedMoreSeedsList` (stale chipovi ne smiju ostati za sljedeći show).
2. Combo clear, pair pulse clear, session feel reset (FEEL-A tint).
3. `commit_arena_chips_to_bag` (ako je pest ostavio T1/T2 na polju).
4. Clear field, pest nest.
5. Unlock hub nav.
6. `GameState.go_to_camp_hub()`.

Redoslijed: **hide prije** `go_to_camp_hub` (L21). Hub **ne čeka** da se Arena scene uništi — vidi dolje.

Hub Arena tab i standalone arena: **isti** path (L4).

Nije potrebno dvostruko „Close“ + „Go to Camp“. Jedan tap = odlazak. Done i Back **i dalje** rade **bez** otvaranja ovog overlaya — igrač može otići prije stucka — ali **također** zovu hide (L21) da leftover popup nikad ne ostane `visible` u pozadini.

## Hub persist — zašto se popup vraća

[`meta_hub_controller.gd`](../../game/scripts/meta/meta_hub_controller.gd) instancira Arena page jednom (`_arena_page`). Swipe/tab na Camp **ne** `queue_free` arenu. `set_arena_page_active(false)` samo gasi `process_mode` i refresh bag na return.

Danas (`LEFTOVER-B`):

| Korak | Stanje overlaya |
|-------|-----------------|
| Bag tap, stuck | `visible = true` |
| Tap overlay → `_on_done_pressed` | polje prazno, Camp, **overlay i dalje true** |
| Igrač u kampu | Arena page živi, dim+panel i dalje true (nije na ekranu jer tab nije Arena) |
| Tab natrag na Arena | `set_arena_page_active(true)` — **ne** hide; igrač vidi leftover popup na praznom polju |

To krši očekivanje „nakon što odem u kamp, ekran u areni treba biti isti ko prije“: prije stuck overlaya Arena je **playfield + vreća + Done**, bez dim veila. Nakon Camp-a mora biti to, ne zamrznuti popup.

**„Isti ko prije“ (L23) znači:**

| Što | Stanje nakon Camp, kad se vrati Arena |
|-----|----------------------------------------|
| Overlay | `visible = false`, lista prazna |
| Playfield | 0 chipova (Done već `_clear_field_chips`) |
| Combo / pair pulse / Pip bounce | reset (`_reset_session_feel`, `_clear_combo`) |
| Muncher | nest |
| Hub nav | otključan |
| Torba | **remainder T1 ostaje** (clover 3, daisy 2, …). Nije wipe savea. Nije nova partija. |
| Hint / bag chrome | `_refresh_bag` na `set_arena_page_active(true)` — vreća opet klikabilna; stuck tap opet otvara overlay |

Nije: nova Godot sesija. Nije: grant D na tab return (to bi obrisalo loot iz runa u **istom** playu).

## Remen: hide na page-inactive (L22)

Ako Done zaboravi hide (regressija), `set_arena_page_active(false)` zove isti `_hide_need_more_overlay()`. Overlay tap, Done gumb, Back gumb, i odlazak s Arena taba swipeom — svi ostavljaju overlay ugašen.

`set_arena_page_active(true)` **ne** otvara overlay. Overlay samo bag tap (L15).

`refresh_for_meta_hub` ne treba otvarati overlay; smije ostati hide-only ako je netko ostavio visible.

## Kad se overlay **ne** otvara

- Pour uspio (pulled > 0).
- Bag prazan → postojeći empty copy.
- Arena full → postojeći full copy.
- Auto-refill pull 0 → **ne** forsirati overlay svaki frame. Samo **igračev tap** vreće (L15 / L25).

C **ne** mijenja ova pravila. C mijenja samo **kako se gasi** i **kako se čita naslov**.

## Što overlay nije

- Nije fail / game over.
- Nije dnevni cap poruka.
- Nije daily claim.
- Nije zamjena za Done (Done ne mora otvoriti overlay).
- Nije persist (`SAVE_VERSION` ne raste — L13 ostaje).
- Nije shop / IAP / ad.

## Smokes (LEFTOVER-B) — ostaju

1. Bag `{clover: 3, daisy: 2, tulip: 1}`, polje 0, simulirani bag tap: 0 chipova spawnano, overlay vidljiv, naslov sadrži `You need more seeds`.
2. Lista ima 3 reda; clover label sadrži `3/4`.
3. Wallet nepromijenjen.
4. `has_method("_on_done_pressed")` ostaje.
5. Ne otvarati overlay iz auto-refill.

## Smokes (LEFTOVER-C) — `arena_leftover_c_smoke` ✅

1. Overlay `visible = true` → `_on_done_pressed` **ili** overlay `gui_input` → overlay `visible == false`; lista bez djece.
2. Nakon toga `set_arena_page_active(true)` (simulirani povratak taba): overlay i dalje false; `_chips` prazan.
3. `set_arena_page_active(false)` dok je overlay true → overlay false (remen).
4. Naslov i dalje string `You need more seeds!`; theme `font_color` **nije** `UI_TEXT` `#4A4A4A` (svijetla).
5. Pour / refill 12 / leftover-A math netaknuti (ne dirati u C).

Headless: `arena_leftover_c_smoke` + `arena_leftover_b_smoke`. SceneRouter deferred `change_to` — ne čekati meta hub; assertirati overlay flag + hide helper.

## Povezano

- [[ideje-arena-leftover-math|n/4]] · [[ideje-arena-leftover-pour|stuck definicija]] · [[ideje-arena-leftover-grant|debug 100]]  
- [[ideje-arena-leftover-field|field]] — E **nije** overlay  
- [[ideje-arena-leftover-pitanja|L4 L6 L8 L9 L21–L25]]
