---
status: draft
tags: [vizija, publika]
---

# Ciljana publika

## Sažetak

Primarni igrač je **široki casual segment 13–25** (downloadi i ad revenue), s fokusom monetizacije na **18–35** koji ostaju i plaćaju IAP. Igra **8–15 minuta dnevno** u 4–6 kratkih runova plus vrijeme u kampu — u pokretu i kod kuće, jednom rukom na telefonu.

## Primarna publika

| Aspekt | Opis |
|--------|------|
| Dob | **13–25** primarno (store appeal, volumen); **18–35** IAP sweet spot |
| Iskustvo s igrama | Casual — poznaju merge/run igre, ne traže tutorial od 10 min |
| Navike | Put, red, pauza **i** kuća/krevet/sofa — oba konteksta jednako važna |
| Uređaji | Android + iOS, mid-range telefoni (ne zahtijevamo flagship) |
| Session length | **~90 s po runu**; **8–15 min/dan** ukupno (4–6 runova + 2–3 min kamp) |

## Sekundarna publika

- **25–45 idle/merge fanovi** — prepoznaju loop, češći IAP, manji % baze.
- **Mlađi od 13** — mogu igrati (cute tema), ali store listing i monetizacija ciljaju teen+.

## Motivacije

Zašto bi ova publika odabrala **Merge Meadow**?

- **Brzi satisfying trenutak** — merge pop i rast brojki bez učenja složenih kontrola.
- **Napredak koji traje** — kamp se gradi između sesija; sutra si jači (power fantasy).
- **Cozy bez obveze** — pastelni ljubimci, nema kazne; idealno za “ubij vrijeme” i opuštanje.
- **Besplatno za probati** — F2P, core loop bez paywalla.

## Frustracije koje izbjegavamo

| Frustracija | Zašto (novac) |
|-------------|----------------|
| Predugački tutorial | Churn prije prvog oglasa |
| Agresivni paywall / pay-to-win | Loši reviewi, uninstall |
| Interstitial usred runa | Isto + kratak session = još gore UX |
| FOMO timer koji blokira run | Osjećaj kazne → manje D7 |
| Previše push notifikacija | Uninstall |

## Monetizacijski segmenti (očekivanja)

| Segment | ~% baze | Ponašanje | Što im nudimo |
|---------|---------|-----------|---------------|
| Free + ads | ~90% | Gleda rewarded, rijetko plaća | Revive, dupli loot, daily, endless |
| Casual payer | ~5% | 1–2 kupnje | Remove ads €3.99, starter pack €1.99 |
| Whales | ~1% | Ignorirati u v1 | Nema duboke ekonomije za njih u launchu |

**Napomena:** LTV se gradi kroz **retention × ARPDAU** (oglasi + mali IAP), ne kroz whale hunting.

## Retention alati (v1)

- **Daily reward** u kampu — merge bonus ili free chest (povećava D7).
- **Push notifikacije** — max 1/dan, opcionalno u v1.1 (“Your camp is ready!”).
- **Bez** energy sustava koji blokira core run u v1 (neograničeni runovi; cooldown samo na bonus nagradama ako uopće).

## Odluke (zaključano)

| Pitanje | Odgovor |
|---------|---------|
| Globalna vs lokalna publika | **Globalna**, EN store listing |
| Tablet u v1 | Phone-first; tablet layout **OUT** za v1 (scope) |
| Willingness to pay | Niska do umjerena — casual payer €2–4 jednokratno |

## Otvorena pitanja

- [ ] Treba li energy/stamina u v1.1 ili ostati neograničeni runovi?
- [ ] A/B test: daily push on/off utjecaj na D7?

## Povezano

- [[koncept|koncept]]
- [[../02-design/core-loop|core-loop]]
- [[../04-experience/pristupacnost|pristupacnost]]
