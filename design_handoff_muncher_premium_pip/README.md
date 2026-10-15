# Muncher redizajn + Premium Pip · handoff

Dvije stvari iz `docs/04-experience/design-drafts/muncher-premium-pip-cd-brief.md` (pročitan s `master`, 2026-10-13): **A** novi Muncher — *Nibbs, seed-mole*; **B** prvi premium Pip skin — *Sir Pip · Meadow Knight*. Pravila munchera, valute, Classic / Blossom / Sky i zvuk nisu dirani.

## Šta otvoriti

- `design/Muncher.dc.html`: Arena uživo s pravim pravilima (85 px/s, novi cilj svakih 0,25 s, jede na 36 px 0,5 s, T3 → led 2 s, budi se 0,3 s), fokus po propovima `season` / `state` / `direction`, galerija svih stanja i prelaza (petlje), čitljivost na svih 8 livada pored sjemenke Ø 140.
- `design/PremiumPip.dc.html`: 5 pogleda uz Classic, silueta 64 px, HUD 88, vlastiti klipovi + svih 77 zajedničkih (tap → oba igraju isti klip), sve površine uz Classic (polje 190, kartica 230, Arena 150, run odozgo 150, HUD 88, Camp 150, Shop / Ormar 246 i 126), Shop · Looks kartica (available / busy / owned / wearing), Ormar kartice (Classic „Free" · Sir Pip pod velom / kupljen / nošen „Premium").
- `design/Specs.dc.html`: pivoti munchera i krug jedenja, gnijezdo, budžeti iz `godot/budgets.json`, dodani čvorovi i zamijenjeni dijelovi po pogledu, test siluete, **živa samoprovjera** (konzola: `SELFCHECK n/10 …`).
- `design/muncher.js` · `knight.js` · `pip_*.js`: jedini izvor. `pip_runtime.js` je kopija iz `design_handoff_pip/` + 3 male izmjene (vidi § Prenos).
- `assets/muncher/{parts,fx,nest}` (46 SVG) · `assets/pip/parts_knight` (26) · `assets/pip/fx/k_*` (3) · `assets/pip/hud/pip_hud_knight.svg`.
- `godot/`: `muncher_rig.json`, `muncher_animations.json`, `skins_knight.json`, `rig_additions.json`, `animations_additions.json`, `shop_export.json`, `budgets.json`.

## § Odlučeno

**A · Nibbs, seed-mole (u igri i dalje „Muncher").** Bucmasti krtičak boje kajsije s razbojničkom maskom preko očiju, nosom kao ružičasti cvijet i dva velika zuba. Nestašan, ne strašan: okruglo tijelo, velike oči, obrve „V" samo dok lovi, a kad mu sjemenka pobjegne, lupi nogom i napravi „hmph". Topla kajsija + šljiva maska + ink obrub se čitaju na svih 8 livada i jasno se razlikuju od tamnih sjemenki i mint Pipa.
- Gnijezdo = **krtičnjak** 270 × 124 s rupom, klicom i ukradenim ljuskama. Zadnji dio je ispod njega, prednja usna preko njega **samo** dok spava / budi se u gnijezdu (z_index pravilo u `muncher_rig.json → nest.z_rule`).
- Rig: 3 pogleda (front ↓, back ↑, side →; ← = `root.scale.x −1`). Pogled se bira po smjeru: `|dx| ≥ 0,8·|dy|` → side, inače front / back, najmanje 0,2 s po pogledu.
- `root` = `_pest_center` = centar jedenja = usta (front 0 px, side 2 px).
- 16 klipova: `m_sleep_nest`, `m_sleep_spot`, `m_wake_nest`, `m_wake_spot` (0,3 s, „!"), `m_awake` (prvo buđenje u sesiji + UI baner „Muncher's awake!"), `m_hunt_front/side/back` (0,36 s ciklus = 30,6 px na 85 px/s), `m_eat_front/side` (0,5 s, 2 griza po 0,25 s, mrvice), `m_freeze` 0,18 s → `m_frozen` → `m_thaw` 0,25 s (led puca u 4 krhotine), `m_doze` → `m_sleep_spot`, `m_escaped_front/side` (sjemenka pobjegla).
- Tabela stanje → klip: `muncher_animations.json → states`. Kod zadržava sva pravila i samo bira klip.

**B · Sir Pip · Meadow Knight.** Priča: one noći kad je Muncher prvi put prekopao djetelinu, Pip se zakleo da će čuvati svaku sjemenku. Oklop od livade:
- kaciga od kapice žira sa zlatnom trakom i koraljnom perjanicom;
- naprsnik od kalajnog naprstka sa zlatnom djetelinom;
- ogrtač od plave latice s nazubljenim rubom;
- okrugli štit, čizme od žira, zlatne manžetne na ušima i šapama.
- Krzno: medeno (token set). Silueta (kupola kacige + perjanica + ogrtač) se čita na 64 px, u HUD-u 88 i odozgo u runu.
- **Isti pivoti.** Perjanica sjedi na čvoru `tuft`, pa jaše sve postojeće ključeve čuperka. Dodaci su djeca postojećih čvorova (`k_cape` → body, `k_helm` → head, `k_shield` → arm_L / arm_R, `k_collar` → body), pa nasljeđuju svaki postojeći klip. Samoprovjera 5 to mjeri: svjetske matrice svih Classic čvorova su identične u svih 77 klipova.
- Vlastito:
  - `pose_knight` (Shop / Ormar);
  - `sig_knight` 1,5 s (skok, pobode barjak, salutira, 3 zvjezdice);
  - `idle_knight` (svakih 6–10 s kaciga sklizne ukrivo, protrese glavom, „tink");
  - `t3_knight` (zamjenjuje `merge_t3`: štit visoko, ogrtač se raširi);
  - `goal_knight` (zamjenjuje `finish`: ogrtač se raširi, perjanica skoči);
  - sloj ogrtača `k_cape_idle` / `k_cape_run` na trećem playeru „Skin" (dira samo `k_*`).
- Bez traga u runu (svjesno, da run ostane čist).
- **Proizvod i cijena (prijedlog, odluka je tvoja):** „Sir Pip · Meadow Knight", SKU `pip_knight`, non-consumable, **€3,99 / $3,99**. Iznad impulsnog €1,99 jer je cijeli novi izgled u 5 pogleda sa 7 vlastitih klipova; ispod €4,99 da nikad ne bude skuplji od paketa. Samo kozmetika (Pillar 2): nikakav efekat na sjemenke, brzinu, munchera ni nagrade.
- Shop · Looks: premium kartica 1032 s oznakom „Premium" (`#D4A5FF`) i ljubičastim dugmetom s cijenom iz prodavnice (money.buy → money.busy → owned / wearing). Ormar: Classic „Free", Sir Pip „Premium"; nekupljen je pod velom i tap vodi na karticu u Shopu.

## § Performanse

Izmjereno skriptom koja pravi fajlove (`godot/budgets.json`) i ponovo u pregledaču (Specs):

| | Muncher | Sir Pip | Limit §4 |
|---|---|---|---|
| Čvorovi | 22 rig + 2 gnijezdo = **24** | **+4 / +4 / +3 / +2 / +3** (front / three_q / side / back / top) | ≤ 24 · ≤ 10 po pogledu |
| Zamijenjeni dijelovi | — | 8 / 8 / 8 / 5 / 5 | — |
| Atlas | **1024 × 387 @1×**, 1024 × 844 @1,5× (46 sprite-ova, 1 px = 1 game px) | **1024 × 300 @1×**, 1024 × 648 @1,5× (65 sprite-ova: vlastiti + dijeljeni prebojeni) | 1 tekstura ≤ 1024² |
| SVG | **26,9 KB** (46 fajlova) | **46,5 KB** (30 novih fajlova) | ≤ 120 KB · ≤ 150 KB |
| Efekti | 12 frejmova, ≤ 5 FX čvorova + led, najduži 0,4 s | k_star × 3, k_tink, k_flag (≤ 4 živa), bez traga | ≤ 12 sprite-ova, ≤ 0,6 s |
| Animacija | samo position / rotation / scale / visible / frame / modulate:a | isto | ništa po frejmu |

Atlas se pakuje @1,5× (pokriva 1440 px široke ekrane). @2× bi bio 1438 (muncher) i 1150 (Sir Pip), pa za to treba druga stranica. Ne preporučujem: muncher je 1:1 u game px, a Pip najviše 246 / 256.

U Godotu nema `_draw()` po frejmu. Muncher postaje `Node2D` stablo + `AnimationPlayer`, a `arena_pest.gd` gubi `_Layer` painter-e.

## § Samoprovjera (§5.3)

Provjereno u pregledaču (`design/Specs.dc.html`, konzola `SELFCHECK 10/10`) 2026-10-13, prije pakovanja.

1. Muncher je novi lik u stilu Pipa, simpatičan, ne strašan; čita se na svijetloj i tamnoj livadi. **da**: najmanji kontrast krzna ili obruba prema svih 8 livada je 3,31:1 (Amber Canopy), a krzno prema tamnoj sjemenki ≥ 3:1.
2. Muncher ima sva stanja iz §2.1, prelaze i kretanje u 4 pravca. **da**: 16 klipova; front ↓, back ↑, side →, ← = flip.
3. Centar jedenja = usta; mjere iz §2.2.6. **da**: usta su 0 / 2 px od roota; r 58 × 52; dužina ≤ 136; gnijezdo 270 × 124.
4. Premium skin nije recolor: ima vlastite dijelove / dodatke u svih 5 pogleda. **da**: 2–4 nova čvora i 5–8 zamijenjenih dijelova po pogledu.
5. Svih 75 postojećih Pip animacija radi sa skinom (isti pivoti). **da**: paket ima 77 (75 iz igre + 2); 4 uzorka po klipu, svjetske matrice Classic čvorova identične.
6. Skin ima pozu, potpis, idle detalj, reakciju na T3 i cilj, i HUD glavu. **da**
7. Skin je prepoznatljiv na 88 px i u runu odozgo. **da**: sama silueta (bez boje) se razlikuje od Classica 10,4 % u HUD-u 88 i 23,6 % odozgo. Blossom / Sky: najviše 1,3 % (pravilo: ≥ 10 % i ≥ 5 × coin skin), a boja razlikuje i ostalo.
8. Shop i Ormar kartice imaju sva stanja; Classic ostaje „Free", premium ima „Premium". **da**
9. Budžeti iz §4 su ispunjeni i napisani. **da**: tabela iznad.
10. Nigdje blur, glow, gradijent ni maska. **da**: skenirani su svi SVG dijelovi.

## § Prenos (za agenta)

- **Muncher:** `arena_pest.gd` zadržava enum, tajmere i ciljanje.
  - Crtanje zamijeni instancom scene iz `muncher_rig.json`: 3 pogleda, vidljiv je samo jedan, zamjena frejma za `eye_L/eye_R/mouth/ice/fx*`.
  - Uvezi `AnimationPlayer` iz `muncher_animations.json`.
  - Pri promjeni `get_pose_key()` / smjera pusti klip iz `states`.
  - Na `_release_target()` zbog spajanja pusti `m_escaped_*` kao overlay.
  - Kod prvog buđenja u sesiji pusti `m_awake` + baner (`assets/muncher/fx/m_banner.svg`, Label „Muncher's awake!", Nunito 900 44).
  - Poslije: `arena_perf_bench.gd`, `perf_suite_bench.gd` (`arena_muncher_eats`, `arena_merges`).
- **Sir Pip:**
  - `skins.json` dobija unos iz `skins_knight.json`: `replace_parts_by_view`; dijeljeni dijelovi idu preko `recolor_shared_parts`.
  - `UiPip._raster` čita zamjene po pogledu.
  - Čvorovi iz `rig_additions.json` se instanciraju samo za `knight`.
  - Klipovi iz `animations_additions.json` idu u isti player; sloj ogrtača ide u treći `AnimationPlayer "Skin"`.
  - `reactions` mapira `merge_t3` → `t3_knight` i `finish` → `goal_knight`; `idle_detail` pušta overlay svakih 6–10 s dok traje odmor.
  - `cosmetics.json` dobija `shop_export.json → cosmetics_item` (`source: "iap"`, SKU `pip_knight`). IAP grant → `cosmetics.owned`.
- Izmjene u `pip_runtime.js` (samo za pregledač):
  - filter `n.skin`;
  - `partFor(skin, view, sprite)`;
  - sloj `skin.loops`;
  - `skin.reactions`;
  - `skin.idle_detail`.
