---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, merge, pitanja, scratch]
povezano:
  - ideje-arena
  - ideje-arena-ciljevi
  - ideje-arena-feel
  - ideje-arena-bloom
  - ideje-arena-pest
  - ideje-arena-grupe
  - plan-prompts-arena
  - CHECKPOINT
ai_sažetak: "ARENA-01 pitanja — A0–A35 freeze 2026-08-20; combo+coins, pulse, auto-refill, T2 leftover→2×T1, daily badge."
---

# IDEJE — ARENA-01 pitanja

> [[ideje-arena|ARENA-01 hub]]. Magnet + MA-01b ostaju. **Freeze A0–A35 2026-08-20.** Grupe: [[ideje-arena-grupe|grupe]]. Prompti: [[../06-production/plan-prompts-arena|plan-prompts-arena]] — zalijepi **COMB-A**.

## Kako koristiti

1. Pregledaj sažetak + **Odgovor** na A0–A35. Override samo svjesno.
2. Kod: [[../06-production/plan-prompts-arena|prompti]] **COMB-A → FLOW-A → FLOW-B → DAILY-A → FEEL-A → FEEL-B** (mapa: [[ideje-arena-grupe|grupe]]). Cliff u areni ispada.
3. Ne vraćati bloom panel u arenu. Ne prepisivati [[../02-design/merge-arena-v1.1|merge-arena-v1.1]] dok ne kažeš „dodaj u scope“.

## Sažetak

| # | Tema | Odluka |
|---|------|--------|
| **A0a** | Najveći bol | **Mješavina** — katalog |
| **A0b** | Ambicija prvog tracka | **Magnet + lagani ciljevi** (combo, cliff, daily) |
| **A1** | Combo nagrada | **C** — vizual + 1–2 coins na visokom combu (5+), dnevni cap |
| **A2** | Combo prozor | **A** — kratko ~1.2–1.6 s (arcade) |
| **A3** | Što lomi combo | **A** — samo timeout (pest ne lomi) |
| **A4** | Soft cliff primarna poruka | **A** — merge (“još 1 Clover do T2/T3”) |
| **A5** | Gdje stoji cliff | **C** — samo Camp; arena čista (cliff **nije** ARENA-01 kod) |
| **A6** | Dnevni zadatak koliko | **A** — jedan arena zadatak (prvi DG-01 slice) |
| **A7** | Daily nagrada | **C** — samo vizualni badge / streak dana, bez loota |
| **A8** | Daily UI | **C** — progress u areni, claim/badge u Campu |
| **A9** | Clear-field bonus | **B** — samo VFX, bez coina |
| **A10** | T2 na playfieldu | **A** — ostavi T2 (T2→T3 je igra) |
| **A11** | Bloom spend | **D (custom)** — auto-riješi T2 kad para u ovom runu više nema |
| **A11b** | Kamo auto-T2 | **E (custom)** — Donate/Album/Basket nisu opcija; T2 → 2× T1 u camp bag |
| **A11c** | Scope spend | **B** — u areni nema Donate/Album/Basket; T3 crystal; spend samo Camp |
| **A12** | Pair pulse | **A** — da, u istom tracku kao combo |
| **A13** | Sort by type | **C** — ne u ovom tracku (magnet + pulse) |
| **A14** | Clutter / pour | **D (custom)** — cap 40; auto-pour kad polje padne na 10, dok bag ima sjeme |
| **A15** | Pour sadržaj | **B** — preferiraj tipove koji već imaju orphan/par na polju |
| **A16** | Muncher vs combo | **A** — pest jede sjeme, ne lomi combo, nema extra freeze |
| **A17** | Muncher kao igračka | **A** — ne sada |
| **A18** | Pip u areni | **B** — mali Pip na rubu, reakcija na combo/T3 |
| **A19** | Vizualni napredak | **B** — livada tint s brojem T3 u sesiji |
| **A20** | Score | **A** — nema scorea, samo combo broj |
| **A21** | Tajmer / runde | **A** — bez tajmera (sandbox) |
| **A22** | Auto-chain | **A** — svaki merge ručni |
| **A23** | Merge Hint vs combo | **A** (+ napomena) — hint ostaje tekst; možda izbaciti kasnije, ne ovaj track |
| **A24** | Duljina sesije | **C** — prvi pour zadovoljava, ostatak opcionalan |
| **A25** | Odd leftover | **A** — T1 na Done u bag; T2 leftover već 2×T1 |
| **A26** | Tutorial combo | **C** — ništa; igrač otkrije HUD |
| **A27** | Audio | **A** odgođeno — pitch-up ding, ali tek na cjelokupni SFX pass (kraj / D0-P) |
| **A28** | Monetizacija uz ciljeve | **A** — ništa novo |
| **A29** | Interstitial na izlazu | **B** — ne u ARENA-01; parking post-launch A/B |
| **A30** | Mythic u areni | **C** — ne dirati u ovom tracku |
| **A31** | HUD copy | **A** — Combo |
| **A32** | Prioritet sliceova | **A** — combo (+pulse, refill, leftover T2) prvo; daily zadnje (preporuka, prihvaćena) |
| **A33** | Prvi kod uz ciljeve | **B** — pair pulse u prvi kod uz combo (preporuka, prihvaćena) |
| **A34** | Playtest prije koda | **A** — freeze pa prompti/kod (nije čekanje na D0-P) |
| **A35** | Ostalo | **A** — ništa više; lista dovoljna |

---

## A0a — Što je najmonotonije

**Pitanje:** Što ti je NAJVIŠE monotono u Merge Areni danas?

| Opcija | |
|--------|--|
| A | Lov na parove u hrpi (do 40 chipova). |
| B | Isti drag-merge zauvijek — nema runde, comba, ni kratkog cilja. |
| C | Merge radi, ali nema wow (VFX/SFX, pop, Pip). |
| D | T2 ostaje + Donate/Keep/Basket je korak previše. |
| E | Muncher nije zabavan — dosadan ili samo smeta. |
| F | Mješavina / nisam siguran — biram iz kataloga. |

**Odgovor (2026-08-20):** **F**.

---

## A0b — Koliko daleko u prvom tracku

**Pitanje:** Koliko daleko želiš ići u prvom tracku (v1.1+, ne D0 blocker)?

| Opcija | |
|--------|--|
| A | Samo feel + jasnoća (sort, pulse, VFX, T2 inbox) — ista mehanika. |
| B | Isti magnet + lagani ciljevi: combo, soft cliff, dnevni arena zadatak. |
| C | Novi verbovi / igračke: eventi, pest kao ljubimac, gold seed, runde. |
| D | Prvo cijela lista pitanja, pa freeze — nemoj još birati track. |

**Odgovor (2026-08-20):** **B**.

---

## A1 — Combo nagrada

**Pitanje:** Što combo donosi? Nikad obavezno za upgrade. Nema pay-to-merge.

| Opcija | |
|--------|--|
| A | **Samo vizual** (broj, punch, čestice). Nema ekonomije. |
| B | Vizual + extra Muncher freeze (npr. +0.5 s po stupnju, cap). |
| C | Vizual + 1–2 coins na visokom combu (npr. 5+), **dnevni cap**. |
| D | A + B, bez coina. |

Detalj: [[ideje-arena-ciljevi|ciljevi]] · [[ideje-arena-pest|pest freeze]].

**Odgovor (2026-08-20):** **C**. Vizual ostaje; coins samo na visokom combu (draft 5+), dnevni cap da se ne farma. Nije put do upgradea.

---

## A2 — Combo prozor

**Pitanje:** Koliko dugo smiješ čekati između mergeva?

| Opcija | |
|--------|--|
| A | Kratko (~1.2–1.6 s) — arcade, pest ima smisla. |
| B | Srednje (~2.0–2.5 s) — casual palac. |
| C | Dugo (~3.5 s) — cozy, combo skoro uvijek drži. |

**Odgovor (2026-08-20):** **A**. Arcade prozor; pest i clutter moraju biti čitljivi (A12/A14 kasnije) jer 1.5 s ne oprašta lov u hrpi.

---

## A3 — Što lomi combo

**Pitanje:** Osim isteka prozora, što još resetira streak na 0? Done/Back uvijek gase.

| Opcija | |
|--------|--|
| A | **Samo timeout.** |
| B | Timeout + pest jede **bilo koji** chip. |
| C | Timeout + pest + „prazan“ drag (release bez mergea). |

**Odgovor (2026-08-20):** **A**. Pest i dalje jede sjeme, ali ne resetira streak. Prazan drag ne kažnjava.

---

## A4 — Soft cliff: koja poruka je primarna

**Pitanje:** Jedna rečenica u areni — što ima prednost?

| Opcija | |
|--------|--|
| A | Merge („Još 1 Clover T1 do T2 / do T3“). |
| B | Upgrade donate („Još 1 T2 do Sprinkler“). |
| C | Daily zadatak („Combo 5 danas 2/5“). |
| D | **Rotira:** merge dok ima para, inače donate, inače daily. |

**Odgovor (2026-08-20):** **A**. Donate i daily nisu primarni tekst u areni (mogu ostati u Campu / A8).

---

## A5 — Gdje stoji cliff

**Pitanje:** Gdje živi ta rečenica?

| Opcija | |
|--------|--|
| A | Postojeći `info_label` (zamijeni generički „keep merging“). |
| B | Mali fiksni red iznad playfielda; `info_label` ostaje tutorial/pest. |
| C | Samo na Camp kartici; arena ostaje čista. |

Ako **C**, cliff ispada iz ARENA-01 koda.

**Odgovor (2026-08-20):** **C**. Arena bez cliff HUD-a. A4 A i dalje vrijedi za **Camp** copy (postojeći `garden_cliff_text` / merge smjer). ARENA-01 B-slice (cliff u areni) **ispada**.

---

## A6 — Dnevni zadatak: koliko

**Pitanje:** Koliko DG-01 u ovom tracku?

| Opcija | |
|--------|--|
| A | **Jedan** arena zadatak (prvi DG-01 slice). |
| B | Puna DG-01 trijada (run + arena + donate) odmah. |
| C | Nema dailya ovdje — samo combo + cliff. |

**Odgovor (2026-08-20):** **A**. Puna DG-01 trijada nije ovaj track. Jedan merge/combo/T3 zadatak po danu.

---

## A7 — Daily nagrada

**Pitanje:** Što dobiješ na claim (1× / local day)? Preskoči ako A6=C.

| Opcija | |
|--------|--|
| A | +coins (rang daily chest mikro). |
| B | Coins + 2–3 unlocked T1. |
| C | Samo vizualni badge / streak dana, bez loota. |

**Odgovor (2026-08-20):** **C**. Coins ostaju na combu (A1 C), ne na daily claimu.

---

## A8 — Daily UI

**Pitanje:** Gdje progress, gdje Claim? Preskoči ako A6=C.

| Opcija | |
|--------|--|
| A | Jedan red u areni (progress + Claim). |
| B | Na postojećem daily chest u Campu. |
| C | Oboje: progress u areni, claim u Campu. |

**Odgovor (2026-08-20):** **C**. Arena vidi npr. `2/5`; Claim/badge na postojećem chestu u Campu. Mali progress chrome, ne cliff rečenica.

---

## A9 — Clear-field bonus

**Pitanje:** Kad na polju nema više legalnih parova (odd leftover OK)?

| Opcija | |
|--------|--|
| A | Da — mali VFX + maybe 1 coin (sesijski cap). |
| B | Da — samo VFX. |
| C | Ne — ostaje sandbox pour/Done. |

**Odgovor (2026-08-20):** **B**. Celebration kad nema para; coins ostaju na A1 C. Nije fail ako ne clear-aš.

---

## A10 — T2 na playfieldu

**Pitanje:** Spec kaže T2 odmah u inbox; kod ostavlja T2. Što radimo?

| Opcija | |
|--------|--|
| A | **Ostavi T2** (merge T2→T3 je igra; bloom tap kad hoćeš). |
| B | T2 odmah u inbox; arena = samo T1 playground. (Ako B: u chatu dopuni gdje nastaje T3.) |
| C | T2 kratko ostane (~1 s) pa fly u inbox ako ga ne spojiš. |

Detalj i rupa T3: [[ideje-arena-bloom|bloom]].

**Odgovor (2026-08-20):** **A**. Spec inbox preporuka se ne primjenjuje u ovom tracku. T2+T2 na polju hrani kratki combo.

---

## A11 — Bloom spend friction

**Pitanje:** Kako trošiš T2 (Donate / Album / Basket)?

| Opcija | |
|--------|--|
| A | Ostavi panel s tri gumba. |
| B | Default **jedan tap** (Donate ako nije max, inače Album, inače Basket). |
| C | Swipe na T2: gore Donate, dolje Album, Basket long-press. |

**Odgovor (2026-08-20):** **D (custom, chat).** T2 ostaje na polju dok postoji šansa za drugi T2 istih tipa u **ovom merge runu** (polje + preostali T1 tog tipa na polju/u bagu dovoljni za još jedan T2). Čim to više nije moguće, T2 se **auto-riješi** — bez panela usred comba. Panel 3 gumba / swipe **nisu** default. Pod-pitanje **A11b** = *kamo* ide auto-spend.

---

## A11b — Auto-riješen T2: kamo

**Pitanje:** Kad sistem skine odd T2, koja akcija?

| Opcija | |
|--------|--|
| A | Stack kao stari B: Donate ako nije max, inače Album ako može upgrade, inače Basket. |
| B | Fly u inbox/stash — spend kasnije (Camp ili traka), ne usred arene. |
| C | Uvijek Album (ako već u albumu na tom tieru → Donate stack, pa Basket). |
| D | Uvijek Donate ako upgrade nije max; inače ostavi T2 (igrač tapne). |

**Odgovor (2026-08-20):** **E (custom, chat).** Donate / Album / Basket **nisu** opcije za taj T2. Vraća se u Camp kao **dva T1** istog tipa. Nije coin, nije crystal.

---

## A11c — Scope: samo leftover ili cijeli spend

**Pitanje:** „Donate, album i basket više nisu opcija uopšte“ — koliko daleko?

| Opcija | |
|--------|--|
| A | **Samo leftover T2** (nema para u runu) → 2× T1. T2 koji **može** par se i dalje mergea u T3. T3 i dalje crystal stash. Donate/Album/Basket ostaju za T3/Camp ako već postoje. |
| B | U areni **nema** Donate/Album/Basket uopšte. Odd T2 → 2× T1. T3 crystal. Album/donate/basket žive samo u Campu (ako uopšte). |
| C | U areni nema spend panela. Odd T2 → 2× T1. T3 također reciklirati / druga pravila (upiši u chatu). |

**Odgovor (2026-08-20):** **B**. Arena = merge playground + leftover T2→2×T1. Nema bloom panela. T3 → garden stash kao danas. Donate/Album/Basket **samo Camp**.

---

## A12 — Pair pulse

**Pitanje:** Dok držiš chip, isti tip+tier treperi?

| Opcija | |
|--------|--|
| A | Da, **u istom tracku** kao combo. |
| B | Da, ali zaseban mali slice poslije. |
| C | Ne. |

**Odgovor (2026-08-20):** **A**. Pulse partnera dok držiš chip; ide u combo slice, ne kasnije.

---

## A13 — Sort by type

**Pitanje:** Spec pita za Sort. Trebamo li ga u ARENA-01?

| Opcija | |
|--------|--|
| A | Gumb Sort — skupi iste tipove u grozdove. |
| B | Auto-sort pri pouru. |
| C | Ne u ovom tracku. |

**Odgovor (2026-08-20):** **C**. Playfield ostaje rasut. Nema Sort gumba ni auto-grozda.

---

## A14 — Clutter / pour količina

**Pitanje:** `ARENA_MAX_CHIPS` = 40. Mijenjati?

| Opcija | |
|--------|--|
| A | Ostavi 40. |
| B | Smanji na ~24 (stari spec draft). |
| C | Pour u valovima: prvo 8–12, tap again. |

**Odgovor (2026-08-20):** **D (custom, chat).** Cap ostaje **40**. Kad broj chipova na polju padne na **10**, vreća se **sama** istrese do 40 (ili dok bag ne ostane prazan). Ciklus do kraja sjemena za taj run. Nije ručni tap za svaki val.

---

## A15 — Pour sadržaj

**Pitanje:** Što izlazi iz vreće na polje?

| Opcija | |
|--------|--|
| A | Random mix kao sad. |
| B | Preferiraj tipove koji već imaju para / orphan na polju. |
| C | Igrač bira koji tip iz vreće izlazi (Camp-like select). |

**Odgovor (2026-08-20):** **B**. Auto-refill (A14 D) i prvi pour guraju tipove koji već imaju 1 na polju, ako bag to ima.

---

## A16 — Muncher vs combo

**Pitanje:** Kako pest živi uz combo HUD? Ako A1=B/D, **C je u konfliktu** (extra freeze treba pest hook).

| Opcija | |
|--------|--|
| A | Pest ostaje pritisak; jede = lomi combo (ako A3 to kaže). |
| B | T3 freeze + combo freeze se **slažu** (duži freeze na visokom combu). |
| C | U ovom tracku pest **ne dirati** (samo combo/cliff/daily). |

**Odgovor (2026-08-20):** **A**. T3 freeze ostaje 2 s. Combo nagrada = coins (A1 C), ne freeze. Pest FSM se ne širi.

---

## A17 — Muncher kao igračka

**Pitanje:** Katalog C. Novi verb?

| Opcija | |
|--------|--|
| A | **Ne sada.** |
| B | Nahrani 1 T1 namjerno → sitni bonus (ne P2W). |
| C | Cozy: pest spava dok ne uključiš „challenge“. |

**Odgovor (2026-08-20):** **A**. Muncher ostaje štetočina. Nema feed, nema cozy toggle.

---

## A18 — Pip u areni

**Pitanje:** Treba li Pip na playfieldu?

| Opcija | |
|--------|--|
| A | Nema Pipa (focus na sjeme). |
| B | Mali Pip na rubu, reakcija na combo/T3. |
| C | Pip drži vreću (kozmetika bag-a). |

**Odgovor (2026-08-20):** **B**. Kozmetika/reakcija; nije kolizija, nije eat target.

---

## A19 — Vizualni napredak u areni

**Pitanje:** Mijenja li se playfield BG tijekom sesije?

| Opcija | |
|--------|--|
| A | Playfield BG se **ne** mijenja. |
| B | Lagani „livada cvjeta“ tint s brojem T3 u sesiji. |
| C | Trajni kamp vizual; arena ostaje playground. |

**Odgovor (2026-08-20):** **B**. Sesijski tint; reset na Done. Nije trajni kamp vizual.

---

## A20 — Score

**Pitanje:** Osim combo broja, ima li zbroja? Nema leaderboarda.

| Opcija | |
|--------|--|
| A | Nema scorea — samo combo broj. |
| B | Sesijski score (merges × combo), nestaje na Done. |
| C | Best combo u saveu (personal best). |

**Odgovor (2026-08-20):** **A**. Nema sesijskog zbroja ni best-combo savea.

---

## A21 — Tajmer / runde

**Pitanje:** Ima li vremenskog pritiska osim Munchera?

| Opcija | |
|--------|--|
| A | **Bez** tajmera (cozy sandbox + ciljevi). |
| B | Opcionalni „hurry“ 30 s bonus, default off. |
| C | Svaki pour je mini-runda. |

**Odgovor (2026-08-20):** **A**. Auto-refill nije runda. Done slobodan.

---

## A22 — Auto-chain

**Pitanje:** T1+T1 = T2; ako je drugi T2 blizu, magnet ga privuče sam?

| Opcija | |
|--------|--|
| A | Ne — svaki merge ručni. |
| B | Da, kratki chain (osjećaj comba). |
| C | Samo kad je combo već ≥3. |

**Odgovor (2026-08-20):** **A**. Nema T1→T3 lanca u jednom pokretu. Combo 5 traži pet ručnih snapova u ~1.5 s prozoru — pulse (A12) je bitan.

---

## A23 — Merge Hint booster vs combo

**Pitanje:** Što radi postojeći Merge Hint uz nove ciljeve?

| Opcija | |
|--------|--|
| A | Hint i dalje samo tekst; combo nezavisan. |
| B | Hint vizualno pulsea par (ako A12 da). |
| C | Hint pauzira pest 3 s (jači consumable — core i dalje free). |

**Odgovor (2026-08-20):** **A** + parking. Hint ostaje kao danas (tekst). Combo nezavisan. Ewentualno izbacivanje Hint IAP-a **nije** ARENA-01.

---

## A24 — Duljina zabavne sesije

**Pitanje:** Koliko dugo arena treba biti zabavna u jednom ulazu? Nije tvrdi tajmer.

| Opcija | |
|--------|--|
| A | 20–40 s (brzi merge pa Play). |
| B | 1–2 min (isprazni bag). |
| C | Oba: prvi pour zadovoljava, ostatak opcionalan. |

**Odgovor (2026-08-20):** **C**. Done uvijek OK. Auto-refill ne tera da ostaneš do praznog baga.

---

## A25 — Odd leftover T1 / T2

**Pitanje:** Što s nesparenim sjemenom?

| Opcija | |
|--------|--|
| A | Status quo (Done reciklira T1; T2 tap spend). |
| B | „Trade leftover“ 3 odd T1 → 1 coin u areni. |
| C | Odd T1 se sami vrate u bag bez Done. |

**Odgovor (2026-08-20):** **A**. Nema trade 3 T1→coin. Nema auto-return T1 prije Done.

---

## A26 — Tutorial za combo

**Pitanje:** Kako igrač sazna da combo postoji? Ne novi `tutorial_*` korak.

| Opcija | |
|--------|--|
| A | Jedna nova rečenica („Merge brzo za combo“). |
| B | Prvi combo = kratki toast, bez novog koraka. |
| C | Ništa; igrač otkrije sam. |

**Odgovor (2026-08-20):** **C**. Combo broj + pulse dovoljni. Nema nove rečenice, nema toast flaga.

---

## A27 — Audio

**Pitanje:** SFX za combo u ovom tracku?

| Opcija | |
|--------|--|
| A | Pitch-up ding po combu (D0-P ili uz combo). |
| B | Isti merge SFX, bez pitcha. |
| C | Odgodi audio; ovaj track samo HUD/logika. |

**Odgovor (2026-08-20):** **A, kasnije.** Pitch-up je odluka. ARENA-01 kod **ne** radi audio; ide u globalni SFX pass (kraj igre / D0-P).

---

## A28 — Monetizacija uz ciljeve

**Pitanje:** Nova plaćanja / ads u areni?

| Opcija | |
|--------|--|
| A | **Ništa novo.** Daily/combo free. |
| B | Rewarded: freeze pest 5 s na pauzi (prazno polje / Done). |
| C | IAP „combo shield“ — **ne preporučujem** (pay-to-merge feel). |

**Odgovor (2026-08-20):** **A**. Nema rewarded freeze, nema combo shield IAP.

---

## A29 — Interstitial na izlazu iz Arene

**Pitanje:** Spec: ne bez A/B.

| Opcija | |
|--------|--|
| A | **Ne.** |
| B | Parkiraj za post-launch A/B, ne u ARENA-01 kodu. |

**Odgovor (2026-08-20):** **B**. Ovaj track ne stavlja ad na Done. Ideja ostaje u parking lotu.

---

## A30 — Mythic / ★★★ u istoj areni

**Pitanje:** Diramo li rarity u ovom tracku?

| Opcija | |
|--------|--|
| A | Status quo (isti playfield, merge samo isti tip). |
| B | Zlatni outline + mythic **ne** ulaze u combo. |
| C | Ne dirati u ovom tracku. |

**Odgovor (2026-08-20):** **C**. Nema zlatnog outline koda, nema combo izuzetka za mythic.

---

## A31 — Ime na HUD-u

**Pitanje:** Engleski copy za broj (UI je EN).

| Opcija | |
|--------|--|
| A | `Combo` |
| B | `Streak` |
| C | `Bloom chain` |

**Odgovor (2026-08-20):** **A**. HUD: `Combo` + broj.

---

## A32 — Prioritet sliceova ako ne stane sve

**Pitanje:** Redoslijed koda nakon freezea (default plan: combo → cliff → daily).

| Opcija | |
|--------|--|
| A | Combo prvo, cliff, daily zadnje. |
| B | Cliff prvo (Pillar 3), combo, daily. |
| C | Daily prvo (retention), combo, cliff. |

**Odgovor (2026-08-20):** **A** (preporuka agenta, prihvaćena). Prvi kod: Combo HUD + pulse + auto-refill na 10 + leftover T2→2×T1. Daily progress/badge zadnji slice. Camp cliff nije novi arena PR.

---

## A33 — Što iz B/C kataloga obavezno u prvi kod

**Pitanje:** Uz ciljeve, što mora u prvi PR?

| Opcija | |
|--------|--|
| A | **Ništa** — čisti A (combo/cliff/daily). |
| B | Pair pulse (A12) jer combo bez nje je slijep. |
| C | T2 inbox (A10 B) jer T2 chore ubija tempo comba. |

Možeš reći **B i C** ako oba; to su dva slicea, ne jedan PR.

**Odgovor (2026-08-20):** **B** (preporuka, prihvaćena). Usklađeno s A12 A. T2 inbox (C) ne vrijedi. Prvi combo PR uključuje pulse.

---

## A34 — Playtest prije koda

**Pitanje:** Kad smije prvi `game/` slice?

| Opcija | |
|--------|--|
| A | Docs freeze pa odmah P0+A kod (P0 = ovi docovi). |
| B | Najprije ti 5 min u editoru s checklistom (što dosadi), pa freeze. |
| C | Docs sada; kod tek nakon D0-P. |

**Odgovor (2026-08-20):** **A**. Docs su P0. Sljedeći chat može biti Plan prompt za combo slice. Nije obavezan 5-min playtest gate; nije čekanje na D0-P.

---

## A35 — Još nešto što lista ne pokriva

**Pitanje:** Slobodan tekst. Što fali u areni što A1–A34 ne pitaju? (npr. sjeme skače, mrziš Munchera, arena kao vrt, …)

**Odgovor (2026-08-20):** **A**. Lista dovoljna. Freeze A0–A35 zatvoren.

---

## Agent — bilježenje

**Freeze 2026-08-20:** A0–A35 popunjeni. Hub: [[ideje-arena|ARENA-01]]. Prompti: [[../06-production/plan-prompts-arena|plan-prompts-arena]] (COMB-A prvo). Kanon spec se i dalje ne prepisuje dok korisnik ne kaže „dodaj u scope“.

## Povezano

- [[ideje-arena|hub]] · [[ideje-arena-grupe|grupe]] · [[ideje-arena-ciljevi|ciljevi]] · [[ideje-arena-feel|feel]] · [[ideje-arena-bloom|bloom]] · [[ideje-arena-pest|pest]]
- [[../06-production/plan-prompts-arena|prompti]]
- [[../06-production/CHECKPOINT|CHECKPOINT]]
