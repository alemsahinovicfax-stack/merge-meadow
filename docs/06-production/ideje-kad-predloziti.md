---
type: produkcija
status: aktivan
milestone: M7
tags: [produkcija, ideje, workflow, agent]
povezano:
  - ideje-roadmap-implementacije
  - ideje-prvo-iskustvo
  - ideje-gameplay-ekonomija
  - ideje-home-paid
  - ideje-home-glide
  - ideje-home-focus
  - ideje-home-unlock
  - ideje-home-incard
  - ideje-home-cardfit
  - ideje-home-lockflow
  - ideje-home-barfit
  - ideje-arena
  - CHECKPOINT
  - RADIONICA-razvoj
ai_sažetak: "Kad agent predlaže scratch ideju iz vaulta — triggeri, format, backlog UX-01+ / HOME-11 / ARENA-01."
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
| Camp UI, navigacija, gumbi | `camp_*`, F4–F5, F8 shop | ideje-prvo-iskustvo, roadmap F8 | **UX-04** Hub carousel |
| Run feel, spawn, HUD | `run_controller`, F2–F5 | [[../03-content/ideje-gameplay-ekonomija\|gameplay ekonomija]] R1–R7 | R3 zlatni grm |
| Loot / fail / rewarded | `loot_screen`, F3 | prvo iskustvo, monetizacija M1–M2 | — |
| Ekonomija, shop, novčići | `game_state`, F8 | [[../02-design/ekonomija-brojevi\|brojevi]], ideje §6 shop | Shop stub |
| Tutorial, onboarding | `tutorial_*`, F6–F7 | [[../03-content/ideje-prvo-iskustvo\|prvo iskustvo]] | — |
| Art / placeholder zamjena | CHECKPOINT C2 | roadmap F8, ideje launch scope | Pip sprite |
| Retention, dnevni loop | poslije F7 gate | ideje T1–T4, K5 pasivni | Daily chest |
| Home Stage / Shop IAP / post-launch tema | Home polish, shop packs, v1.1 | [[../03-content/ideje-sezone\|ideje-sezone]] | **SEZ-01** |
| Home layout, Panel chrome, season strip | `main_menu`, `season_stage` | [[../03-content/ideje-home-polish\|HOME-01]] | **HOME-01** |
| Home strip swipe mrtav na karticama | `season_stage` gui_input, paneli | [[../03-content/ideje-home-hit-targets\|HOME-02]] | **HOME-02** |
| Home chrome, Endless Hard, strip slide | `main_menu`, Endless, `season_stage` tap/tween | [[../03-content/ideje-home-chrome\|HOME-03]] | **HOME-03** |
| Shop season packs / paid vs free na Homeu | `shop_screen`, `season_stage` dual-band | [[../03-content/ideje-home-paid\|HOME-04]] | **HOME-04** |
| Home L/R glajd, vertikalni band swipe, outline | `season_stage` slide/swipe | [[../03-content/ideje-home-glide\|HOME-05]] | **HOME-05** |
| Home L/R cut, invert swipe, Browser ne fokusira, Theme badge | `season_stage`, `season_browser`, `PlayThemeBadge` | [[../03-content/ideje-home-focus\|HOME-06]] | **HOME-06** |
| Swipe dolje select, next-lock Unlock, 48 roster cvjetova | `season_stage`, `game_state`, `seasons.json` | [[../03-content/ideje-home-unlock\|HOME-07]] | **HOME-07** |
| Roster/Unlock nisu u prozoru sezone, premalo se vidi | `season_stage` CenterSlot, roster/gate overlay | [[../03-content/ideje-home-incard\|HOME-08]] | **HOME-08** |
| Unlock nije na Amberu / ime nije na sredini / roster isti na svim sezonama | `TEST_LOCK` amber, CenterTitle, roster frame | [[../03-content/ideje-home-cardfit\|HOME-09]] | **HOME-09** |
| Roster biježi lijevo / ellipsis / boja kasni na swipe / locked = ime+barovi+zlatni Unlock | `FreeRoster` clip, `UnlockGate` kut, `seasons.json` cost | [[../03-content/ideje-home-lockflow\|HOME-10]] | **HOME-10** |
| Barovi prekrivaju 🔒+ime / suvišan gate okvir / treba 500c za test Unlock | `UnlockGate` `anchor_top`, `make_frame`, debug wallet | [[../03-content/ideje-home-barfit\|HOME-11]] | **HOME-11** |
| Merge UX, slot overflow | kamp playtest, pre-launch | [[../02-design/merge-arena-v1.1\|merge-arena-v1.1]] | **MA-01** Merge Arena |
| Arena monotonija, combo, cliff, daily u areni | `merge_arena_controller`, Muncher, post-MA-01 playtest | [[../03-content/ideje-arena\|ideje-arena]] | **ARENA-01** |
| Daily retention | post-launch metrika | merge-arena-v1.1 § DG-01 · ARENA-01 daily slice | **DG-01** Daily Goals |

## Backlog — UX / flow (prioritet za predlaganje)

| ID | Ideja | Trigger (kad ponuditi) | Effort | Milestone |
|----|-------|------------------------|--------|-----------|
| **UX-01** | **Main menu gumb u kampu** | Camp navigacija | **S** | ✅ M7 2026-07-05 |
| **UX-04** | **Hub carousel** (Clash Royale swipe) — Shop · **Main Menu (centar)** · Camp · Arena · Collection | F8 shop, C2 art, meta UI | **L** | v1.1.0 |
| **MA-01b** | **Arena Muncher** — pest jede T1/T2, freeze na T3 | MA-01 playtest | **M** | v1.1.0 |
| UX-02 | Progress traka umjesto countdown tajmera | Run HUD / C2 art pass | M | v1.1 |
| UX-03 | Reset tutorial (dev) u settings | Debug, QA tutoriala | S | dev only |
| **MA-01** | **Merge Arena** (zamjena gredica) | Slot overflow, merge feel | **L** | v1.1.0 |
| **DG-01** | **Daily Goals** (3 task + bonus) | Retention, daily loop | **M** | v1.1.1 |
| **SEZ-01** | **Sezone / teme** (free linear + paid IAP; Home Stage) | Home, Shop IAP, post-launch | **L** | v1.1+ · prompti [[plan-prompts-sez-01\|plan-prompts-sez-01]] **P0–E ✅** |
| **HOME-01** | **Home polish** — ukinuti Panel; 3-slot free swipe | `main_menu`, Season Stage | **M** | v1.1+ · prompti [[plan-prompts-home-polish\|plan-prompts-home-polish]] **P0–C ✅** |
| **HOME-02** | **Hit targets** — swipe+tap preko kartica | `season_stage` paneli gutaju input | **S** | v1.1+ · [[plan-prompts-home-hit-targets\|plan-prompts-home-hit-targets]] **HIT-A ✅** |
| **HOME-03** | **Home chrome** — 2 gumba, Browser samo C, Endless Hard, slide | `main_menu`, Endless, strip tween | **M** | v1.1+ · [[plan-prompts-home-chrome\|plan-prompts-home-chrome]] **P0–C ✅** |
| **HOME-04** | **Paid dual-band + shop packs** — bez Select; 2-col; 20/80 paid/free | Shop packs, Home paid vs free | **L** | v1.1+ · [[plan-prompts-home-paid\|plan-prompts-home-paid]] **P0–C ✅** |
| **HOME-05** | **Glide + katalog** — full-slot L/R; vertikalni swap; Play outline; +1 free +2 paid | Home swipe, nove sezone | **M** | v1.1+ · [[plan-prompts-home-glide\|plan-prompts-home-glide]] **P0–C ✅** |
| **HOME-06** | **Focus korekcija** — L/R bez cuta; invert swipe; Browser fokus; outline; test-lock; bez badgea | L/R cut, Browser, Theme: label | **M** | v1.1+ · [[plan-prompts-home-focus\|plan-prompts-home-focus]] **P0–C ✅** |
| **HOME-07** | **Unlock + roster** — swipe dolje select; next-lock Unlock; 48 T3 cvjetova | Select, lantern test, roster | **M** | v1.1+ · [[plan-prompts-home-unlock\|plan-prompts-home-unlock]] **P0–C ✅** |
| **HOME-08** | **In-card chrome** — roster+Unlock u hero-centar prozoru; veći tip; Lantern gate na kartici | Overlay vs prozor, čitljivost | **S** | v1.1+ · [[plan-prompts-home-incard\|plan-prompts-home-incard]] **P0–B ✅** |
| **HOME-09** | **Cardfit** — Amber off TEST_LOCK; naslov sredina; roster kontrast+širina | Unlock „nije napravljen“, ime gore, isti tamni roster | **S** | v1.1+ · [[plan-prompts-home-cardfit\|plan-prompts-home-cardfit]] **P0–B ✅** |
| **HOME-10** | **Lockflow** — locked poster 500/20 gold; roster desno bez ellipsisa; wash | Roster clip lijevo, `...`, swipe glitch boje, Unlock nije ime+barovi | **S** | v1.1+ · [[plan-prompts-home-lockflow\|plan-prompts-home-lockflow]] **P0–B ✅** |
| **HOME-11** | **Barfit** — gate niže ispod 🔒+ime; bez okvira; debug 500c | Barovi prekrivaju ime/katanac, wash panel suvišan, Unlock se ne da testirati | **S** | v1.1+ · [[plan-prompts-home-barfit\|plan-prompts-home-barfit]] **P0–A ✅** |
| **ARENA-01** | **Arena zabavnija** — combo+pulse, auto-refill, leftover T2→2×T1, daily badge | Arena dosadna, Muncher, T2 chore | **M** | v1.1+ · [[../03-content/ideje-arena\|ideje-arena]] **freeze ✅** · prompti [[plan-prompts-arena\|plan-prompts-arena]] COMB-A… |

### UX-01 — Main menu u kampu (detalj)

**Problem:** Nakon tutorijala hub je **Play + Camp** na main menuu, ali iz kampa jedini izlaz je **Play** — treba ugasiti Godot da vidiš hub.

**Rješenje:** Gumb u `camp_scene` (npr. ispod Play ili u headeru): **Main Menu** → `SceneRouter` → `main_menu.tscn`. Ne dira save; `tutorial_complete` ostaje.

**DoD:** Jedan tap iz kampa → main menu s Play + Camp; headless smoke prolazi.

**Povezano:** [[../03-content/ideje-prvo-iskustvo#nakon-tutorijala--main-menu-hub-odlučeno-2026-07-04|post-tutorial hub]]

### UX-04 — Hub carousel (Clash Royale meta) — odobreno v1.1.0 (2026-07-29)

**Koncept:** Jedan meta-layer s **swipe L/R** između 5 full-screen stranica. **Default landing = Main Menu (centar).**

| # | Stranica | Svrha |
|---|----------|--------|
| 0 | **Shop** | Kozmetika, IAP, coins sink |
| 1 | **Main Menu ★** | Play, Endless, Camp/Shop shortcuti (trenutni hub) |
| 2 | **Camp / Garden** | Upgrade kartice, daily, Play/Merge footer |
| 3 | **Merge Arena** | MA-01 + MA-01b Muncher |
| 4 | **Collection / Journal** | Album, ★★★ preview |

**Run / loot** ostaju odvojene scene (ne dio carousela).

**Kod:** `game/scenes/meta/meta_hub.tscn`, `swipe_pager.gd`, `meta_hub_controller.gd`.

**Effort:** L — implementirano u v1.1 paket.

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
- [[../03-content/ideje-sezone|SEZ-01 sezone]]
- [[../03-content/ideje-arena|ARENA-01 Merge Arena]]
- [[plan-prompts-arena|plan-prompts-arena]] — COMB-A→FEEL-B
- [[../03-content/ideje-home-lockflow|HOME-10 Lockflow]]
- [[../03-content/ideje-home-barfit|HOME-11 Barfit]]
- [[../03-content/ideje-home-cardfit|HOME-09 Cardfit]]
- [[plan-prompts-sez-01|plan-prompts-sez-01]] — P0→E
- `.cursor/rules/ideje-kad-predloziti.mdc`
