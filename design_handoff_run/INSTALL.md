# Instalacija u Godot

Folder `game/` preslikava strukturu projekta — raspakuj preko `Mobilna igra/`:

```
game/scripts/visual/ui_run.gd      → class_name UiRun
game/assets/ui/run/icon_pause.svg
game/assets/ui/run/icon_basket.svg
```

Zatim:

1. `scripts/godot-import.ps1` → generiše `.import` za 2 nova SVG-a
2. Commitaj `.svg` + `.svg.import`
3. `icon_coin` / `icon_seed` / `icon_diamond` su već u `game/assets/ui/chrome/` — ne kopirati

`design/` je samo referenca (otvori `Run Redesign.dc.html` u browseru) — ne ide u `game/`.
Detalji prenosa: `README.md`.
