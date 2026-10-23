---
type: produkcija
status: draft
milestone: M8
tags: [produkcija, admob, app-ads]
povezano:
  - play-console-sutra
  - admob-setup
ai_sažetak: "Šablon app-ads.txt za AdMob; čeka publisher ID; mora na root hostname-a iz Play 'Developer website' (GitHub user site, ne /merge-meadow/)."
---

# app-ads.txt (šablon — još NE objavljivati)

> Roditelj: [[06-production/_index|06-production]] · Koraci: [[play-console-sutra|play-console-sutra]] § 8

`app-ads.txt` ovdje ima `pub-XXXXXXXXXXXXXXXX` umjesto pravog publisher ID-a. Zato **nije** u `privacy/`: workflow *Privacy policy Pages* objavljuje cijeli `privacy/` folder, a i da ga objavi, bio bi na pogrešnoj adresi.

**Gdje mora stajati:** AdMob čita samo hostname iz polja *Developer website* u Play Consoleu i traži `https://<hostname>/app-ads.txt`.

| Developer website u Playu | Gdje crawler traži |
|---------------------------|--------------------|
| `https://alemsahinovicfax-stack.github.io/merge-meadow/` | `https://alemsahinovicfax-stack.github.io/app-ads.txt` |

Znači treba **GitHub user site**: repo tačno imena `alemsahinovicfax-stack.github.io`, s `app-ads.txt` u korijenu (Pages uključen na `main`). Alternativa: vlastita domena.

**Kad dobiješ publisher ID** (AdMob → Settings → Account information, `pub-…`): agent zamijeni `XXXXXXXXXXXXXXXX`, napravi/ažurira user-site repo (uz tvoju dozvolu) i provjeri AdMob → Apps → app-ads.txt status (do 24 h).

Zadnje polje `f08c47fec0942fa0` je Googleov certifikacijski ID — uvijek isti.
