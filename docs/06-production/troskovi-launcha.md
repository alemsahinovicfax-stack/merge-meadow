---
type: produkcija
status: aktivan
milestone: M8
tags: [produkcija, launch, troškovi, monetizacija, platforme]
povezano:
  - CHECKPOINT
  - milestone-i
  - scope-i-granice
  - play-internal-test
  - ../05-technical/platforme
ai_sažetak: "Sve naknade i troškovi objave — Android kad je igra spremna; iOS kad se prikupi ~99 USD; tablica + faze."
---

# Troškovi launcha i plan objave

> **Strategija (2026-07-11):** Prvo **maksimalni polish + sve v1 ideje**. Tek onda **25 USD** i **Android-only** objava. **iOS** i **99 USD/god** Apple Developer — **tek kad prihod s Androida (ili štednje) pokrije ~99 USD**. Do tada: updates, polish, sadržaj.

## Tablica svih troškova

### A — Store developer računi (kad dođe red)

| # | Stavka | Iznos | Kada platiti | Obavezno? | Napomena |
|---|--------|-------|--------------|-----------|----------|
| A1 | **Google Play Console** — developer registracija | **25 USD** | **Faza 2** — kad je igra spremna za objavu | Da (za Android store) | Jednokratno; **nema refunda** ako identitet ne prođe |
| A2 | **Apple Developer Program** | **99 USD/god** | **Faza 4** — kad imaš ~99 USD | Da (za App Store / TestFlight) | Godišnja obnova dok držiš app na storeu |
| | **Subtotal store računi (godina 1, samo Android)** | **25 USD** | | | |
| | **Subtotal store računi (godina 1, Android + iOS)** | **124 USD** | | | Prva godina; sljedeće **+99 USD/god** samo Apple |

### B — Obavezno oko builda i storea (0 USD naknade platformi)

| # | Stavka | Iznos | Kada | Obavezno? | Napomena |
|---|--------|-------|------|-----------|----------|
| B1 | Godot 4 | **0** | Sada | Da (alat) | Open source |
| B2 | Android Studio + emulator | **0** | Sada | Da (Android test) | SDK besplatan |
| B3 | Privacy policy hosting | **0** | ✅ | Da (Play/App Store URL) | GitHub Pages — [live URL](https://alemsahinovicfax-stack.github.io/merge-meadow/) |
| B4 | GitHub (public repo) | **0** | ✅ | Ne (Pages zahtijeva public ili paid) | Solo dev workflow |
| B5 | Store listing copy + screenshotovi | **0** | ✅ pripremljeno | Da (sadržaj) | `store-listing-en.md`, 8× PNG |
| B6 | Google Play / App Store forme | **0** | Faza 2 / 4 | Da (vrijeme) | Content rating, data safety, app content — bez dodatne naknade |
| B7 | AdMob integracija | **0** | Prije launcha | Da (monetizacija v1) | Nema upfront fee |
| B8 | Google Play Billing / IAP setup | **0** | Prije launcha | Da (shop v1) | Nema upfront fee |

### C — iOS specifično (odgođeno — Faza 4)

| # | Stavka | Iznos | Kada | Obavezno za iOS? | Napomena |
|---|--------|-------|------|------------------|----------|
| C1 | Apple Developer (A2) | **99 USD/god** | Kad prikupiš kapital | Da | Trigger: ~**99 USD** prihoda ili štednja |
| C2 | **Mac** za lokalni iOS export | **0–?** | Faza 4 | Ne ako imaš CI | Posuditi Mac, cloud Mac, ili **GitHub Actions** (GHA besplatan tier — ograničen) |
| C3 | iOS prilagođavanje + TestFlight test | **0** (rad) | Faza 4 | Da (kvaliteta) | Safe area, touch, performanse na iPhoneu — **pipeline već u repo** |
| C4 | D-U-N-S broj | **0** | Samo org. račun | Ne (osoba) | Solo **Individual** račun — ne treba |

### D — Marketing i vizual (opcionalno, ne blocker)

| # | Stavka | Iznos | Kada | Obavezno? | Napomena |
|---|--------|-------|------|-----------|----------|
| D1 | CPI test kampanja | **50–100 €** | **Nakon** Android launcha | Ne | CHECKPOINT D — validacija ASO/ikonice |
| D2 | Profesionalni app icon / feature graphic | **0–50 €** | Prije ili poslije launcha | Ne | Može placeholder dok ne zaradi |
| D3 | Vlastita domena (npr. mergemeadow.com) | **~10–15 €/god** | Opcionalno | Ne | GitHub Pages URL je dovoljan za policy |

### E — Prihod — nije trošak objave, ali “cijena” prodaje

| # | Stavka | Iznos | Napomena |
|---|--------|-------|----------|
| E1 | Google Play provizija na IAP | **~15%** (Small Business / prvi $1M) ili 30% | Odbija se od prodaje |
| E2 | Apple provizija na IAP | **~15%** (Small Business) ili 30% | Isto |
| E3 | AdMob | Dio prihoda reklama ide Googleu | Nema upfront |

### F — Lokalno / porez (varijabilno, nije Google/Apple cjenik)

| # | Stavka | Iznos | Napomena |
|---|--------|-------|----------|
| F1 | Porez na prihod od igre | Ovisi o državi | Provjeri lokalno (BiH/HR solo dev) |
| F2 | Obrt / d.o.o. | Varijabilno | Nije obavezno za sam upload; često za legalno fakturiranje |

---

## Ukupni minimumi po scenariju

| Scenarij | Unaprijed (prije prihoda) | Godišnje nakon objave |
|----------|---------------------------|------------------------|
| **Samo razvoj (sada)** | **0 USD** | — |
| **Android launch (Faza 2)** | **25 USD** jednom | 0 USD (Play nema godišnju naknadu) |
| **Android + marketing test** | **25 USD + 50–100 €** | — |
| **Android + iOS (Faza 4, godina 1)** | **25 + 99 = 124 USD** + eventualno Mac | **+99 USD/god** Apple |

---

## Plan faza (ažurirano)

```
┌─────────────────────────────────────────────────────────────────┐
│ FAZA 1 — Pre-launch polish (SADA)                    Trošak: 0 │
│ • Implementirati sve v1 IN ideje do kraja                        │
│ • Max polish, updates, playtest, bugfix                          │
│ • NE plaćati Play Console                                      │
│ • NE objavljivati na storeu                                    │
└───────────────────────────────┬─────────────────────────────────┘
                                │ igra = spremna za vanjski svijet
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│ FAZA 2 — Android launch                              Trošak: 25 USD │
│ • Platiti Google Play developer račun                          │
│ • Internal test → closed/open → production                     │
│ • AdMob + IAP production ID-evi                                │
└───────────────────────────────┬─────────────────────────────────┘
                                │ prihod / štednja
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│ FAZA 3 — Post-Android rast (međuvremeno)             Trošak: 0 store │
│ • Updates, polish, sadržaj, balans                             │
│ • CPI test 50–100 € (opcionalno)                               │
│ • Cilj: prikupiti ~99 USD za Apple                             │
└───────────────────────────────┬─────────────────────────────────┘
                                │ ~99 USD prikupljeno
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│ FAZA 4 — iOS                                         Trošak: 99 USD/god │
│ • Apple Developer Program                                      │
│ • iOS prilagođavanje + build (Mac/GHA)                         │
│ • TestFlight → App Store submit                                │
└─────────────────────────────────────────────────────────────────┘
```

### Trigger uvjeti (kada platiti)

| Faza | Platiti kada | Iznos |
|------|--------------|-------|
| **Faza 2** | v1 scope + ideje implementirane; igra maksimalno ispolirana; spreman release APK/AAB | **25 USD** |
| **Faza 3** | Odmah nakon Android objave — kontinuirano | **0** (rad na igri) |
| **Faza 4** | Stanje / prihod ≥ **~99 USD** (Apple fee) + iOS build testiran | **99 USD** |

---

## Projekcija: koliko do prvih ~100 USD? (pretpostavka)

> **Nije garantija** — solo debut na Play Storeu bez budžeta jako varira. Brojke su usklađene s [[../02-design/monetizacija|monetizacija]] (ARPDAU $0.03–0.15, ~5% casual payer) i planom **Faza 3** (updates + opcionalno CPI test **nakon** launcha).

### Model (pojednostavljeno)

```
Neto prihod / dan ≈ DAU × ARPDAU + IAP_danas

DAU     = aktivni igrači dnevno (organic + eventualni CPI)
ARPDAU  = prosjek po aktivnom igraču (oglasi + mali IAP, neto tebi)
IAP     = rijetki remove ads (€3.99) i starter pack (€1.99), ~85% neto nakon Play provizije
```

**Zašto je sporo na startu:** prva igra, nema brenda, algoritam te ne poznaje; većina downloada u mjesec 1 dolazi **organski** (sporo) osim ako ne uložiš CPI test (50–100 € kupi instalacije, **ne** direktno $100 u novčaniku — treba monetizirati te igrače).

### Tri scenarija (nakon **D0 polish** launcha, Android only)

| Scenarij | Instalacije (mjesec 1) | Prosj. DAU (mj. 1–2) | ARPDAU | IAP / mjesec | **Vrijeme do ~100 USD neto** |
|----------|------------------------|----------------------|--------|--------------|------------------------------|
| **Pesimistični** | 100–300 organic | 8–20 | $0.04–0.06 | 0–2 kupnje (~0–8 $) | **4–9 mjeseci** |
| **Realistični** | 400–1 500 organic + dobri reviewi | 25–60 | $0.06–0.10 | 3–8 kupnji (~15–35 $) | **6–14 tjedana** |
| **Optimistični** | 2 000+ (ASO + CPI test + sretan algoritam) | 80–150 | $0.10–0.15 | 10+ kupnji | **2–4 tjedna** |

**Centar težine (realistično za Merge Meadow nakon punog D0):** otprilike **2–4 mjeseca** do prvih **100 USD neto**, ako redovito radiš **Fazu 3** (updates, daily chest, balans, 1 mala ASO iteracija). Brže (**6–10 tjedana**) ako retention bude iznad prosjeka (D7 daily chest + fair F2P) i dobiješ **500+** kvalitetnih instalacija u mjesec 1.

### Što u tvojoj igri pomaže / usporava

| Pomaže | Usporava |
|--------|----------|
| Hybrid loop (run + kamp) → bolji D7 od čistog runnera | Prvi naslov, nema publike |
| Rewarded na ×2/revive (Fair F2P, više opt-in) | Rewarded ≠ svaki run — manje impresija nego forced ads |
| IAP €1.99–3.99 (1 prodaja ≈ 2–3 dana ads-only prihoda) | ~90% baze nikad ne plaća |
| Launch **nakon** D0 (daily chest, SFX, polish) | Bez UA budžeta na dan 1 — organic je spor |
| CPI test 50–100 € **u Fazi 3** može ubrzati učenje, ne magiju | Crowded genre (merge + runner) |

### Koliko DAU treba? (brza formula)

| Avg ARPDAU | DAU za ~100 USD u **60 dana** | DAU za ~100 USD u **90 dana** |
|------------|-------------------------------|-------------------------------|
| $0.05 | ~33 | ~22 |
| $0.08 | ~21 | ~14 |
| $0.12 | ~14 | ~9 |

*(Samo ads; svaka remove ads kupnja skraćuje rok za ~3–7 dana ovisno o ARPDAU.)*

### Praktičan zaključak za iOS trigger (~99 USD)

1. **Planiraj 2–4 mjeseca** Android-only rada (updates, ne čekanje pasivno).
2. **Ne računaj** da će CPI test od 50–100 € sam „donijeti“ 100 $ — to je **marketing trošak**; prihod dolazi od zadržanih igrača.
3. **Prvi payout** na AdMob/Play često ima **prag ~100 USD** — prvi put kad „stigneš“ na 99 $, možda još čekaš do kraja mjeseca + obrade; računaj **+2–4 tjedna** buffer.
4. **Alternativa:** ako želiš iOS u fiksnom roku (npr. 6 mjeseci), **odvoji 99 USD iz štednje** i iOS tretiraj kao investiciju; prihod s Androida neka bude bonus.

---

## Što je već spremno (ne troši novac)

- [x] Privacy policy URL (GitHub Pages)
- [x] EN store listing + 8 screenshotova
- [x] Android debug APK + export pipeline
- [x] iOS export pipeline (GHA) — **aktivira se u Fazi 4, ne sada**
- [x] IAP / AdMob hookovi u kodu (production ID-evi tek u Fazi 2)

## Sljedeći korak (operativno)

1. **Faza 1** — [[d0-prelaunch-checklist|d0-prelaunch-checklist]] (Blok A→E)
2. **Ne** otvarati Play Console dok Faza 1 nije gotova
3. Kad D0 ✅ → **25 USD** → [[play-internal-test|D5 internal test]]

## Povezano

- [[CHECKPOINT|CHECKPOINT]] — aktivna sekcija D
- [[play-internal-test|play-internal-test]] — runbook (Faza 2)
- [[milestone-i|milestone-i]] — M8 ciljevi
- [[scope-i-granice|scope-i-granice]] — što mora biti gotovo prije launcha
- [[../05-technical/platforme|platforme]] — Android-first, iOS kasnije
