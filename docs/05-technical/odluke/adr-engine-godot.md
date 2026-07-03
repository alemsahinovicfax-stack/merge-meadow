---
status: draft
tags: [tehnicko, engine]
decision: godot-4
---

# ADR: Engine — Godot 4

**Status:** Prihvaćeno  
**Datum:** 2026-06-30

## Kontekst

Solo student dev, slabiji laptop, 2D hybrid casual (lane run + merge UI), Android + iOS, F2P ads + IAP.

## Odluka

Koristimo **Godot 4.x** s GDScriptom.

## Posljedice

- `game/` folder = Godot projekt
- iOS build planirati s Mac/CI rješenjem
- Monetizacija preko Godot mobile plugina (AdMob, billing)

## Povezano

- [[../engine-odluka|engine-odluka]]
