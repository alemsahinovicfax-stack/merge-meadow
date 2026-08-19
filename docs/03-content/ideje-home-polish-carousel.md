---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, carousel, sezone, scratch]
povezano:
  - ideje-home-polish
  - ideje-home-polish-layout
  - ideje-home-polish-pitanja
  - ideje-sezone
  - ideje-sezone-ux-home
ai_sažetak: "HOME-01 carousel — linear 3-slot free traka; centar veći; lijevo previous unlocked; desno next locked ili unlocked."
---

# IDEJE — Home polish carousel (free 3-slot)

> [[ideje-home-polish|HOME-01]]. Freeze **P16**: samo **free** lanac. Paid nikad nije slot na traci.

## Metafora

Nije beskonačni wrap-karusel svih playable sezona (to je SEZ-C `cycle_playable`).  
To je **prozor od tri mjesta** u sortiranom nizu `SeasonCatalog.free_defs_sorted()` (`order` 1, 2, 3, …).

Fokus = **jedan free `season_id`**. New game: `country_bloom`.

```
Indeksi u free lancu:    0:S1     1:S2     2:S3
Fokus S1 (locked S2):    [  —  ] [ S1★ ] [ 🔒S2 ]
Fokus S2 (S1+S2 unlock): [ S1  ] [ S2★ ] [ 🔒S3 ]
Fokus S3 (sve unlock):   [ S2  ] [ S3★ ] [  —   ]
```

`★` = centar, vizualno veći.  
`—` = slot skriven (nema prethodnog / nema sljedećeg).

## Pravila slota

### Centar

- Uvijek popunjen (barem S1, uvijek unlocked).
- **Veći** od side slotova. Draft omjer širine/visine kartice: **~1.35×** side (P22).
- Puna boja / thumbnail sezone. Nije sivo.
- Prikazuje display name (EN, P14) na/ispod thumba; seed peek 2–3 ikone **opcionalno** sitnije nego današnji Stage tekst.
- **Tap (P19 default):** otvara Season Browser.
- **Nije** Unlock sheet (to je desni locked).

### Desno

- `next_free = free_defs[focus_index + 1]` ako postoji; inače slot **skriven**.
- Ako `next` **nije** u `unlocked_seasons`:
  - sivo / desaturirano + katanac;
  - tap → **Unlock sheet** za taj id (P11 ostaje);
  - swipe prema njoj **ne** postavlja active (ne možeš „odsvirati“ locked). Swipe desno kad je next locked: ili no-op ili mali bounce (P23 default: **bounce, no change**).
- Ako `next` **jest** unlocked:
  - puna boja, **nije** siva, **nema** katanac;
  - manja od centra;
  - tap **ili** swipe prema njoj → ona postaje fokus (klizi u centar).

### Lijevo

- `prev_free = free_defs[focus_index - 1]` ako `focus_index > 0`.
- U v1 katalogu prev je **uvijek already unlocked** (linear gate: ne možeš imati S3 bez S2). Ipak pravilo: ako bi prev bio locked (ne bi smio), ne prikazuj.
- Puna boja. Svrha: „znam da mogu swipe natrag“.
- Tap (P19 default): odmah fokus na nju (isto što i swipe lijevo).
- S1 fokus → lijevi slot **skriven** (nema „prazne sive S0“).

## Što se događi na unlock S2 (glavni scenario)

Prije: centar S1, desno 🔒S2.  
Igrač otključa S2 (sheet ili Browser). **P12:** `active_season_id = frost_orchard`.  
**HOME-01 dodatno:** strip fokus = S2.

Poslije:

- Lijevo: **Country Bloom**, puna boja, manja.
- Centar: **Frost Orchard**, veća.
- Desno: **Lantern Meadow** locked teaser.

Igrač swipe lijevo → S1 opet centar, S2 desno pune boje (ne siva).

## Paid i `active_season_id` (P16 freeze, detalj)

Home traka **nikad** ne crta `moonlit_warren` / `coral_tide`.

Ali Play koristi `active_season_id`, a P12 grant paid **auto-switcha** active na paid.

Zato postoje **dva pojma**:

| Pojam | Život | Tko ga mijenja |
|-------|--------|----------------|
| `active_season_id` | save, run, theme | unlock free, grant paid, Browser select, **strip swipe/tap na free** |
| `strip_focus_id` (free only) | save **ili** izvedeno | samo free unlock / strip gesta / Browser select **free** |

**P16 ponašanje:**

1. Strip **uvijek** vizualizira free lanac oko `strip_focus_id`.
2. Ako je `active` paid, centar i dalje pokazuje **zadnji free fokus** (ne paid art).
3. Swipe/tap na free karticu postavlja **oboje**: `strip_focus_id` i `active_season_id` na tu free (paid više nije active).
4. Paid i dalje biraš u Browseru/Shopu; Play tada vozi paid temu dok strip laže „zadnju free“.

**Mismatch:** igrač vidi Country Bloom u sredini, a run je Moonlit.  
**P21 default:** mali badge na/uz Play, npr. `Theme: Moonlit Warren` (EN), samo kad `active` nije isti kao `strip_focus_id`. Tap badge **ne** mora otvoriti Shop (može no-op ili Browser paid). Override u pitanjima.

### Treba li novo save polje?

Opcije:

- **A (preporuka):** `strip_focus_id: String` u player save (uz v9+ migrate). Default S1. Normalize: mora biti free + unlocked; inače clamp na najviši unlocked free `order` ili S1.
- **B:** izvedi strip iz `active` ako je free, inače iz `last_free_active` cache.
- **C:** strip fokus = uvijek highest unlocked free (gubi „vraćam se na S1 u centar“). **Odbaci** — krši ideju lijevog slota.

HOME-B bira **A** osim ako override.

Kad unlock_free(S2): `strip_focus_id = S2` (usklađeno s P12).  
Kad grant_paid: **ne** dirati `strip_focus_id`.  
Kad `set_active_season` na free (Browser): `strip_focus_id = that id`.  
Kad `set_active_season` na paid: strip fokus ostaje.

## Geste (u rectu trake)

| Input | Ponašanje |
|-------|-----------|
| Swipe lijevo (prst ide lijevo, sadržaj ide lijevo) | Ako desni slot postoji **i unlocked** → fokus +1. Ako desni locked ili nema → bounce (P23). |
| Swipe desno | Ako lijevi postoji → fokus −1. Inače bounce. |
| Tap centar | Browser (P19). |
| Tap lijevo | Fokus prev (P19). |
| Tap desno locked | Unlock sheet. |
| Tap desno unlocked | Fokus next. |
| Tap+swipe konflikt | Ista lock distanca kao Stage (`SWIPE_LOCK_PX` ~20): prešao prag = swipe, inače tap. |

**Nema wrapa (P20).** Na S1 swipe desno ne skače na S3.

Hub: `block_hub_swipe` samo na strip Control.

## Veličine i peek (P22 draft)

Na širini 1080:

- Centar ~ **52–58%** širine trake, visina puna zona (~300).
- Side ~ **centar / 1.35**, vertikalno centrirani (optički niži/manji).
- Side kartice **djelomično viri** (~70–85% vlastite širine vidljivo, rest clip) da se vidi „ima još“.
- Locked desno: opacity ~0.65 + lock glyph, ne samo blago sivilo.

Animacija (P23 default): **snap ~180ms** ease-out, ne instant cut kao današnji `cycle_playable`. Ako 180ms lomi smoke, smoke čeka frame+timer.

## Stanja kartice (sažetak)

| Stanje | Slot | Boja | Tap |
|--------|------|------|-----|
| Free unlocked, fokus | C | full, veća | Browser |
| Free unlocked, susjed | L ili R | full, manja | fokus na nju |
| Free locked, next | R | grey+lock | Unlock sheet |
| Free locked, not next | — | nije na traci | samo Browser lista |
| Paid owned/unowned | — | nije na traci | Browser/Shop |

## Što ostaje iz SEZ-C

- Browser modal (free linear + Premium paid).
- Unlock sheet sadržaj (coins + T3 check-only).
- `open_browser` / sheet signali.

Što odlazi:

- ActiveCard kao dominantan tekst-prozor.
- `cycle_playable` po `list_playable_season_ids()` (paid u mixu).
- Teaser koji postoji samo kao locked next **bez** lijevog previous slota.

## Smoke (HOME-B)

Update [`game/scripts/dev/season_home_smoke.gd`](../../game/scripts/dev/season_home_smoke.gd):

- New game: centar S1, desno Frost Orchard locked, lijevo hidden.
- Teaser tap i dalje **ne** otvara Browser (P11).
- Nakon mock unlock S2: centar Frost, lijevo Country Bloom **nije** „Locked“, desno Lantern locked.
- Paid grant: `is_season_playable(moonlit)` true, strip centar **i dalje** free fokus (ne Moonlit title).
- Hub swipe isolation i dalje.

## Fair F2P

Traka ne smije vizualno reći da je paid „jači“. Paid uopće nije tu. Badge na Play (P21) je **informacija teme**, ne paywall.

## Povezano

- [[ideje-home-polish|hub]] · [[ideje-home-polish-layout|layout]] · [[ideje-home-polish-pitanja|pitanja]]
- [[ideje-sezone-ux-home|stari SEZ-C UX]]
