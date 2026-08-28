---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, home, ux, unlock, gate, sezone, scratch]
povezano:
  - ideje-home-barfit-gate
  - ideje-home-barfit-pitanja
  - plan-prompts-home-barfit
  - ideje-home-lockflow
  - ideje-home-cardfit
  - CHECKPOINT
ai_sažetak: "HOME-11 hub — locked barovi prekrivaju 🔒+ime; spustiti gate; skinuti suvišan okvir panela; debug 500 coins da se testira Unlock."
---

# IDEJE — Home barfit (HOME-11 hub)

> **ID:** **HOME-11** · v1.1+ (nije v1 launch blocker).  
> **Kod:** **BARFIT-A ✅**. Prompti: [[../06-production/plan-prompts-home-barfit|plan-prompts-home-barfit]] **BARFIT-P0 → A**.  
> **Prethodnik:** [[ideje-home-lockflow|HOME-10]] LOCKFLOW-A–B ✅ — locked free **jest** poster (ime + Coins/Seeds 500/20 + Unlock sivi→zlato), roster skriven dok locked, pa širi desno bez ellipsisa. Playtest nakon toga vidi **tri sitne stvari** na istom posteru koje i dalje smetaju.  
> **Pillar:** [[../01-vision/design-pillars|Fair F2P]] — 500 coins **nije** produkcijski starting wallet. Samo **debug/playtest** grant da se vidi zlatni Unlock. Trošak u JSON ostaje 500/20. Paid i Ember bez coin Unlock.

## Pitch

LOCKFLOW-A je stavio UnlockGate u **donju polovicu** `CenterFill` (`anchor_top = 0.48`). Na papiru je „ispod imena“. U playtestu **nije**.

Zaključana sezona u hero-centru crta naslov kao:

```
🔒
Lantern Meadow
```

`CenterTitle` je **full-rect**, H+V CENTER (P107 / CARDFIT-B). Katanac i ime žive u **geometrijskom centru** kartice. Gate koji počinje na 48% visine **ulazi u taj blok**: panel, barovi i gumb sjede preko 🔒 i preko imena. Igrač ne vidi što otključava.

Drugo: gate je `PanelContainer` s `SeasonCardContrast.make_frame` (wash 0.28 + 1 px border). Kartica **već** ima mood boju. Drugi okvir oko barova je **suvišan** — izgleda kao naljepnica zalijepljena preko sezone, ne kao sadržaj kartice.

Treće: da se Unlock uopće testira, treba 500 coins (i 20 T3). Playtest: **daj 500 coinsa po defaultu** u debug buildu, da gumb može postati zlatan bez ručnog štelanja savea.

To je **isti** widget, isti 500/20, isto zlato, isti hide-roster. Samo: **niže**, **bez okvira**, **debug wallet**.

## Dijagnoza — zašto barovi jedu ime i katanac

U [`season_stage.tscn`](../../game/scenes/ui/season_stage.tscn) locked hero ima **dva** overlaya na istom `CenterFill`:

| Node | Sidro | Što crta |
|------|-------|----------|
| `CenterTitle` | full-rect (`anchor_right/bottom = 1`), H+V CENTER, font 28, autowrap | `🔒\n{ime}` kad je `locked` ([`season_stage.gd`](../../game/scripts/ui/season_stage.gd) `_fill_slot`: `title.text = "🔒\n%s" % name`) |
| `UnlockGate` | `anchor_left = 0.12`, **`anchor_top = 0.48`**, `anchor_right = 0.88`, `anchor_bottom = 1`, `offset_top = 8`, `offset_bottom = -12`, min `(280, 188)`, `z_index = 1` | Coins label + bar, Seeds label + bar, Unlock gumb |

Katanac **nije** poseban node. Nije ikona u kutu. To je prvi red naslova. Kad gate pokrije naslov, pokrije **oba**.

```
CenterFill (hero visina ~H)
┌─────────────────────────┐
│                         │
│         🔒              │  ← vertikalni centar naslova
│    Lantern Meadow       │  ← ime, i dalje oko 50% H
│ ████ UnlockGate ████████│  ← počinje na 0.48 H  → preklopa
│ Coins n/500             │
│ Seeds n/20              │
│      [ Unlock ]         │
└─────────────────────────┘
```

LOCKFLOW-A P115 je rekao „donja polovica, ispod imena“. `0.48` **jest** donja polovica geometrije kartice, ali **nije** ispod naslovnog bloka, jer naslov nije gore — naslov je u sredini. P107 namjerno drži ime u centru. HOME-11 **ne** vraća ime gore (P100 je playtest odbio). Spuštamo **gate**, ne naslov.

`custom_minimum_size.y = 188` + VBox (2 labele 18 px, 2 bara 14 px, gumb, separation 6, frame padding 10) treba ~180–200 px. Na hero Fillu ~360–420 px visine, panel od 0.48 do dna **mora** preći preko centra. Zato „malo dolje“ nije kozmetika — mora početi **ispod** lock+ime bloka (~2 retka × 28 px plus razmak ≈ 70–90 px oko centra).

## Dijagnoza — zašto okvir smeta

[`season_unlock_gate.gd`](../../game/scripts/ui/season_unlock_gate.gd) `_apply_frame`:

```
add_theme_stylebox_override("panel", CONTRAST.make_frame(season_id, 10))
```

`make_frame` = `StyleBoxFlat` s `FRAME_ALPHA = 0.28`, `darkened(0.18)` / `lightened(0.20)`, border 1 px @ 0.35. To je **isti** algoritam kao roster wash (LOCKFLOW-B / P122). Na **unlocked** kartici roster-panel ima smisla (lista na kartici). Na **locked** kartici gate-panel je drugi pravokutnik iste palete, s rubom, preko već obojene sezone. Playtest: **suvišan**. Barovi i gumb trebaju sjediti **direktno** na kartici.

Što **nije** „okvir prikaza“ i ostaje:

- `ProgressBar` fill (sama traka Coins/Seeds)
- Unlock gumb (`subtle` / `gold` iz `UiPalette`)
- Roster `make_frame` na **unlocked** kartici (HOME-10 B)
- Mood fill same kartice (`_apply_card_color`)

## Dijagnoza — zašto 500 coins debug

`can_unlock_free` traži **oba**: `wallet_coins >= 500` **i** `t3_flower_count() >= 20`, plus sequential previous unlocked. Bez 500c gumb ostaje `subtle` + IGNORE — playtest ne vidi zlato ni tap.

Danas debug boot (`main_menu.gd`): `debug_unlock_all_seasons()` skipa Lantern+Amber+Ember, **ne dira** wallet. Igrač s 0 coins vidi prazan Coins bar. Traženo: **500 po defaultu** da se gumb testira.

To **nije** ekonomija v1. Novi igrač i dalje kreće od 0 u produkciji. JSON `coins_cost` ostaje 500. Fair F2P: debug grant ≠ pay-to-skip.

Gumb zlatni treba i 20 T3. Playtest je rekao coins; bez T3 bar Seeds ostaje prazan i Unlock sivi. HOME-11 **preporučuje** isti debug fixture da osigura i `t3_flower_count() >= 20` (npr. clover kristali), inače „testiram dugme“ ne radi. Vidi P133.

## Zašto sada

Upravo smo zatvorili LOCKFLOW-A–B i relockali Lantern+Amber da se vidi poster. Playtest: barovi prekrivaju 🔒+ime, okvir smeta, nema 500c za zlato. Ako agent samo spusti `anchor_top` i ostavi frame, i dalje je naljepnica. Ako samo skine frame i ostavi 0.48, ime i katanac i dalje nestaju. **Jedan kod prompt (A)** — layout + frameless + debug wallet zajedno, jer su isti node (`UnlockGate`) + isti playtest.

## Što HOME-10 **jest** vs što HOME-11 **overridea**

| HOME-10 (ostaje) | HOME-11 |
|------------------|---------|
| Locked = ime sredina + barovi + Unlock sivi→gold | Ostaje sadržaj. **Pozicija** gatea niže (P129) |
| Roster skriven dok locked | Ostaje (P116) |
| JSON Frost/Lantern/Amber **500 / 20** | Ostaje. Ne dirati `seasons.json` trošak |
| Gold variant, tamni ink | Ostaje (P118) |
| Lantern+Amber locked, nisu TEST_LOCK | Ostaje |
| Gate child `CenterFill`, horizontala ~0.12–0.88 | Ostaje parent i L/R margine. **`anchor_top` override** |
| Gate `make_frame` wash kao roster | **Override P130:** locked gate **bez** panela/borda |
| Debug skip lantern+amber | Ostaje. **Dodatak P132:** debug wallet ≥ 500 |
| Naslov full-rect CENTER, `🔒\nime` na locked | Ostaje (P107). Ne gurati naslov gore |
| Roster 0.85, no ellipsis, wash 0.28, midpoint | Ostaje. Ne dirati u A |

Puna tablica: [[ideje-home-barfit-pitanja|pitanja]] P129–P136.

## Simptom vs cilj

| Danas (nakon HOME-10) | Cilj |
|-----------------------|------|
| Barovi / panel preko 🔒 i imena | Gate **ispod** lock+ime; katanac i ime čitljivi |
| Drugi wash-okvir oko barova | Nema panela; barovi i gumb na kartici |
| 0 coins u debugu → sivi Unlock | Debug wallet ≥ 500 (i T3 ≥ 20) → zlatni Unlock testabilan |
| `anchor_top = 0.48` | ~**0.62** (raspon 0.58–0.70) — dovoljno dolje, ne zalijepljeno za dno gumba |

## Što HOME-11 **jest**

- Spustiti UnlockGate da **ne prekriva** katanac ni ime zaključane sezone.
- Skinuti **okvir** gate panela (StyleBox wash+border). Trake i gumb ostaju.
- U **debug** buildu osigurati **500 coins** (ne smanjivati veći wallet) da se Unlock može testirati. Pratilac: 20 T3 ako ih nema.
- Isti chrome na Lantern, Amber, Frost (bilo koji next-lock). Nije hardkod `lantern_meadow`.

Detalj: [[ideje-home-barfit-gate|gate]].

## Što HOME-11 **nije**

- Novi Unlock widget, sheet, coin Unlock na paid / Ember.
- Promjena JSON 500/20, gold hex, hide-roster, sequential, TEST_LOCK.
- Vraćanje naslova gore (P100). Vraćanje gatea u desni kut (P110).
- Roster širina / ellipsis / wash / midpoint (HOME-10 B).
- Produkcijski starting coins 500 za nove igrače. SAVE_VERSION. Brisanje `user://player_save.json`.
- Band 20/80, L/R in-place, Shop Select, AdMob, `seed_type_ids`, 48 stubova.
- Launch blocker. v1.1+.

## Agent

- Kad korisnik dira „barovi prekrivaju ime“, „katanac“, „spusti barove“, „skini okvir“, „500 coins da testiram Unlock“ → **HOME-11**.
- Ne dirati `CenterTitle` sidro da „oslobodi“ barove.
- Ne stavljati 500 coins u produkcijski default wallet.
- Ne miješati BARFIT-A s novim roster/JSON radom.

## Povezano

- [[ideje-home-lockflow|HOME-10]] · [[ideje-home-cardfit|HOME-09]] · [[ideje-home-incard|HOME-08]]
- [[../06-production/CHECKPOINT|CHECKPOINT]] · [[../06-production/plan-prompts-home-barfit|prompti]]
