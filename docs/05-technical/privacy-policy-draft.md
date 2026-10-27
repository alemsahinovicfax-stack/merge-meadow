---
type: tehnicko
status: aktivan
tags: [tehnicko, legal, privacy]
povezano:
  - sigurnost
  - platforme
  - play-internal-test
ai_sažetak: "Politika privatnosti Merge Meadowa: izvor je privacy/index.html (objavljuje ga GitHub Pages workflow na push u master); ovdje sažetak, zašto ne kopiramo tuđu, i šta mora biti istina u igri prije launcha (UMP pristanak, ATT, Data safety, uzrast)."
---

# Politika privatnosti

> **Izvor teksta:** [`privacy/index.html`](../../privacy/index.html) — engleski, za store. Push u `master` koji dira `privacy/**` pokreće workflow **Privacy policy Pages** i stranica ide javno na `https://alemsahinovicfax-stack.github.io/merge-meadow/` (link u Settingsu: `UiSettings.PRIVACY_URL`).
>
> **2026-10-16:** prepisana na zahtjev („premalo je"). Stara verzija je imala 5 kratkih sekcija; nova ima 13 i pokriva ono što Google Play, App Store i GDPR traže.

## Zašto ne kopirati politiku druge igre

1. **Tekst je tuđe autorsko djelo.**
2. **Opisivala bi njihovu igru, ne našu.** Druge igre često imaju naloge, servere, analitiku (Firebase, Unity Analytics), cloud save i chat. Politika koja tvrdi nešto što igra ne radi (ili prešuti nešto što radi) je netačna. Google Play to provjerava uz *Data safety* formular, a Apple uz *App Privacy*.

Zato je tekst napisan prema onome što **naša** igra stvarno radi. Za provjeru može poslužiti besplatan generator (npr. *App Privacy Policy Generator*, otvoren kod), ali samo kao lista stvari koje ne smiju fale — ne kao tekst.

## Šta politika kaže (sažetak)

| Tema | Šta piše |
|------|----------|
| Nalog | Nema. Napredak je samo na uređaju (`user://player_save.json`). |
| Reklame | Google AdMob: advertising ID / IDFA (samo uz ATT dozvolu), app set ID, IP, uređaj, interakcija s reklamama. Personalizovane uz pristanak (EEA / UK / CH), opt-out u SAD-u, *Settings → Privacy choices*. |
| Kupovine | **Ova verzija ih nema** (v1 samo s reklamama, 2026-10-26 — teme, skinovi i boosteri za coine iz igre, coini se ne prodaju). Sekcija o Google Play / App Store ostaje za buduću verziju: mi ne vidimo podatke kartice; purchase token na uređaju (`granted_purchase_tokens`) protiv dupliranja; *Restore purchases*. |
| Podrška | Email i poruka, samo za odgovor, najduže 12 mjeseci. |
| Ne skupljamo | Lokaciju, kontakte, kameru, mikrofon, vlastitu analitiku; ne prodajemo podatke. |
| Pravni osnov | Pristanak (personalizacija), ugovor (kupovine — samo ako se nude), legitimni interes (nepersonalizovane reklame, prevencija prevara, podrška). |
| Prava | Pristup, ispravka, brisanje, prigovor, prenosivost, povlačenje pristanka; odgovor u 30 dana; žalba nadzornom tijelu. |
| Djeca | Igra za opću publiku, nije namijenjena djeci ispod 13. |
| Prenos | Google / Apple, SCC i EU–US Data Privacy Framework. |

## Mora biti istina u igri prije launcha

- [ ] **Identitet** — GDPR traži ime (ili firmu) i zemlju onoga ko odgovara za podatke. Na stranici je sada samo „independent developer" + email. Prije store submita dodaj u §1 svoje ime ili ime studija i zemlju (to i Play Console ionako javno prikazuje uz developer račun).
- [x] **Google UMP pristanak** (2026-10-23, LAUNCH-PREP C): `admob_backend.gd` na startu radi `consent_information.update` → forma ako je `REQUIRED` → tek onda `MobileAds.initialize`; reklame se traže samo kad je status `NOT_REQUIRED` / `OBTAINED`. *Privacy choices* zove `AdManager.show_privacy_options()` → UMP *privacy options* forma kad je potrebna, inače ova stranica. Dev: Settings → Developer → „Consent as EU" / „Reset ad consent".
- [ ] **AdMob → Privacy & messaging:** forma se prikazuje **samo ako u AdMob konzoli postoji poruka** — napravi *European regulations (GDPR)* poruku (i po želji *US state regulations*) za Merge Meadow. Bez toga UMP vrati „nije potrebno" i nema forme ni u EU. (Korisnikov korak — [[../06-production/play-console-sutra|play-console-sutra]] § 8.)
- [x] Politika 2026-10-23: dodani približna lokacija iz IP-a, dijagnostika, interakcije s igrom, šifrovanje u prenosu, tačan ritam interstitiala, reklame samo za sve uzraste (`max_ad_content_rating = G`), SAD opt-out samo gdje Google poruka važi.
- [x] Politika 2026-10-26: v1 bez kupovina — sažetak, tabela, § 3 (Remove Ads), § 4 i pravni osnov kažu da ova verzija nema kupovina; tekst o Google Playu / App Storeu ostaje uz napomenu „samo ako se kupovine nude".
- [ ] **iOS:** ATT prompt prije IDFA (kad dođe iOS build).
- [ ] **Play Console → Data safety:** gotovi odgovori u [[../06-production/play-console-sutra|play-console-sutra]] § 4 (zamjenjuju listu ispod):
  - *Device or other IDs* i *App interactions* / *Diagnostics* — prikupljeno i dijeljeno (AdMob, svrha: reklame, analitika reklama, prevencija prevara);
  - *Purchase history* — v1 ne (nema kupovina ni Billinga); kad se IAP vrati, ono što dolazi kroz Play Billing;
  - *Personal info → Email* — samo ako korisnik piše podršci (*optional*);
  - šifrovanje u prenosu: da (AdMob / Play);
  - brisanje: korisnik briše lokalne podatke deinstalacijom.
  - Googleova lista onoga što AdMob SDK prikuplja: *Google Mobile Ads SDK — data disclosure* (developers.google.com).
- [ ] **Uzrast publike (Play → Target audience):** ako izabereš uzrast ispod 13, igra ulazi u *Families* pravila (samo certificirani ad SDK-ovi, child-directed tretman reklama) i politika se mora promijeniti. Preporuka: **13+**, uz AdMob max ad content rating **G**.
- [ ] Ako se ikad doda analitika, crash reporting ili cloud save — prvo ažurirati politiku i Data safety.
- [ ] Objava: GitHub Pages (repo javan ili GitHub Pro), pa URL u Play Console i App Store Connect.

## Povezano

- [[sigurnost|sigurnost]]
- [[platforme|platforme]]
- [[../06-production/play-internal-test|play-internal-test]]
