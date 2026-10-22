// Pip — art source: skin tokens, part sprites (local px around pivot), cutout rigs per view.
// Everything here is DATA consumed by pip_runtime.js (browser) and exported to godot/*.json + assets/pip/**.svg.
(function (G) {
'use strict';
const INK = '#2D3436', WHITE = '#FFFFFF', MOUTH = '#7A3B46', TONGUE = '#FF9FB4', SHADOW = '#1A1A14', CREAM = '#FFF8F0';
const f2 = n => Math.round(n * 100) / 100;
const pt = p => f2(p[0]) + ' ' + f2(p[1]);
function P(d, fill, sw, stroke, extra) { return '<path d="' + d + '" fill="' + (fill || 'none') + '"' + (sw ? ' stroke="' + (stroke || INK) + '" stroke-width="' + sw + '" stroke-linejoin="round" stroke-linecap="round"' : '') + (extra || '') + '/>'; }
function E(cx, cy, rx, ry, fill, sw, stroke, extra) { return '<ellipse cx="' + cx + '" cy="' + cy + '" rx="' + rx + '" ry="' + ry + '" fill="' + (fill || 'none') + '"' + (sw ? ' stroke="' + (stroke || INK) + '" stroke-width="' + sw + '"' : '') + (extra || '') + '/>'; }
function S(d, sw, stroke) { return P(d, 'none', sw || 3, stroke); }
function xf(points, a, cx, cy, sx) { const c = Math.cos(a), s = Math.sin(a); sx = sx || 1; return points.map(([x, y]) => [cx + x * sx * c - y * s, cy + x * sx * s + y * c]); }
// scalloped circle (cotton tail, clouds, fluff)
function fluff(cx, cy, r, n, b, rot) { rot = rot || 0; let d = ''; for (let i = 0; i <= n; i++) { const a = rot + i / n * Math.PI * 2; const p = [cx + r * Math.cos(a), cy + r * Math.sin(a)]; if (!i) d += 'M' + pt(p); else { const m = rot + (i - 0.5) / n * Math.PI * 2; d += ' Q' + pt([cx + (r + 2 * b) * Math.cos(m), cy + (r + 2 * b) * Math.sin(m)]) + ' ' + pt(p); } } return d + 'Z'; }
function petal(cx, cy, r, a) { const t = [[0, 0], [-r * .58, -r * .3], [-r * .52, -r * .96], [-r * .2, -r], [0, -r * .8], [r * .2, -r], [r * .52, -r * .96], [r * .58, -r * .3]]; const p = xf(t, a, cx, cy); return 'M' + pt(p[0]) + ' C' + pt(p[1]) + ' ' + pt(p[2]) + ' ' + pt(p[3]) + ' L' + pt(p[4]) + ' L' + pt(p[5]) + ' C' + pt(p[6]) + ' ' + pt(p[7]) + ' ' + pt(p[0]) + 'Z'; }
function flower(cx, cy, r, fill, center, rot) { let s = ''; for (let i = 0; i < 5; i++) s += P(petal(cx, cy, r, (rot || 0) + i * Math.PI * 2 / 5), fill, 2.2); return s + E(cx, cy, r * .26, r * .26, center, 1.8); }
function star4(cx, cy, r) { const k = r * .32; return 'M' + pt([cx, cy - r]) + ' L' + pt([cx + k, cy - k]) + ' L' + pt([cx + r, cy]) + ' L' + pt([cx + k, cy + k]) + ' L' + pt([cx, cy + r]) + ' L' + pt([cx - k, cy + k]) + ' L' + pt([cx - r, cy]) + ' L' + pt([cx - k, cy - k]) + 'Z'; }
function star5(cx, cy, r) { let d = ''; for (let i = 0; i < 10; i++) { const a = -Math.PI / 2 + i * Math.PI / 5, rr = i % 2 ? r * .46 : r; d += (i ? ' L' : 'M') + pt([cx + rr * Math.cos(a), cy + rr * Math.sin(a)]); } return d + 'Z'; }

// ── Skins (tokens). Classic hexes are the recolor KEYS: every classic token hex is unique in the part SVGs.
const TOKENS = ['fur', 'fur_sh', 'fur_lt', 'ear_in', 'cheek', 'nose', 'iris'];
const SKINS = [
  { key: 'classic', id: '', title: 'Classic Pip', coin_cost: 0, tokens: { fur: '#A8E6CF', fur_sh: '#7CCBAE', fur_lt: '#D4F5E4', ear_in: '#FFCCD5', cheek: '#FFB88C', nose: '#F2899F', iris: '#3E7D69' },
    overlays: [], showcase: 'pose_classic', signature: 'sig_classic',
    detail: 'Mint coat, folded right-ear tip and the three-lock forehead tuft. The base every skin keeps.' },
  { key: 'blossom', id: 'pip_blossom', title: 'Pip Blossom', coin_cost: 250, tokens: { fur: '#FFD3DE', fur_sh: '#F2AEC1', fur_lt: '#FFF0F3', ear_in: '#FF9FB8', cheek: '#FF94AE', nose: '#E5678A', iris: '#8C4560' },
    overlays: ['ov_sprig', 'ov_btail'], showcase: 'pose_blossom', signature: 'sig_blossom',
    detail: 'Cherry-blossom sprig at the left ear root (two flowers + leaf) and a five-petal blossom tail. Signature: twirl that sheds six petals.' },
  { key: 'sky', id: 'pip_sky', title: 'Pip Sky', coin_cost: 200, tokens: { fur: '#C2E2FA', fur_sh: '#96C3EC', fur_lt: '#EAF5FE', ear_in: '#FFCDD6', cheek: '#FFB98D', nose: '#F2899E', iris: '#3B6A9B' },
    overlays: ['ov_ctip_l', 'ov_ctip_r', 'ov_ctail'], showcase: 'pose_sky', signature: 'sig_sky',
    detail: 'Cloud-dipped ear tips and a three-puff cloud tail. Signature: a cloud hop — rises on two puffs and floats down.' }
];

// ── Sprites. frames: {name: tokens => svg}. Coordinates are LOCAL to the node pivot (0,0).
const SPR = {};
function spr(name, frames, note) { SPR[name] = { frames: typeof frames === 'function' ? { default: frames } : frames, note: note || '' }; }

spr('shadow', k => E(0, 0, 54, 9, SHADOW, 0, 0, ' fill-opacity="0.14"'), 'ground shadow (alpha .14 = UiHomeV3.PIP_SHADOW)');
spr('shadow_t', k => E(0, 8, 40, 46, SHADOW, 0, 0, ' fill-opacity="0.22"'), 'run shadow, top view');

// FRONT
spr('foot_f', k => E(0, 0, 25, 11, k.fur) + P('M -21 5 C -12 11 12 11 21 5 C 14 8 -14 8 -21 5 Z', k.fur_sh) + E(0, 0, 25, 11, 'none', 3) + S('M -8 10 L -8 5 M 0 11 L 0 5.5 M 8 10 L 8 5', 2.2));
spr('body_f', k => {
  const base = 'M0 -84 C 30 -84 54 -56 54 -30 C 54 -8 32 6 0 6 C -32 6 -54 -8 -54 -30 C -54 -56 -30 -84 0 -84 Z';
  return P(base, k.fur) + P('M 29 -76 C 45 -64 54 -46 54 -30 C 54 -8 32 6 0 6 C 24 0 42 -16 44 -36 C 45 -52 40 -66 29 -76 Z', k.fur_sh) +
    P('M -24 -46 Q -18 -54 -11 -48 Q -5 -56 0 -50 Q 5 -56 11 -48 Q 18 -54 24 -46 C 30 -32 28 -6 0 -2 C -28 -6 -30 -32 -24 -46 Z', k.fur_lt) + P(base, 'none', 3);
});
spr('paw_f', k => E(0, 9, 9.5, 9, k.fur) + P('M 2 16.5 C 7 15 9.5 11 9.5 8 C 8 13 5 15 2 16.5 Z', k.fur_sh) + E(0, 9, 9.5, 9, 'none', 3) + S('M -3 14.5 L -3 17.5 M 3 14.5 L 3 17.5', 2));
const HEAD_F = 'M0 -92 C 38 -92 64 -68 64 -38 C 64 -24 58 -12 48 -4 L 56 0 L 42 2 C 30 9 16 12 0 12 C -16 12 -30 9 -42 2 L -56 0 L -48 -4 C -58 -12 -64 -24 -64 -38 C -64 -68 -38 -92 0 -92 Z';
spr('head_f', k => P(HEAD_F, k.fur) +
  P('M 51 -66 C 61 -54 65 -36 60 -22 C 57 -13 52 -7 48 -4 L 56 0 L 42 2 C 30 9 16 12 0 12 C 30 4 50 -14 54 -36 C 55 -48 54 -57 51 -66 Z', k.fur_sh) +
  P('M0 -27 C -6 -33 -24 -33 -26 -19 C -27 -7 -12 -3 0 -9 C 12 -3 27 -7 26 -19 C 24 -33 6 -33 0 -27 Z', k.fur_lt) +
  E(-42, -20, 10, 6.5, k.cheek) + E(42, -20, 10, 6.5, k.cheek) + P(HEAD_F, 'none', 3));
spr('tuft', k => P('M -13 6 C -15 -5 -9 -14 -4 -8 C -3 -19 6 -21 6 -10 C 10 -17 17 -13 13 6 Z', k.fur) + P('M 6 -10 C 10 -17 17 -13 13 6 L 8 6 C 11 -2 10 -7 6 -10 Z', k.fur_sh) + S('M -13 6 C -15 -5 -9 -14 -4 -8 C -3 -19 6 -21 6 -10 C 10 -17 17 -13 13 6', 3));
// ears: long left ear in one piece; right ear = base + folded tip (Pip's silhouette signature)
const EAR_L = 'M -13 6 C -20 -20 -18 -54 -5 -68 C 3 -76 13 -71 14 -54 C 15 -32 12 -10 12 6 Z';
spr('ear_l', k => P(EAR_L, k.fur) + P('M -6 2 C -10 -20 -9 -46 -3 -57 C 3 -61 7 -54 7 -42 C 7 -24 5 -8 5 2 Z', k.ear_in) + P('M 9 -64 C 14 -56 15 -34 12 6 L 8 6 C 10 -20 11 -46 9 -64 Z', k.fur_sh) + P(EAR_L, 'none', 3));
const EAR_RB = 'M -13 6 C -18 -14 -17 -36 -12 -48 C -8 -58 8 -58 13 -48 C 15 -30 12 -10 12 6 Z';
spr('ear_rb', k => P(EAR_RB, k.fur) + P('M -6 2 C -9 -16 -8 -34 -5 -44 C -2 -48 4 -48 6 -44 C 7 -28 5 -8 5 2 Z', k.ear_in) + P('M 9.5 -50 C 11 -50 12 -49 13 -48 C 15 -30 12 -10 12 6 L 8.5 6 C 10 -16 10.5 -34 9.5 -50 Z', k.fur_sh) + P(EAR_RB, 'none', 3));
const TIP = 'M -12.5 2 C -12 -10 -6 -23 2 -26 C 10 -28 15 -17 13.5 2 C 13 8 -12 8 -12.5 2 Z';
spr('ear_tip', k => P(TIP, k.fur) + P('M 5 -27 C 12 -26 15 -16 13.5 3 C 11 4.5 9 5 7 5 C 10 -6 9 -18 5 -27 Z', k.fur_sh) + P(TIP, 'none', 3));
spr('tail', k => P(fluff(0, 0, 13, 7, 2.6), k.fur_lt) + P('M 3 12 Q 12 8 13.5 -1 Q 9 7 1 9.5 Z', k.fur) + P(fluff(0, 0, 13, 7, 2.6), 'none', 3));

// FACE (shared by front / 3q / side / top; mirrored by node scale where needed)
const EYE = {
  open: k => E(0, 0, 11, 14, k.iris) + E(0, -2.5, 10, 11.5, INK) + E(-3.8, -6.5, 4.4, 4.8, WHITE) + E(4, 5, 2, 2, WHITE),
  blink: k => S('M -11 1 Q 0 7 11 1', 3.6),
  happy: k => S('M -11 4 Q 0 -10 11 4', 3.6),
  wide: k => E(0, -1, 12.5, 16, k.iris) + E(0, -3, 11.5, 13.5, INK) + E(-4.2, -8, 5, 5.4, WHITE) + E(4.5, 5, 2.4, 2.4, WHITE) + E(0, -1, 12.5, 16, 'none', 2),
  half: k => P('M -11 -1 C -11 10 11 10 11 -1 Z', k.iris) + P('M -10 -1 C -10 7 10 7 10 -1 Z', INK) + E(-3.6, 2.2, 2.6, 2.2, WHITE) + S('M -12.5 -1.5 L 12.5 -1.5', 3.4),
  x: k => S('M -7 -7 L 7 7 M 7 -7 L -7 7', 3.6),
  spin: k => S('M 1 0 C 1 -3 -4 -3 -4 1 C -4 6 4 7 6 1 C 8 -6 0 -11 -6 -8 C -11 -5 -11 4 -8 8', 3),
  spark: k => E(0, 0, 11, 14, k.iris) + E(0, -2.5, 10, 11.5, INK) + P(star4(-3.5, -5.5, 6.5), WHITE) + E(4.2, 5, 2.2, 2.2, WHITE) + E(-4.5, 4.5, 1.4, 1.4, WHITE),
  heart: k => P('M 0 10 C -14 1 -13 -11 -5 -11 C -2 -11 0 -8 0 -5 C 0 -8 2 -11 5 -11 C 13 -11 14 1 0 10 Z', k.nose, 2.4) + E(-5, -5, 2.2, 2.6, WHITE),
  squint: k => S('M -9 -7 L 7 0 L -9 7', 3.6),
  squint_r: k => S('M 9 -7 L -7 0 L 9 7', 3.6),
  down: k => E(0, 0, 11, 14, k.iris) + E(0, 1, 10, 11.5, INK) + E(-3.8, -1, 4, 4.2, WHITE) + E(4, 7, 1.8, 1.8, WHITE)
};
spr('eye', EYE, 'swap group eye_L / eye_R');
spr('brow', { none: k => '', flat: k => S('M -7 1 Q 0 -2 7 1', 3.2), up: k => S('M -7 -3 Q 0 -8 7 -3', 3.2), worried: k => S('M -7 1 Q 0 -1 7 -5', 3.2), cross: k => S('M -7 -4 Q 0 -3 7 3', 3.2) }, 'swap; R uses scale.x −1');
spr('nose', k => P('M -6 -3 Q 0 -6.5 6 -3 Q 4.5 3 0 4 Q -4.5 3 -6 -3 Z', k.nose, 2) + S('M 0 4 L 0 9', 2.2));
spr('mouth', {
  w: k => P('M -2.8 0.5 L 2.8 0.5 L 2.5 5.5 L -2.5 5.5 Z', WHITE, 1.8) + S('M -9 -2 Q -4.5 4 0 -1 Q 4.5 4 9 -2', 2.6),
  smile: k => P('M -8 -2 Q 0 1 8 -2 Q 6 8 0 8 Q -6 8 -8 -2 Z', MOUTH) + E(0, 5.4, 3.6, 2.2, TONGUE) + P('M -8 -2 Q 0 1 8 -2 Q 6 8 0 8 Q -6 8 -8 -2 Z', 'none', 2.4),
  grin: k => P('M -11 -3 Q 0 1 11 -3 Q 9 11 0 11 Q -9 11 -11 -3 Z', MOUTH) + E(0, 7.8, 5, 3, TONGUE) + P('M -11 -3 Q 0 1 11 -3 Q 9 11 0 11 Q -9 11 -11 -3 Z', 'none', 2.4),
  o: k => E(0, 2.5, 4.2, 5.2, MOUTH, 2.4),
  flat: k => S('M -6 1 L 6 1', 2.6),
  frown: k => S('M -7 4 Q 0 -2 7 4', 2.6),
  blep: k => P('M -3 1 Q -3 7.5 0 7.5 Q 3 7.5 3 1 Z', TONGUE, 2) + S('M -9 -2 Q -4.5 4 0 -1 Q 4.5 4 9 -2', 2.6),
  wobble: k => S('M -9 2 Q -6 -2 -3 2 Q 0 6 3 2 Q 6 -2 9 2', 2.6),
  chew: k => P('M -2.4 1 L 2.4 1 L 2.2 5 L -2.2 5 Z', WHITE, 1.8) + S('M -5 0 Q 0 3 5 0', 2.6)
}, 'swap group mouth');

// THREE-QUARTER (turned to viewer-right)
spr('body_q', k => {
  const base = 'M0 -84 C 30 -84 54 -56 54 -30 C 54 -8 32 6 0 6 C -32 6 -54 -8 -54 -30 C -54 -56 -30 -84 0 -84 Z';
  return P(base, k.fur) + P('M 22 -80 C 44 -68 54 -46 54 -30 C 54 -8 32 6 0 6 C 30 -2 40 -20 42 -38 C 43 -54 36 -70 22 -80 Z', k.fur_sh) +
    P('M -12 -46 Q -6 -54 1 -48 Q 7 -56 12 -50 Q 18 -55 24 -47 Q 30 -50 33 -42 C 37 -26 30 -6 10 -2 C -14 -4 -18 -30 -12 -46 Z', k.fur_lt) + P(base, 'none', 3);
});
const HEAD_Q = 'M -4 -92 C 36 -93 64 -70 66 -40 C 68 -28 64 -16 56 -8 C 60 -5 62 -1 60 2 C 48 9 26 12 4 12 C -16 12 -30 9 -42 2 L -55 0 L -47 -4 C -57 -12 -62 -24 -62 -38 C -62 -68 -40 -91 -4 -92 Z';
spr('head_q', k => P(HEAD_Q, k.fur) +
  P('M 46 -74 C 60 -62 67 -44 66 -30 C 65 -18 60 -10 56 -8 C 60 -5 62 -1 60 2 C 48 9 26 12 4 12 C 34 4 52 -12 56 -32 C 58 -48 54 -63 46 -74 Z', k.fur_sh) +
  P('M 16 -27 C 10 -33 -6 -33 -8 -19 C -9 -7 4 -3 16 -9 C 26 -3 38 -7 37 -19 C 36 -32 22 -33 16 -27 Z', k.fur_lt) +
  E(-30, -20, 10, 6.5, k.cheek) + E(48, -19, 6.5, 6, k.cheek) + P(HEAD_Q, 'none', 3));

// SIDE (profile facing right)
const BODY_S = 'M -52 -10 C -58 -44 -30 -70 4 -70 C 30 -70 46 -54 46 -30 C 46 -8 30 6 -2 6 C -34 6 -50 2 -52 -10 Z';
spr('body_s', k => P(BODY_S, k.fur) + P('M -50 -6 C -48 2 -34 6 -2 6 C 18 6 32 2 40 -6 C 24 -2 -20 0 -50 -6 Z', k.fur_sh) +
  P('M 28 -58 C 42 -48 47 -28 40 -9 C 34 0 26 2 17 0 C 29 -16 31 -38 28 -58 Z', k.fur_lt) + P(BODY_S, 'none', 3) + S('M -40 -12 C -37 -32 -20 -45 0 -44', 2.6));
spr('foot_s', k => P('M -30 0 C -30 -8 -18 -12 0 -12 C 18 -12 31 -7 31 -1 C 31 5 20 7 0 7 C -20 7 -30 5 -30 0 Z', k.fur) + P('M -26 4 C -16 7 18 7 29 3 C 22 5 -16 5 -26 4 Z', k.fur_sh) +
  P('M -30 0 C -30 -8 -18 -12 0 -12 C 18 -12 31 -7 31 -1 C 31 5 20 7 0 7 C -20 7 -30 5 -30 0 Z', 'none', 3) + S('M 22 -2 L 26 3 M 15 -3 L 18 4', 2));
const HEAD_S = 'M -6 -90 C 30 -92 56 -72 62 -46 C 67 -40 71 -31 69 -22 C 67 -12 59 -6 49 -4 C 40 6 22 10 4 8 C -14 7 -28 0 -36 -8 L -46 -6 L -42 -14 C -46 -22 -48 -31 -47 -42 C -46 -70 -30 -88 -6 -90 Z';
spr('head_s', k => P(HEAD_S, k.fur) + P('M -36 -8 L -46 -6 L -42 -14 C -46 -22 -48 -31 -47 -42 C -40 -22 -24 -6 4 0 C 22 3 36 0 46 -6 C 38 6 20 10 4 8 C -14 7 -28 0 -36 -8 Z', k.fur_sh) +
  P('M 40 -37 C 54 -40 67 -33 67 -22 C 67 -12 57 -6 47 -6 C 37 -6 32 -14 34 -24 C 35 -30 37 -35 40 -37 Z', k.fur_lt) + E(30, -16, 9, 6, k.cheek) + P(HEAD_S, 'none', 3));

// BACK
spr('body_b', k => {
  const base = 'M0 -84 C 30 -84 54 -56 54 -30 C 54 -8 32 6 0 6 C -32 6 -54 -8 -54 -30 C -54 -56 -30 -84 0 -84 Z';
  return P(base, k.fur) + P('M 29 -76 C 45 -64 54 -46 54 -30 C 54 -8 32 6 0 6 C 24 0 42 -16 44 -36 C 45 -52 40 -66 29 -76 Z', k.fur_sh) + P(base, 'none', 3) + S('M -14 -60 C -6 -64 6 -64 14 -60', 2.4);
});
spr('foot_b', k => E(0, 0, 22, 12, k.fur) + E(0, 2, 14, 7, k.fur_lt) + E(-8, -5, 4, 3, k.fur_lt) + E(0, -6.5, 4, 3, k.fur_lt) + E(8, -5, 4, 3, k.fur_lt) + E(0, 0, 22, 12, 'none', 3));
spr('head_b', k => P(HEAD_F, k.fur) + P('M 51 -66 C 61 -54 65 -36 60 -22 C 57 -13 52 -7 48 -4 L 56 0 L 42 2 C 30 9 16 12 0 12 C 30 4 50 -14 54 -36 C 55 -48 54 -57 51 -66 Z', k.fur_sh) +
  P(HEAD_F, 'none', 3) + S('M -6 -86 C -2 -80 2 -80 6 -84', 2.2));
spr('ear_back', k => P(EAR_L, k.fur) + P('M 9 -64 C 14 -56 15 -34 12 6 L 8 6 C 10 -20 11 -46 9 -64 Z', k.fur_sh) + P(EAR_L, 'none', 3));
spr('ear_backb', k => P(EAR_RB, k.fur) + P('M 9.5 -50 C 11 -50 12 -49 13 -48 C 15 -30 12 -10 12 6 L 8.5 6 C 10 -16 10.5 -34 9.5 -50 Z', k.fur_sh) + P(EAR_RB, 'none', 3));

// TOP (run, bird's-eye, nose = up). 150-frame, collision 56×56 centred on pivot.
const BODY_T = 'M 0 -38 C 26 -38 36 -20 37 0 C 39 22 30 42 0 42 C -30 42 -39 22 -37 0 C -36 -20 -26 -38 0 -38 Z';
spr('body_t', k => P(BODY_T, k.fur) + P('M 16 -34 C 30 -26 36 -12 37 0 C 39 22 30 42 0 42 C 22 34 30 18 29 0 C 28 -14 24 -26 16 -34 Z', k.fur_sh) + P(BODY_T, 'none', 3) + S('M -30 12 C -27 20 -22 25 -15 28 M 30 12 C 27 20 22 25 15 28', 2.2));
spr('head_t', k => {
  const h = 'M 0 -32 C 17 -32 27 -20 27 -6 C 27 2 24 8 20 11 L 25 14 L 15 15 C 10 17 5 18 0 18 C -5 18 -10 17 -15 15 L -25 14 L -20 11 C -24 8 -27 2 -27 -6 C -27 -20 -17 -32 0 -32 Z';
  return P(h, k.fur) + P('M 14 -29 C 23 -23 27 -14 27 -6 C 27 2 24 8 20 11 L 25 14 L 15 15 C 10 17 5 18 0 18 C 14 12 21 2 21 -8 C 21 -17 18 -24 14 -29 Z', k.fur_sh) + P('M -9 -26 C -6 -32 6 -32 9 -26 C 7 -21 -7 -21 -9 -26 Z', k.fur_lt) + P(h, 'none', 3);
});
spr('foot_t', k => P('M 0 -20 C 8 -20 10 -8 10 4 C 10 15 6 22 0 22 C -6 22 -10 15 -10 4 C -10 -8 -8 -20 0 -20 Z', k.fur) + P('M -5 6 C -5 14 -3 18 0 18 C 3 18 5 14 5 6 C 3 9 -3 9 -5 6 Z', k.fur_lt) + P('M 0 -20 C 8 -20 10 -8 10 4 C 10 15 6 22 0 22 C -6 22 -10 15 -10 4 C -10 -8 -8 -20 0 -20 Z', 'none', 3));
spr('paw_t', k => E(0, 0, 7, 9.5, k.fur) + E(0, 0, 7, 9.5, 'none', 2.6) + S('M -2.5 -6 L -2.5 -9 M 2.5 -6 L 2.5 -9', 1.8));

// SKIN OVERLAYS (fixed colours, attach to rig nodes per view)
const OV = {};
OV.ov_sprig = { skin: 'blossom', art: k => P('M -2 6 C 6 -2 16 -2 22 4 C 14 10 4 10 -2 6 Z', '#9FD8A6', 2.2) + S('M 0 6 C 7 3 13 3 19 4', 1.6, '#5E9D6A') + flower(-6, 0, 11, WHITE, '#FFD56B', .2) + flower(10, -10, 8.5, '#FF94AE', '#FFD56B', -.3), note: 'two blossoms + leaf, ear_L root' };
OV.ov_btail = { skin: 'blossom', art: k => { let s = ''; for (let i = 0; i < 5; i++) s += P(petal(0, 0, 17, i * Math.PI * 2 / 5 + .3), i % 2 ? '#FFF0F3' : '#FFD3DE', 2.6); return s + E(0, 0, 5.5, 5.5, '#FF94AE', 2.2); }, note: 'blossom tail (covers tail)' };
const CAP = 'M -12 7 Q -16 -2 -9 -6 Q -7 -14 0 -13 Q 7 -15 10 -7 Q 17 -3 13 7 Q 0 11 -12 7 Z';
OV.ov_ctip_l = { skin: 'sky', art: k => P(CAP, WHITE) + P('M -11 5.5 Q 0 9 12 5.5 Q 12 2.5 10 2.5 Q 0 6 -10 2.5 Z', '#D6ECFB') + P(CAP, 'none', 3), note: 'cloud cap, ear_L tip' };
OV.ov_ctip_r = { skin: 'sky', art: OV.ov_ctip_l.art, note: 'cloud cap, folded tip' };
const CTAIL = 'M -16 6 Q -22 -2 -14 -8 Q -12 -18 -2 -16 Q 4 -22 12 -15 Q 22 -14 20 -4 Q 26 4 16 10 Q 0 15 -16 6 Z';
OV.ov_ctail = { skin: 'sky', art: k => P(CTAIL, WHITE) + P('M -14 6 Q 0 12 15 8 Q 20 4 18 1 Q 6 9 -12 3 Z', '#D6ECFB') + P(CTAIL, 'none', 3), note: 'cloud tail (covers tail)' };

// FX + seasonal props (one swap node each; ≤ 12 FX sprites live at once)
const FX = {
  ring: k => E(0, 0, 100, 42, 'none', 8, '#FFF8F0', ' stroke-opacity="0.55"'),
  petal: k => P(petal(0, 9, 18, 0), '#FF94AE', 2.4),
  petal2: k => P(petal(0, 9, 18, 0), '#FFF0F3', 2.4),
  cloud: k => P(CTAIL, WHITE, 2.6),
  sparkle: k => P(star4(0, 0, 12), '#FFEAA7', 2.2),
  star: k => P(star5(0, 0, 11), '#FFD56B', 2.2),
  heart: k => P('M 0 10 C -14 1 -13 -11 -5 -11 C -2 -11 0 -8 0 -5 C 0 -8 2 -11 5 -11 C 13 -11 14 1 0 10 Z', '#FF94AE', 2.4),
  zzz: k => S('M -6 -6 L 6 -6 L -6 6 L 6 6', 7, INK) + S('M -6 -6 L 6 -6 L -6 6 L 6 6', 3.4, CREAM),
  dust: k => P(fluff(0, 0, 9, 5, 2), CREAM, 2.2),
  pollen: k => E(-6, 0, 3.4, 3.4, '#FFEAA7', 1.6) + E(4, -5, 2.8, 2.8, '#FFEAA7', 1.6) + E(5, 5, 2.4, 2.4, '#FFEAA7', 1.6),
  sweat: k => P('M 0 -9 C 5 -2 7 2 7 5 C 7 9 4 11 0 11 C -4 11 -7 9 -7 5 C -7 2 -5 -2 0 -9 Z', '#B8E0F5', 2.2),
  bang: k => P('M -4 -16 L 4 -16 L 2 4 L -2 4 Z', '#FFEAA7', 2.6) + E(0, 11, 3.4, 3.4, '#FFEAA7', 2.6),
  note: k => S('M -3 6 L -3 -10 L 7 -12 L 7 3', 3) + E(-6, 6, 4, 3, INK) + E(4, 3, 4, 3, INK),
  // seasonal props (rekviziti)
  butterfly: k => E(-7, -4, 7, 8, '#FFCCD5', 2.2) + E(7, -4, 7, 8, '#FFCCD5', 2.2) + E(-5, 6, 5, 4.5, '#D4A5FF', 2.2) + E(5, 6, 5, 4.5, '#D4A5FF', 2.2) + E(0, 1, 2, 8, INK),
  dandelion: k => S('M 0 30 C 2 18 -1 10 0 0', 3, '#5E9D6A') + P(fluff(0, -6, 9, 10, 1.6), WHITE, 2) + E(0, -6, 3, 3, '#E9E3D6'),
  seedfluff: k => S('M 0 6 L 0 -2', 1.6) + P(star4(0, -4, 4), WHITE, 1.4),
  snowflake: k => S('M 0 -9 L 0 9 M -8 -4.5 L 8 4.5 M -8 4.5 L 8 -4.5', 3.4, INK) + S('M 0 -9 L 0 9 M -8 -4.5 L 8 4.5 M -8 4.5 L 8 -4.5', 1.6, WHITE),
  snowclump: k => P(fluff(0, 0, 13, 6, 2.6), WHITE, 2.6) + P('M -10 6 Q 0 12 11 5 Q 4 8 -10 6 Z', '#D6E6F5'),
  firefly: k => E(0, 0, 9, 9, '#FFEAA7', 0, 0, ' fill-opacity="0.35"') + E(0, 0, 4.2, 4.2, '#FFEAA7', 2) + E(-3, -4, 3, 2, WHITE, 1.4),
  leaf: k => P('M 0 -16 C 9 -8 11 4 0 16 C -11 4 -9 -8 0 -16 Z', '#E6AE55', 2.4) + S('M 0 -12 L 0 13', 1.8, '#A9652F'),
  acorn: k => E(0, 3, 7, 8.5, '#B07A44', 2.4) + P('M -9 -2 C -9 -9 9 -9 9 -2 C 4 0 -4 0 -9 -2 Z', '#6E4A28', 2.4) + S('M 0 -7 L 1.5 -11', 2.4),
  burrow: k => E(0, 0, 40, 14, '#1E2244') + E(0, -3, 40, 11, 'none', 4, '#50579A'),
  dirt: k => E(-5, 0, 4, 3.4, '#6E5238', 1.6) + E(4, -3, 3.4, 3, '#6E5238', 1.6) + E(3, 4, 2.6, 2.4, '#6E5238', 1.6),
  bubble: k => E(0, 0, 12, 12, '#E8F6FF', 2.4, '#5FAEB3', ' fill-opacity="0.55"') + E(-4, -4, 3, 2.4, WHITE),
  shell: k => P('M -14 4 C -14 -10 -6 -16 0 -16 C 6 -16 14 -10 14 4 C 6 8 -6 8 -14 4 Z', '#FFF1E8', 2.4) + S('M 0 6 L -7 -11 M 0 6 L 0 -14 M 0 6 L 7 -11', 1.8, '#E9C2AE'),
  meteor: k => S('M -30 -14 L 6 2', 5, '#FFF2BF') + E(8, 3, 6, 6, '#FFF2BF', 2.2),
  starpetal: k => P(star4(0, 0, 9), '#D9CCFF', 2),
  smoke: k => P(fluff(0, 0, 12, 6, 2.6), '#C9B3A6', 2.4, '#7A5A50'),
  ember: k => E(0, 0, 6, 6, '#FFB074', 2.2, '#C8744E') + E(0, 0, 2.6, 2.6, '#FFE0B8')
};

// ── Rigs. Node: [id, parent, x, y, z, sprite, opts]. Root sits on the ground under the feet.
// x,y = rest position relative to parent pivot (px of the view frame). opts: rot, sx, sy, swap, ov, hide.
function N(id, parent, x, y, z, sprite, o) { return Object.assign({ id, parent, x, y, z, sprite, rot: 0, sx: 1, sy: 1 }, o || {}); }
const FXN = () => [
  N('fx_ring', 'root', 0, 0, -40, 'fx', { hide: true }),
  N('prop2', 'root', 0, 0, -30, 'fx', { hide: true }),
  N('fx_a', 'root', 0, 0, 40, 'fx', { hide: true }), N('fx_b', 'root', 0, 0, 40, 'fx', { hide: true }), N('fx_c', 'root', 0, 0, 40, 'fx', { hide: true }),
  N('fx_d', 'root', 0, 0, 40, 'fx', { hide: true }), N('fx_e', 'root', 0, 0, 40, 'fx', { hide: true }), N('fx_f', 'root', 0, 0, 40, 'fx', { hide: true }),
  N('emote', 'root', 0, 0, 42, 'fx', { hide: true }), N('prop', 'root', 0, 0, 30, 'fx', { hide: true })
];
const FACE = (ex, ey, sep, sc) => [
  N('eye_L', 'head', ex - sep, ey, 3, 'eye', { swap: 'eye', sx: sc[0], sy: sc[0] }),
  N('eye_R', 'head', ex + sep, ey, 3, 'eye', { swap: 'eye', sx: sc[1], sy: sc[1] })
];
const RIGS = {
  front: { frame: [256, 256], origin: [128, 240], nodes: [
    N('root', null, 0, 0, 0, null), N('shadow', 'root', 0, 0, -50, 'shadow'), N('pip', 'root', 0, 0, 0, null),
    N('foot_L', 'pip', -30, -9, 4, 'foot_f'), N('foot_R', 'pip', 30, -9, 4, 'foot_f', { sx: -1 }),
    N('body', 'pip', 0, -8, 0, 'body_f'),
    N('tail', 'body', 0, -20, -5, 'tail', { hide: true }),
    N('arm_L', 'body', -22, -30, 8, 'paw_f'), N('arm_R', 'body', 22, -30, 8, 'paw_f', { sx: -1 }),
    N('head', 'body', 0, -72, 6, 'head_f'),
    N('ear_L', 'head', -24, -78, -2, 'ear_l', { rot: -10 }),
    N('ear_R', 'head', 24, -78, -2, 'ear_rb', { rot: 12 }),
    N('ear_R_tip', 'ear_R', 0, -50, 1, 'ear_tip', { rot: 122 }),
    N('tuft', 'head', 0, -88, 2, 'tuft'),
    ...FACE(0, -47, 23, [1, 1]),
    N('brow_L', 'head', -24, -66, 3, 'brow', { swap: 'brow' }), N('brow_R', 'head', 24, -66, 3, 'brow', { swap: 'brow', sx: -1 }),
    N('nose', 'head', 0, -29, 4, 'nose'), N('mouth', 'head', 0, -17, 4, 'mouth', { swap: 'mouth' }),
    N('ov_sprig', 'ear_L', 4, -2, 6, 'ov', { ov: 'ov_sprig' }),
    N('ov_ctip_l', 'ear_L', 0, -62, 2, 'ov', { ov: 'ov_ctip_l' }), N('ov_ctip_r', 'ear_R_tip', 0, -22, 2, 'ov', { ov: 'ov_ctip_r' }),
    ...FXN() ] },
  three_q: { frame: [256, 256], origin: [128, 240], nodes: [
    N('root', null, 0, 0, 0, null), N('shadow', 'root', 0, 0, -50, 'shadow'), N('pip', 'root', 0, 0, 0, null),
    N('foot_R', 'pip', 30, -11, -1, 'foot_f', { sx: -.85 }), N('foot_L', 'pip', -24, -8, 4, 'foot_f'),
    N('body', 'pip', 0, -8, 0, 'body_q'),
    N('tail', 'body', -50, -16, -5, 'tail'),
    N('ov_btail', 'tail', 0, 0, 1, 'ov', { ov: 'ov_btail', sx: .85, sy: .85 }), N('ov_ctail', 'tail', -2, 0, 1, 'ov', { ov: 'ov_ctail', sx: .85, sy: .85 }),
    N('arm_L', 'body', -10, -30, 8, 'paw_f'), N('arm_R', 'body', 30, -32, 8, 'paw_f', { sx: -.9 }),
    N('head', 'body', 4, -72, 6, 'head_q'),
    N('ear_L', 'head', -30, -76, -2, 'ear_l', { rot: -16 }),
    N('ear_R', 'head', 14, -82, -3, 'ear_rb', { rot: 8 }),
    N('ear_R_tip', 'ear_R', 0, -50, 1, 'ear_tip', { rot: 118 }),
    N('tuft', 'head', -4, -88, 2, 'tuft', { rot: -4 }),
    N('eye_L', 'head', -12, -47, 3, 'eye', { swap: 'eye' }), N('eye_R', 'head', 35, -46, 3, 'eye', { swap: 'eye', sx: .76, sy: .97 }),
    N('brow_L', 'head', -12, -66, 3, 'brow', { swap: 'brow' }), N('brow_R', 'head', 35, -65, 3, 'brow', { swap: 'brow', sx: -.76 }),
    N('nose', 'head', 16, -29, 4, 'nose'), N('mouth', 'head', 16, -17, 4, 'mouth', { swap: 'mouth' }),
    N('ov_sprig', 'ear_L', 4, -2, 6, 'ov', { ov: 'ov_sprig' }),
    N('ov_ctip_l', 'ear_L', 0, -62, 2, 'ov', { ov: 'ov_ctip_l' }), N('ov_ctip_r', 'ear_R_tip', 0, -22, 2, 'ov', { ov: 'ov_ctip_r' }),
    ...FXN() ] },
  side: { frame: [256, 256], origin: [128, 240], nodes: [
    N('root', null, 0, 0, 0, null), N('shadow', 'root', 0, 0, -50, 'shadow', { sx: 1.12 }), N('pip', 'root', 0, 0, 0, null),
    N('foot_L', 'pip', -10, -7, -2, 'foot_s'), N('foot_R', 'pip', -2, -5, 4, 'foot_s'),
    N('body', 'pip', 0, -8, 0, 'body_s'),
    N('tail', 'body', -52, -22, -2, 'tail'),
    N('ov_btail', 'tail', -2, 0, 1, 'ov', { ov: 'ov_btail', sx: .85, sy: .85 }), N('ov_ctail', 'tail', -4, 0, 1, 'ov', { ov: 'ov_ctail', sx: -.85, sy: .85 }),
    N('arm_L', 'body', 38, -16, -1, 'paw_f'), N('arm_R', 'body', 30, -14, 8, 'paw_f'),
    N('head', 'body', 12, -60, 6, 'head_s'),
    N('ear_L', 'head', -16, -80, -3, 'ear_l', { rot: -34 }),
    N('ear_R', 'head', -4, -82, -2, 'ear_rb', { rot: -20 }),
    N('ear_R_tip', 'ear_R', 0, -50, 1, 'ear_tip', { rot: -118 }),
    N('tuft', 'head', 10, -88, 2, 'tuft', { rot: 12 }),
    N('eye_R', 'head', 30, -50, 3, 'eye', { swap: 'eye', sx: .84 }),
    N('brow_R', 'head', 30, -69, 3, 'brow', { swap: 'brow', sx: -.84 }),
    N('nose', 'head', 64, -31, 4, 'nose', { sx: .75, rot: 12 }), N('mouth', 'head', 56, -15, 4, 'mouth', { swap: 'mouth', sx: .7 }),
    N('ov_sprig', 'ear_R', 2, -6, 8, 'ov', { ov: 'ov_sprig' }),
    N('ov_ctip_l', 'ear_L', 0, -62, 2, 'ov', { ov: 'ov_ctip_l' }), N('ov_ctip_r', 'ear_R_tip', 0, -22, 2, 'ov', { ov: 'ov_ctip_r' }),
    ...FXN() ] },
  back: { frame: [256, 256], origin: [128, 240], nodes: [
    N('root', null, 0, 0, 0, null), N('shadow', 'root', 0, 0, -50, 'shadow'), N('pip', 'root', 0, 0, 0, null),
    N('foot_L', 'pip', 28, -6, 2, 'foot_b'), N('foot_R', 'pip', -28, -6, 2, 'foot_b'),
    N('body', 'pip', 0, -8, 0, 'body_b'),
    N('tail', 'body', 0, -22, 3, 'tail', { sx: 1.15, sy: 1.15 }),
    N('ov_btail', 'tail', 0, 0, 1, 'ov', { ov: 'ov_btail' }), N('ov_ctail', 'tail', 0, 0, 1, 'ov', { ov: 'ov_ctail' }),
    N('head', 'body', 0, -72, 6, 'head_b'),
    N('ear_L', 'head', 24, -78, 2, 'ear_back', { rot: 10, sx: -1 }),
    N('ear_R', 'head', -24, -78, 2, 'ear_backb', { rot: -12, sx: -1 }),
    N('ear_R_tip', 'ear_R', 0, -50, 1, 'ear_tip', { rot: 122 }),
    N('tuft', 'head', 0, -88, 1, 'tuft', { sx: -1 }),
    N('ov_sprig', 'ear_L', -2, -2, 6, 'ov', { ov: 'ov_sprig', sx: -1 }),
    N('ov_ctip_l', 'ear_L', 0, -62, 2, 'ov', { ov: 'ov_ctip_l' }), N('ov_ctip_r', 'ear_R_tip', 0, -22, 2, 'ov', { ov: 'ov_ctip_r' }),
    ...FXN() ] },
  top: { frame: [150, 150], origin: [75, 75], nodes: [
    N('root', null, 0, 0, 0, null), N('shadow', 'root', 0, 0, -50, 'shadow_t'), N('pip', 'root', 0, 0, 0, null),
    N('foot_L', 'pip', -22, 40, -1, 'foot_t', { rot: 8 }), N('foot_R', 'pip', 22, 40, -1, 'foot_t', { sx: -1, rot: -8 }),
    N('arm_L', 'pip', -29, -40, -1, 'paw_t', { rot: -14 }), N('arm_R', 'pip', 29, -40, -1, 'paw_t', { rot: 14 }),
    N('body', 'pip', 0, 0, 0, 'body_t'),
    N('tail', 'body', 0, 42, 1, 'tail', { sx: .8, sy: .8 }),
    N('ov_btail', 'tail', 0, 0, 1, 'ov', { ov: 'ov_btail' }), N('ov_ctail', 'tail', 0, 0, 1, 'ov', { ov: 'ov_ctail' }),
    N('head', 'body', 0, -34, 2, 'head_t'),
    N('ear_L', 'head', -13, 4, -1, 'ear_back', { rot: -140, sx: .64, sy: .66 }),
    N('ear_R', 'head', 13, 4, -1, 'ear_backb', { rot: 141, sx: .64, sy: .66 }),
    N('ear_R_tip', 'ear_R', 0, -50, 1, 'ear_tip', { rot: 40 }),
    N('tuft', 'head', 0, -12, 3, 'tuft', { sx: .7, sy: .7 }),
    N('eye_L', 'head', -22, -12, 2, 'eye', { swap: 'eye', sx: .3, sy: .4, rot: -16 }), N('eye_R', 'head', 22, -12, 2, 'eye', { swap: 'eye', sx: .3, sy: .4, rot: 16 }),
    N('nose', 'head', 0, -31, 2, 'nose', { sx: .7, sy: .7 }),
    N('ov_sprig', 'head', -13, -2, 4, 'ov', { ov: 'ov_sprig', sx: .8, sy: .8 }),
    N('ov_ctip_l', 'ear_L', 0, -62, 2, 'ov', { ov: 'ov_ctip_l' }), N('ov_ctip_r', 'ear_R_tip', 0, -22, 2, 'ov', { ov: 'ov_ctip_r' }),
    ...FXN() ] }
};
RIGS.front.nodes.find(n => n.id === 'tail').hide = true;

// ── Expressions (≥ 12) = swap frames for eye_L, eye_R, brow_L, brow_R, mouth
const EXPR = {
  neutral: ['open', 'open', 'none', 'none', 'w'], happy: ['happy', 'happy', 'none', 'none', 'smile'], joy: ['happy', 'happy', 'up', 'up', 'grin'],
  curious: ['open', 'open', 'up', 'flat', 'o'], surprised: ['wide', 'wide', 'up', 'up', 'o'], admire: ['spark', 'spark', 'up', 'up', 'smile'],
  love: ['heart', 'heart', 'none', 'none', 'w'], sleepy: ['half', 'half', 'none', 'none', 'w'], asleep: ['blink', 'blink', 'none', 'none', 'chew'],
  blink: ['blink', 'blink', 'none', 'none', 'w'], squint: ['squint', 'squint_r', 'cross', 'cross', 'o'], sneeze: ['squint', 'squint_r', 'none', 'none', 'grin'],
  dizzy: ['spin', 'x', 'worried', 'worried', 'wobble'], worried: ['open', 'open', 'worried', 'worried', 'frown'], sad: ['down', 'down', 'worried', 'worried', 'frown'],
  annoyed: ['half', 'half', 'cross', 'cross', 'flat'], determined: ['open', 'open', 'cross', 'cross', 'w'], wink: ['happy', 'open', 'none', 'up', 'blep'],
  proud: ['happy', 'happy', 'up', 'up', 'w'], munch: ['happy', 'happy', 'none', 'none', 'chew']
};
const EXPR_NODES = ['eye_L', 'eye_R', 'brow_L', 'brow_R', 'mouth'];

G.PipArt = { INK, CREAM, SKINS, TOKENS, SPR, OV, FX, RIGS, EXPR, EXPR_NODES, helpers: { P, E, S, fluff, petal, flower, star4, star5 } };
})(typeof window !== 'undefined' ? window : globalThis);
