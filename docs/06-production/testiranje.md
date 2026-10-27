---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, testiranje, retencija]
povezano:
  - procjena-igraca
  - play-console-sutra
  - ideje-prvo-iskustvo
ai_sažetak: "QA i playtest plan: smoke po buildu, playtest prvog iskustva sa 5–10 nepoznatih ljudi (vremena, KPI), protokol closed testa (ne podsjećati, statistika iz igre 15. dan ili kasnije, tumačenje malog uzorka)."
---

# Testiranje

> Roditelj: [[06-production/_index|06-production]] · Strategija mjerenja: [[procjena-igraca|procjena-igraca]]

## Sažetak

QA plan za solo deva — emulator + telefon, playtest prvog iskustva s nepoznatim ljudima i closed test na Google Playu s mjerenjem retencije iz same igre (RET-01).

## Faze testiranja

| Faza | Kada | Uređaj | Fokus |
|------|------|--------|-------|
| Dev smoke | Svaki commit | Emulator | Crashes, input (`scripts/smoke-all.ps1`, `scripts/gut-run.ps1`) |
| Greybox playtest | M6 | Android emulator | Feel, 5 min |
| Slice playtest | M7 | Emulator + iPhone | Full loop |
| **Playtest prvog iskustva** | Prije closed testa | Telefon | 5–10 **nepoznatih** ljudi, prvih 10 min (§ ispod) |
| **Closed test** | Prije produkcije | Play (12–20 testera, 14 dana) | D1 / D3 / D7 / D14, bugovi (§ ispod) |
| Store test | Launch | Internal / TestFlight | IAP, ads |

## Checklist po buildu (smoke)

- [ ] App se pokreće bez crasha
- [ ] Swipe radi
- [ ] Run završava i prikazuje loot
- [ ] Kamp se otvara
- [ ] Save/load nakon restarta app-a
- [ ] Pause radi
- [ ] Zvuk off u settings
- [ ] Settings → 5 dodira na verziju otvara „Your stats" (i u release buildu)

## Playtest prvog iskustva (5–10 nepoznatih)

Nadogradnja starog „M7 playtest scripta". Cilj: vidjeti prvih 10 minuta očima nekoga ko igru nije vidio. Prijatelji i porodica ne broje se — previše su ljubazni i znaju šta igra radi.

**Pravila za tebe (posmatrača)**
1. Novi save (obriši podatke aplikacije ili novi telefon). Telefon u ruke, ti samo gledaš.
2. **Ne pomaži i ne objašnjavaj.** Ako pitaju „šta sad?", reci „uradi šta misliš da treba". Zapiši pitanje — to je nalaz.
3. Zamoli da misle naglas („govori šta vidiš i šta pokušavaš").
4. Pusti ih da igraju koliko žele (najviše 10 min). Ne predlaži drugi run — gledaš da li ga sami pokrenu.
5. Poslije: Settings → 5 dodira na verziju → zapiši „First merge" i broj runova.

**List za posmatrača (jedan red po osobi)**

| Polje | Kako |
|---|---|
| Ko (godine, igra li mobilne igre) | pitaj prije |
| Prvi dodir (s) | štoperica od otvaranja |
| Prvi „lijep" trenutak (s) i šta je bio | prvo „oo", smijeh, komentar |
| Kraj runa 1 (s), pao ili prošao | |
| Prvi merge (mm:ss igre) | ekran statistike |
| Otvorio Arenu (da / ne) | |
| **Drugi run sam od sebe** (da / ne, s) | ključni signal |
| Zbunjenost (citati) | doslovno |
| Zašto je prestao | pitaj poslije |
| Zabava 1–5 · Jasnoća 1–5 | pitaj poslije |
| „Bi li igrao sutra?" | pitaj poslije — slab signal, ali zapiši |

**Ciljevi** (iz [[../03-content/ideje-prvo-iskustvo|ideje-prvo-iskustvo]]): prvi lijep trenutak < 15 s · prvi merge < 4 min igre · drugi run svojevoljno prije izlaska. Ako ih manje od pola osoba ne postigne → popravi prvo iskustvo prije closed testa.

## Closed test — mjerenje (RET-01)

Igra broji dane igranja sama (lokalno, ništa ne šalje — `ActivityLog`). Zato se testeri **ne kontaktiraju usred testa**: svaki podsjetnik („jesi li igrao?") povećava igranje i kvari mjerenje.

1. **Poziv** (EN/BS u [[play-console-sutra|play-console-sutra]] § 7) kaže samo: drži instalirano, igraj kad ti se da; na kraju jedna anketa.
2. **Tokom testa:** kanal za bugove ostaje otvoren (tester javlja sam). Ti ne pišeš.
3. **15. dan ili kasnije:** poruka za kraj testa (§ 7) + Google Form. Ne ranije: dan kad tester kopira red se ne broji (tada je igru otvorio zbog reda), pa bi D14 ostao neizmjeren.
   - Zabava 1–5 · Jasnoća 1–5
   - Šta ti je nedostajalo / šta je bilo dosadno?
   - Kad si zadnji put igrao/la i zašto si stao/la (ako jesi)?
   - Bi li nastavio/la igrati poslije testa? (da / možda / ne)
   - Zalijepi red iz igre (Settings → 5 dodira na verziju → Copy)
   - EN verzija istih pitanja: Fun 1–5 · Clarity 1–5 · What was missing or boring? · When did you last play, and why did you stop (if you did)? · Would you keep playing after the test? · Paste the line from the game.
4. **Redovi → CSV:** prvi red `scripts/analytics/testeri-primjer.csv` je zaglavlje; dodaj po red za svakog testera u `testeri.csv` (van repoa ili u `docs/00-personal/`), pa:
   `python scripts/analytics/retention_forecast.py cohort --csv testeri.csv --today 2026-11-20`
5. **Tumačenje** — mali uzorak, ljudi koje znaš:

| Testera od 15 vratilo se | Wilson 95 % | D1 signal | D7 signal |
|---|---|---|---|
| 1 | 1–30 % | 🔴 | 🔴 |
| 2 | 4–38 % | 🔴 | 🟡 |
| 4 | 11–52 % | 🟡 | 🟢 |
| 6 | 20–64 % | 🟡 | 🟢 |
| 8 | 30–75 % | 🟢 | 🟢 |
| 10 | 42–85 % | 🟢 | 🟢 |

   Pragovi su viši od benchmarka jer prijatelji igraju više od stranaca: 🔴 = ni oni se ne vraćaju (jasan problem, popravi prije produkcije); 🟡 = nejasno; 🟢 = „nije katastrofa", ne „uspjeh". Pravi broj daje tek prva grupa od ~300 pravih instalacija ([[procjena-igraca|procjena-igraca]] § Faze).
6. Iz ankete i reda statistike zapiši 3 najveća problema → Google pita „šta si naučio" kod zahtjeva za produkciju.

## Feedback kanal

- Google Form (anketa za kraj testa) + Discord / WhatsApp grupa samo za bugove.

## Otvorena pitanja

- [ ] TestFlight beta broj testera

## Povezano

- [[CHECKPOINT|CHECKPOINT]]
- [[procjena-igraca|procjena-igraca]]
- [[rizici|rizici]]
