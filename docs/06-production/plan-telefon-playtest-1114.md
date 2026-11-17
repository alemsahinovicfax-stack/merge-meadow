---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, playtest, telefon, balans, plan]
povezano:
  - plan-telefon-playtest-1112b
  - telefon-playtest-1114-izvjestaj
  - CHECKPOINT
ai_sažetak: "FIX-TEL-4 plan (2026-11-14): pragovi Journey sezona +10 (40 / 45 / 50), level najviše 2 min, 25 levela po sezoni (peti pojas), sanduci Level Patha po novom redu cvijeća (+2000 coina na 25), Endless Pace +10 % i spawn +20 %, Boost dugme u boji tiera s većim portretom. Plan je unaprijed odobren; faze A–F."
---

# FIX-TEL-4 — četvrti krug (balans i 25 levela)

> Roditelj: [[06-production/_index|06-production]] · Prethodni krug: [[plan-telefon-playtest-1112b|plan-telefon-playtest-1112b]] · 2026-11-14
> Plan je odobren unaprijed („nastavi po istom šablonu") — izvršava se odmah. Izvještaj: [[telefon-playtest-1114-izvjestaj|telefon-playtest-1114-izvjestaj]].
> Claude Design nije potreban: put se produžava istim kamenjem, sanducima i pozadinom; peti pojas je crtež po uzoru na postojeća četiri.

## Zahtjevi i kako su pročitani

| # | Zahtjev | Čitanje | Faza |
|---|---------|---------|------|
| 1 | Cvijeće za otključavanje Journey sezona skoči za po 10 | Svaki prag +10: Frost Orchard 40, Lantern Meadow 45, Amber Canopy 50 (bilo 30 / 35 / 40). Themes ostaju coini | A |
| 2 | Level traje najviše 2 minute | Leveli 1–19 ostaju (60–116 s), 20–25 su 120 s; kod reže sve preko 120 s | A |
| 3 | +5 levela u svakoj sezoni (25) | Level N je iste težine u svakoj sezoni, pa je jedna tabela: 21–25 nastavljaju korak 16–20 (brzina, rampa, gustina, prepreke, parovi), trajanje 120 s. Peti pojas „Blitz" 21–25. Put je viši za 1030 px | B |
| 4 | Sanduci na 5 / 10 / 15 / 20 / 25 | T3 cvjetovi: 10 × prvi ljubičasti, 15 × drugi ljubičasti, 20 × drugi ljubičasti, 5 × zlatni, 10 × zlatni. Coini ostaju 200 / 400 / 600 / 1000, a level 25 daje 2000. Veliki sanduk i zastavica cilja sele na 25 | C |
| 5 | Endless: Pace 10 % jači, prepreke i nagrade 20 % češće | Svaka stepenica Pacea nosi 10 % veći korak težine (22 s tabele umjesto 20; poslije zadnjeg ključa brzina +0,044 po stepenici). Razmak spawna ÷ 1,2 u Endlessu | D |
| 6 | Boost dugme u boji tiera, veći portret | Ljubičasti level: lavanda dugme; zlatni level: zlatno dugme (i kad nema dovoljno — blijeda nijansa). Portret cvijeta 64 → 104 px u krem disku; „×N" i coini u dva reda desno | E |

## Faze

- **A** — `seasons.json` pragovi; rez trajanja na 120 s.
- **B** — `levels.json` 21–25; `MAX_RUN_LEVEL`, `LevelPathDomain.LEVELS` = 25; raspored puta (`layout.json`) generisan alatom: 5 novih kamenova, ruta, visina 5930; peti pojas (pločice, zastavica); tekstovi „/ 25", „Play repeats Level 25". Stari save: igrač koji je završio put (21) staje na level 21 i nastavlja.
- **C** — nagrade sanduka po levelu (vrsta + broj + coini); pločice ispod sanduka i popup crtaju pravi cvijet.
- **D** — Endless.
- **E** — Boost dugme.
- **F** — testovi, slike svih 8 puteva, `release-check.ps1` (code 14), izvještaj.

## Povezano

- [[plan-telefon-playtest-1112b|plan-telefon-playtest-1112b]]
- [[CHECKPOINT|CHECKPOINT]]
