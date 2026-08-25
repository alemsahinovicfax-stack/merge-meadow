---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, gesta, swipe, chrome, scratch]
povezano:
  - ideje-home-chrome
  - ideje-home-hit-targets-gesta
  - ideje-home-polish-carousel
  - ideje-home-chrome-pitanja
ai_sažetak: "HOME-03 gesta — Browser samo srednja kartica; gap no-op; snap-slide 220ms; bounce na rubu; HIT-A ignore ostaje."
---

# IDEJE — HOME-03 gesta (Browser + smooth strip)

> [[ideje-home-chrome|HOME-03 hub]]. Hit-through: [[ideje-home-hit-targets|HOME-02]] **ostaje**. Ovo mijenja **što tap znači** i **kako swipe izgleda**.

## Tap mapa (CHROME-B) — freeze P40–P41

Hit-test i dalje `get_global_rect()` na slotovima, release pozicija, prag `SWIPE_LOCK_PX` 20 (P30).

| Zona | Tap (nije swipe) | Ne |
|------|------------------|-----|
| **C** srednji okvir | `open_browser()` — free + paid dolje (postojeći overlay) | Ne Play |
| **L** visible | `set_active` + strip fokus (P35) | Ne Browser |
| **R** unlocked | isto | Ne Browser |
| **R** locked | Unlock sheet P11 | Ne Browser |
| **G** gap / pad Stagea | **no-op** | Ne Browser (override P29) |

Danas `_handle_tap`: L, pa R, pa **else Browser**. B mijenja else u `return`.

Centar **mora** biti eksplicitni rect (ne „sve što nije L/R“). Inače gap opet otvara Browser.

Redoslijed predložen: L → R → **C** → return. (C nakon L/R da granica L/C i dalje preferira L.)

## Swipe semantika (ne dirati u B)

Isto kao HOME-B: dx &lt; 0 → +1 ako desno unlocked, inače bounce; dx &gt; 0 → −1 ako L postoji. P20 no wrap. P33 drag na lock ≠ sheet.

HIT-A: djeca Row IGNORE, Stage STOP. Slide u C **ne smije** vratiti STOP na kartice.

## Zašto swipe nije gladak danas

`_play_snap` tweeka **alpha**. `refresh()` odmah mijenja tekst/boju tri slota. Nema pomaka x. Mozak vidi **cut**.

## Smooth slide (CHROME-C, P42)

**Cilj osjećaja:** kartice **odklize** ~jednu širinu slota, pa sjednu u novi L/C/R. Trajanje **200–280ms** (default **220**), ease-out. Duže od starog 180ms fadea je OK.

**Ne u C v1:** follow-finger (kartica prati prst tijekom drag). To je v2 ako playtest traži. Prag swipe i dalje 20px pa **jedan** cycle + slide.

### Tehnika (HBox ne smije pregaziti x)

HBox `Row` layout resetira `position`. Zato:

1. Ubaci **holder** `Control` (`%StripMotion`) full-rect, `mouse_filter IGNORE`.
2. `Row` child holdera.
3. Tween **holder.position.x** (ili `offset_left`) za `dir`: +1 slide **lijevo** (negativan x) za ~`(center_slot.size.x + separation)` * 0.45–0.7 (peek, ne puni ekran — 3 slota već viri).
4. Na `finished`: `refresh()`, `position.x = 0`, kratki fade opcionalno **ne** obavezan.
5. `_ignore_hits(row)` i dalje; holder IGNORE.

Ako holder krši hit: Stage i dalje puni rect — OK.

**Alternativa jeftinija:** scale/modulate crossfade duži — **odbaci** kao primarni; playtest traži **scroll**.

### Redoslijed s podacima

Danas: `cycle_free_strip` odmah mijenja `strip_focus` pa `refresh` pa fade.  

C: ili

- **A (preporuka):** najprije tween (vizual „ide prema desnoj kartici“), na kraju `cycle_free_strip` + refresh + reset x. Risk: ako cycle fail (locked), ne smiješ krenuti slide — bounce **prije** tweena.
- **B:** cycle+refresh odmah, tween „dolazak“ s suprotnog x. Može treperiti jedan frame.

Prefer **fail-fast bounce**, success → slide then commit **or** commit then slide-from-offset. Implementator bira jedan; smoke čeka tween.

### Bounce

Locked smjer: **ne** slide u prazno. Ostaje modulate bounce ili 8–12px overshoot holdera pa natrag. Ne wrap.

## Hub pager

`block_hub_swipe` na Stageu ostaje. Horizontalni strip swipe ne mijenja Shop/Camp page.

## Overlay

Browser/sheet STOP (P32). Slide se ne pokreće dok je overlay otvoren (input ne stiže Stageu).

## Playtest (čovjek)

1. Tap **sredine** → Browser; zatvori.
2. Tap **između** kartica → ništa.
3. Tap lijeve otključane → ta sezona centar, **sa** slideom (nakon C).
4. Swipe preko kartice → slide, ne blink.
5. S1 swipe u prazno → bounce, ne wrap.
6. Play Endless na Frost → Frost tema + Hard.

## Povezano

- [[ideje-home-hit-targets-gesta|HOME-02 gesta]] — prag, L/R, hub
- [[ideje-home-chrome-pitanja|P36–P44]]
