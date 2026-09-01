---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, kamp, ux, upgrade, donate, scratch]
povezano:
  - ideje-camp-pitanja
  - ideje-camp-chrome
  - ideje-camp-donate
  - ideje-camp-grupe
  - ideje-camp-cliff
  - plan-prompts-camp
  - plan-prompts-camp-cliff
  - ideje-arena
  - ekonomija-brojevi
  - ideje-kad-predloziti
  - CHECKPOINT
ai_sažetak: "CAMP-01 hub — manje tutorijala u kampu; Seeds/Flowers; bez companion pickera; Sprinkler i Loot Boost troše 2× T3 iz Flowers."
---

# IDEJE — Razvoj kampa (CAMP-01 hub)

> **ID:** **CAMP-01** · v1.1+ (nije v1 launch blocker, nije D0-P art).  
> **Kod:** **CAMP-A ✅ B ✅**. Prompti: [[../06-production/plan-prompts-camp|plan-prompts-camp]] **CAMP-P0 ✅ → A ✅ → B ✅**. Grupe: [[ideje-camp-grupe|grupe]].  
> **Nastavak:** [[ideje-camp-cliff|CAMP-02]] — GardenCliff rupa; prompti [[../06-production/plan-prompts-camp-cliff|plan-prompts-camp-cliff]] **CAMP2-P0 ✅ → A**.  
> **Freeze:** C1–C20 **2026-08-30** — [[ideje-camp-pitanja|pitanja]]. C21 (CAMP-02) overridea C7 za GardenCliff slot.  
> **Prethodnik:** ARENA-01 FLOW-A ✅ — arena više **ne** donira (leftover T2 → 2× T1; T3 → flower stash).  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — upgrade ostaje besplatan sink (cvijeće iz igre); nema IAP na Sprinkler / Loot Boost.

## Pitch

Kamp je **orijentacija + sink**, ne drugi merge. Playtest vidi tri greške odjednom:

1. **Tutorijalni šum.** Žuti `StatusToast` na vrhu scrolla ponavlja što si upravo tapnuo („Sprinkler upgraded!“). `GardenCliff` gura Journal. `CrystalCliff` i dalje kaže „Merge T3 in Arena → flowers here“ — igrač to već zna.
2. **Pogrešna imena.** Kartica s T1 torbom zove se Garden. Kartica s T3 stashom zove se Flower stash. Igrač misli na **Seeds** i **Flowers**.
3. **Companion picker** na dnu (`RunPrepCard`) ne treba u kampu. Pip i dalje trči u runu; izbor nije dio ovog loopa.
4. **Upgrade je mrtav.** Caption kaže „donate in Arena“. Arena to više ne radi. T2 stash u kampu ne postoji. Sprinkler Upgrade ostaje disabled zauvijek.

CAMP-01 **ne** vraća donate u arenu. **Ne** oživljava gredice. Čisti chrome (A), pa pretvara Upgrade u **spend 2 T3 iz Flowers** (B) i napiše caption koji kaže **šta upgrade radi**.

## Što Sprinkler i Loot Boost rade

Oboje su **run power**. Level se diže u kampu; efekat se vidi u **sljedećem** runu. Nisu kamp-dekoracija.

| Upgrade | Save | Efekat | Brojke |
|---------|------|--------|--------|
| **Sprinkler** | `magnet_level` 0–4 | Magnet u runu — širi usis sjemena | Domet `40 + level × 48` px (`get_magnet_radius()` → `player.set_magnet_radius`) |
| **Loot Boost** | `multiplier_level` 0–4 | Množitelj loota nakon runa | ×1.0 / ×1.25 / ×1.5 / ×1.75 / ×2.0 |

Legacy: na max Sprinkler `CAMP_BED_BONUS` (+3 gredice). Gredice nisu v1 UI. **Ne dirati** u ovom tracku.

## Dijagnoza — zašto je donate mrtav

ARENA-01 freeze **A11c**: spend samo Camp; nema bloom panela u areni. FLOW-A: leftover T2 → 2× T1 u bag; T3 ide u `garden_crystal_stash`. `arena_odd_t2_smoke` zabranjuje keep/donate na Done.

Kamp i dalje radi stari loop:

| Korak | Kod danas | Stvarnost |
|-------|-----------|-----------|
| Doniraj T2 u areni | `donate_bloom` / bed donate | Arena ne zove to |
| `sprinkler_donations` 0–2 | `_refresh_upgrade_cards` | Ostaje 0 |
| Upgrade kad `donations >= MAGNET_COST_T2` | `try_upgrade_magnet` | Gumb disabled |
| Caption | `"Donated %d/%d T2 — donate in Arena"` | Laž |

T2 nema inventar u kampu (nema gredica na ekranu, nema T2 stash kartice). Loot Boost traži T3 donate — T3 **postoji** u Flowers, ali gumb čeka `multiplier_donations`, koji se puni samo preko mrtvog donate API-ja.

**Odluka:** oba Upgrade gumba troše **2× T3 iz Flowers**. Atomic na tap. Exchange za coins ostaje. Nema T2 donate. Nema arena donate.

```
Lane run → loot u seed bag → Camp Seeds → Merge Arena
                                          ↓
                                   Camp Flowers (T3)
                                    /       |       \
                           Sprinkler   Loot Boost   Exchange coins
                              ↓            ↓
                         sljedeći run (magnet / ×loot)
```

## Simptom vs cilj

| Danas | Cilj |
|-------|------|
| Žuti toast na vrhu nakon akcije | Nema `StatusToast` |
| „New blooms in Journal…“ u GardenCliff | Ta grana **obrisana**; ostali Seeds hintovi ostaju |
| „Merge T3 in Arena…“ / „Tap a flower type…“ pod Flowers | `CrystalCliff` **cijeli** sklonjen |
| Garden / Flower stash | **Seeds** / **Flowers** (samo `text`, ne node ime) |
| Pip/Mochi picker u `RunPrepCard` | Kartica **uklonjena**; `GameState` companion ostaje |
| „donate in Arena“; Upgrade disabled | Spend 2 flowers; caption = magnet / ×loot |

## Što CAMP-01 **jest**

- **A (chrome):** toast, journal/T2 cliff grane, cijeli CrystalCliff, companion picker, rename naslova.
- **B (donate + copy):** Flowers plaćaju oba upgradea; captioni objašnjavaju efekat.

Detalj: [[ideje-camp-chrome|chrome]] · [[ideje-camp-donate|donate]].

## Što CAMP-01 **nije**

- Vraćanje bloom panela / `donate_bloom` u arenu.
- Novi T2 stash u kampu.
- Gredice, staklenik UI, `CAMP_BED_BONUS` rewrite.
- Companion picker u Settings (kasnije, nije ovaj track).
- Journal scene, Home sezone, Shop, AdMob, IAP na upgrade.
- D0-P art / SFX.
- Launch blocker.

## Agent

- Kad korisnik dira kamp toast, Garden/Seeds, Flower stash, companion picker, „donate in Arena“, Sprinkler / Loot Boost — **CAMP-01**.
- Kad korisnik dira „Bag seeds are“, tekst između Seeds i broja — **CAMP-02** ([[ideje-camp-cliff|cliff]]).
- Ne spajati A i B. A ne dira `MAGNET_COST` / `try_upgrade_*`.
- Ne oživljavati arena donate da „popraviš“ caption.
- Fair F2P: cvijeće iz mergea, ne shop.

## Povezano

- [[ideje-camp-pitanja|pitanja]] · [[ideje-camp-grupe|grupe]] · [[ideje-camp-cliff|CAMP-02 cliff]]
- [[../06-production/plan-prompts-camp|prompti]] · [[../06-production/plan-prompts-camp-cliff|CAMP-02 prompti]] · [[../06-production/CHECKPOINT|CHECKPOINT]]
- [[ideje-arena|ARENA-01]] A11c · [[../02-design/ekonomija-brojevi|ekonomija-brojevi]]
