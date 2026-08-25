---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, pitanja, hit-targets, scratch]
povezano:
  - ideje-home-hit-targets
  - ideje-home-hit-targets-gesta
  - ideje-home-hit-targets-tehnika
  - ideje-home-polish-pitanja
  - plan-prompts-home-hit-targets
ai_sažetak: "HOME-02 pitanja — P28 freeze hit-through; P29–P35 defaulti za HIT-A."
---

# IDEJE — HOME-02 pitanja

> [[ideje-home-hit-targets|HOME-02 hub]]. SEZ P1–P15 i HOME **P16–P27** **ostaju**. Ovdje samo input/hit.

## Kako koristiti

1. Pregledaj P28–P35. Javi override **prije** HIT-A koda.
2. Implementacija: prompt **HIT-A** u [[../06-production/plan-prompts-home-hit-targets|plan-prompts-home-hit-targets]].
3. Ne re-otvaraj P16 (paid na traci) ni P19 semantiku — HOME-02 je **dostava** P19 na karticu.

---

## P28 — Hit-through kartica (freeze)

**Pitanje:** Smiju li `PanelContainer` kartice gutati `gui_input`, ili cijela traka (uključujući panele) ide u Stage handler?

**Kontekst:** Playtest 2026-08-19: swipe/tap rade skoro samo u prazninama. `_handle_tap` već postoji.

**Odgovor (2026-08-19, HOME-02):** **Hit-through.** Kartice **nisu** barijera. `mouse_filter` IGNORE na vizualnom `Row` stablu. Stage STOP. Ovo je **freeze** za HIT-A.

---

## P29 — Tap u praznini trake (gap / pad)

**Pitanje:** Tap koji nije u L/C/R rectu, ali jest na Stageu?

**Default:** **Browser** (postojeći `else: open_browser()`). Igrač je tapnuo „traku“, ne Play.

**HOME-03 override (P41 freeze):** gap/pad = **no-op**. Browser samo srednja kartica (P40). Vidi [[ideje-home-chrome-pitanja|HOME-03 pitanja]].

Override: no-op. Ne preporučeno — izgleda kao mrtav klik između kartica.

---

## P30 — Prag tap vs swipe

**Pitanje:** Mijenjati `SWIPE_LOCK_PX` (20)?

**Default:** **Ne.** 20 px ostaje. Playtest smije kasnije 16–28 bez novog ID-a ako je jedan literal.

---

## P31 — Tap locked desno

**Pitanje:** Browser (cijeli katalog) ili Unlock sheet (P11)?

**Default:** **Unlock sheet** — usklađeno s P11 i P19. Browser ostaje tap na **centar** (i gap P29).

---

## P32 — Overlay vs traka

**Pitanje:** Kad je Browser ili sheet otvoren, smije li swipe ispod mijenjati strip?

**Default:** **Ne.** Overlay STOP. `_ignore_hits` **samo** na `Row`, nikad na Browser/sheet.

---

## P33 — Swipe počeo na locked desnoj kartici

**Pitanje:** Swipe +1 preko katanaca = sheet ili bounce?

**Default:** **Swipe** = cycle ako unlocked, inače **bounce**. **Tap** = sheet. Ne otvarati sheet na drag.

---

## P34 — Što je „lista sezona“ na tap centra

**Pitanje:** Novi inline dropdown na Homeu, ili postojeći Season Browser overlay (free + paid dolje)?

**Default:** **Postojeći Browser.** Nije novi UI. Paid ostaju **dolje u Browseru**, ne na Home slotovima (P16).

---

## P35 — Tap otključanog boka

**Pitanje:** No-op, Browser, ili odmah ta sezona trenutna?

**Default:** **Odmah fokus + `set_active`** (P19). To čini hub fluidnim: tap S1 lijevo = S1 centar, bez drugog ekrana.

Override: bokovi samo swipe, tap bok = no-op. **Odbaci** za HIT-A — playtest je eksplicitno tražio klik na pored → trenutna.

---

## Sažetak defaulta

| # | Default | Freeze? |
|---|---------|---------|
| P28 | Hit-through cijele trake | **Da** (chat 2026-08-19) |
| P29 | Gap tap = Browser | Preporuka |
| P30 | Prag 20 px | Preporuka |
| P31 | Locked R tap = sheet | Preporuka (= P11) |
| P32 | Overlay hvata; ignore samo Row | Preporuka |
| P33 | Drag na lock = bounce/cycle, ne sheet | Preporuka |
| P34 | Centar = postojeći Browser | Preporuka |
| P35 | Tap bok unlocked = select | Preporuka |

---

## Pitanja koja **ne** otvaramo ovdje

- Unique S2 seedovi, Play Console SKU, IAP cijena.
- Wrap (P20 već ne).
- Centar = Play (P19 override odbijen).
- Fling kroz više sezona.
- Final art / photo thumbnail.
- Hub carousel broj stranica (UX-04).

Ako treba: novi ID, ne nabijati u HIT-A.

## Povezano

- [[ideje-home-polish-pitanja|HOME-01 P16–P27]]
- [[../06-production/plan-prompts-home-hit-targets|HIT prompti]]
