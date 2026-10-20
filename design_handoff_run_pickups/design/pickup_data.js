// Run pickups — single source of truth (preview engine, Specs and godot/*.json are all generated from this).
// Units: px of the 1080 x 1920 artboard, seconds. Key = [t, value, ease-to-next]. Ease names = Godot Tween (TRANS_x + EASE_y):
// lin · quad_in · quad_out · quad_inout · back_out · sine_inout.
(function (G) {
'use strict';
const KIT = {"SEEDS":{"country_bloom":["clover","tulip","pumpkin"],"frost_orchard":["frost_snowdrop","winter_camellia","crystal_peony"],"lantern_meadow":["dusk_firefly_grass","foxfire_lily","midnight_lotus"],"amber_canopy":["copper_leaf","cider_dahlia","amber_magnolia"],"moonlit_warren":["moon_moss","lunar_orchid","umbral_lily"],"coral_tide":["sea_thrift","coral_hibiscus","reef_crown"],"starfall_glade":["comet_sprig","aurora_tulip","nova_bloom"],"ember_fen":["marsh_rush","flame_iris","fenfire_crown"]},"names":{"clover":"Meadow Clover","daisy":"Field Daisy","buttercup":"Buttercup Lane","tulip":"Barn Tulip","sunflower":"Sunfence","pumpkin":"Harvest Pumpkin","frost_snowdrop":"Frost Snowdrop","ice_crocus":"Ice Crocus","silver_aconite":"Silver Aconite","winter_camellia":"Winter Camellia","hoarfrost_rose":"Hoarfrost Rose","crystal_peony":"Crystal Peony","dusk_firefly_grass":"Dusk Firefly Grass","paper_lantern_bloom":"Paper Lantern Bloom","evening_primrose":"Evening Primrose","foxfire_lily":"Foxfire Lily","glow_wisteria":"Glow Wisteria","midnight_lotus":"Midnight Lotus","copper_leaf":"Copper Leaf","maple_aster":"Maple Aster","russet_mallow":"Russet Mallow","cider_dahlia":"Cider Dahlia","golden_oak_bloom":"Golden Oak Bloom","amber_magnolia":"Amber Magnolia","moon_moss":"Moon Moss","nightshade_petal":"Nightshade Petal","silver_harebell":"Silver Harebell","lunar_orchid":"Lunar Orchid","star_jasmine":"Star Jasmine","umbral_lily":"Umbral Lily","sea_thrift":"Sea Thrift","salt_daisy":"Salt Daisy","tide_anemone":"Tide Anemone","coral_hibiscus":"Coral Hibiscus","pearl_waterlily":"Pearl Waterlily","reef_crown":"Reef Crown","comet_sprig":"Comet Sprig","nebula_clover":"Nebula Clover","meteor_daisy":"Meteor Daisy","aurora_tulip":"Aurora Tulip","galaxy_sunburst":"Galaxy Sunburst","nova_bloom":"Nova Bloom","marsh_rush":"Marsh Rush","peat_violet":"Peat Violet","cinder_buttercup":"Cinder Buttercup","flame_iris":"Flame Iris","smoke_lotus":"Smoke Lotus","fenfire_crown":"Fenfire Crown"},"crops":{"clover_t1":[89,132,78,121],"tulip_t1":[86,113,85,140],"pumpkin_t1":[60,145,123,104],"pumpkin_t3":[29,103,179,146],"frost_snowdrop_t1":[102,141,71,111],"winter_camellia_t1":[93,115,74,138],"crystal_peony_t1":[88,103,81,151],"crystal_peony_t3":[40,58,176,196],"dusk_firefly_grass_t1":[97,135,68,114],"foxfire_lily_t1":[87,99,81,154],"midnight_lotus_t1":[31,170,174,79],"midnight_lotus_t3":[31,153,209,98],"copper_leaf_t1":[96,130,64,122],"cider_dahlia_t1":[93,107,73,146],"amber_magnolia_t1":[85,102,91,152],"moon_moss_t1":[77,136,102,113],"moon_moss_t3":[48,81,160,168],"lunar_orchid_t1":[60,131,136,120],"lunar_orchid_t3":[60,59,136,192],"umbral_lily_t1":[81,73,92,180],"umbral_lily_t3":[72,52,126,201],"sea_thrift_t1":[89,125,73,124],"sea_thrift_t3":[73,62,113,187],"coral_hibiscus_t1":[87,104,80,149],"coral_hibiscus_t3":[70,58,132,195],"reef_crown_t1":[99,111,58,144],"reef_crown_t3":[48,67,164,188],"comet_sprig_t1":[92,126,77,123],"comet_sprig_t3":[49,72,161,177],"aurora_tulip_t1":[98,114,63,139],"aurora_tulip_t3":[85,65,110,188],"nova_bloom_t1":[92,102,75,151],"nova_bloom_t3":[40,52,178,201],"marsh_rush_t1":[98,128,63,121],"marsh_rush_t3":[63,71,138,178],"flame_iris_t1":[90,107,69,146],"flame_iris_t3":[78,71,117,182],"fenfire_crown_t1":[92,99,75,155],"fenfire_crown_t3":[31,51,197,203],"nightshade_petal_t3":[77,51,102,202],"silver_harebell_t3":[93,105,124,147],"star_jasmine_t3":[74,63,127,189],"salt_daisy_t3":[82,55,92,198],"tide_anemone_t3":[90,71,76,182],"pearl_waterlily_t3":[35,162,209,89],"nebula_clover_t3":[75,56,123,197],"meteor_daisy_t3":[79,61,98,192],"galaxy_sunburst_t3":[73,45,110,209],"peat_violet_t3":[92,89,72,164],"cinder_buttercup_t3":[89,69,78,184],"smoke_lotus_t3":[35,164,183,87]},"run":{"country_bloom":{"ground":"#2F4A33","lane":"#44663F","edge":"rgba(255,248,240,.20)","seam":"rgba(255,248,240,.16)"},"frost_orchard":{"ground":"#DCE7F3","lane":"#5F7894","edge":"rgba(255,255,255,.55)","seam":"rgba(255,255,255,.30)"},"lantern_meadow":{"ground":"#15112A","lane":"#2C2450","edge":"rgba(255,227,184,.26)","seam":"rgba(255,227,184,.16)"},"amber_canopy":{"ground":"#7A5434","lane":"#4A3220","edge":"rgba(255,235,199,.28)","seam":"rgba(255,235,199,.16)"},"moonlit_warren":{"ground":"#1A1E3E","lane":"#323A6E","edge":"rgba(237,235,255,.24)","seam":"rgba(237,235,255,.16)"},"coral_tide":{"ground":"#E8C9A8","lane":"#3B6F78","edge":"rgba(255,255,255,.40)","seam":"rgba(255,255,255,.22)"},"starfall_glade":{"ground":"#100D26","lane":"#2A2456","edge":"rgba(233,224,255,.26)","seam":"rgba(233,224,255,.16)"},"ember_fen":{"ground":"#1C0F0B","lane":"#3E2A22","edge":"rgba(255,199,158,.26)","seam":"rgba(255,199,158,.16)"}}};
const INK = '#2D3436';
const PIP_Y = 1574, LANES = [270, 540, 810];
// Anchors (follow Pip every frame): C = paws / catch point, B = back / "pocket".
const ANCHOR = { C: [0, -46], B: [0, 12] };
const SPRITES = {
  coin: { file: 'assets/pickups/coin.svg', w: 96, h: 96 },
  coin_edge: { file: 'assets/pickups/coin_edge.svg', w: 96, h: 96 },
  shadow: { file: 'assets/pickups/pickup_shadow.svg', w: 64, h: 18 },
  soil: { file: 'assets/pickups/seed_soil.svg', w: 112, h: 52 },
  dew: { file: 'assets/pickups/seed_dew.svg', w: 22, h: 28 },
  halo2: { file: 'assets/pickups/seed_halo_r2.svg', w: 150, h: 150 },
  halo3: { file: 'assets/pickups/seed_halo_r3.svg', w: 170, h: 170 },
  spark: { file: 'assets/fx/fx_sparkle.svg', w: 30, h: 30 },
  ring_gold: { file: 'assets/fx/fx_ring_gold.svg', w: 128, h: 128 },
  ring_mint: { file: 'assets/fx/fx_ring_mint.svg', w: 128, h: 128 },
  ring_lav: { file: 'assets/fx/fx_ring_lav.svg', w: 128, h: 128 },
  ring_peach: { file: 'assets/fx/fx_ring_peach.svg', w: 128, h: 128 },
  chip: { file: 'assets/fx/fx_coin_chip.svg', w: 26, h: 26 },
  crumb: { file: 'assets/fx/fx_crumb.svg', w: 16, h: 16 },
  stamp_x2: { file: 'assets/fx/fx_x2.svg', w: 84, h: 84 },
  // sapling = existing Season Kit flower art (t1 crop, ★3 bloom = t3 crop); not a new texture
  sapling: { file: 'res://assets/flowers/<seed>_t1.svg (crop)', w: 0, h: 104, anchor: 'bottom' },
  bloom: { file: 'res://assets/flowers/<seed>_t3.svg (crop)', w: 0, h: 104, anchor: 'bottom' }
};
const MAGNET = {
  radius: L => 40 + 48 * L, files: [0, 1, 2, 3, 4].map(L => 'assets/fx/magnet_ring_l' + L + '.svg'),
  ring: { rot_deg_s: 18, alpha: 1, pull_pulse: { s: 1.04, t: 0.1 } },
  fly: { t_min: 0.12, t_max: 0.2, t: 'lerp(t_min, t_max, clamp(d / 232))', ease: 'quad_in', arc: 0.22, arc_note: 'perpendicular bulge = arc · d, away from lane centre', scale_end: 0.85, homing: true }
};
const IDLE = {
  coin: { sprites: ['shadow', 'coin|coin_edge', 'spark'], bob: { amp: 5, w: 2.6 },
    spin: { period: 1.6, turn: 0.48, rule: 'u = (t mod period)/turn; if u<1: sx = max(0.12,|cos 2πu|), frame = coin_edge while |cos|<0.25', phase: 'x/1080 · period' },
    glint: { at: [30, -30], t: [0.62, 0.92], s: [[0.62, 0, 'back_out'], [0.74, 1, 'quad_in'], [0.92, 0]], r: [0, 90] }, shadow: { at: [0, 40], s: [1, 1] } },
  seed: { 1: { sprites: ['shadow', 'soil', 'sapling', 'dew'] }, 2: { sprites: ['shadow', 'halo2', 'soil', 'sapling', 'dew', 'spark', 'spark'] }, 3: { sprites: ['shadow', 'halo3', 'soil', 'sapling', 'dew', 'spark', 'spark', 'spark'] },
    soil_at: [0, 18], sapling_base: [0, 20], shadow: { at: [0, 34], s: [1.6, 1.3] }, dew: { at: [16, -44], bob: { amp: 2, w: 3.1 } },
    sway: { deg: 6, period: 1.6, pivot: 'sapling base' }, bob: { amp: 3, w: 2.4 },
    halo: { 2: { sprite: 'halo2', at: [0, -36], rot_deg_s: 40, pulse: { amp: 0.04, period: 1.6 }, sparks: { n: 2, radius: 62, deg_s: 120, s: 0.8 } },
            3: { sprite: 'halo3', at: [0, -40], rot_deg_s: -30, pulse: { amp: 0.05, period: 1.4 }, sapling_scale: 1.12, sparks: { n: 3, radius: 70, deg_s: -90, s: 0.9 } } } }
};
const HUD = {
  chips: { coin: [610, 124], seed: [806, 124] },
  pill: { h: 64, radius: 32, bg: '#FFF8F0', border: [INK, 3], icon: 44, font: '900 44px Nunito', ink: INK, pad_x: 18, gap: 8, shadow: '0 4 0 rgba(18,28,22,.42)' },
  flight: { dur: 0.3, ease: 'quad_inout', path: 'quadratic: from C, ctrl = (C.x + 0.25·(chip.x − C.x), C.y − 260), to chip', s: [[0, 1, 'quad_out'], [0.3, 0.7]], a: [[0, 1], [0.26, 1, 'lin'], [0.3, 0]] },
  bump: { s: '[[0,1,quad_out],[0.06,bump,back_out],[0.2,1]]', number_pop: [[0, 1.25, 'quad_out'], [0.16, 1]] },
  toast: 'unchanged: "+1 Name" under SeedChip, 1.4 s, max 2 (run_pickup_feed.gd)'
};
const STREAK = { window: 0.6, max: 5, note: 'coin contacts ≤ 0.6 s apart raise n (1..5); same rule as the rising coin tone' };

function coin(n) {
  const k = Math.min(Math.max(n, 1), 5), ringS = 1 + 0.15 * (k - 1), chips = [3, 3, 4, 4, 5][k - 1], S = [];
  S.push({ id: 'coin', sprite: 'coin', own: true, at: 'C', t0: 0, t1: 0.12, frame: [[0, 'coin'], [0.07, 'coin_edge']], z: 2,
    keys: { y: [[0, 0, 'quad_in'], [0.1, 12]], sx: [[0, 1.25, 'quad_out'], [0.04, 1.25, 'quad_in'], [0.1, 0.12]], sy: [[0, 0.75, 'quad_out'], [0.04, 1.05, 'quad_in'], [0.1, 0.7]], a: [[0, 1], [0.09, 1, 'lin'], [0.12, 0]] } });
  S.push({ id: 'ring', sprite: k >= 5 ? 'ring_peach' : 'ring_gold', at: 'C', t0: 0.03, t1: 0.26, z: 1,
    keys: { s: [[0.03, r(0.3 * ringS), 'quad_out'], [0.26, r(ringS)]], a: [[0.03, 1], [0.14, 1, 'quad_in'], [0.26, 0]] } });
  for (let i = 0; i < chips; i++) {
    const ang = (-90 + i * 360 / chips + (k % 2 ? 0 : 180 / chips)) * Math.PI / 180, d = 60 + 8 * k;
    S.push({ id: 'chip' + i, sprite: 'chip', at: 'C', t0: 0.05, t1: 0.26, z: 3,
      keys: { x: [[0.05, 0, 'quad_out'], [0.26, r(Math.cos(ang) * d)]], y: [[0.05, 0, 'quad_out'], [0.26, r(Math.sin(ang) * d)]], r: [[0.05, 0], [0.26, 200]], s: [[0.05, 1], [0.26, 0.45]], a: [[0.05, 1], [0.18, 1, 'lin'], [0.26, 0]] } });
  }
  if (k === 3 || k === 4) S.push({ id: 'spark', sprite: 'spark', at: 'C', t0: 0.06, t1: 0.24, z: 3, keys: { y: [[0.06, -64]], s: [[0.06, 0, 'back_out'], [0.14, 1.3, 'quad_in'], [0.24, 0]], r: [[0.06, 0], [0.24, 90]] } });
  return { id: 'coin_n' + k, kind: 'coin', streak: k, pip: 'pickup_coin', sprites: S,
    hud: { chip: 'coin', t0: 0.08, text: '+1', pill_scale: r(1 + 0.05 * (k - 1)), bump: r(1.08 + 0.02 * (k - 1)) } };
}
function seed(rar, twin) {
  const S = [], R3 = rar === 3, R2 = rar === 2;
  const peak = R3 ? 1.3 : R2 ? 1.2 : 1.12;
  const hop = (dx, dt, rot) => ({
    x: dx ? [[0.06 + dt, 0, 'quad_out'], [0.26 + dt, dx]] : undefined,
    y: R3 ? [[0, 0, 'quad_inout'], [0.06, 0, 'quad_inout'], [0.22, 10, 'quad_in'], [0.32, 58]] : [[0, 0, 'quad_inout'], [0.06 + dt, 0, 'quad_inout'], [0.26 + dt, 58]],
    sx: [[0, 1, 'quad_out'], [0.05, 0.82, 'quad_out'], [0.09, 1]], sy: [[0, 1, 'quad_out'], [0.05, 1.28, 'quad_out'], [0.09, 1]],
    s: R3 ? [[0.06, 1, 'quad_out'], [0.15, peak, 'lin'], [0.22, peak - 0.05, 'quad_in'], [0.32, 0.45]] : [[0.06 + dt, 1, 'quad_out'], [0.16 + dt, peak, 'quad_in'], [0.26 + dt, 0.45]],
    r: [[0.06 + dt, 0], [(R3 ? 0.32 : 0.26) + dt, rot]],
    a: R3 ? [[0, 1], [0.31, 1, 'lin'], [0.34, 0]] : [[0, 1], [0.24 + dt, 1, 'lin'], [0.28 + dt, 0]] });
  const clean = o => { for (const q in o) if (!o[q]) delete o[q]; return o; };
  S.push({ id: 'sapling', sprite: 'sapling', own: true, at: 'C', t0: 0, t1: R3 ? 0.34 : 0.28, z: 3, frame: R3 && !twin ? [[0, 'sapling'], [0.12, 'bloom']] : [[0, 'sapling']], keys: clean(hop(twin ? -24 : 0, 0, -20)) });
  if (twin) S.push({ id: 'sapling_b', sprite: 'sapling', at: 'C', t0: 0, t1: 0.32, z: 3, frame: [[0, 'sapling']], keys: clean(hop(24, 0.04, 20)) });
  S.push({ id: 'soil', sprite: 'soil', own: true, at: 'C', t0: 0, t1: 0.22, z: 1, keys: { y: [[0, 18]], s: [[0, 1, 'quad_out'], [0.06, 1.14, 'quad_in'], [0.2, 0.55]], a: [[0, 1], [0.12, 1, 'lin'], [0.22, 0]] } });
  const nCrumb = twin ? (rar > 1 ? 0 : 2) : rar === 1 ? 3 : 1, cang = [-150, -30, 90];
  for (let i = 0; i < nCrumb; i++) { const a = cang[i] * Math.PI / 180;
    S.push({ id: 'crumb' + i, sprite: 'crumb', at: 'C', t0: 0.03, t1: 0.22, z: 2, keys: { x: [[0.03, 0, 'quad_out'], [0.22, r(Math.cos(a) * 38)]], y: [[0.03, 18, 'quad_out'], [0.22, r(18 + Math.sin(a) * 30)]], s: [[0.03, 1], [0.22, 0.4]], a: [[0.03, 1], [0.16, 1, 'lin'], [0.22, 0]] } }); }
  if (rar > 1) S.push({ id: 'halo', sprite: R3 ? 'halo3' : 'halo2', own: true, at: 'C', t0: 0, t1: 0.2, z: 0, keys: { y: [[0, -36]], s: [[0, 1, 'quad_out'], [0.2, 1.8]], r: [[0, 0], [0.2, R3 ? -45 : 60]], a: [[0, 1], [0.1, 1, 'quad_in'], [0.2, 0]] } });
  if (rar > 1 && !twin) [-1, 1].forEach((sg, i) => S.push({ id: 'spark' + i, sprite: 'spark', at: 'C', t0: 0.04, t1: 0.26, z: 4,
    keys: { x: [[0.04, 0, 'quad_out'], [0.26, sg * (R3 ? 56 : 46)]], y: [[0.04, -20, 'quad_out'], [0.26, R3 ? -78 : -60]], s: [[0.04, 0, 'back_out'], [0.12, R3 ? 1.3 : 1.1, 'quad_in'], [0.26, 0]], r: [[0.04, 0], [0.26, sg * 120]] } }));
  if (twin) S.push({ id: 'stamp', sprite: 'stamp_x2', at: 'C', t0: 0.08, t1: 0.38, z: 5, keys: { y: [[0.08, -64, 'quad_out'], [0.38, -84]], s: [[0.08, 0, 'back_out'], [0.18, 1, 'lin'], [0.3, 1, 'quad_in'], [0.38, 0]], r: [[0.08, -20, 'back_out'], [0.18, 0]] } });
  const rt0 = R3 ? 0.3 : twin ? 0.26 : R2 ? 0.26 : 0.24, rt1 = R3 ? 0.4 : rt0 + 0.12;
  S.push({ id: 'ring', sprite: R3 ? 'ring_gold' : R2 ? 'ring_lav' : 'ring_mint', at: 'B', t0: rt0, t1: rt1, z: 1, keys: { s: [[rt0, 0.3, 'quad_out'], [rt1, R3 ? 1 : 0.8]], a: [[rt0, 1], [rt0 + 0.05, 1, 'quad_in'], [rt1, 0]] } });
  return { id: 'seed_r' + rar + (twin ? '_twin' : ''), kind: 'seed', rarity: rar, twin: !!twin,
    pip: twin ? 'pickup_twin' : rar > 1 ? 'pickup_seed_rare' : 'pickup_seed', sprites: S,
    hud: { chip: 'seed', t0: R3 ? 0.1 : 0.06, text: twin ? '+2' : '+1', pill_scale: R3 ? 1.12 : 1, bump: twin ? 1.16 : R3 ? 1.14 : 1.1 } };
}
function r(v) { return Math.round(v * 100) / 100; }
function len(ev) { return r(Math.max(...ev.sprites.map(s => s.t1), ev.hud.t0 + HUD.flight.dur)); }
const EVENTS = {};
[1, 2, 3, 4, 5].forEach(n => { const e = coin(n); EVENTS[e.id] = e; });
[1, 2, 3].forEach(rr => { const a = seed(rr, false), b = seed(rr, true); EVENTS[a.id] = a; EVENTS[b.id] = b; });
for (const id in EVENTS) { const e = EVENTS[id]; e.len = len(e); e.sprite_count = e.sprites.length + 1; } // +1 = HUD pill
const PIP_PRIORITY = { pickup_coin: 0, pickup_seed: 1, pickup_twin: 2, pickup_seed_rare: 3 };
G.PickupData = { KIT, INK, PIP_Y, LANES, ANCHOR, SPRITES, MAGNET, IDLE, HUD, STREAK, EVENTS, PIP_PRIORITY,
  BUDGET: { per_touch_sprites: 8, per_touch_sec: 0.4, concurrent_touches: 3, concurrent_sprites: 24, idle_pickups: 10, atlas: 512, svg_kb: 60, pip_anims: 4, camp_layers: 12 } };
})(typeof window !== 'undefined' ? window : globalThis);
