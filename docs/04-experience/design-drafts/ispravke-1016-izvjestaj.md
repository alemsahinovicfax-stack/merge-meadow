---
type: iskustvo
status: aktivan
milestone: M8
tags: [iskustvo, ispravke, arena, camp, home, shop, run, settings, privacy]
povezano:
  - run-pickups-cd-brief
  - privacy-policy-draft
  - greske-katalog
  - CHECKPOINT
ai_sažetak: "Ispravke poslije playtesta 2026-10-16: Settings iznad Arene i zaključan zupčanik tokom runde, muncher u sredini i uvijek na najbližoj sjemenki, Camp link nastavlja s plaćenim sezonama (samo cijena), rezervisano cvijeće zadnje, Home polje raste po ukupno uzgojenom ★3, bez čipa „0 / 13 grown", vreća bez limita (plijen se više ne gubi), Shop štand iznad kartica, nadogradnje smiju trošiti i ★3 čuvano za sljedeću sezonu; Loot Boost na ukupno sjeme, bez duplog boosta na revive, vidljiv pečat (Twin provjeren); odgovori o vibraciji, Reduce motion, Restore purchases i politici privatnosti; CD brief za pickupe u runu i kartice plaćenih sezona u Campu."
---

# Ispravke 2026-10-16 — izvještaj

> Roditelj: [[../_index|04-experience]] · CD uputstvo: [[run-pickups-cd-brief]] · politika privatnosti: [[../../05-technical/privacy-policy-draft|privacy-policy-draft]]

## Ukratko

| # | Tvoja prijava | Uzrok | Šta je urađeno |
|---|---------------|-------|----------------|
| 1 | U Areni otvorim Settings — neki elementi idu preko njega | Settings je imao z 50, a Arena slojeve do z 60 (muncher, pilula „N / 50", combo) | Settings je iznad svega (z 200) |
| 2 | Settings ne smije raditi dok traje runda u Areni | Zaključavali su se samo tabovi i swipe | Zupčanik je zaključan i prigušen (60 %) dok traje runda, kao tabovi |
| 3 | Muncher u sredinu Arene, ne na vrh | Gnijezdo je bilo fiksno na y 132 | Gnijezdo je u centru polja (540, 795); sjeme se ne spawnuje preko njega |
| 4 | Muncher zaključa jedno sjeme i zaobilazi sve usputno | Meta se birala samo kad stara nestane | Svakih 0,25 s ide na sjemenku koja mu je SADA najbliža; mijenja metu kad je druga bliža bar za 24 px (da ne treperi) |
| 5 | Kad uzmem sve free sezone, Camp link kartica nestane | Kartica je znala samo za besplatne | Nastavlja s prvom plaćenom sezonom koju nemaš: ime + zlatno dugme s **cijenom** (bez coina i ★3). Kupovina ide kroz isti IAP kao na Homeu, pa isti „burst" i Home na kupljenoj sezoni. Nestaje tek kad imaš sve |
| 6 | Cvijeće s alertom (rezervisano) uvijek zadnje u Campu | Lista je bila po rijetkosti i imenu | Rezervisani ★3 tip je uvijek na kraju; prvo se nudi ono što se slobodno prodaje |
| 7 | Home polje se ne mijenja poslije Arene | Polje je čitalo **trenutni stash**. Tvoj stash je bio prazan (prodato / potrošeno), iako si napravio T3 cvijeće | Polje broji **ukupno uzgojeno ★3** (novi brojač `star3_grown`): ne vene kad prodaš u Campu ili otključaš sezonu. Novi T3 iz Arene izraste čim se vratiš. Stari save dobija brojač iz Albuma (svaki ★3 iz Dnevnika = bar 1) |
| 8 | Ukloni „0 / 13 grown" | — | Čip je uklonjen iz scene i koda |
| 9 | Sjemena iz runa ne dođu u Camp (i sa ×2 i bez) | Vreća je imala limit 40; tvoja je bila 38 / 40, pa su od plijena stala 2 sjemena, a ostatak se obrisao | **Vreća nema limit** — sav plijen ide u Camp. Arena ionako sipa samo koliko polje prima |
| 10 | Shop · Boosters: skinovi idu preko štanda s tabovima | Štand je imao z 3, a Pip u „All set" i u karticama do z 15, oznaka „Premium" z 16 | Štand je iznad svih kartica (z 20); izmjereno na sva 4 taba |
| 11 | Pickup animacije u runu | — | **CD uputstvo, dio A:** [[run-pickups-cd-brief]] + slike `run-pickups-ref/` |
| 12 | Camp kartice plaćenih sezona da imaju dizajn kao besplatne | Plaćene sezone nemaju Season Kit recept „camp", pa je kartica samo obojena (sada u boji livade sezone) | **CD uputstvo, dio B** (isti brief, §4) + slike `camp-paid-card-ref/` |
| 13 | Imam coine i cvijeće, a nadogradnju (Magnet / Loot / Twin) ne mogu kliknuti | Nadogradnje su čuvale onoliko ★3 koliko traži sljedeća besplatna sezona (Kept). Na Frostu: 20 Crystal Peony, Lantern traži tačno 20 → „nemaš cvijeća" (roza oznaka preko cvijeta), čak i sa 500 coina | Nadogradnje sada smiju potrošiti sve ★3 sezone. Kad kupovina zadire u cvijeće za sljedeću sezonu, ispod imena sezone piše „Uses flowers saved for Lantern Meadow". Kept granica ostaje samo za prodaju u Campu |
| 14 | Loot Boost kao da se ne primjenjuje; provjeri i Twin Seeds | (a) bonus se zaokruživao **po tipu sjemena**: 1 × 1,25 = 1, pa run s mnogo tipova po jedno-dva sjemena nije dobijao skoro ništa; (b) revive je boost primjenjivao dvaput; (c) nigdje se nije vidjelo da je boost uračunat | Bonus se računa na **ukupno** sjeme i dijeli po tipovima (5 različitih × 1,25 = 6, ranije 5); revive ga primijeni jednom; na kraju runa zlatni pečat „Loot Boost ×1.25 · 3 twins". Twin Seeds je radio ispravno (8 % po nivou), sada se i vidi koliko ih je bilo |

## Nadogradnje i „Kept" cvijeće

| Gdje | Prije | Sada |
|------|-------|------|
| Prodaja u Campu | ne prodaje ispod onoga što traži sljedeća sezona (Kept · N / M) | isto |
| Nadogradnje na polju | nisu smjele dirati Kept cvijeće — dugme je izgledalo kao „nema cvijeća" | smiju; napomena na sheetu kaže čije cvijeće troše |

Tvoj slučaj: Frost, 20 Crystal Peony, Lantern traži 20. Twin Seeds sada košta 2 cvijeta i 10 coina, pa ostane 18 / 20 — Camp kartica Lanterna to odmah pokaže.

## Loot Boost i Twin Seeds

| Nivo | Loot Boost | Twin Seeds (šansa da sjeme da 2) |
|------|-----------|----------------------------------|
| 0 | ×1.0 | 0 % |
| 1 | ×1.25 | 8 % |
| 2 | ×1.5 | 16 % |
| 3 | ×1.75 | 24 % |
| 4 | ×2.0 | 32 % |

- **Gdje se vidi:** brojač u runu je bez boosta (ono što pokupiš). Pauza i kraj runa pokazuju plijen **s** boostom; zlatni pečat kaže zašto je veći.
- **Pad:** boost se računa prije „Kept half" — od 15 coina s ×1,5 ostane 8.
- **Revive:** run nastavlja s pokupljenim brojevima, boost se primijeni jednom na kraju.
- **Twin:** samo sjeme sa staze (nagradni grm ne), i ide prije boosta — Twin 2 × ×1,25 se slažu.
- **Po sezoni:** nadogradnje kupljene na polju Frosta važe kad igraš Frost. Otvaranje polja sezone je postavlja kao aktivnu; u drugoj sezoni nivoi su njeni (možda 0) — ako si kupovao na jednoj, a igrao drugu, boost nije bio aktivan.

Primjer (×1,25): pokupiš clover, daisy, tulip, sunflower, buttercup po 1 → ranije 5, sada 6. Zaokruživanje po tipu je bilo nasumično: po jedno sjeme nije davalo ništa (1 → 1), po dva je davalo više (2 → 3). Sada je uvijek ×m na ukupno: 7 + 2 + 1 = 10 → 13 (9 + 3 + 1).

## Odnos polja, Campa i Dnevnika (provjereno)

| Gdje | Šta pokazuje | Šta ga mijenja |
|------|--------------|----------------|
| **Camp · Flowers** | ★3 cvijeće koje imaš za prodaju (stash) | Arena T3 i Loot Burst (+), prodaja i otključavanje sezone (−) |
| **Dnevnik (Album)** | otkriveno cvijeće i najviši tier koji si imao | samo raste (Arena T3, Loot Burst) |
| **Home polje sezone** | ukupno uzgojeno ★3 svakog tipa te sezone | samo raste (Arena T3, Loot Burst) — **od danas** |

Mjesta na polju (zadani raspored; sezona sa Season Kitom može imati svoja): 6 prednjih traže po 5 komada svog tipa, 6 srednjih po 1, zadnje veliko 10. Sa jednim ★3 svakog od 6 tipova izraste 6 mjesta.

## Tvoja pitanja

### Vibracija — kako dodati i ima li smisla?

**Već je u igri** (od zvuka cijele igre, 2026-10-14) i poštuje prekidač u Settingsu. Na laptopu i u emulatoru se ne osjeti — samo na telefonu.

Vibrira na velike trenutke:
- udarac u runu (60 ms);
- T3 spajanje, otključavanje sezone, cilj runa (40 ms);
- ×2 plijen, poklon (30 ms);
- kupovina za coine, nadogradnja (25 ms).

**Ima smisla, ali samo ovako rijetko:**
- kratka haptika na nagradu je standard u casual igrama i daje „težinu";
- na svaki coin ili tap bi brzo iritirala i trošila bateriju.

Moja preporuka: ostaviti kako jeste. Ako na telefonu osjetiš da je preslabo ili prejako, to je jedan broj po trenutku.

### Reduce motion — radi li išta i treba li nam?

**Radi.** Kad je uključen:
- Pip ne poskakuje i ne pravi velike pokrete — osjećaje pokazuje licem;
- muncher igra mirnije verzije klipova;
- staje ambijent sezone (latice, svici, iskre) i njihanje cvijeća;
- grm u runu i traka napretka nemaju „pop";
- Settings ulazi samo prelazom alfe, bez klizanja;
- brojač na vratima Arene i traka u Campu ne animiraju korake.

**Da, vrijedi ga zadržati:**
- to je opcija pristupačnosti — nekima pokret na ekranu izaziva mučninu;
- iOS ima istu sistemsku opciju, a Apple je cijeni pri pregledu;
- kod već postoji i ništa ne košta.

Za malu igru nije obavezan, ali brisanje bi bio korak unazad.

### Restore purchases — ima li smisla?

**Da, i mora ostati:**
- Remove Ads, 4 plaćene sezone i Sir Pip su *trajne* kupovine (non-consumable);
- Apple **zahtijeva** dugme za vraćanje takvih kupovina (App Review 3.1.1) — bez njega iOS build bude odbijen;
- na Androidu Google Play vraća kupovine i sam, ali dugme je sigurnosna mreža (novi telefon, reinstalacija).

**Ne preporučujem da trajne stvari postanu „kupi ponovo"** kao Loot Burst:
- igrač koji promijeni telefon bi izgubio Remove Ads i sezone koje je platio — to znači refundacije i loše recenzije;
- Apple ne dozvoljava da se trajno otključavanje prodaje kao potrošna stvar.

Loot Burst je potrošan (resurs) i tako je ispravno.

### Politika privatnosti — kopirati od slične igre?

**Ne kopirati**, iz dva razloga:
1. tekst je tuđe autorsko djelo;
2. opisivao bi njihovu igru (nalozi, serveri, analitika), a ne našu. Google i Apple porede politiku s *Data safety* / *App Privacy* formularom.

**Napisao sam novu**, po onome što naša igra stvarno radi: `privacy/index.html`, 13 sekcija umjesto 5. Pokriva:
- AdMob i pristanak (EEA, UK, Švicarska) i opt-out u SAD-u;
- kupovine;
- šta ne skupljamo;
- pravni osnov, rokove čuvanja i prava korisnika;
- djecu, prenos podataka, sigurnost, promjene i kontakt.

Šta još treba prije launcha: [[../../05-technical/privacy-policy-draft|privacy-policy-draft]] § „Mora biti istina u igri":
- tvoje ime ili studio i zemlja;
- UMP pristanak kad se spoji AdMob;
- Data safety formular;
- uzrast publike 13+.

**Pazi:** push na `master` koji dira `privacy/` objavljuje stranicu (GitHub Pages workflow).

## Provjereno

- **Novi test `fixes_1016_smoke`:**
  - Arena slojevi do z 60, a Settings z 200;
  - zupčanik zaključan tokom runde i otključan kad runda završi;
  - gnijezdo u centru;
  - muncher prelazi na bližu sjemenku i ne treperi na skoro jednako udaljenim;
  - rezervisano cvijeće zadnje;
  - polje raste iz uzgojenog ★3 dok je stash prazan;
  - prodaja ne smanjuje uzgojeno;
  - migracija starog save-a;
  - nema čipa „grown";
  - vreća 38 + plijen = sve u vreći;
  - Shop štand z 20 iznad sadržaja svih tabova (Looks 16, Boosters 15, Support 15);
  - nadogradnje: Frost sa 20 / 20 Crystal Peony koje čeka Lantern i 500 coina — sva tri dugmeta aktivna, napomena „Uses flowers saved for Lantern Meadow", Twin troši 2 cvijeta.
- **Novi test `loot_boost_twin_smoke`** (od kupovine do kraja runa):
  - svih 5 nivoa: ukupno sjeme = round(ukupno × m), nijedan tip ne gubi, coini round(raw × m);
  - kupovina na polju sezone diže nivo aktivne sezone, druga sezona ima svoje;
  - pravi run s pickupima: plijen pojačan tačno jednom; Twin na nivou 0 nikad, na nivou 4 — 112–113 od 300 sjemenki u dva prolaza (šansa je jedan `randf() < 0,32` po sjemenki; očekivano 96, granica testa 66–126); nagradni grm nije Twin;
  - revive: boost se primijeni jednom;
  - loot ekran: zlatni pečat i chipovi s boostom.
- **GUT `test_game_state_loot_boost`** (11 testova): vrijednosti po nivou, zaokruživanje, pad (Kept half poslije boosta), sirovi carry za revive, Twin šansa.
- **`camp_season_link_smoke` proširen:** plaćena sezona s cijenom, kupovina kroz stub IAP, skok na Home, kartica nestaje kad je sve kupljeno.
- **Ažurirani testovi:**
  - `home_field_overlay_smoke`, `season_kit_all_smoke` (nema čipa);
  - GUT `test_game_state_seed_bag` (vreća bez limita).
- **Cijela suita:** 73 / 73 smoke testa exit 0, save nijednom nije promijenjen (kumulativno); **GUT 42 / 42**.
- **Snimci ekrana** (prozor, opengl3): gnijezdo u sredini i prostor oko njega, zupčanik prigušen tokom runde, Settings preko Arene, Camp kartica Moonlit Warren s cijenom €2.99, Shop Boosters i Looks skrolovani — ništa ne izlazi preko štanda.

## Šta da probaš

1. **Arena:**
   - prospi sjeme — zupčanik je prigušen i ne otvara se;
   - kad runda završi, otvori Settings — ništa iz Arene ne viri.
2. **Arena:** muncher spava u sredini. Kad ga probudiš, odvuci njegovu metu daleko — odmah se okreće na bližu.
3. **Camp:** cvijeće s alertom je zadnje.
4. **Camp:** otključaj sve free sezone (Settings → Dev). Kartica pokazuje prvu plaćenu sezonu i cijenu; tap na cijenu je kupuje (stub).
5. **Home:** otvori polje, napravi T3 u Areni, vrati se — novi cvijet izraste. Prodaj ga u Campu — ostaje na polju.
6. **Run:** igraj s punom vrećom — sva sjemena iz plijena su u Campu.
7. **Shop · Boosters:** skrolaj — ništa ne ide preko štanda.
8. **Home polje Frosta → nadogradnje:** sa cvijećem koje čeka Lantern dugmad su aktivna, a ispod imena sezone piše „Uses flowers saved for Lantern Meadow".
9. **Run s Loot Boostom / Twin Seedsom** (kupljeno na polju sezone koju igraš): na kraju runa desno iznad plijena zlatni pečat „Loot Boost ×1.25 · N twins"; brojevi u plijenu su veći od brojača u runu.

## Povezano

- [[../_index|← Iskustvo]]
- [[run-pickups-cd-brief|run-pickups-cd-brief]]
- [[../../05-technical/privacy-policy-draft|privacy-policy-draft]]
- [[../../05-technical/godot/greske-katalog|greske-katalog]] (#40, #41, #42)
- [[../../06-production/CHECKPOINT|CHECKPOINT]]
