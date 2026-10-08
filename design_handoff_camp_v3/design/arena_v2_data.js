// Merge Arena v2 — jedini izvor istine za mockup i za godot/arena_v2_export.json.
// Sve mjere su px baze 1080 x 1920; polje (Bg) je 1080 x 1633, playfield 1080 x 1589 od vrha stranice.
// Livade su RECEPT: boje + poligoni u % (x od 1080, y od 1633) + rasuti elementi (R2 niz, bez RNG-a).

export const W = 1080, H = 1633, FIELD_H = 1589;
const fr = x => x - Math.floor(x);
const clamp01 = x => Math.max(0, Math.min(1, x));
const r2 = v => Math.round(v * 100) / 100;

// ── Boje i kontrast ─────────────────────────────────────────────────────────
function parseHex(h) { const s = h.replace('#', ''); const v = [0, 2, 4, 6].map(i => i < s.length ? parseInt(s.substr(i, 2), 16) : 255); return v; }
function toHex(v, alpha) { const b = v.slice(0, 3).map(x => Math.round(Math.max(0, Math.min(255, x))).toString(16).padStart(2, '0')).join(''); return '#' + b.toUpperCase() + (alpha ? Math.round(v[3]).toString(16).padStart(2, '0').toUpperCase() : ''); }
export function lerpHex(a, b, t) { const A = parseHex(a), B = parseHex(b); const hasA = a.length > 7 || b.length > 7; return toHex(A.map((x, i) => x + (B[i] - x) * t), hasA); }
export function over(top, bottom) { const T = parseHex(top), B = parseHex(bottom); const a = T[3] / 255; return toHex([0, 1, 2].map(i => T[i] * a + B[i] * (1 - a))); }
export function lum(hex) { const v = parseHex(hex).slice(0, 3).map(c => { c /= 255; return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4); }); return 0.2126 * v[0] + 0.7152 * v[1] + 0.0722 * v[2]; }
export function contrast(a, b) { const x = lum(a), y = lum(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); }
export function hsv(h, s, v) { h = fr(h) * 6; const i = Math.floor(h), f = h - i, p = v * (1 - s), q = v * (1 - s * f), t = v * (1 - s * (1 - f)); const m = [[v, t, p], [q, v, p], [p, v, t], [p, q, v], [t, p, v], [v, p, q]][i % 6]; return toHex(m.map(x => x * 255)); }

// ── Pravilo dvostrukog ruba ────────────────────────────────────────────────
// Svaki objekat igre na polju ima taman vanjski rub (ink) i svijetlu traku odmah do njega.
// Za bilo koju boju polja jedna od te dvije ivica ima >= 3:1 (dokaz: najgori slucaj je
// L_polja + 0.05 = sqrt((L_svijetlo + 0.05)(L_ink + 0.05))).
export const DUAL_EDGE = {
  seed: { ink: '#2D3436', light: '#FFF8F0', label: 'Sjemenka' },
  muncher: { ink: '#3E2856', light: '#FFEAA7', label: 'Muncher' },
  basket: { ink: '#3A2A1B', light: '#F0DDB4', label: 'Korpa' },
  pip: { ink: '#2D3436', light: '#A8E6CF', label: 'Pip' }
};
export function worstCase(ink, light) { const a = lum(light) + 0.05, b = lum(ink) + 0.05; return Math.sqrt(a / b); }
export function edgeContrast(obj, fieldHex) { const e = DUAL_EDGE[obj]; return Math.max(contrast(e.ink, fieldHex), contrast(e.light, fieldHex)); }

// ── Tokeni ──────────────────────────────────────────────────────────────────
export const SEED = {
  radius: 67.2, base_w: 4, base: '#2D3436', t2_corner: 38, t2_base_corner: 42,
  rim: '#FFF8F0', rim_edge: '#CBC2B6', well: '#22342A', well_edge: '#16211B',
  gold: '#FFD56B', gold_edge: '#D6A82F', shadow: 'rgba(20,32,26,.42)', shadow_y: 6,
  note: 'SeedBase = rim.grow(4), crta se prvi (ispod sjene i rima). 4 px = (CHIP_MIN_DIST 142.8 - 134.4) / 2, pa se dvije baze nikad ne preklapaju.'
};

export const MUNCHER = {
  head_r: 50, segments: [38, 32, 26], edge_w: 4, eat_radius: 36, speed: 85, eat_sec: 0.5, wake_sec: 0.3, freeze_sec: 2.0,
  colors: {
    body: '#A275CD', body_deep: '#946AC0', edge: '#3E2856', spot: '#FFEAA7',
    asleep_body: '#8C61B8', asleep_deep: '#7F58A8', asleep_edge: '#3E2856',
    frozen_body: '#A6D1FA', frozen_deep: '#95C3EE', frozen_edge: '#4F7FAE', frozen_spot: '#E8F6FF',
    mouth: '#3B2350', tongue: '#FF9FB4', tooth: '#FFF8F0', eye: '#FFFFFF', ink: '#2D3436',
    ice: 'rgba(232,246,255,.58)', ice_edge: '#DCF0FF', ice_hi: '#FFFFFF', alarm: '#FFEAA7',
    shadow: 'rgba(20,26,22,.30)'
  },
  // Poze: pomaci segmenata od centra glave (px) — iste u Godotu (lokalno, prije nagiba).
  poses: {
    sleep: { segs: [[-60, 18], [-40, 56], [4, 64]], head_rot: 8, antenna: [[-34, -58], [30, -60]] },
    wake: { segs: [[56, 10], [98, -2], [134, -22]], head_rot: 0, antenna: [[-22, -80], [22, -80]] },
    hunt: { spacing: [56, 102, 144], wave: 8, head_rot: -6, antenna: [[-30, -74], [26, -76]] },
    eat: { spacing: [44, 80, 110], wave: 4, head_rot: 0, head_scale: 1.08, antenna: [[-38, -62], [38, -62]] },
    frozen: { spacing: [56, 102, 144], wave: 0, head_rot: 0, antenna: [[-24, -76], [24, -76]] }
  },
  nest: { w: 250, h: 112, bed_w: 206, bed_h: 78, fill: '#9E7A52', edge: '#735738', bed: '#6E5238', bed_edge: '#543E2A', petals: ['#FFCCD5', '#FFEAA7', '#D4A5FF', '#B8E0F5', '#FFCCD5'] },
  zzz: { sizes: [26, 32, 38], offsets: [[58, -30], [82, -46], [108, -58]], fill: '#FFF8F0', outline: 6 },
  timing: { bob_period: 0.6, bob_amp: 5, chomp_period: 0.25, freeze_in: 0.18, freeze_out: 0.25, wake_pop: 0.12 }
};

export const BASKET = {
  hit: [300, 280], bottom_gap: 40, pivot: [150, 272], tilt_pour: -12, tilt_in: 0.1, tilt_out: 0.25,
  colors: { wicker: '#C99A5F', weave: '#A87B48', rim: '#F0DDB4', rim_weave: '#D8BC8A', edge: '#3A2A1B', handle: '#B88A55', opening: '#5A4230', cloth: '#FFB88C', cloth_edge: '#E8A374', cloth_dot: '#FFF8F0', counter: '#FFF8F0', counter_edge: '#CBC2B6', counter_ink: '#2D3436', shadow: 'rgba(20,26,22,.28)' },
  counter: { c: [252, 236], r: 42, font: 44 },
  // 12 mjesta za cvijet koji viri: [x, y, velicina, rotacija]; red popunjavanja = redoslijed niza.
  pile: [
    [150, 138, 62, -4], [110, 141, 60, 8], [190, 141, 60, 12], [70, 147, 56, -14], [230, 147, 56, -10],
    [132, 103, 62, -8], [172, 103, 62, 6], [92, 109, 58, 10], [212, 109, 58, -12],
    [154, 66, 64, 4], [114, 72, 60, -6], [194, 74, 60, 12]
  ],
  visible_rule: 'count <= 0 ? 0 : clamp(round(count * 12 / 40), 1, 12)',
  max_seeds: 40
};
export function basketVisible(count) { return count <= 0 ? 0 : Math.max(1, Math.min(12, Math.round(count * 12 / 40))); }

export const COMBO = {
  window: 1.4, coin_at: 5,
  steps: [
    { n: 2, mark: 52, ring: 260, light: 0.04, bow: false, gold: false, pip: 'hop' },
    { n: 3, mark: 58, ring: 320, light: 0.07, bow: false, gold: false, pip: 'hop' },
    { n: 4, mark: 64, ring: 380, light: 0.10, bow: true, gold: false, pip: 'hop' },
    { n: 5, mark: 70, ring: 380, light: 0.13, bow: true, gold: true, pip: 'big', coin: true },
    { n: 6, mark: 70, ring: 380, light: 0.13, bow: true, gold: true, pip: 'hop' }
  ],
  mark: { rise_from: -78, rise_to: -128, pop_in: 0.18, hold: 0.30, fade: 0.25, outline: 8, fill: '#FFF8F0', gold: '#FFD56B', ink: '#2D3436' },
  ripple: { from_r: 90, width: 10, alpha: 0.55, sec: 0.5 },
  light: { in_sec: 0.2, out_sec: 0.35 },
  bow: { scale: 1.18, sec: 0.3, delay_per_ring: 0.25 },
  pip: { hop: [1.18, 0.28], big: [1.26, 0.36] },
  coin: { size: 56, sec: 0.5 }
};
export function comboStep(n) { if (n < 2) return null; return COMBO.steps[Math.min(n, 6) - 2]; }

// ── Oblici rasutih elemenata (jedinica = velicina elementa; y raste nadole) ────
// ['c',cx,cy,r,ci] krug · ['e',cx,cy,rx,ry,ci] elipsa · ['p',[[x,y]..],ci] poligon
// ['l',x1,y1,x2,y2,w,ci] linija (okrugli kraj) · ['a',cx,cy,r,a0,a1,w,ci] luk (stepeni) · ['r',x,y,w,h,rad,ci]
const star = (n, ro, ri, rot = -90) => { const p = []; for (let i = 0; i < n * 2; i++) { const a = (rot + i * 180 / n) * Math.PI / 180, r = i % 2 ? ri : ro; p.push([r2(Math.cos(a) * r * 100) / 100, r2(Math.sin(a) * r * 100) / 100]); } return p; };
const petals = (n, dist, r, ci, rot = -90) => Array.from({ length: n }, (_, k) => { const a = (rot + k * 360 / n) * Math.PI / 180; return ['c', r2(Math.cos(a) * dist * 100) / 100, r2(Math.sin(a) * dist * 100) / 100, r, ci]; });
const halfEllipse = (cx, cy, rx, ry, n = 12) => Array.from({ length: n + 1 }, (_, k) => { const a = Math.PI + Math.PI * k / n; return [r2((cx + Math.cos(a) * rx) * 100) / 100, r2((cy + Math.sin(a) * ry) * 100) / 100]; });

export const SHAPES = {
  tuft: [['p', [[-0.5, 0], [-0.3, -0.78], [-0.12, 0]], 0], ['p', [[-0.18, 0], [0.02, -1], [0.2, 0]], 0], ['p', [[0.1, 0], [0.34, -0.7], [0.5, 0]], 0]],
  blade: [['p', [[-0.07, 0], [0.03, -1], [0.09, 0]], 0]],
  clover: [['c', -0.2, 0.06, 0.21, 0], ['c', 0.2, 0.06, 0.21, 0], ['c', 0, -0.24, 0.21, 0]],
  daisy: [...petals(5, 0.28, 0.18, 0), ['c', 0, 0, 0.15, 1]],
  primrose: [...petals(4, 0.22, 0.2, 0, -45), ['c', 0, 0, 0.1, 1]],
  stone: [['e', 0, 0, 0.5, 0.32, 0], ['e', -0.12, -0.1, 0.2, 0.09, 1]],
  post: [['r', -1.3, -0.78, 2.6, 0.1, 0, 1], ['r', -1.3, -0.46, 2.6, 0.1, 0, 1], ['r', -0.1, -1, 0.2, 1, 0.04, 0], ['p', [[-0.12, -1], [0, -1.12], [0.12, -1]], 0]],
  tree: [['r', -0.05, -0.5, 0.1, 0.5, 0, 1], ['c', -0.2, -0.6, 0.19, 0], ['c', 0.2, -0.6, 0.19, 0], ['c', 0, -0.72, 0.3, 0]],
  drift: [['e', -0.24, 0, 0.3, 0.14, 0], ['e', 0.08, -0.05, 0.34, 0.19, 0], ['e', 0.36, 0.02, 0.2, 0.11, 0]],
  puddle: [['e', 0, 0, 0.5, 0.17, 0], ['e', -0.12, -0.04, 0.2, 0.035, 1]],
  sparkle: [['p', star(4, 0.5, 0.12), 0]],
  dot: [['c', 0, 0, 0.5, 0]],
  lantern: [['l', 0, 0, 0, 0.36, 0.035, 2], ['r', -0.15, 0.33, 0.3, 0.08, 0.02, 2], ['e', 0, 0.68, 0.28, 0.3, 0], ['e', 0, 0.68, 0.1, 0.3, 1], ['r', -0.08, 0.97, 0.16, 0.05, 0.02, 2]],
  firefly: [['c', 0, 0, 0.5, 1], ['c', 0, 0, 0.22, 0]],
  leaf: [['p', [[0, -0.5], [0.2, -0.22], [0.22, 0.12], [0, 0.5], [-0.22, 0.12], [-0.2, -0.22]], 0], ['l', 0, -0.4, 0, 0.44, 0.05, 1]],
  acorn: [['e', 0, 0.1, 0.26, 0.32, 0], ['e', 0, -0.16, 0.3, 0.14, 1], ['l', 0, -0.28, 0.07, -0.44, 0.07, 1]],
  mushroom: [['r', -0.1, -0.34, 0.2, 0.34, 0.05, 1], ['p', halfEllipse(0, -0.3, 0.42, 0.28), 0], ['c', -0.14, -0.42, 0.06, 1], ['c', 0.12, -0.46, 0.05, 1]],
  dapple: [['e', 0, 0, 0.5, 0.28, 0]],
  burrow: [['e', 0, 0, 0.5, 0.3, 1], ['e', 0, 0.05, 0.38, 0.2, 0]],
  moss: [['c', -0.22, 0, 0.24, 0], ['c', 0.1, -0.06, 0.28, 0], ['c', 0.34, 0.05, 0.18, 0]],
  pebble: [['e', 0, 0, 0.5, 0.34, 0]],
  moon: [['c', 0, 0, 0.5, 0], ['c', -0.16, -0.08, 0.1, 1], ['c', 0.18, 0.14, 0.07, 1], ['c', 0.06, -0.26, 0.05, 1]],
  shell: [['p', [[-0.5, 0.12], [-0.44, -0.16], [-0.28, -0.38], [0, -0.47], [0.28, -0.38], [0.44, -0.16], [0.5, 0.12], [0.14, 0.24], [-0.14, 0.24]], 0], ['l', 0, 0.18, -0.3, -0.28, 0.05, 1], ['l', 0, 0.18, 0, -0.4, 0.05, 1], ['l', 0, 0.18, 0.3, -0.28, 0.05, 1], ['e', 0, 0.22, 0.14, 0.08, 1]],
  starfish: [['p', star(5, 0.5, 0.21), 0]],
  ripple: [['a', 0, 0, 0.5, 200, 340, 0.06, 0], ['a', 0, 0.14, 0.32, 212, 328, 0.06, 0]],
  coral: [['l', 0, 0, 0, -0.62, 0.12, 0], ['l', 0, -0.3, -0.26, -0.56, 0.11, 0], ['l', 0, -0.42, 0.24, -0.72, 0.1, 0], ['l', -0.26, -0.56, -0.3, -0.82, 0.09, 0], ['c', -0.3, -0.84, 0.07, 0], ['c', 0.24, -0.74, 0.07, 0], ['c', 0, -0.64, 0.07, 0]],
  thrift: [['l', 0, 0, 0, -0.62, 0.05, 1], ['c', 0, -0.72, 0.22, 0], ['c', -0.08, -0.78, 0.05, 2], ['c', 0.07, -0.67, 0.05, 2]],
  fern: [['p', [[-0.5, 0], [0, -0.34], [0.5, 0]], 0], ['p', [[-0.4, -0.24], [0, -0.6], [0.4, -0.24]], 0], ['p', [[-0.28, -0.5], [0, -0.86], [0.28, -0.5]], 0]],
  meteor: [['l', -0.5, 0, 0.36, 0, 0.05, 1], ['c', 0.4, 0, 0.09, 0]],
  cattail: [['l', 0, 0, 0.02, -1, 0.04, 1], ['l', 0, 0, -0.18, -0.6, 0.035, 1], ['e', 0.015, -0.74, 0.07, 0.16, 0]],
  ember: [['c', 0, 0, 0.5, 0], ['c', 0, 0, 0.22, 1]],
  iris: [['p', [[0, 0.32], [-0.26, 0], [-0.12, -0.34], [0, -0.6], [0.12, -0.34], [0.26, 0]], 0], ['p', [[0, 0.2], [-0.12, 0], [0, -0.3], [0.12, 0]], 1]],
  glint: [['e', 0, 0, 0.5, 0.06, 0]]
};

// ── Pomocni generatori (samo za autorstvo; export nosi razrijesene tacke) ─────
function cr(p0, p1, p2, p3, t) { const t2 = t * t, t3 = t2 * t; return [0, 1].map(k => 0.5 * ((2 * p1[k]) + (-p0[k] + p2[k]) * t + (2 * p0[k] - 5 * p1[k] + 4 * p2[k] - p3[k]) * t2 + (-p0[k] + 3 * p1[k] - 3 * p2[k] + p3[k]) * t3)); }
function smoothOpen(pts, steps = 8) { const out = []; for (let i = 0; i < pts.length - 1; i++) { const p0 = pts[Math.max(0, i - 1)], p1 = pts[i], p2 = pts[i + 1], p3 = pts[Math.min(pts.length - 1, i + 2)]; for (let s = 0; s < steps; s++) out.push(cr(p0, p1, p2, p3, s / steps)); } out.push(pts[pts.length - 1]); return out; }
function smoothClosed(pts, steps = 8) { const n = pts.length, out = []; for (let i = 0; i < n; i++) { const p0 = pts[(i - 1 + n) % n], p1 = pts[i], p2 = pts[(i + 1) % n], p3 = pts[(i + 2) % n]; for (let s = 0; s < steps; s++) out.push(cr(p0, p1, p2, p3, s / steps)); } return out; }
function hash(i, seed) { return fr(Math.sin(i * 12.9898 + seed * 78.233) * 43758.5453); }
function spikes(x0, x1, step, yTop, yBot, seed, jit = 1) { const pts = []; let i = 0; for (let x = x0; x <= x1 + 0.001; x += step / 2, i++) { const tip = i % 2 === 1; pts.push([x + (tip ? (hash(i, seed + 7) - 0.5) * step * 0.3 : 0), tip ? yTop + hash(i, seed) * jit : yBot - hash(i, seed + 3) * jit * 0.6]); } return pts; }
function ellipsePts(cx, cy, rx, ry, n = 48) { return Array.from({ length: n }, (_, k) => { const a = Math.PI * 2 * k / n; return [cx + Math.cos(a) * rx, cy + Math.sin(a) * ry]; }); }
const mirror = poly => poly.map(([x, y]) => [100 - x, y]);
const shift = (pts, dy) => pts.map(([x, y]) => [x, y + dy]);
const swag = x => x <= 50 ? 2.8 + 3.8 * Math.sin(Math.PI * (x + 2) / 52) : 2.8 + 3.8 * Math.sin(Math.PI * (x - 50) / 52);
const DOWN = [[102, 101], [-2, 101]], UP = [[102, -1], [-2, -1]];

// Elementi ne crtaju centar u ovim zonama (gnijezdo, korpa, Pip) osim ako tip ima noAvoid.
export const AVOID = [[36.5, 0, 27, 11.5], [34, 76.5, 32, 23.5], [0, 85, 19, 15]];

// ── Osam livada ─────────────────────────────────────────────────────────────
// layer.kind: poly (edge + close, smooth) · polys (eksplicitni) · blob (zatvoren, smooth) · ellipse (c %, r %) · line (w px) · shape
// scatter: zones [[x,y,w,h] %], n [nivo0, nivo4], size [min,max] px, grow [x0,x4], rot [min,max] °, phase [px,py,ps,pr]
const FIELD_SRC = [
  {
    id: 'country_bloom', name: 'Country Bloom', tagline: 'Warm fields, soft petals, home pastures.', mood: '#E6F2DB',
    place: 'Pašnjak kod kuće: valoviti brežuljci, ograda na grebenu, pokošena trava.',
    base: ['#EAF3DF', '#EEF6E2'],
    layers: [
      { id: 'hills_far', kind: 'poly', edge: [[-2, 11.5], [10, 9.2], [22, 10.4], [34, 11.8], [46, 10.2], [58, 9.0], [70, 10.6], [82, 11.6], [92, 10.0], [102, 9.6]], close: DOWN, fill: ['#BCD9A3', '#B1D795'] },
      { id: 'hills_mid', kind: 'poly', edge: [[-2, 15.4], [12, 13.8], [26, 14.8], [40, 16.2], [54, 15.0], [68, 13.6], [82, 14.6], [94, 15.8], [102, 15.2]], close: DOWN, fill: ['#98C27F', '#8EC273'] },
      { id: 'pasture', kind: 'poly', ground: true, edge: [[-2, 19.5], [16, 18.4], [34, 19.6], [52, 20.6], [70, 19.2], [86, 18.2], [102, 19.0]], close: DOWN, fill: ['#7DAA67', '#73AA5A'] }
    ],
    scatter: [
      { id: 'fence', shape: 'post', zones: [[0, 16.9, 100, 0]], even: true, noAvoid: true, n: [14, 14], size: [46, 46], palette: ['#F4EAD6', '#DCCDB0'], phase: [0, 0, 0, 0] },
      { id: 'tuft', shape: 'tuft', zones: [[2, 21, 96, 77]], n: [16, 30], size: [34, 56], grow: [1, 1.4], rot: [-6, 6], palette: ['#6A9857'], phase: [0.11, 0.37, 0.53, 0.71] },
      { id: 'clover', shape: 'clover', zones: [[2, 21, 96, 77]], n: [7, 12], size: [30, 42], palette: ['#8FBC78'], phase: [0.63, 0.19, 0.27, 0.4] },
      { id: 'stone', shape: 'stone', zones: [[3, 24, 94, 70]], n: [5, 5], size: [30, 52], palette: ['#97B489', '#B2CAA5'], phase: [0.29, 0.83, 0.61, 0.1] },
      { id: 'daisy', shape: 'daisy', zones: [[2, 21, 96, 77]], n: [0, 22], size: [20, 28], rot: [0, 72], palette: ['#FFF8F0', '#FFD56B'], phase: [0.47, 0.05, 0.9, 0.33] },
      { id: 'buttercup', shape: 'daisy', zones: [[2, 21, 96, 77]], n: [0, 12], size: [16, 22], rot: [0, 72], palette: ['#FFEAA7', '#E8C44A'], phase: [0.83, 0.71, 0.12, 0.66] }
    ],
    lush: 'Trava izraste (+40 %), preko pašnjaka procvjeta 22 tratinčice i 12 ljutića, zelena postaje sočnija.',
    combo: { light: '#FFEAA7', ring: '#FFF8F0' }
  },
  {
    id: 'frost_orchard', name: 'Frost Orchard', tagline: 'Crisp air, silver blossom.', mood: '#D1E6FF',
    place: 'Smrznuti voćnjak: ravan horizont, dva reda stabala, nanosi snijega i zaleđene lokve.',
    base: ['#E3EEFB', '#E9F2FC'],
    layers: [
      { id: 'snowfield', kind: 'poly', edge: [[-2, 14.2], [30, 13.8], [60, 14.2], [102, 13.9]], close: DOWN, fill: ['#C7D8EC', '#CCDDF0'] },
      { id: 'frost_ground', kind: 'poly', ground: true, edge: [[-2, 17.2], [25, 16.9], [50, 17.3], [75, 16.8], [102, 17.1]], close: DOWN, fill: ['#9FB6CF', '#A7BFD8'] },
      { id: 'drifts_near', kind: 'poly', edge: [[-2, 90], [8, 87.5], [18, 89.5], [30, 86.8], [42, 89.2], [55, 87.4], [66, 89.6], [78, 86.6], [90, 88.8], [102, 87.2]], close: DOWN, fill: ['#C3D5EA', '#CADBEE'] }
    ],
    scatter: [
      { id: 'trees_far', shape: 'tree', zones: [[2, 14.0, 96, 0]], even: true, noAvoid: true, n: [12, 12], size: [62, 62], palette: ['#B3C7DE', '#8C9FB8'], phase: [0, 0, 0, 0] },
      { id: 'trees_near', shape: 'tree', zones: [[4, 17.4, 92, 0]], even: true, noAvoid: true, n: [7, 7], size: [104, 104], palette: ['#A3BAD4', '#7F93AD'], phase: [0, 0, 0, 0] },
      { id: 'drift', shape: 'drift', zones: [[2, 20, 96, 64]], n: [6, 9], size: [110, 170], palette: ['#B6CAE0'], phase: [0.21, 0.66, 0.35, 0] },
      { id: 'puddle', shape: 'puddle', zones: [[4, 24, 92, 56]], n: [3, 4], size: [90, 130], palette: ['#8FA8C4', '#D2E2F4'], phase: [0.77, 0.14, 0.52, 0] },
      { id: 'blossom', shape: 'dot', zones: [[1, 7.5, 98, 9]], noAvoid: true, n: [0, 34], size: [8, 13], palette: ['#FFFFFF'], phase: [0.37, 0.58, 0.2, 0] },
      { id: 'sparkle', shape: 'sparkle', zones: [[2, 19, 96, 78]], n: [0, 16], size: [14, 22], rot: [0, 45], palette: ['#F4F9FF'], phase: [0.05, 0.93, 0.44, 0.3] }
    ],
    lush: 'Krošnje procvjetaju srebrnim cvijetom (34 bijele tačke u redu stabala), po tlu zasja 16 iskrica inja, tlo posvijetli.',
    combo: { light: '#FFFFFF', ring: '#FFFFFF' }
  },
  {
    id: 'lantern_meadow', name: 'Lantern Meadow', tagline: 'Dusk lights among tall grass.', mood: '#EBD6FF',
    place: 'Livada u sumrak: visoka trava uokviruje polje sa strana, girlanda fenjera gore.',
    base: ['#CDB6E6', '#D5BFEC'],
    layers: [
      { id: 'far_grass', kind: 'poly', smooth: false, edge: spikes(-2, 102, 3.2, 8.2, 13.2, 3, 1.6), close: DOWN, fill: ['#584C7C', '#5D5184'] },
      { id: 'dusk_ground', kind: 'poly', ground: true, edge: [[-2, 14.5], [20, 14], [40, 14.6], [60, 14.1], [80, 14.7], [102, 14.2]], close: DOWN, fill: ['#463E66', '#4A4270'] },
      { id: 'side_grass', kind: 'polys', polys: (() => { const L = [[0, 20], [4.5, 26], [1.5, 28], [7, 36], [2, 38], [6, 47], [1.8, 50], [8, 60], [2.2, 63], [6.5, 72], [2, 75], [7.5, 84], [2.5, 87], [5, 95], [0, 100]]; return [L, mirror(shift(L, 3))]; })(), fill: ['#362F52', '#342D52'] },
      { id: 'garland', kind: 'line', edge: Array.from({ length: 27 }, (_, i) => [-2 + i * 4, swag(-2 + i * 4)]), smooth: true, w: 5, fill: ['#2E2745', '#2E2745'] }
    ],
    scatter: (() => {
      const xs = [22, 78, 6, 94, 38, 62, 14, 86, 30, 70];
      const at = xs.map(x => [x, r2(swag(x) + 0.1)]);
      return [
        { id: 'lantern_dim', shape: 'lantern', at, noAvoid: true, n: [10, 10], size: [72, 72], palette: ['#7E6698', '#958099', '#2E2745'], phase: [0, 0, 0, 0] },
        { id: 'lantern_lit', shape: 'lantern', at, noAvoid: true, n: [3, 10], size: [72, 72], palette: ['#FFB88C', '#FFE3B8', '#2E2745'], phase: [0, 0, 0, 0] },
        { id: 'blade', shape: 'blade', zones: [[8, 16, 84, 82]], n: [14, 26], size: [50, 90], grow: [1, 1.35], rot: [-8, 8], palette: ['#554C7A'], phase: [0.15, 0.62, 0.8, 0.45] },
        { id: 'firefly', shape: 'firefly', zones: [[6, 16, 88, 80]], n: [6, 26], size: [14, 22], palette: ['#FFEAA7', '#FFEAA74D'], phase: [0.42, 0.28, 0.66, 0] },
        { id: 'primrose', shape: 'primrose', zones: [[8, 18, 84, 78]], n: [0, 16], size: [18, 26], rot: [0, 90], palette: ['#FFEAA7', '#E8C44A'], phase: [0.9, 0.47, 0.31, 0.2] }
      ];
    })(),
    lush: 'Upali se svih 10 fenjera (3 → 10), svitaca bude 26, trava naraste, procvjeta 16 noćurki.',
    combo: { light: '#FFD08A', ring: '#FFE3B8' }
  },
  {
    id: 'amber_canopy', name: 'Amber Canopy', tagline: 'Warm late-season light through high leaves.', mood: '#FFEBC7',
    place: 'Šumsko tlo pod visokom krošnjom: lišće visi odozgo, dva stabla sa strane, snopovi svjetla i mrlje sunca.',
    base: ['#7F5C3B', '#83603D'], baseGround: true,
    layers: [
      { id: 'light_beams', kind: 'polys', polys: [[[20, 10], [27, 10], [14, 70], [4, 70]], [[56, 11], [62, 11], [48, 74], [40, 74]], [[82, 10], [88, 10], [76, 66], [68, 66]]], fill: ['#FFEBC714', '#FFEBC71F'] },
      { id: 'trunks', kind: 'polys', polys: [[[-1, -1], [5.5, -1], [6.5, 40], [5, 72], [7, 101], [-1, 101]], [[101, -1], [94.5, -1], [93.2, 46], [95, 80], [93.6, 101], [101, 101]]], fill: ['#5E4127', '#5E4127'] },
      { id: 'canopy_back', kind: 'poly', edge: [[-2, 11], [6, 14.5], [14, 12], [22, 15.2], [30, 12.4], [38, 14.8], [46, 12.2], [54, 15.4], [62, 12.6], [70, 15], [78, 12], [86, 14.6], [94, 12.2], [102, 14]], close: UP, fill: ['#6E4A26', '#6C4E25'] },
      { id: 'canopy_front', kind: 'poly', edge: [[-2, 6.5], [5, 9.8], [12, 7.2], [19, 10.4], [27, 7.6], [35, 9.6], [43, 6.8], [52, 9.2], [60, 7], [68, 10], [76, 7.4], [84, 10.2], [92, 7.6], [102, 9]], close: UP, fill: ['#B7792F', '#C98A3A'] }
    ],
    scatter: [
      { id: 'dapple', shape: 'dapple', zones: [[8, 20, 84, 76]], n: [5, 10], size: [100, 170], palette: ['#9C774E'], phase: [0.33, 0.12, 0.7, 0] },
      { id: 'leaf', shape: 'leaf', zones: [[7, 18, 86, 80]], n: [14, 34], size: [26, 40], rot: [0, 360], variants: [['#D98C4A', '#A9652F'], ['#E6AE55', '#B98535'], ['#C8703E', '#95502A']], phase: [0.58, 0.36, 0.14, 0.9] },
      { id: 'acorn', shape: 'acorn', zones: [[8, 22, 84, 74]], n: [3, 8], size: [20, 26], rot: [-25, 25], palette: ['#B07A44', '#6E4A28'], phase: [0.08, 0.77, 0.5, 0.25] },
      { id: 'mushroom', shape: 'mushroom', zones: [[8, 24, 84, 70]], n: [2, 7], size: [28, 40], palette: ['#E8805A', '#FFF1DC'], phase: [0.72, 0.55, 0.3, 0] }
    ],
    lush: 'Krošnja se pozlati, sunčevih mrlja je 10 (bilo 5), lišća 34 (bilo 14), iznikne 7 gljiva i 8 žireva.',
    combo: { light: '#FFD56B', ring: '#FFEBC7' }
  },
  {
    id: 'moonlit_warren', name: 'Moonlit Warren', tagline: 'Night blooms under a quiet moon.', mood: '#B8BDFF',
    place: 'Zečje brdo noću: veliki mjesec, humke, rupe jazbina u tlu.',
    base: ['#252A55', '#282E5C'],
    layers: [
      { id: 'moon', kind: 'shape', shape: 'moon', at: [80, 5.2], size: 150, palette: ['#EDEBFF', '#D2D0F2'] },
      { id: 'mounds_far', kind: 'poly', edge: [[-2, 15], [6, 12.4], [14, 11.2], [22, 12.8], [30, 14.4], [40, 12.2], [50, 10.8], [60, 12.6], [70, 14], [80, 12], [90, 11.6], [102, 13.4]], close: DOWN, fill: ['#323868', '#343B6E'] },
      { id: 'warren_ground', kind: 'poly', ground: true, edge: [[-2, 18.4], [18, 17.6], [36, 18.6], [54, 19.2], [72, 18], [90, 17.4], [102, 18.2]], close: DOWN, fill: ['#3B4175', '#3E457C'] },
      { id: 'mounds_near', kind: 'polys', smooth: true, polys: [[[-2, 101], [-2, 82], [6, 79.6], [14, 80.4], [21, 83.2], [27, 88], [31, 101]], [[102, 101], [102, 80.5], [94, 78.6], [86, 79.8], [78, 83], [72, 88], [68, 101]]], fill: ['#474E88', '#4A528E'] }
    ],
    scatter: [
      { id: 'sky_star', shape: 'dot', zones: [[2, 1, 70, 9]], noAvoid: true, n: [10, 16], size: [5, 8], palette: ['#DCDDFF'], phase: [0.61, 0.24, 0.5, 0] },
      { id: 'burrow', shape: 'burrow', zones: [[8, 24, 84, 54]], n: [4, 6], size: [80, 110], palette: ['#1E2244', '#50579A'], phase: [0.27, 0.49, 0.18, 0] },
      { id: 'moss', shape: 'moss', zones: [[4, 20, 92, 76]], n: [9, 18], size: [30, 46], palette: ['#4C5494'], phase: [0.83, 0.07, 0.39, 0] },
      { id: 'glint', shape: 'sparkle', zones: [[4, 19, 92, 78]], n: [3, 14], size: [12, 18], rot: [0, 45], palette: ['#CFD3FF'], phase: [0.12, 0.88, 0.63, 0.5] },
      { id: 'night_bloom', shape: 'daisy', zones: [[4, 20, 92, 76]], n: [0, 18], size: [18, 26], rot: [0, 72], palette: ['#E6E4FF', '#FFEAA7'], phase: [0.5, 0.33, 0.77, 0.1] }
    ],
    lush: 'Otvori se 18 noćnih cvjetova, rosa zasja na 14 mjesta (bilo 3), mahovina se udvostruči, na nebu 16 zvijezda.',
    combo: { light: '#B8BDFF', ring: '#E6E4FF' }
  },
  {
    id: 'coral_tide', name: 'Coral Tide Garden', tagline: 'Salt breeze and seashell petals.', mood: '#FFE0D6',
    place: 'Plićak i pijesak: obala dijagonalno preko polja, pjena, mokar i suh pijesak.',
    base: ['#5FAEB3', '#63B4B8'],
    layers: (() => {
      const shore = [[-2, 46], [8, 44.2], [18, 45.4], [28, 42.6], [38, 43.4], [48, 40.4], [58, 41], [68, 37.8], [78, 38.6], [88, 35.4], [102, 35.8]];
      return [
        { id: 'shallows', kind: 'poly', edge: [[-2, 9], [20, 10.2], [45, 8.8], [70, 10.4], [102, 9.2]], close: DOWN, fill: ['#86C9C6', '#8BCECB'] },
        { id: 'foam', kind: 'poly', edge: shore, close: DOWN, fill: ['#F4FAF6', '#F4FAF6'] },
        { id: 'wet_sand', kind: 'poly', edge: shift(shore, 1.3), close: DOWN, fill: ['#D69C82', '#D8A086'] },
        { id: 'dry_sand', kind: 'poly', ground: true, edge: [[-2, 52.5], [14, 51], [30, 49.2], [46, 47.6], [62, 45.4], [78, 43.6], [102, 41.6]], close: DOWN, fill: ['#E2B196', '#E5B69A'] }
      ];
    })(),
    scatter: [
      { id: 'ripple', shape: 'ripple', zones: [[4, 12, 92, 24]], n: [6, 10], size: [60, 100], palette: ['#B8E2DE'], phase: [0.19, 0.4, 0.6, 0] },
      { id: 'pebble', shape: 'pebble', zones: [[4, 52, 92, 46]], n: [7, 7], size: [16, 30], palette: ['#C99A84'], phase: [0.7, 0.2, 0.45, 0] },
      { id: 'shell', shape: 'shell', zones: [[4, 54, 92, 44]], n: [6, 14], size: [30, 44], rot: [-30, 30], variants: [['#FFF1E8', '#E9C2AE'], ['#FFCCD5', '#E8A3B1']], phase: [0.36, 0.81, 0.27, 0.6] },
      { id: 'starfish', shape: 'starfish', zones: [[6, 56, 88, 40]], n: [2, 6], size: [34, 46], rot: [0, 72], palette: ['#F29B80'], phase: [0.93, 0.52, 0.15, 0.37] },
      { id: 'coral', shape: 'coral', zones: [[4, 42, 92, 8]], n: [0, 7], size: [44, 64], rot: [-12, 12], palette: ['#F59A8B'], phase: [0.44, 0.66, 0.08, 0.9] },
      { id: 'thrift', shape: 'thrift', zones: [[4, 56, 92, 40]], n: [0, 12], size: [30, 40], rot: [-8, 8], palette: ['#FFB3C1', '#7FA46E', '#FFE0E6'], phase: [0.11, 0.29, 0.73, 0.2] }
    ],
    lush: 'Na rubu plime izraste 7 koralja, pijesak se napuni školjkama (6 → 14) i morskim karanfilima (12), voda se razbistri.',
    combo: { light: '#FFCCD5', ring: '#FFFFFF' }
  },
  {
    id: 'starfall_glade', name: 'Starfall Glade', tagline: 'Petals that catch the night sky.', mood: '#DBCCFF',
    place: 'Proplanak u šumi jela: jele u prstenu oko čistine, zvjezdano nebo, meteori.',
    base: ['#2A2350', '#2D2656'],
    layers: [
      { id: 'firs_back', kind: 'poly', smooth: false, edge: spikes(-2, 102, 7, 7.6, 15.6, 11, 2.0), close: DOWN, fill: ['#221C42', '#231D45'] },
      { id: 'glade_ground', kind: 'poly', ground: true, edge: [[-2, 19.5], [25, 18.6], [50, 19.8], [75, 18.8], [102, 19.4]], close: DOWN, fill: ['#3A3163', '#3D3468'] },
      { id: 'firs_sides', kind: 'polys', polys: (() => { const L = [[-1, 17], [5.5, 23], [2.5, 23.5], [7.5, 31], [3, 31.5], [8.5, 40], [3.5, 40.5], [8, 49], [3, 49.5], [6.5, 57], [-1, 62]]; return [L, mirror(L)]; })(), fill: ['#221C42', '#231D45'] },
      { id: 'clearing', kind: 'ellipse', c: [50, 60], r: [44, 30], fill: ['#40366C', '#443A73'] }
    ],
    scatter: [
      { id: 'dot_star', shape: 'dot', zones: [[2, 0.5, 96, 8]], noAvoid: true, n: [14, 22], size: [5, 9], palette: ['#E9E0FF'], phase: [0.3, 0.7, 0.2, 0] },
      { id: 'star', shape: 'sparkle', zones: [[2, 0.8, 96, 7]], noAvoid: true, n: [8, 18], size: [16, 28], rot: [0, 45], variants: [['#FFF2BF'], ['#E9E0FF']], phase: [0.66, 0.13, 0.41, 0.8] },
      { id: 'meteor', shape: 'meteor', zones: [[10, 1, 80, 5.5]], noAvoid: true, n: [1, 4], size: [110, 160], rot: [148, 154], palette: ['#FFF2BF', '#FFF2BF66'], phase: [0.2, 0.5, 0.35, 0.5] },
      { id: 'fern', shape: 'fern', zones: [[4, 22, 92, 76]], n: [6, 12], size: [40, 60], grow: [1, 1.25], palette: ['#342C5C'], phase: [0.57, 0.91, 0.62, 0] },
      { id: 'star_petal', shape: 'sparkle', zones: [[8, 22, 84, 74]], n: [3, 20], size: [12, 18], rot: [0, 45], palette: ['#D9CCFF'], phase: [0.81, 0.36, 0.09, 0.2] }
    ],
    lush: 'Nebo se napuni (22 tačke, 18 zvijezda, 4 meteora), na čistinu padne 20 zvjezdanih latica, paprat naraste.',
    combo: { light: '#DBCCFF', ring: '#FFF2BF' }
  },
  {
    id: 'ember_fen', name: 'Ember Fen', tagline: 'Low firelight over marsh blooms.', mood: '#FFC79E',
    place: 'Močvara u sumrak vatre: tresetno tlo, lokve, rogoz uz rubove, dva pojasa dima.',
    base: ['#C8744E', '#CF7C52'],
    layers: [
      { id: 'far_reeds', kind: 'poly', smooth: false, edge: spikes(-2, 102, 2.4, 5.6, 10.6, 5, 1.8), close: DOWN, fill: ['#3E2624', '#40282A'] },
      { id: 'peat', kind: 'poly', ground: true, edge: [[-2, 12.4], [25, 11.8], [50, 12.6], [75, 11.9], [102, 12.3]], close: DOWN, fill: ['#58392F', '#5C3C31'] },
      { id: 'pools', kind: 'blob', blobs: [[[10, 33], [22, 30.5], [34, 32.5], [38, 37], [28, 40.5], [14, 39.5]], [[58, 50], [72, 47.6], [86, 50.2], [88, 55.5], [74, 58.6], [60, 56.4]], [[14, 70], [28, 68.4], [36, 71.6], [32, 76.8], [18, 77.2], [10, 74]]], fill: ['#3B2A2C', '#3D2B2E'] },
      { id: 'smoke', kind: 'blob', blobs: [[[-4, 26], [20, 24.4], [46, 25.6], [72, 23.8], [104, 25], [104, 29.6], [74, 30.4], [46, 29], [20, 30.6], [-4, 29.4]], [[-4, 60.5], [24, 59], [52, 60.6], [78, 58.8], [104, 60], [104, 64.4], [78, 63.2], [52, 65], [24, 63.6], [-4, 64.6]]], fill: ['#FFC79E2E', '#FFC79E1F'] }
    ],
    scatter: [
      { id: 'pool_glint', shape: 'glint', at: [[20, 35], [70, 52.5], [22, 73], [28, 37.6], [76, 55.2], [30, 75.4]], n: [3, 6], size: [60, 90], palette: ['#D27B55A6'], phase: [0, 0, 0.4, 0] },
      { id: 'cattail', shape: 'cattail', zones: [[1, 14, 13, 82], [86, 14, 13, 82]], n: [10, 22], size: [80, 120], grow: [1, 1.3], rot: [-6, 6], palette: ['#8A5536', '#2E1E1C'], phase: [0.24, 0.55, 0.47, 0.3] },
      { id: 'peat_tuft', shape: 'tuft', zones: [[4, 15, 92, 82]], n: [10, 14], size: [30, 46], palette: ['#6A4538'], phase: [0.68, 0.2, 0.84, 0] },
      { id: 'ember', shape: 'ember', zones: [[4, 13, 92, 85]], n: [6, 22], size: [10, 16], palette: ['#FFB074', '#FFE0B8'], phase: [0.14, 0.73, 0.28, 0] },
      { id: 'marsh_bloom', shape: 'iris', zones: [[6, 16, 88, 80]], n: [0, 12], size: [24, 32], rot: [-10, 10], palette: ['#FF9F6B', '#FFD3A8'], phase: [0.39, 0.06, 0.58, 0.4] }
    ],
    lush: 'Dim se razrijedi, rogoza bude 22 (bilo 10), žeravica 22, lokve dobiju odsjaj, procvjeta 12 plamenih perunika.',
    combo: { light: '#FFB88C', ring: '#FFC79E' }
  }
];

export const SEASON_KEYS = FIELD_SRC.map(f => f.id);

// Razrijesi slojeve u eksplicitne poligone (u %).
function resolveLayer(L) {
  const round = pts => pts.map(p => [r2(p[0]), r2(p[1])]);
  if (L.kind === 'poly') { const e = L.smooth === false ? L.edge : smoothOpen(L.edge); return { id: L.id, kind: 'poly', ground: !!L.ground, polys: [round([...e, ...L.close])], fill: L.fill }; }
  if (L.kind === 'polys') return { id: L.id, kind: 'poly', polys: L.polys.map(p => round(L.smooth ? smoothOpen(p) : p)), fill: L.fill };
  if (L.kind === 'blob') return { id: L.id, kind: 'poly', polys: L.blobs.map(b => round(smoothClosed(b))), fill: L.fill };
  if (L.kind === 'ellipse') return { id: L.id, kind: 'poly', polys: [round(ellipsePts(L.c[0], L.c[1], L.r[0], L.r[1]))], fill: L.fill };
  if (L.kind === 'line') return { id: L.id, kind: 'line', polys: [round(smoothOpen(L.edge))], w: L.w, fill: L.fill };
  if (L.kind === 'shape') return { id: L.id, kind: 'shape', shape: L.shape, at: L.at, size: L.size, palette: L.palette, fill: [L.palette[0], L.palette[0]] };
  return L;
}
export const FIELDS = {};
FIELD_SRC.forEach(f => { FIELDS[f.id] = { ...f, layers: f.layers.map(resolveLayer), scatter: f.scatter.map(s => ({ grow: [1, 1], rot: [0, 0], ...s })) }; });

// ── Instance rasutih elemenata (isti proracun u ui_arena_v2.gd) ──────────────
export const R2 = { a1: 0.7548776662466927, a2: 0.5698402909980532, size: 0.6180339887498949, rot: 0.41421356237309515 };
export function scatterInstance(s, i) {
  let x, y;
  if (s.at) { [x, y] = s.at[i % s.at.length]; }
  else if (s.even) { const z = s.zones[0]; x = z[0] + (i + 0.5) / s.n[1] * z[2]; y = z[1] + z[3] * 0.5; }
  else { const zi = i % s.zones.length, k = Math.floor(i / s.zones.length), z = s.zones[zi]; x = z[0] + fr(s.phase[0] + R2.a1 * (k + 1)) * z[2]; y = z[1] + fr(s.phase[1] + R2.a2 * (k + 1)) * z[3]; }
  const size = s.size[0] + (s.size[1] - s.size[0]) * fr(s.phase[2] + R2.size * (i + 1));
  const rot = s.rot[0] + (s.rot[1] - s.rot[0]) * fr(s.phase[3] + R2.rot * (i + 1));
  const palette = s.variants ? s.variants[i % s.variants.length] : s.palette;
  const avoided = !s.noAvoid && AVOID.some(a => x >= a[0] && x <= a[0] + a[2] && y >= a[1] && y <= a[1] + a[3]);
  return { x, y, size, rot, palette, avoided };
}
export function scatterAlpha(s, i, level) { return clamp01(s.n[0] + (s.n[1] - s.n[0]) * level / 4 - i); }
export function scatterGrow(s, level) { return s.grow[0] + (s.grow[1] - s.grow[0]) * level / 4; }

// ── SVG putanje za mockup (spojene po boji — malo DOM cvorova) ─────────────
const f2 = v => (Math.round(v * 100) / 100).toString();
function mkT(tx, ty, rotDeg, sc) { const r = rotDeg * Math.PI / 180, c = Math.cos(r), sn = Math.sin(r); return { pt: (x, y) => [tx + sc * (c * x - sn * y), ty + sc * (sn * x + c * y)], sc, rot: rotDeg }; }
function rectPts(x, y, w, h, rad) { const r = Math.min(rad, w / 2, h / 2); if (r <= 0) return [[x, y], [x + w, y], [x + w, y + h], [x, y + h]]; const out = []; const cs = [[x + w - r, y + r, -90], [x + w - r, y + h - r, 0], [x + r, y + h - r, 90], [x + r, y + r, 180]]; cs.forEach(([cx, cy, a0]) => { for (let k = 0; k <= 4; k++) { const a = (a0 + k * 22.5) * Math.PI / 180; out.push([cx + Math.cos(a) * r, cy + Math.sin(a) * r]); } }); return out; }
function ellD(c, rx, ry, rot) { const r = rot * Math.PI / 180, dx = Math.cos(r) * rx, dy = Math.sin(r) * rx; return 'M' + f2(c[0] - dx) + ',' + f2(c[1] - dy) + 'a' + f2(rx) + ',' + f2(ry) + ' ' + f2(rot) + ' 1,0 ' + f2(2 * dx) + ',' + f2(2 * dy) + 'a' + f2(rx) + ',' + f2(ry) + ' ' + f2(rot) + ' 1,0 ' + f2(-2 * dx) + ',' + f2(-2 * dy) + 'Z'; }
const polyD = pts => 'M' + pts.map(q => f2(q[0]) + ',' + f2(q[1])).join('L') + 'Z';
function primAbs(p, T) {
  switch (p[0]) {
    case 'c': return { fill: true, d: ellD(T.pt(p[1], p[2]), p[3] * T.sc, p[3] * T.sc, 0) };
    case 'e': return { fill: true, d: ellD(T.pt(p[1], p[2]), p[3] * T.sc, p[4] * T.sc, T.rot) };
    case 'p': return { fill: true, d: polyD(p[1].map(q => T.pt(q[0], q[1]))) };
    case 'r': return { fill: true, d: polyD(rectPts(p[1], p[2], p[3], p[4], p[5]).map(q => T.pt(q[0], q[1]))) };
    case 'l': { const s0 = T.pt(p[1], p[2]), s1 = T.pt(p[3], p[4]); return { fill: false, w: p[5] * T.sc, d: 'M' + f2(s0[0]) + ',' + f2(s0[1]) + 'L' + f2(s1[0]) + ',' + f2(s1[1]) }; }
    case 'a': { const pts = []; for (let k = 0; k <= 8; k++) { const a = (p[4] + (p[5] - p[4]) * k / 8) * Math.PI / 180; pts.push(T.pt(p[1] + Math.cos(a) * p[3], p[2] + Math.sin(a) * p[3])); } return { fill: false, w: p[6] * T.sc, d: 'M' + pts.map(q => f2(q[0]) + ',' + f2(q[1])).join('L') }; }
  }
  return null;
}
const pctPts = pts => 'M' + pts.map(q => f2(q[0] * W / 100) + ',' + f2(q[1] * H / 100)).join('L');
export function buildField(id, level = 0) {
  const F = FIELDS[id] || FIELDS.country_bloom; const t = Math.max(0, Math.min(4, level)) / 4;
  const layers = [];
  const pushPrims = (prims, palette, T, alpha, bucket) => prims.forEach(p => {
    const ci = p[p.length - 1], col = palette[Math.min(ci, palette.length - 1)];
    const a = primAbs(p, T); if (!a) return;
    const key = a.fill ? 'f|' + col + '|' + alpha : 's|' + col + '|' + (Math.round(a.w * 2) / 2) + '|' + alpha;
    let g = bucket.get(key);
    if (!g) { g = a.fill ? { d: '', f: col, s: 'none', sw: '0', o: alpha } : { d: '', f: 'none', s: col, sw: String(Math.round(a.w * 2) / 2), o: alpha }; bucket.set(key, g); }
    g.d += a.d;
  });
  F.layers.forEach(L => {
    if (L.kind === 'shape') { const b = new Map(); pushPrims(SHAPES[L.shape], L.palette, mkT(L.at[0] * W / 100, L.at[1] * H / 100, 0, L.size), 1, b); b.forEach(g => layers.push(g)); return; }
    const col = lerpHex(L.fill[0], L.fill[1], t);
    const d = L.polys.map(poly => pctPts(poly) + (L.kind === 'line' ? '' : 'Z')).join('');
    layers.push(L.kind === 'line' ? { d, f: 'none', s: col, sw: String(L.w), o: 1 } : { d, f: col, s: 'none', sw: '0', o: 1 });
  });
  const items = [];
  const anchors = [];
  F.scatter.forEach(s => {
    const g = scatterGrow(s, level); const bucket = new Map();
    for (let i = 0; i < s.n[1]; i++) {
      const a = scatterAlpha(s, i, level); if (a <= 0) continue;
      const it = scatterInstance(s, i); if (it.avoided) continue;
      const x = it.x * W / 100, y = it.y * H / 100;
      anchors.push({ type: s.id, x, y });
      pushPrims(SHAPES[s.shape], it.palette, mkT(x, y, it.rot, it.size * g), Math.round(a * 100) / 100, bucket);
    }
    bucket.forEach(v => items.push(v));
  });
  return { base: lerpHex(F.base[0], F.base[1], t), layers, items, anchors };
}

// Boje na kojima sjemenka moze lezati (za tabelu kontrasta).
export function fieldColors(id, level = 0) {
  const F = FIELDS[id]; const t = level / 4; const out = [];
  const groundL = F.layers.find(l => l.ground);
  const ground = groundL ? lerpHex(groundL.fill[0], groundL.fill[1], t) : lerpHex(F.base[0], F.base[1], t);
  const add = (c, name) => { const hex = c.length > 7 ? over(c, ground) : c; out.push({ hex, name }); };
  add(lerpHex(F.base[0], F.base[1], t), 'base');
  F.layers.forEach(L => { if (L.kind === 'line') return; if (L.kind === 'shape') { add(L.palette[0], L.id); return; } add(lerpHex(L.fill[0], L.fill[1], t), L.id); });
  F.scatter.forEach(s => { if (s.n[0] + (s.n[1] - s.n[0]) * t <= 0) return; (s.variants || [s.palette]).forEach(p => p.forEach((c, k) => add(c, s.id + '.' + k))); });
  return out;
}
export function minEdgeContrast(obj, id, level) {
  let min = Infinity, at = null;
  fieldColors(id, level).forEach(c => { const v = edgeContrast(obj, c.hex); if (v < min) { min = v; at = c; } });
  return { min, at };
}
export function minCreamOnly(id, level) {
  let min = Infinity, at = null;
  fieldColors(id, level).forEach(c => { const v = contrast('#FFF8F0', c.hex); if (v < min) { min = v; at = c; } });
  return { min, at };
}

// ── Proceduralni cvijet (CampPlantDraw._draw_generic_*) za tipove bez SVG-a ────
export const SEASON_HUE = { frost_orchard: 0.55, lantern_meadow: 0.10, amber_canopy: 0.06, moonlit_warren: 0.65, coral_tide: 0.97, starfall_glade: 0.78, ember_fen: 0.02 };
export function procPalette(season, jitter = 0) { const h = fr((SEASON_HUE[season] ?? 0.3) + jitter + 1); return { petal: hsv(h, 0.55, 0.92), center: hsv(h + 0.08, 0.65, 0.78), seed: hsv(h, 0.48, 0.85) }; }

// ── Rezovi SVG cvijeca (vidljivi piksel u 256 platnu) ─────────────────────────
export const CROP = { clover_t1: [80, 89, 96, 164], clover_t2: [65, 52, 126, 202], daisy_t1: [90, 119, 76, 134], daisy_t2: [62, 42, 132, 212], buttercup_t1: [90, 125, 76, 128], buttercup_t2: [69, 52, 118, 201], tulip_t1: [83, 117, 89, 136], tulip_t2: [75, 62, 100, 192], sunflower_t1: [88, 116, 80, 138], sunflower_t2: [57, 33, 142, 222], pumpkin_t1: [85, 99, 86, 154], pumpkin_t2: [48, 75, 158, 153], pumpkin_t3: [30, 47, 197, 181], clover_t3: [65, 52, 139, 202] };
export function cropImg(key, box) { const c = CROP[key]; if (!c) return null; const s = box / Math.max(c[2], c[3]); return { src: 'icons/flowers/' + key + '.svg', size: r2(256 * s), left: r2((box - c[2] * s) / 2 - c[0] * s), top: r2((box - c[3] * s) / 2 - c[1] * s) }; }
