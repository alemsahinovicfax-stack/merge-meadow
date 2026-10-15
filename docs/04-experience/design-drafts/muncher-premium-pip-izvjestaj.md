---
type: iskustvo
status: aktivan
milestone: M8
tags: [dizajn, arena, muncher, pip, skin, premium, iap, claude-design, izvjestaj, performanse]
povezano:
  - muncher-premium-pip-cd-brief
  - performanse
  - scope-i-granice
  - CHECKPOINT
  - changelog
ai_sažetak: "Prenos design_handoff_muncher_premium_pip (2026-10-14): muncher je sada Nibbs, krtica (MuncherRig, 3 pogleda, 16 klipova, krtičnjak, baner pri prvom buđenju), pravila ista, 2–4 draw poziva umjesto 44–51; Sir Pip · Meadow Knight je prvi premium Pip skin (€3.99, SKU pip_knight) s vlastitim dijelovima u 5 pogleda, ogrtačem na sloju Skin, Shop premium karticom i oznakom Premium u Ormaru."
---

# Muncher (Nibbs) + Sir Pip — izvještaj o prenosu

> Roditelj: [[04-experience/_index|04-experience]] · brief: [[muncher-premium-pip-cd-brief]] · paket: `design_handoff_muncher_premium_pip/` („Character skin design 1.zip") · datum: 2026-10-14

## Ukratko

Oba dijela paketa su u igri.

1. **Muncher je sada Nibbs, seed-mole.** U igri se i dalje zove „Muncher".
   - Bucmasti krtičak boje kajsije s razbojničkom maskom, nosom kao ružičasti cvijet i dva zuba. Spava u krtičnjaku.
   - Nacrtan je od dijelova kao Pip (`MuncherRig`): 3 pogleda (naprijed, nazad, bočno; lijevo je zrcaljeno) i 16 klipova. Ništa se ne crta po frejmu.
   - **Pravila su ista:** 85 px/s, novi cilj svakih 0,25 s, jede na 36 px 0,5 s, led 2 s, buđenje 0,3 s. Kod samo bira klip za stanje.
2. **Sir Pip · Meadow Knight je prvi premium Pip skin**, za pravi novac.
   - Kaciga od kapice žira s koraljnom perjanicom, naprsnik od naprstka sa zlatnom djetelinom, plavi ogrtač, okrugli štit, čizme od žira, medeno krzno.
   - Vlastiti dijelovi u svih 5 pogleda; svih 75 postojećih animacija radi s njim.
   - Ima vlastite klipove: pozu, potpis (pobode barjak i salutira), idle detalj (kaciga sklizne, pa „tink"), reakciju na T3 (štit visoko) i cilj runa (ogrtač se raširi).
   - Shop ima premium karticu s cijenom (€3.99); u Ormaru Sir Pip ima oznaku „Premium". Samo je izgled (Pillar 2).

## Šta igrač vidi

### Nibbs u Areni

| Trenutak | Klip | Šta se vidi |
|---|---|---|
| Polje prazno | `m_sleep_nest` | spava u rupi krtičnjaka, prednja usna ga pokriva do pola, zzz |
| Sjeme prosuto | `m_wake_nest` / `m_wake_spot` (0,3 s) | iskoči, „!", zemlja leti |
| Prvo buđenje u sesiji | `m_awake` (1,4 s) + baner | protegne se i zijevne, protrlja šape; baner „Muncher's awake!" uleti ispod krtičnjaka i stoji 1,6 s |
| Lov | `m_hunt_front` / `m_hunt_back` / `m_hunt_side` | gega se prema sjemenki; pogled se bira po smjeru, najmanje 0,2 s isti |
| Sjemenka mu nestane (spojena / u korpu) | `m_escaped_*` preko lova | stane, lupi nogom, „hmph", pa odmah novi cilj |
| Jede | `m_eat_front` / `m_eat_side` (0,5 s) | dva griza, mrvice i ljuske lete |
| T3 merge | `m_freeze` → `m_frozen` → `m_thaw` | kocka leda, drhti i cvokoće; zadnjih 0,25 s led puca u 4 krhotine |
| Polje ostane prazno | `m_doze` → `m_sleep_spot` | zijevne i zaspi tu gdje stoji |

Krtičnjak se vidi i kad Nibbs ode iz rupe. Prednja usna je preko njega samo dok spava ili se budi u rupi.

### Sir Pip

- **Svuda gdje je Pip:** polje, kartica sezone, Arena, run odozgo, glava na traci napretka u runu, Shop i Ormar. Ogrtač lagano diše (sloj „Skin"), a u runu leprša uz galop.
- **Shop · Looks:** premium kartica ispod Blossoma i Skya, s oznakom „Premium", „Meadow Knight · Looks only" i ljubičastim dugmetom s cijenom.
  - Tap na cijenu: tri tačke, pa kupljen i odmah obučen („✓ Wearing", žuta kartica, kvačica) i toast „Pip wears Sir Pip".
  - Ako nosi drugi skin, dugme je „✓ Owned"; tap ga ponovo obuče.
- **Ormar:** „Free" (Classic) i „Premium" (Sir Pip) su pilule ispod imena. Nekupljen Sir Pip je pod velom; tap vodi u Shop pravo na njegovu karticu.
- **IAP:** proizvod `pip_knight` (non-consumable). Kupovina ga obuče; Restore purchases samo vrati vlasništvo. Dev reset kupovina (stub) ga vraća u prodavnicu.

## Odstupanja od paketa (i zašto)

| Paket | U igri | Zašto |
|---|---|---|
| „Zamijenjeni dijelovi su u finalnim bojama, bez recolora" | Recolor ide i na dijelove Sir Pipa | SVG-ovi ušiju, šapa i tijela nose classic boje krzna (mint); bez recolora su uši i šape ostale mint. Boje oklopa nisu classic boje, pa ostaju |
| z dodataka 0,5 / 2,5, ogrtač −6 | Godot z iz `skins.json → gz` (ogrtač −1, štit iznad lica) | Godot ima samo cijele z, a sjena Pipa je na −4: ogrtač na −6 bi bio ispod sjene. Redoslijed je provjeren skriptom naspram pregledača; jedina razlika je da štit može prekriti zvjezdice u T3 |
| Led: `m_freeze` → `m_frozen` 2 s → `m_thaw` | Pucanje je u zadnjih 0,25 s od 2 s | Pravilo „led 2 s" ostaje tačno; u pregledaču led traje 2,25 s |
| Pip u pregledu Shopa / Ormara | Pip je podignut za 4 z (`UiPip.HOST_LIFT`) | Pregled crta pozadinu sam, pa su ogrtač i sjena (z < 0) padali ispod nje. Oznake kartice su zato na z 16 |
| „Free" na Classicu gore lijevo (paket settings_fixes) | „Free" i „Premium" ispod imena | Ovako ih crta novi paket; gore lijevo se „Premium" sudarao s kvačicom nošenog skina |
| Baner 44 px | Tekst se smanji da stane (~38 px) | „Muncher's awake!" na 44 px je širi od pločice (372 px) |
| — | Baner se ne pokazuje kad Arena tutorial već piše „Muncher's awake" | Isti tekst dvaput |
| Gnijezdo y 132 (pregledač) | `NEST_Y` 108 → 132; keepout sjemenki 140 × 215 | Krtičnjak 270 × 124 je veći od starog gnijezda |
| „Sjemenka pobjegla" kao overlay | Pogled ostaje 0,8 s dok traje „hmph" | Promjena pogleda bi prekinula klip na pola |
| Atlas @1,5× (prijedlog) | Muncher @1,5× (1024 × 840); Pip ostaje @2× | Muncher je 1:1 u px igre; Pip je i do sad bio @2×, pa Sir Pip izgleda jednako oštro kao ostali |
| Cijena €3.99 | `price_label` €3.99 dok je stub; na Androidu cijena iz Google Playa | Odluka o cijeni je tvoja (vidi dole) |

## Datoteke

- **Novo:**
  - `game/scripts/camp/muncher_rig.gd` (`MuncherRig`);
  - `game/data/muncher/rig.json` i `animations.json` (iz paketa);
  - `game/assets/muncher/{parts,fx,nest}` (46 SVG);
  - `game/assets/pip/parts_knight` (26), `game/assets/pip/fx/k_*` (3), `game/assets/pip/hud/pip_hud_knight.svg`;
  - `game/scripts/ui/shop_premium_look_card.gd` (`ShopPremiumLookCard`).

  SVG-ovi su kopirani bez ugrađenog C2PA bloka (~7,7 KB po fajlu): vitez je 25 KB umjesto 227 KB, muncher 29 KB umjesto 386 KB.
- **Muncher:**
  - `arena_pest.gd`: crtanje krugova u slojevima zamijenio rig, krtičnjak i baner; pravila netaknuta.
  - Stare konstante gusjenice izbačene iz `ui_arena_v2.gd`.
  - `ui_arena.gd`: gnijezdo i keepout.
  - `merge_arena_controller.gd`: tutorial sakrije baner.
- **Sir Pip:**
  - `data/pip/rig.json`: dodaci sa `"skin": "knight"`, plus fx `k_star`, `k_tink` i `k_flag`.
  - `skins.json`: unos `knight` (`replace`, `gz`, `skin_layer`, `reactions`, `idle_detail`).
  - `animations.json`: 7 klipova.
  - `ui_pip.gd`:
    - dodaci samo za svoj skin, zamjena dijelova po pogledu, Godot z;
    - treći player „Skin" (pauzira se dok base klip sam pomjera ogrtač);
    - reakcije, idle detalj;
    - vlastita biblioteka animacija za skin s dodacima;
    - atlas bez overlaya drugih skinova.
- **Kozmetika i IAP:**
  - `cosmetics.json`: `pip_knight` (`source: iap`, `sku`, look `{"skin": "knight"}`).
  - `cosmetic_catalog.gd`: `is_iap_item`, `get_sku`, `get_pip_look`, `item_for_sku`.
  - `monetization_config.gd`: `SKU_PIP_KNIGHT`, `cosmetic_for_sku`.
  - `iap_manager.gd`: vlasništvo, grant, dev reset.
  - `cosmetics.gd` i `game_state.gd`: `grant_iap_cosmetic`, `revoke_iap_cosmetics`.
- **Shop i Ormar:**
  - `shop_screen.gd`: premium kartica, „Owned → obuci", skrol iz Ormara na karticu, toast.
  - `shop_buy_button.gd`: `owned_tappable`.
  - `item_card.gd` i `ui_wardrobe.gd`: „Premium" i „Free" ispod imena.
  - `wardrobe_sheet.gd`: tap na nekupljenog Sir Pipa vodi u Shop (`shop_requested(slot, item)`).
  - `item_preview.gd`: skin iz looka, `HOST_LIFT`.
- `export_presets.cfg`: novi folderi u `include_filter` (inače APK ne bi imao SVG-ove i JSON munchera).
- Paket je kopiran u `design_handoff_muncher_premium_pip/`.

## Kako je provjereno

- **Novi testovi:**
  - `muncher_rig_smoke.gd` (u pravoj Areni):
    - spava u rupi;
    - prvo buđenje: „!", baner, m_awake;
    - lov u 4 smjera (lijevo zrcaljeno);
    - sjemenka pobjegla, pa „hmph" preko lova;
    - led: m_freeze → m_frozen → m_thaw u zadnjih 0,25 s, kraj na 2 s;
    - prazno polje: m_doze → m_sleep_spot;
    - drugo buđenje bez banera i bez m_awake;
    - nova sesija ponovo pokaže baner;
    - z ispod oblačića tutoriala.
  - `premium_pip_smoke.gd`:
    - katalog i SKU;
    - Shop kartica money.buy → money.busy → Wearing;
    - Pip svuda knight;
    - coini i sjemenke netaknuti;
    - „Owned" tap ga obuče;
    - restore bez oblačenja;
    - druga kupovina = already_owned;
    - Ormar „Premium" pod velom, tap → Shop;
    - dev reset.
- **Ažurirani testovi:**
  - `pip_rig_smoke` (82 animacije, 4 skina, dodaci po pogledu, perjanica iz `parts_knight`, ogrtač iznad sjene a ispod repa, Skin player, reakcije);
  - `wardrobe_smoke`;
  - `arena_v2_fields_smoke`.
- **Snimci** (Godot, uz pregledač paketa):
  - tabla Sir Pip × 5 pogleda i ključni trenuci klipova;
  - tabla Nibbs × 16 klipova;
  - Arena na svijetloj i tamnoj livadi (Starfall Glade);
  - Home kartica, polje, Shop (dostupno / kupljeno / nošeno), Ormar (pod velom / nošeno);
  - run odozgo i glava na traci napretka.

## Performanse (laptop, AMD iGPU, GL Compatibility)

**Muncher — A/B, ista Arena, stari (gusjenica) prema novom (Nibbs)**, bez vsynca, razlika „s muncherom − bez njega":

| Stanje | Draw pozivi munchera | Primitivi | Frejm (ms) |
|---|---|---|---|
| Spava u gnijezdu | **51 → 2** | 2 476 → 31 | +0,6 → +0,3 |
| Lovi / jede | **44 → 3–4** | ~2 300 → ~0 | +1,9–2,4 → +0,4–0,6 |
| Led | **49 → 2** | 3 015 → 32 | — |
| Logika + animacija (tick) | — | — | 0,043–0,051 → **0,024** ms |

Sa vsyncom (kao igra): `arena_muncher_eats` 0 kasnih frejmova, najgori 18,7 ms; svi Arena scenariji 0–2 kasna.

**Jednokratno:**

| | Gdje | Cijena |
|---|---|---|
| Atlas munchera (46 SVG @1,5×) | pozadinski thread, kad se Arena napravi | 68–97 ms (+ ~2 ms upload) |
| Rig munchera | prvi tick kad je atlas spreman | ~5 ms + prvi klip 1,5–5 ms |
| Atlas Sir Pipa (@2×) | pozadinski thread (Shop / Ormar) | 185–217 ms (+ 3–7 ms upload) |
| Atlas Classica | isto | 113–144 ms |
| Sir Pip build + idle | | 6,4–7,6 ms (Classic 5–5,6) |

- Atlas Sir Pipa je bio 260–310 ms. Svaki skin je rasterizovao i overlaye drugih skinova (grančicu, oblake); sad ih preskače (pomaže i Classicu).
- Start huba je nakon dodavanja premium kartice imao jedan frejm ~61 ms: tekstura atlasa i rig viteza u istom frejmu. Pregled sada gradi rig frejm poslije teksture. `hub_boot_5s` je 7–10 kasnih, najgori ~43 ms (3 od 4 prolaza), isto kao prije viteza.
- Ako je Sir Pip **obučen**, njegov atlas se pravi pri startu na glavnom threadu, kao i svaki nošeni skin. To je ~200 ms umjesto ~130 za Classic, jednom po pokretanju.
- Svi atlasi su 1024 px široki. Sir Pip je u istom 1024 × 2048 kao Classic, Blossom i Sky, pa nema dodatne memorije osim njegove teksture kad se koristi. Atlas munchera je 1024 × 840.
- SVG: muncher 29 KB (limit 120), Sir Pip 49 KB (limit 150).

## Odluke koje čekaju tebe

- **Cijena Sir Pipa.** Paket predlaže €3,99 / $3,99: iznad impulsnih €1,99, ispod €4,99, isto kao Remove Ads. U igri je €3.99 dok je stub; na Androidu se prikazuje cijena iz Google Playa.
  - Proizvod `pip_knight` (non-consumable) treba napraviti u Google Play Console.
- **m_awake prije prvog lova.** Pri prvom buđenju u sesiji Nibbs se 1,4 s proteže prije nego krene (kao u pregledaču paketa). To je igraču u korist i vidi se samo jednom po sesiji. Ako želiš strogo 0,3 s, klip se može puštati dok već hoda.
- **Nekupljeni Blossom i Sky u Ormaru** su i dalje pod velom bez tapa; samo Sir Pip vodi u Shop. Isto ponašanje za sve skinove je jedan red koda, ako želiš.
