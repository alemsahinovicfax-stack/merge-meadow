---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, gesta, hit-targets, scratch]
povezano:
  - ideje-home-hit-targets
  - ideje-home-hit-targets-tehnika
  - ideje-home-hit-targets-pitanja
  - ideje-home-polish-carousel
  - ideje-home-polish-pitanja
ai_sažetak: "HOME-02 gesta — puni hit-rect × tap/swipe; prag; hub pager; overlay; mouse vs touch."
---

# IDEJE — HOME-02 gesta (hit mapa)

> [[ideje-home-hit-targets|HOME-02 hub]]. Semantika = HOME-01 [[ideje-home-polish-carousel|carousel]] + **P19**, prošireno na **svaki** start-rect uključujući panele.

Freeze pitanja: [[ideje-home-hit-targets-pitanja|P28–P35]].

## Koordinate

Sve je u **SeasonStage** global rectu (traka). Play gumb, chest, basket, hub chrome **nisu** dio ove mape.

Unutar Stagea:

| Zona | Vizual | Danas (STOP na panelu) | Cilj |
|------|--------|-------------------------|------|
| **C** | Veća srednja kartica | Dead | Swipe + tap Browser |
| **L** | Lijeva kartica (skrivena na S1) | Dead | Swipe + tap select |
| **R** | Desna kartica | Dead | Swipe + tap select ili sheet |
| **G** | Gap (HBox `separation` 8 px, clip rubovi) | Radi | Ista semantika (P29 tap = Browser) |
| **Pad** | Stage iznad/ispod kartica unutar min visine 260 | Može raditi | Tretirati kao **G** (isti handler) |

„Početak prsta“ = `_press_start` u `season_stage.gd`. Tap hit-test danas koristi **release** `pos` → `get_global_transform() * pos` vs `slot.get_global_rect()`. HIT-A to **ne** mijenja osim ako IGNORE pomakne koordinate (ne bi smio).

## Prag tap vs swipe (P30)

`SWIPE_LOCK_PX := 20.0` ostaje.

| `abs(dx)` | Klasifikacija | Napomena |
|-----------|---------------|----------|
| &lt; 20 | **Tap** na release | `dy` se **ne** koristi za klasifikaciju danas |
| ≥ 20 horizontalno | **Swipe** odmah u `_update_press` | Jedan cycle po gesti (`_swiped` latch) |

Vertikalni drag: ako je `|dx|` mali, ostaje tap (ili no-op dok prst drži). **Ne** uvoditi vertikalni strip-scroll. Ako igrač vuče skoro pa vertikalno preko kartice, bolje tap/no-op nego slučajni cycle. Override nije u P0 scopeu.

Nakon što je swipe okidao, **release ne smije** dodatno tapati (već `_swiped` guard).

## Smjer swipe (isti kao HOME-B)

Komentar u kodu: prst **lijevo** (negative `dx`) = sadržaj ide lijevo = **advance** prema desnoj kartici = `cycle_free_strip(+1)`.

| dx | Namjera | Uvjet uspjeha | Fail |
|----|---------|---------------|------|
| &lt; 0 (prst lijevo) | Fokus +1 | Desni slot postoji **i unlocked** | Bounce, fokus isti |
| &gt; 0 (prst desno) | Fokus −1 | Lijevi slot postoji (uvijek unlocked kad visible) | Bounce na S1 (nema L) |

**P20:** nema wrapa. S3 swipe +1 → bounce. S1 swipe −1 → bounce.

Swipe **smije** početi na **R locked**. Ako je to +1 pokušaj, `cycle_free_strip` fail → bounce. To **nije** sheet. Sheet je samo **tap** (P31, P33).

## Matrica: start zona × gesta

Pretpostavka: L/C/R visible prema `strip_focus` (new game: L hidden, C S1, R locked S2). Debug unlock: L S1, C S2, R S3 unlocked.

### Horizontalni swipe (bilo koji start L/C/R/G)

Isti ishod **neovisno o start zoni**. To je cijela poanta HOME-02: kartica nije zid.

| Gesta | Ishod |
|-------|--------|
| Swipe +1 allowed | Snap, novi centar, Play active = ta free |
| Swipe +1 blocked | Bounce, Browser se **ne** otvara |
| Swipe −1 allowed | Snap natrag |
| Swipe −1 blocked | Bounce |

### Tap (ispod praga)

| Start / release zona | Ishod | Ne |
|----------------------|--------|-----|
| **C** | `open_browser()` — free lista + paid dolje | Ne Play, ne sheet |
| **L** visible | `set_active_season(left_id)` + refresh (P35) | Ne Browser |
| **R** unlocked | `set_active_season(right_id)` + refresh | Ne Browser |
| **R** locked | `open_unlock_sheet(right_id)` (P11 / P31) | Ne Browser, ne cycle |
| **G** / pad Stagea | Browser (**P29** default) | Ne select slučajnog slota |
| Izvan Stagea | Nije HOME-02 | Hub pager / Play / chest |

Ako L nije visible (S1 fokus), tap u tom vizualnom praznom boku pada u **G** → Browser. To je OK: nema „prethodne sezone“.

### Tap na naslov (Label unutar slota)

Isti slot kao parent. Label **ne** smije biti zaseban hit (IGNORE). Inače smo opet u bug-u.

## Conflict s hub SwipePager

[`swipe_pager.gd`](../../game/scripts/ui/swipe_pager.gd) `should_block_hub_swipe_at`: ako je točka unutar nodea u grupi `block_hub_swipe`, hub **ne** mijenja stranicu.

`SeasonStage` je u toj grupi. Kad kartice STOP-aju event, hub pager **može** i dalje vidjeti motion na toj točki (ovisno o tome tko je `accept_event`). Playtest: swipe na kartici često **ne** cycle-a strip, a ponekad se osjeća kao da „ništa ne radi“ ili kao da hub pokušava. Cilj HIT-A: Stage prima event, `accept_event()` kao danas, hub **blokiran** na cijelom Stage rectu uključujući panele.

**Ne** stavljati `block_hub_swipe` na cijeli HomeColumn (HOME-A pravilo). Chest/Play ostaju hub-swipe-friendly.

## Overlay: Browser i Unlock sheet

Kad je Browser ili sheet **vidljiv**, oni su djeca Stagea (instance u `season_stage.tscn`) i **moraju** STOP-ati input (P32). HIT-A `IGNORE` rekurzija ide samo na **`Row`**, ne na overlay.

| Stanje | Prst na overlayu | Prst na traci ispod (ako viri) |
|--------|------------------|--------------------------------|
| Browser open | Lista / close / paid red | Ne bi smio viriti; ako viri, overlay Dim treba pokriti |
| Sheet open | Sheet gumbi | Isto |

Dok je overlay otvoren, **ne** cycle-ati strip ispod. To već vrijedi ako overlay hvata evente.

## Mouse (Godot editor) vs touch (telefon)

Handler već sluša `InputEventMouseButton` / `Motion` **i** `ScreenTouch` / `ScreenDrag`. HIT-A ne dodaje treći path. Desktop playtest = lijevi klik + drag, ekvivalent prstu.

Desni klik / srednji: ignorirati (već samo `MOUSE_BUTTON_LEFT`).

Multi-touch: ostaje jedan `_pressing` flag (postojeće). Nije HOME-02.

## Play mismatch (P21)

Tap na strip **free** kartice postavlja `active` na tu free → badge se **gasi**. Tap centar → Browser; ako tamo odabereš paid, vratiš se na Home, strip i dalje free fokus, badge **Theme: …**. HOME-02 to ne dira; samo omogućuje da do Browsera **dođeš tapom na C**.

## Što namjerno ostaje „krutije“

- Jedan cycle po swipe (nema fling kroz 3 sezone). HOME-B latch.
- Nema wrapa.
- Nema swipe-up za Browser.
- Nema long-press.

Ako playtest želi fling, to je **novi** ID, ne HIT-A.

## Playtest skripta (čovjek, 2 minute)

Debug unlock (HOME-C) → fokus S2.

1. Swipe počevši **na sredini** kartice lijevo → S3 u centar.
2. Swipe počevši **na desnoj** kartici desno → natrag S2.
3. Swipe počevši **na lijevoj** kartici.
4. Tap sredine → Browser; vidi paid; zatvori.
5. Tap lijeve → S1 centar.
6. (New game save bez debug unlock) tap locked desno → sheet, ne Browser.
7. Swipe na Home **ispod** Play (izvan Stage) → hub ide na Camp/Shop, strip se ne miče.

## Povezano

- [[ideje-home-hit-targets-tehnika|tehnika]] — kako Godot mora propustiti event
- [[ideje-home-polish-carousel|HOME-01 carousel]] — ista cycle matematika
