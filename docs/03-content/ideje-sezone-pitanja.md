---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, sezone, pitanja, scratch]
povezano:
  - ideje-sezone
  - ideje-sezone-ux-home
  - ideje-sezone-ekonomija
  - ideje-sezone-content
  - ideje-sezone-data-model
  - plan-prompts-sez-01
ai_sažetak: "SEZ-01 pitanja — P1–P15 odgovoreno (freeze + 2026-08-19)."
---

# IDEJE — Sezone: otvorena pitanja

> **P1–P15** upisani (freeze + odgovori 2026-08-19). Override prije SEZ-B ako treba.

## Kako koristiti

1. Pregledaj P1–P15 — javi override ako treba.
2. Implementacija: Plan mode prompti **P0 → B → C → D → E** iz [[../06-production/plan-prompts-sez-01|plan-prompts-sez-01]].

---

## P1 — Milestone / timing

**Pitanje:** Samo v1.1+ nakon launcha, ili thin slice još u prelaunchu / M8?

| Opcija | |
|--------|--|
| A | Strogo v1.1+ nakon store launcha |
| B | Thin slice Home Stage bez paid |
| C | **v1.1 feature radimo sada** (ne čekaj store) |

**Odgovor (freeze 2026-08-19):** **C** — radimo sada kao v1.1 feature.

---

## P2 — Seed catalog

**Pitanje:** Nove vrste po sezoni ili reskin/rename postojećih 7 tipova?

| Opcija | |
|--------|--|
| A | Reskin istih ID-eva |
| B | Novi `type_id` po sezoni |
| C | **Hibrid:** S1 = postojeći set; S2+ = novi |

**Odgovor (freeze 2026-08-19):** **C**.

---

## P3 — T3 flower gate

**Pitanje:** Koliko T3 flowera za free S2? Check-only ili spend?

**Odgovor (freeze 2026-08-19):** Count **5**; Mode **check-only** (ne troši `garden_crystal_stash`).

---

## P4 — Coin cost free S2+

**Pitanje:** Fiksni trošak ili raste po `order`?

**Odgovor (freeze 2026-08-19):** **B** — raste: S2=`80`, S3=`150`.

---

## P5 — Paid vs free linear

**Pitanje:** Smije li paid prije free S2?

**Odgovor (freeze 2026-08-19):** **A** — da, paid paralelan.

---

## P6 — Donji paid UI u Browseru

**Odgovor (freeze 2026-08-19):** **A** — horizontal scroll cards.

---

## P7 — Clear rabbit

**Odgovor (freeze 2026-08-19):** **A** — samo Journal / gallery kozmetika (ne Pip swap u prvoj rundi).

---

## P8 — Journal / Album

**Odgovor (freeze 2026-08-19):** **A** — globalni album.

---

## P9 — Volumen prvog dropa

**Odgovor (freeze 2026-08-19):** **A** — 3 free + 2 paid (S1 playable; S2–S3 + paid stub data).

---

## P10 — Leveli / endless

**Odgovor (freeze 2026-08-19):** **A** — shared levels + season spawn/BG only.

---

## Dodatna pitanja

### P11 — Next-free teaser tap

**Pojmovi:**
- **Season Browser** = veliki popup katalog (gore free sezone u redu, dolje paid). Otvara se tapom na središnji Stage.
- **Unlock sheet** = manji panel/overlay samo za **jednu** zaključanu free sezonu: „treba X coins + Y T3 flowers“, progress, gumb Unlock.

Što radi tap na desni locked teaser?

**Odgovor (2026-08-19):** **samo Unlock sheet** za tu next-free sezonu (ne Browser).

### P12 — Auto-switch active on unlock / purchase

**Odgovor (2026-08-19):** **Da** — odmah `active_season_id` na novu sezonu. Isto za **paid** nakon kupnje/own.

### P13 — Diamonds

**Odgovor (2026-08-19):** **Ne** — diamonds ne kupuju free season unlock.

### P14 — Lokalizacija imena

**Odgovor (2026-08-19):** Ostaje **EN** u UI-u (npr. Country Bloom).

### P15 — Enemy gameplay

**Odgovor (2026-08-19):** Trenutno **samo art reskin** prepreka/neprijatelja; nema novih behavioura po sezoni.

---

## Defaulti (sažetak freeze)

Vidi [[../06-production/plan-prompts-sez-01|plan-prompts-sez-01]] tablicu freeze + [[ideje-sezone|hub]].

## Povezano

- [[ideje-sezone|hub]] · [[ideje-sezone-ux-home|UX]] · [[ideje-sezone-ekonomija|ekonomija]] · [[ideje-sezone-content|content]] · [[ideje-sezone-data-model|data model]]
- [[../06-production/plan-prompts-sez-01|plan-prompts-sez-01]]
