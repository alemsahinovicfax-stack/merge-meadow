## plant_frame.gd — NIJE skripta za igru.
## Popis novih vrijednosti POSTOJECIH konstanti, grupisano po fajlu. Nazivi su isti kao u kodu.
## Izvor: design_handoff_plant_frame/design/PlantFrame.dc.html · docs/04-experience/design-drafts/plant-frame-cd-brief.md
## "—" = konstanta ostaje nekoristena poslije prenosa; brisi je tek kad smoke testovi prodju.

# ============================================================================
# UiArena — game/scripts/visual/ui_arena.gd
# ============================================================================
# Promjer cipa (arena_seed_chip.gd CHIP_RADIUS 48 x 1.4 = 134) — NE DIRATI.
const RIM_BORDER := 3               # bilo 3 (isto)
const RIM_BAND_T1 := 5              # bilo 11 · vidljiv cream 14 -> 8
const RIM_BAND_T2 := 8              # bilo 15 · vidljiv cream 18 -> 11
const WELL_BORDER := 2              # bilo 2 (isto)
const CHIP_T2_RADIUS := 38          # bilo 38 (isto)
const CHIP_T2_WELL_RADIUS := 27     # bilo 26 · 38 - 11
const T2_HAIRLINE_INSET := 5        # bilo 7 · prsten lezi u cream pojasu 3..11
const T2_HAIRLINE_RADIUS := 33      # bilo 32
const T2_HAIRLINE_W := 2            # bilo 3
const FLOWER_SIZE_T1 := 80.0        # bilo 78 · kutija ODREZANOG crteza (vidi CropRule)
const FLOWER_SIZE_T2 := 88.0        # bilo 84 · kutija odrezanog crteza
const FLOWER_SIZE_T3 := 140.0       # bilo 140 (isto) · kristal bez okvira
# PULSE_GOLD #F2D940 i COIN_GOLD #FFD56B ostaju boje hinta / magneta.

# ============================================================================
# ArenaChipDraw — game/scripts/camp/arena_chip_draw.gd  (_draw_ring)
# ============================================================================
# Ring.PULSE   sirina 6 -> 12 · grow 14 -> 20 (prsten od r 77 do r 65; 10 px van cipa)
# Ring.PULSE   alpha 0.8 -> 1.0
# Ring.PARTNER sirina 7 -> 14 · grow 20 -> 24 (r 79 -> 65), scale 1.04 ostaje
# Prsten se crta IZNAD rima (danas ispod) — prekrije 2 px ruba RIM_EDGE.
# Pravilo: sirina hinta > RIM_BORDER + RIM_BAND_T2 (12 > 11).

# ============================================================================
# UiJournal — game/scripts/visual/ui_journal.gd
# ============================================================================
const ROW_H := 200                  # bilo 200 (isto)
const SLOT := 136                   # bilo 112 · prostor natpisa ide okviru
const SLOT_GAP := 14                # bilo 18 · TierStrip 3 x 136 + 2 x 14 = 436
const WELL_INSET := 0               # bilo 10 · well se ne crta (tier_well_style van upotrebe) —
const ART := 110                    # bilo 88 · odrezan crtez, BEZ FIT_FRAC 0.36
const TIER_LABEL_FONT := 0          # bilo 32 · TierLabel cvor se brise —
const TIER_LABEL_GAP := 0           # bilo 8 —
const HALO_GROW := 9                # bilo 9 (isto)
# tier_frame_style("crystal"): set_corner_radius_all(30) -> 36
# tier_halo_style(true):       30 + HALO_GROW          -> 36 + HALO_GROW
# tier_frame_style("bloom"/"empty"): SLOT / 2 vec prati SLOT, bez izmjene.

# ============================================================================
# UiCamp — game/scripts/visual/ui_camp.gd
# ============================================================================
const CHIP_SIZE := Vector2(489, 176)  # isto
const CHIP_ART_FRAME := 128           # isto
const CHIP_ART_FRAME_RADIUS := 28     # isto
const CHIP_ART_WELL_INSET := 0        # bilo 8 · art_well_style van upotrebe —
const CHIP_ART_SEED := 104            # bilo 96 · odrezano
const CHIP_ART_FLOWER := 108          # bilo 100 · odrezano
const TRADE_ART := 104                # isto
const TRADE_ART_WELL_INSET := 0       # bilo 7 —
const TRADE_ART_SEED := 84            # bilo 80
const TRADE_ART_FLOWER := 88          # bilo 84
const SEASON_ART_FRAME := 56          # isto
const SEASON_ART := 46                # bilo 40

# ============================================================================
# UiRun — game/scripts/visual/ui_run.gd
# ============================================================================
const SEED_SIZE := 120                # isto · sad vizualna kutija biljke, nije krug
const SEED_WELL_SIZE := 0             # bilo 84 · nema wella ni kruga —
const SEED_FLOWER_SIZE := 120         # bilo 76 (x 0.36) · odrezan crtez puni SEED_SIZE
const SEED_PIP_SIZE := 22             # bilo 16 · pip dobija cream rub 3 px (CHIP_BG)
const SEED_PIP_RADIUS := 78           # bilo 51 · uglovi isti -> kruna iznad biljke
const PICKUP_SHADOW_SIZE := Vector2(64, 18)  # isto
const PICKUP_SHADOW_OFFSET := 70      # bilo 40 · sjena ispod baze stabljike (+60)
# seed_pickup.tscn radius = 26 — NE DIRATI.

# ============================================================================
# CampPlantDraw — game/scripts/camp/camp_plant_draw.gd
# ============================================================================
# FIT_FRAC := 0.36 ostaje za Home polje, korpu i biranje sezone.
# Journal, Camp i Run prelaze na odrezan crtez (CropRule u plant_frame_export.json):
#   rect = texture.get_image().get_used_rect()   # jednom po texturi, kesirati
#   s = box / max(rect.size.x, rect.size.y); nacrtaj region rect skaliran s, centriran u box.
