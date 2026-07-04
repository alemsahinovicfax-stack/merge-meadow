---
type: produkcija
status: aktivan
milestone: M7
tags: [produkcija, ideje, workflow, agent]
povezano:
  - ideje-roadmap-implementacije
  - ideje-prvo-iskustvo
  - ideje-gameplay-ekonomija
  - CHECKPOINT
  - RADIONICA-razvoj
ai_sažetak: "Kad agent predlaže scratch ideju iz vaulta — triggeri, format, backlog UX-01+."
---

# Ideje — kad predložiti (agent + ti)

> **Scratch ideje** žive u `docs/03-content/ideje-*.md` i [[ideje-roadmap-implementacije|roadmap]].
> **Ne implementirati** bez potvrde (scope guard). Ovdje: **kada** ih ponuditi i **kako**.

## Pravilo (1 ideja po prilici)

Agent **može** ponuditi **najviše jednu** ideju kad trigger odgovara trenutnom poslu. Format:

```
💡 IDEJA [ID] — kratak naslov

Zašto sada: [1 rečenica veza s trenutnim korakom]
Što: [1–2 bulleta]
Effort: S / M / L · Milestone: M7 / v1.1 / v1
Primjeniti sada, odgoditi, ili preskočiti?
```

- **Ne** spamati svaku sesiju.
- **Ne** predlagati OUT scope (vidi `scope-i-granice.md`).
- **Da** predložiti kad CHECKPOINT korak i trigger tablica se poklapaju.

## Triggeri (kontekst → pogledaj ideje)

| Kad radimo… | CHECKPOINT / fajl | Predloži iz… | Primjer ID |
|-------------|-------------------|--------------|------------|
| Camp UI, navigacija, gumbi | `camp_*`, F4–F5 | [[../03-content/ideje-prvo-iskustvo\|prvo iskustvo]], roadmap F8 | **UX-01** Main menu |
| Run feel, spawn, HUD | `run_controller`, F2–F5 | [[../03-content/ideje-gameplay-ekonomija\|gameplay ekonomija]] R1–R7 | R3 zlatni grm |
| Loot / fail / rewarded | `loot_screen`, F3 | prvo iskustvo, monetizacija M1–M2 | — |
| Ekonomija, shop, novčići | `game_state`, F8 | [[../02-design/ekonomija-brojevi\|brojevi]], ideje §6 shop | Shop stub |
| Tutorial, onboarding | `tutorial_*`, F6–F7 | [[../03-content/ideje-prvo-iskustvo\|prvo iskustvo]] | — |
| Art / placeholder zamjena | CHECKPOINT C2 | roadmap F8, ideje launch scope | Pip sprite |
| Retention, dnevni loop | poslije F7 gate | ideje T1–T4, K5 pasivni | Daily chest |

## Backlog — UX / flow (prioritet za predlaganje)

| ID | Ideja | Trigger (kad ponuditi) | Effort | Milestone |
|----|-------|------------------------|--------|-----------|
| **UX-01** | **Main menu gumb u kampu** — `To Meadow` / `Home`; Play+Camp hub bez restarta Godota | Camp UI, navigacija, post-tutorial, korisnik spominje restart | **S** | M7 / v1.1 |
| UX-02 | Progress traka umjesto countdown tajmera | Run HUD / C2 art pass | M | v1.1 |
| UX-03 | Reset tutorial (dev) u settings | Debug, QA tutoriala | S | dev only |

### UX-01 — Main menu u kampu (detalj)

**Problem:** Nakon tutorijala hub je **Play + Camp** na main menuu, ali iz kampa jedini izlaz je **Play** — treba ugasiti Godot da vidiš hub.

**Rješenje:** Gumb u `camp_scene` (npr. ispod Play ili u headeru): **Main Menu** → `SceneRouter` → `main_menu.tscn`. Ne dira save; `tutorial_complete` ostaje.

**DoD:** Jedan tap iz kampa → main menu s Play + Camp; headless smoke prolazi.

**Povezano:** [[../03-content/ideje-prvo-iskustvo#nakon-tutorijala--main-menu-hub-odlučeno-2026-07-04|post-tutorial hub]]

## Agent checklist (po sesiji)

1. Pročitaj CHECKPOINT `sljedeci_korak` + aktivnu datoteku.
2. Pogledaj tablicu triggera gore — ima li **točan** match?
3. Ako da → jedna `💡 IDEJA` prije zatvaranja sesije **ili** na početku sljedećeg koraka (ne usred bugfixa).
4. Ako korisnik kaže **primjeni** → provjeri scope → implementiraj → ažuriraj roadmap/changelog.
5. Ako **odgodi** → ostavi u ovom docu; ne briši.

## Povezano

- [[ideje-roadmap-implementacije|build order F0–F9]]
- [[../03-content/ideje-prvo-iskustvo|prvo iskustvo]]
- [[../03-content/ideje-gameplay-ekonomija|gameplay ekonomija]]
- `.cursor/rules/ideje-kad-predloziti.mdc`
