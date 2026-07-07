---
type: dizajn
status: aktivan
milestone: M6
tags: [dizajn, gdd]
povezano:
  - pitch
  - core-loop
  - scope-i-granice
  - mehanike/_index
ai_sažetak: "Executive index Merge Meadow — lane run + merge kamp F2P hybrid casual."
---

# GDD overview

## Sažetak

**Merge Meadow** — F2P hybrid casual: 90 s lane run + merge kamp. Executive index; detalji u linkovanim docima.

## Igra u kratko

| Aspekt | Dokument |
|--------|----------|
| Pitch | [[../01-vision/pitch|pitch]] |
| Koncept / emocija | [[../01-vision/koncept|koncept]] |
| Publika | [[../01-vision/ciljana-publika|ciljana-publika]] |
| Pillars | [[../01-vision/design-pillars|design-pillars]] |
| Core loop | [[core-loop|core-loop]] |

## Što gradimo SADA (source of truth)

- [[spec-vertical-slice|spec-vertical-slice]] — tačno ponašanje svakog ekrana/mehanike + DoD (kod prati ovo)
- [[ekonomija-brojevi|ekonomija-brojevi]] — sve balans-konstante slice-a na jednom mjestu

## Ključne mehanike (must-have v1)

1. [[mehanike/lane-run|Lane run]] — core sesija, ad momenti
2. [[mehanike/merge-kamp|Merge kamp]] — meta, D7 retention
3. [[mehanike/mnozitelj-upgrade|Množitelj i upgrade]] — power fantasy

## Progresija i ekonomija

- [[progresija|progresija]] — 100 runova, endless, dnevni ritam
- [[ekonomija|ekonomija]] — Orbs T1–T3, merge 2:1
- [[monetizacija|monetizacija]] — rewarded + IAP

## Kontrole i UX

- [[kontrole-i-input|kontrole-i-input]] — portrait, swipe
- [[../04-experience/ui-ux|ui-ux]] — screen flow
- [[../04-experience/art-direction|art-direction]] — flat cartoon

## Tehnički sažetak

- Engine: Godot 4 ([[../05-technical/engine-odluka|engine-odluka]])
- Platforme: Android + iOS ([[../05-technical/platforme|platforme]])
- Scope: [[../06-production/scope-i-granice|scope-i-granice]]
- Operativa: [[../06-production/CHECKPOINT|CHECKPOINT]]

## Vertical slice vs launch

| | M7 slice | Launch |
|---|----------|--------|
| Run leveli | ~10 test | 100 + endless |
| Merge tierovi | 2 | 3–4 |
| Shop / IAP | test | production |
| iOS | iPhone test build | App Store |

## Usklađenost sa scopeom

GDD je usklađen s [[../06-production/scope-i-granice|scope-i-granice]] IN/OUT listom. Nove feature ideje → provjeri pillare → CHECKPOINT A ili OUT.

## Povezano

- [[_index|← Dizajn]]
- [[../06-production/milestone-i|milestone-i]]
