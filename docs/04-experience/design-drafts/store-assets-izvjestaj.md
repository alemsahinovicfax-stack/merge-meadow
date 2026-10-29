---
type: dizajn
status: aktivan
milestone: M8
tags: [dizajn, store, marketing, play-store, claude-design, ikona, izvjestaj, prenos]
povezano:
  - store-assets-cd-brief
  - store-listing-en
  - store-screenshots
  - play-console-sutra
  - launch-prep-plan
  - CHECKPOINT
ai_sažetak: "Play Store paket od Claude Designa (3 kruga) prihvaćen 2026-10-29 i prenesen: marketing/store/ (ikona 512, feature graphic svijetla + tamna, 8 screenshotova, promo), nova ikona hero Pip s kristalnim božurom u igri i AAB-u, store-listing-en prepisan."
---

# Play Store paket — izvještaj

> Brief: [[store-assets-cd-brief]] · Tekst za Play: [[../../06-production/store-listing-en|store-listing-en]] · Upload: [[../../06-production/play-console-sutra|play-console-sutra]]

## Ukratko

Grafika za Google Play je gotova. Claude Design je radio u tri kruga, a ja sam pregledao svaki krug. Sve je u `marketing/store/`, nova ikona je u igri, a napravljen je i novi AAB s njom.

Glavna poruka (hook) je **Run. Merge. Bloom.** — tri glagola koja opisuju cijelu igru: trčiš, spajaš, cvjeta.

## Šta je gdje

| Šta | Fajl | Ide u Play Console |
|---|---|---|
| Ikona 512×512 | `marketing/store/app-icon-512.png` | App icon |
| Feature graphic 1024×500 | `marketing/store/feature-graphic.png` | Feature graphic |
| Tamna verzija bannera | `marketing/store/feature-graphic-dark.png` | rezerva |
| 8 screenshotova | `marketing/store/screenshots/01_…08_*.png` | Phone screenshots, po redu |
| Promo 1200×630 | `marketing/store/promo-1200x630.png` | ne — za testere, GitHub stranicu |
| Pregled svega | `marketing/store/design/store_preview.html` | otvori u browseru |
| Hero Pip (cijeli zec s cvijetom) | `marketing/store/design/source/hero_pip/` | ne — za objave, stranicu |

Sve je provjereno: tačne dimenzije, a banneri i screenshoti nemaju prozirnost, što Play traži.

## Screenshoti po redu

| # | Naslov | Šta se vidi |
|---|---|---|
| 1 | Run. Merge. Bloom. | run u Country Bloomu, uvećano sjeme, hero Pip uz telefon |
| 2 | Merge two of a kind | Arena, prevlačenje dvije iste sjemenke |
| 3 | Watch your meadow grow | Home polje puno cvijeća |
| 4 | 7 meadows to explore | tri sezone (Starfall, Moonlit, Frost) |
| 5 | 140 levels to bloom | Level Path sa sanducima |
| 6 | Beat your best | Endless, „New best!" (novi čisti kadar s05b) |
| 7 | Loot after every run | Arena combo + kartica plijena |
| 8 | No energy. No timers. | Shop s temama i izgledima za coine |

## Tri kruga — šta se mijenjalo

| Krug | Problem | Rješenje |
|---|---|---|
| 1 → 2 | Zec na banneru odsječen (uši, tijelo), blijeda pozadina, obična ikona; duplirani HUD na screenshotu 06; loot kartica preko Arene (zbunjujuće) | Cijeli „hero Pip" s cvijetom, čiste pozadine, nova topla ikona; screenshot 07 preko runa |
| 2 → 3 | Hero Pip izgledao kao da ima staklenu kacigu, šiljci na vratu, cvijet nisko i sa strane, ukočena poza; zec na screenshotu 01 presječen ivicom; na 06 krug efekta preko HUD-a | Ponovo nacrtan zec: meko senčenje, glatki vrat, šape drže stabljiku na grudima, cvijet uz obraz, mali skok; na 01 cijeli zec na brdu; 06 iz novog čistog kadra |

Sitnice koje su ostale, a ne smetaju objavi: stabljika malo viri ispod šapa, pa cvijet podsjeća na lizalicu; zec na screenshotu 01 je malen.

## Ikona u igri

- Nova ikona: Pip (glava i ramena) grli kristalni božur, na peach → zlatnoj pozadini. Čita se i na 48 px, i na bijeloj i na tamnoj pozadini.
- `game/scripts/dev/make_app_icons.gd` sada uzima CD-ove master fajlove iz `marketing/store/design/source/icon/`:
  - ikona 512 i adaptivni slojevi (prednji, pozadina, mono za Android teme) idu 1:1;
  - stara launcher ikona 192 je smanjena 512 sa zaobljenim uglovima;
  - splash značka je adaptivna pozadina + Pip u krugu s tamnim obrubom.
- Import urađen, kratki headless start igre prošao bez grešaka u skriptama.
- **Novi AAB:** `game/export/android/merge_meadow.aab` (68,9 MB), potpisan. Iz njega sam izvukao launcher ikonu i provjerio da je nova.
- Verzija je i dalje `version/code=1` — dok ništa nije uploadano na Play, ne treba je dizati.

## Tekst za store

`docs/06-production/store-listing-en.md` je prepisan:

- **Short description (74 znaka):** „Run for seeds, merge them into crystal flowers, and grow your cozy meadow."
- **Full description:** Run / Merge / Bloom, 7 livada, 140 levela, Endless, Bloom Album, bez energije i tajmera, bez kupovina, reklame opcione.
- Uklonjeno: „100 levels", Easy / Normal / Hard, „pets", „camp upgrades" kao glavna petlja.

## Šta je obrisano

Starih 8 screenshotova s emulatora (`01-run-lane.png` … `08-collection.png`, jul 2026) — pokazivali su Remove Ads, Starter Pack i Easy/Normal/Hard, kojih više nema. Ostaju u git historiji.

## Otvoreno (tvoj dio)

- [ ] **Developer name** — upiši ga u Play Console kad otvoriš nalog (u screenshotima ga nema, pa se ništa ne mora mijenjati).
- [ ] Upload: ikona, feature graphic, 8 screenshotova, short i full description iz `store-listing-en.md`.
- [ ] Odluči koji banner ide: svijetli je preporuka (tamni je rezerva).
- Ako se kasnije doda Ember Fen kao osma livada: promijeni naslov u `Store Assets v3.dc.html` („8 meadows") i exportuj artboard ponovo.
