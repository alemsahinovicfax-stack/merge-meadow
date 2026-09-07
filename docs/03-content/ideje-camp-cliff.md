---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, kamp, ux, chrome, cliff, scratch]
povezano:
  - ideje-camp-cliff-pitanja
  - ideje-camp
  - ideje-camp-chrome
  - plan-prompts-camp-cliff
  - CHECKPOINT
ai_sažetak: "CAMP-02 hub — C21 freeze ostaje; CAMP2-A kod superseded od CAMP-03 A (GardenCliff + BagLabel)."
---

# IDEJE — CAMP-02 Seeds cliff (prazna rupa)

> **ID:** **CAMP-02** · v1.1+ (nije v1 launch blocker, nije D0-P art).  
> **Kod:** **ne pasteati CAMP2-A.** Docs **CAMP2-P0 ✅**. C21 kod upija [[ideje-camp-link|CAMP-03]] **CAMP3-A** (C22–C23: cliff **i** Broj `Seeds: n/cap`). Prompti: [[../06-production/plan-prompts-camp-cliff|plan-prompts-camp-cliff]] **CAMP2-P0 ✅ · A superseded**.  
> **Nastavak:** [[ideje-camp-link|CAMP-03]] · [[../06-production/plan-prompts-home-camp-field|playlist]].  
> **Prethodnik:** [[ideje-camp|CAMP-01]] A ✅ B ✅ — toast van, Seeds/Flowers, Upgrade iz Flowers. C7 je ostavio GardenCliff hintove (bag T1, tutorial, fallback). Playtest: ta rupa i dalje smeta.  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — nema IAP; samo copy.

## Pitch

Kartica Seeds treba izgledati kao **naslov + broj + grid**. Između `GardenTitle` („Seeds“) i `BagLabel` (`Seeds: n / 40`) danas sjedi `%GardenCliff` — 18 px autowrap. Kad imaš sjeme u torbi, string je:

```
Bag seeds are T1 — pour in Arena or trade 3→coins. T2 blooms resolve in Arena.
```

Igrač to već zna (Arena pour, Trade gumb ispod). Rupa gura grid dolje. CAMP-02 **briše cijeli taj slot vizualno**: ništa između naslova i broja. Node ostaje zbog UniqueName / smoke.

## Dijagnoza

U [`camp_scene.tscn`](../../game/scenes/camp/camp_scene.tscn) `GardenVBox`:

```
GardenTitle     "Seeds"
GardenCliff     ← C7 hintovi (tutorial / bag T1 / flowers / fallback)
BagLabel        "Seeds: n / cap"
SeedBagScroll
ExchangeButton
```

[`camp_controller.gd`](../../game/scripts/camp/camp_controller.gd) `_refresh_garden_card` uvijek seta `garden_cliff.text = _garden_cliff_text(...)`. `_garden_cliff_text` ima grane: tutorial merge, bag > 0 (Bag seeds are…), crystals > 0, fallback `Run → collect seeds → Merge here.`

CAMP-01 **C2/C20** su skinuli Journal i T2 Sprinkler grane. **C7** je namjerno ostavio ostalo da A ne ostavi prazan label. Playtest sada kaže: **prazan slot je cilj**.

CrystalCliff je već `visible = false` (C3). Isti pattern za GardenCliff.

## Simptom vs cilj

| Danas (CAMP-01) | Cilj |
|-----------------|------|
| Tekst između Seeds i `Seeds: n` | Ništa — VBox collapsa |
| `"Bag seeds are T1…"` | Nestaje |
| Tutorial / flowers / fallback u istom labelu | Nestaju iz tog mjesta; **ne** premještati u drugi node |

## Što CAMP-02 **jest**

- `%GardenCliff` UniqueName **ostaje**.
- Uvijek `visible = false` i `text = ""`.
- `_garden_cliff_text` vraća `""` (ili se više ne zove za UI).
- Tscn default prazan.
- `camp_layout_smoke`: node postoji; hidden ili prazan; **nema** `"Bag seeds are"`.

Detalj: [[ideje-camp-cliff-pitanja|C21]].

## Što CAMP-02 **nije**

- Flowers kartica, Upgrade, Exchange, footer Merge/Play.
- Home sezone / meadow (to je [[ideje-home-meadow|HOME-12]]).
- Vraćanje cliff hintova u hub top bar ili StatusToast (toast je mrtav, C1).
- Arena leftover/sort. SAVE_VERSION.

## Agent

- Kad korisnik dira „Bag seeds are“, „tekst ispod Seeds“, „rupa između naslova i broja“ → **CAMP-03 A** (ne CAMP2-A).
- Ne dirati CAMP-01 spend API.
- Ne spajati s HOME-12 kodom. Ne pasteati CAMP2-A.

## Povezano

- [[ideje-camp|CAMP-01 hub]] · [[ideje-camp-link|CAMP-03]] · [[ideje-camp-chrome|chrome]] · [[ideje-camp-cliff-pitanja|C21]]
- [[../06-production/plan-prompts-camp-cliff|prompti]] · [[../06-production/plan-prompts-home-camp-field|CAMP-03 playlist]] · [[../06-production/CHECKPOINT|CHECKPOINT]]
