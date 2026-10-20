# design_handoff_run_pickups

Dvije stvari za Merge Meadow (brief `docs/04-experience/design-drafts/run-pickups-cd-brief.md`):
**A** puni redizajn pickupa u runu i **B** Camp kartica za 4 plaćene sezone.

## Šta otvoriti

| Fajl | Šta je |
|---|---|
| `design/RunPickups.dc.html` | A uživo: scena 1080 × 1920 s HUD-om v2, svih 8 livada, L0–L4, „usporeno ×4", 6 dodira izbliza, 4 Pip reakcije, idle na 8 livada, magnet 0 / 2 / 4, brojač FX sprite-ova |
| `design/CampPaidCards.dc.html` | B uživo: kartica na Camp stranici (tap na cijenu → buying → burst / failed), 4 sezone × 4 stanja, porodica uz Frost / Lantern / Amber, ink tablica |
| `design/Specs.dc.html` | mjere, vremena, krive, budžeti (čita `pickup_data.js`) |
| `design/pickup_data.js` | **izvor istine za A** (godot JSON-i su generisani iz njega) |
| `design/pickup_engine.js` | preview „engine" (= kako se slaže u Godotu: pool Sprite2D, samo transformi) |
| `design/pip_pickups.js` | 4 Pip animacije (isti `def()` format kao `design_handoff_pip`) |
| `design/camp_recipes.js` | **izvor istine za B** (recepti + ink + rosteri) |

Stranice se otvaraju direktno u pregledaču (prvo učitavanje traje par sekundi — 15+ živih scena).

## § Odlučeno

**A · pickupi**
- **Pip uzima, pickup ne nestaje.** `collect()` gasi koliziju i šalje `collected` odmah (brojanje isto), ali čvor ostaje i igra događaj iz `godot/pickup_fx.json`, pa tek onda `queue_free`.
- **Coin:** ulovi se na nos (C = Pip + (0, −46)), sabije se i okrene (frejm `coin_edge`), uskoči u Pipa; zlatni prsten + 3 krhotine. 0,26 s na terenu.
- **Sjeme:** iščupa se iz zemljice (zemljica se ugne i raspadne u mrvice), sadnica skoči u šape pa u džep na leđima (B = Pip + (0, 12)), mint prsten iz džepa.
- **★2:** mint oreol od latica (lavanda pri puknuću) + 2 iskrice; veći skok. **★3:** zlatni oreol, sadnica se u letu pretvori u t3 cvijet, zlatni prsten iz džepa, 2 iskrice; Pip `pickup_seed_rare`. Rijetkost se na stazi vidi po oreolu (ništa / 5 latica mint / 8 latica zlato + iskrice) — bez brojanja kružića.
- **Twin +2:** dvije sadnice (lijeva u lijevu šapu, desna 0,04 s kasnije u desnu), pečat ×2 iznad glave, pilula „+2", Pip `pickup_twin` (dva popa).
- **Niz coina:** razmak ≤ 0,6 s → n 1–5 (isto pravilo kao ton). Prsten raste (0,3 → 1 + 0,15·(n−1)), krhotine 3→5, iskrica na n3–n4, breskva prsten na n5, pilula i trzaj čipa malo veći. 5 / s izgleda kao crescendo, ne kao 5 istih bljeskova.
- **Magnet:** pravilo isto (u krugu = pokupljeno). Cijeli pickup doleti do C: `lerp(0,12, 0,2, d / 232)` s, `quad_in`, luk ⟂ 0,22·d, skala → 0,85; krug se trzne 4 % pri hvatanju. Krug ostaje diskretan (tačkasti, krem, 18°/s).
- **Čitljivost na 8 livada:** sve ima ink rub #2D3436 + krem #FFF8F0 rub (naljepnica, kao `stickerContrast` u Season Kitu) — bez sezonskih varijanti.
- **HUD:** krem pilula (ikona + „+1"/„+2") leti 0,3 s do CoinChipa (610, 124) / SeedChipa (806, 124), čip se trzne, broj raste pri dolasku. Poruka „+1 Ime" ispod SeedChipa ostaje kakva jeste.
- **Pip:** samo overlay (`pip.s`, `pip.r`, `head.r`, oči) → noge, šape i uši ostaju na `run_gallop`; x skretanja radi `player.gd` tween. Prioritet overlaya: coin < seed < twin < rare (niži ne prekida viši).

**B · plaćene kartice**
- Recept `camp` za sve 4 (9–10 slojeva, samo oblici iz `shapes`): Moonlit (mjesec između imena i dugmeta, humke s jazbinama, mahovina), Coral (dijagonalna obala, mreškanje, koralj, školjke, zvjezdača), Starfall (zvjezdano nebo, meteor, silueta jela, čistina, paprat), Ember (dimni pojas, trska, lokva s odsjajem, rogoz, žar). Rasuti elementi su samo u mirnoj zoni između imena i dugmeta.
- **Ink po sezoni:** Moonlit / Starfall / Ember `#FFF8F0` (min 11,46 / 14,42 / 13,99 : 1), Coral `#3D3D33` (min 6,64 : 1) — polje `ink` u receptu.
- **Raspored:** ime + zlatno dugme s cijenom (300 × 120, #E8C44A / #BA9D3B, tvrda sjena), bez lokota, coina i ★3. Ispod: oznaka **PREMIUM** (zlatna, ink rub) + „6 new flowers" + red od 6 cvjetova sezone (t3) u okvirima po rijetkosti (krem / mint / zlato). Isti rub, sjena, visine redova i dugme kao besplatna → ista porodica, a razlika se vidi odmah (nema traka, ima red cvjetova i PREMIUM).
- **Stanja:** `price` · `buying` (zlatno dugme spušteno 4 px bez sjene, tri tačke umjesto „…") · `burst` (isti prsten kao besplatna, „Unlocked", pa Home) · `failed` (kratka pilula „Purchase cancelled" 1,6 s, pa `price`). Tap na karticu van dugmeta = Home bez kupovine.
- Ember Fen nema cijenu u kitu (SOON) — u previewu stoji „€2.99*" samo kao primjer; stvarna cijena je uvijek `IAPManager.get_price_label()`.

## § Performanse (stvarni brojevi)

| | Budžet | Stvarno |
|---|---|---|
| Sprite-ova po dodiru (uklj. pilulu) | ≤ 8 | coin n1–2: 6 · n3–5: 8 · ★1: 7 · ★2: 8 · ★3: 8 · twin ★1: 8 · twin ★2/★3: 7 |
| Trajanje na terenu | ≤ 0,4 s | coin 0,26 · ★1 0,36 · ★2 0,38 · ★3 0,40 · twin 0,38 (pilula do čipa +0,3 s, HUD) |
| Istovremeno | 3 dodira → ≤ 24 | 3 × 8 = 24; scena ima brojač „FX max u petlji" |
| Idle | samo transformi | coin 3 · ★1 5 · ★2 8 · ★3 9 Sprite2D, 0 `_draw` po frejmu; 10 pickupa ≤ 90 statičnih čvorova |
| Atlas | 1 × ≤ 512² | `assets/pickup_fx_atlas.png` 512 × 512 (iskorišteno 512 × 398), 15 regija (`godot/pickup_fx_atlas.json`) |
| SVG ukupno | ≤ 60 KB | 13,9 KB neto, 20 fajlova (`assets/pickups` + `assets/fx`). Napomena: platforma pri snimanju dodaje c2pa `<metadata>` (~8 KB/fajl); izbaciti pri importu — ne utiče na teksturu |
| Pip animacije | ≤ 4, ≤ 0,4 s, overlay | 4: 0,22 / 0,30 / 0,40 / 0,36 s |
| Camp recept | ≤ 12, statično, unutar ruba | 9 / 10 / 10 / 10 slojeva; crta se jednom u 1026 × 312 unutar ruba 3 |
| Sadnice / cvjetovi | — | postojeće teksture cvjetova (t1 crop / t3), nisu nove |

## § Samoprovjera (§6.3, provjereno u pregledaču 2026-10-19)

1. Dodir izgleda kao da ga je Pip uzeo — pickup ne nestane prije reakcije: **da**
2. Coin i sjeme različit trenutak; ★2 / ★3 i twin +2 jasno različiti: **da**
3. Magnet: pickup doleti do Pipa (≤ 0,2 s); „u krugu = pokupljeno" ostaje: **da**
4. Niz od 5 coina u sekundi izgleda dobro i raste: **da** (scena „Niz 5 coina / s", 1,5× brzina, skretanje usred niza)
5. Čitljivo na svijetloj i tamnoj livadi; ne pokriva prepreke ni grm: **da** (FX ostaje u ~110 px oko Pipa, iznad staze; prepreke / grm nisu dirani)
6. Pip reakcije ne prekidaju trčanje ni skretanje: **da** — napomena: runtime ima jedan overlay slot, pa pickup zamijeni `lane_left/right` nagib (x tween skretanja ide dalje); ako treba oboje, drugi AnimationPlayer „Overlay2"
7. Sve 4 plaćene imaju recept `camp` u istom stilu; ništa van ruba: **da**
8. Plaćena kartica: samo cijena, sva 4 stanja; tekst ≥ 4,5:1 i na tamnim: **da** (min 6,64:1)
9. Budžeti §5 ispunjeni i napisani: **da**
10. Nigdje blur, glow, gradijent ni maska; ništa se ne crta po frejmu: **da** (crop sadnice = region AtlasTexture; ring = sprite, ne shader)

## Paket

```
design/      RunPickups · CampPaidCards · Specs (.dc.html) + support.js, pip_*.js, seasons_kit.js, pickup_*.js, camp_recipes.js, icons/, ref/flowers/ (kopije postojećih)
assets/      pickups/*.svg · fx/*.svg · pickup_fx_atlas.png
godot/       pickup_fx.json · pickup_idle.json · animations_additions.json · seasons_kit_camp.json · camp_paid_card.json · pickup_fx_atlas.json
```

## Prenos (agent, §8)

- `seed_pickup.gd` / `coin.gd`: `collect()` → kolizija off, `collected` emit, stanje „fly/event" po `pickup_fx.json`; `queue_free` na kraju.
- `player.gd` MagnetField: umjesto trenutnog `collect` pokreni let (`magnet.fly`), `collect` zove se pri ulasku kao danas.
- `seed_visual.gd` / `coin_visual.gd`: idle iz `pickup_idle.json` (Sprite2D iz atlasa, bez `_draw`).
- `run_controller.gd` `_on_coin_collected` / `_on_seed_collected`: bira `coin_n{1..5}` / `seed_r{1..3}[_twin]`, `_pip_play(event.pip)` uz `pip_priority`.
- `run_pickup_feed.gd`: pilula + let + trzaj po `hud`; `run_ring_fx.gd` se više ne koristi.
- `seasons_kit_camp.json` → `kits[id].camp` + `surfaces.camp.seasons`; `season_link_card.gd _apply_card_look`: `_ink = recipe.ink ?? CAMP_TEXT`; `_show_paid` po `camp_paid_card.json`.
