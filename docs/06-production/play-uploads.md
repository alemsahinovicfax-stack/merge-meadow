---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, play, upload, verzije]
povezano:
  - CHECKPOINT
  - play-internal-test
  - plan-telefon-playtest-1111
ai_sažetak: "Dnevnik uploada na Google Play: jedan red po AAB-u (datum, version code, traka, šta je u njemu, rezultat kapije). scripts/release-check.ps1 čita zadnji code odavde i ne da build s istim ili manjim."
---

# Play uploadi

> Roditelj: [[06-production/_index|06-production]] · Kapija: `scripts/release-check.ps1` (mora završiti s `RELEASE OK`) · Pravila: [[plan-telefon-playtest-1111|plan-telefon-playtest-1111]] § 3a

**Kako se koristi:** poslije svakog uploada dodaj red na dno tablice. Kapija čita najveći `Code` iz tablice i odbija build čiji `version/code` nije veći — zato red upiši **tek kad je AAB stvarno uploadan**.

| Datum | Code | Verzija | Traka | Šta je u buildu | Kapija |
|-------|------|---------|-------|------------------|--------|
| 2026-11-10 | 10 | 1.0.1 | internal | Prvi build na telefonu: visok ekran bez crnih traka, zeko u runu. **Bez skinova i Nibbsa** (greske-katalog #63), raspored i dodir #64, #65 | nije postojala |

## Sljedeći (još nije uploadan)

- **Code 13 · 1.0.1 · internal** — FIX-TEL-3: Arena štekanje pri tapu na vreću, Level Path (swipe, gašenje pri odlasku s Homea), Journal ★T1 iz runa, Muncher jači, pragovi sezona 30 / 35 / 40, Boostovi po levelu u T3 cvjetovima. Izvještaj: [[telefon-playtest-1112b-izvjestaj|telefon-playtest-1112b-izvjestaj]]. Kad ga uploadaš, upiši red u tablicu.
- **Code 12 · 1.0.1 · internal** — (ako je uploadan, upiši i njega u tablicu) FIX-TEL-2: run (kontakt glavom, vjetar ×5, odbrojavanje poslije pauze, Endless Pace 10 s), Home (Ormar, Basket desno, glatki paneli), Camp trejd bez štekanja, Journal „Loading…", Arena cap 200. Izvještaj: [[telefon-playtest-1112-izvjestaj|telefon-playtest-1112-izvjestaj]]. Kad ga uploadaš, upiši red u tablicu.
- **Code 11 · 1.0.1 · internal** — (ako je uploadan 2026-11-11 / 12, upiši i njega u tablicu) FIX-TEL: skinovi / novi Pip / Nibbs u buildu, svi omjeri ekrana, Shop skrol prstom, sjeme u Areni, „Continue", kraj merge runde, Camp, Journal bez gradnje pri ulasku. Izvještaj: [[telefon-playtest-1111-izvjestaj|telefon-playtest-1111-izvjestaj]]. Kad ga uploadaš, premjesti ovaj red u tablicu.

## Povezano

- [[play-internal-test|play-internal-test]]
- [[CHECKPOINT|CHECKPOINT]]
