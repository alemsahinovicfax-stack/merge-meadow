---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, roster, unlock, sezone, scratch]
povezano:
  - ideje-home-incard-roster
  - ideje-home-incard-gate
  - ideje-home-incard-pitanja
  - plan-prompts-home-incard
  - ideje-home-unlock
  - CHECKPOINT
ai_sažetak: "HOME-08 hub — roster i Unlock gate u hero-centar prozoru sezone; veći tip; paid+free; Lantern locked s progresom na kartici."
---

# IDEJE — Home in-card roster + Unlock (HOME-08 hub)

> **ID:** **HOME-08** · v1.1+ (nije v1 launch blocker).  
> **Kod:** **INCARD-A–B ✅**. Prompti: [[../06-production/plan-prompts-home-incard|plan-prompts-home-incard]].  
> **Chrome korekcija:** [[ideje-home-cardfit|HOME-09]] CARDFIT ✅; dalje [[ideje-home-lockflow|HOME-10]] — roster clip, locked poster 500/20 gold.  
> **Prethodnik:** [[ideje-home-unlock|HOME-07]] UNLOCK-A–C ✅ — **krivo shvaćen layout** (Stage overlay umjesto prozora sezone).  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — paid roster je kozmetički pregled; coin Unlock samo na **prvoj zaključanoj free** sezoni.

## Pitch

HOME-07 je uradio pravu **logiku** i krivi **prostor**. Igrač ne gleda „donji lijevi kut Home Stagea“. Igrač gleda **prozor sezone** — veliku karticu u sredini hero trake (~80% visine). Sve što sezona nudi (cvijeće) i sve što treba da je otključaš (coins, sjemena, Unlock) mora živjeti **unutar tog panela**, kao da je printano na posteru te sezone.

Tri playtest prigovora, jedan uzrok:

1. **Cvijeće nije u prozoru.** `SeasonRoster` je sibling Stagea, anchored na cijeli SeasonStage. Kad gledaš Country Bloom karticu, lista cvjetova visi lijevo-dolje na Stageu — vizualno „pored“ sezone, ne **u** njoj. Treba: donji lijevi kut **tog** `CenterSlot` / `PaidCenterSlot`.
2. **Ništa se ne vidi.** Ikona 28px, ime font 13, red 28px. Na telefonu (i na 540×960 desktop windowu) to je prašina. Treba veći crtež i veći tekst, čitljiv s ruke.
3. **Lock UI nije na zaključanoj sezoni.** Unlock gate je Stage overlay desno-dolje. Lantern Meadow **jest** debug-skip (P84) — nije playable — ali igrač to ne vidi kao „Lantern je zaključan“ jer progress i Unlock nisu **na Lantern prozoru**. Prva zaključana free sezona mora nositi svoje trake i gumb.

Paid i free **isti** roster-u-prozoru. Paid **nema** coin Unlock (P54, P89).

## Zašto sada

HOME-07 UNLOCK-C je zatvoren u kodu, ali playtest kaže: krivo mjesto, premalo, lock ne izgleda kao lock. Korekcija je **isti Home Stage i isti katalog 48 stubova**, ne novi feature-set. Ako agent ostavi overlay i samo poveća font, i dalje nije „u prozoru sezone“.

Kod mora ostati razdvojen: **A roster u kartici**, **B gate u kartici**.

## Što HOME-07 **jest** vs što HOME-08 **overridea**

| HOME-07 (ostaje) | HOME-08 |
|------------------|---------|
| P81 swipe dolje = select | Ostaje |
| P82 swipe gore = bounce; band = tap | Ostaje |
| P83 next-lock selectable; further bounce | Ostaje |
| P84 debug skip lantern; `can_unlock_free` da; Amber/Ember TEST_LOCK | Ostaje; **vizual** locka ide u Lantern prozor (P99) |
| P85 inline gate, ne sheet za next-lock | Ostaje logika; **parent** se mijenja: child slota, ne Stage |
| P86 coins + T3 flower count („sjemena“) | Ostaje (P98) |
| P87–P88 48 stubova; T3 art + ★ + ime | Ostaje; **veličina i parent** override (P92, P94) |
| P89 paid swipe + roster, nema coin Unlock | Ostaje; roster sada u paid **hero** prozoru (P95) |
| P90 tamni okvir | Ostaje, veći |
| P91 `seed_type_ids` ne dirati | Ostaje (P102) |
| Layout: Stage overlay 232×188, font 13 | **Override P92–P96:** child hero-centar slota, veći tip |

Puna tablica: [[ideje-home-incard-pitanja|pitanja]] P92–P102. P1–P91 ostaju osim layout overridea gore.

## Simptom vs cilj

| Danas (nakon HOME-07) | Cilj |
|-----------------------|------|
| Roster visi na Stageu, lijevo-dolje | Roster **unutar** hero-centar kartice, donji lijevi kut |
| Font 13 / ikona 28 — ne čita se | Ikona ~52px, ime ~22, zvijezde ~18, red ~56px |
| Unlock gate visi na Stageu, desno-dolje | Gate **unutar istog** next-lock prozora, donji desni kut |
| Lantern se može fokusirati, ali lock UI nije na njoj | Lantern centar = 🔒 + roster + coins/Seeds trake + sivi Unlock |
| Paid Coral: roster na Stage overlayu | Coral **u** `PaidCenterSlot` kad je paid-hero |
| L/R uske kartice i 20% preview | **Bez** rostera/gatea (P93) |

## Što HOME-08 **jest**

- Premjestiti roster iz Stage overlaya u **hero-centar slot** (free `CenterSlot` ili paid `PaidCenterSlot`).
- Isti 48-stub katalog, veći crtež i tekst, tamni okvir, HIT-A `IGNORE`.
- Premjestiti Unlock gate u **isti** free hero-centar panel, dolje-desno, samo za next-lock (Lantern).
- Unlock sivo / neklikabilno dok `not can_unlock_free`; primary + klikabilno kad ima coins + T3.
- Paid hero: roster da, gate ne.

Detalj: [[ideje-home-incard-roster|roster]] · [[ideje-home-incard-gate|gate]].

## Što HOME-08 **nije**

- Ponovno otvaranje P81–P91 geste (select, bounce, next-lock cycle).
- Roster na L/R side karticama ili na preview 20% traci.
- Coin Unlock na paid / Ember / Amber TEST_LOCK.
- Novi cvjetovi, novi `seed_type_ids`, SAVE_VERSION, AdMob, Shop Select, inline IAP, hub pager.
- Mijenjanje band 20/80 ili L/R in-place pretapanja.
- Follow-finger, wrap.

## Agent

- Kad korisnik dira „cvijeće nije u prozoru“, „premalo se vidi“, „Unlock treba na Lantern kartici“ → **HOME-08**.
- Ne vraćati Stage overlay. Ne stavljati roster na uske L/R slotove.
- Ne grantati lantern kroz `debug_unlock_all` (P84 ostaje).

## Povezano

- [[ideje-home-unlock|HOME-07]] · [[ideje-home-cardfit|HOME-09]] · [[ideje-home-focus|HOME-06]] · [[ideje-home-paid|HOME-04]]
- [[../06-production/CHECKPOINT|CHECKPOINT]] · [[../06-production/plan-prompts-home-incard|prompti]]
