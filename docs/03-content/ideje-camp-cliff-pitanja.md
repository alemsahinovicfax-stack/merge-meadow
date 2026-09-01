---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, kamp, pitanja, chrome, cliff, scratch]
povezano:
  - ideje-camp-cliff
  - ideje-camp-pitanja
  - plan-prompts-camp-cliff
ai_sažetak: "CAMP-02 pitanje C21 — GardenCliff uvijek hidden + prazan; override C7 za taj slot."
---

# IDEJE — CAMP-02 pitanja (C21)

> [[ideje-camp-cliff|hub]]. Freeze **2026-09-01**.  
> CAMP-01 **C1–C20** ostaju osim **C7 za GardenCliff slot**. C2/C20 (nema journal / T2 stringova) i dalje vrijede — prazan label ih automatski zadovoljava.

C1 (toast), C3 (CrystalCliff hidden), C4–C6 (naslovi / RunPrep), C8–C14 (Flowers spend), C15–C20 (companion, milestone, arena/home ruke dalje) **ne dirati**.

| # | Pitanje | Odluka |
|---|---------|--------|
| **C21** | Tekst između Seeds i `Seeds: n / cap`? | **Ništa.** `%GardenCliff` ostaje UniqueName. Uvijek `visible = false` i `text = ""`. `_garden_cliff_text` vraća `""`. Tutorial merge, bag T1, flowers ready, fallback **nestaju iz tog mjesta** — ne premještati. Override CAMP-01 **C7** samo za ovaj slot. |

## Zašto C21

C7 je držao hintove da A ne ostavi prazan label (smoke je tražio node, ne sadržaj). Playtest: rupa je šum. BagLabel već kaže broj; Exchange i Merge uče rest. CrystalCliff je već isti pattern (C3).

## Otvoreno (ne blokira CAMP2-A)

Agent **ne** mora pitati. Preporuka: ostavi node u tscn (kao StatusToast / CrystalCliff), samo hide + prazan text. Manji diff od brisanja UniqueName.

## Nije otvoreno

- Novi hint u hub baru ili toastu.
- Dirati Flowers / Upgrade / Home.
- Vratiti „Bag seeds are“ kao tooltip.
- SAVE_VERSION.

## Override mapa

| Staro | Novo |
|-------|------|
| C7 ostali GardenCliff stringovi ostaju | C21 slot uvijek prazan/hidden |

## Povezano

- [[ideje-camp-pitanja|C1–C20]] · [[../06-production/plan-prompts-camp-cliff|prompti]]
