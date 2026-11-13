---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, playtest, telefon, bugfix, izvjestaj]
povezano:
  - plan-telefon-playtest-1112
  - telefon-playtest-1111-izvjestaj
  - play-uploads
  - greske-katalog
  - CHECKPOINT
ai_sažetak: "FIX-TEL-2 izvještaj (2026-11-12): drugi krug prijava s telefona — run (kontakt glavom, vjetar ×5, odbrojavanje poslije pauze, Endless Pace 10 s), Home (Ormar, Basket desno, glatki paneli), Camp trejd 31 → 1,4 ms, Journal kostur Loading…, Arena cap 200. Šta je mjereno i slikano na laptopu, šta nije potvrđeno na telefonu, lista za ručnu provjeru."
---

# FIX-TEL-2 — izvještaj drugog kruga (build 12)

> Roditelj: [[06-production/_index|06-production]] · Plan: [[plan-telefon-playtest-1112|plan-telefon-playtest-1112]] · Prvi krug: [[telefon-playtest-1111-izvjestaj|telefon-playtest-1111-izvjestaj]] · 2026-11-12

## 1. Ukratko

Svih 11 prijava je urađeno u kodu. Novi AAB je **version code 12** (verzija 1.0.1). **Ništa od ovoga nije provjereno na pravom telefonu** — sve je mjereno, testirano i slikano na laptopu (prozor omjera 20:9). Tvoj korak je § 5.

Tri nalaza su bila drugačija od onoga što se činilo:

- **Camp trejd:** nije štekala animacija novčića (0,03 ms), nego sve oko nje — vidi § 3.
- **Izrezani skinovi:** nije stvar okvira; veličina Pipa u sličici se uopšte nije primjenjivala (bug i na kompjuteru).
- **Trzaj panela na Homeu:** animacija je kretala u istom frejmu u kojem se sadržaj gradi.

## 2. Šta je urađeno

| # | Prijava | Šta je sada | Kako je provjereno |
|---|---------|-------------|--------------------|
| 1 | Glava Pipa pređe preko sjemena / coina / prepreke | Kolizija Pipa ide od vrha glave; coin i prepreka imaju koliziju do ruba crteža. Predmet se „pikne" čim dotakne glavu | Test `run_head_contact_smoke` + slika trenutka dodira |
| 2 | Vjetar se ne osjeti | Nalet gurne stazu 50 px (bilo 10), puta brzina levela (do 125 px na brzim levelima / visokom Pace-u). Staza se više ne vraća nazad. Jače linije, Pip se više nagne | Test (`levels_endless_smoke`); **nije slikano** |
| 3 | „Keep running" odmah nastavlja | Meni se zatvori, na sredini 3 → 2 → 1 (2,1 s), pa igra krene. Pauza usred odbrojavanja vraća meni | Test + slika |
| 4 | Endless Pace na 20 s | Pace se mijenja svakih 10 s | Test |
| 5 | Katanac proziran kao skin | Pun bijeli bedž s katancem u gornjem desnom uglu sličice, iznad Pipa | Slika Ormara |
| 6 | Skinovima odsječene uši / glava | Pip je cijeli u okviru (i u Shop · Looks) | Slika Ormara |
| 7 | Ormar / Boosts / Basket ulaze s trzajem | Panel čeka dva frejma ispod ekrana pa ulazi; spor frejm uspori animaciju umjesto da je preskoči. Ormar se izgradi unaprijed, pola sekunde poslije otvaranja polja | Testovi Homea prolaze; **glatkoća se vidi samo na telefonu** |
| 8 | Basket desno ispod Boostova | Urađeno; oblačić tutoriala pokazuje s lijeve strane | Slika + test |
| 9 | Camp trejd šteka | Vidi § 3 | Mjerenje `camp_trade_bench` |
| 10 | Journal: sezone se učitavaju s trzajem | Sezona odmah zauzme punu visinu; na mjestu redova su blijedi „kosturi" s natpisom **Loading…**; redovi stižu jedan po jedan (svaki drugi frejm) s blagim fade-om | Slika + testovi Journala |
| 11 | Arena: cap 200 sjemenki po rundi | Runda dolije najviše 200; ostatak čeka u vreći. Pilula iznad vreće: `N / 50` dok fali, `N / 200` (mint, oznaka, blagi puls) kad možeš igrati. Tap na vreću poslije 200 — oblačić „200 seeds this round…" | Test `arena_round_cap_smoke` + slika |

## 3. Camp trejd — šta je stvarno štekalo

Izmjereno skriptom `camp_trade_bench` (60 trejdova kao pri držanju dugmeta, laptop):

| | Prije | Poslije |
|---|-------|---------|
| Jedan trejd | **31 ms** (najgori 62 ms) | **1,4 ms** (najgori 5,7 ms) |
| Od toga: usklađivanje kartica sjemenki | 40 ms* | 0,05 ms |
| Puštanje dugmeta (i običan tap) | ruši i gradi obje liste + snima save (7–21 ms) | lagano osvježavanje; save pola sekunde kasnije |
| Let novčića | 0,03 ms | 0,03 ms |

\* mjereno zasebno, pod opterećenjem.

Uzrok: svaki trejd je na **svakoj** kartici sjemenke ponovo postavljao stil, a svako puštanje dugmeta je rušilo cijelu listu i odmah snimalo. Kad klikćeš Trade dok novčić leti, to se dešavalo na svaki klik.

Tvoja ideja je primijenjena: novčići sada lete isto kao pickupi u runu (isti čvorovi kruže, jedan prolaz po frejmu, bez pravljenja novih). Ali samo to ne bi riješilo trzaj — riješilo ga je ovo iznad.

Telefon je obično 4–8 puta sporiji od laptopa, pa očekujem 6–12 ms po trejdu umjesto 120–250 ms. To je procjena, ne mjerenje.

## 4. Odluke koje sam donio umjesto tebe

| Odluka | Zašto | Kako se mijenja |
|--------|-------|-----------------|
| **Endless: Pace N je iste težine kao prije**, pa težina sada raste **duplo brže** (Pace 6 poslije 60 s umjesto 120 s) | „Pace na 10 s" sam shvatio kao iste stepenice koje brže stižu | Ako je preteško: `ENDLESS_KEY_SEC_PER_TIER` u `game/scripts/run/run_level_library.gd` s 20 na 10 — stepenice ostaju na 10 s, težina po sekundi se vraća na staro |
| **Vjetar ne vraća stazu nazad** | S 50+ px „naprijed pa nazad" bi predmet na tren ušao u Pipa pa se odmakao — lažan sudar | — |
| **Razmak između redova prepreka 300 → 366 px** | Sudar sada počinje 66 px ranije (glava + rub prepreke); bez ovoga bi izmicanje bilo teže nego prije | `MIN_ROW_GAP_PX` u `run_controller.gd` |
| **Uši Pipa ne broje kao kontakt**, samo glava | Uši u pogledu odozgo strše iza i sa strane; kontakt ušima bi bio nefer | — |
| **Katanac u uglu**, ne na sredini | Na sredini pokriva lice skina koji želiš vidjeti | — |
| **U rundi brojač na vreći pokazuje koliko runda još može dobiti** (najviše 200), ne cijelu vreću | Inače ne bi bilo jasno zašto vreća prestane sipati | — |
| **Uz „Reduce motion" nema naleta vjetra** (kao i do sada), odbrojavanje se samo smjenjuje | Postojeće pravilo igre | — |

## 5. Šta ti radiš

1. Upload `game\export\android\merge_meadow.aab` (code 12) na internal test.
2. Prođi listu:
   - [ ] **Run:** coin / sjeme nestane čim dotakne glavu; prepreka te zaustavi na dodir glave, ne tijela
   - [ ] **Run:** nalet vjetra se jasno osjeti (na 15 s u levelu, na svaki novi Pace u Endlessu), jači na višim levelima
   - [ ] **Run:** pauza → „Keep running" → 3, 2, 1 → igra krene; je li 2 sekunde previše ili premalo?
   - [ ] **Endless:** Pace se mijenja svakih 10 s; je li sada preteško?
   - [ ] **Home:** Basket je desno ispod Boostova
   - [ ] **Ormar:** skinovi cijeli u sličicama, katanac jasan; ulazak panela bez trzaja (i Boosts, i Basket)
   - [ ] **Camp:** klikći i drži Trade — šteka li i dalje?
   - [ ] **Journal:** skrolaj do dna — nove sezone se pojave s „Loading…" bez trzaja
   - [ ] **Arena:** pilula `N / 200` kad imaš 50+; runda stane na 200 sjemenki; ostatak je u vreći
3. Dodaj red u [[play-uploads|play-uploads]] (i za code 11 ako ga nisi upisao).
4. Javi šta ne prolazi.

## 6. Šta nije riješeno ili nije potvrđeno

| Stavka | Stanje |
|--------|--------|
| Sve iz § 2 na pravom telefonu | Nije provjereno — samo laptop |
| Glatkoća panela i Journala | Uzroci trzaja su uklonjeni u kodu, ali „glatko" se može potvrditi samo na telefonu |
| Izgled naleta vjetra | Testiran brojevima, nije slikan |
| Home: ulazak na stranicu (4–9 ms na laptopu) | Nije dirano ni u ovom krugu |
| Tableti: trake sa strane; Home kartica na visokom ekranu | Otvoreno iz prvog kruga |
| Testovi zavise od savea | Otvoreno iz prvog kruga (`fixes_1016_smoke` pada na čistom saveu, kao i prije) |
| CD redizajn Journala (harmonika) | Nije rađen — prvo vidjeti build 12 |

## 7. Rezultat kapije

`scripts/release-check.ps1`, 2026-11-12, 12,7 min → **RELEASE OK**

| Korak | Rezultat |
|-------|----------|
| SVG tekst | 168 kopija, `svg_source_smoke` prolazi |
| GUT | 149 / 149 |
| Smoke testovi | 82 / 88 s kopijom tvog savea; preostalih 6 (svi Camp, isti kao u prvom krugu) prolaze na čistom saveu → nijedan ne pada u oba |
| Testovi iz exportovanog paketa | prolaze |
| Version code | 12 (zadnji u `play-uploads` tablici: 10) |
| AAB | `game\export\android\merge_meadow.aab`, 69,2 MB, SVG tekst 168 / 168, data JSON 16 / 16, bez test fajlova |

Napomene:

- Prvi pokušaj kapije je pao na njenoj vlastitoj grešci od jučer (pokvarena putanja izolovanog GUT savea, katalog #70) — ne na igri. Ispravljeno, pa ovaj prolaz.
- Kapija na početku briše stari `merge_meadow.aab`, pa AAB code 11 više nije u folderu.

## 8. Novi alati

- `scripts/dev/camp_trade_bench.gd` — cijena jednog trejda po koracima
- `scripts/dev/pip_bounds_probe.gd` — stvarne granice crteža Pipa po skinu i pogledu
- `scripts/dev/fix_tel2_capture.gd` — slike Homea, Ormara, panela, runa, Arene, Journala u omjeru telefona
- Testovi: `run_head_contact_smoke`, `arena_round_cap_smoke`
- Katalog grešaka #67–#70

## Povezano

- [[plan-telefon-playtest-1112|plan-telefon-playtest-1112]]
- [[play-uploads|play-uploads]]
- [[../05-technical/godot/greske-katalog|greske-katalog]]
- [[CHECKPOINT|CHECKPOINT]]
