---
type: tehnicko
status: aktivan
milestone: M6
tags: [tehnicko, godot, dev]
povezano:
  - platforme
  - CHECKPOINT
  - engine-odluka
ai_sažetak: "HP AMD laptop — Godot 4.7 uvijek s --rendering-driver opengl3; skripta scripts/godot-open.ps1."
---

# Godot dev setup — HP laptop

## Problem

Na ovom stroju (**AMD Radeon integrisana grafika**, stariji drajver) Godot 4.7 s **Vulkan (Forward+)** zaglavi pri otvaranju projekta — editor se ne učita.

## Rješenje (obavezno)

**Uvijek** pokreći Godot s:

```
--rendering-driver opengl3
```

## Kako pokrenuti (preporučeno)

### 1. Skripta iz repoa (najlakše)

Dvostruki klik:

```
scripts/godot-open.bat
```

Ili u PowerShellu iz roota projekta:

```powershell
.\scripts\godot-open.ps1
```

Skripta traži exe na Desktopu, u Downloads ili `C:\Godot\`. Ako je drugdje:

```powershell
$env:GODOT_PATH = "C:\putanja\Godot_v4.7-stable_win64.exe"
.\scripts\godot-open.ps1
```

### 2. Ručno (PowerShell)

```powershell
& "$env:USERPROFILE\Desktop\Godot_v4.7-stable_win64.exe" --rendering-driver opengl3
```

### 3. Windows shortcut (trajno)

Desni klik na exe → Create shortcut → Properties → Target:

```
"C:\Users\Alem\Desktop\Godot_v4.7-stable_win64.exe" --rendering-driver opengl3
```

## Novi projekti

Pri **Create New Project** odaberi renderer **Compatibility** (ne Forward+).

U postojećem projektu: **Project → Project Settings → Rendering → Renderer → Rendering Method** = `gl_compatibility`.

## Za agenta (Cursor)

- **Ne predlaži** dvostruki klik na Godot exe bez OpenGL flaga — neće raditi na ovom laptopu.
- Za pokretanje koristi `scripts/godot-open.ps1` ili komandu s `--rendering-driver opengl3`.
- Detalji: [[platforme|platforme]] · root `AGENTS.md`

## Povezano

- [[platforme|platforme]] — Android emulator, SDK putanje
- [[../06-production/CHECKPOINT|CHECKPOINT]] — B1 setup
