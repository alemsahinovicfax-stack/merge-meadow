---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, merge, combo, cliff, daily, scratch]
povezano:
  - ideje-arena
  - ideje-arena-pitanja
  - ideje-arena-feel
  - merge-arena-v1.1
  - design-pillars
ai_sažetak: "ARENA-01 ciljevi — combo prozor, soft cliff, daily slice DG-01, clear-field; brojke draft dok A1–A9 ne freezeaju."
---

# IDEJE — ARENA-01 ciljevi (combo, cliff, daily)

> [[ideje-arena|ARENA-01 hub]]. Ovo je **prioritet A** prvog tracka: isti magnet, novi sloj cilja. Feel/bloom/pest su drugi docovi; ovdje samo gdje se dodiruju (combo lomi pest, cliff čita donate, daily broji T3).

## Zašto ciljevi, ne novi verb

Magnet merge je dovoljno zadovoljavajući kao **gesto**. Monotonija dolazi jer **svaki merge ima istu vrijednost**. Prvi T1+T1 i dvadeseti T1+T1 osjećaju se jednako. Kamp to rješava cliffom („još 1 do magneta“); arena to nema.

Tri sloja, od sesije prema danu:

| Sloj | Vrijeme | Što drži |
|------|---------|----------|
| **Combo** | 1–3 sekunde | Tempo ruke; „još jedan brzo“ |
| **Soft cliff** | ova sesija / ovaj bag | Smjer: koji tip, koji donate |
| **Daily** | local day | Razlog otvoriti arenu sutra |

Nijedan sloj **ne smije** biti obavezan za upgrade ili run. Combo 0 i dalje mergea T3. Daily neblokiran = Pillar 2. Nema „ističe vrijeme, izgubio si sjeme“ = Pillar 3.

## Combo / streak

### Pravilo (draft, A1–A3 freeze)

1. Uspješan snap merge (`try_merge_arena_chips` ok) → combo += 1 ako je proteklo **manje od prozora** od prethodnog mergea; inače combo = 1.
2. Prvi merge sesije (nakon pour ili praznog polja) = combo 1. HUD se smije sakriti dok je 1, pokazati od 2 (čitljivije na mobitelu).
3. Prozor (A2): kratko 1.2–1.6 s / srednje 2.0–2.5 s / dugo ~3.5 s. Draft preporuka dok nema odgovora: **B srednje** — casual palac, Muncher još uvijek stigne smetati.
4. HUD: veliki broj blizu gornjeg ruba playfielda ili uz `info_label`. Copy (A31): Combo / Streak / Bloom chain. Engleski UI (projekt).
5. Sesija reset: Done, Back, prazno polje + pest sleep, izlaz sa stranice. Ne persistati combo u save (osim A20 C = best).

### Nagrada (A1)

| Opcija | Ekonomija | Pest | Rizik |
|--------|-----------|------|--------|
| **A** samo vizual | Nema | Nema | Najčišće; combo može biti „prazan broj“ |
| **B** vizual + extra freeze | Nema | +0.5 s po stupnju, cap npr. +2 s | Combo postaje obrana od Munchera |
| **C** vizual + 1–2 coins na 5+ | Da, **dnevni cap** (npr. 10 coins/dan) | Nema | Farm kroz prazne mergeve; treba cap |
| **D** A+B bez coina | Nema | Kao B | Preporuka ako A3 lomi combo na eat |

**Pillar 2:** coins s comba nikad ne smiju biti jedini put do upgradea. Ako C, cap mora biti manji od daily chest mikro nagrade ili jednak, ne veći.

**Ne:** combo multiplier na loot sljedećeg runa, combo koji skipa T2, IAP „combo shield“.

### Što lomi combo (A3)

| Opcija | Feel |
|--------|------|
| **A** samo timeout | Cozy; pest je vizual, ne sudac |
| **B** timeout + pest jede bilo koji chip | Pest ima zube; combo = rizik |
| **C** + prazan drag (release bez mergea) | Strože; kažnjava lov / misclick |

Prazan drag je čest dok loviš par u 40 chipova. **C** uz A14=40 može biti frustrirajuće. Ako clutter ostane visok, A ili B su sigurniji.

Done / Back **uvijek** gase combo (nije kazna — izlaz).

### Auto-chain (A22)

Danas: T1+T1 ostavlja T2; sljedeći T2+T2 je **novi** drag.  
Ako B: novi T2 se magnetom vuče na postojeći T2 u radiusu → lanac T1→T3 u jednom pokretu. To **jako** hrani combo (2 mergea brzo).  
Ako C: lanac samo dok je combo već ≥3 — nagrada za tempo, ne default.

Draft dok nema freeze: **A ručno** u prvom kodu (manje rubnih slučajeva s pestom koji jede mid-chain).

### Interakcija s Merge Hint (A23)

Hint danas: tekst, `consume_merge_hint_booster` na ulazu. Combo je nezavisan (A). Ako pair pulse postoji (A12), hint smije **isti** pulse (B) — to je feel, ne nova ekonomija. C (hint pauzira pest 3 s) je jači consumable; Pillar 2 OK samo ako je **opcioni** i core merge radi bez njega.

## Soft cliff

### Što je

Jedna rečenica, jedan broj. Nije lista zadataka. Isti duh kao Camp `garden_cliff_text`, ali **vidljiv dok mergeaš**.

Primjeri (EN copy, draft):

- `1 more Clover to make a T2.`
- `1 more T2 Clover to crystal.`
- `Donate 1 bloom for Sprinkler Lv3.`
- `Daily: combo 5 — 2/5.`

### Primarna poruka (A4)

| Opcija | Kad je dobro | Kad smeta |
|--------|--------------|-----------|
| **A** merge | Uvijek ima para na polju / u bagu | Kad je bag mix i „koji Clover“ nije očito |
| **B** donate | Igrač je u upgrade hunt | Kad su upgradei maxed (već ima poruku Keep) |
| **C** daily | Retention hook | Dosadno ako daily nije u ovom tracku (A6 C) |
| **D** rotira | Jedan slot, pametan prioritet | Treba pravila prioritet ili izgleda nasumično |

Draft prioritet za D (ako freeze D):

1. Ako postoji legalan par **na polju** za tip koji je 1 merge od T3 → ta poruka.
2. Inače ako donate nije maxed i ima T2 na polju → donate.
3. Inače daily progress.
4. Fallback: postojeći pest/tutorial `info_label`.

### Gdje stoji (A5)

| Opcija | Pros | Cons |
|--------|------|------|
| **A** `info_label` | Nema novog nodea | Gubi pest tutorial / merge hint dok je cliff uključen |
| **B** fiksni red iznad playfielda | `info_label` ostaje transient | +1 HUD; titovi na malom ekranu |
| **C** samo Camp | Nula posla u areni | Ne rješava monotoniju **u** areni |

Track A bez B-slice HUD-a je besmislen ako A5=C. Ako korisnik izabere C, cliff **ispada** iz ARENA-01 koda (ostaje Camp).

### Izvor podataka

`GameState`: bag counts po `type_id`, `_chip_data` na polju, `sprinkler_donations` / `MAGNET_COST_T2`, `multiplier_donations`, daily progress. Cliff mora biti **čista funkcija** (lako smoke: 1 Clover T1 na polju + 1 u bagu → „1 more Clover“).

Ne duplicirati quest state. Ne persistati „koji cliff je prikazan“ — računaj svaki merge.

## Dnevni arena zadatak

DG-01 u [[../02-design/merge-arena-v1.1|merge-arena-v1.1]] = 3 zadatka + bonus, prošireni chest, v1.1.1. ARENA-01 smije uzeti **prvi slice**, ne cijeli sistem, osim A6=B.

### Koliko (A6)

| Opcija | Scope | Veza DG-01 |
|--------|-------|------------|
| **A** jedan arena zadatak | Ovaj track | Kasnije se 3. slot DG-01 može mapirati na ovo |
| **B** puna trijada | Preveliko za ARENA-01 A–C | Run coins + seeds + merge u jednom PR-u |
| **C** nema dailya | Combo + cliff only | DG-01 ostaje parking |

Draft: **A**. Generator (jedan od, skalirano na unlock):

- Merge **3× T2** danas.
- Napravi **1× T3** (crystal stash).
- Dostiži **combo 5** jednom danas.

Ne: „potroši IAP“, „pogledaj ad“, „merge mythic only“.

### Nagrada (A7)

Uskladiti s `DAILY_CHEST_*` u ekonomija-brojevi **kad** freeze i „dodaj u scope“. Draft dok nije kanon:

| Opcija | Draft | Pillar 2 |
|--------|-------|----------|
| **A** coins | +6 do +8 (chest mikro, ne burst) | OK |
| **B** coins + 2–3 unlocked T1 | Mali pour sutra | OK ako tipovi već unlocked |
| **C** samo badge | Nula ekonomije | Slab retention |

Claim **1× po local day**, isti key duh kao `last_daily_chest_day` (novi key, npr. `last_arena_daily_day`, da chest i arena daily ne gutaju jedan drugog).

### UI (A8)

| Opcija | Gdje claim | Gdje progress |
|--------|------------|---------------|
| **A** red u areni | Arena | Arena |
| **B** daily chest Camp | Camp | Camp (arena samo broji u save) |
| **C** oboje | Camp | Arena vidi 2/5, Claim u Campu |

A zahtijeva chrome u areni (Done bar već gusto). B je najmanje UI, ali igrač ne vidi zadatak dok mergea. C je najjasniji loop, dva mjesta.

Ne blokirati Done ako daily nije claiman. Ne auto-otvarati arenu u ponoć.

## Clear-field bonus (A9)

**Definicija:** na polju nema para `(type_id, tier)` s count ≥ 2. Odd T1 i neraspoloženi T2 (čeka spend) **jesu** clear u smislu „nema mergea“.

| Opcija | Nagrada | Rizik |
|--------|---------|-------|
| **A** VFX + maybe 1 coin | Sitno | Coin farm: pour 2, merge, repeat |
| **B** samo VFX | Čisto | Dovoljno za „ah!“ |
| **C** ne | — | Manje posla |

Ako A: **sesijski cap** 1 coin ili 0 ako je combo C već dao coins. Nikad po mergeu.

Nije fail ako igrač **ne** clear-a. Nije zvono za Done. Bag još može imati sjeme — pour again je OK.

## Sesija i duljina (A24)

Cilj feel-a, ne tvrdi tajmer (A21 default bez tajmera).

| Opcija | Dizajn implikacija |
|--------|-------------------|
| **A** 20–40 s | Prvi pour mora imati par; combo prozor smije biti kraći; daily = 1 T3 max |
| **B** 1–2 min | Bag empty je cilj; cliff merge ima vremena; pest pritisak duže |
| **C** oba | Prvi pour = combo + cliff hit; ostatak poura opcionalan, Done uvijek OK |

**A21 tajmer:** A bez tajmera je default tracka. B hurry 30 s = opt-in bonus, default off. C mini-runda po pouru mijenja sandbox — veći scope, skoro van A-tracka.

## Score (A20)

Nije leaderboard. Nije online.

- **A** samo combo broj (nestaje).
- **B** sesijski `merges * combo_at_merge` sum, nula na Done, HUD mali.
- **C** `best_arena_combo` u saveu — Pillar 3 soft, bez poredjenja s drugima.

B+C mogu zajedno kasnije; u prvom kodu biraj **jedno** da HUD ne bude burza.

## Odd leftover (A25)

Vezano uz clear-field i T2 chore. Status quo: Done reciklira T1; T2 tap spend. B (3 odd T1 → 1 coin) je mini-sink u areni — nova mehanika, nije cilj-sloj; samo ako freeze. C (auto return T1) smanjuje Done ritual.

## Tutorial (A26)

Combo se uči **jednom**. A = nova rečenica na `info_label`. B = toast na prvom combo≥2, flag u save (`arena_combo_tutorial_shown`). C = ništa.

Ne novi tutorial korak u `tutorial_*` skripti. Ne blokirati pour.

## Prioritet sliceova (A32)

Default plan promptova: combo → cliff → daily.  
Ako B: cliff prvo (poruka postoji, combo kasnije).  
Ako C: daily prvo (retention), pa combo.

A33 (što iz B/C u prvi kod): čisti A vs pair pulse vs T2 inbox. Pulse pomaže combo (vidiš sljedeći par). T2 inbox ubrzava tempo (nema panel mid-combo). Oba su **scope creep** ako uđu u isti PR kao combo HUD.

## Što ne mijenja ovaj doc

- Magnet radius, snap, chip separation.
- `MAX_MERGE_TIER` = 3.
- Fair F2P run math.
- Home / sezone.

Brojke (prozor sekunde, coin cap, daily +N) idu u `ekonomija-brojevi.md` **tek** na „dodaj u scope“, ne sada.

## Povezano

- [[ideje-arena|hub]] · [[ideje-arena-pitanja|A1–A9 A20–A22 A24 A26 A32]]
- [[ideje-arena-feel|feel]] — pulse da combo nije slijep
- [[../02-design/merge-arena-v1.1|DG-01]]
