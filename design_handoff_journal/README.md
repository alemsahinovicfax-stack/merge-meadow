# Handoff: Journal / Bloom Album

Dizajn iz Claude Designa za prenos u `scenes/ui/collection_journal.tscn`
(+ `collection_journal.gd`, `collection_journal_row.gd`). Prati Notion brief
„Journal / Bloom Album" i `docs/04-experience/design-drafts/journal-cd-brief.md`.

Pretpostavlja da je **hub chrome već prenesen** (`design_handoff_hub_chrome/`) —
Journal se uklapa u **1080 × 1597** između headera (143) i footera (180).
Header i footer se ne mijenjaju.

## Šta je ovo

**Fidelity: hi-fi za layout, mjere, boje, tipografiju i stanja; placeholder za art.**
Sve je mjereno u bazi 1080 × 1920, prenos 1:1. Cvijeće u mockupu je *pravo* što igra
danas crta (`assets/sprites/flowers/*.svg` za Country Bloom, `CampPlantDraw`
proceduralno za ostale sezone) — ali art nije dio ovog zadatka; oblik i veličina
slota (112 / art 88) su spec, crtež nije.

**HTML je referenca, ne kod za kopiranje.** Gradi se postojećim obrascima:
`StyleBoxFlat`, `PanelContainer`, `ui_palette.gd`, `ui_chrome.gd`. Bez shadera,
gradijenata i blura; najviše jedna sjena po elementu.

Odabran (preporuka): **1a — Varijanta A, pastel hub.** Varijanta B (1b, „knjiga
uspomena") je u dizajnu kao alternativa. Golden Album frame (1c / 1d) je kozmetika,
default isključen. NEW na Journal tabu: **1e — broj** (već implementiran), 1f tačka
kao alternativa.

| | 1a pastel hub | 1b memory book |
|---|---|---|
| Pozadina | `#FFF8F0` (kao danas) | `#2E4733` + krem stranica |
| Širina reda | **1032** | 992 |
| Naslov | Label u ink (PNG ima 1,8 : 1 na krem) | postojeći zlatni PNG radi (5,5 : 1) |
| Novi kontejneri | 0 | 1 panel + scroll unutra |
| Najduža imena | stanu | ellipsis (Paper Lantern Bloom) |

## Sadržaj paketa

| Fajl | Šta je | Gdje ide |
|---|---|---|
| `godot/ui_journal.gd` | **Paste-ready.** Boje, mjere, `row_style()`, `tier_frame_style()`, `tier_well_style()`, `tier_halo_style()`, `new_badge_style()`, `album_page_style()`, `golden_frame_style()`, `golden_plaque_style()`, `tab_dot_style()`, `caption_for()`, `summary_text()`, `row_y()`. | `game/scripts/visual/` |
| `godot/styles/*.tres` | 23 StyleBoxFlat resursa — isti brojevi kao `ui_journal.gd`, ako radije vežeš u sceni nego iz koda. | `game/assets/ui/journal/styles/` |
| `godot/journal_tree.txt` | Node tree sa veličinama, vertikalni i horizontalni lanac, razlike za B i GoldenFrame. | — |
| `assets/icons/` | `tab_journal.svg` / `_light` i `icon_lock.svg` (kopije, nepromijenjene), **`icon_lock_ink.svg`** (isti path u `#2D3436` za svijetlu podlogu). | `game/assets/ui/chrome/` |
| `assets/tier/` | `tier_empty`, `tier_frame_bloom`, `tier_frame_crystal`, `tier_new_halo` (referenca — u igri su StyleBoxFlat), `ph_tier_t1..t3` (placeholder art 88 px, **nije za produkciju**). | `game/assets/ui/journal/` |
| `assets/badge_new.svg`, `assets/tab_badge_dot.svg` | Referenca za NEW pilulu i tačku na tabu. Tekst u SVG-u je samo referenca — u Godotu je Label. | — |
| `design/Journal Redesign.dc.html` | **Sve na jednom mjestu:** danas u kodu, 1a, 1b, spec reda (4 stanja + 3 NEW), TierSlot, grayscale test, NEW na tabu (1e/1f), Golden Album (1c/1d), duga lista (48 tipova), odluke. Otvori u browseru. | — |
| `design/JournalScreen.dc.html` | Parametrizovan ekran (varijanta, golden, scroll, set podataka). | — |
| `design/BloomRow.dc.html` | Parametrizovan red (tip, rarity, stanje, new_tier, širina). | — |
| `design/JournalToday.dc.html` | Rekonstrukcija današnjeg ekrana iz koda (referenca). | — |
| `design/HubScreen.dc.html` · `support.js` · `icons/` · `flowers/` | Kopija hub chromea (nije mijenjana), runtime i asseti za dizajn fajlove. | — |

## Prenos — 7 koraka

### 1. `ui_journal.gd` + asseti
Kopiraj `godot/ui_journal.gd` u `game/scripts/visual/`. `icon_lock_ink.svg` u
`game/assets/ui/chrome/`, pa `scripts/godot-import.ps1` i commituj `.import`
(CLAUDE.md § Novi asset). Sve boje su postojeće (`ui_palette`, `ui_chrome`, Camp);
jedina „nova" je `CAPTION_INK #3F4547` = Camp ScrollHint.

### 2. Stranica — `collection_journal.tscn`
Vidi `journal_tree.txt`. Ukratko (A):

| Sloj | y | h |
|---|---|---|
| `PageHead` (naslov + summary + divider) | 0 | **175** |
| `ListScroll` | 175 | **1422** |

Zbir: 175 + 1422 = **1597**. `PageHead` je fiksan, lista skrola ispod.
`ListScroll.vertical_scroll_mode` → `SHOW_NEVER` + tanki grabber (8 px, `scroll_grabber.tres`)
umjesto default teme (danas `SHOW_ALWAYS` crta Godot default traku).

### 3. `BloomRow` — `collection_journal_row.gd`
Isti skript, novi raspored. Horizontalni lanac (1032):
`3 · 28 · InfoColumn 578 · 24 · TierStrip 372 · 24 · 3`.
TierStrip: `112 · 18 · 112 · 18 · 112`. Visina reda **200** u svim stanjima.

Danas red nema caption — dodaj `RowCaption` Label (`UiJournal.caption_for()`),
max 2 reda. `NewBadge` ostaje sibling panela (kao danas), ali ide **gore lijevo**
`(28, −18)` i u `#FFCCD5` (ista „novo" boja kao TabBadge), ne terakota.

### 4. Tabela stanja

| Stanje | Fill / edge | T1 | T2 | T3 | Ime | Caption |
|---|---|---|---|---|---|---|
| `locked` | `#E4E4E0` / `#B6B6B2` | prazan | prazan | prazan | `???` `#5C5C58` | Keep playing to discover this bloom. |
| `seen` | rarity | **bloom** | prazan | prazan | ime | Spotted in runs — merge to T2, then Keep in Album. |
| `album_t2` | rarity | **bloom** | **bloom** | prazan | ime | In your Album (T2 bloom). Merge to T3 for crystal. |
| `album_t3` | rarity | **bloom** | **bloom** | **crystal** | ime | Crystal bloom saved in Album! |
| + NEW | isto | halo na `new_tier` | | | + `NewBadge` | New discovery! / New bloom kept in Album! / New crystal in Album! |

Rarity: ★1 `#B8D4F0`/`#93AAC0` · ★2 `#E0C4FF`/`#B39DCC` · ★3 `#FFE8B8`/`#CCBA93`.

**TierSlot** — `tier_frame_style(kind)`:

| kind | Frame | Well | Art |
|---|---|---|---|
| `empty` | r 56 · fill ink 5 % · ring **4** ink 32 % | — | — |
| `bloom` (T1/T2) | r 56 · `#FFF8F0` · 3 `#CBC2B6` | inset 10 · r 46 · `#22342A` · 2 `#16211B` | 88 · `collection_bloom_icon.gd` |
| `crystal` (T3) | r 30 · `#FFD56B` · 3 `#D6A82F` | inset 10 · r 20 | 88 |
| + `NewHalo` | 130 × 130 na (−9, −9) · `#FFCCD5` · 3 ink | | |

Locked ≠ unlocked **bez boje**: prazan prsten vs tamni well sa rimom, a T3 mijenja
i oblik (kvadrat). Provjereno grayscale testom u dizajn fajlu.
`collection_bloom_icon.gd` više ne crta sivi krug za zaključan tier — sakrij ga,
prazan slot je sada `Frame` „empty".

### 5. NEW mora preživjeti otvaranje (bug u današnjem kodu)
Danas `refresh_for_meta_hub()` zove `GameState.mark_collection_journal_viewed()` pa
odmah `_apply_entries_in_place()` — svaki NEW nestane u istom frameu u kojem bi se
pojavio. Igrač ga nikad ne vidi.

```gdscript
var _new_snapshot: Dictionary = {}   # type_id -> new_tier, samo za ovu posjetu

func refresh_for_meta_hub() -> void:
	for e in GameState.get_collection_journal_entries():
		if bool(e.get("is_new", false)):
			_new_snapshot[str(e.type_id)] = int(e.new_tier)
	GameState.mark_collection_journal_viewed()   # pravilo ostaje: podaci + tab badge se brišu na otvaranje
	...  # red: is_new = _new_snapshot.has(type_id), new_tier = _new_snapshot[type_id]

func on_meta_page_left() -> void:              # pozovi iz meta_hub_controller._on_page_changed kad index != COLLECTION
	_new_snapshot.clear()
```

### 6. Auto-scroll na prvi NEW + sezonska poglavlja
- Kad `_new_snapshot` nije prazan: `ListScroll.scroll_vertical = row_y(prvi NEW) − 330`
  (1,5 reda konteksta iznad), clamp. Redovi se danas grade 6 po frameu — sagradi do
  ciljnog reda pa skroluj. Bez newsa: otvara se na vrhu, kao danas.
- `SeasonHeader` između grupa: `SeedCatalog.season_id_for(type_id)` +
  `SeasonCatalog.get_def(id).display_name`. Lista je već u redoslijedu `seasons.json`,
  sortiranje ne treba. `SeasonCount` = broj `album_t2`/`album_t3` u sezoni, „4 / 6 kept".
  `SeasonLock` (`icon_lock_ink.svg`) kad sezona nije otključana.
- `SummaryLabel` = `UiJournal.summary_text(entries)` → „Album: 5 blooms kept · 4 spotted"
  (kept = album_t2 + album_t3, spotted = samo `seen`; jednina za 1). Funkcija
  `format_collection_journal_summary()` iz briefa ne postoji u kodu.

### 7. Journal tab + Golden Album
- **1e (preporuka):** ništa za raditi — `meta_hub_controller._refresh_tab_badges()` već
  šalje `count_collection_journal_news()` u `HubTab` (pink `#FFCCD5`, 3 px `#1A241E`, „9+").
  Camp `collection_badge` je mrtav kod (sakriven u hubu) — može se ukloniti.
- **1f (alternativa):** u `hub_tab.gd` umjesto brojača `Panel` 30 × 30 (`tab_dot_style()`),
  isti ugao.
- **GoldenFrame** (kad je `journal_gold` opremljen): dva Panela bez centra
  (`golden_frame_edge.tres` 13 / r 38 na offset 12, `golden_frame_gold.tres` 7 / r 35 na
  offset 15) + naslov na plaketi (`golden_plaque.tres`, Label 56 / 900 ink). Lista se
  uvlači na x 44 · 992 širine. `CosmeticCatalog.get_journal_title_color()` više ne treba.
  U B pozlati se sama `AlbumPage` (`album_page_b_gold.tres` + `golden_frame_gold_b.tres`).

## Kontrast — provjereno

| Šta | Prema | Ratio |
|---|---|---|
| Ime / ★ `#2D3436` | `#B8D4F0` / `#E0C4FF` / `#FFE8B8` | 8,8 / 8,7 / 11,2 : 1 |
| Caption `#3F4547` | `#B8D4F0` / `#E0C4FF` / `#FFE8B8` | 6,4 / 6,3 / 8,1 : 1 |
| Locked ink `#5C5C58` | `#E4E4E0` | 5,3 : 1 |
| Summary `#555C5E` | `#FFF8F0` | 6,5 : 1 |
| Naslov `#2D3436` (A) | `#FFF8F0` | 12,0 : 1 |
| Naslov `#FFD56B` / PNG `#E8B80A` (B) | `#2E4733` | 7,3 / 5,5 : 1 |
| NEW `#2D3436` | `#FFCCD5` | 9,5 : 1 |
| Plaketa `#2D3436` | `#FFD56B` | 9,0 : 1 |
| Današnji PNG naslov `#E8B80A` | `#FFF8F0` | **1,8 : 1** ✗ (zato A ide u ink) |

Najmanji tekst: ★ i T-labele 32 px, count sezone 36 px; body/caption **38 px**.
Nema novih dodirnih zona — Journal ostaje bez interakcije osim skrola.

## Font
Dizajn je u **Nunito** (700/800/900), kao i hub chrome paket. Bez Nunito sve mjere
ostaju iste; jedino naslov u A treba re-bake `title_bloom_album.png` u `#2D3436`
umjesto Labela. Današnji Journal renderuje u Godot default fontu (Open Sans SemiBold) —
`JournalToday.dc.html` ga tako i prikazuje.

## Gotovo kad
- [ ] Svih 48 tipova (8 sezona) renderuje bez zastoja; visina reda 200 u svakom stanju
- [ ] Rarity hexovi tačno kao u tabeli; locked uvijek `#E4E4E0`
- [ ] 4 stanja razlučiva na **grayscale** screenshotu (0 / 1 / 2 / 3 popunjena + kvadrat T3)
- [ ] NEW pilula, halo i NEW caption vidljivi cijelu posjetu; tab badge nestaje na otvaranje
- [ ] Otvaranje sa newsom skroluje na prvi NEW red
- [ ] Summary broji isto što i redovi (kept / spotted)
- [ ] Nijedan tekst se ne reže osim imena tipa (ellipsis)
- [ ] GoldenFrame samo kad je `journal_gold` opremljen
- [ ] Smoke: `meta_hub_smoke`, `meta_hub_flow_smoke`, `swipe_snap_smoke` + novi `journal_new_snapshot_smoke` (NEW vidljiv poslije `refresh_for_meta_hub`, nestaje poslije napuštanja stranice)

## Van zadatka — nije u dizajnu
- Shop, Home, Camp, Arena, Run, ekonomija, unlock pravila sezona — netaknuto.
- Tap na red (detalji cvijeta), filter, pretraga, sortiranje — nije dizajnirano.
- Sticky SeasonHeader pri skrolu — lijepo bi bilo, treba custom kod; nije nacrtano.
- Finalni art cvijeća za 42 tipa van Country Bloom — i dalje `CampPlantDraw`.

## Otvoreno
1. **Auto-scroll** je ponašanje, ne layout — nacrtan kao ON. Potvrdi.
2. **SeasonHeader** je opcion; bez njega redovi se ne mijenjaju.
3. **Golden Album** postaje frame + plaketa. Ako ostaje samo tint naslova, ime SKU-a „frame" je pitanje.
4. Redovi plaćenih / neotključanih sezona su `???` kao danas — lock na headeru je jedini dodatak.
5. Brief kaže „danas se news nigdje ne vidi u hubu" — to je prije hub chrome prenosa; broj na tabu već radi.
