# assets/

Nema novih fajlova za uvoz. Polje koristi postojeće:

- `game/assets/ui/chrome/icon_seed.svg` (chrome v2) — prazna korpa; `icon_seed_light.svg` se briše
- `game/assets/ui/chrome/icon_flower.svg` (chrome v2) — GrownChip
- `icon_lock.svg` — zaključana korpa, zaključani red pickera

Glifovi ︽ (Upgrades), ‹ (Seasons), ▶ (Play) i ∞ (Endless, dva prstena) crtaju se u kodu: `UiStage.draw_chevron()`, `draw_play()`, `draw_arc()`. Cvijeće i Pipa crta igra; `design/flowers/ph_*.svg` su samo placeholderi u mockupu.
