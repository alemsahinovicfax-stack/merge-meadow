---
type: sadrzaj
status: ideja
milestone: "—"
tags: [sadrzaj, tutorial, onboarding, ux, brainstorm, scratch]
povezano:
  - ideje-gameplay-ekonomija
  - ideje-identitet-lore
  - core-loop
  - spec-vertical-slice
ai_sažetak: "SCRATCH — minuta-po-minuta scenarij prvih 5 min (Pip, novčići, sjeme, vrt, loadout). Nije kanon."
---

# IDEJE — prvo iskustvo (~5 min)

> ⚠️ **Brainstorm / režija.** Ne mijenja `core-loop`, `spec-vertical-slice` ni kod.
> Temelji: [[ideje-identitet-lore|Pip + sjeme/cvijet]], [[ideje-gameplay-ekonomija|kamp K1+K3+K6, scope v1]].
> Stari `core-loop` tutorial (~60 s) **proširujemo** na puni onboarding novog dizajna.

## Cilj sesije

Nakon ~5 minuta igrač **mora znati**:

| # | Igrač zna… |
|---|------------|
| 1 | Tko je Pip i **zašto** trči (livada je izgublila boju) |
| 2 | **Novčići** = česta valuta (shop, kasnije) |
| 3 | **Sjeme** = rijetko, posebno, ide u kamp |
| 4 | Kamp = **sadnja + merge** (2 ista → cvijet) |
| 5 | **Loadout** = biraš što će se češće pojavljivati u runu |
| 6 | Razlog za **drugi run** (još jedno sjeme / skoro merge / set) |

**Komercijalni KPI:** prvi satisfying trenutak &lt; 15 s; prvi merge &lt; 4 min; želja za run #2 prije izlaska.

---

## Pravila tutoriala

- **Max 2 callout bubblea** (ostalo = animacija, SFX, vizual).
- **Bez cutscena**, bez NPC dijaloga.
- **Run 1:** bez faila (ili near-miss samo na novčiće — R6).
- **Run 2:** prva prava prepreka + 50% loot na fail (kratko objašnjenje na loot ekranu).
- **Ne uvoditi u Run 1:** staklenik ★★★, grmovi između traka, shop, rewarded oglasi, dnevnik (otključava se nakon Run 2).
- **Jezik bubblea:** EN (store jezik).

---

## Timeline — minuta po minuti

### 0:00–0:15 · Main menu

| Što se vidi | Što se događa |
|-------------|---------------|
| Pip (sprite ili placeholder s imenom) | Jedna rečenica ispod Play: *"Help Pip bring color back to the meadow."* |
| Play gumb | Tutorial hint (samo prvi launch): *"Swipe left and right in the run."* |

**Bubble #1 (jedini na startu):** nema — rečenica je dio UI-a, ne popup.

Igrač tapne **Play** → odmah Run 1 (bez međuekrana).

---

### 0:15–1:30 · Run 1 — "novčići i prvo sjeme"

| Vrijeme | Događaj | Feel / juice |
|---------|---------|--------------|
| 0:15 | Prvi swipe — Pip se pomakne (tween) | blagi SFX hop |
| 0:20 | **Novčići** počnu padati (često, 3 lanea) | +1 fly to HUD, zlatni bljesak |
| 0:35 | Callout na HUD: ikona novčića + *"Coins for the shop!"* (2 s, nestane) | ne blokira input |
| 0:45 | Prvo **sjeme Clover ★** — jedini u ovom runu | veći fanfare, Pip skok (R4), zvuk ★ |
| 1:00 | Još novčića, **nema prepreke** | tempo opušten |
| 1:20 | Timer kraćen (Run 1 = **45 s**, ne punih 75) | namjerno kraći tutorial run |
| 1:30 | Finish (uspjeh) → Loot ekran | *"Run Complete!"* |

**Loot Run 1:** npr. 12 novčića + 1 Clover ★. Bez Double/Revive gumbi još (pojave se Run 2).

Igrač razumije: **novčići = stalno, sjeme = wow moment**.

---

### 1:30–2:45 · Kamp — "prva gredica"

| Vrijeme | Događaj | UI |
|---------|---------|-----|
| 1:35 | Auto ili gumb **To Camp** | prijelaz |
| 1:40 | Kamp: **vrt s gredicama** (K1). Jedna gredica **svijetli** | ostale prazne/zatamnjene |
| 1:45 | **Bubble #2:** *"Plant your seed here!"* (strelica na gredicu) | jedini vođeni korak u kampu |
| 1:50 | Tap gredica → Clover se sadi (T1 sprite) | mali "pop" |
| 2:00 | Kratki tekst u `info_label`: *"Collect more of the same seed to merge into a flower."* | ne popup |
| 2:10 | Gumb **Play** / *"Another run!"* istaknut | |
| 2:15 | **Loadout (K6):** koš pored Play — **prazan**, siva ikona + *"Fill your basket later"* | ne forsirati Run 2 |
| 2:20 | Staklenik u pozadini — **zaključan** vizual (katanc) | ★★★ kasnije |
| 2:30 | Igrač ide na Run 2 | |

**Ne pokazuj:** merge, magnet, shop, dnevnik.

---

### 2:45–3:45 · Run 2 — "još sjemena, prva opasnost"

| Vrijeme | Događaj | Napomena |
|---------|---------|----------|
| 2:45 | Normalniji run (**60 s**) | više novčića |
| 3:00 | Drugo **Clover ★** | igrač povezuje: trebam još jedno |
| 3:20 | Opcionalno: **Daisy ★** (drugi tip) — "Novo!" mali badge | uvodi raznolikost, ne obavezno Run 2 |
| 3:35 | **Prva prepreka** na laneu (jedna, predvidiva) | vizual: lokvica / tamni grm |
| 3:40 | Sudar → fail **ili** prođe ako swipea | ako fail → 50% loot objašnjenje |

**Loot Run 2:** novčići + 1–2 sjemena. Tek sada na loot ekranu:

- Kratka linija: *"Hit an obstacle? You keep half your seeds."*
- Gumbi **Retry** + **To Camp** (Revive/Double — prvi put **sivi** s *"Coming soon"* ili rewarded placeholder kad AdMob spreman).

---

### 3:45–4:45 · Kamp — "prvi merge"

| Vrijeme | Događaj | Feel |
|---------|---------|------|
| 3:50 | U kampu: 2× Clover T1 u gredicama (posadi drugi) | ili auto-deponuj iz loota |
| 4:00 | Vođenje: tap jedan Clover → tap drugi → **merge** | animacija rasta u **Clover cvijet T2** |
| 4:10 | `info_label`: *"Nice! Merged into a flower. The meadow feels brighter."* | lore bez priče |
| 4:20 | **Loadout otključan:** stavi **Clover** u koš (1 slot, v1 launch) | *"Clover will show up more in your next run!"* |
| 4:30 | Pip reakcija u kampu (hop) | cozy beat |
| 4:40 | Soft cliff na ekranu: *"Collect Sunflower ★★ for the Summer set!"* ili *"1 more merge unlocks Magnet sprinklers"* | ovisi o balansu |

---

### 4:45–5:15 · Run 3 (opcionalno u tutorialu) — "loadout radi"

| Što se događa | Dokaz |
|---------------|-------|
| Clover se **češće** spawna u runu | igrač vidi uzrok ↔ posljedicu |
| Kraj runa → igrač sam ide u kamp ili Play | **tutorial flag** `tutorial_seen` = gotovo |
| Dnevnik: ikona **otključana** s 1–2 unosa (Clover, Daisy) | L1 light — bez silueta još |

**Kraj tutoriala (~5 min):** main menu hub — **Play** ili **Camp**, bez vođenja (vidi dolje).

---

## Nakon tutorijala — main menu hub (odlučeno 2026-07-04)

| Stanje | Main menu |
|--------|-----------|
| Prije mergea (tutorial) | Samo **Play** + swipe hint |
| Nakon mergea | **Play** + **Camp**, bez hinta, bez tutorial runa |
| Ponovni ulazak u app | `user://tutorial_flags.json` pamti `tutorial_complete` — tutorial se ne ponavlja |

Igrač bira: novi run ili direktno u vrt.

### UX backlog — Main menu iz kampa (UX-01, ideja)

| | |
|---|---|
| **Problem** | Hub (Play + Camp) je na main menuu, ali iz kampa samo **Play** — restart Godota da vidiš hub. |
| **Rješenje** | Gumb **Main Menu** u kampu → `main_menu.tscn` (tutorial flag ostaje). |
| **Kad raditi** | Camp navigacija / F8 polish — vidi [[../06-production/ideje-kad-predloziti\|ideje-kad-predloziti]] UX-01. |
| **Status** | ✅ implementirano 2026-07-05 (`MainMenuButton` u `camp_scene`) |

---

## Što je IN vs OUT u tutorialu

| IN (prvih 5 min) | OUT (kasnije / v1.1) |
|------------------|----------------------|
| Novčići + 1–2 tipa sjemena (★) | 10 tipova, ★★★ |
| Vrt, 1 gredica vođena | Staklenik gameplay |
| Merge T1→T2 jednom | Magnet upgrade |
| Loadout 1 slot | 3 slota |
| Jedna prepreka, 50% fail | Grmovi između traka |
| Retry, To Camp | Rewarded ×2 / Revive (ili placeholder) |
| Dnevnik ikona | Pun katalog + siluete |
| Shop | Nakon 3. runa ili kamp level 2 |

---

## Callout tekstovi (EN draft)

| # | Tekst | Kad |
|---|-------|-----|
| UI | *Help Pip bring color back to the meadow.* | Main menu |
| 1 | *Coins for the shop!* | Run 1, ~20 s |
| 2 | *Plant your seed here!* | Kamp, prva gredica |
| — | *Collect more of the same seed to merge into a flower.* | Kamp info_label |
| — | *Hit an obstacle? You keep half your seeds.* | Loot Run 2 |
| — | *Clover will show up more in your next run!* | Loadout unlock |
| cliff | *Collect Sunflower for the Summer set!* | Nakon mergea |

---

## Brojke za tutorial runove (draft — uskladiti s [[../02-design/ekonomija-brojevi|ekonomija-brojevi]] kad postane kanon)

| Run | Trajanje | Novčići (target) | Sjeme | Prepreka |
|-----|----------|------------------|-------|----------|
| Run 1 | 45 s | 10–15 | 1× Clover ★ | 0 |
| Run 2 | 60 s | 15–20 | 1–2× ★ | 1 (srednji lane) |
| Run 3+ | 75 s | normal spawn | normal | normal |

Spawn Run 1: **100%** barem jedan pickup; novčići svaki ~1.5 s; sjeme fiksno na ~30 s.

---

## Kriterij "tutorial gotov" (DoD za dizajn)

- [ ] Igrač bez pomoći posadi sjeme u gredicu
- [ ] Igrač sam napravi merge nakon 2. runa
- [ ] Igrač razumije razliku novčić vs sjeme (playtest pitanje)
- [ ] Igrač stavi sjeme u loadout i primijeti razliku u Run 3
- [ ] Max 2 bubblea — playtest: nije "previše teksta"
- [ ] Prvi merge prije 4. minute (timer u playtestu)

---

## Povezano

- [[ideje-gameplay-ekonomija|ideje-gameplay-ekonomija]] — scope, sjemena, kamp
- [[ideje-identitet-lore|ideje-identitet-lore]] — Pip motivacija
- [[../02-design/core-loop|core-loop]] — stari 60 s tutorial (kanon, zastarijeva)
- [[../02-design/spec-vertical-slice|spec-vertical-slice]] — trenutni kod (kanon)

> **Build order:** [[../06-production/ideje-roadmap-implementacije|ideje-roadmap-implementacije]]  
> **Kad predložiti ideju:** [[../06-production/ideje-kad-predloziti|ideje-kad-predloziti]]
