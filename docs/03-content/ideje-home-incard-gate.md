---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, unlock, gate, sezone, scratch]
povezano:
  - ideje-home-incard
  - ideje-home-incard-pitanja
  - ideje-home-unlock-gate
ai_sažetak: "HOME-08 gate — coins+Seeds+Unlock u next-lock free prozoru (Lantern); sivo dok nema resursa; paid bez gatea."
---

# IDEJE — HOME-08 Unlock gate u prozoru sezone

> [[ideje-home-incard|hub]]. Logika `can_unlock_free` / `unlock_free` / P84 lantern skip **ostaje**. Ovaj doc overridea **gdje** gate živi i kako izgleda gumb.

## Što je krivo

HOME-07 `UnlockGate` je Stage overlay (anchor bottom-right). Igrač na Lantern Meadow vidi karticu s imenom, a progress „negdje desno na Homeu“. To **nije** „prva zaključana sezona ima progres na svom prozoru“.

Lantern **jest** zaključan u saveu (`debug_unlock_all` ga preskače). Vizual locka nije na njenom prozoru — zato playtest izgleda kao da agent „nije zaključao Lantern“.

## Parent (P96)

Gate je **child istog hero-centar panela** kao roster kad je free-hero: `%CenterSlot`. Sidro: **donji desni kut** tog panela, da ne sjedi preko rostera (P92 lijevo). `clip_contents` na slotu.

**Vidi se samo kad:**

1. `home_band != "paid"` (free je hero), **i**
2. `strip_focus_id == next_locked_free_id()`, **i**
3. sezona nije `is_test_locked_season` (Amber nema ovaj UI — bounce / 🔒 bez coin Unlock), **i**
4. sezona nije playable.

Tipičan playtest: Frost playable, Lantern next-lock u centru → Lantern prozor nosi 🔒, roster, dvije trake, Unlock.

**Ne vidi se:** playable centar (Bloom/Frost); paid-hero (Moonlit/Coral/…); preview 20%; L/R side kartice; Amber further-lock.

## Sadržaj (P97, P98)

Isti podaci kao HOME-07 gate, veći da se čita u kartici:

1. Progress **Coins** — `wallet_coins / def.coins_cost` (Lantern 150).
2. Progress **Seeds** — `t3_flower_count() / t3_flowers_required` (Lantern 8). Riječ „sjemena“ na UI; broj je **T3 garden flowers**, ne seed bag (P86/P98).
3. Gumb **Unlock** — `UiClickButton`.

### Stanja gumba

| Resursi | Izgled | Input |
|---------|--------|--------|
| `not can_unlock_free` | `disabled`, `button_variant = "subtle"` (sivo, prazno) | `MOUSE_FILTER_IGNORE` — swipe prolazi |
| `can_unlock_free` | `disabled = false`, `button_variant = "primary"` (ispunjeno bojom) | `MOUSE_FILTER_STOP` — tap `unlock_free` |

Tap kad je spreman: `unlock_free` → Lantern playable, `active` + strip na nju, gate nestaje, Amber desno ostaje further-lock bounce.

Sheet (`season_unlock_sheet`) ostaje u sceni kao fallback; Stage **ne** otvara sheet za next-lock (P85 ostaje). Browser next-lock: close + Home fokus na Lantern, gate se vidi **u** Lantern prozoru.

## Lantern locked (P99)

Ponovljeno jer je playtest to trazio:

- `debug_unlock_all_seasons` **ne** dodaje `lantern_meadow` (ni amber, ni ember).
- `is_test_locked_season` i dalje **samo** amber + ember — zato `can_unlock_free(lantern)` **radi** kad ima 150c + 8 T3 + Frost unlocked.
- Na Lantern prozoru: 🔒 u naslovu, roster Lantern cvjetova, gate. To **jest** „zaključana sezona“.

## Paid (P95)

Nema ovog panela. IAP ostaje Shop / Browser. Ember locked: roster u paid-hero prozoru, bez Unlock.

## HIT-A

Unlock gumb STOP samo dok je klikabilan. Roster IGNORE. Gate panel IGNORE osim gumba.

## Tehnički (za INCARD-B, ne P0 kod)

- Ukloniti Stage-level `[node name="UnlockGate"]`.
- Gate node unutar `CenterSlot` (ne u `PaidCenterSlot`).
- [`season_unlock_gate.gd`](../../game/scripts/ui/season_unlock_gate.gd): `refresh_gate` kako sad, veći font/bar; parent već clipa.
- Smokes: Lantern centar → gate **dijete** center slota, `visible`; s 0 coins gumb IGNORE; s 150/8 STOP + unlock; paid Coral → gate hidden.

## Acceptance

- Debug skip: Bloom+Frost playable, Lantern nije. Cycle na Lantern: **u ljubičastom prozoru** coins + Seeds trake + sivi Unlock; roster Midnight Lotus ★★★ lijevo.
- Bez 150c/8 T3: Unlock se ne može tapnuti; swipe L/R radi.
- S resursima: gumb primary; tap grant-a Lantern; gate nestaje; Amber desno bounce.
- Paid Coral: roster u prozoru, **nema** Unlock.
