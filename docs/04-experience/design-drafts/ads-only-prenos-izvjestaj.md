---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, monetizacija, coini, shop, home, camp, claude-design, izvjestaj, prenos]
povezano:
  - ads-only-cd-brief
  - ads-only-cd-izvjestaj
  - ads-only-coini-izvjestaj
  - design-pillars
  - CHECKPOINT
ai_sažetak: "Paket design_handoff_ads_only (Claude Design) prenesen u igru 2026-10-28: tenda puni 1032 px (3 taba 336), jedno dugme coin cijene S/M/L za Shop, Home i Camp (fiksna širina, SVG kvačica + traka 3 s, „10,000“), oblačić „Need N more coins“, oznaka „Special“ umjesto „Premium“, Home tabovi Journey / Themes i pilula štednje; čeka playtest."
---

# v1 bez kupovina — prenos paketa u igru

> Roditelj: [[../_index|04-experience]] · Brief: [[ads-only-cd-brief|ads-only-cd-brief]] · Paket: `design_handoff_ads_only/` (README § Odlučeno) · Snimke poslije prenosa: `ads-only-prenos-ref/` (a01–a15, isti snimač `game/scripts/dev/ads_only_capture.gd`)

## Ukratko

Paket je stigao u dvije verzije. Prvu sam provjerio u pregledaču (sve § 6.3 stavke drže; 5 sitnica u mockovima), Claude Design ih je ispravio u drugoj verziji, i ta je prenesena. Logika, cijene i dva tapa se ne mijenjaju — mijenja se samo izgled.

## Šta je u igri

| Dio | Gdje | Šta |
|---|---|---|
| **A · Tenda** | `UiShopV2.tab_w / tab_step / tab_x0`, `shop_tab_bar.gd` | Tabovi pune 1032 px, razmak 12: 3 taba 336 (x 24 / 372 / 720, srednji na 540), 4 taba 249 (= Shop v2) |
| **C · Coin cijena** | `ui_coin_price.gd` (novo), `ShopBuyButton.size_key`, `home_v3_card_content.gd`, `season_link_card.gd` `_PriceFace` | Jedno dugme: S 300×120 / 44 (Camp, Shop sezona), M 320×120 / 52 (Looks, Boosters, Sir Pip), L 360×132 / 56 (Home tema). Širina ista u svakom stanju. Stanja buy · short · confirm (SVG `check_confirm` umjesto novčića + traka 8 px 3 s) · buying (mint „✓ Yours“ + prsten 0,42 s, ukupno 0,6 s) · owned („Yours“ / „Wearing“ ≤ 48 px) · play (≤ 52 px) · € (MONEY, samo s IAP-om). Broj „10,000“ kroz `UiChrome.format_count` |
| **„Need N more coins“** | `need_coins_bubble.gd` (novo) | Jedan oblačić #FFE8B8 (h 64, 34 px, 1,6 s) iznad dugmeta, desno poravnat, rep na sredini; u Campu ispod. Zamjenjuje Shop pilulu, Home toast i Camp toast. Broj također „5,800“ |
| **D · „Special“** | `special_tag.gd` (novo) | Zvjezdica + „Special“ na #C2E2FA, rub 3: Shop Sir Pip L, Camp tema M (bila žuta „PREMIUM“), Ormar S (bila ljubičasta „Premium“). Ljubičasta MONEY samo na € licu |
| **B1 · Home tabovi** | `home_v3_tabs.gd` | „Journey“ (sjemenka, krem) · „Themes“ (zvjezdica, #C2E2FA). ID-evi `free` / `premium` ostaju |
| **B · Kartica teme** | `home_v3_card_content.gd` | Rub „Special“ plavi 8 s ink obrubom 3 (bio zlatni); coin cijena L; kupljena „✓ Yours“ (Play je ispod) |
| **B3 · Štednja** | isto | Mirna pilula „4,200 / 10,000“ iznad cijene (mint kad je dovoljno, nikad preko cijene); nema je kad je kupljeno ni u IAP režimu |
| Ikone | `game/assets/ui/chrome/` | `check_confirm.svg`, `check_ink.svg`, `icon_special.svg` (+ `.import`, `svg/scale` 2 — izvor je 48 px) |

Kupljena kozmetika koja nije obučena sad piše „Yours“ (bilo „Owned“), kao u paketu.

## Odstupanja

- **Camp u IAP režimu** (kad se merchant riješi) i dalje crta staro zlatno dugme s € cijenom; MONEY lice tamo nije preneseno — v1 ga ne prikazuje. Shop i Home € lice imaju.
- **Ormar** — „Special“ S stoji na mjestu današnje pločice ispod imena (ne lijevo gore +16 kao u skici), jer je tamo kvačica nošenog skina (`item_card.gd`, kako README kaže).
- Camp burst poslije kupovine ostaje svoj (prsten kartice); dugme za to vrijeme pokazuje mint „✓ Yours“.

## Testovi (Linux, headless)

- Novi `ads_only_design_smoke`: tenda 3 / 4 taba, srednji tab na 540, S/M/L mjere, „10,000“ staje u S, širina 300 u buy / confirm / play / short, oblačić iznad dugmeta s „5,800“-formatom, Sir Pip „Special“ L, Home Journey / Themes, L 360×132 i pilula „4,200 / 10,000“ (nema je s IAP-om).
- Ažurirani na novi format i oblačić: `coin_offers_smoke`, `iap_off_smoke`, `shop_cosmetic_buy_smoke` („Yours“), `season_home_smoke` (L 132).
- **GUT 149/149**; smoke **80/83** — tri pada (`arena_nav_lock_smoke`, `fixes_1016_smoke`, `levels_endless_smoke`) padaju isto i na kodu prije prenosa u ovom Linux okruženju (tajming runde / Endless), nisu od ovog prenosa. Na Windowsu provjeriti `scripts/smoke-all.ps1`.
- Snimke `ads-only-prenos-ref/` (Godot, Xvfb + opengl3): Shop 3 / 4 taba, potvrda s trakom, oblačić, Boosters, Sir Pip, Home Journey / Themes, štednja, Camp cijena / potvrda / oblačić ispod.

## Playtest (debug build)

1. Shop: 3 taba pune tendu; tap na temu bez coina → drhtaj + puls čipa + oblačić 1,6 s; s coinima prvi tap tamno + traka se skuplja 3 s, drugi tap mint „✓ Yours“ s prstenom pa „▶ Play“.
2. Home → Themes: plavi tab i rub, pilula štednje, isto dugme L; poslije kupovine „✓ Yours“.
3. Camp (Settings → Developer → Unlock all seasons): „Special“ M, dugme S, oblačić ispod dugmeta.
4. Ormar → Pip: Sir Pip s „Special“.

## Povezano

- [[ads-only-cd-brief|ads-only-cd-brief]] · [[ads-only-cd-izvjestaj|ads-only-cd-izvjestaj]] · [[../../06-production/ads-only-coini-izvjestaj|ads-only-coini-izvjestaj]] · [[../../06-production/CHECKPOINT|CHECKPOINT]]
