---
status: draft
tags: [iskustvo, audio]
---

# Audio direction

## Sažetak

Minimalan ali **satisfying** audio — SFX obavezno u sliceu; muzika opcionalna u kampu.

## Muzika

- **Žanr:** Lo-fi / acoustic pastel; sporo, cozy
- **Kamp:** Mekani loop, niska glasnoća
- **Run:** Tišina ili vrlo blagi ambient (ne smeta u javnom transportu)
- **Launch:** 1 kamp track; run opcionalno

## SFX (P0)

| Događaj | Karakter | Prioritet |
|---------|----------|-----------|
| Orb pickup | Kratak pop, visoki ton | M6 greybox |
| Merge pop | Satisfying ding + sparkle | M7 |
| Fail | Mekani thud, ne kazna | M6 |
| Upgrade unlock | Fanfare 0.5 s | M7 |
| UI tap | Blagi click | M7 |
| Rewarded ad complete | Pozitivan chime | Launch |

## Mix

| Kontekst | Glasnoća |
|----------|----------|
| Default SFX | 70% |
| Default music | 40% |
| Zvuk off u settings | Da — default za prvi run opcionalno |

## Implementacija (Godot)

- `AudioManager` autoload — pool 4–8 `AudioStreamPlayer`
- OGG za muziku, WAV za kratke SFX
- Placeholder: besplatni pack (Kenney, OpenGameArt) do finalnih

## Otvorena pitanja

- [ ] Licenca za finalnu muziku (royalty-free)
- [ ] Haptic + audio sync na merge

## Povezano

- [[art-direction|art-direction]]
- [[../05-technical/arhitektura|arhitektura]]
