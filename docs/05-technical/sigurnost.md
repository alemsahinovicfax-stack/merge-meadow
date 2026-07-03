---
status: draft
tags: [tehnicko, sigurnost]
---

# Sigurnost

## Sažetak

Solo F2P casual igra bez servera — **niski rizik**, ali store i SDK-ovi imaju **minimum** za launch. Duboka sigurnosna revizija **nije prioritet u M6/M7**; checklist za **M8 launch**.

## Kada radimo što

| Faza | Sigurnost | Zašto |
|------|-----------|-------|
| **M6 greybox** | Gotovo ništa | Lokalni prototip, nema storea |
| **M7 slice** | Test SDK ključevi, `.gitignore` | AdMob/IAP test — ne commitaj tajne |
| **M8 launch** | **v1 minimum** ispod | Store zahtjevi + osnovna zaštita |
| **Post-launch** | Proširenja | Kad imaš korisnike i prihod |

**Nije prerano** znati što dolazi na launchu; **jeste prerano** raditi penetration test ili cloud security prije prvog APK-a.

## v1 launch — minimum (M8) ✅ obavezno

| Stavka | Akcija |
|--------|--------|
| **Tajne van gita** | AdMob app ID, IAP ključevi — env / export credentials, `.gitignore` |
| **Minimalni permissions** | Samo Internet (+ vibrate opcionalno) — vidi [[platforme|platforme]] |
| **Službeni SDK-ovi** | AdMob + Google Play Billing / StoreKit — ne custom payment |
| **Privacy policy** | URL u store listing (čak i za “ne prikupljamo podatke”) |
| **Lokalni save** | `user://save.json` — nema osjetljivih PII; ne logiraj lične podatke |
| **HTTPS** | Prepušteno ad/IAP SDK-ovima i storeu |
| **Debug build** | Ne objavljuj debug APK s test flagovima na Play |

## v1 — ne radimo (OUT)

| Stavka | Zašto kasnije / nikad |
|--------|----------------------|
| Vlastiti backend / login | Nema u scopeu |
| Cloud save | Nema servera u v1 |
| Anti-cheat | Single-player casual — nepotrebno |
| Certificate pinning | Overkill za offline casual |
| Enkripcija save fajla | Nema osjetljivih podataka |

## Post-launch / v1.1+ (kad zatreba)

- GDPR export/brisanje podataka — **ako** dodaš analytics ili account
- Firebase Analytics privacy review — ako uključiš analytics
- IAP receipt validacija — store SDK već radi; server-side samo ako imaš backend
- Security update policy — pratiti Godot/engine CVE

## Checklist prije store submita (M8)

- [ ] Nema API ključeva u repou
- [ ] Privacy policy URL live
- [ ] Permissions opravdane u store formi
- [ ] Testirani release build (ne debug)
- [ ] Age rating usklađen s contentom (3+)

## Otvorena pitanja

- [ ] Hosting privacy policy (GitHub Pages / Notion — besplatno)
- [ ] Treba li analytics u v1 (preporuka: **ne** na startu — manje GDPR brige)

## Povezano

- [[platforme|platforme]]
- [[../06-production/scope-i-granice|scope-i-granice]]
- [[../06-production/verzije-nakon-launcha|verzije-nakon-launcha]]
