// Nibbs the seed-mole — the new Muncher. Art (SVG parts), cutout rig (front / side / back + nest),
// animations as data (same key format as Pip animations.json), a browser player that only moves nodes,
// and the exporter for godot/muncher_*.json + assets/muncher/**.svg.  1 frame px = 1 game px.
// Root = pest centre = eat centre (mouth). Needs pip_art.js (helpers) + pip_runtime.js (sample, ease).
(function boot(G) {
'use strict';
// helmet scripts load in any order: wait for dependencies
if (!(G.PipArt && G.PipArt.helpers && G.Pip && G.Pip.sample)) { setTimeout(() => boot(G), 15); return; }
const { P, E, S, fluff, star4, star5 } = G.PipArt.helpers, INK = '#2D3436', WHITE = '#FFFFFF', MOUTH = '#7A3B46', TONGUE = '#FF9FB4';
const C = {
  fur: '#F4B286', fur_sh: '#D98C5E', fur_lt: '#FFE1C2', mask: '#6E4A66', mask_lt: '#8C6684', pink: '#FF9DB5', pink_sh: '#E67896', pink_lt: '#FFD0DC', claw: '#FFF3DF', cheek: '#FF9DB5',
  dirt: '#A9774F', dirt_sh: '#87593A', dirt_lt: '#C99868', hole: '#4A3226', pebble: '#C9C2B8', sprout: '#8FCB7E', sprout_sh: '#5E9D6A',
  ice: '#CFEFFF', ice_edge: '#6FB6DE', ice_hi: '#FFFFFF', ice_sh: '#A9DCF5', star: '#FFD56B'
};
const SPR = {};
const spr = (name, frames, note) => { SPR[name] = { frames: typeof frames === 'function' ? { default: frames } : frames, note: note || '' }; };

// ── FRONT (body-local, body centre 0,0; mouth at (0,10))
const BEAN = 'M 0 -54 C 34 -54 58 -32 58 -2 C 58 30 34 50 0 50 C -34 50 -58 30 -58 -2 C -58 -32 -34 -54 0 -54 Z';
const MASK_F = 'M -55 -34 C -30 -44 30 -44 55 -34 C 58 -26 58 -14 56 -6 C 30 -15 -30 -15 -56 -6 C -58 -14 -58 -26 -55 -34 Z';
const COWLICK = 'M -10 -52 C -14 -64 -5 -70 -2 -60 C 0 -72 12 -70 9 -52';
spr('m_body_f', () => P(BEAN, C.fur) + P('M 36 -42 C 52 -28 58 -12 58 -2 C 58 30 34 50 0 50 C 30 40 46 22 48 -2 C 49 -18 44 -32 36 -42 Z', C.fur_sh) +
  P('M -32 10 C -32 -6 -16 -10 0 -10 C 16 -10 32 -6 32 10 C 32 32 16 44 0 44 C -16 44 -32 32 -32 10 Z', C.fur_lt) +
  P(MASK_F, C.mask) + S('M -46 -34 C -24 -40 -6 -41 6 -41', 3, C.mask_lt) + P(MASK_F, 'none', 3) +
  E(-38, 8, 8, 5, C.cheek) + E(38, 8, 8, 5, C.cheek) + P(COWLICK + ' Z', C.fur) + S(COWLICK, 3) + P(BEAN, 'none', 3), 'bean body + bandit mask + muzzle');
spr('m_ear', () => E(0, 0, 11, 10, C.fur, 3) + E(0, 1.5, 5.5, 5, C.pink));
spr('m_knot', () => P('M 0 -4 C 10 -14 22 -12 26 -4 C 18 -2 10 0 0 4 Z', C.mask, 2.6) + P('M 0 2 C 8 6 14 16 12 26 C 6 20 2 12 -2 6 Z', C.mask, 2.6) + E(0, 0, 6, 6, C.mask, 2.6), 'mask knot tails (flutter)');
spr('m_nose', () => { let s = ''; for (let i = 0; i < 6; i++) { const a = -Math.PI / 2 + i * Math.PI / 3; s += E((Math.cos(a) * 7).toFixed(1), (Math.sin(a) * 6).toFixed(1), 5.4, 5, C.pink); }
  return s + S('M -11 -4 C -12 -10 -6 -12 -3 -10 C -1 -13 4 -13 6 -10 C 10 -12 13 -8 11 -3 C 14 1 12 7 7 7 C 4 10 -4 10 -7 7 C -12 7 -14 1 -11 -4 Z', 2.6) + E(0, -1, 4, 3.4, C.pink_lt) + E(-3, -3, 1.6, 1.4, WHITE); }, 'flower nose (star-nosed mole)');
const EYE = {
  open: () => E(0, 0, 11, 13, WHITE, 2.8) + E(1.5, 1.5, 6.5, 8, INK) + E(-0.5, -2.5, 2.6, 2.8, WHITE) + E(4, 5, 1.2, 1.2, WHITE) + S('M -11 -22 L 9 -15', 4.6),
  sly: () => E(0, 0, 11, 13, WHITE, 2.8) + E(4, 3, 6, 7, INK) + E(2.5, 0, 2.2, 2.4, WHITE) + P('M -11 -1 C -10 -12 10 -12 11 -1 L 11 -3 C 6 -14 -6 -14 -11 -3 Z', C.mask) + S('M -11.5 -1 L 11.5 -1', 3.2) + S('M -11 -20 L 9 -13', 4.6),
  wide: () => E(0, -1, 12.5, 15, WHITE, 2.8) + E(0, 0, 4.5, 5.5, INK) + E(-1.4, -1.8, 1.6, 1.8, WHITE) + S('M -10 -27 Q 0 -32 10 -26', 4.2),
  closed: () => S('M -10 1 Q 0 8 10 1', 3.8),
  happy: () => S('M -10 4 Q 0 -8 10 4', 3.8) + S('M -10 -18 Q 0 -22 10 -17', 3.6),
  squeeze: () => S('M 9 -7 L -7 0 L 9 7', 3.8) + S('M -11 -19 L 9 -12', 4.6),
  frozen: () => E(0, 0, 11, 13, WHITE, 2.8) + E(0, 1, 3.4, 4, INK) + S('M -10 -16 L 9 -23', 4.2),
  annoyed: () => E(0, 0, 11, 13, WHITE, 2.8) + E(1, 3, 6, 7, INK) + E(-0.5, 1, 2, 2, WHITE) + P('M -11 -2 C -10 -13 10 -13 11 -2 L 11 -4 C 6 -15 -6 -15 -11 -4 Z', C.mask) + S('M -11.5 -2 L 11.5 -2', 3.2) + S('M -12 -18 L 10 -9', 5)
};
spr('m_eye', EYE, 'swap: eye + brow in one frame; R = scale.x −1');
const MO = {
  grin: () => P('M -16 -2 Q 0 6 16 -2 Q 12 12 0 12 Q -12 12 -16 -2 Z', MOUTH, 2.6) + P('M -6.5 1.5 L -0.5 2.4 L -0.5 9 L -6.5 9 Z', WHITE, 2) + P('M 0.5 2.4 L 6.5 1.5 L 6.5 9 L 0.5 9 Z', WHITE, 2),
  smug: () => S('M -14 2 Q -2 8 14 -4', 3) + P('M -5 4.5 L 0.5 5 L 0.5 11 L -5 11 Z', WHITE, 2) + P('M 1.5 5 L 7 4 L 7 10 L 1.5 11 Z', WHITE, 2),
  chomp_open: () => E(0, 4, 17, 15, MOUTH, 2.8) + E(0, 12, 9, 5, TONGUE) + P('M -8 -10.5 L -0.8 -10.8 L -0.8 -2 L -8 -2.5 Z', WHITE, 2) + P('M 0.8 -10.8 L 8 -10.5 L 8 -2.5 L 0.8 -2 Z', WHITE, 2),
  chomp_shut: () => S('M -18 2 Q 0 9 18 2', 3) + P('M -7 4.5 L -0.6 5.8 L -0.6 12 L -7 11 Z', WHITE, 2) + P('M 0.6 5.8 L 7 4.5 L 7 11 L 0.6 12 Z', WHITE, 2) + E(-24, 0, 5, 4, C.cheek) + E(24, 0, 5, 4, C.cheek),
  snore: () => E(0, 3, 4.5, 4, MOUTH, 2.4) + P('M 3 -1 L 8 -1 L 8 5 L 3 5 Z', WHITE, 1.8),
  o: () => E(0, 4, 8, 9, MOUTH, 2.6) + P('M -4 -4.5 L 4 -4.5 L 4 1 L -4 1 Z', WHITE, 1.8),
  chatter: () => P('M -14 0 L 14 0 L 14 9 L -14 9 Z', MOUTH, 2.6) + S('M -13 4.5 L -9 1 L -5 8 L -1 1 L 3 8 L 7 1 L 11 8 L 13 4.5', 2.2, WHITE),
  pout: () => S('M -12 8 Q 0 0 12 8', 3) + P('M -5 3.5 L -0.5 3 L -0.5 9 L -5 9.5 Z', WHITE, 2) + P('M 0.5 3 L 5 3.5 L 5 9.5 L 0.5 9 Z', WHITE, 2),
  yawn: () => E(0, 5, 11, 14, MOUTH, 2.8) + E(0, 12, 6, 4, TONGUE) + P('M -5 -8.5 L -0.5 -8.8 L -0.5 -3 L -5 -3.3 Z', WHITE, 1.8) + P('M 0.5 -8.8 L 5 -8.5 L 5 -3.3 L 0.5 -3 Z', WHITE, 1.8)
};
spr('m_mouth', MO, 'swap: buck teeth always visible — the "muncher" read');
const PAW = 'M -12 -6 C -12 -14 12 -14 12 -6 C 14 2 12 10 8 14 C 6 18 -6 18 -8 14 C -12 10 -14 2 -12 -6 Z';
spr('m_paw', () => P(PAW, C.pink) + P('M 6 -11 C 12 -6 14 2 12 9 C 10 14 6 16 2 17 C 8 10 9 0 6 -11 Z', C.pink_sh) + P(PAW, 'none', 3) +
  P('M -8 14 C -10 20 -8 24 -5 23 C -3 22 -3 18 -4 15 Z', C.claw, 2.2) + P('M -2 16 C -3 23 0 26 2 25 C 4 24 4 20 2 16 Z', C.claw, 2.2) + P('M 4 15 C 4 21 7 24 9 22 C 10 20 9 16 7 13 Z', C.claw, 2.2), 'digging paw, 3 claws');
spr('m_foot', () => E(0, 0, 13, 8, C.pink, 3) + S('M -5 6 L -5 3 M 0 7 L 0 4 M 5 6 L 5 3', 2));
spr('m_tail', () => P('M -5 0 C -6 10 -2 18 2 20 C 6 18 7 10 5 0 Z', C.pink, 2.6));

// ── SIDE (facing right; body centre 0,0; mouth at (46,12))
const BEAN_S = 'M -62 2 C -62 -30 -36 -48 -2 -48 C 30 -48 50 -32 58 -14 C 66 -12 72 -6 70 4 C 68 12 60 16 52 16 C 42 38 20 48 -6 48 C -40 48 -62 32 -62 2 Z';
const MASK_S = 'M -32 -40 C -2 -46 40 -38 58 -16 C 56 -10 52 -6 48 -4 C 34 -16 8 -22 -34 -20 C -36 -28 -36 -34 -32 -40 Z';
spr('m_body_s', () => P(BEAN_S, C.fur) + P('M -60 12 C -54 34 -34 48 -6 48 C 20 48 42 38 52 16 C 34 30 -20 38 -60 12 Z', C.fur_sh) +
  P('M 16 6 C 24 -4 40 -6 52 2 C 56 10 52 16 52 16 C 44 34 30 42 14 42 C 6 32 8 16 16 6 Z', C.fur_lt) + P(MASK_S, C.mask) + P(MASK_S, 'none', 3) +
  E(28, 8, 7, 4.5, C.cheek) + P('M -6 -46 C -8 -58 2 -62 4 -54 C 8 -64 18 -60 14 -46 Z', C.fur) + S('M -6 -46 C -8 -58 2 -62 4 -54 C 8 -64 18 -60 14 -46', 3) + P(BEAN_S, 'none', 3) +
  S('M -40 -20 C -30 -30 -18 -34 -6 -34', 2.6, C.fur_sh), 'side');
spr('m_nose_s', () => E(0, 0, 8, 9, C.pink, 2.6) + E(5, -6, 4.5, 4, C.pink, 2.2) + E(6, 5, 4.5, 4, C.pink, 2.2) + E(0, 0, 3, 3.4, C.pink_lt) + E(-1, -2, 1.4, 1.4, WHITE));
// ── BACK
spr('m_body_b', () => P(BEAN, C.fur) + P('M 36 -42 C 52 -28 58 -12 58 -2 C 58 30 34 50 0 50 C 30 40 46 22 48 -2 C 49 -18 44 -32 36 -42 Z', C.fur_sh) +
  P('M -56 -28 C -30 -36 30 -36 56 -28 L 57 -18 C 30 -26 -30 -26 -57 -18 Z', C.mask, 2.6) + S('M -30 4 C -20 -4 -8 -6 0 -6 M 30 4 C 20 -4 8 -6 0 -6 M -26 22 C -16 16 16 16 26 22', 2.6, C.fur_sh) +
  P(COWLICK + ' Z', C.fur) + S(COWLICK, 3) + P(BEAN, 'none', 3), 'back: mask strap, fur stripes');
spr('m_foot_b', () => E(0, 0, 12, 9, C.pink, 3) + E(0, 2, 6, 4, C.pink_sh) + E(-6, -4, 2.4, 2, C.pink_sh) + E(0, -5.5, 2.4, 2, C.pink_sh) + E(6, -4, 2.4, 2, C.pink_sh));
spr('m_shadow', () => E(0, 0, 54, 11, '#1A1A14', 0, 0, ' fill-opacity="0.18"'), 'ground shadow (alpha .18)');
// ── ICE (frame swap: ice → crack). 180 × 156, translucent flat fill so Nibbs reads inside.
const ICE = 'M -72 -78 L 72 -78 Q 90 -78 90 -60 L 90 58 Q 90 76 72 76 L -72 76 Q -90 76 -90 58 L -90 -60 Q -90 -78 -72 -78 Z';
const iceBase = () => P(ICE, C.ice, 4, C.ice_edge, ' fill-opacity="0.62"') +
  S('M -62 -58 L -40 -36 M -62 -34 L -52 -24', 7, C.ice_hi) + P('M -60 76 L -48 76 L -54 92 Z', C.ice_edge) + P('M -6 76 L 6 76 L 0 88 Z', C.ice_edge) + P('M 42 76 L 56 76 L 49 96 Z', C.ice_edge) +
  P(fluff(-46, -78, 10, 6, 3.2), WHITE, 2.4) + P(fluff(-12, -80, 13, 7, 3.4), WHITE, 2.4) + P(fluff(24, -78, 9, 6, 3), WHITE, 2.4) + P(star4(86, -66, 9), WHITE, 2) + P(star4(-92, 18, 7), WHITE, 2);
spr('m_ice', { ice: iceBase, crack: () => iceBase() + S('M -20 -78 L -8 -40 L -30 -10 L -12 24 M -8 -40 L 22 -28 L 40 6 M -30 -10 L -60 2 M 22 -28 L 60 -50 M -12 24 L 10 76', 3.4, INK) }, 'ice block (frozen 2 s) — frames ice / crack');
// ── NEST (molehill 270 × 124, separate scene: back under Nibbs, front lip over him while he sleeps in it)
spr('m_nest_back', () => E(0, 6, 135, 56, C.dirt, 3) + P('M 60 -40 C 100 -30 132 -10 135 6 C 134 24 110 40 80 50 C 110 30 118 4 60 -40 Z', C.dirt_sh) +
  S('M -100 -26 C -70 -44 -30 -50 0 -50', 4, C.dirt_lt) + E(0, 0, 84, 30, C.hole, 3) + E(0, 5, 74, 22, '#3A271D') +
  E(-112, -6, 7, 5, C.pebble, 2.2) + E(96, -26, 6, 4.5, C.pebble, 2.2) +
  S('M -64 -46 C -66 -60 -62 -70 -56 -76', 3.4, C.sprout_sh) + P('M -56 -76 C -46 -86 -32 -82 -30 -74 C -40 -70 -50 -70 -56 -76 Z', C.sprout, 2.4) + P('M -58 -66 C -72 -72 -80 -66 -80 -60 C -70 -58 -62 -60 -58 -66 Z', C.sprout, 2.4), 'molehill + hole + sprout');
const LIP = 'M -84 2 C -60 32 60 32 84 2 C 108 8 134 22 134 34 C 122 58 70 66 0 66 C -70 66 -122 58 -134 34 C -134 22 -108 8 -84 2 Z';
const husk = (x, y, r) => { const c = Math.cos(r), s = Math.sin(r), pt = (a, b) => (x + a * c - b * s).toFixed(1) + ' ' + (y + a * s + b * c).toFixed(1); return P('M ' + pt(-9, 0) + ' C ' + pt(-6, -6) + ' ' + pt(6, -6) + ' ' + pt(9, 0) + ' C ' + pt(6, 6) + ' ' + pt(-6, 6) + ' ' + pt(-9, 0) + ' Z', '#F3E7CF', 2.2) + S('M ' + pt(-5, 0) + ' L ' + pt(5, 0), 1.6, '#8C7A5A'); };
spr('m_nest_front', () => P(LIP, C.dirt) + P('M 84 2 C 108 8 134 22 134 34 C 122 58 70 66 0 66 C 70 56 110 42 84 2 Z', C.dirt_sh) + S('M -84 2 C -60 32 60 32 84 2', 3.4, C.hole) + P(LIP, 'none', 3) +
  S('M -96 30 C -70 46 -40 52 -14 54', 3.6, C.dirt_lt) + E(-74, 44, 7, 4.5, C.dirt_sh) + E(64, 50, 9, 5, C.dirt_sh) + E(108, 34, 5, 3.6, C.pebble, 2) + husk(-30, 50, .3) + husk(30, 54, -.5) + husk(46, 42, .9), 'front lip (covers his lower half in the nest) + stolen husks');
// ── FX (≤ 12 frames; all swap nodes)
const FX = {
  z: () => S('M -8 -8 L 8 -8 L -8 8 L 8 8', 9, INK) + S('M -8 -8 L 8 -8 L -8 8 L 8 8', 4.4, '#FFF8F0'),
  bang: () => { let d = ''; for (let i = 0; i < 16; i++) { const a = -Math.PI / 2 + i * Math.PI / 8, r = i % 2 ? 22 : 32; d += (i ? ' L ' : 'M ') + (Math.cos(a) * r).toFixed(1) + ' ' + (Math.sin(a) * r).toFixed(1); } return P(d + ' Z', C.star, 3.4) + P('M -4.5 -17 L 4.5 -17 L 2.5 5 L -2.5 5 Z', INK) + E(0, 12, 4, 4, INK); },
  crumb_a: () => P('M -7 -4 C -2 -8 6 -6 7 0 C 6 6 -4 7 -7 2 Z', '#FFE08A', 2.2),
  crumb_b: () => P('M -6 -5 L 6 -4 L 4 6 L -5 4 Z', '#FFCCD5', 2.2),
  crumb_c: () => E(0, 0, 5, 4.5, '#B8E0F5', 2.2),
  husk: () => husk(0, 0, 0),
  shard: () => P('M 0 -14 L 9 2 L 2 14 L -8 4 Z', C.ice, 2.6, C.ice_edge) + S('M -2 -6 L 2 2', 2.2, WHITE),
  puff: () => P(fluff(0, 0, 12, 7, 3.6), '#FFF8F0', 2.6),
  dirt: () => E(-6, 0, 6, 5, C.dirt, 2.2) + E(6, -4, 4.5, 4, C.dirt_sh, 2),
  spark: () => P(star4(0, 0, 11), '#FFEAA7', 2.2),
  sweat: () => P('M 0 -9 C 5 -2 7 2 7 5 C 7 9 4 11 0 11 C -4 11 -7 9 -7 5 C -7 2 -5 -2 0 -9 Z', '#B8E0F5', 2.2),
  star: () => P(star5(0, 0, 10), C.star, 2.2)
};
// "Muncher's awake!" banner plate (text = Godot Label, Nunito 900 44, ink on cream)
spr('m_banner', () => P('M -170 -34 L 170 -34 Q 186 -34 186 -18 L 186 18 Q 186 34 170 34 L -170 34 Q -186 34 -186 18 L -186 -18 Q -186 -34 -170 -34 Z', '#FFF8F0', 4) + P('M -186 -4 L -206 -14 L -198 6 L -206 24 L -186 16 Z', C.mask, 3) + P('M 186 -4 L 206 -14 L 198 6 L 206 24 L 186 16 Z', C.mask, 3), 'banner plate 412 × 72 (UI, not in the rig)');

// ── RIGS. Node: [id, parent, x, y, z, sprite, opts]
const N = (id, parent, x, y, z, sprite, o) => Object.assign({ id, parent, x, y, z, sprite, rot: 0, sx: 1, sy: 1 }, o || {});
const FXN = () => [N('ice', 'root', 0, -8, 30, 'm_ice', { swap: 'ice', hide: true }), N('emote', 'root', -58, -86, 40, 'fx', { hide: true }),
  N('fx_a', 'root', 0, 0, 35, 'fx', { hide: true }), N('fx_b', 'root', 0, 0, 35, 'fx', { hide: true }), N('fx_c', 'root', 0, 0, 35, 'fx', { hide: true }), N('fx_d', 'root', 0, 0, 35, 'fx', { hide: true })];
const RIGS = {
  front: { frame: [320, 300], origin: [160, 170], nodes: [
    N('root', null, 0, 0, 0, null), N('shadow', 'root', 0, 40, -50, 'm_shadow'), N('mole', 'root', 0, 38, 0, null),
    N('tail', 'mole', 0, -10, -8, 'm_tail', { hide: true }),
    N('foot_L', 'mole', -24, -4, 2, 'm_foot'), N('foot_R', 'mole', 24, -4, 2, 'm_foot', { sx: -1 }),
    N('body', 'mole', 0, -48, 0, 'm_body_f'),
    N('ear_L', 'body', -40, -40, -1, 'm_ear'), N('ear_R', 'body', 40, -40, -1, 'm_ear'),
    N('knot', 'body', 50, -26, -2, 'm_knot'),
    N('eye_L', 'body', -21, -22, 3, 'm_eye', { swap: 'eye' }), N('eye_R', 'body', 21, -22, 3, 'm_eye', { swap: 'eye', sx: -1 }),
    N('nose', 'body', 0, -4, 5, 'm_nose'), N('mouth', 'body', 0, 12, 4, 'm_mouth', { swap: 'mouth' }),
    N('paw_L', 'body', -48, 16, 6, 'm_paw', { rot: 14 }), N('paw_R', 'body', 48, 16, 6, 'm_paw', { sx: -1, rot: -14 }),
    ...FXN() ] },
  side: { frame: [320, 300], origin: [160, 170], nodes: [
    N('root', null, 0, 0, 0, null), N('shadow', 'root', -36, 40, -50, 'm_shadow', { sx: 1.18 }), N('mole', 'root', -46, 38, 0, null),
    N('tail', 'mole', -62, -40, -2, 'm_tail', { rot: 70 }),
    N('foot_L', 'mole', -30, -4, -1, 'm_foot', { sx: .9 }), N('foot_R', 'mole', -8, -2, 2, 'm_foot'),
    N('body', 'mole', 0, -48, 0, 'm_body_s'),
    N('ear_L', 'body', -10, -40, -1, 'm_ear', { sx: .8 }), N('ear_R', 'body', 6, -42, 1, 'm_ear', { sx: .8, hide: true }),
    N('knot', 'body', -32, -30, 2, 'm_knot', { sx: -1, rot: -10 }),
    N('eye_R', 'body', 30, -22, 3, 'm_eye', { swap: 'eye', sx: .82 }),
    N('nose', 'body', 70, 0, 5, 'm_nose_s'), N('mouth', 'body', 46, 12, 4, 'm_mouth', { swap: 'mouth', sx: .7 }),
    N('paw_L', 'body', 14, 32, -1, 'm_paw', { rot: -30, sx: .9 }), N('paw_R', 'body', 24, 32, 6, 'm_paw', { rot: -50 }),
    ...FXN() ] },
  back: { frame: [320, 300], origin: [160, 170], nodes: [
    N('root', null, 0, 0, 0, null), N('shadow', 'root', 0, 40, -50, 'm_shadow'), N('mole', 'root', 0, 38, 0, null),
    N('paw_L', 'mole', -52, -30, -1, 'm_paw', { rot: -10 }), N('paw_R', 'mole', 52, -30, -1, 'm_paw', { sx: -1, rot: 10 }),
    N('body', 'mole', 0, -48, 0, 'm_body_b'),
    N('foot_L', 'mole', -22, -2, 2, 'm_foot_b'), N('foot_R', 'mole', 22, -2, 2, 'm_foot_b'),
    N('tail', 'body', 0, 30, 3, 'm_tail'),
    N('ear_L', 'body', -40, -40, 1, 'm_ear'), N('ear_R', 'body', 40, -40, 1, 'm_ear'),
    N('knot', 'body', 0, -22, 4, 'm_knot', { rot: 60 }),
    ...FXN() ] }
};
const NEST = { frame: [300, 160], origin: [150, 86], nodes: [N('nest_back', null, 0, 0, -60, 'm_nest_back'), N('nest_front', null, 0, 0, 20, 'm_nest_front')] };

// ── faces: [eye_L, eye_R, mouth]
const FACE = { hunt: ['open', 'open', 'grin'], sly: ['sly', 'sly', 'smug'], wake: ['wide', 'wide', 'o'], sleep: ['closed', 'closed', 'snore'], bite: ['squeeze', 'squeeze', 'chomp_open'], chew: ['happy', 'happy', 'chomp_shut'],
  frozen: ['frozen', 'frozen', 'chatter'], annoyed: ['annoyed', 'annoyed', 'pout'], yawn: ['closed', 'closed', 'yawn'], happy: ['happy', 'happy', 'grin'] };
const FACE_NODES = ['eye_L', 'eye_R', 'mouth'];

// ── animations (same data model as Pip: deltas from rest, [t, v…, transition])
const L = 1, H = 0, O = .5, I = 2, IO = -2;
const ANIMS = {}, ORDER = [];
function mdef(id, len, meta, build) {
  const tracks = {}, events = [], ex = [];
  const b = { tracks, events,
    k(n, q, keys) { (tracks[n] = tracks[n] || {})[q] = keys; return b; },
    x(...a) { for (let i = 0; i < a.length; i += 2) ex.push([a[i], a[i + 1]]); return b; },
    ev(t, name, arg) { events.push([t, name, arg == null ? null : arg]); return b; },
    fx(n, frame, keys) { const ls = ['p', 's', 'a', 'r'].filter(q => keys[q]).map(q => keys[q]); const t0 = Math.min(...ls.map(k => k[0][0])), t1 = keys.end != null ? keys.end : Math.max(...ls.map(k => k[k.length - 1][0]));
      const tr = tracks[n] = tracks[n] || {}; tr.v = [[0, 0], [t0, 1], [t1, 0]]; tr.f = [[0, frame]]; ['p', 's', 'r', 'a'].forEach(q => { if (keys[q]) tr[q] = keys[q]; }); return b; } };
  build(b);
  if (ex.length) FACE_NODES.forEach((n, i) => { const tr = tracks[n] = tracks[n] || {}; if (!tr.f) tr.f = ex.map(([t, e]) => [t, (FACE[e] || FACE.hunt)[i]]); });
  const a = Object.assign({ id, len, loop: false, layer: 'base', view: 'front', state: '', desc: '', rm: { type: 'damp', k: .3 } }, meta, { tracks, events });
  ANIMS[id] = a; ORDER.push(id); return a;
}
const osc = (t0, amp, per) => [[t0, 0], [t0 + per * .5, amp], [t0 + per, -amp * .5], [t0 + per * 1.5, amp * .22], [t0 + per * 2, 0]];
const cat = (...ls) => [].concat(...ls).sort((a, b) => a[0] - b[0]);
const zzz = (b, len) => [['fx_a', 0], ['fx_b', len / 3], ['fx_c', len * 2 / 3]].forEach(([n, t0], i) => {
  const t1 = t0 + len * .6; const tr = b.tracks[n] = {}; tr.f = [[0, 'z']]; tr.v = t0 ? [[0, 0], [t0, 1], [t1, 0]] : [[0, 1], [t1, 0]];
  tr.p = [[t0, 34, -46, L], [t1, 62 + i * 4, -104]]; tr.s = [[t0, .45, .45, O], [t0 + .3, .8 + i * .1, .8 + i * .1], [t1, 1, 1]]; tr.a = [[t0, 1], [t1 - .25, 1], [t1, 0]]; });
// SLEEP (loop) — in the nest he sits 24 px lower so the front lip covers his belly
[['m_sleep_nest', 18, 'Asleep in the nest: curled, breathing, mask knot droops, zzz rising. Front lip of the nest covers his lower half.'], ['m_sleep_spot', 4, 'Asleep on the spot (field empty): same loop, on the grass with his shadow.']].forEach(([id, dy, desc]) => mdef(id, 2.8, { loop: true, state: id === 'm_sleep_nest' ? 'SLEEPING_NEST' : 'SLEEPING_SPOT', desc, rm: { type: 'expr' } }, b => {
  b.k('mole', 'p', [[0, 0, dy]]); b.k('mole', 's', [[0, 1.04, .94, IO], [1.4, 1.08, .9, IO], [2.8, 1.04, .94]]);
  b.k('body', 'r', [[0, -3, IO], [1.4, -1, IO], [2.8, -3]]);
  b.k('ear_L', 'r', [[0, -20]]); b.k('ear_R', 'r', [[0, 20]]); b.k('knot', 'r', [[0, 30, IO], [1.4, 36, IO], [2.8, 30]]);
  b.k('paw_L', 'p', [[0, 16, -8]]); b.k('paw_L', 'r', [[0, -30]]); b.k('paw_R', 'p', [[0, -16, -8]]); b.k('paw_R', 'r', [[0, 30]]);
  b.k('nose', 's', [[0, 1, 1, IO], [1.4, 1.1, 1.1, IO], [2.8, 1, 1]]);
  if (dy > 10) b.k('shadow', 'v', [[0, 0]]);
  zzz(b, 2.8); b.x(0, 'sleep');
}));
// WAKE (0.3 s = ARENA_PEST_WAKE_DELAY): pop + "!"
[['m_wake_nest', 18], ['m_wake_spot', 4]].forEach(([id, dy]) => mdef(id, .3, { state: 'WAKE_DELAY', hold: true, desc: 'Wakes (0.3 s): pops ' + (dy > 10 ? 'out of the hole, dirt flies' : 'up') + ', ears up, "!" burst.', rm: { type: 'expr', fx: true } }, b => {
  b.k('mole', 'p', [[0, 0, dy, O], [.14, 0, -16, I], [.3, 0, 0]]); b.k('mole', 's', [[0, 1.06, .9, O], [.12, .9, 1.14, O], [.24, 1.06, .95], [.3, 1, 1]]);
  b.k('ear_L', 'r', [[0, -20], [.12, 14, O], [.3, 0]]); b.k('ear_R', 'r', [[0, 20], [.12, -14, O], [.3, 0]]); b.k('knot', 'r', [[0, 30], [.14, -16, O], [.3, 0]]);
  b.fx('emote', 'bang', { s: [[0, .2, .2, O], [.12, 1.25, 1.25], [.22, 1, 1]], r: [[0, -20], [.12, 8], [.22, 0]], end: .3 });
  if (dy > 10) { b.fx('fx_a', 'dirt', { p: [[0, -40, 10, O], [.3, -86, -30]], end: .3 }); b.fx('fx_b', 'dirt', { p: [[0, 40, 10, O], [.3, 88, -24]], end: .3 }); b.fx('fx_c', 'dirt', { p: [[.04, 10, 14, O], [.3, 24, -62]], end: .3 }); }
  b.x(0, 'wake');
}));
mdef('m_awake', 1.4, { state: 'WAKE_DELAY (first time in session)', desc: '"Muncher\'s awake!": big stretch-yawn, rubs his paws together, sly grin. UI banner drops in above the nest (separate, 1.6 s).', rm: { type: 'expr' } }, b => {
  b.k('mole', 's', [[0, 1, 1], [.1, 1.06, .92, O], [.4, .9, 1.14, IO], [.62, 1.04, .96, O], [.74, 1, 1]]); b.k('mole', 'p', [[0, 0, 0], [.4, 0, -6], [.66, 0, 0]]);
  b.k('paw_L', 'r', [[0, 0], [.1, 0], [.36, 120, O], [.6, 120], [.74, -10], [.84, 0]]); b.k('paw_R', 'r', [[0, 0], [.1, 0], [.36, -120, O], [.6, -120], [.74, 10], [.84, 0]]);
  b.k('paw_L', 'p', [[0, 0, 0], [.36, -6, -40], [.6, -6, -40], [.74, 30, -6], [.84, 32, -8], [.94, 28, -4], [1.04, 32, -8], [1.14, 28, -4], [1.24, 32, -8], [1.4, 30, -6]]);
  b.k('paw_R', 'p', [[0, 0, 0], [.36, 6, -40], [.6, 6, -40], [.74, -30, -6], [.84, -32, -4], [.94, -28, -8], [1.04, -32, -4], [1.14, -28, -8], [1.24, -32, -4], [1.4, -30, -6]]);
  b.k('ear_L', 'r', [[0, 0], [.36, -10], [.7, 8, O], [.9, 0]]); b.k('ear_R', 'r', [[0, 0], [.36, 10], [.7, -8, O], [.9, 0]]);
  b.k('knot', 'r', cat([[0, 0]], osc(.7, -18, .2)));
  b.fx('fx_a', 'spark', { p: [[.8, 0, 22]], s: [[.8, .2, .2, O], [.94, 1, 1], [1.2, .3, .3]], end: 1.2 });
  b.x(0, 'wake', .12, 'yawn', .66, 'sly', 1.3, 'sly');
});
// HUNT loops per direction (waddle; 0.36 s cycle = 30.6 px at 85 px/s)
const huntLen = .36;
mdef('m_hunt_front', huntLen, { loop: true, view: 'front', state: 'HUNTING', dir: 'down', speed_px_s: 85, desc: 'Hunting, coming toward camera (down): waddle, paws dig the air, mask knot flaps.', rm: { type: 'damp', k: .3 } }, b => {
  const h = huntLen / 2;
  b.k('mole', 'r', [[0, -5, IO], [h, 5, IO], [huntLen, -5]]); b.k('mole', 'p', [[0, 0, 0, O], [h / 2, 0, -7, I], [h, 0, 0, O], [h * 1.5, 0, -7, I], [huntLen, 0, 0]]);
  b.k('mole', 's', [[0, 1.04, .96, O], [h / 2, .98, 1.03, I], [h, 1.04, .96, O], [h * 1.5, .98, 1.03, I], [huntLen, 1.04, .96]]);
  b.k('foot_L', 'p', [[0, 0, -6], [h, 0, 0], [huntLen, 0, -6]]); b.k('foot_R', 'p', [[0, 0, 0], [h, 0, -6], [huntLen, 0, 0]]);
  b.k('paw_L', 'r', [[0, -18, IO], [h, 18, IO], [huntLen, -18]]); b.k('paw_R', 'r', [[0, -18, IO], [h, 18, IO], [huntLen, -18]]);
  b.k('knot', 'r', [[0, -12], [h / 2, 10], [h, -12], [h * 1.5, 10], [huntLen, -12]]); b.k('ear_L', 'r', [[0, -6], [h, 6], [huntLen, -6]]); b.k('ear_R', 'r', [[0, 6], [h, -6], [huntLen, 6]]);
  b.x(0, 'hunt');
});
mdef('m_hunt_side', huntLen, { loop: true, view: 'side', state: 'HUNTING', dir: 'right (left = root scale.x −1)', speed_px_s: 85, desc: 'Hunting sideways: nose first, paws paddle, tail wags, knot streams behind.', rm: { type: 'damp', k: .3 } }, b => {
  const h = huntLen / 2;
  b.k('mole', 'r', [[0, 2, IO], [h, -3, IO], [huntLen, 2]]); b.k('mole', 'p', [[0, 0, 0, O], [h / 2, 0, -6, I], [h, 0, 0, O], [h * 1.5, 0, -6, I], [huntLen, 0, 0]]);
  b.k('foot_L', 'p', [[0, -6, -5], [h, 6, 0], [huntLen, -6, -5]]); b.k('foot_R', 'p', [[0, 6, 0], [h, -6, -5], [huntLen, 6, 0]]);
  b.k('paw_R', 'r', [[0, -30, IO], [h, 24, IO], [huntLen, -30]]); b.k('paw_L', 'r', [[0, 24, IO], [h, -30, IO], [huntLen, 24]]);
  b.k('knot', 'r', [[0, -14], [h / 2, 6], [h, -14], [h * 1.5, 6], [huntLen, -14]]); b.k('tail', 'r', [[0, -16], [h, 16], [huntLen, -16]]);
  b.k('nose', 's', [[0, 1, 1], [h / 2, 1.12, 1.12], [h, 1, 1], [h * 1.5, 1.12, 1.12], [huntLen, 1, 1]]);
  b.x(0, 'hunt');
});
mdef('m_hunt_back', huntLen, { loop: true, view: 'back', state: 'HUNTING', dir: 'up', speed_px_s: 85, desc: 'Hunting away from camera (up): rump waddle, soles flash, tail wags, knot flaps.', rm: { type: 'damp', k: .3 } }, b => {
  const h = huntLen / 2;
  b.k('mole', 'r', [[0, -5, IO], [h, 5, IO], [huntLen, -5]]); b.k('mole', 'p', [[0, 0, 0, O], [h / 2, 0, -7, I], [h, 0, 0, O], [h * 1.5, 0, -7, I], [huntLen, 0, 0]]);
  b.k('foot_L', 'p', [[0, 0, -8], [h, 0, 0], [huntLen, 0, -8]]); b.k('foot_R', 'p', [[0, 0, 0], [h, 0, -8], [huntLen, 0, 0]]);
  b.k('foot_L', 's', [[0, 1, 1.15], [h, 1, .8], [huntLen, 1, 1.15]]); b.k('foot_R', 's', [[0, 1, .8], [h, 1, 1.15], [huntLen, 1, .8]]);
  b.k('paw_L', 'r', [[0, -14, IO], [h, 14, IO], [huntLen, -14]]); b.k('paw_R', 'r', [[0, -14, IO], [h, 14, IO], [huntLen, -14]]);
  b.k('tail', 'r', [[0, -22], [h, 22], [huntLen, -22]]); b.k('knot', 'r', [[0, -14], [h / 2, 10], [h, -14], [h * 1.5, 10], [huntLen, -14]]);
});
// EAT (0.5 s, 2 bites of 0.25 s; loops while EATING). Mouth = root = eat centre.
['front', 'side'].forEach(v => mdef('m_eat_' + v, .5, { loop: true, view: v, state: 'EATING', desc: 'Eating (0.5 s): two big bites, cheeks puff, crumbs fly from the mouth.', rm: { type: 'expr' } }, b => {
  const dx = v === 'side' ? 1 : 0;
  b.k('mole', 's', [[0, 1, 1], [.06, .95, 1.06, O], [.12, 1.08, .92, O], [.25, 1, 1], [.31, .95, 1.06, O], [.37, 1.08, .92, O], [.5, 1, 1]]);
  b.k('mole', 'p', [[0, 0, 0], [.12, dx * 4, 4, O], [.25, 0, 0], [.37, dx * 4, 4, O], [.5, 0, 0]]);
  b.k('paw_L', 'p', [[0, v === 'side' ? 4 : 10, v === 'side' ? -2 : 6]]); b.k('paw_R', 'p', [[0, v === 'side' ? 2 : -10, v === 'side' ? -4 : 6]]); b.k('paw_L', 'r', [[0, v === 'side' ? -20 : 46]]); b.k('paw_R', 'r', [[0, v === 'side' ? -24 : -46]]);
  b.k('ear_L', 'r', [[0, 0], [.12, -10], [.25, 0], [.37, -10], [.5, 0]]); b.k('ear_R', 'r', [[0, 0], [.12, 10], [.25, 0], [.37, 10], [.5, 0]]);
  const ox = v === 'side' ? 6 : 0;
  b.fx('fx_a', 'crumb_a', { p: [[.12, ox, 6, O], [.34, ox - 44, 30]], r: [[.12, 0], [.34, -90]], end: .34 });
  b.fx('fx_b', 'crumb_b', { p: [[.14, ox, 6, O], [.38, ox + 46, 24]], r: [[.14, 0], [.38, 120]], end: .38 });
  b.fx('fx_c', 'crumb_c', { p: [[.37, ox, 6, O], [.5, ox - 26, 40]], end: .5 });
  b.fx('fx_d', 'husk', { p: [[.37, ox, 6, O], [.5, ox + 30, 36]], r: [[.37, 0], [.5, 140]], end: .5 });
  b.x(0, 'bite', .12, 'chew', .25, 'bite', .37, 'chew');
}));
// FROZEN (T3 → 2 s) : in 0.18 s, shiver loop, thaw 0.25 s
mdef('m_freeze', .18, { state: 'FROZEN (in)', hold: true, desc: 'T3 merge: ice slams shut (0.18 s back-out), he stiffens mid-step.', rm: { type: 'end' } }, b => {
  b.k('ice', 'v', [[0, 1]]); b.k('ice', 'f', [[0, 'ice']]); b.k('ice', 's', [[0, .8, .8, O], [.12, 1.06, 1.06], [.18, 1, 1]]);
  b.k('mole', 's', [[0, 1, 1], [.1, .94, 1.08], [.18, .96, 1.05]]); b.k('ear_L', 'r', [[0, 0], [.18, 16]]); b.k('ear_R', 'r', [[0, 0], [.18, -16]]);
  b.k('paw_L', 'r', [[0, 0], [.18, 60]]); b.k('paw_R', 'r', [[0, 0], [.18, -60]]); b.k('knot', 'r', [[0, 0], [.18, -30]]);
  b.x(0, 'frozen');
});
mdef('m_frozen', .4, { loop: true, state: 'FROZEN', desc: 'Frozen (until 2 s): tiny shiver inside the ice, teeth chatter.', rm: { type: 'expr' } }, b => {
  b.k('ice', 'v', [[0, 1]]); b.k('ice', 'f', [[0, 'ice']]);
  b.k('mole', 's', [[0, .96, 1.05]]); b.k('mole', 'p', [[0, -1.5, 0, H], [.05, 1.5, 0, H], [.1, -1.5, 0, H], [.15, 1.5, 0, H], [.2, 0, 0, H], [.4, 0, 0]]);
  b.k('ear_L', 'r', [[0, 16]]); b.k('ear_R', 'r', [[0, -16]]); b.k('paw_L', 'r', [[0, 60]]); b.k('paw_R', 'r', [[0, -60]]); b.k('knot', 'r', [[0, -30]]);
  b.k('mouth', 'p', [[0, 0, 0, H], [.05, 0, 1.5, H], [.1, 0, 0, H], [.15, 0, 1.5, H], [.2, 0, 0]]);
  b.x(0, 'frozen');
});
mdef('m_thaw', .25, { state: 'FROZEN (out)', desc: 'Thaw (0.25 s): ice cracks, bursts into 4 shards, he shakes it off and resumes the hunt.', rm: { type: 'expr', fx: false } }, b => {
  b.k('ice', 'v', [[0, 1], [.08, 0]]); b.k('ice', 'f', [[0, 'crack']]);
  [['fx_a', -60, -60, -120, -110], ['fx_b', 60, -60, 120, -100], ['fx_c', -60, 40, -110, 70], ['fx_d', 60, 40, 116, 76]].forEach(([n, x0, y0, x1, y1]) => b.fx(n, 'shard', { p: [[.08, x0, y0, O], [.25, x1, y1]], r: [[.08, 0], [.25, x1 > 0 ? 160 : -160]], a: [[.18, 1], [.25, 0]], end: .25 }));
  b.k('mole', 'r', cat([[0, 0]], osc(.08, 10, .08))); b.k('mole', 's', [[0, .96, 1.05], [.1, 1.08, .94, O], [.2, 1, 1]]);
  b.k('ear_L', 'r', [[0, 16], [.1, -14, O], [.25, 0]]); b.k('ear_R', 'r', [[0, -16], [.1, 14, O], [.25, 0]]); b.k('paw_L', 'r', [[0, 60], [.2, 0]]); b.k('paw_R', 'r', [[0, -60], [.2, 0]]); b.k('knot', 'r', [[0, -30], [.14, 20], [.25, 0]]);
  b.x(0, 'wake', .16, 'annoyed');
});
mdef('m_doze', .9, { state: 'SLEEPING_SPOT (in)', hold: true, desc: 'Field is empty: big yawn, stretch, slumps down where he stands — then m_sleep_spot.', rm: { type: 'end' } }, b => {
  b.k('mole', 's', [[0, 1, 1], [.3, .92, 1.1, IO], [.5, .94, 1.08], [.78, 1.06, .92, O], [.9, 1.04, .94]]); b.k('mole', 'p', [[0, 0, 0], [.3, 0, -4], [.78, 0, 4], [.9, 0, 4]]);
  b.k('paw_L', 'r', [[0, 0], [.3, 110, O], [.5, 110], [.8, -30]]); b.k('paw_R', 'r', [[0, 0], [.3, -110, O], [.5, -110], [.8, 30]]);
  b.k('paw_L', 'p', [[0, 0, 0], [.3, -4, -36], [.5, -4, -36], [.8, 16, -8]]); b.k('paw_R', 'p', [[0, 0, 0], [.3, 4, -36], [.5, 4, -36], [.8, -16, -8]]);
  b.k('ear_L', 'r', [[0, 0], [.8, -20]]); b.k('ear_R', 'r', [[0, 0], [.8, 20]]); b.k('knot', 'r', [[0, 0], [.9, 30]]); b.k('body', 'r', [[0, 0], [.8, -3]]);
  b.x(0, 'hunt', .14, 'yawn', .6, 'sleep');
});
['front', 'side'].forEach(v => mdef('m_escaped_' + v, .8, { view: v, state: 'HUNTING (target merged away)', desc: 'His seed got merged before he reached it: stops, stomps, paws up, "hmph" puff — then picks a new target.', rm: { type: 'expr', fx: false } }, b => {
  b.k('mole', 'p', [[0, 0, 0], [.1, 0, 0, O], [.22, 0, -14, I], [.32, 0, 0], [.8, 0, 0]]); b.k('mole', 's', [[0, 1, 1], [.1, 1.06, .92, O], [.18, .94, 1.08], [.32, 1.12, .88, O], [.44, 1, 1]]);
  b.k('foot_R', 'p', [[0, 0, 0], [.22, 0, -6], [.32, 0, 0], [.44, 0, -8], [.52, 0, 0]]);
  b.k('paw_L', 'r', [[0, 0], [.18, v === 'side' ? -100 : 70, O], [.6, v === 'side' ? -100 : 70], [.8, 0]]); b.k('paw_R', 'r', [[0, 0], [.18, v === 'side' ? -120 : -70, O], [.6, v === 'side' ? -120 : -70], [.8, 0]]);
  b.k('ear_L', 'r', cat([[0, 0]], osc(.32, -14, .1))); b.k('ear_R', 'r', cat([[0, 0]], osc(.32, 14, .1))); b.k('knot', 'r', cat([[0, 0]], osc(.32, 20, .12)));
  b.fx('fx_a', 'puff', { p: [[.34, 44, -62, O], [.64, 64, -84]], s: [[.34, .3, .3, O], [.5, 1, 1], [.64, 1.1, 1.1]], a: [[.52, 1], [.64, 0]], end: .64 });
  b.fx('fx_b', 'puff', { p: [[.38, -44, -62, O], [.68, -64, -84]], s: [[.38, .3, .3, O], [.54, .9, .9], [.68, 1, 1]], a: [[.56, 1], [.68, 0]], end: .68 });
  b.x(0, 'wake', .18, 'annoyed', .74, 'hunt');
}));

// ── state → animation table (game code keeps every rule; it only picks clips)
const STATES = {
  SLEEPING_NEST: { loop: 'm_sleep_nest', view: 'front', nest_front_over: true },
  WAKE_DELAY: { enter: 'm_wake_nest | m_wake_spot (0.3 s = ARENA_PEST_WAKE_DELAY)', first_in_session: 'm_awake + UI banner "Muncher\'s awake!"' },
  HUNTING: { loop_by_dir: { down: 'm_hunt_front', up: 'm_hunt_back', right: 'm_hunt_side', left: 'm_hunt_side + root.scale.x = −1' }, dir_rule: '|dx| ≥ 0.8·|dy| → side, else dy > 0 → front, dy < 0 → back; re-evaluated with the target (0.25 s), min 0.2 s per view', on_target_merged: 'm_escaped_front | m_escaped_side (overlay of 0.8 s, he keeps the rules: new target at once)' },
  EATING: { loop: 'm_eat_front | m_eat_side (side when hunting sideways, otherwise front)', len_s: .5, bites: 2 },
  FROZEN: { enter: 'm_freeze (0.18 s)', loop: 'm_frozen', exit: 'm_thaw (0.25 s)', total_s: 2 },
  SLEEPING_SPOT: { enter: 'm_doze (0.9 s)', loop: 'm_sleep_spot' }
};

// ── player (same model as Pip: rest pose × keyed deltas, sprites never redrawn)
const mul = (m, n) => [m[0] * n[0] + m[2] * n[1], m[1] * n[0] + m[3] * n[1], m[0] * n[2] + m[2] * n[3], m[1] * n[2] + m[3] * n[3], m[0] * n[4] + m[2] * n[5] + m[4], m[1] * n[4] + m[3] * n[5] + m[5]];
const loc = (x, y, r, sx, sy) => { const c = Math.cos(r * Math.PI / 180), s = Math.sin(r * Math.PI / 180); return [c * sx, s * sx, -s * sy, c * sy, x, y]; };
const r3 = v => Math.round(v * 1000) / 1000;
function prep(rig) { if (!rig.map) { rig.map = {}; rig.nodes.forEach(n => rig.map[n.id] = n); } return rig; }
function abz(rig, n) { let z = 0, c = n; while (c) { z += c.z; c = c.parent ? rig.map[c.parent] : null; } return z; }
class MInst {
  constructor(el, o) { this.el = el; this.o = Object.assign({ view: 'front', size: 320, flip: false, rig: null }, o); this.base = null; this.over = null; this.speed = 1; this.listeners = []; this.build(); }
  build() {
    const rig = prep(this.o.rig || RIGS[this.o.view]); this.rig = rig; const ns = 'http://www.w3.org/2000/svg', fr = rig.frame;
    const svg = document.createElementNS(ns, 'svg'); svg.setAttribute('viewBox', '0 0 ' + fr[0] + ' ' + fr[1]); svg.setAttribute('width', this.o.size); svg.setAttribute('height', this.o.size * fr[1] / fr[0]); svg.style.cssText = 'overflow:visible;display:block';
    const list = rig.nodes.filter(n => n.sprite && (!this.o.only || this.o.only.includes(n.id))).map((n, i) => ({ n, i, z: abz(rig, n) })).sort((a, b) => a.z - b.z || a.i - b.i);
    this.els = {}; this.cur = {};
    for (const { n } of list) { const g = document.createElementNS(ns, 'g');
      if (n.sprite !== 'fx') { const sp = SPR[n.sprite], names = Object.keys(sp.frames); g.innerHTML = names.length === 1 ? sp.frames[names[0]]() : names.map(f => '<g data-f="' + f + '" style="display:none">' + sp.frames[f]() + '</g>').join(''); }
      svg.appendChild(g); this.els[n.id] = g; }
    this.el.innerHTML = ''; this.el.appendChild(svg); this.svg = svg; this.render();
  }
  set(o) { const rb = ('view' in o && o.view !== this.o.view) || ('size' in o && o.size !== this.o.size); Object.assign(this.o, o); if (rb) this.build(); else this.render(); }
  on(fn) { this.listeners.push(fn); return this; }
  play(id, opt) { const a = ANIMS[id]; if (!a) { console.warn('Muncher: no anim', id); return this; } opt = opt || {}; const rm = G.Muncher.reduceMotion;
    if (a.view && RIGS[a.view] && a.view !== this.o.view && !this.o.rig) this.set({ view: a.view });
    const st = { a, t: rm && a.rm && a.rm.type === 'end' ? a.len : 0, cb: opt.then, hold: opt.hold != null ? opt.hold : a.hold };
    if (opt.overlay) this.over = st; else this.base = st; return this; }
  tick(dt) {
    const step = st => { const pt = st.t; st.t += dt * this.speed; const a = st.a; let wrap = false; if (a.loop && st.t >= a.len) { st.t %= a.len; wrap = true; }
      a.events.forEach(([et, nm, arg]) => { if ((!wrap && pt < et && st.t >= et) || (wrap && (et > pt || et <= st.t))) this.listeners.forEach(f => f(nm, arg)); }); return !a.loop && st.t >= a.len; };
    if (this.base && step(this.base)) { if (this.base.hold) this.base.t = this.base.a.len; const cb = this.base.cb; this.base.cb = null; if (!this.base.hold) this.base = null; cb && cb(); }
    if (this.over && step(this.over)) { const cb = this.over.cb; this.over = null; cb && cb(); }
    this.render();
  }
  seek(id, t) { const a = ANIMS[id]; if (a.view && RIGS[a.view] && a.view !== this.o.view) this.set({ view: a.view }); this.base = { a, t: t == null ? a.len * .5 : t, hold: true }; this.render(); return this; }
  render() {
    const rig = this.rig, pose = {}, rm = G.Muncher.reduceMotion, W = {};
    if (this.base) G.Pip.sample(this.base.a, this.base.t, pose, rm); if (this.over) G.Pip.sample(this.over.a, this.over.t, pose, rm);
    for (const n of rig.nodes) {
      const o = pose[n.id] || {}, p = o.p || [0, 0], s = o.s || [1, 1];
      let m = loc(n.x + p[0], n.y + p[1], n.rot + (o.r || 0), n.sx * s[0], n.sy * s[1]);
      m = n.parent ? mul(W[n.parent], m) : mul([this.o.flip ? -1 : 1, 0, 0, 1, rig.origin[0], rig.origin[1]], m); W[n.id] = m;
      const g = this.els[n.id]; if (!g) continue; const c = this.cur[n.id] = this.cur[n.id] || {};
      let vis = o.v != null ? !!o.v : !n.hide; const al = o.a != null ? o.a : 1; if (al <= .001) vis = false;
      const ts = 'matrix(' + m.map(r3).join(' ') + ')'; if (c.t !== ts) { g.setAttribute('transform', ts); c.t = ts; }
      if (c.v !== vis) { g.style.display = vis ? '' : 'none'; c.v = vis; } if (c.a !== al) { g.style.opacity = al < 1 ? al : ''; c.a = al; }
      let f = o.f; if (n.swap && f == null) f = n.swap === 'eye' ? 'open' : n.swap === 'mouth' ? 'grin' : 'ice';
      if (n.sprite === 'fx') { if (f && c.f !== f) { g.innerHTML = FX[f] ? FX[f]() : ''; c.f = f; } }
      else if (n.swap && c.f !== f) { for (const ch of g.children) ch.style.display = ch.getAttribute('data-f') === f ? '' : 'none'; c.f = f; }
    }
    this.world = W;
  }
  destroy() { this.el.innerHTML = ''; }
}

// ── export
function parts() { const out = [];
  for (const s in SPR) { const names = Object.keys(SPR[s].frames); const dir = /nest/.test(s) ? 'nest' : s === 'm_banner' ? 'fx' : 'parts'; names.forEach(f => out.push({ file: 'muncher/' + dir + '/' + s + (names.length > 1 ? '__' + f : '') + '.svg', sprite: s, frame: names.length > 1 ? f : 'default', fn: SPR[s].frames[f], kind: dir })); }
  for (const f in FX) out.push({ file: 'muncher/fx/' + f + '.svg', sprite: 'fx', frame: f, fn: FX[f], kind: 'fx' });
  return out; }
function exportAll() {
  const files = {}, idx = {};
  parts().forEach(p => { const f = G.Pip.svgFile(p.fn()); files['assets/' + p.file] = f.svg; idx[p.sprite + ':' + p.frame] = { file: 'res://assets/' + p.file, offset: [f.box[0], f.box[1]], size: [f.box[2], f.box[3]] }; });
  const node = n => { const o = { id: n.id, parent: n.parent, pos: [n.x, n.y], rot_deg: n.rot, scale: [n.sx, n.sy], z: n.z };
    if (n.sprite === 'fx') { o.sprite = 'fx'; o.swap_group = 'fx'; } else if (n.sprite) { const fr = Object.keys(SPR[n.sprite].frames); if (n.swap) { o.swap_group = n.swap; o.frames = {}; fr.forEach(f => o.frames[f] = idx[n.sprite + ':' + f]); o.default_frame = n.swap === 'eye' ? 'open' : n.swap === 'mouth' ? 'grin' : 'ice'; } else o.sprite = idx[n.sprite + ':default']; }
    if (n.hide) o.visible = false; return o; };
  const rig = { schema: 1, character: 'Nibbs the seed-mole (in-game name: Muncher)', units: '1 px = 1 game px (Arena, base 1080 × 1920)', root: 'root = ArenaPest._pest_center = eat centre = mouth (GameState.ARENA_PEST_EAT_RADIUS 36 measured from here)',
    views: {}, direction_rule: STATES.HUNTING.dir_rule, flip: 'left = root.scale.x −1 on the side view', nest: { frame: NEST.frame, origin: NEST.origin, nodes: NEST.nodes.map(node), size: [270, 124], z_rule: 'nest_back z_index −1 under the pest; nest_front +1 over the pest ONLY while SLEEPING_NEST / WAKE_DELAY at the nest, otherwise under it' },
    fx_frames: Object.fromEntries(Object.keys(FX).map(f => [f, idx['fx:' + f]])), faces: { nodes: FACE_NODES, sets: FACE }, banner: idx['m_banner:default'],
    measures: { visual_radius: [58, 52], length_px: { front: 116, side: 136, back: 116 }, eat_centre: [0, 0], mouth_rest: { front: [0, 0], side: [0, 2] }, ice: [180, 156] } };
  for (const v in RIGS) { const r = prep(RIGS[v]); rig.views[v] = { frame: r.frame, origin: r.origin, nodes: r.nodes.map(node) }; }
  const GP = { p: 'position', r: 'rotation_degrees', s: 'scale', a: 'modulate:a', v: 'visible', f: 'frame' };
  const anims = { schema: 1, values: 'deltas from the rest pose of the node in the current view (same as game/data/pip/animations.json)', key_format: '[t_sec, value..., transition]; transition = Godot ease curve (1 linear, 0 hold, 0.5 out, 2 in, -2 in-out)', default_transition: -2, states: STATES,
    list: ORDER.map(id => { const a = ANIMS[id], tracks = []; for (const n in a.tracks) for (const q in a.tracks[n]) tracks.push({ node: n, prop: GP[q], keys: a.tracks[n][q] }); return { id, length: a.len, loop: a.loop, layer: a.layer, view: a.view, state: a.state, dir: a.dir || null, desc: a.desc, hold_last: !!a.hold, tracks, events: a.events.map(([t, n, g]) => ({ t, name: n, arg: g })), reduce_motion: a.rm }; }) };
  return { files, rig, anims, idx };
}
function atlas(scale) { const boxes = parts().filter(p => p.kind !== 'nest' && p.sprite !== 'm_banner').map(p => { const b = G.Pip.svgFile(p.fn()).box; return [b[2], b[3]]; });
  let x = 0, y = 0, rh = 0; const s = [...boxes].sort((a, b) => b[1] - a[1]); for (const [w0, h0] of s) { const w = Math.ceil(w0 * scale) + 2, h = Math.ceil(h0 * scale) + 2; if (x + w > 1024) { x = 0; y += rh; rh = 0; } x += w; rh = Math.max(rh, h); } return { w: 1024, h: y + rh, sprites: boxes.length, scale }; }

G.Muncher = { C, SPR, FX, RIGS, NEST, FACE, ANIMS, ORDER, STATES, create: (el, o) => new MInst(el, o), MInst, parts, exportAll, atlas, prep, reduceMotion: false,
  viewFor(dx, dy) { if (Math.abs(dx) >= .8 * Math.abs(dy)) return { view: 'side', flip: dx < 0, anim: 'm_hunt_side' }; return dy > 0 ? { view: 'front', flip: false, anim: 'm_hunt_front' } : { view: 'back', flip: false, anim: 'm_hunt_back' }; } };
})(typeof window !== 'undefined' ? window : globalThis);
