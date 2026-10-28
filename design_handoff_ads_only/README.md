# design_handoff_ads_only — Merge Meadow v1 bez kupovina pravim novcem

Godot 4.7 · GL Compatibility · artboard 1080 × 1920. Stil Shop v2 / Home v3 / Camp: ravne boje, obrub #2D3436, jedna tvrda sjena. Bez blura, glowa, gradijenata, maski.

## Sadržaj
- `design/ShopTabs.dc.html` — A1 tenda 3 taba, A2 tenda 4 taba (živo, ⟨guides⟩)
- `design/CoinPrice.dc.html` — C: jedno dugme cijene, S/M/L × sva stanja + živi test
- `design/ShopCoins.dc.html` — Shop Seasons · Looks (Sir Pip) · Boosters (F)
- `design/HomeSeasons.dc.html` — B1 Journey/Themes, B2 sva stanja, B3 štednja, B4 IAP
- `design/CampTheme.dc.html` — E: kartica sljedeće teme, živo + sva stanja
- `design/PremiumTag.dc.html` — D: oznaka „Special" + odluka o MONEY
- `design/Specs.dc.html` — sve mjere i boje na jednom mjestu
- `design/PriceButton, AwningTabs, SpecialTag, HubHeader, HubFooter .dc.html` — dijelovi
- `assets/icons/` — check_confirm.svg, check_ink.svg, icon_special.svg (novo)
- `godot/` — shop_tabs.json, coin_price.json, home_season_tabs.json, premium_tag.json

Svaki ekran ima prekidače: wallet 4,200 / 12,000 · v1 coini / IAP € · usporeno ×4 · reset.

## § Odlučeno
1. **Tenda (A):** tabovi pune 1032 px, razmak 12, `w = floor((1032 − 12(n−1))/n)`. n=3 → 336 (x 24/372/720), n=4 → 249 (= današnji Shop v2). Pruge se ne mijenjaju.
2. **Home tabovi (B1):** „Free / Premium" → **Journey** (sjemenka, krem) · **Themes** (zvjezdica, #C2E2FA). Journey je uvijek prvi i otvoren po defaultu. ID-jevi `free` / `premium` u kodu ostaju — mijenja se samo prikaz.
3. **Coin cijena (C):** S 300×120 / M 320×120 / L 360×132; font 44 / 52 / 56. Širina fiksna u svim stanjima. Format „10,000" kroz `UiChrome.format_count` (kao header).
4. **Potvrda:** ink lice + zlatna **SVG** kvačica iste veličine kao novčić + traka 3 s. Nema „✓"/„√" glifa iz fonta. +0 px širine.
5. **„Need N more coins":** jedan oblačić #FFE8B8 za Shop, Home i Camp (zamjenjuje toast), 1,6 s. Camp: ispod dugmeta. Oblačić (~431 px) je širi od dugmeta i namjerno smije 1,6 s prekriti susjede (Camp okviri cvijeća, Home pilula štednje).
6. **Kupljena tema:** Shop kartica → „▶ Play"; Home kartica → „✓ Yours" (veliko Play dugme je ispod kartice). Font u kupljenim stanjima: „Yours"/„Wearing" min(font, 48), „Play" min(font, 52) — vidi coin_price.json.
7. **Oznaka (D):** „Special" + zvjezdica, #C2E2FA, L/M/S. Riječ „Premium" se ne prikazuje u v1.
8. **MONEY #D4A5FF:** u v1 nigdje; u IAP režimu samo lice € dugmeta.
9. **B3:** mirna pilula „4,200 / 10,000" (isti oblik kao pilule besplatnog puta); nestaje kad je kupljeno i u IAP režimu. Bez procenata, bez tajmera.
10. Pillar 2: bez paketa coina, popusta, tajmera, „limited", „best value", „buy coins".

## § Performanse
| Stavka | Vrijednost |
|---|---|
| Rad po frejmu | 0 (`_process` nije potreban; sve na signal/Tween) |
| Tenda | crta se jednom (`_draw` na ready / resize / promjenu `visible_tabs`) — 18 pruga + n tabova |
| Promjena stanja dugmeta | samo StyleBoxFlat + tekst + ikona (bez novih nodova) |
| Najduži efekat | 0,6 s (kupovina: pop 0,22 + prsten 0,42 paralelno) |
| Drhtaj / puls čipa / pop | 0,32 / 0,30 / 0,22 s |
| Timer potvrde | 1 Timer 3 s (`T_CONFIRM_TIMEOUT`) + 1 Tween scaleX trake |
| Oblačić „Need N" | 1 Label + 1 Timer 1,6 s; 1 instanca po ekranu |
| SVG (nove ikone) | ~0,7 KB crteža; sa C2PA metapodacima ≤ 8 KB svaka (≤ 60 KB ✔). Na importu u Godot metapodaci se ignorišu |
| Najveći SVG u paketu | pip_hud_knight.svg ≈ 30 KB (postojeći, ≤ 60 KB) |
| Maske / blur / glow / gradijenti | 0 |
| Prozirnost | samo prsten kupovine: `modulate.a` 1→0 na 1 spriteu, 0,42 s; sjene su neprozirne boje s alfom u StyleBoxFlat (bez blend pass-a) |

## § Samoprovjera (§6.3) — provjereno u pregledaču
1. Shop tenda 3 taba popunjena, bez rupa, srednji tab na x 540 — **da**
2. Ista tenda za 4 taba = Shop v2 (249 / 261 / 24) — **da**
3. Home bez „Free / Premium"; Journey prvi i glavni — **da**
4. Kartica teme na Homeu u svim stanjima (može / fali / Need / potvrda / kupljeno / aktivna / IAP) — **da**
5. Jedan sistem cijene za Shop, Home i Camp — **da**
6. Potvrda: SVG kvačica, širina ista kao obično dugme — **da**
7. 5 cifara („10,000") staje u S, font ≥ 44 px — **da** (S = 44)
8. Format broja kao header („10,000") — **da**
9. Jedna oznaka + jedna boja za „posebno za coine" na 4 mjesta; odluka o MONEY zapisana — **da**
10. Nigdje „€", „$", „Restore purchases", „Purchase cancelled", „billing" u v1 režimu; nema paketa coina / popusta / tajmera / „limited" / „best value" — **da** (€ samo u prekidaču IAP režima)
11. Efekti ≤ 0,6 s, ništa po frejmu, bez blura/glowa/gradijenata/maski, SVG ≤ 60 KB — **da**

## Ne dira se
Ormar kartica u PremiumTag je skica — razmake uzeti iz `game/scripts/ui/item_card.gd`.

Cijene, pravila kupovine, besplatni put, balans, header/footer, Season Kit, Settings, zvuk. Nema novih ekrana ni tabova.
