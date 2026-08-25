---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, browser, sezone, scratch]
povezano:
  - ideje-home-focus
  - ideje-home-focus-pitanja
  - ideje-home-paid
  - ideje-sezone
ai_sažetak: "HOME-06 Browser — unlocked/owned tap postavlja home_band + 3-slot centar + active; overlay se zatvara; locked ostaje sheet/IAP."
---

# IDEJE — HOME-06 Season Browser → Home fokus

> [[ideje-home-focus|HOME-06 hub]]. Browser ostaje (P46). Shop i dalje **nema** Select (P47). Ovo popravlja **Home** nakon Browser odabira.

## Simptom

Igrač otvori Season Browser (tap **hero centra**). Tapne sezonu (npr. Coral Tide ili Frost Orchard). Overlay se zatvori ili ostane dojam da je „selektovano“: na Homeu se pojavi **outline**, ali **hero 80% i dalje pokazuje staru sezonu**. Fokus 3-slota nije ta kartica. Play tema i vizual se razilaze. Igrač kaže: browser ne radi.

## Uzrok (kod nakon HOME-05)

`season_browser.gd`:

- Unlocked free → `GameState.set_active_season(id)` → `season_selected` → `close()`
- Owned paid → isto
- Locked free → `unlock_requested` (sheet), bez select
- Unowned paid → `IAPManager.purchase(sku)`, bez select

`GameState.set_active_season`:

- Postavlja `active_season_id`
- Ako je **free**: `strip_focus_id = id` — 3-slot **bi** trebao centrirati, **ali** `home_band` se **ne** mijenja
- Ako je **paid**: `paid_strip_focus_id = id` — paid 3-slot bi se centrirao **da je** `home_band == "paid"`; ako je igrač na free-hero, paid ostaje 20% preview. Outline (`active_season_id`) može pasti na malu preview karticu. Hero i dalje free.

`season_stage.gd` `_on_browser_selected`:

```
func _on_browser_selected(_season_id: String) -> void:
    refresh()
```

Samo crta postojeći `home_band`. Nikad `swap_home_band`. Zato „outline da, fokus ne“.

Ako igrač odabere **drugu free** dok je već na free-hero, `strip_focus_id` se ažurira i `refresh()` **bi** trebao centrirati. Ako to u playtestu i dalje faila, uzrok je isti handler: treba eksplicitni `swap_home_band("free", id)` / `set_strip_focus`, ne oslanjati se na side-effect `set_active`.

## Cilj (P72)

Nakon tap-a na **playable** sezonu u Browseru:

1. Overlay se **zatvori** (kao sad).
2. `home_band` = `"free"` ili `"paid"` prema `SeasonDef`.
3. Ta sezona je **centar hero 3-slota** (`strip_focus_id` ili `paid_strip_focus_id`).
4. Ako band treba promijeniti, **isti visinski glajd** kao tap na preview (`swap_home_band`). Ako je band već točan, **nema** lažnog visinskog tweena — samo centriraj + `refresh`.
5. `active_season_id` = ta sezona (već iz Browser `set_active`). Outline sjedi na **hero centru**, ne na preview susjedu.
6. Play koristi tu temu. **Nema** `Theme:` badge (P74) — ni kad je prije bilo mismatch.

## Locked / unowned u Browseru

Ne mijenjaj:

| Kartica | Tap |
|---------|-----|
| Locked free (uključujući test-lock amber) | Unlock sheet **osim** P77: test-lock = bounce, nema sheet dok je flag |
| Unowned paid (uključujući test-lock ember) | IAP **osim** P78: test-lock = no-op, kartica vidljiva |
| Close / dim | `close()`, Home ne dira fokus |

Test-lock detalj: [[ideje-home-focus-chrome|chrome]].

## API

Predloženi Stage handler:

```
func _on_browser_selected(season_id: String) -> void:
    var def := GameState.get_season_def(season_id)
    if def == null:
        refresh()
        return
    var band := "paid" if def.is_paid() else "free"
    if GameState.home_band == band:
        if band == "paid":
            GameState.set_paid_strip_focus(season_id)
        else:
            GameState.set_strip_focus_id(season_id)  # ili postojeći setter
        refresh()
        return
    swap_home_band(band, season_id)
```

`swap_home_band(to_band, focus_id)` već prima `focus_id`: ne-prazan string postavlja fokus te trake i `set_active` ako playable. Browser je već zvao `set_active` — dupli poziv mora biti idempotentan.

Ne otvaraj Browser ponovo. Ne skači `home_band` iz **Shopa**.

## Home 3-slot tap (nije Browser, ali isti osjećaj)

Ako igrač tapne **vidljivu** L/R karticu na hero traci, postojeći cycle je stavlja u centar. Nakon P72, Browser i L/R tap moraju završiti u istom stanju: odabrana playable sezona = hero centar + outline + `active`.

Tap hero **centra** i dalje otvara Browser (P40/P46). Ne koristi Browser handler za taj tap.

## Acceptance (browser)

- Na free-hero, Browser → owned Moonlit: visine klize u paid-hero, Moonlit centar, outline na tom centru, overlay zatvoren.
- Na paid-hero, Browser → unlocked Frost: visine klize u free-hero, Frost centar, outline na Frost.
- Na free-hero, Browser → Frost (druga free): **bez** band tweena (već free), Frost postaje centar, Bloom lijevo/desno po prozoru.
- Locked kartica u Browseru ne zove `season_selected` (osim ako već tako radi sheet).
- Smoke: postojeći home/browser put ako ima assert; inače ručni playtest u Godot play.
