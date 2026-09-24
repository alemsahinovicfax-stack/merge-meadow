---
type: dizajn
status: aktivan
milestone: "—"
tags: [dizajn, ui, journal, claude-design, mockup, test]
povezano:
  - ../../02-design/spec-vertical-slice
  - ../ui-i-art-alati
  - ../art-direction
  - ../../06-production/CHECKPOINT
ai_sažetak: "Journal (Bloom Album) spec + prompt za Claude Design; CD paket `design_handoff_journal/` (smjer 1a) prenesen u igru 2026-09-23 — vidi § Implementacija."
---

# Journal (Bloom Album) — spec + Claude Design brief

> **Status: implementirano 2026-09-23** — smjer 1a (Varijanta A, pastel hub) iz CD paketa `design_handoff_journal/`; vidi [§ Implementacija](#implementacija-2026-09-23) i [[journal-izvjestaj|izvještaj]].
>
> **Prvobitno: eksperiment.** Ovo NIJE bio dio tadašnjeg CHECKPOINT koraka (D0-P / CAMP-06) i ne mijenja kod u `game/`. Cilj je testirati da li jedan ovako napisan dokument daje Claude Designu dovoljno da napravi koristan mockup za jedan ekran, prije nego se isto uradi za Shop/Home. Ako test uspije, ovaj format se ponavlja za ostale ekrane kao zaseban zadatak — ne automatski.

Ovaj dokument ima dva dijela:

1. **Spec** — tačno šta Journal ekran danas radi, u istom formatu kao Camp/Arena u [[../../02-design/spec-vertical-slice|spec-vertical-slice]] (kojeg taj dokument nema za Journal — vidi prošlu analizu u sesiji).
2. **Prompt za Claude Design** — gotov tekst za copy-paste u CD, na kraju dokumenta.

---

## 1. Spec — Journal (kod danas)

**Scena:** `scenes/ui/collection_journal.tscn` · **skripte:** `scripts/ui/collection_journal.gd`, `collection_journal_row.gd`, `collection_bloom_icon.gd` · **podaci:** `GameState.get_collection_journal_entries()` (`scripts/autoload/game_state.gd`)

### Ulazne tačke

| Put | Kako |
|-----|------|
| Meta Hub tab | Index **1** od 5 (`Shop·Journal·Home·Camp·Arena`), swipe ili tab dugme, label "Journal" |
| Prečica iz Campa | `CollectionButton` (hub-chrome zona A, uvijek vidljiv na Camp stranici) → `GameState.go_to_collection_journal()` → skoči direktno na tab 1 |

Kad je stranica **embedded u hub** (što je uvijek u živom flow-u), vlastiti `BackButton` na Journalu je sakriven — navigacija ide preko hub tabova/swipea. `BackButton` postoji u sceni samo za standalone/dev pristup (vraća na Camp).

### Layout (odozgo prema dolje)

1. **Hub top bar** (nije dio Journal scene — dijeljen sa svih 5 stranica): coin ikona+broj, seed ikona+broj, diamond ikona+broj. Uvijek vidljiv iznad svake stranice huba.
2. **TopBar red** (unutar Journal scene): `BackButton` (home ikona, "subtle" varijanta, 52×52, sakriven u hub modu) + `TitleLabel` — tekst "Bloom Album", 34pt, boja fonta zavisi od opremljene kozmetike (vidi § Kozmetika ispod).
3. **SummaryLabel** — centriran red, npr. *"Album: 3 blooms kept · 5 spotted"* (`format_collection_journal_summary()`).
4. **ListScroll → List** — vertikalni scroll, jedan red (`CollectionJournalRow`) po tipu sjemena iz **svih sezona ikad viđenih** (`SeedCatalog.all_type_ids()`), ne fiksnih 6 — lista može biti duga i raste sa sezonama. Redovi se grade postupno (6/frame) da ne zamrzne UI.
5. **Pozadina:** tamno-zeleni `ColorRect` (`Color(0.15, 0.22, 0.17)`) preko cijele scene.

   > **Zapažanje (moje, ne iz dokumentacije):** ovo je jedina stranica huba koja koristi taman background — Camp/Shop/Home/Arena su na toplom pastelu po [[../art-direction|art-direction]] paleti (`#FFF8F0` warm white i sl.). Ovo je vjerovatno naslijeđe starije verzije UI-a prije nego je paleta standardizovana. Otvoreno je pitanje da li Journal treba ostati "tamnija, mood-ovita knjiga uspomena" namjerno, ili treba da prati pastel jezik ostatka huba — vidi prompt niže, tražim od CD da ponudi oba.

### Anatomija jednog reda (`CollectionJournalRow`)

| Element | Ponašanje |
|---------|-----------|
| Pozadina panela | Zaobljeni pravougaonik (10px radius, 2px border @16% opacity), boja po **rarity** (tabela ispod) |
| Naslovni red | Ime tipa (npr. "Clover") + opcionalni **NEW** badge (mala zaobljena pilula, terakota `#D95A47`-ish, samo ako `is_new`) |
| Zvjezdice | 1–3 `★` u prigušenoj zlatnoj (`#B89E33`-ish), broj = rarity |
| Red od 3 tier ikone | T1 / T2 / T3 kolone, svaka: mini ilustracija biljke (64×64, proceduralno crtana) + caption "T1"/"T2"/"T3" ispod. Otključan tier = puna boja ikone + zelena caption; zaključan = sivi prazan krug + siva caption |
| Caption red | Kontekstualan tekst po stanju (tabela ispod) |

**Boje po rarity** (`ui_palette.gd`, `rarity_bg_style`) — koristiti **tačno ove hex vrijednosti**, ne reinterpretirati:

| Rarity | Boja pozadine reda | Hex |
|--------|---------------------|-----|
| ★1 | Pastel plava | `#B8D4F0` |
| ★2 | Pastel lavanda | `#E0C4FF` |
| ★3 | Pastel zlatna | `#FFE8B8` |
| Locked (bilo koji rarity) | Neutralno siva | `#E4E4E0` |

### Stanja reda (`state` iz `get_collection_journal_entries()`)

| Stanje | Uvjet | Caption |
|--------|-------|---------|
| `locked` | Nije viđen, nije otkriven, `kept_tier == 0` | "Keep playing to discover this bloom." |
| `seen` | Otkriven u runu, ili `kept_tier ≥ 2`, ili (u sezonskom unlock lancu i spawn otključan) | "Spotted in runs — merge to T2, then Keep in Album." |
| `album_t2` | `kept_tier ≥ 2` | "In your Album (T2 bloom). Merge to T3 for crystal." |
| `album_t3` | `kept_tier ≥ 3` (max tier, "crystal") | "Crystal bloom saved in Album!" |

Kad je `is_new == true` (upravo otključano/podignuto), caption se **prepiše**: "New discovery!" / "New bloom kept in Album!" / "New crystal in Album!" ovisno o `new_tier`.

`is_new` se postavlja kad merge/donate podigne `kept_tier`, a **briše se u paketu** čim se Journal otvori (`mark_collection_journal_viewed()` čisti sve odjednom — nema per-red "viewed" praćenja).

### Poznata praznina u kodu (moje zapažanje, vrijedno za mockup)

`GameState` ima `has_collection_journal_news()` / `count_collection_journal_news()`, ali **ništa u hub tab baru ih ne koristi**. Jedino mjesto koje broji "news" je `collection_badge` na Camp stranici (`camp_controller.gd` `_refresh_collection_badge()`), i taj badge je eksplicitno sakriven kad je hub aktivan:

```
collection_badge.visible = news > 0 and not _meta_hub_embedded
```

Pošto igra danas **uvijek** radi unutar huba, ovaj badge je efektivno mrtav kod — igrač ga nikad ne vidi. Preporuka (moja, ne postojeća odluka): CD treba domoknuti mali notification-dot/broj na sam **"Journal" tab** u hub nav baru, jer je to jedini nav element koji igrač stvarno gleda. Ovo tražim od CD kao prijedlog, ne kao gotovu odluku — treba potvrda prije implementacije.

### Kozmetika (link na Shop)

`CosmeticCatalog.SLOT_JOURNAL_FRAME` — trenutno 1 SKU: **"journal_gold" / "Golden Album"**, 120 coins. Efekt: mijenja boju `TitleLabel` teksta iz default tople zlatne `(1, 0.92, 0.55)` u bogatiju zlatnu `(1, 0.88, 0.35)`. To je **samo boja teksta naslova** — nema vizuelnog okvira/rama oko panela uprkos imenu "frame".

> **Otvoreno pitanje za CD:** da li dizajnirati stvarni vizuelni okvir/traku oko cijelog ekrana kad je kozmetika opremljena (da opravda ime "frame"), ili ostaviti kao title-color-only efekat i preimenovati koncept kasnije? Ne odlučuj ovo — ponudi obje varijante kao opciju.

### "Gotovo kad" (definicija završenosti, isti format kao Camp/Arena)

- Lista renderuje sve tipove sjemena bez crasha, uključujući duge liste (višesezonski roster)
- Rarity boje tačno odgovaraju ★ tieru; locked red je vizuelno jasno drugačiji od unlocked
- Tier ikone: otključan/zaključan kontrast čitljiv i bez boje (oblik + siva vs boja — accessibility, vidi [[../pristupacnost|pristupačnost]])
- NEW badge se pojavljuje kad treba i nestaje odmah po otvaranju Journal-a
- Summary broj (kept/spotted) odgovara stvarnom broju redova u tim stanjima
- Prečica iz Campa (`CollectionButton`) ispravno doskoči na Journal tab

### Ograničenja za mockup (accessibility, iz [[../pristupacnost|pristupačnost]])

- Touch target min **44×44 pt** (redovi/badge nisu klikabilni danas, ali ako CD predloži interakciju, poštuj minimum)
- Ne oslanjati se samo na boju za razliku locked/unlocked — oblik (puna ikona vs prazan krug) mora nositi informaciju i bez boje
- Min font 14pt body, 18pt+ za ključne brojke

---

## 2. Prompt za Claude Design

> Kopiraj sve ispod ove linije direktno u Claude Design.

```
Radim mockup za jedan ekran mobilne igre (Merge Meadow — casual F2P merge/runner
hibrid, portrait, flat pastel cartoon art stil, bez pixel-arta). Ekran je "Journal"
(interno ime: Bloom Album) — jedan od 5 tabova u swipeable meta-hubu
(Shop · Journal · Home · Camp · Arena), otvoren na svom tabu.

CILJ: high-fidelity mockup ovog jednog ekrana, kao osnova za implementaciju u
Godot 4. Ne dizajniraj ostale 4 stranice huba — samo naslovnu traku huba (top bar)
u onoj mjeri u kojoj se Journal nalazi ispod nje, i sam tab bar na dnu ako ti
pomaže da pokažeš predloženu "NEW" oznaku (vidi zadatak 3 ispod).

STIL / PALETA (koristi tačno ove hex vrijednosti, ne izmišljaj nove):
- Primary: mint zelena #A8E6CF
- Secondary: lavanda #D4A5FF
- Pozadina (topla, "cozy" varijanta): warm white #FFF8F0
- Accent/CTA: peach #FFB88C
- Coin gold: #FFD56B
- UI tekst: soft charcoal #4A4A4A
- Outline: deep charcoal #2D3436 (outline uvijek ~20% tamniji od fill-a ispod sebe)
- Rarity boje redova: ★1 pastel plava #B8D4F0, ★2 pastel lavanda #E0C4FF,
  ★3 pastel zlatna #FFE8B8, locked (bilo koji rarity) neutralno siva #E4E4E0
Zaobljeni uglovi, soft drop shadow (nizak opacity, offset 2-4px), bez oštrih
ivica, bez pixel grida, bez retro efekata.

TRENUTNA IMPLEMENTACIJA (danas u kodu — tamna pozadina) koristi taman
zeleno-siv background (#26382B) za cijeli Journal ekran, dok su ostale 4
stranice huba na toplom pastelu (#FFF8F0 i sl.) iz palete iznad. Ovo je
vjerovatno nenamjerna nedosljednost iz ranije verzije UI-a.

ZADATAK 1 — glavni prikaz (scroll lista):
Napravi mockup liste "bloom" tipova, odozgo prema dolje:
- Top bar (hub-shared, dijeli ga svih 5 tabova): tri "chip"-a sa ikonom + brojem
  — coin, seed, diamond — poravnati desno ili centrirano gore.
- Naslov "Bloom Album" (veliki, upadljiv font, zlatna nijansa boje teksta).
- Kratak summary red ispod naslova, centriran, primjer teksta:
  "Album: 3 blooms kept · 5 spotted"
- Scrollable lista "redova", svaki red je kartica sa:
  - Pozadina obojena po rarity (vidi hex gore) — jasno vizuelno drugačija boja
    za locked (siva) vs bilo koji unlocked rarity.
  - Ime bilja (npr. "Clover", "Tulip", "Sunflower") + zvjezdice (1-3, prigušena
    zlatna boja) pored imena.
  - Opcionalni mali "NEW" badge (zaobljena pilula, topla terakota boja) u
    gornjem desnom uglu kartice — pokaži bar jedan red SA badge-om i ostale bez.
  - Red od 3 male ikone biljke (T1/T2/T3), svaka sa "T1"/"T2"/"T3" labelom ispod.
    Otključane ikone = puna boja + zelenkasta labela; zaključane = prazan sivi
    krug/placeholder + siva labela. NE dizajniraj detaljnu botaničku ilustraciju
    za ove ikone — dovoljan je jednostavan geometrijski placeholder (npr. krug/
    list oblik), pravu ilustraciju crta Godot kod proceduralno.
  - Jedan red kratkog opisnog teksta na dnu kartice (caption), primjeri:
    "Keep playing to discover this bloom." (locked)
    "Spotted in runs — merge to T2, then Keep in Album." (seen)
    "In your Album (T2 bloom). Merge to T3 for crystal." (album T2)
    "Crystal bloom saved in Album!" (album T3, najsvečaniji ton)
Pokaži mix od barem 6 redova: 1-2 locked, 1-2 seen, 1 album T2, 1 album T3, i
bar jedan od njih sa NEW badge-om.

ZADATAK 2 — dvije varijante pozadine:
Napravi VARIJANTU A (topla, pastel, dosljedna ostatku huba — warm white #FFF8F0
kao baza) i VARIJANTU B (trenutna tamnija, "cozy knjiga uspomena" atmosfera —
tamno zelena baza, ali s poboljšanim kontrastom i pastel akcentima na karticama
da ne izgleda mračno). Ne biraj umjesto mene — želim vidjeti obje pa odlučiti.

ZADATAK 3 — prijedlog "NEW" indikatora na tab baru:
U kodu postoji brojač nepregledanih otkrića koji se trenutno nigdje ne
prikazuje igraču. Predloži kompaktan notification-dot ili mali brojčani badge
na "Journal" tabu/dugmetu u hub navigaciji (dno ekrana), koji signalizira da
ima novih otkrića. Ovo je prijedlog za razmatranje, ne finalna odluka — po
mogućnosti pokaži 2 varijante (dot vs. broj u pilul).

ZADATAK 4 — kozmetika naslova (opciono, niži prioritet):
Postoji kupovni "Golden Album" cosmetic koji danas samo mijenja boju teksta
naslova u bogatiju zlatnu. Predloži i alternativu gdje taj cosmetic dodaje
vizuelni okvir/traku oko cijelog ekrana (da opravda ime "frame") — samo kao
opcija za poređenje, ne mijenjaj default izgled.

OGRANIČENJA:
- Portrait mobilni format (osnovna referenca 1080×1920, ali mockup ne mora
  biti piksel-precizan, samo proporcionalno tačan).
- Touch-friendly razmaci (minimalni tap target ~44×44pt ekvivalent).
- Ne oslanjaj se samo na boju za locked/unlocked razliku — oblik (puna ikona
  vs prazan krug) mora nositi informaciju i za colorblind korisnike.
- Ne dizajniraj Shop, Home, Camp ili Arena stranice — fokus isključivo na
  Journal, plus minimalni djelovi huba (top bar, tab bar) potrebni za kontekst.
- Ne izmišljaj nove funkcije/dugmad koje nisu tražene gore (npr. filter,
  search, sortiranje) — ako imaš ideju za to, navedi je kao odvojen prijedlog
  na kraju, ne kao dio glavnog mockupa.

IZLAZ: statični artboard(i) su dovoljni, ne treba interaktivnost. Ako praviš
više varijanti (zadatak 2 i 3), jasno ih labeliraj (Varijanta A/B, Opcija 1/2)
da ih mogu uporediti jednu pored druge.
```

---

## Implementacija (2026-09-23)

Izvor: `design_handoff_journal/` (README, `godot/ui_journal.gd`, `godot/journal_tree.txt`, `design/*.dc.html`). Odabran smjer **1a — Varijanta A, pastel hub**.

| Fajl | Šta |
|------|-----|
| `scripts/visual/ui_journal.gd` (`UiJournal`) | paste-ready iz paketa, nepromijenjen: boje, mjere, `row_style`, `tier_frame_style`, `tier_well_style`, `tier_halo_style`, `new_badge_style`, `album_page_style`, `golden_frame_style`, `golden_plaque_style`, `caption_for`, `summary_text`, `row_y` |
| `scenes/ui/collection_journal.tscn` | `PageHead` 175 (TitleAccent 10 × 56 + „Bloom Album“ + summary + divider) i `ListScroll` ispod; `GoldenPlaque`, `GoldenFrameEdge` / `GoldenFrameGold` za kozmetiku |
| `scripts/ui/collection_journal.gd` | posjeta: snapshot NEW-a prije `mark_collection_journal_viewed()`, sezonska poglavlja („N / 6 kept“ + lokot), lista se gradi 6 redova po frameu, auto-scroll na prvi NEW (`row_y` − 330), `on_meta_page_left()` gasi NEW |
| `scripts/ui/collection_journal_row.gd` | red 1032 × 200: ime + ★ (ime ide u ellipsis), caption 2 reda, tri slota 112 (prazan prsten · bloom well · T3 gold kvadrat), NEW pilula (28, −18) i halo na `new_tier` |
| `scripts/meta/meta_hub_controller.gd` | `_on_page_changed` javlja Journalu da je stranica napuštena |
| `assets/ui/chrome/icon_lock_ink.svg` (+ `.import`) | lokot u ink za svijetlu podlogu (zaglavlje zaključane sezone) |
| smoke | novi `journal_new_snapshot_smoke`; ažuriran `collection_journal_smoke` |

**Odstupanja od paketa:**

1. `godot/styles/*.tres` nisu kopirani — stilovi se prave iz `ui_journal.gd` u kodu (paket to nudi kao izbor).
2. `ListScroll` je `SHOW_NEVER` bez tankog grabbera iz paketa: lista se vuče prstom, bez trake.
3. Naslov je Label u Nunitu (font je u igri od Home v2), pa `title_bloom_album.png` nije trebalo re-bake-ovati.
4. Placeholderi `assets/tier/ph_*.svg` se ne koriste — cvijeće crta igra (`CampPlantDraw` / `FlowerAssets`), kako paket i predviđa.
5. NEW na tabu je opcija 1e (broj), koja je već radila prije prenosa; `tab_dot_style()` (1f) stoji neiskorišten.

**Otvorena pitanja iz paketa:** auto-scroll je uključen; sezonska poglavlja su uključena; Golden Album je frame + plaketa; redovi zaključanih sezona ostaju `???` uz lokot na zaglavlju.


## Povezano

- [[../../02-design/spec-vertical-slice|spec-vertical-slice]] — format po kojem je pisan § 1 (Camp/Arena imaju isti tretman, Shop/Home/Journal nemaju)
- [[../art-direction|art-direction]] — paleta, stil
- [[../ui-i-art-alati|ui-i-art-alati]] — kako se asset/dizajn prenosi u Godot nakon što mockup postoji
- [[../pristupacnost|pristupačnost]] — a11y ograničenja korištena gore
- [[../../06-production/CHECKPOINT|CHECKPOINT]] — trenutni koraci
- [[journal-izvjestaj|journal-izvjestaj]] — izvještaj o prenosu (2026-09-23)
