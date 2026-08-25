---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, pitanja, gesta, sezone, scratch]
povezano:
  - ideje-home-focus
  - ideje-home-focus-gesta
  - ideje-home-focus-browser
  - ideje-home-focus-chrome
  - plan-prompts-home-focus
  - ideje-home-glide-pitanja
  - ideje-home-paid-pitanja
ai_sažetak: "HOME-06 pitanja P69–P80 — L/R in-place pretapanje, invert swipe, Browser fokus, outline, test-lock, badge."
---

# IDEJE — HOME-06 pitanja (P69–P80)

> [[ideje-home-focus|hub]]. P1–P68 ostaju osim overridea označenih dolje. Freeze 2026-08-20.

## Kako koristiti

1. Pregledaj **P69–P80**. Override samo ako svjesno mijenjaš spec.
2. Kod: prompti **P0 → A → B → C** u [[../06-production/plan-prompts-home-focus|plan-prompts-home-focus]].
3. Ne diraj band-swap visine / 20/80. Ne vraćaj Shop Select. Ne pali Theme badge.

---

## P69 — L/R motion analog band-swapa

**Pitanje:** Klizanje free↔paid (visine 20↔80, ~250ms) je referenca. GLIDE-A (cijeli 3-slot se pomjeri pa `refresh` snapne) nije to. Kad mijenjaš Bloom → Frost klikom ili swipeom, koji pokret?

| Opcija | |
|--------|--|
| A | Odredišna kartica raste u centar, stara se skuplja u stranu (kao 20/80 na karticama), plus pomak. |
| B | Nova sezona uleti preko stare kao panel; susjedi stoje. |
| C | Zadrži pomak cijelog 3-slot reda, ali **bez cuta** — stretch/pretapanje dok putuju, isto 250ms. |

**Odgovor (freeze 2026-08-20, override playtest):** **nije C.** Row-slide (čak i sa stretch) i dalje **nije gladak** — rez na `refresh`. Igrač ne dira proporcije; traži **istu preobrazbu kao free↔paid**: slotovi ostaju, sadržaj se pretapa `BAND_TWEEN_SEC`. Nema pomaka HBoxa. Nema follow-finger. Override P60: `width+8` offset **uklonjen**.

---

## P70 — Smjer vertikalnog swipea

**Pitanje:** HOME-05: prst gore (`dy < 0`) na free-hero → paid. Invert?

**Odgovor:** **Da.** Prst **dolje** na free-hero → paid-hero. Prst **gore** na paid-hero → free-hero. Suprotno / već na tom bandu → bounce. Tap preview ostaje (nije invert). P62 override samo za **smjer**; vertikalni swipe i dalje = `swap_home_band`, ne cycle kartice (P65).

---

## P71 — Outline kontrast

**Pitanje:** 3px `E8D5A3` se ne vidi na Country Bloom. Jači kontrast?

**Odgovor:** **Da.** Vidi P79 za točan stroke.

---

## P72 — Browser tap → Home fokus

**Pitanje:** Tap sezone u Browseru selektuje (outline) ali sezona nije hero-fokus. Što treba?

**Odgovor:** Playable tap: zatvori Browser, postavi `home_band` na kind te sezone, stavi je u **centar** hero 3-slota, `active` već set. Ako band treba promjenu → `swap_home_band` (visinski glajd). Ako je band već točan → centriraj bez lažnog tweena. Locked/unowned: sheet / IAP / test-lock no-op, ne `season_selected`.

---

## P73 — Zadnja free i zadnja paid zaključane za test

**Pitanje:** Koje sezone? Uvijek locked ili samo dok previous nije unlockan (već postoji za free S4)?

**Odgovor:** `amber_canopy` (zadnja free) i `ember_fen` (zadnja paid) **uvijek** nisu playable dok je test flag. Ne ovisi o lantern unlock / IAP. Svrha: vidjeti lock UI.

---

## P74 — Tekst između Play i Play Endless

**Pitanje:** `PlayThemeBadge` (`Theme: …`) i bilo koji drugi iskačući tekst između dva Play CTA?

**Odgovor:** **Ugasiti sve.** Badge `visible = false` / no-op refresh. Play interno i dalje P50 (nije paywall).

---

## P75 — Outline = active ili = hero centar?

**Pitanje:** P61 je Play `active`. Nakon P72 obično se poklapaju. Locked centar?

**Odgovor:** I dalje **playable `active_season_id`**. Locked centar bez outline. Ako je active susjed (fokus na lock teaseru), outline na tom susjedu je OK.

---

## P76 — debug_unlock_all i test-lock

**Pitanje:** Debug gumb otključa sve, uključujući amber/ember?

**Odgovor:** **Preskoči** `amber_canopy` i `ember_fen` dok je flag. Ostale free + paid grant-a kao sad.

---

## P77 — Tap na test-locked free (amber) na Home / Browser

**Pitanje:** Unlock sheet (P11) ili bounce?

**Odgovor:** **Bounce**, nema sheet, dok je flag. Sheet bi implicirao da se može kupiti; test-lock nije kupovina.

---

## P78 — Ember u Shopu / Browseru dok je flag

**Pitanje:** Sakriti pack, ostaviti kupovinu, ili vidljiv no-op?

**Odgovor:** **Vidljiv, tap no-op.** Nema `purchase` / `grant_paid_season`. Home: sivo + lock.

---

## P79 — Točan outline stroke

**Pitanje:** Boja/debljina?

**Odgovor:** Visoki kontrast na svijetlom i tamnom. Prefer: border ~5px `FFF6D6` + shadow 2px `1A1A14`. Fallback: 4–5px `1A1A14` bez cream. Ne 3px `E8D5A3`.

---

## P80 — Kako se gasi test-lock kasnije

**Pitanje:** Save migracija? Remote config?

**Odgovor:** Jedan const `TEST_LOCK_LAST_SEASONS` (default **true** u ovom sliceu). `false` → normalan gate/IAP. Nema SAVE_VERSION bump. Stari save koji već drži amber/ember unlock **i dalje** ih tretira locked dok je const true.

---

## Freeze tablica

| # | Odluka |
|---|--------|
| **P69** | L/R **in-place pretapanje** (kao band visine); nema HBox pomaka; `BAND_TWEEN_SEC`; nema follow-finger |
| **P70** | Swipe dolje → paid; swipe gore → free; bounce suprotno; tap ostaje |
| **P71** | Jači outline kontrast |
| **P72** | Browser playable → band + centar + close |
| **P73** | amber + ember uvijek locked (test) |
| **P74** | Nema teksta između Play gumba |
| **P75** | Outline = playable active |
| **P76** | debug_unlock preskače amber/ember |
| **P77** | Test-lock free tap = bounce, ne sheet |
| **P78** | Ember vidljiv, kupnja no-op |
| **P79** | 5px svijetli + tamna sjena (ili tamni 4–5px) |
| **P80** | `TEST_LOCK_LAST_SEASONS` const, default true |
