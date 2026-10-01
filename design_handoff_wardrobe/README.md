# Wardrobe (Ormar) — handoff

Novi ekran: igrač bira kozmetiku koju je kupio u Shopu. Otvara se s polja sezone, preko ekrana, kao treći sheet (porodica korpe 1326 i nadogradnji 922). Mehanika, ekonomija, cijene i Shop se ne mijenjaju. Jedan dizajn.

## Šta otvoriti
- `design/FieldWithWardrobe.dc.html` — polje sezone s ikonom ormara, interaktivno (Looks → biraj → Close / tap na scrim / povuci sheet dolje → Pip skoči u novom skinu ili toast). Prop `season` (8), `endless` (bool), `zones` (keepouti, Pip zona, 13 mjesta), `newDot`; za kadrove `openT`, `hopT`, `ringT`, `toastText`, `equipped`, `owned`.
- `design/Wardrobe.dc.html` — sheet 1080 × 1326. Prop `slot`, `owned[]`, `equipped{}`, `extra` (bool: + demo podaci, 8 slotova / 12 Pip skinova), `season`, `demoN` (N generisanih stavki), `gridScroll`, `tabScroll`, `onClose(pending, changed)`.
- `design/ItemCard.dc.html` — JEDNA kartica za sve slotove (worn / owned / none, Default, New).
- `design/ItemPreview.dc.html` — vrste pregleda `companion · meadow · album · swatch`, ista komponenta za karticu (210 × 150) i pozornicu (1032 × 300).
- `design/Wardrobe Specs.dc.html` — sva stanja §8.1, anatomija, pravila mreže i tabova, proširenje, primjena, gdje se vidi, skinovi, živa samoprovjera (§9 na dnu, isto u konzoli `SELFCHECK …`).
- `design/wardrobe_data.js` — logika mockupa: učitava `../godot/cosmetics.json` (rezerva: ugrađena identična kopija), demo zakrpa, recolor, boje runa. Nije tokens fajl.
- `design/icons/` — NOVI asseti (ikona ormara, 3 ikone slota, rezervna ikona, ink Shop ikona, pečeni `pip_blossom.svg` / `pip_sky.svg`).
- `design/demo/` — ikone demo slotova (samo za §8.1/6, ne ulaze u igru). `design/ref/` — nepromijenjene kopije iz home_v3 / shop / arena_v2.
- `godot/` — `cosmetics.json` (katalog), `wardrobe_export.json`, `ui_wardrobe.gd`, `wardrobe_tree.txt` (stablo + red prenosa).

## § Odlučeno
- **Ikona = pločica polja 180 (876, 1265, 180, 180)**, isti StyleBox kao Gift / korpa / nadogradnje (`UiHomeField.tile()`, glyph 84, rub 3, tvrda sjena 8). Stoji u desnoj koloni pločica (x 876 = Upgrades), 16 iznad donjeg reda (1461 − 16) — isti razmak kao Gift → korpa. Iznad Endlessa je (774–1010), ali poravnata s pločicama, ne s Endlessom, jer nije dio Endlessa. Kad Endless nije vidljiv (tutorial), ostaje na mjestu.
- **Čita se kao izgled:** roze glyph (PINK `#FFCCD5`, jedina boja pločica koja na polju još nije zauzeta) + vješalica + natpis **„Looks“** — isto ime kao sekcija Looks u Shopu („for coins · looks only“). Nema novčića (≠ Shop), nema zupčanika (≠ postavke).
- **Sukob 1 — Pip:** `PIP_BASE_ZONE` (151, 1306, 778, 131) → **(151, 1306, 614, 131)**. Stopala do x 765 → desni rub Pipa 860 = lijevi rub novog keepouta → 16 do pločice (= BLOCK_GAP). `PIP_DEFAULT_BASE` (756, 1404) se ne mijenja: Pip „kod kuće“ stoji pored svog ormara (25 px). Lijevi rub zone i donji red se ne diraju.
- **Sukob 2 — cvijeće:** najbliži cvijet #11 [88, 30, 136] = (882, 1007, 136, 136) završava na 1143 → 122 px iznad pločice; #10 je 95 px lijevo. Novi keepout **`Rect2i(860, 1249, 212, 212)`** (pločica ± 16, kao Upgrades keepout); ne siječe nijedno od 13 mjesta.
- **WardrobeDot** (mint 48, gore lijevo kao UpgradeDot) samo kad postoji tvoja stavka s `new_since` > zadnja viđena verzija kataloga. Danas nikad (sve stavke `new_since: null`).
- **Sheet 1326 = BasketSheet** (top y 307): grabber, naslov 56, sub 40, Close 132 — ista porodica. Sub „Looks only. Tap one to wear it.“ je i Pillar 2 rečenica.
- **Raspored:** PreviewStage 1032 × 300 (uvijek vidljiv) → SlotTabs 120 → ItemGrid (skrola) → Close. Pozornica pokazuje izabranu stavku u kontekstu (Pip na livadi aktivne sezone, staza runa, stranica Albuma) + chip „gdje se vidi“ iz `applies_to`.
- **Jedan tap = izbor**, najviše jedna stavka po slotu; tap na Default skida. Izabrana kartica = picker „chosen“ jezik (rim `#FFF6D6`, rub 4 ink) + ✓ 60. Aktivni tab = peach (kao footer/Shop jump chip) — navigacija i izbor se nikad ne miješaju.
- **Ne prodaje:** stavka iz Shopa koju nemaš se ne crta (ormar = tvoje stvari). Jedini put u Shop: zadnja ćelija mreže „More in Shop“ (isprekidan rub), ili dugme u EmptyState. Nijedna cijena, nijedno dugme za kupovinu. pip_sky u stanju §8.1/2 se zato ne vidi.
- **Kartica „none“** (veo + katanac, kao Home v3) postoji samo za stavke drugog izvora (`source` season / event, kasnije): „otključava se igrom“, nije dodirljiva.
- **Prazno stanje:** Default (nošen) + EmptyState preko 3 kolone s rečenicom slota („Pip's looks come from the Shop.“) i dugmetom More in Shop. Tabovi ostaju — igrač vidi koji slotovi postoje.
- **Zatvaranje JE snimanje:** Close, tap na scrim, povlačenje > 160 px i Android back rade isto. Nema Save. Zatvaranje usred otvaranja se prihvata (tween iz trenutnog položaja).
- **ApplyMoment:** slot koji se vidi na polju (`applies_to` ima `field`) → Pip skoči u novom skinu (1,18 / 280 ms, kao combo hop u Areni) + jedan krem prsten oko stopala (500 ms). Slot koji se na polju ne vidi → toast iz `slot.toast` („Runs use Sunset Meadow“), 2,6 s. Nijedan loop.
- **Pip skin na pravom artu:** recolor `pip_idle.svg` po mapi iz JSON-a (tijelo `#A8E6CF`, svijetlo `#D4F5E4`, obrazi `#FFB88C`). Obrub, oči, crtež netaknuti. 0 KB po novom skinu; svaki budući skin = 2–3 hexa. Pravilo: L(tijelo) ≥ L(`#A8E6CF`) → dvostruki rub ostaje ≥ 3,00 : 1 (Blossom 3,07, Sky 3,05). Pečeni `pip_blossom.svg` / `pip_sky.svg` su rezerva i dokaz izgleda, generisani istom mapom.
- **Tint livade samo u runu** (+ Shop preview i pozornica ormara). Polje sezone: ne — livada JE identitet sezone, a kartica na Homeu i polje dijele iste piksele u prelazu (tint bi napravio šav ili bi obojio sve kartice istom bojom). Arena: ne — 8 livada su 8 mjesta s vlastitim paletama; ×1,08 / 0,94 / 0,86 bi Frost Orchard učinio toplim, a Moonlit ljubičastim. Kontrast sjemenke bi ostao (dvostruki rub ne ovisi o polju), ali identitet ne.
- **Okvir albuma:** Journal kao danas; u ormaru stranica Albuma iz Shop pregleda (ram 10 `#E8C44A`, naslov × 0,8).
- **Opisi stavki** ostaju doslovno (katalog se ne mijenja), iako „in runs“ više nije tačno — vidi Otvoreno.

## § Primjena
| Slot | applies_to | Gdje se vidi | Kako (tokeni) |
|---|---|---|---|
| `pip_skin` | field, season_card, arena, run, run_hud, camp, shop | polje sezone (`season_field_pip.gd` → `UiHomeV3.draw_pip`), kartica sezone na Homeu, Arena (`pip_placeholder_control.gd`), run (`pip_visual.gd`), run HUD CompanionChip i Camp (`pip_placeholder_control.gd`), Shop „With it“ | `PipAssets.get_texture(skin)` = `pip_idle.svg` + `look.recolor` → `Image.load_svg_from_string` → ImageTexture, keš (skin, scale). `PipDraw` se više ne koristi za skin. Refresh na `cosmetics_changed`. |
| `meadow_bg` | run, shop | pozadina runa (`lane_background.gd`), Shop pregled, pozornica ormara | `modulate = look.tint × SeasonTheme.bg_modulate(season)` — logika kao danas, tint dolazi iz JSON-a. Polje sezone i Arena: ne (§ Odlučeno). |
| `journal_frame` | journal, shop | Bloom Album u Journalu, Shop pregled, ormar | `look.frame {color #E8C44A, width 10, radius 14}` + `look.title_modulate 0,8` (= današnji `get_journal_title_color`). |

Primjena: `Cosmetics.apply_wardrobe(pending)` na početku zatvaranja → jedan `save_player_save()` → `GameState.cosmetics_changed(changed_slots)` → svaki čvor iz `applies_to` se osvježi bez restarta (hub stranice, Pip na polju, Arena, Camp; run čita pri startu).

## § Proširivost
- **Nova stavka** = jedan zapis u `items[]`: `id, slot, title, description, coin_cost, source, order, new_since, look`. `look` ima polja koja traži vrsta pregleda slota. Kartica, mreža, tab-tačka „new“ i pozornica rade sami.
- **Novi slot** = jedan zapis u `slots[]`: `id, title, icon, order, preview, preview_args, applies_to[], allow_default, default_title, toast, empty_text`. `preview` bira postojeću vrstu: `companion` (bilo koji lik s SVG artom + recolor; Mochi = `subject: mochi`), `meadow` (tint pozadine runa), `album` (frame / paper / title_modulate), `swatch` (rezerva: 1–2 boje). Ikona 128 u stilu chrome ikona; bez ikone → `slot_generic.svg`.
- **Mreža:** uvijek 4 kolone × 240 (gap 24 = 1032). Ćelije = Default + vidljive stavke (po `order`) + ShopLink | EmptyState (span 3). Redova ⌈n / 4⌉; mreža skrola, pozornica/tabovi/Close stoje. 1 stavka → 1 red; 5 → 2 reda; 30 → 8 redova.
- **Tabovi:** ako svi stanu u 1032 → rastegnu se (3 slota); inače prirodna širina i vodoravni skrol, aktivni ≥ 24 od ruba, zadnji vidljivi uvijek odsječen kao znak (8 slotova). Bez fade-a.
- **Izvori:** `source: shop` (danas) — skriveno dok nije tvoje; `season` / `event` — vidljivo pod velom, `source_ref` kaže odakle.
- **Dokaz:** Specs §5 — `extra` dodaje 5 slotova i 10 Pip skinova (jedan `source: season`, jedan `new_since: 2`) samo kroz `withPatch(CATALOG, DEMO)`; `demoN` generiše 1 / 5 / 30 stavki. Komponente su iste datoteke. Demo podaci su u `wardrobe_data.js → DEMO` i NISU u `cosmetics.json`.
- **Save igrača se ne mijenja:** `owned_cosmetics {id: true}`, `equipped_cosmetics {slot: id}`; nema ključa = Default.

## § Šta se briše
- `CosmeticCatalog.ITEMS` (dict u kodu) → `game/data/cosmetics/cosmetics.json`; isti id / slot / cijena (provjereno, Specs §9/6).
- `CosmeticCatalog.get_pip_palette()` i palete body/ear/ear_inner/outline → `look.recolor`.
- `pip_visual.gd`: grana „skin opremljen → `_use_draw_fallback = true` → PipDraw“. `PipDraw` ostaje samo kao rezerva kad SVG nedostaje.
- Shop `CosmeticPreview` polovina `h.draw` (PipDraw) → sprite sa skinom (izgled kartice Shopa isti).
- „Skidanja nema“ — sada Default u svakom slotu (`allow_default`).
- `UiHomeField.PIP_BASE_ZONE` (151, 1306, 778, 131) → (151, 1306, 614, 131).

## § Samoprovjera
Provjereno 2026-10-01 u `design/Wardrobe Specs.dc.html` (Chromium), mjereno iz DOM-a (okviri polja: koordinate pretvorene u px stranice); živi tok je niz pravih `click()` na elementima u okviru „Probaj uživo“. Isti ispis: Specs §9 i konzola `SELFCHECK`.
1. **da** — 4 okvira (Country / Moonlit × sa / bez Endlessa): pločica (876, 1265, 180, 180); do Endlessa 32 (bez Endlessa nema), do najbližeg cvijeta 95, do Pipa kod kuće 25, do Pipa na najdesnijem mjestu zone 16. 0 presjeka.
2. **da** — WardrobeButton 180 × 180, kartica 240 × 272, tab 120, ShopLink 120 / 240 × 272, Close 132. Najmanji tekst 34 px („New“), sve ostalo ≥ 36. Najmanji kontrast 5,71 : 1 (INK_SOFT na DISABLED); ink/krem 12,04, ink/peach 7,54, krem na chipu pozornice 9,28.
3. **da** — 15 WardrobeSheet okvira, svaki tačno 1 DefaultCard. Živi tok: Pip Blossom → Close → Pip na polju u Blossomu; ponovo Looks → Classic Pip → tap na scrim → Pip opet mint.
4. **da** — 15 okvira: najviše 1 ShopLink po ekranu, 0 cijena, 0 „buy / coins / price / $ / €“.
5. **da** — `extra`: 8 SlotTab, 12 ItemCard u slotu Pip (+ Default); `demoN` 1 / 5 / 30 ItemCard. Iste tri komponente, druga je samo vrijednost kataloga.
6. **da** — katalog učitan iz `godot/cosmetics.json`, identičan ugrađenoj kopiji; pip_blossom pip_skin 250 · pip_sky pip_skin 200 · meadow_sunset meadow_bg 150 · meadow_lavender meadow_bg 180 · journal_gold journal_frame 120.
7. **da** — 117 slika Pipa na stranici (polje 17, kartica sezone 1, Arena 1, run 4 uklj. HUD, pozornica 11, kartice …): sve imaju geometriju `pip_idle.svg` bajt-po-bajt, razlika samo u hex bojama; 0 PipDraw.
8. **da** — Pip na polju promijeni skin u istom kadru kad se sheet zatvori; riječ „Save“ se u ormaru ne pojavljuje.
9. **da** — 0 gradijenata, 0 blur / drop-shadow filtera, 0 mekih sjena (sve sjene blur 0), 0 beskonačnih animacija (header/footer = postojeći chrome v2, nije ocjenjivan).

**Budžet:** novi asseti u `design/icons/` (8 SVG) — sadržaj ~4,6 KB; s provenance `<metadata>` blokom koji dodaje alat 68,7 KB ukupno (< 100 KB). Blok se smije obrisati pri uvozu. Novi skinovi u igri: 0 KB (mapa u JSON-u).

## Otvoreno
- Opisi `pip_blossom` („… for Pip in runs.“) i Shop stringovi `SLOT_TITLES` / `SLOT_EQUIPPED_NOTE` („in runs“, „Pip wears this in runs.“) postaju netačni kad skin radi svuda. Predlog (samo tekst, bez izmjene Shopa): „Soft pink accents for Pip.“ i „everywhere · wear one“. Treba potvrda.
- `Image.load_svg_from_string` na slabijem Androidu: rasterizovati jednom po (skin, veličina) pri startu / na `cosmetics_changed`, ne svaki kadar. Ako se pokaže sporo → uvoz pečenih `icons/pip_<id>.svg`.
- Kartica sezone i Arena u Specs §7 su pojednostavljeni isječci (isti Pip art, isti draw_pip / portrait); ostatak tih ekrana nije mijenjan.

## § Ideje van zadatka
- ShopLink može voditi pravo na slot u Shopu (Looks → isti slot), uz povratak u ormar kad se kupovina završi.
- Pip na polju bi mogao rijetko (jednom po sesiji) prići ormaru dok hoda — bez loopa, samo kao cilj hoda.
