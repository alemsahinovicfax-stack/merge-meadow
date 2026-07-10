---
type: produkcija
status: aktivan
milestone: M6
tags: [produkcija, milestone, checkpoint]
povezano:
  - CHECKPOINT
  - RADIONICA-razvoj
  - roadmap
ai_sažetak: "M0–M8 pregled i kriteriji; dnevni rad ide preko CHECKPOINT-a."
---

# Milestone-i

> **Dnevni rad:** koristi [[CHECKPOINT|CHECKPOINT]] — ovaj fajl je pregled i kriteriji.  
> **Detaljni koraci:** [[RADIONICA-razvoj|RADIONICA-razvoj]]

## Dokumentacija vs kod (sažetak)

| Što | Do čega | Status |
|-----|---------|--------|
| **Pisanje dokumentacije (plan)** | **M5½** / CHECKPOINT **A** | ✅ završeno |
| **Prva faza kodiranja** | **M6** / CHECKPOINT **B** (B1–B3) | 🔲 sljedeće |
| **Sljedeća runda dokumentacije** | Nakon **B3** playtesta | čeka M6 |
| **v1 launch (igra + store)** | **M8** / CHECKPOINT **D** | daleko — nije prvi kod |

Detalji → [[CHECKPOINT#Dokumentacija vs kod — kada što radiš|CHECKPOINT]]

---

## Pregled

| M | Naziv | Status | Checkpoint sekcija |
|---|-------|--------|-------------------|
| M0 | Infrastruktura dokumentacije | ✅ | — |
| M1 | Vizija | ✅ | A1 |
| M2 | Core dizajn | ✅ | A1 |
| M3 | Sadržaj i iskustvo (osnova) | ✅ | A2 djelomično |
| M4 | Tehničko i scope | ✅ | A3 djelomično |
| M5 | Gate (DoD prije koda) | ✅ | A4 |
| **M5½** | **Dokumentacija detalji** | **✅** | **A1–A4** |
| M6 | Greybox prototip | _sljedeće_ | B |
| M7 | Vertical slice | ⏸ | C |
| M8 | Launch | ⏸ | D |

---

## M5½ — Dokumentacija detalji ✅

**Završeno:** 2026-06-30 — svi docs u [[CHECKPOINT#Sekcija A|Sekcija A]].

**Sljedeće:** M6 greybox — vidi [[CHECKPOINT#Sekcija B — M6 Greybox (Godot prototip)|Sekcija B]].

---

## M6 — Greybox prototip

**Cilj:** Dokazati lane run feel na Androidu (HP dev).

| # | Zadatak | Done |
|---|---------|------|
| 6.1 | Godot 4 na Windows + `game/` projekt | [ ] |
| 6.2 | Android export + APK na emulatoru | [ ] |
| 6.3 | Lane run: swipe, orbs, prepreka, kraj runa | [ ] |
| 6.4 | Loot broj na kraju (placeholder UI) | [ ] |
| 6.5 | 5 min playtest + bilješke | [ ] |

**Exit:** APK s igrivim runom — bez mergea, bez final arta. **Zatim:** kratko ažuriraj docs (CHECKPOINT **B3** trigger) → kreni **M7**.

**Nije cilj M6:** merge, shop, iOS, 100 levela, monetizacija — to je M7/M8.

---

## M7 — Vertical slice

**Cilj:** Kompletan loop s polishom — spremno za vanjski playtest.

| # | Zadatak | Done |
|---|---------|------|
| 7.1 | Loot ekran (×2, revive, retry, kamp) | [ ] |
| 7.2 | Merge kamp min 2 tiera | [ ] |
| 7.3 | 1 upgrade linija (magnet/množitelj) | [ ] |
| 7.4 | Menu → run → loot → kamp flow | [ ] |
| 7.5 | Tutorial prvi launch | [ ] |
| 7.6 | Art pass (**flat cartoon**, slice scope) | [ ] |
| 7.7 | AdMob test + IAP stub (Android) | [ ] |
| 7.8 | iOS build na iPhone (Mac/CI) | [ ] |

**Exit:** Netko tko nije radio na projektu igra 5+ min bez pomoći.

**Napomena:** Pun launch (100 runova, shop polish) = Sekcija D, ne M7.

---

## M8 — Launch (izvan slice-a)

| # | Zadatak | Done |
|---|---------|------|
| 8.1 | 100 runova + endless | [ ] |
| 8.2 | Shop production IAP | [ ] |
| 8.3 | EN store listing + ASO | [x] |
| 8.4 | Google Play + App Store submit | [ ] |
| 8.5 | Marketing test €50–100 | [ ] |

---

## Gate prolaz M5

| Stavka | Status |
|--------|--------|
| Datum | 2026-06-30 |
| DoD 7/7 | ✅ |
| Engine | Godot 4 |
| Platforme | Android + iOS |

---

## Dev okruženje (tvoj setup)

| Uređaj | Uloga | Faza |
|--------|-------|------|
| HP laptop, Windows | Dev + Android export | M6+ svaki dan |
| Android emulator (AVD) | Primarni test | M6+ svaki dan |
| Stariji Android telefon | Fizički test | Kad nabavljen |
| iPhone | iOS test | **M7 (C4)** — ne paralelno s greyboxom |

**Strategija:** Android-first, jedan Godot projekt. Detalji → [[../05-technical/platforme|platforme]] · [[CHECKPOINT|CHECKPOINT]]

## Otvorena pitanja

- [ ] Realan launch datum (ovisno o fakultetu)
- [ ] Mac pristup za iOS — fakultet, prijatelj, ili cloud CI?
- [x] Android telefon ili emulator? → **Emulator primarno** + stariji Android kad nabavi; iPhone za iOS u M7

## Povezano

- [[CHECKPOINT|CHECKPOINT]] — **glavni operativni fajl**
- [[RADIONICA-razvoj|RADIONICA-razvoj]]
- [[roadmap|roadmap]]
- [[scope-i-granice|scope-i-granice]]
