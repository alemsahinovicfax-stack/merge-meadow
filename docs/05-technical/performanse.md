---
status: draft
tags: [tehnicko, performanse]
---

# Performanse

## Sažetak

Ciljevi za mid-range Android i iPhone — Godot 2D na slabijem laptopu za dev.

## Ciljevi (v1)

| Metrika | Cilj | Test |
|---------|------|------|
| FPS (gameplay) | 60 (min 30 na starijem) | Android emulator + iPhone |
| RAM | < 150 MB | Godot profiler |
| Cold start | < 3 s | Emulator |
| APK veličina | < 80 MB | Launch build |
| Baterija | Nema beskonačnog loopa u pozadini | Manual |

## Optimizacije (Godot)

- Object pooling za orbs i čestice
- Atlas spriteovi za UI
- OGG umjesto WAV za muziku
- Ograniči `_process` na aktivne nodeove
- Jedan tileset za lane pozadinu

## Slab laptop (dev)

- Zatvori druge aplikacije pri exportu
- Koristi **debug** build za iteracije
- Release export samo za test distribuciju

## Otvorena pitanja

- [ ] Min spec uređaj za službeni test (npr. Android API 24)

## Povezano

- [[engine-odluka|engine-odluka]]
- [[platforme|platforme]]
