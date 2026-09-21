# Home — biranje sezone · CD isporuka

Redizajn Home scene biranja sezone (`SeasonStage`) za Merge Meadow.
Brief: `docs/04-experience/design-drafts/home-season-select-cd-brief.md`.
Preporučeni smjer: **1a Season Trail**.

Artboard je **1080 × 1920**; Home je **1080 × 1597** između zadatog headera (143) i footera (180). Sve mjere u artboardima i u exportu su u px te baze i prenose se 1:1.

## Šta otvoriti

Otvori `.dc.html` fajlove direktno u browseru. Kartice u kanvasu se mogu pan-ovati i zoom-ovati.

| Fajl | Šta je | Isporuka |
|---|---|---|
| `Home Season Select.dc.html` | **počni ovdje** — 1a Season Trail i 1b Season Shelf jedan pored drugog, s preporukom i obrazloženjem | P1.1 |
| `Home Shelf.dc.html` | 1b u punoj veličini + trade-off | P2.11 |
| `Home Gestures.dc.html` | skica gesti i zone za hub swipe, za oba smjera | P1.8 |
| `Home States.dc.html` | novi igrač · pregled svih sezona · sve 4 free otključane | P1.2, P1.5, P1.7 |
| `Home Unlock.dc.html` | storyboard: spremno → trenutak → poslije (= dolazak iz Campa) | P1.3 |
| `Home Premium.dc.html` | nekupljena · kupovina u toku · kupljena i aktivna · coming soon | P1.4 |
| `Home Specs.dc.html` | spec sheet kartice, 8 mood boja, tabela animacija, asset lista, otvorena pitanja | P1.6, P2.9, P2.10 |

## Komponente

| Fajl | Šta je |
|---|---|
| `HomeScreen.dc.html` | cijeli ekran. Props: `scene` (11 stanja), `dir` (`trail` \| `shelf`), `zones` (skica gesti), `bare`. Chrome i kartica su uvučeni u ekran — svaki artboard je jedan mount. |
| `SeasonCard.dc.html` | **kanonska kartica sezone.** Props: `variant` (6 visina), `state` (10 stanja), `season` (8), brojevi gatea, `price`. Otvori je i mijenjaj props da vidiš bilo koju kombinaciju. |
| `HubScreen.dc.html` | zadati header i footer iz hub chrome paketa — referenca, ne mijenja se. |
| `support.js` | runtime za `.dc.html`; mora stajati uz njih. |

## Asseti

Dizajn učitava samo ovo, na ovim putanjama:

- `icons/icon_coin.svg`, `icons/icon_lock.svg` — unlock poster i zaključane kartice
- `icons/icon_seed.svg`, `icons/icon_diamond.svg`, `icons/icon_settings_light.svg`, `icons/tab_*.svg` — zadati header i footer
- `flowers/ph_*.svg` — placeholderi za roster i za ★3 cvijet u gateu (8 fajlova)

Sve ostalo je ravna boja + radius + border + jedna sjena (`StyleBoxFlat`). Za export treba samo `icon_gift.svg` (84 × 84) i `pulse_ring.png` (256 × 256, postoji iz capability testa). Sezonske ilustracije ne postoje — dizajn radi bez njih, slot 996 × 340 je predviđen.

## Prenos u Godot

`godot/` sadrži sve za implementaciju:

- **`godot/home_export.json`** — ekran kao podaci: tokeni i paleta, rect i mjere svakog bloka, 6 varijanti kartice sa svim child-mjerama, 11 stanja s tačnim brojevima, tween tabela, EN tekstovi s placeholderima, asset lista, mapa „CD sloj → node / skripta" po §10 briefa, i lista smoke testova koji moraju pasti.
- **`godot/ui_home.gd`** — `StyleBoxFlat` fabrike i izvedene boje. Zaključane i coming-soon boje se **računaju** iz mood boje (`locked_fill()`, `soon_fill()`, `card_border()`), ne hardkodiraju po sezoni.
- **`godot/README.md`** — red prenosa u 7 koraka i šta se briše.

### Šta se briše pri prenosu

`season_browser.tscn` + `season_browser.gd` (kolona koja se skroluje *jeste* pregled svih sezona) · mrtav `SeasonUnlockSheet` · `split` režim u `season_unlock_progress.gd` · `BandColumn` / `PaidBand` / `BandSep` / `FreeBand` / `*Motion` / `*Slot` node-ovi i funkcije `swap_home_band`, `cycle_free_strip`, `cycle_paid_strip`, `_play_inplace_morph` · `DecorMoundLeft/Right` · `PlayThemeBadge`.

### Odlučeno

**Play** pokreće run u aktivnoj sezoni odmah (1 korak umjesto 3) i nosi ime te sezone u čipu — dugme čita kao `Play · Country Bloom`. Polje sezone se otvara tapom na karticu aktivne sezone ili na `Open meadow ↗`. `season_meadow_smoke` se mijenja pri prenosu.

### Još traži potvrdu

Brisanje Browsera · pozadina `#2E4733` umjesto `#243329` · Ember Fen kao „Coming soon" kartica ili sakriven do izlaska · `PremiumCard` je dijeljen sa Shopom, pa Shop naslijeđuje ovaj izgled.

### Šta se ne mijenja

Ekonomija (500 coina + 20 ★3), redoslijed i linearnost besplatnog puta, IAP tok i cijene, header i footer, broj sezona (`seasons.json` ostaje izvor — raspored ne pretpostavlja 4 + 4).
