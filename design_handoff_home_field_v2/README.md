# Home — polje sezone, pass 2 — handoff

Brief: `docs/04-experience/design-drafts/home-field-v2-cd-brief.md` (prva runda: `home-field-cd-brief.md`, paket `design_handoff_home_field/`). Chrome: `design_handoff_hub_chrome_v2/` (header 143, footer 144, stranica 1080 × 1633 od y 143).
Jedan dizajn. Mjere u px baze 1080 × 1920, prenos 1:1. Koordinate kontrola su u prostoru stranice.

## Šta otvoriti

| Fajl | Šta je |
|---|---|
| `design/FieldScreen.dc.html` | Ekran 1080 × 1920. Prop `scene` = full · first · basket_empty · picker · upgrades · upgrades_need · empty · full13 · claimed; `season` = boja livade (8); `zones` = keepout / mjesta / Pip zona preko ekrana |
| `design/Field Specs.dc.html` | Sva stanja iz §8.1, kontrast za 8 sezona × 3 trake (računa se uživo), gornji dio i donji red uvećani, oba sheeta, stanja dugmeta nadogradnje, keepout + tablica 13 mjesta, prelaz i animacije |
| `design/HubChromeScreen.dc.html` | Zadati header/footer v2 — kopija, ne mijenja se |
| `godot/` | `home_field_v2_export.json`, `ui_home_field.gd` (samo izmjene), `field_tree.txt`, `README.md` (red prenosa) |
| `assets/` | Nema novih fajlova — vidi `assets/README.md` |

Mapiranje stanja iz §8.1: 1 `full` · 2 `first` · 3 `basket_empty` · 4 `picker` · 5 `upgrades` + `upgrades_need` · 6 `empty` + `full13` · 7 `full` sa `season` = amber_canopy / moonlit_warren · 8 `claimed`.

## Odlučeno

1. **Livada je cijela stranica 1080 × 1633**, bez ruba i radiusa — prozor je bio 37 % stranice, sada je 100 %, a kontrole pokrivaju ≈ 13 %.
2. **Trake 0–523 nebo · 523–1110 daljina · 1110–1633 prednja** (`MEADOW_BANDS [0.32, 0.68]`) — gornja grupa stoji cijela na nebu, donji red cijeli na prednjoj traci, pa nijedna kontrola ne prelazi granicu trake.
3. **Kontrast = jezik naljepnica:** svaka kontrola je neprozirna (krem / peach / lavanda / mint / zlatna) s rubom 3 px `#2D3436`. Rub drži najmanje **6,14 : 1** (Moonlit, prednja traka) — jedno rješenje za svih 8 sezona, bez varijante.
4. **Svijetli tekst nikad ne stoji na livadi.** Tekst je tamni ink na neprozirnom fillu (najmanje 5,61 : 1, soft ink na zaključanoj korpi) ili `#1A1A14` direktno na livadi (najmanje 8,46 : 1).
5. **Sjena znači "pritisni me":** pritisljive naljepnice imaju tvrdu sjenu `0 8 0 rgba(26,26,20,.28)`, a info (GrownChip, TutorialHint) samo rub.
6. **Gift je isti DailyGiftCard kao na biranju sezone** (180, krem, rub 3, radius 32, lavanda kutija) — nova instanca iste scene u polju, bez runtime reparenta; u polju dobija samo sjenu.
7. **Korpa dijeli Gift okvir 1:1**; mijenja se samo sadržaj: zaključana (lokot, "Basket") · prazna ("Choose") · izabrano (portret + "+5 %"). Tako je +5 % stalno vidljiv na ekranu, ne samo u pickeru.
8. **Jedini loop je ripple oko prazne korpe** (1,2 s) — tačke na Giftu i Upgradesu su statične, oblačić tutoriala isto.
9. **Ulaz u nadogradnje je treća pločica iste porodice** (876, 24): znak ︽ + dvije mini trake nivoa (Magnet, Loot). Tako se napredak vidi prije tapa, a riječ "Upgrades" (174 px na 38) ionako ne staje u 180.
10. **Zlatna tačka na Upgradesu = nešto se može kupiti sada.** Ista gramatika kao roze tačka na Giftu, druga boja.
11. **Nadogradnje su u bottom sheetu 922**, isti sheet kao korpa (krem, radius 36, rub ink) — jedan obrazac za oba panela, palac dohvata dugmad.
12. **Kartica nadogradnje ima naslov + "Lv N / 4" i ispod 4 segmenta.** Čip "you have N" otpada, jer razlog već piše na dugmetu ("Need 1").
13. **Maxed dugme je mint bez sjene**, a efekat bez "· fully upgraded" — Lv 4 / 4 + Maxed to već kaže, a na 44 px rečenica ne staje.
14. **Ime sezone ostaje, 56 ink na nebu; tagline otpada.** Lantern i Starfall su obje lavanda, pa bez imena nije jasno gdje si; tagline već stoji na kartici jedan tap nazad i ne staje u 624 px.
15. **GrownChip ide ispod imena** i dobija `icon_flower.svg` iz chrome v2 — broji isto cvijeće koje header zove Flowers.
16. **Donji red: Seasons 236 × 124 · Play 432 × 140 · Endless 236 × 124.** Play je centriran na x 540 i ne pomjera se kad se Endless otključa — isti palac na istom mjestu.
17. **Seasons ostaje riječ s ‹** — zadržava čitljivo "‹ Seasons" iz HOME-20; ikona bi bila još jedan znak za učiti.
18. **Endless nosi znak ∞ (dva prstena) umjesto podnaslova** "Hard · no finish line"; lavanda boja ostaje.
19. **Prije tutoriala oblačić stoji uz korpu**, sa strelicom na nju, a ne iznad Play reda — objašnjava ono što je zaključano.
20. **Gift nema tačku prije kraja tutoriala** — `can_claim_daily_chest()` traži `tutorial_complete`, pa bi tačka lagala.
21. **13 mjesta prerasporedno u 4 dubine (F 88 · M 116 · N 136 · kruna 168)**, sve 20–30 % veće nego danas. Drugi cvijet tipa (prag 5) stoji iza prvog (prag 1), pa se vidi kako tip "raste unazad".
22. **Pip hoda u pojasu 778 × 131 ispred svih cvjetova** (baza y 1306–1437), iznad donjeg reda — nikad pod kontrolom, nikad iza cvijeta.
23. **Prelaz je isti rect tween na novu metu** (0, 0, 1080 × 1633, radius 36 → 0, rub 8 → 0). Chrome ulazi fade + 16 px klizanjem sa svog ruba, stagger 0,06, s Play prvim.
24. **Polje prelazi na Nunito (`UiStage.font`)** — Gift je isti čvor kao na biranju sezone, a dva fonta na istoj stranici bi se vidjela.
25. **Basket sheet je krem, ne tamni** — portreti u zlatnom okviru i tamnom wellu iskaču na kremu; ista porodica kao naljepnice.
26. **Upgrade scena je "ready + maxed", a Need N je zasebna scena** — `pick_upgrade_flower_type()` bira jedan cvijet za obje kartice, pa ready i Need N ne mogu stajati zajedno.

## Keepout i mjesta

Keepout (koordinate stranice):

| Zona | Rect | Napomena |
|---|---|---|
| Gore lijevo | 8, 8, 212 × 408 | Gift + Basket |
| Gore desno | 860, 8, 212 × 212 | Upgrades |
| Ime + čip | 212, 20, 656 × 184 | mouse_filter IGNORE — swipe prolazi, cvijeće ne smije |
| Donji red | 54, 1445, 972 × 188 | Seasons · Play · Endless |
| Oblačić | 220, 214, 632 × 216 | samo prije tutoriala |

Sve zone gore su na nebu (0–523), gdje nema mjesta. Jedina zona koja dira livadu je donji red: sve baze cvjetova su između y 735 i 1208, a Pip ≤ 1437.

Nova `MEADOW_SPOTS` — `[x %, y % od poda stranice, veličina px, indeks u rosteru, prag]`, crta se ovim redom (nazad → naprijed):

```
F  [10,55,88,3,5] [26,54,88,0,5] [42,55,88,1,5] [58,54,88,4,5] [74,55,88,2,5] [90,54,88,5,5]
M  [18,40,116,0,1] [50,42,116,1,1] [82,40,116,2,1]
N  [12,29,136,3,1] [66,28,136,4,1] [88,30,136,5,1]
C  [34,26,168,5,10]
```

Baza u px: centar x = x % × 10,8 · baza y = 1633 − y % × 16,33. Pragovi i indeksi su isti skup kao danas (6 × 1, 6 × 5, 1 × 10; indeks 5 ima tri mjesta), mijenjaju se samo pozicije i veličine.

Pip: `PIP_SIZE 190`, zona baze x 14–86 %, y 12–20 % od poda (151, 1306, 778 × 131), default (756, 1404).

## Šta se briše

- `FieldTopRow` (Seasons 300 × 124 + ime/tagline red) — Seasons seli u donji red, ime na nebo, tagline otpada.
- `BasketCard` 1032 × 180 i `basket_card()` / `basket_button()` — zamjenjuje ih BasketButton 180.
- `FieldUpgradeStack` kao stalni blok (2 × 192) — kartice sele u UpgradesSheet.
- `meadow_frame()` (rub 6, radius 26) i `MEADOW_INNER` — livada nema okvir.
- `field_panel()`, `back_button()`, `PANEL_*`, `DISABLED_*`, `SUB_ON_DARK`, `CHROME` u `ui_home_field.gd` — tamni jezik stranice `#2E4733` više ne postoji na ovom ekranu.
- `TOP_ROW_H`, `BACK_W`, `BASKET_H`, `UPGRADE_H`, `UPGRADE_LEFT_W`, `PLAY_ROW_H`, `PLAY_W`, `ENDLESS_W`.
- Čip "you have N" na kartici nadogradnje; podnaslov "Hard · no finish line" na Endlessu.
- `icon_seed_light.svg` (korpa koristi `icon_seed.svg` iz chrome v2).

## Ideje van zadatka

- Tap na izrasli cvijet mogao bi pokazati "Meadow Clover · 7 in your stash" — livada bi postala i pregled zalihe.
- Kad nadogradnja bude kupljena, isti cvijet iz cijene mogao bi odletjeti iz kartice do trake nivoa na UpgradesButtonu (0,4 s).
- Gift na biranju sezone mogao bi dobiti istu tvrdu sjenu — tada bi obje instance bile potpuno iste, bez `set_drop()`.
- Pip bi mogao ponekad zaći među redove (y-sort) — zona je sada dovoljno velika za to.
