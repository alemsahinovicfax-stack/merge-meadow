# Handoff: Sjeme i cvijet u okviru (plant_frame)

Prati `docs/04-experience/design-drafts/plant-frame-cd-brief.md`. Jedan dizajn na četiri mjesta: Arena, Journal, Camp i Run. Sve mjere su u px baze 1080 × 1920, prenos je 1:1.

## Šta otvoriti

- `design/PlantFrame.dc.html` prikazuje pet stanja iz §7.1. Prop `scene` bira stanje: `all`, `arena_idle`, `arena_hint`, `journal`, `camp` ili `run`.
- `design/PlantFrame Specs.dc.html` sadrži anatomiju u omjeru 1:1, mjeru odreza za svih devet sprite-ova i tabelu „danas → novo“.
- `godot/plant_frame.gd` daje nove vrijednosti postojećih konstanti. `godot/plant_frame_export.json` sadrži tokene, komponente, scene i odluke. `godot/README.md` opisuje redoslijed prenosa.
- `design/flowers/` sadrži postojeće `clover/daisy/tulip_t1–t3.svg`, samo s `viewBox` odrezanim na vidljivi crtež. Crtež je netaknut i služi samo mockupu, jer igra reže u runtimeu.

## Pravilo u jednoj rečenici

Biljka se reže na vidljivi crtež i puni kutiju po visini. Okvir nosi tier i spajanje, a gdje spajanja nema (u runu), okvira nema.

## Mjere, ukratko

- **Arena:**
  - čip ostaje 134 px;
  - vidljivi cream se stanjuje sa 14 na 8 (T1) i sa 18 na 11 (T2);
  - biljka ima kutiju 80 / 88, crtež odrezan;
  - hint je 12 px (magnet 14) i deblji je od svakog cream ruba;
  - well ostaje.
- **Journal:**
  - natpisi T1/T2/T3 idu van;
  - slot raste sa 112 na 136, a biljka je 110;
  - bez zelenog wella;
  - red ostaje 1032 × 200.
- **Camp:**
  - kartica ostaje 489 × 176, okvir 128;
  - bez wella;
  - biljka je 104 (sjeme) / 108 (cvijet);
  - Trade bar: 84 / 88 u okviru 104;
  - ikona sezone: 46 u okviru 56.
- **Run:**
  - bez kruga i bez wella;
  - sadnica je vizual od 120 px, a kolizija ostaje r 26;
  - pipovi su 22 px s cream rubom, u kruni iznad biljke;
  - sjena je na +70.

## § Odlučeno

1. **Odrez po visini:** svih devet sprite-ova je više nego šire, pa punjenje po dužoj strani daje T1 istu vidljivu visinu kao T2 — T1 se konačno vidi, a tier i dalje nosi okvir.
2. **Arena cream 8 / 11:** najtanje što još čita kao „tijelo sjemenke“ na livadi i ostavlja mjesta za T2 unutrašnji prsten.
3. **T2 prsten 2 px na insetu 5:** razlika T1/T2 ostaje i bez boje, a stane u cream od 11 px.
4. **Hint 12 px, 10 px van čipa i 2 px preko ruba:** deblji je od cream ruba (12 > 11), a ne ulazi među susjede na razmaku centara 142,8.
5. **Hint iznad rima, alpha 1,0:** kad se crta ispod, rim pojede unutrašnji dio prstena. To je bio pola današnjeg problema.
6. **Biljka u Areni 80 / 88:** „samo malo veća“ po kutiji; stvarni vidljivi skok dolazi od odreza, a margina do wella ostaje 19 / 12 px.
7. **Arena well ostaje:** nosi kontrast svijetlog cvijeća (bijela tratinčica) na tamnoj livadi, kako je Arena handoff izmjerio.
8. **Journal slot 136, gap 14:** natpis oslobađa 42 px visine, a info kolona ostaje oko 514 px, pa caption na 38 px stane u dva reda.
9. **Journal T2 bez novog znaka:** tier se čita iz pozicije (1-2-3 slijeva), crteža (sadnica ili cvijet) i zlatnog kvadrata kristala. Novi prsten bi tražio novu konstantu.
10. **Podloga Journala i Campa je cream, ne tint reda:** cream krug je već jezik „sjeme/bloom“ u oba ekrana; na pastel kartici se čita kao žeton, ne kao rupa.
11. **Camp okvir ostaje 128:** biljka raste unutra, pa se ime, pipovi i pillovi u kartici ne pomjeraju.
12. **Run pipovi u kruni (radius 78, isti uglovi):** funkcija `seed_pip_positions` ostaje ista, mijenja se samo konstanta; pip od 22 px s cream rubom čita se na tamnoj stazi i bez kruga.
13. **Run sjena na +70:** bez kruga je baza stabljike na +60. Sjena ispod nje drži pravilo „pickup pluta, prepreka stoji“ iz Run handoffa.
14. **Nijedna nova boja:** pip rub je `CHIP_BG` cream, a hint je postojeći `#F2D940` / `#FFD56B`.

## § Šta se briše

- **Journal:** `TierLabel` (T1/T2/T3), `ArtWell`, `WELL_INSET`, `TIER_LABEL_*`.
- **Camp:** well u `camp_art_frame.gd`, `CHIP_ART_WELL_INSET`, `TRADE_ART_WELL_INSET`.
- **Run:** krem krug 120, rub 4, well 84 i `SEED_WELL_SIZE`.

## § Ideje van zadatka

- **Arena:** kratki haptic tik kad se partner-prsten upali, uz isti ritam kao puls.
- **Run:** kad se sadnica pokupi, kratko je prikaži u Arena okviru dok leti u brojač. Tako igrač vidi da je to ista sjemenka koju kasnije spaja.
- **Journal:** tap na slot otvara crtež u punoj veličini (lightbox), bez nove navigacije.
- **Home polje i korpa:** i dalje koriste `FIT_FRAC 0.36`. Isti odrez bi i tamo pomogao T1, ali to nije ovaj zadatak.
