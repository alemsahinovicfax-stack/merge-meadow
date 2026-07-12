---
type: sadrzaj
status: ideja
milestone: "—"
tags: [sadrzaj, gameplay, ekonomija, kamp, brainstorm, scratch]
povezano:
  - ideje-identitet-lore
  - svijet-i-lore
  - ekonomija
  - merge-kamp
  - spec-vertical-slice
ai_sažetak: "SCRATCH brainstorm — rarity orbovi, grmovi između laneova, novčići, kolekcionarski dnevnik, shop skinovi, boostovi, ideje za kamp. Nije kanon."
---

# IDEJE — gameplay, ekonomija, kamp (SCRATCH)

> ⚠️ **Brainstorm samo.** Ne mijenja postojeće docove ni kod.
> **Odlučeno (identitet):** Pip + sjeme/cvijet — vidi [[ideje-identitet-lore|ideje-identitet-lore]].
> Kad nešto prihvatimo → promovirati u `ekonomija`, `merge-kamp`, `spec-vertical-slice` itd.

---

## Potvrđeno (ne dirati dok ne kažemo)

- **Lik:** Pip (zeko)
- **Resursi u runu:** sjeme → cvijet (tier progresija, ne apstraktni orb)
- **Kamp (hibrid):** **K1 vrt + K3 staklenik + K6 loadout** — potvrđeno 2026-07-03

### Kamp hibrid — kako radi zajedno (skica)

```
┌─────────────────────────────────────────┐
│  STAKLENIK (K3)                         │
│  ★★★ sjemena, dnevnik, limitirani slotovi│
│  "wow" moment za mythic                  │
├─────────────────────────────────────────┤
│  VRT / GREDICE (K1)                     │
│  ★–★★ sadiš, merge 2→1, biljka raste    │
│  pasivni novčići (opc. K5), vizual livade│
├─────────────────────────────────────────┤
│  PIPOV KOŠ / LOADOUT (K6)                │
│  1–3 sjemena → češći spawn u slj. runu  │
│  Play → run                               │
└─────────────────────────────────────────┘
```

Dopunski elementi (nisu obavezni, ali dobro sjede): **K4** zamjena viška, **K9** jedan dnevni zadatak, **K10** craft lane dekoracija.

---

## Ideje korisnika (2026-07-03)

### 1. Rarity preko zvjezdica (1–3)

Svaki pickup (sjeme/cvijet/…) ima **vizualni tier rijetkosti**:

| Zvjezdice | Rijetkost | Primjer |
|-----------|-----------|---------|
| ★ | Common | obično sjeme livade |
| ★★ | Rare | cvijet s posebnom bojom |
| ★★★ | Mythic / Legendary | sjeme lubenice, zlatni lotus, … |

- Svaki tip **drugačije i unikatnije** izgleda (silueta + boja + zvjezdice).
- Rijetkost utječe na vrijednost u kampu / shopu / kolekciji (brojke TBD).

### 2. Različiti tipovi orbova (pickupova)

Ne samo jedan generički krug — **više vrsta** (npr. sjeme suncokreta, tulipan, lubenica, gljiva, …).
Svaka vrsta = vlastit sprite + eventualno vlastita rarity.

### 3. Tipovi + rarity zajedno

Kombinacija **2 + 1**: npr. *Sjeme lubenice ★★★* je drugačiji od *Sjeme livade ★* — i po izgledu i po rijetkosti.
Matrica: `tip × rarity` → kolekcionarska dubina.

### 4. Dnevnik / knjižica kolekcije

- UI ekran (ili tab u kampu): **katalog** svih tipova + rarity.
- Otključava se kad prvi put skupiš dani tip ("Pip je pronašao novo sjeme!").
- Komercijalni kut: kolekcionarstvo = D7 retention, shareable ("sakupio sam legendarnu lubenicu").
- Povezuje se s idejom **6** (kupovina / unlock lane dekoracija).

### 5. Tutorial companion skuplja novčiće; orbovi/sjeme "po prilici"

- **Pip (ili companion)** automatski skuplja **novčiće** dok igrač swipea (pasivni income u runu).
- **Sjeme/cvjetovi** se pojavljuju **sporadično** na traci — rijetkiji, posebniji moment.
- Razdvaja "stalnu valutu" (novčići) od "kolekcionarskog/meta" resursa (sjeme).
- Tutorial: prvo nauči novčiće, pa prvo sjeme → jasniji pacing.

### 6. Ekonomija → shop: skinovi, pozadine, kolekcionarske stvari

Valute (draft):
- **Novčići** — česta, iz runa + grmova; kupuju skinove, pozadine trake, kozmetiku.
- **Sjeme (po tipu)** — rijetkija; unlock **lane dekoracija** koje se ponekad vide na scroll pozadini.

Primjer: skupiš dovoljno **sjemenja lubenice ★★★** → na traci koja se pomiče **ponekad** se pojavi lubenica kao dekor (objekt koji si "zaradio/kupio").
Igrač vidi svoj napredak u svijetu, ne samo u brojkama.

Moguće kategorije shopa:
- Skinovi za Pip-a
- Pozadine livade (lane scroll art)
- Lane props (lubenica, cvjetni arki, …)
- Kamp dekoracije
- Kolekcionarski okviri u dnevniku

### 7. Tri trake + grmovi IZMEĐU traka (nagrada)

Između laneova (u "mrtvoj zoni" između vertikalnih linija) — **grmovi s nagradom**:
- Pip prođe kroz grm → pokupi **nekoliko novčića** ili sjeme/cvijet.
- Motivira **swerve / srednji lane** ili riskantniji put (ovisno o kontrolama).
- Vizualno: grm "puca" u confetti, novčići/sjeme iskaču.

### 8. Grmovi između traka — vizualna razlika nagrada vs prepreka

**Ista lokacija** (između traka), **dva tipa grma**:

| Tip | Vizual | Ishod |
|-----|--------|-------|
| **Nagrada** | grm **skače, trese se**, viri novčić/sjeme | pickup |
| **Prepreka** | grm miran, tamniji, trnje / mrtve grane | sudar → fail ili gubitak % |

Igrač **na prvi pogled** zna što je što — bez teksta.
Fail: Pip se zabije, sjeme se rasprši (50% loot već postoji u specu).

### 9. Boostovi na traci ili u grmu

Kratkotrajni power-upi (pickup u runu ili iz "dobrog" grma):

| Boost | Efekt | Trajanje |
|-------|-------|----------|
| Magnet | veći domet skupljanja | ~5–10 s |
| Štit | jedan sudar ne faila run | 1 hit ili ~8 s |
| 2× sjeme | dupli pickup iz grmova/orbova | ~10 s |

Stacking / max 1 aktivni — TBD. Monetizacija: IAP "start with shield" opcionalno (Pillar 2 provjera).

---

## Predložene ideje za KAMP (trenutni merge grid se ne sviđa)

> Trenutno: 9 slotova, T1+T1=T2, magnet upgrade. Funkcionalno OK, ali **dosadno / apstraktno**.
> Cilj kamp ideja: cozy, vizualno, razlog za povratak, povezano s Pip + sjeme/cvijet + kolekcija.

### K1. Vrt / gredice (umjesto apstraktne mreže)

- Kamp = **mali vrt s gredicama** (ne grid gumbi).
- Sjeme iz runa **sadiš** u praznu gredicu → nakon mergea (2 ista = veći cvijet) vizualno raste biljka.
- Magnet upgrade = npr. **pčelinjak** ili **zaljevka** na rubu vrta (vidljivo, ne samo brojka).
- Zašto bolje: odmah vidiš *što gradiš*, livada "cvjeta" (usklađeno s loreom).

### K2. Pipova kućica / cozy hub

- Kamp = **Pipov dom** (soba + mali vrt ispred).
- Merge = spajanje predmeta u sobi (cvijeće u vazi, okviri, jastuci) ili u vrtu.
- Unlock soba / zona vrta = meta progres (kamp level).
- Zašto bolje: emocionalna veza, skinovi za Pip-a imaju gdje "živjeti".

### K3. Kolekcionarski staklenik (greenhouse)

- Centar kampa = **staklenik** gdje držiš rijetka sjemena (★★★).
- Obična sjemena idu u vanjski vrt; legendarna u staklenik.
- Dnevnik (ideja 4) je **knjiga na stolu** u stakleniku — jedan tap.
- Zašto bolje: rarity sistem dobiva fizičko mjesto; "wow" moment za mythic.

### K4. Tržnica / zamjena (bez pay-to-win)

- NPC-free: **"Pipova ploča"** — zamijeni višak sjemena za novčiće ili skin kupon.
- Npr. 10× common sjeme → 1 rare sjeme ili dekor.
- Zašto bolje: rješava "pun inventar", daje smisao duplikatima u kolekciji.

### K5. Pasivni rast (lagani idle)

- U kampu posađeni cvjetovi **generiraju novčiće** dok si offline (cap npr. 4 h).
- Povratak = "Pip je u međuvremenu skupio X novčića" + vizualno više cvjetova.
- Zašto bolje: D1/D7 hook bez energy sustava; komercijalno standard u hybrid casual.

### K6. Kamp kao "pripremi sljedeći run"

- Umjesto samo mergea: **odaberi 1–3 sjemena** koja će se češće pojavljivati u sljedećem runu (loadout).
- Strategija: "idem loviti lubenicu" → staviš lubenicu u Pipov koš.
- Zašto bolje: kamp postaje **planiranje**, ne samo klikanje; povezuje run ↔ kamp.

### K7. Vizualni progres livade (meta mapa)

- Kamp pogled = **široka livada** koja se širi s mergeom (faze: pusto → trava → cvijeće → voćnjak).
- Nema apstraktnog UI-a — scrolluješ kamp lijevo/desno, vidiš što si otključao.
- Lane dekoracije iz ideje 6 pojavljuju se i ovdje kao statični elementi.
- Zašto bolje: jedan kontinuirani svijet umjesto "ekran s gumbima".

### K8. Ljubimci u kampu (Mochi, Bramble)

- Merge grid zamijenjen ili dopunjen: **ljubimci šetaju kampom**, tap = mali bonus ili flavor.
- Unlock ljubimca = kamp milestone (već u draftu `likovi`).
- Zašto bolje: cute factor za store; kamp nije prazan dok čekaš.

### K9. Mini-zadatak dana u kampu

- "Posadi 3 tulipana" / "Spoji 2 rare sjemena" → nagrada novčići ili skin fragment.
- Jedan zadatak, bez quest loga — samo jedna kartica na ulazu u kamp.
- Zašto bolje: dnevni razlog otvoriti app bez punog daily reward grind sustava.

### K10. Radionica dekoracija (craft)

- Sjeme + novčići → **izradi lane prop** (npr. luk od cvijeća) koji se pojavljuje u runu.
- Jače od čistog shopa: osjećaj **stvorio sam ovo**.
- Zašto bolje: spaja ideju 6 s aktivnošću u kampu.

---

## Kako se ideje slažu (jedna moguća slika)

```
RUN:  Pip skuplja novčiće (često) + sjeme po prilici (rijetko)
      Grmovi između traka: nagrada (skače) vs prepreka (miran)
      Boostovi: magnet / štit / 2×
           ↓
LOOT: novčići + sjemena po tipu/rarity
           ↓
KAMP: vrt / staklenik / Pipova kućica — saditi, merge, craft dekor
      Dnevnik kolekcije ★–★★★
      Shop: skinovi, pozadine, lane props (novčići + sjemena)
           ↓
SLJEDEĆI RUN: odabrana sjemena u loadoutu; kupljena lubenica na traci
```

---

## Otvorena pitanja (za kasnije)

- [ ] Koliko tipova sjemena na launch (5? 15? 30?)? → **10 na v1, 14 ukupno do v1.1** (vidi katalog)
- [ ] Da li rarity utječe samo na vizual ili i na merge pravila?
- [ ] Kamp: koji od K1–K10 (ili hibrid) zamjenjuje trenutni 9-slot grid? → **K1+K3+K6 potvrđeno**
- [ ] Novčići vs sjeme — dvije valute ili sjeme = pod-tip kolekcije?
- [ ] Grmovi između traka: zahtijeva li **swerve** kontrole (M7 otvoreno pitanje lane-run)?
- [ ] Boostovi: free samo iz runa ili i rewarded "start with boost"?
- [ ] Dnevnik: zaseban ekran ili tab u kampu?

---

## Dalje ideje (2026-07-03, runda 2)

> Nastavak brainstorma — run, loot, monetizacija, retention, feel. Nije kanon.

### RUN — feel i varijacija

| # | Ideja | Zašto (pare / retention) |
|---|-------|--------------------------|
| R1 | **Combo grmova** — 2–3 nagradna grma zaredom = mali coin multiplier (×1.5) | nagrađuje skill/risk, satisfying chain |
| R2 | **Vremenski mood lanea** — sunce = više novčića, kiša = više rijetkih sjemena (rotacija po runu ili dnevno) | varijacija bez novih mehanika, razlog "još jedan run" |
| R3 | **Zlatni grm** — jednom po runu, bljesak + garantirano ★★ ili ★★★ sjeme | highlight moment za TikTok/screenshot |
| R4 | **Pip reakcije** — skok/celebration na rare pickup, šok na prepreku | emocija bez teksta, cute = shareable |
| R5 | **Koš na leđima** — loadout sjemena vidljiv na Pipu tijekom runa (3 mala ikona) | kamp ↔ run veza vidljiva |
| R6 | **Near-miss** (tutorial / early runs) — prepreka oduzme novčiće, ne fail | mekši onboarding prije pravog faila |
| R7 | **Magnet = prskalica** — upgrade u kampu vizualno = veći radius prskanja u runu | tematski upgrade umjesto apstraktnog "Lv4" |

### LOOT / KOLEKCIJA

| # | Ideja | Zašto |
|---|-------|-------|
| L1 | **Silueta u dnevniku** — neotkrivena sjemena = "?" silueta (Pokémon-style) | kolekcionarstvo, D7 |
| L2 | **"Novo otkriće!"** — prvi put ★★★ = kratki fanfare + kartica za share | organski marketing |
| L3 | **% kolekcije** na main menuu — "Livada 34% procvjeta" | meta cilj bez quest loga |
| L4 | **Setovi** — "Ljetni set" (lubenica, suncokret, …) — bonus kad skupiš cijeli set u dnevniku | live ops / sezonski content |
| L5 | **Duplikat → staklenik XP** — višak ★★★ daje "sjaj" koji širi staklenik (1 slot) | smisao duplikatima, monetizacija expand IAP opcionalno |

### KAMP — dopuna hibridu K1+K3+K6

| # | Ideja | Zašto |
|---|-------|-------|
| C1 | **Zalijevanje tapom** — uvenula gredica? jedan tap = brži rast / bonus novčići | micro-interakcija, kamp nije pasivan ekran |
| C2 | **Staklenik = limit slotova** (npr. 3 na start) — proširenje novčićima ili kamp levelom | progression sink, IAP "greenhouse +1 slot" cosmetic-adjacent |
| C3 | **Pusti cvijet u livadu** — mergeani ★★★ možeš "pustiti" na meta livadu → trajni vizual (K7 light) | emotional payoff, vidiš napredak |
| C4 | **Pčelinjak kao magnet** — upgrade linija = više pčela skuplja novčiće u runu (passive) | zamjena za trenutni apstraktni magnet upgrade |
| C5 | **Pipova klupa / odmor** — tap Pip u kampu = flavor animacija + jednom dnevno mali coin gift | cozy, lik ima karakter |
| C6 | **Sezonska gredica** — jedna gredica mijenja temu (zima/ljeto) s live ops eventom | retention bez story modea |

### MONETIZACIJA (Fair F2P — Pillar 2)

| # | Ideja | Tip |
|---|-------|-----|
| M1 | Rewarded: **instant posadi** u staklenik (preskoči čekanje rasta) | ad |
| M2 | Rewarded: **dupli novčići** na loot ekranu (već postoji za loot — proširiti) | ad |
| M3 | IAP: **remove ads** | standard |
| M4 | IAP: **starter pack** — Pip skin + 1 ★★★ sjeme + staklenik slot | conversion |
| M5 | IAP: **samo kozmetika** — skinovi, pozadine, koš na leđima, okviri dnevnika | nikad P2W |
| M6 | **Kozmetički battle pass lite** — 30 dana, samo vizuali, bez gameplay statova | opcionalno post-launch |

### RETENTION (bez energy/stamine)

| # | Ideja | Zašto |
|---|-------|-------|
| T1 | **7-day streak** — dan 7 = garantirano ★★ sjeme (ne blokira run) | D7 bez kazne |
| T2 | **"Sjeme tjedna"** — jedan featured tip u shopu/loadout bonusu | FOMO blagi, live ops |
| T3 | **"Pip čeka"** — ako nisi bio 24h+, Pip drži mali poklon (novčići) na ulazu u kamp | comeback hook |
| T4 | **Nefinished merge** — jedna gredica "skoro cvijet" ostaje između sesija | soft cliff (već u core-loopu, sada vizualno) |

### AUDIO / JUICE

| # | Ideja |
|---|-------|
| A1 | Različit **SFX po rarity** — ★ tiho, ★★★ bass "pop" |
| A2 | Kamp **ambient** — ptice/cvrčci jači kad je vrt puniji |
| A3 | Dobri grm = **satisfying rustle**; loši = tužan "bonk" |
| A4 | Merge u vrtu = **rast biljke** animacija + zvuk (skala s tierom) |

### STORE / MARKETING (projekt koji uzima pare)

| # | Ideja |
|---|-------|
| S1 | Screenshot #1: Pip kroz livadu, koš pun sjemena, zlatni grm u pozadini |
| S2 | Screenshot #2: puni staklenik + dnevnik 80% |
| S3 | Video hook: "skupljam → sadim → livada cvjeta" u 15 s |
| S4 | ASO riječi: *merge garden*, *cute bunny*, *collect seeds*, *cozy meadow* |

### Tehnički / scope napomene (za kasnije)

- Grmovi **između** traka vjerojatno traže **swerve** ili širi hitbox — otvoreno u `lane-run.md`.
- Dnevnik + 15+ tipova sjemena = **content pipeline** (sprite po tipu × rarity varijanta).
- Staklenik slot limit = jednostavan broj u `GameState`, ali UI/art veći od greyboxa.

---

## Launch scope — v1 vs v1.1 vs kasnije (2026-07-04)

> **Cilj:** solo student (~5–8 h/tj.) — što stigne **zaraditi**, što odgoditi bez ubijanja vizije.
> Usklađeno s [[../06-production/scope-i-granice|scope-i-granice]] gdje moguće; novi brainstorm (sjeme, grmovi, vrt) remapira prioritete.
> **Legenda:** ✅ launch · 🟡 v1.1 (1–2 mj. nakon) · 🔵 v1.2+ / live ops · ❌ OUT (Pillar 2 / prevelik scope)

### Faze u jednoj slici

```
M7 slice (sada)     →  v1 launch (M8)        →  v1.1 update      →  v1.2+
greybox loop        →  zarada na storeu      →  depth + retention →  live ops
Pip kvadratić       →  Pip sprite            →  grmovi, diary     →  sezone, pass
1 tip sjeme         →  10 tipova + 2 seta    →  +5 tipova, set 3  →  events
grid kamp           →  vrt+staklenik+loadout →  craft, streak     →  battle pass lite
```

### RUN

| Feature | M7 slice | v1 launch | v1.1 | Napomena |
|---------|----------|-----------|------|----------|
| 3 lanea + swipe | ✅ | ✅ | ✅ | već greybox |
| Pip skuplja **novčiće** (često) | 🟡 placeholder | ✅ | ✅ | core ekonomija |
| **Sjeme** po prilici (rijetko) | 🟡 1 tip | ✅ 10 tipova | ✅ 15 tipova | vidi katalog dolje |
| Prepreka na laneu (sudar) | ✅ | ✅ | ✅ | |
| **Grmovi između traka** (nagrada/prepreka) | ❌ | 🟡 samo nagrada | ✅ pun vizual (skače vs miran) | v1.1 ako nema swerve |
| Boostovi (magnet/štit/2×) | ❌ | 🟡 1 tip (magnet) | ✅ sva 3 | launch: magnet dovoljan |
| Zlatni grm (R3) | ❌ | 🟡 | ✅ | wow moment |
| Combo grmova (R1) | ❌ | ❌ | 🟡 | polish |
| Vrijeme lanea sunce/kiša (R2) | ❌ | ❌ | 🔵 | content varijacija |
| 100 runova + endless | ❌ | ✅ | ✅ | iz scope-i-granice |
| Loadout koš na Pipu (R5) | ❌ | ✅ 1 slot | ✅ 3 slota | launch: 1 slot = manje UI |

### LOOT / KOLEKCIJA

| Feature | M7 slice | v1 launch | v1.1 |
|---------|----------|-----------|------|
| Loot ekran ×2 / revive / retry / kamp | ✅ | ✅ | ✅ |
| Rarity ★–★★★ vizual | 🟡 boja only | ✅ zvjezdice | ✅ |
| **Dnevnik kolekcije** | ❌ | 🟡 10 unosa, bez silueta | ✅ siluete + % (L1, L3) |
| "Novo otkriće!" (L2) | ❌ | 🟡 | ✅ |
| Set bonus (L4) | ❌ | ✅ 2 seta | ✅ 3. set |
| Duplikat → staklenik XP (L5) | ❌ | ❌ | 🟡 |

### KAMP (K1+K3+K6 hibrid)

| Feature | M7 slice | v1 launch | v1.1 |
|---------|----------|-----------|------|
| Trenutni 9-slot grid | ✅ (privremeno) | ❌ zamijeni | — |
| **Vrt / gredice** (K1) | ❌ | ✅ 6 gredica | ✅ 9 gredica |
| **Staklenik** (K3) | ❌ | ✅ 2 slota | ✅ 4 slota |
| **Loadout** (K6) | ❌ | ✅ 1 sjeme | ✅ 3 sjemena |
| Magnet = prskalica (R7/C4) | ✅ apstraktno | ✅ tematski sprite | ✅ |
| Množitelj upgrade | ❌ | 🟡 ili v1.1 | ✅ |
| Zalijevanje (C1) | ❌ | ❌ | 🟡 |
| Pasivni novčići (K5) | ❌ | 🟡 cap 2h | ✅ cap 4h |
| Craft lane dekor (K10) | ❌ | ❌ | 🟡 3 dekoracije |
| Pip tap gift (C5) | ❌ | 🟡 | ✅ |
| Ljubimac #2 (Mochi) | ❌ | ✅ cosmetic | ✅ |
| Daily chest | ❌ | ✅ | ✅ |
| Zamjena viška (K4) | ❌ | 🟡 | ✅ |

### SHOP / MONETIZACIJA

| Feature | v1 launch | v1.1 | OUT |
|---------|-----------|------|-----|
| AdMob rewarded (×2, revive) | ✅ | ✅ | — |
| Remove ads IAP | ✅ | ✅ | — |
| Starter pack | ✅ | ✅ | — |
| Kozmetika (skin Pip, pozadina) | ✅ 3–5 itema | ✅ +10 | — |
| Lane props (lubenica na traci) | 🟡 2 props | ✅ | — |
| Battle pass (M6) | ❌ | ❌ | 🔵 v1.2+ |
| Gacha / energy | ❌ | ❌ | ❌ Pillar 2 |

### ART / CONTENT budžet (realno solo)

| Asset | v1 launch | Komentar |
|-------|-----------|----------|
| Pip sprite + 2 animacije | ✅ | zamjena kvadratića — **prioritet #1** |
| Sjeme spriteovi | **10 tipova** × (sjeme + cvijet T2) = 20 | ne 30 na launch |
| Grmovi (dobar/loš) | 🟡 1 par | v1.1 drugi par |
| Kamp pozadina (vrt + staklenik) | ✅ 1 scena | scroll ili statično |
| UI flat set | ✅ min | loot, kamp, shop, diary |
| Muzika | 🟡 1 loop kamp | opcionalno |

### Što **rezati** ako kasniš (redoslijed žrtvovanja)

1. Endless mode → ostavi 50 runova + 1 endless stub  
2. Množitelj upgrade → samo magnet  
3. Lane props u runu → samo shop skinovi  
4. Staklenik → sve u vrt (rare vizualno isti merge)  
5. Dnevnik → samo lista bez silueta  
6. **Nikad rezati:** loop, ads, remove ads, Pip identitet, min 6 tipova sjemena  

### Otvoreno nakon ovog scopea

- [ ] Kad brainstorm postane kanon → ažurirati `scope-i-granice` (eksplicitna potvrda korisnika)
- [ ] M7 slice exit: zamijeniti grid kamp **prije** ili **poslije** Pip arta?

> **Prvo iskustvo (~5 min):** vidi [[ideje-prvo-iskustvo|ideje-prvo-iskustvo]] — minuta-po-minuta scenarij tutoriala.

---

## Katalog sjemena — 14 tipova + setovi (2026-07-04)

> EN imena (store). **Default rarity** = kako najčešće spawna u runu (može ★★ varijanta rijeđe).
> **Merge:** T1 sjeme u kampu → T2 cvijet/plod (2× isti tip).
> **Launch v1:** prvi **10** (označeno ✅); ostatak 🟡 v1.1.

### Setovi

| Set | Članovi | Bonus kad kompletan (dnevnik) | Launch |
|-----|---------|-------------------------------|--------|
| **Meadow Starter** | Clover, Daisy, Buttercup | +5% novčića u runu (permanent mini) | ✅ v1 |
| **Summer Harvest** | Sunflower, Pumpkin, Watermelon | unlock lane prop *lubenica* na traci | ✅ v1 |
| **Spring Bloom** | Tulip, Bluebell, Rose | unlock pozadina *cvjetni brežuljak* | 🟡 v1.1 |
| **Mystic Garden** | Lotus, Golden Poppy, Moonflower | unlock Pip skin *sjajni kaput* (kozmetika) | 🟡 v1.1 |
| **Woodland** (mini) | Mushroom, Lavender | — (2 člana, bonus: +1 staklenik slot temp 7 dana) | 🟡 v1.1 |

### Pojedinačni tipovi

| # | ID | EN naziv | Set | Default ★ | T2 (merge) | Vizual (skica) | Launch |
|---|-----|----------|-----|-----------|------------|----------------|--------|
| 1 | `clover` | Clover | Meadow Starter | ★ | cvjetni grm | mali zeleni list, 3 listića | ✅ |
| 2 | `daisy` | Daisy | Meadow Starter | ★ | bijeli cvijet | bijeli latica + žuti centar | ✅ |
| 3 | `buttercup` | Buttercup | Meadow Starter | ★ | žuti cvijet | žuta zvijezda cvijet | ✅ |
| 4 | `tulip` | Tulip | Spring Bloom | ★★ | otvoreni tulipan | čašica, crvena/roza | ✅ |
| 5 | `sunflower` | Sunflower | Summer Harvest | ★★ | veliki cvijet | žuti disk, smeđi centar | ✅ |
| 6 | `bluebell` | Bluebell | Spring Bloom | ★★ | zvončić | ljubičasto zvono | 🟡 |
| 7 | `rose` | Rose | Spring Bloom | ★★ | ruža | crvena ruža, trn na stabljici | 🟡 |
| 8 | `lavender` | Lavender | Woodland | ★★ | snop lavande | ljubičasti snop | 🟡 |
| 9 | `mushroom` | Mushroom | Woodland | ★★ | gljiva (T2) | crvena gljiva s točkicama | 🟡 |
| 10 | `pumpkin` | Pumpkin | Summer Harvest | ★★★ | mala bundeva | narančasta, zelena stabljika | ✅ |
| 11 | `watermelon` | Watermelon | Summer Harvest | ★★★ | mini lubenica | zelena ljuska, crvena unutrašnjost slice | ✅ |
| 12 | `lotus` | Lotus | Mystic Garden | ★★★ | lotus cvijet | ružičasti na listu, blagi glow | 🟡 |
| 13 | `golden_poppy` | Golden Poppy | Mystic Garden | ★★★ | zlatni mak | zlatno-žuti, čestice | 🟡 |
| 14 | `moonflower` | Moonflower | Mystic Garden | ★★★ | noćni cvijet | bijeli, svijetli rub (glow) | 🟡 |

### Spawn pravila (draft brojevi)

| Rarity | Udio u spawnu sjemena | Primjer u runu |
|--------|----------------------|----------------|
| ★ | ~60% | Clover, Daisy, Buttercup |
| ★★ | ~30% | Tulip, Sunflower, … |
| ★★★ | ~10% | Pumpkin, Watermelon; Lotus iz zlatnog grma |

- **Loadout:** odabrano sjeme +5% šanse po slotu (v1: 1 slot = +5%).
- **Zlatni grm (v1.1):** garantira jedan ★★★ iz seta trenutnog tjedna.

### v1 launch = 10 tipova (preporuka)

✅ Clover, Daisy, Buttercup, Tulip, Sunflower, Pumpkin, Watermelon + **dodaj za launch minimum:**
- **Lavender** (★★) — lijepa boja, raznolikost  
- **Rose** (★★) — store screenshot appeal  

→ Kompletni **Meadow Starter** (3) + **Summer Harvest** (3) + 4 solo = dovoljno za dnevnik i 2 set bonusa.

### Sprite pipeline (procjena)

| Faza | Spriteovi | Ukupno |
|------|-----------|--------|
| v1 launch | 10 tipova × 2 (sjeme + T2) + 3 coin + Pip + 2 grm | ~26 |
| v1.1 | +4 tipa × 2 + diary UI + 2 lane props | +12 |
| Glow varijante ★★★ | opcionalno overlay, ne novi sprite | +0–5 |

---

## Ideje — UI run progress (2026-07-04)

> **Ne sviđa se** trenutni **odbrojavajući tajmer** (`75s`, `74s`…) na vrhu.

### Zamjena: vertikalna linija napretka (lane progress)

| Aspekt | Odluka / skica |
|--------|----------------|
| Umjesto | broj sekundi na sredini vrha |
| Novi UI | **vertikalna traka** ~**1/5 širine** portret ekrana (npr. desni rub) |
| Dno trake | **start** runa — Pip / zastavica start |
| Vrh trake | **cilj** — zastavica / finish line |
| Pip ikona | mali zeko **ide uspravno** duž trake kako run napreduje (`elapsed / RUN_DURATION`) |
| Gameplay | run i dalje traje fiksno vrijeme (ili kasnije distance-based) — traka je **vizual**, ne nužno drugačija mehanika odmah |

**Zašto:** jasniji osjećaj "trčim prema cilju" umjesto abstract countdown; bolje za lore (livada gore).

**Launch:** 🟡 v1.1 ili C2 art pass — greybox može zadržati tajmer dok se ne implementira traka.

---

## Ideje — ekonomija sjemena i kamp (2026-07-04)

> Otvorena pitanja za kanon (`ekonomija`, `merge-kamp`) — **još nije odlučeno**.

### Fail pravilo (odlučeno za kod)

| Resurs | Na fail | Na uspjeh |
|--------|---------|-----------|
| **Sjeme** | **50%** (`round`) | 100% |
| **Novčići** | **50%** (`round`) | 100% |

*(Prije: novčići 100% na fail — promijenjeno 2026-07-04.)*

### Pitanja — kamp i cilj skupljanja

| # | Pitanje | Opcije / smjer |
|---|---------|----------------|
| E1 | **Brojač sjemena u kampu?** | Da — ukupno u vrtu + u "torbi" prije sadnje; ili samo po gredicama |
| E2 | **Šta je cilj skupljanja sjemena?** | (a) merge → cvijet → magnet/prskalica (trenutni hibrid) · (b) **setovi** (Meadow/Summer) · (c) **dnevnik 100%** · (d) craft lane dekor |
| E3 | **Jedan broj ili po tipu?** | "12 seeds" vs "Clover ×3, Sunflower ×1" — kolekcija traži **po tipu** |
| E4 | **Soft goal u kampu?** | "Još 2 Clover do mergea" / "Summer set 2/3" — umjesto apstraktnog broja |
| E5 | **Novčići u kampu?** | Samo **wallet** broj (shop), ne na gredicama |

### Preporuka (scratch, nije kanon)

- **Kamp prikazuje:** wallet novčići + **sjeme po tipu** (mala lista ili ikone), ne jedan agregat.
- **Primarni cilj igrača:** merge u vrtu + **setovi u dnevniku**; novčići = shop/kozmetika.
- **Brojač "meta":** % kolekcije ili set progress, ne "skupi 1000 sjemena".

### Odlučeno (2026-07-04)

| # | Pitanje | Odluka |
|---|---------|--------|
| E2 | **Cilj skupljanja sjemena** | **Oboje:** T2 → doniraj sprinkler **ili** zadrži za kolekciju/set/dnevnik |
| E1 | Brojač u kampu | Bag po tipu + `discovered_blooms` + T2 na gredicama |
| E3 | Prikaz | Po tipu (ne jedan agregat) |
| Kapacitet | Gredice | **9** vrt + **2** staklenik |
| Višak | K4 zamjena | **3× isti tip iz baga → 8 novčića** |

---

## Novčići — uloga (odlučeno 2026-07-04)

> Kanon za v1. Detalji brojki → [[../02-design/ekonomija-brojevi|ekonomija-brojevi]].

### Jedna rečenica

**Novčići = česta soft valuta za kozmetiku; sjeme = rijetka meta valuta za vrt, kolekciju i snagu (sprinkler).**

### Dvije valute — razdvajanje

| | **Novčići** | **Sjeme (po tipu)** |
|---|-------------|---------------------|
| **Frekvencija u runu** | često (~70% pickupa) | rijetko (~30%) |
| **Emocija** | "Pip je zaradio" — stalni tok | "Wow, novo sjeme!" — highlight |
| **Cilj igrača** | štednja za shop / skin | sadnja, merge, setovi, dnevnik |
| **Snaga (gameplay)** | ❌ ne | ✅ T2 → sprinkler (magnet) |
| **Sink (v1)** | kozmetika (skin Pip, pozadina, okviri) | merge, donate, loadout, kolekcija |
| **Perzistencija** | `wallet_coins` | `seed_bag` + gredice |

### Tok (povezanost s objektima)

```
RUN
  coin pickup ──────────────┐
  seed pickup ────┐         │
                  │         │
LOOT EKRAN        │         │
  finish_run      │         ├──► wallet_coins (novčići odmah u wallet)
  fail 50%        │         │
  Double (ad) ×2  │         │
  To Camp ────────┼──► seed_bag (sjeme u torbu)
                  │
KAMP              │
  plant / merge ──┘         │
  donate T2 bloom ─────────► sprinkler (magnet) — NE novčići
  exchange 3× seed ────────► +8 coins (recycle viška)
  Play ────────────────────► sljedeći run
                  │
SHOP (M8)         │
  wallet_coins ────────────► kozmetika (IN v1)
```

### Izvori novčića — v1 launch ✅

| Izvor | Status | Napomena |
|-------|--------|----------|
| Pickup u runu | ✅ kod | ~70% spawnova (ostatak sjeme) |
| Zamjena viška (K4) | ✅ kod | 3× isti tip → 8 coins |
| Rewarded ×2 loot | ✅ kod | i novčići i sjeme |
| Grmovi između traka | ❌ v1.1 | |
| Pasivni kamp (K5) | ❌ v1.1 | |
| Dnevni zadatak | ❌ v1.1 | |
| IAP coin pack | ❌ OUT v1 | samo starter pack burst, ne hard grind |

### Sink — v1 launch ✅

| Sink | IN/OUT | Napomena |
|------|--------|----------|
| Pip skinovi | ✅ IN | Pillar 2 — kozmetika |
| Pozadine trake / livade | ✅ IN | |
| Okviri dnevnika | ✅ IN | |
| Magnet / sprinkler | ❌ OUT | samo T2 donate |
| Loadout slot | ❌ OUT | progres kroz igranje, ne shop |
| Lane props unlock | 🟡 v1.1 | preko **setova sjemena**, ne novčića |

### Fail pravilo (novčići)

| Resurs | Fail | Uspjeh |
|--------|------|--------|
| Novčići | **50%** (`ceil`) | 100% |
| Sjeme | **50%** (`ceil`) | 100% |

→ Pillar 1: i fail daje nešto; novčići + sjeme padaju jednako.

### Odlučeno (novčići, 2026-07-04 večer)

| # | Pitanje | Odluka |
|---|---------|--------|
| C1 | Coins po runu | **Nije prioritet** — balans kasnije, playtest |
| C2 | Shop cijene (draft) | **Skin Pip 250** · **Pozadina livade 150** (M8 shop) |
| C3 | Wallet u kampu | ✅ **Vidljiv label** (`Wallet: X coins`) |
| C4 | Set bonus (+5% coins) | **v1.1+** — ne u v1 |
| C5 | Double loot | **Samo trenutni run** (`last_run_coins` / `last_seed_bag`); ×2 ne dira prošli wallet osim bonusa za ovaj run |

### Otvoreno (novčići)

- [ ] C1 brojke kad shop + playtest (niski prioritet)
- [ ] C2 fine-tune cijena nakon prvog shop prototipa

### Otvoreno (čekamo odluku)

- [ ] E1–E5: ~~potvrdi prije F4~~ → E2 + kapacitet **odlučeno 2026-07-04** (vidi gornju tablicu)
- [ ] Zamijeniti tajmer progress trakom — kada (v1.1 / art pass)?

---

## Odobreno za v1.1 (2026-07-11)

| ID | Naslov | Sažetak | Doc |
|----|--------|---------|-----|
| **MA-01** | Merge Arena | Gredice → poseban ekran; T1 rasuta + magnet drag; T2/T3 u Bloom inbox traku | [[../02-design/merge-arena-v1.1\|merge-arena-v1.1]] |
| **DG-01** | Daily Goals | 3 mini-zadatka/dan (coins, seeds po unlocku, merge tier) + bonus reward; prošireni chest | isti |

**Ne implementirati prije v1 launch.** Trenutni kamp (pair-first, seed chips, Keep→Album) = ship blocker polish, ne zamjena.

## Povezano

- [[ideje-identitet-lore|ideje-identitet-lore]] — Pip + sjeme/cvijet
- [[../02-design/mehanike/merge-kamp|merge-kamp]] — trenutni kamp (kanon)
- [[../02-design/ekonomija|ekonomija]] · [[../02-design/ekonomija-brojevi|ekonomija-brojevi]]
- [[../02-design/spec-vertical-slice|spec-vertical-slice]]
