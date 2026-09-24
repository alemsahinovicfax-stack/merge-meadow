---
type: dizajn
status: aktivan
tags: [dizajn, ui, home, sezone, claude-design, ab-test]
ai_sazetak: "A/B varijanta B (BEZ Notiona) — isti brief kao Notion stranica za redizajn Home biranja sezone u Claude Design."
---

# A/B test: Home biranje sezone — Claude Design (BEZ Notiona)

> **Varijanta B.** Isti sadržaj kao Notion stranica „A/B test: Home biranje sezone — Claude Design (SA Notionom)“.
> U ovoj rundi Claude Designu **ne** šalji Notion link — samo ovaj fajl (ili copy-paste).

## Kako koristiti

1. Otvori Claude Design.
2. Zalijepi **Prompt za Claude Design** na dnu.
3. Priloži **ovaj** `.md` fajl (ili zalijepi cijeli sadržaj).
4. Ne šalji Notion stranicu u ovoj rundi.
5. Traži isti deliverable kao u sekciji Isporuka.

Cilj testa: da li isti brief kao običan fajl daje bolji/gori CD rezultat od Notion verzije.

---

## Šta redizajniramo

**Home — scena biranja sezone** (SeasonStage) u Merge Meadow.

Ne diramo: SeasonField (livada), Shop, Journal, Camp, Arena, header/footer huba, ekonomiju (500 coin + 20 ★3), redoslijed sezona, IAP cijene.

Zašto opet: prvi CD prolaz (Season Trail) je u igri, ali nisi zadovoljan — kartice bez identiteta, sitni tekst, skrivene geste, nejasan Play, slab premium pregled.

---

## Fiksna pravila (ne mijenjati)

- 8 sezona: 4 free linearno (Country Bloom → Frost Orchard → Lantern Meadow → Amber Canopy); 4 premium IAP (Moonlit Warren, Coral Tide Garden, Starfall Glade, Ember Fen coming soon).
- Free unlock: **500 coins + 20 ★3** prethodne sezone; samo **next lock** se smije fokusirati/otključati.
- Tačno jedna **aktivna** sezona; fokus ≠ aktivna na next locku.
- Unlock na licu mjesta (zlatno dugme kad su oba uslova OK).
- Premium se može pregledati prije kupovine (6 cvjetova); cijena = store string.
- Tap na otključanu sezonu → ulaz u **polje sezone** (polje se ne dizajnira ovdje).
- Camp može otključati i poslati igrača na Home s već otključanom sezonom u fokusu (bez drugog unlock trenutka).
- Daily gift ostaje na ovoj sceni.
- Fair F2P: free put uvijek vidljiv; bez agresivnog Buy / lažne hitnosti.

---

## Problemi koje CD mora riješiti

1. Kartice = obojeni pravougaonici — treba **identitet** sezone (mood + tagline + 2–3 cvijeta iz rostera; slot za buduću ilustraciju).
2. Tekst/brojevi premali — min **38 px** tekst, **44 px** brojevi; touch **≥ 120 px**.
3. Skrivene geste / dvije trake — geste moraju biti očite; dvije trake **nisu obavezne**.
4. Play ne pokreće run odmah — predloži jasan tok (npr. Play = run, kartica = polje).
5. Jasno **„u ovoj igraš“** vs **„samo gledam“**.
6. Browser ne smije izgledati kao debug meni (redizajn ili spoji sa scenom).
7. Hub horizontalni swipe mora ostati moguć — označi zonu ili drugu gestu za sezone.
8. Vizuelni jezik kao hub chrome / Arena / Camp (tamna traka `#1A241E`, cream rim + tamni well).

---

## Artboard i chrome

- Artboard **1080 × 1920** portrait.
- Header **143 px**, footer **180 px** — prikaži, ne mijenjaj.
- Home content **1080 × 1597** između njih.
- StyleBoxFlat friendly: ravna boja, radius, border, jedna sjena. Bez blur/glow shadera, teških gradijenata, 3D flip kartica.

### Paleta (hex)

mint `#A8E6CF` · lavanda `#D4A5FF` · peach `#FFB88C` (CTA/Play) · coin gold `#FFD56B` · UI gold `#E8C44A` (Unlock) · warm white `#FFF8F0` · price bg `#FFE8B8` · soft sky `#B8E0F5` · UI tekst `#4A4A4A` · outline `#2D3436` · chrome `#1A241E` · aktivna rub `#FFF6D6`

Mood sezona: Country Bloom `#A8E6CF` · Frost Orchard `#C5D5E8` · Lantern Meadow `#C9B8E0` · Amber Canopy `#E8C48A` · Moonlit Warren `#3D3A6B` · Coral Tide `#E8A090` · Starfall Glade `#6B5B95` · Ember Fen `#C45C26`

---

## Isporuka (P1)

1. Glavni ekran mid-game (2 free otključane, next lock djelimično).
2. Novi igrač + tutorial hint.
3. Unlock spremno + storyboard 2–3 kadra trenutka.
4. Premium: nekupljena / kupovina / kupljena aktivna / coming soon.
5. Sve 4 free otključane.
6. Spec sheet kartice (sva stanja × mood boje).
7. Browser ili zamjena + obrazloženje.
8. Skica gesti + hub-swipe zona.

Max **2** vizuelna smjera, jedan pored drugog, s preporukom.

Imena slojeva: `HomePage`, `SeasonStage`, `SeasonCard`, `ActiveBadge`, `SeasonRoster`, `UnlockPoster`, `CoinProgress`, `FlowerProgress`, `UnlockButton`, `PremiumCard`, `PriceTag`, `SeasonBrowser`, `ProgressIndicator`, `PlayButton`, `DailyGiftCard`, `HubSwipeZone`.

---

## Prompt za Claude Design

Kopiraj sve ispod ove linije u Claude Design:

```
Radim REDIZAJN (drugi prolaz) ekrana HOME — biranje sezone u Merge Meadow.
Casual F2P merge/runner, portrait, flat pastel cartoon, cozy meadow.
Vizuelni jezik mora pratiti već redizajnirani hub chrome / Arena / Camp
(tamna traka #1A241E; cream rim + tamni well).

Jedini brief za ovu rundu je Markdown fajl koji ti šaljem (A/B varijanta B).
Pročitaj ga cijelog prije rada. Dizajniraš SAMO scenu biranja sezone —
ne SeasonField (livada, Pip, korpa, Endless).

Cilj: na prvi pogled jasno u kojoj sezoni igra, šta ima, koliko fali do
sljedeće free, šta nudi premium; lak ulaz u run; svaka sezona ima identitet;
1:1 prenos u Godot 4 (StyleBoxFlat).

Fiksno: 4 free linearno (500 coin + 20 ★3); samo next lock otključiv;
4 premium IAP pregledivi prije kupovine; jedna aktivna sezona; fair F2P;
tekst ≥38px, brojevi ≥44px, touch ≥120px; EN copy; header 143 / footer 180;
content 1080×1597.

Riješi: identitet kartica, očite geste, jasan Play vs polje, Active vs Fokus,
Browser koji nije debug, hub swipe zona, bez mrtvog prostora.

Isporuka P1 iz brief fajla. Max 2 smjera + preporuka. Ne mijenjaj ekonomiju.
```
