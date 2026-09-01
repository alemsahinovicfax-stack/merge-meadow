---
type: sadrzaj
status: ideja
milestone: "v1.1+"
tags: [sadrzaj, arena, leftover, pitanja, freeze, scratch]
povezano:
  - ideje-arena-leftover
  - ideje-arena-leftover-grupe
  - ideje-arena-leftover-popup
  - ideje-arena-leftover-field
  - ideje-arena-leftover-grant
  - plan-prompts-arena-leftover
  - ideje-arena-sort
  - ideje-arena-pitanja
ai_sažetak: "ARENA-02 pitanja L0–L37 — pour ÷4, overlay; L1 reopen field T1; L21–L25 hide; L26–L30 debug 100; L31–L37 unpaired T1."
---

# IDEJE — ARENA-02 pitanja (L0–L37)

> [[ideje-arena-leftover|hub]]. Freeze **2026-08-28** (always_floor4 + refill 12 + overlay). L21–L30 isti dan (dismiss + debug 100). **L31–L37** isti dan (field T1, chat return_unmergeable).  
> ARENA-01 A0–A35 **ostaju**. A14 prag 10 **overridea** L0c na 12. A15 orphan **podređen** ÷4 (L2). A25 odd T1 na polju: pour A sprječava na ulazu; **E kod ne** — mid-session skida [[ideje-arena-sort|ARENA-03]] vacuum (t1_eq &lt; 4), ne leftover-E par.

## Freeze tablica

| # | Pitanje | Odluka |
|---|---------|--------|
| **L0** | Što popravljamo? | Odd T1 **na playfieldu** nakon što nema legalnog T3 puta; tap vreće trese ostatak i ponavlja bol. |
| **L0b** | 6 clover u torbi? | **Uvijek** 4 na polje, 2 u torbi. Ručni tap **i** auto-pour. `floor(n/4)*4` **po tipu**. |
| **L0c** | Auto-refill prag? | **12** (bilo 10). Cap polja **40**. Polje **0** i dalje ne auto-poura (FLOW-B). |
| **L0d** | Kad nema ×4 u torbi, a bag > 0? | Vreća klikabilna → overlay **You need more seeds!** + kamp T1 lista **`n/4`**. Tap **bilo gdje** → Camp (Done path). Nije IAP, nije fail. Done/Back bez overlaya ostaju. |
| **L1** | Pest pojede 1 od 4 na polju? | **Reopen L31.** Neparni T1 tog tipa ide u torbu (3→1 bag + 2 polje). FLOW-A T2 ostaje. Overlay se ne mijenja. |
| **L2** | A15 orphan (1 na polju) — pour 3 da se spoji? | **Ne.** Orphan prefer samo ako pour količina `% 4 == 0`. ÷4 > A15. |
| **L3** | Mythic pumpkin / watermelon? | **Da**, isto ÷4. Nema posebnog pour pravila. |
| **L4** | Overlay → Camp iz hub taba i standalone? | **Isto** `commit` + `go_to_camp_hub` kao Done. |
| **L5** | Tipovi s 0 u torbi u listi? | **Ne.** `5/4` se ne crta; pour prvo skine 4. |
| **L6** | Tutorial na prvom overlayu? | **Ne** (kao A26 C). `3/4` je copy. |
| **L7** | Soft cap torbe 40 vs debug 100? | Pour gleda **slotove polja** + ÷4, ne soft cap. Cap konstanta se **ne** diže u ovom tracku. |
| **L8** | Tap na red daisy u overlayu? | **Ne** radi ništa posebno. Cijeli overlay = Camp. Nema trade select. |
| **L9** | Jezik copyja? | **EN** kao arena HUD (`You need more seeds!`). i18n kasnije. |
| **L10** | FEEL-B clear-field VFX? | **Ostaje.** Rjeđi nakon E (neparni T1 ide u torbu); pest i dalje jede; VFX smije flashati kad resolve skine par. |
| **L11** | FLOW-A leftover T2? | **Ostaje.** ÷4 smanjuje uzrok; T2 recycle i dalje ako nema para. |
| **L12** | Combo / daily / Pip? | **Ne dirati.** Overlay nije combo break osim što odlazak u Camp radi Done (gasi combo). |
| **L13** | SAVE_VERSION / novi save key? | **Ne** za A/B/C/D/E. Overlay i field resolve nisu persist. Debug bag flag je in-memory. |
| **L14** | „Nothing to pour.“ za remainder? | **Ne.** To je overlay, ne info_label dead-end. |
| **L15** | Auto-refill pull 0 — spam overlay? | **Ne.** Overlay samo na **igračev tap** vreće. |
| **L16** | Arena full + remainder u bagu? | Postojeća full poruka. Overlay nije za full. |
| **L17** | Bag 0? | Postojeća empty poruka. |
| **L18** | Coin sink za odd T1 (A25 B)? | **Ne** u ARENA-02. Remainder ostaje u torbi za sljedeći run. |
| **L19** | Milestone / kanon spec? | v1.1+ scratch. [[../02-design/merge-arena-v1.1\|merge-arena-v1.1]] se **ne** prepisuje dok „dodaj u scope“. |
| **L20** | Grana / prompti? | **`master`**. Jedan Plan prompt po chatu: P0 → A → B → C-P0 → C → D → **E-P0 → E**. Ne spajati A+B, C+D, **D+E**. |
| **L21** | Overlay ostaje nakon Camp? | **Hide prije** `go_to_camp_hub`. Helper `_hide_need_more_overlay()`: `visible = false` + clear lista. Overlay tap, Done, Back — svi. |
| **L22** | Remen ako Done zaboravi hide? | `set_arena_page_active(false)` također hide. Tab swipe s Arene = overlay ugašen. Active true **ne** otvara overlay. |
| **L23** | „Ekran u areni isti ko prije“? | Overlay skriven, polje prazno, combo/Pip/tint reset (Done već). **Torba zadrži remainder T1.** Nije wipe savea, nije grant na tab return. |
| **L24** | Poruka „trebam još sjemena“ u popup-u? | **Da**, EN **You need more seeds!** kao naslov panela. Svijetla boja, ne `UI_TEXT` `#4A4A4A`. Nema drugog tutorial pasusa (L6). Scroll ne proguta naslov. |
| **L25** | C dira kad se overlay otvara / pour? | **Ne.** Auto-refill i dalje ne otvara (L15). Pour ÷4 i refill 12 ostaju A. |
| **L26** | Kad debug 100 u torbu? | **Svaki debug play**, jednom po **processu**, overwrite nakon load savea. **Ne** na povratak Arena taba (hub živi; loot u sesiji ostaje). |
| **L27** | Koji tipovi / cap / produkcija? | clover daisy buttercup tulip sunflower. Unlock 4, tutorial complete. `SEED_BAG_SOFT_CAP` **ne** diže. `DEBUG_DEV_RESOURCES` false = no-op. |
| **L28** | Brojevi (zbroj 100)? | Freeze, ne RNG: clover **19**, daisy **22**, buttercup **13**, tulip **28**, sunflower **18**. Mix ×4 + remainder. |
| **L29** | Arena `ensure_dev_unlocked_seeds(10)`? | **Prestaje** min-10 top-up (remainder 3 ne smije postati 10). Zamjena: D apply jednom po procesu. |
| **L30** | `grant_test_seeds.gd`? | Ista freeze mapa. Nema `SAVE_VERSION`. |
| **L31** | Mid-session leftover T1 na polju? | **Return unmergeable.** Po tipu, ako je T1 count **neparan**, vrati **jedan** T1 u torbu. 1→bag; 3→1 bag + 2 polje; 5→1 bag + 4 polje. Nije `n%4` (ne sva 3). Nije pour iz torbe da se popravi ×4 (L2). Overlay ostaje. |
| **L32** | Kad se pali? | Isti hookovi kao FLOW-A: `_pest_eat_chip` i nakon uspješnog mergea. `_resolve_stranded_t1` **prije** `_resolve_stranded_t2`. |
| **L33** | Koji chip? | Idle T1 tog tipa, **ne** dragging. Ako nijedan slobodan — skip. |
| **L34** | Bag full? | `seed_bag_remaining_capacity() < 1` → ostavi T1. Soft cap 40 se ne dize. |
| **L35** | Overlay / pour / pest FSM? | **Ne dirati** overlay B+C, pour A, refill 12, pest tajmere/T3 freeze. Eat samo zove resolve. |
| **L36** | FEEL-B? | **Ostaje.** Može flashati kad resolve skine zadnji par. |
| **L37** | Mythic / SAVE_VERSION? | Mythic isto `n%2`. Nema `SAVE_VERSION`. |

## Zašto ove odluke

### L0b — uvijek ÷4, ne samo zadnji val

„Samo kad bi leftover nastao“ ostavlja mid-session 5 daisy na polju. Igrač opet vidi mrtvo sjeme. Uvijek floor-4 čini **svaki** val T3-sposobnim na **ulazu**. Muncher i dalje može pokvariti parnost — to je E / L31.

### L0c — 12 ne 10

Isti FLOW-B stroj. 10 je playtest: polje prebrzo „prazno“. 12 je broj, ne nova petlja. 0-chip pravilo ostaje da leftover T2 / prazan Done ritual ne nestane.

### L0d — overlay umjesto disable vreće

Disable vreće = „igra je pokvarena, imam sjeme a ne mogu tapnuti“. Overlay pretvara instinkt u **Camp**.

### L1 — reopen (L31)

Prvi freeze: pest ostaje pritisak, T1 leftover na polju = FLOW-A/Done/FEEL-B. Playtest: 3 clover nakon eat **ponovo** mrtvo sjeme; torba `n/4` gubi smisao. E vraća samo **neparni** T1 (još ima T2 merge za 2). Muncher i dalje jede — nije nerf pest FSM.

### L2 — ne pourati 3

3+1=4 na polju zvuči pametno, krši „iz torbe samo ×4“ i komplicira queue. Igrač s 1 clover na polju (pest) i 4 u torbi dobije 5 — svjesni dug; default je ne tresti 3.

### L8 / L6 — lista nije shop

Tap red ≠ kupi. Tap = Camp. Bez tutorial toast.

### L21 — hide prije Camp

Hub ne uništava Arena page. Ako overlay ostane `visible`, povratak na tab pokazuje isti popup. Hide je dio Done patha, ne poseban Close gumb.

### L23 — čist ekran, torba ostaje

„Isti ko prije“ = vizual Arene prije stuck overlaya (playfield, vreća, bez dima). Remainder u torbi **jest** namjera leftover loopa. Wipe baga bi bio D na krivom mjestu.

### L24 — naslov postoji u tscn, nije na oku

`NeedMoreSeedsTitle` već ima copy. `section_title_scroll` + `UI_TEXT` `#4A4A4A` na tamnom panelu. C mijenja **kontrast i layout**, ne copy. Fair F2P: i dalje nema buy/ad.

### L26 — play, ne tab

Overwrite svaki F5 da leftover test bude reproducibilan. Overwrite svaki Arena tab bi pojeo run loot u istoj sesiji nakon overlay → Camp.

### L28 — zašto ne 20/20/20/20/20

Jednaki ×4: overlay tek kad igrač ručno spusti bag. Mix remaindera daje `3/4` `2/4` `1/4` nakon poura, plus tulip 28 za čist merge val.

### L29 — min-10 je tihi leftover killer

`ensure_dev` je dizao clover 3 na 10. Stuck overlay se „sam popravio“. D ✅ gasi min-10 na Areni; debug play vidi freeze **100**.

### L31 — neparni T1, ne sva 3

Vratiti 3 clover odmah bi ukinulo T2 merge (2 od 3). Igrač smije spojiti par. Jedan usamljeni T1 nema posla na polju — to je analog FLOW-A za T1. Pour-complete iz torbe bi kršio L2.

### L32 — T1 prije T2

`_t2_has_pair_chance` broji `field_t1 >= 2`. Ako T2 resolve vidi 1 leftover T1 kao „nema 2 T1“ to je OK; ako vidi 3 pa misli da T2 ima T1 put, T2 bi ostao dok 1 T1 leži. Zato prvo skini neparni T1.

## Što nije u L-tablici (namjerno)

Sort, tajmer, ads, energy, fail u areni, T4, bloom panel, Home sezone, AdMob. ARENA-01 G5 constraints i dalje vrijedi. Leftover G5 Field = E, nije to.

## Povezano

- [[ideje-arena-leftover-grupe|grupe]] · [[../06-production/plan-prompts-arena-leftover|prompti]]  
- [[ideje-arena-leftover-popup|popup L21–L25]] · [[ideje-arena-leftover-grant|grant L26–L30]] · [[ideje-arena-leftover-field|field L31–L37]]  
- ARENA-01 A14 A15 A25 [[ideje-arena-pitanja|pitanja]]
