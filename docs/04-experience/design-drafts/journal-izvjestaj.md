---
type: iskustvo
status: aktivan
milestone: M8
tags: [dizajn, ui, journal, claude-design, izvjestaj]
povezano:
  - journal-cd-brief
  - hub-header-footer-cd-brief
  - home-season-select-izvjestaj
  - changelog
ai_sažetak: "Izvještaj o prenosu CD paketa design_handoff_journal (smjer 1a Bloom Album) u Godot 2026-09-23: šta se promijenilo, šta testirati, odstupanja, testovi i šta slijedi."
---

# Journal — Bloom Album: izvještaj o prenosu

> Roditelj: [[04-experience/_index|04-experience]] · brief: [[journal-cd-brief]] (§ Implementacija) · datum: 2026-09-23 · **ništa nije commitano**

## Ukratko

CD-ov paket `design_handoff_journal/` (smjer **1a — pastel hub**) je u igri. Journal je i dalje lista svih cvjetova, ali sada ima zaglavlje stranice, poglavlja po sezonama i red koji rečenicom kaže šta ti je činiti.

- **Red** je 1032 × 200: lijevo ime, zvjezdice i kratka rečenica, desno tri slota (T1 · T2 · T3).
- **Prazan tier** je sada prsten, a ne sivi krug. Popunjen T1/T2 je krem okvir s tamnim wellom, a **T3 je zlatni kvadrat** — razlika se vidi i bez boje.
- **NEW** ostaje vidljiv cijelu posjetu i dobija roze pilulu na redu plus prsten oko tiera koji je nov.
- **Sezonska poglavlja** s brojem „N / 6 kept“ i lokotom kad sezona nije otključana.
- **Auto-scroll:** ako imaš nešto novo, lista se otvara na prvom novom cvijetu.

## Šta se vidi na ekranu

| Dio | Izgled |
|---|---|
| **Zaglavlje** | zlatna crtica + „Bloom Album“ u tamnom inku, ispod „Album: 5 blooms kept · 4 spotted“, pa tanka linija |
| **Poglavlje sezone** | ime sezone, linija, lokot ako sezona nije otključana, i „4 / 6 kept“ desno |
| **Zaključan cvijet** | siva kartica, `???`, tri prazna prstena, tekst „Keep playing to discover this bloom.“ |
| **Viđen** | kartica u boji rarityja, ime, ★, T1 popunjen, „Spotted in runs — merge to T2, then Keep in Album.“ |
| **U albumu (T2)** | T1 i T2 popunjeni, „In your Album (T2 bloom). Merge to T3 for crystal.“ |
| **Kristal (T3)** | sva tri popunjena, T3 zlatni kvadrat, „Crystal bloom saved in Album!“ |
| **Novo** | roze pilula „NEW“ gore lijevo, roze prsten oko novog tiera i posebna rečenica („New crystal in Album!“) |

## Šta testirati u igri

1. Otvori Journal iz huba i skrolaj do dna: osam poglavlja, 48 redova, bez zastajkivanja.
2. Zaključane sezone: `???` redovi i lokot na zaglavlju.
3. Odigraj rundu i mergeaj nešto novo, pa otvori Journal: red s NEW pilulom, a lista se otvara baš na njemu.
4. Dok si na Journalu, NEW ostaje na redu. Brojka na tabu nestaje čim otvoriš stranicu.
5. Odi na drugi tab i vrati se: NEW je nestao, red je u normalnom stanju.
6. Provjeri da se „Album: N blooms kept · M spotted“ slaže s redovima.

## Odstupanja od CD paketa (namjerna)

- **Stilovi se prave u kodu** (`ui_journal.gd`), pa `godot/styles/*.tres` iz paketa nisu kopirani. Brojevi su isti.
- **Lista nema traku za skrol:** vuče se prstom (`SHOW_NEVER`), umjesto tankog grabbera iz paketa.
- **Naslov je Label u Nunitu**, jer igra od Home v2 ima taj font, pa `title_bloom_album.png` nije trebalo ponovo peći.
- **Cvijeće crta igra** (`CampPlantDraw` / pravi art za Country Bloom), ne `ph_*` placeholderi iz paketa — tako paket i predviđa.
- **NEW na tabu** je ostao broj (opcija 1e), koji je radio i prije prenosa.

## Popravljeno usput

**Bug: NEW se nikad nije vidio.** Journal je pri otvaranju zvao `mark_collection_journal_viewed()` pa odmah crtao redove, tako da je oznaka „novo“ nestajala u istom frameu u kojem bi se pojavila. Sada se stanje snimi prije brisanja, pa NEW živi do odlaska sa stranice. Brojka na tabu se i dalje briše na otvaranje, kako je i bilo.

## Testovi

- Novi **`journal_new_snapshot_smoke`**: NEW je vidljiv poslije otvaranja i nestaje kad se stranica napusti.
- **`collection_journal_smoke`**, **`meta_hub_smoke`**, **`meta_hub_flow_smoke`** i **`swipe_snap_smoke`** prolaze.
- Cijeli suite je pokrenut uz ovaj prenos; poznati padovi ostaju isti (`menu_play_smoke`, `merge_arena_smoke`, `shop_smoke` ne ispisuju „OK“, `shop_nav_smoke` je stara greška sa statičkom referencom na `GameState`).

## Poznata ograničenja i sljedeći koraci

- **Art cvijeća** za 42 tipa van Country Blooma je i dalje proceduralan ([[seeds-flowers-cd-brief]]).
- **Tap na red** (detalji cvijeta), filter i pretraga nisu dizajnirani.
- **Sticky zaglavlje sezone** pri skrolu nije nacrtano ni napravljeno.
- **Golden Album** (frame + plaketa) se vidi samo kad je kozmetika `journal_gold` opremljena.
- Paket `design_handoff_journal/` je u korijenu repoa, uz ostale CD pakete.
