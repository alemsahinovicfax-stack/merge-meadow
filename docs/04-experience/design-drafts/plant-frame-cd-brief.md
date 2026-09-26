---
type: dizajn
status: aktivan
milestone: "—"
tags: [dizajn, ui, sjeme, cvijece, arena, journal, camp, run, claude-design, mockup]
povezano:
  - merge-arena-cd-brief
  - journal-cd-brief
  - camp-v2-cd-brief
  - run-cd-brief
  - seeds-flowers-cd-brief
  - art-direction
  - pristupacnost
  - CHECKPOINT
ai_sažetak: "Brief za Claude Design: kako sjeme i cvijet sjede u okviru — tanji krem rub i deblji merge-hint u Areni, journal i camp bez tamnozelenog wella i s biljkom koja puni okvir (journal bez T1/T2/T3 natpisa), run bez okvira."
---

# Sjeme i cvijet u okviru — Claude Design brief

> Nije novi ekran. Isti crtež biljke već postoji; ovdje se mijenja **okvir oko njega** na četiri mjesta: Arena, Journal, Camp i Run. Sve što ovdje nije spomenuto ostaje kako jeste.

Igrač spaja sjemenke u Areni, gleda iste biljke u Journalu i Campu, i skuplja ih u runu. Danas okvir jede crtež: bijeli rub je predebeo, tamnozelena podloga ne ide uz karticu, a sama biljka — posebno T1 — ostaje mala u sredini.

## 0. Kako koristiti ovaj fajl

| Ko | Šta čita | Zašto |
|----|----------|-------|
| **Claude Design** | cijeli fajl (§1–§8) | Šta se mijenja, šta ostaje fiksno, mjere i isporuka |
| **Ti** | §9 | Gotov prompt za copy-paste u CD chat |
| **Agent (kasnije)** | §3, §4, §10 | Današnje vrijednosti i mapa „CD sloj → Godot" |

**Prije slanja prompta: commitaj i pushaj na `master`** — CD čita fajlove iz repoa po tačnoj putanji (ne može listati foldere, zato su putanje u promptu ispisane do kraja).

## 1. Zašto

Igrač, doslovno:

- U **Areni**, dok spaja, bijeli okvir oko sjemenke je predebeo. Hint — prsten koji se pojavi na istim sjemenkama — jedva se vidi od tog bijelog ruba. Debljina je problem (kontrast je sporedan). Sjeme i cvijet unutra treba da budu **samo malo veći**. Okvir u Areni ostaje: on pokazuje šta se može spojiti.
- U **Journalu i Campu** tamnozelena podloga ispod biljke ne ide uz elemente oko nje. Cvijet ne puni okvir, staje otprilike na pola, pa se jedva vidi. U Journalu ispod ikona stoji natpis T1, T2, T3 — to ide van. Okvir i biljka u njemu rastu tako da biljka ispuni okvir; ne mora do samog ruba. T2 i T3 nisu loši. **T1 je premalen**, skoro se ne vidi.
- U **runu** je isti problem najgori: okvir predebeo, sjemenke se ne razlikuju. Okvir tamo **ide van u cijelosti**. U runu nema spajanja, pa okvir nema posla.

## 2. Pravila koja ostaju FIKSNA

Brojevi igre se **ne diraju**. Mijenja se samo kako biljka sjedi u okviru.

| Pravilo | Vrijednost |
|---|---|
| Crtež biljke | postojeći SVG / proceduralni crtež. **Nema novog arta cvijeta.** |
| Arena — veličina čipa | promjer **134 px** (`48 × 1.4`). Razmak, magnet i spawn rešetka ovise o njemu. Raste rub i biljka unutra, ne cijeli čip. |
| Arena — T1 / T2 | T1 je krug, T2 zaobljeni kvadrat s tankim unutrašnjim prstenom. ★3 (mythic) je zlatni rub. To razlikovanje ostaje. |
| Arena — T3 | kristal **nema** ovaj okvir; odleti sa polja. Ne dodavati mu čip. |
| Arena — hint | dok držiš sjemenku, **iste** (isti tip i tier) dobiju prsten. To je hint. Magnet koji privuče par dobije isti jezik debljine. |
| Journal — tri slota | i dalje tri mjesta po redu (prazno / viđeno / T2 u albumu / T3 kristal). Prazan slot je prsten, ne sivi krug. |
| Journal — bez teksta T1/T2/T3 | tier se i dalje čita iz oblika: danas prazan prsten, krem krug, zlatni zaobljeni kvadrat za kristal. Smiješ zadržati taj jezik. |
| Camp — kartica | **489 × 176** ostaje. Sjeme = krem krug, cvijet = zlatni zaobljeni kvadrat. |
| Run — kolizija | radius **26 px** ostaje. Crtež smije biti veći od pogotka, kao i danas. |
| Run — rijetkost | ★1 nema pip, ★2 ima dva, ★3 ima tri. Broj pipa ostaje čitljiv i kad okvira nema. |
| Run — samo T1 | u runu padaju sadnice (tier 1), ne cvijet i ne kristal. |

## 3. Zašto biljka danas izgleda mala

Okvir nije jedini krivac. SVG je nacrtan na platnu **256 × 256**, a biljka ne puni platno — T1 sadnica sjedi nisko i zauzima manji dio od T2/T3. Igra to platno rasteže u kutiju (`FLOWER_SIZE` u Areni, `ART` u Journalu), pa prazan dio platna postane prazan dio okvira.

U Journalu i runu ide još jedan korak: `draw_fitted_plant` skalira crtež na **36 %** kutije (`FIT_FRAC = 0.36`). Zato T1 u slotu od 112 px skoro nestane.

**Za dizajn:** nacrtaj biljku onako kako treba da izgleda u okviru — kao da crtež puni kutiju koju zadaš. Pri prenosu igra odreže prazan dio SVG-a i skalira crtež u tu kutiju. Ti zadaješ **vidljivu** veličinu biljke i marginu do ruba, ne „još 4 px na staru kutiju".

## 4. Šta se mijenja

Tačke su **obavezne**. Kako će izgledati poslije — tvoja odluka. Jedan jezik na sva četiri mjesta, s razlikom koju igrač traži: Arena zadržava okvir, run ga gubi.

### 4.1 Arena

1. **Krem rub tanji.** Danas vidljivi cream pojas je 14 px na T1 (`RIM_BORDER` 3 + `RIM_BAND_T1` 11) i 18 px na T2 (3 + 15). Rub guta čip.
2. **Hint deblji od tog ruba.** Prsten na istim sjemenkama je danas 6 px (`Ring.PULSE`, zlatni `#F2D940`) i gubi se na bijelom. Magnet-partner je 7 px. Poslije hint mora biti **deblji od krem ruba**, da se vidi dok se drži par. Boja može ostati zlatna; debljina je zahtjev.
3. **Biljka samo malo veća**, i dalje s marginom do ruba. Ne do ivice čipa. T1 kutija je danas 78 px, T2 84 px, ali zbog praznog platna (§3) sadnica izgleda manja od toga.

Tamni well u Areni (`#22342A`) smije ostati — on nosi kontrast cvijeta na livadi. Ako ga mijenjaš, napiši zašto u README § Odlučeno.

### 4.2 Journal

4. **Izbaci natpise T1, T2, T3** ispod slotova (danas font 32 px, razmak 8 px).
5. **Povećaj okvir.** Red je 1032 × 200. Slot je 112 px, pa ispod njega natpis. Kad natpis ode, ta visina može postati okvir — red ne mora rasti. Tri slota i dalje stanu desno, ime i caption lijevo.
6. **Biljka puni okvir**, s malo daha do ruba. T2 i T3 su danas podnošljivi; **T1 mora sustići njih**, da sadnica bude prepoznatljiva.
7. **Tamnozeleni well ide van** (`#22342A` u slotu). Ne ide uz pastel kartice reda (plava / ljubičasta / zlatna po rijetkosti). Podloga biljke treba da pripada kartici i okviru, ne livadi.

### 4.3 Camp

8. **Isti problem kao u Journalu:** well `#22342A` unutar krem/zlatnog okvira, biljka puni otprilike pola. Kartica ostaje 489 × 176. Okvir je danas 128 px, crtež 96 (sjeme) / 100 (cvijet) — i to prije praznog platna.
9. Isti jezik okvira kao u Journalu (krem krug za sjeme, zlatni zaobljeni kvadrat za cvijet), da Camp i Album izgledaju kao ista stvar.
10. Trade bar (okvir 104, crtež 80 / 84) i mala ikona na kartici sezone (okvir 56, crtež 40) dijele isti `CampArtFrame`. Povedi ih istim pravilom, u njihovoj veličini: bez zelenog wella, biljka puni okvir.

### 4.4 Run

11. **Okvir skroz van:** krem krug 120 px, rub 4 px, tamni well 84 px. Ostaje sjena na tlu (ona nije okvir).
12. **Sadnica je cijeli pickup** i mora se razlikovati od druge (djetelina, tratinčica, tulipan…). Veličina crteža otprilike kao današnjih 120 px, da staza ne postane tijesnija — ali to je biljka, ne biljka izgubljena u krugu.
13. **Pipovi rijetkosti** (dva ili tri, 16 px, danas na rubu kruga) nađu novo mjesto uz sadnicu. ★1 i dalje nema pip.

### 4.5 Današnje mjere (orijentacija)

| Mjesto | Okvir | Podloga | Crtež koji kod zadaje | Šta igrač vidi |
|---|---|---|---|---|
| Arena T1 | promjer 134, cream pojas 14 px | well `#22342A` | kutija 78 px | sadnica u donjem dijelu kutije |
| Arena T2 | isti promjer, cream 18 px + unutrašnji prsten 3 px | isti well | kutija 84 px | cvijet veći od T1, i dalje s prazninom |
| Arena hint | prsten 6 px izvan čipa | — | — | tanji od bijelog ruba |
| Journal slot | 112 px, rub 3 px | well `#22342A`, uvučen 10 px | `ART` 88, pa × 0,36 | T1 skoro tačka; ispod piše T1/T2/T3 |
| Camp kartica | okvir 128 u kartici 489 × 176 | isti well, uvučen 8 px | 96 / 100 px | otprilike pola okvira |
| Run | krug 120, rub 4 px | well 84 px | kutija 76, pa × 0,36 | okvir, u njemu mala sadnica |

Boje okvira: cream `#FFF8F0`, rub `#CBC2B6`, zlato čipa `#FFD56B` / rub `#D6A82F`, hint `#F2D940`, well `#22342A` / rub `#16211B`.

## 5. Paleta

Koristi postojeće tokene, ne novu paletu.

- Arena: `game/scripts/visual/ui_arena.gd`
- Journal: `game/scripts/visual/ui_journal.gd`
- Camp: `game/scripts/visual/ui_camp.gd`
- Run: `game/scripts/visual/ui_run.gd`

Warm white `#FFF8F0` · ink `#2D3436` · coin gold `#FFD56B` · gold edge `#D6A82F`. Journal redovi već imaju pozadinu po rijetkosti (`UiPalette.rarity_bg_color`). Camp kartica isto. Nova boja samo ako je svjetlija ili tamnija varijanta postojeće, i označena u README.

Oblik: ravna boja, radius, rub, jedna sjena. Tekst koji ostane ≥ 34 px. Kontrast teksta ≥ 4,5:1 prema svojoj podlozi. Arena čip ostaje dovoljno velik za prst (promjer 134).

## 6. Tehnička ograničenja (Godot 4.7, OpenGL, slabiji Android)

- Artboard **1080 × 1920**. Hub stranica između headera (143) i footera (144) je 1633 px. Run je puni ekran, bez headera.
- Paneli = ravna boja (+ alpha), radius, rub, **jedna** sjena. Bez blura, gradijenata na panelima i 3D-a.
- Animacije = tween. Hint u Areni smije pulsirati (danas već pulsira), jedan ritam, bez čestica.
- Biljku crta igra. U mockupu koristi postojeće crteže kao da pune kutiju koju zadaš:
  - `game/assets/sprites/flowers/clover_t1.svg`, `daisy_t1.svg`, `tulip_t1.svg` (i `_t2`, `_t3` za Journal/Camp)
  - placeholderi `design_handoff_home_field_v2/design/flowers/ph_*.svg` ako ti trebaju na ekranu
- Ne diraj `FIT_FRAC` na Home polju, korpi i biranju sezone — ta mjesta nisu u ovom zadatku.

## 7. Isporuka

### 7.1 Stanja koja moraju biti nacrtana

1. **Arena, mir.** Tri T1 čipa različitog tipa (djetelina, tratinčica, tulipan) i jedan T2, na livadi. Rub tanji, biljka malo veća, margina do ruba vidljiva.
2. **Arena, hint.** Držiš jednu djetelinu; ostale djeteline istog tiera imaju prsten **deblji od krem ruba**. Tuđi tip nema prsten.
3. **Journal.** Četiri reda: locked, samo T1 (seen), T2 u albumu, T3 kristal. Bez natpisa T1/T2/T3. T1 čitljiv. Nema zelene podloge. Prazan slot je prsten.
4. **Camp.** Jedna kartica sjemena i jedna kartica cvijeta, ista kartica 489 × 176, biljka puni okvir, podloga okvira ide uz karticu.
5. **Run.** Četiri sadnice na stazi, bez kruga: dvije ★1 različitog tipa, jedna ★2, jedna ★3. Razlika tipa se vidi. Pipovi rijetkosti se vide. Sjenu na tlu zadrži.

### 7.2 Paket (tačna struktura)

Daj **zip za preuzimanje u chatu** s cijelim folderom.

```
design_handoff_plant_frame/
  README.md                   šta otvoriti · § Odlučeno (tvoje odluke, 1 rečenica
                              svaka) · § Šta se briše · § Ideje van zadatka
  design/
    PlantFrame.dc.html        četiri konteksta; prop `scene` bira stanje iz 7.1
    PlantFrame Specs.dc.html  anatomija: Arena čip (mir / hint / T2), Journal slot
                              (prazan / T1 / T2 / T3), Camp art, Run sadnica s pipovima.
                              Tabela mjera u px baze 1080.
    support.js
  godot/
    plant_frame_export.json   meta · tokens · components · scenes · animations ·
                              decisions. Komponente: ArenaChip, ArenaHint, JournalSlot,
                              CampArt, RunSeed.
    plant_frame.gd            NISU nova skripta za igru. Popis novih vrijednosti
                              postojećih konstanti, grupisano po fajlu
                              (UiArena, UiJournal, UiCamp, UiRun) — isti nazivi
                              kao u kodu (RIM_BAND_T1, FLOWER_SIZE_T1, SLOT, ART,
                              CHIP_ART_SEED, CHIP_ART_FLOWER, SEED_SIZE, …).
    README.md                 red prenosa + šta se briše (T natpisi, well, run okvir)
```

**Imena slojeva** (za mapiranje, §10): `ArenaChip`, `ArenaRim`, `ArenaWell`, `ArenaPlant`, `ArenaHint`, `JournalRow`, `JournalSlot`, `JournalPlant`, `CampChip`, `CampArt`, `CampPlant`, `RunSeed`, `RunPlant`, `RunPips`.

## 8. Ne tražimo

- Novi crtež cvijeta (to je [[seeds-flowers-cd-brief|seeds-flowers-cd-brief]]).
- Home polje, korpu, biranje sezone, Shop, header i footer.
- Promjenu promjera arena čipa, kolizije u runu, ekonomije, merge pravila.
- Više varijanti za biranje — jedan dizajn.
- Da run dobije okvir „ali tanji". Okvir u runu ne postoji.

## 9. Prompt za Claude Design

> Kopiraj sve iz bloka ispod u CD. **Prije toga commitaj i pushaj** (vidi §0).

```
Radim izmjenu jednog vizuelnog jezika u mobilnoj igri, na četiri mjesta:
kako SJEME i CVIJET sjede u OKVIRU.

Igra: Merge Meadow — casual F2P merge/runner hibrid, portrait, flat pastel
cartoon (bez pixel-arta, bez 3D). Mood: cozy livada.

Tvoja referenca je jedan fajl u repou (master), pročitaj ga po ovoj tačnoj
putanji:
  docs/04-experience/design-drafts/plant-frame-cd-brief.md
Ako se ovaj prompt i fajl razlikuju, važi fajl. §10 je za kasniji prenos i
možeš ga preskočiti.

Kontekst (isti svijet, ne precrtavaj ove ekrane — samo vidi jezik):
  design_handoff_merge_arena/          (Arena, čip sa cream rubom)
  design_handoff_journal/               (Bloom Album, tri slota)
  design_handoff_camp_v2/design/CampScreen.dc.html
  design_handoff_run/                   (staza, pickup)
  game/scripts/visual/ui_arena.gd
  game/scripts/visual/ui_journal.gd
  game/scripts/visual/ui_camp.gd
  game/scripts/visual/ui_run.gd
  game/assets/sprites/flowers/clover_t1.svg
  game/assets/sprites/flowers/daisy_t1.svg
  game/assets/sprites/flowers/tulip_t1.svg

TVOJ ZADATAK: okvir danas jede biljku. Igrač je rekao ovo, i to su obavezne
tačke (mjere i zašto T1 nestaje su u §3 i §4):

1. ARENA. Bijeli/krem okvir je predebeo (danas 14 px na T1, 18 px na T2).
   Hint — prsten na istim sjemenkama dok jednu držiš — je 6 px i jedva se
   vidi od tog ruba. Neka hint bude DEBLJI od krem ruba. Biljka unutra samo
   MALO veća, ne do ivice. Okvir u Areni OSTAJE (pokazuje šta se spaja).
   Promjer čipa ostaje 134 px. T3 kristal i dalje nema ovaj okvir.

2. JOURNAL i CAMP. Tamnozelena podloga (#22342A) ne ide uz karticu oko nje.
   Biljka puni okvir otprilike do pola. Neka biljka ispuni okvir (ne mora do
   samog ruba). T2 i T3 su ok; T1 je premalen i mora se vidjeti.
   U Journalu IZBACI natpise T1, T2, T3 ispod ikona i povećaj okvir.
   Camp kartica ostaje 489 x 176.

3. RUN. Okvir skroz IZBACI (krem krug 120 px + tamni well). U runu nema
   spajanja. Sadnica mora biti prepoznatljiva — djetelina nije tratinčica.
   Rijetkost ostaje čitljiva: ★2 dva pipa, ★3 tri, ★1 nijedan. Kolizija
   ostaje radius 26. Sjenu na tlu zadrži.

JEDAN DIZAJN: ne pravi smjerove ni varijante za biranje. Kad imaš dilemu,
odluči sam i napiši razlog u jednoj rečenici u README § Odlučeno. Ne čekaj
moju potvrdu.

ZAŠTO JE BILJKA MALA: SVG je na platnu 256 x 256 i ne puni ga, a Journal i
run još skaliraju crtež na 36 % kutije. U mockupu nacrtaj biljku onako kako
treba da izgleda — kao da crtež puni kutiju koju zadaš. Igra će pri prenosu
odrezati prazan platno. Ne crtaj novi cvijet.

MORA OSTATI:
- Arena: T1 krug, T2 zaobljeni kvadrat, ★3 zlatni rub, tamni well smije
  ostati.
- Journal: tri slota, prazan je prsten; tier se čita bez teksta T1/T2/T3.
- Camp: krem krug = sjeme, zlatni kvadrat = cvijet; Trade bar i ikona na
  kartici sezone idu istim pravilom.
- Postojeće boje (cream #FFF8F0, zlato #FFD56B, ink #2D3436).
- Tekst koji ostane >= 34 px. Header 143 i footer 144 se ne diraju.

TEHNIČKI (Godot 4, OpenGL, slabiji Android): artboard 1080 x 1920, sve u px
baze (prenos 1:1). Paneli = ravna boja + alpha, radius, border, jedna sjena.
Bez blura, gradijenata na panelima i 3D-a.

ISPORUKA (§7): pet stanja iz §7.1 i paket TAČNO po strukturi iz §7.2 —
design_handoff_plant_frame/ s README.md, design/ (PlantFrame.dc.html,
PlantFrame Specs.dc.html, support.js) i godot/ (plant_frame_export.json,
plant_frame.gd s novim vrijednostima POSTOJEĆIH konstanti, README.md).
Na kraju mi daj ZIP ZA PREUZIMANJE u chatu s cijelim folderom.

IMENA SLOJEVA: ArenaChip, ArenaRim, ArenaWell, ArenaPlant, ArenaHint,
JournalRow, JournalSlot, JournalPlant, CampChip, CampArt, CampPlant,
RunSeed, RunPlant, RunPips.

NE RADI: novi art cvijeća, Home polje, korpu, Shop, header/footer, promjenu
promjera čipa ili kolizije u runu, tanji okvir u runu (tamo okvira nema).
Ideje van zadatka navedi odvojeno na kraju README-a.
```

## 10. Prenos u Godot (referenca za agenta — CD može preskočiti)

| CD sloj | Godot |
|---|---|
| `ArenaChip`, `ArenaRim`, `ArenaWell`, `ArenaPlant` | `game/scripts/visual/ui_arena.gd` (`RIM_BAND_*`, `RIM_BORDER`, `FLOWER_SIZE_*`) + `game/scripts/camp/arena_chip_draw.gd` `draw_chip` / `draw_flower` |
| `ArenaHint` | `arena_chip_draw.gd` `_draw_ring` (`Ring.PULSE` širina 6, `Ring.PARTNER` širina 7). Pulse pali `merge_arena_controller` na istom tipu i tieru dok se čip drži. |
| Veličina čipa | `arena_seed_chip.gd` `CHIP_RADIUS` (48 × 1.4) — ne dirati |
| `JournalSlot`, `JournalPlant` | `ui_journal.gd` (`SLOT`, `ART`, `WELL_INSET`) + `collection_journal_row.gd` + `collection_bloom_icon.gd` |
| Natpisi T1/T2/T3 | `collection_journal_row.gd` čvor `TierLabel` — briše se |
| Zeleni well u Journalu | `ArtWell` u istom redu + `UiJournal.tier_well_style` |
| `CampArt`, `CampPlant` | `camp_art_frame.gd` (crta well) + `UiCamp.CHIP_ART_*`, `TRADE_ART_*`, `SEASON_ART` |
| `RunSeed`, `RunPlant`, `RunPips` | `run/seed_visual.gd` `_draw` (krug + well + biljka + pipovi) + `UiRun.SEED_*`. Kolizija: `scenes/run/seed_pickup.tscn` `radius = 26` |
| Odrez platna | `camp_plant_draw.gd` `draw_fitted_plant` (`FIT_FRAC` 0.36) i `arena_chip_draw.gd` `draw_flower` (cijeli texture rect). Home, korpa i biranje sezone i dalje zovu `draw_fitted_plant` — njihove pozive ne mijenjati osim ako dijele helper čije ponašanje ostaje isto kad se ne preda nova kutija. |

Smoke koji prenos mora zadržati zelenim: `collection_journal_smoke`, `journal_new_snapshot_smoke`, `camp_layout_smoke`, `arena_redesign_smoke`, `run_redesign_smoke`.

## Povezano

- [[merge-arena-cd-brief|merge-arena-cd-brief]] — čip, cream rub, tamni well
- [[journal-cd-brief|journal-cd-brief]] — Bloom Album, tri slota
- [[camp-v2-cd-brief|camp-v2-cd-brief]] — kartica 489 × 176, art 128
- [[run-cd-brief|run-cd-brief]] — pickup na stazi
- [[seeds-flowers-cd-brief|seeds-flowers-cd-brief]] — art cvijeta, nije ovaj zadatak
- [[../../06-production/CHECKPOINT|CHECKPOINT]]
