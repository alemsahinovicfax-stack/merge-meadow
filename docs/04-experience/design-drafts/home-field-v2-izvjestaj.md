---
type: iskustvo
status: aktivan
milestone: M8
tags: [dizajn, ui, home, polje, sezona, claude-design, izvjestaj]
povezano:
  - home-field-v2-cd-brief
  - home-field-cd-brief
  - hub-chrome-v2-izvjestaj
  - changelog
ai_sažetak: "Izvještaj o prenosu paketa design_handoff_home_field_v2 u Godot 2026-09-25: livada je postala cijela stranica, chrome pluta preko nje — chest i korpa gore lijevo, nadogradnje gore desno, dolje manji red Seasons · Play · Endless."
---

# Home — polje sezone, pass 2 — izvještaj o prenosu

> Roditelj: [[04-experience/_index|04-experience]] · brief: [[home-field-v2-cd-brief]] (§ Implementacija) · datum: 2026-09-25

## Ukratko

Odnos je obrnut. Livada je bila 37 % stranice, sada je **100 %**, a sve kontrole plutaju preko nje i zauzimaju oko **13 %**.

- **Livada: 606 → 1633 px.** Nema više okvira ni radiusa — ona je stranica. Pip od 190 px konačno ima gdje hodati.
- **Chest i korpa gore lijevo**, jedno ispod drugog, **iste plocice 180 × 180**. Gift se u polju do sada uopšte nije vidio.
- **Nadogradnje su jedna plocica gore desno** umjesto dvije kartice koje su trošile 400 px stranice.
- **Donji red je `Seasons · Play · Endless`:** 236 × 124 · 432 × 140 · 236 × 124. Bilo je 300 × 124, 656 × 176 i 360 × 176 u dva odvojena reda.
- **Play je centriran na x 540 i ne pomjera se** kad se Endless otključa — palac uvijek pada na isto mjesto.

## Šta se vidi na ekranu

| Dio | Izgled |
|---|---|
| **Livada** | Tri trake: nebo 0–523, daljina 523–1110, prednja 1110–1633. Gornja grupa kontrola stoji cijela na nebu, donji red cijeli na prednjoj traci — nijedna kontrola ne prelazi granicu trake. |
| **Kontrast** | Svaka kontrola je **neprozirna naljepnica** (krem / peach / lavanda / mint / zlatna) s rubom 3 px `#2D3436`. Jedno rješenje za svih 8 boja livade; rub drži najmanje 6,14 : 1 (Moonlit, prednja traka). Svijetli tekst nikad ne stoji direktno na livadi. |
| **Sjena** | Znači „pritisni me": pritisljive plocice imaju tvrdu sjenu 0 8 0, info (čip, oblačić) samo rub. |
| **Gift** | Ista `HomeGiftCard` kao na biranju sezone, nova instanca u polju — roze tačka kad poklon čeka, bez tačke prije kraja tutoriala. |
| **Korpa** | Dijeli Gift okvir 1:1, mijenja se samo sadržaj: lokot („Basket") · sjeme („Choose" + prsten pažnje) · portret + **„+5 %"** u mint pilulici. Tako je bonus stalno na ekranu, ne samo u pickeru. |
| **Nadogradnje** | Znak ︽ i **dvije mini trake nivoa** (Magnet, Loot) — napredak se vidi prije tapa. Zlatna tačka = nešto se može kupiti sada. |
| **Ime sezone** | 56 px ink na nebu; tagline otpada (stoji na kartici jedan tap nazad). |
| **Čip izraslih** | Ispod imena, s ikonom cvijeta iz chrome v2 — broji isto cvijeće koje header zove Flowers. |
| **Sheetovi** | Oba su krem bottom sheet: korpa 1326, nadogradnje 922. Palac dohvata dugmad. |
| **13 mjesta** | Preraspoređena u 4 dubine (88 · 116 · 136 · kruna 168), sve 20–30 % veće nego prije. Drugi cvijet tipa stoji iza prvog, pa se vidi kako tip „raste unazad". |
| **Pip** | Pojas 778 × 131 ispred svih cvjetova, iznad donjeg reda — nikad pod kontrolom, nikad iza cvijeta. |

## Šta testirati u igri

1. Uđi u sezonu s Home ekrana — kartica se razvuče u cijelu stranicu, pa chrome uplovi (Play prvi).
2. Prođi kroz nekoliko sezona: Amber i Moonlit su najgori kontrast; kontrole moraju ostati čitljive na obje.
3. Tapni korpu prije prvog mergea — plocica se trzne i oblačić objasni zašto.
4. Izaberi sjeme: prsten pažnje stane, plocica pokaže portret i „+5 %".
5. Otvori nadogradnje gore desno; kupi jednu — traka nivoa na plocici poraste, tačka nestane kad nema više cvijeća.
6. Swipe po livadi mijenja hub stranicu; swipe po plocici ili donjem redu ne.
7. Prije kraja tutoriala donji red ima samo Seasons i Play, a Play ostaje na istom mjestu.

## Odstupanja od paketa (namjerna)

- **`FieldOverlay` je dijete `MainMenu`-a, ne `SeasonStage`-a** — `MainMenu` jeste stranica, pa koordinate iz paketa važe 1:1 bez diranja instancirane scene.
- **Nema zajedničkog `SheetLayer`-a** — `BasketPickerOverlay` već radi u korijenu, `UpgradesOverlay` je dodan pored njega.
- **Play u polju je zaseban čvor** (`FieldPlayButton`): `%PlayButton` koji je paket htio preseliti **isti je onaj** na biranju sezone, pa bi selidba ostavila taj ekran bez Play dugmeta. Isto rješenje kao za Gift — druga instanca, jedan handler.
- **Brojač izraslih je izašao iz livade** — livada emituje `grown_changed`, overlay crta čip.
- **Endless nosi „∞ Endless" kao tekst**, ne crtani dvostruki prsten.
- **`home_basket_visual.gd` je zadržan** unutar plocice (novi omjeri) da T3 putanja koju smoke čuva ostane ista.

## Testovi

- Novi **`home_field_overlay_smoke`**: livada 1080 × 1633, rect svake kontrole, dodir ≥ 120, kontrole u `block_hub_swipe` a ime i čip nisu, nijedno od 13 mjesta ni Pip nisu pod keepoutom, oba sheeta se otvaraju i zatvaraju, i na ekranu je **tačno jedan** loop.
- Ažurirani **`season_meadow_smoke`** (donji red, keepout umjesto sudara s karticama, sheet nadogradnji, Gift + korpa iste mjere), **`home_basket_picker_smoke`** (plocica umjesto kartice) i **`season_home_smoke`**.

## Poznata ograničenja i sljedeći koraci

- Paket `design_handoff_home_field_v2/` je u korijenu repoa, uz ostale CD pakete.
- `ui_attention.gd` je ostao bez korisnika — jedini loop je sada unutar `FieldBasketButton`.
- Prelaz nazad (polje → biranje sezone) nije dobio `chrome_out` fazu iz paketa; chrome nestaje s poljem.
- Ideje iz paketa koje nisu rađene: tap na izrasli cvijet pokazuje zalihu, cvijet iz cijene leti do trake nivoa, y-sort Pipa među redovima.
