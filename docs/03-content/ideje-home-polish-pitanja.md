---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, pitanja, polish, scratch]
povezano:
  - ideje-home-polish
  - ideje-home-polish-layout
  - ideje-home-polish-carousel
  - ideje-sezone-pitanja
  - plan-prompts-home-polish
ai_sažetak: "HOME-01 pitanja — P16–P17 freeze 2026-08-19; P18–P27 defaulti za kod."
---

# IDEJE — Home polish: pitanja

> [[ideje-home-polish|HOME-01]]. **P16–P17** odgovoreno u chatu 2026-08-19. Ostalo ima **preporučeni default** da HOME-A/B mogu krenuti bez blokade.

## Kako koristiti

1. Pregledaj P16–P27. Javi override prije HOME-A/B koda.
2. Implementacija: prompti **P0 → A → B → C** u [[../06-production/plan-prompts-home-polish|plan-prompts-home-polish]].
3. SEZ freeze P1–P15 **ostaje**; HOME dodaje P16+ (Home UX), ne dira coins/T3.

---

## P16 — Paid na Home swipe traci

**Pitanje:** Swipe polje na Homeu uključuje li owned paid sezone (kao SEZ-C `list_playable_season_ids`), ili samo free lanac?

**Kontekst:** P5 dozvoljava paid prije S2. P12 auto-switcha `active` na paid kupnju. SEZ-C Stage swipe zato miješa paid u isti ciklus.

**Odgovor (2026-08-19):** **Samo free lanac.** Paid **nikad** nije kartica na Home traci. Paid se bira u Browseru / Shopu. `active_season_id` i dalje može biti paid; Play koristi `active`. Centar trake pokazuje **zadnji free fokus**, ne paid art. Swipe/tap na free karticu **postavlja** `active` na tu free sezonu (prepisuje paid).

Detalj save/fokus: vidi [[ideje-home-polish-carousel|carousel]] (`strip_focus_id` preporuka).

---

## P17 — Što je „veliki prozor“ koji se ukida

**Pitanje:** Ukinuti centrirani `Panel` oko cijelog Home sadržaja, ili samo veliku Season ActiveCard unutar Panela?

**Odgovor (2026-08-19):** Ukinuti **cijeli centrirani Panel** (okvir oko naslova + Stage + Play). Home postaje **otvoren layout**: chest/basket gore, swipe polje u sredini, Play dolje. Nema dijalog-prozora.

Vidi [[ideje-home-polish-layout|layout]].

---

## P18 — Pip, naslov, tagline bez Panela

**Pitanje:** Kad nema okvira, gdje ostaju „Merge Meadow“, Pip portret i tagline?

| Opcija | |
|--------|--|
| A | Compact header iznad trake (manji Pip + manji title) |
| B | Samo Pip, bez wordmarka |
| C | Wordmark u hub chrome / Settings red |
| D | Sakriti sve osim trake + Play |

**Default (preporuka, nije freeze chata):** **A**. TutorialHint samo dok tutorial traje.

---

## P19 — Tap na slotove

**Pitanje:** Što radi tap (ne swipe) na centar / lijevo / desno?

**Default:**

| Slot | Tap |
|------|-----|
| Centar | Season Browser (kao SEZ-C tap ActiveCard) |
| Lijevo (unlocked prev) | Odmah fokus + `set_active` na tu free |
| Desno locked | Unlock sheet (P11) |
| Desno unlocked | Fokus + `set_active` na tu free |

Override: centar = Play? Ne preporučeno (Play gumb već postoji).

---

## P20 — Wrap na krajevima lanca

**Pitanje:** Swipe sa S1 „ulijevo“ ili sa S3 „udesno“ skače na drugi kraj?

**Default:** **Ne.** Bounce / no-op. Linear priča (S1→S2→S3) mora ostati čitljiva.

---

## P21 — Badge kad je active paid, a strip free

**Pitanje:** Kako igrač vidi da Play **nije** vizual centra?

**Default:** Da — mali EN label uz Play (`Theme: Moonlit Warren`) **samo** kad `active_season_id != strip_focus_id`. Nije paywall, nije loot hint.

---

## P22 — Omjer veličina i peek

**Pitanje:** Koliko je centar veći, koliko side viri?

**Default:** Centar **~1.35×** linearne mjere side kartice. Side ~70–85% vlastite širine vidljivo (clip). Locked desno i dalje čitljiv naslov + lock. Brojevi su draft za HOME-B; playtest smije ±10%.

---

## P23 — Animacija vs instant snap

**Pitanje:** Instant cut (SEZ-C) ili tween?

**Default:** Tween **~180ms** ease-out. Locked-direction swipe = kratki bounce, bez promjene fokusa. Smoke smije `await` ~0.3s.

---

## P24 — Endless gumb

**Pitanje:** Endless u traci, pored Play, ili ispod?

**Default:** **Ispod Play**, van swipe polja. Ne dirati D2 endless pravila.

---

## P25 — Tutorial vs nova traka

**Pitanje:** Prvi boot / tutorial overlay smije li blokirati traku?

**Default:** Dok `tutorial_complete == false`, ponašanje kao danas (hint tekst). Ne uvoditi novi season tutorial u HOME-A/B. Traka smije biti vidljiva, ali nije tutorial korak.

---

## P26 — Ime u UI (centar)

**Pitanje:** Display name na thumbeu ili samo art?

**Default:** Ime **na** centru (EN). Side: ime skraćeno / manji font; locked smije samo ime + lock.

---

## P27 — Dublji free lanac (S4+)

**Pitanje:** Ako ikad bude >3 free, ostaje li 3-slot prozor?

**Default:** **Da.** Isti algoritam `focus_index ± 1`. Nema 5 kartica odjednom na Homeu. Katalog i dalje Browser.

---

## Pitanja za kasnije (ne blokiraju HOME-A)

Ovo su stvari koje me zanimaju kad budeš radio art / playtest — nisu dio P0 freeze:

1. **Thumbnail art:** Photo vs flat illustration vs tint ColorRect (sada mood color)? HOME-B smije ostati ColorRect + ime.
2. **Parallax:** Side kartice malo rotirane u 3D? Default **ne** (2D scale+position).
3. **Haptics** na snap (Android)? Default ne u A/B.
4. **Accessibility:** Je li lock + sivilo dovoljno bez ikone katanac? Default **oba**.
5. **Deep-link iz Shopa** „Select theme“ za paid: vraća na Home s mismatch badge, ne pomiče strip — OK?
6. **Swipe brzina:** fling vs jedan slot po gesti? Default **jedan slot** po uspješnom swipeu (kao hub pager).
7. **Dugi press** na centar? Default nema.
8. **Seed peek** na centru: zadržati 2–3 ID-a kao tekst ili maknuti da kartica bude čistiji poster? Default **maknuti dugi tagline/seed string** s HOME-B kartice; ime + mood boja dovoljni dok nema arta.
9. **Clear rabbit** ColorRect na Stageu: maknuti s trake (P7 kozmetika ostaje u Browseru/clear flow kasnije)? Default **maknuti** s 3-slot kartica.
10. **Localization later:** P14 EN ostaje; layout mora podnijeti duža imena (autowrap 2 linije max na centru).
11. **Kad su sve free unlocked i igrač je na S3:** treba li desno „coming soon“ slot? Default **ne**, prazno.
12. **Reduce motion** postavka: skip tween? Nema Settings flag još — instant fallback ako `Engine.time_scale` nije tema.

---

## Sažetak freeze HOME

| # | Odluka |
|---|--------|
| **P16** | Home traka = **samo free**; paid preko Browser/Shop; Play = `active` |
| **P17** | Ukinuti **cijeli** Home `Panel` okvir |
| P18 | Default compact header iznad trake |
| P19 | Default: centar=Browser; L/R unlocked=select; R locked=sheet |
| P20 | Default **bez wrapa** |
| P21 | Default Play badge kad paid ≠ strip |
| P22 | Default centar ~1.35×, side peek |
| P23 | Default ~180ms snap + bounce |
| P24 | Endless ispod Play |
| P25 | Nema novog season tutoriala |
| P26 | Ime na centru |
| P27 | Uvijek 3-slot prozor |

P18–P27 nisu chat-freeze; override prije koda je jeftin.

## Povezano

- [[ideje-home-polish|hub]] · [[ideje-home-polish-layout|layout]] · [[ideje-home-polish-carousel|carousel]]
- [[ideje-sezone-pitanja|SEZ P1–P15]]
- [[../06-production/plan-prompts-home-polish|prompti]]
