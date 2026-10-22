// le_kit.js — design_handoff_leveli_endless · podaci (brief §4, fiksno), pojasevi, tajming i SVG crteži za assets/**.
// Bez importa i bez DOM-a: isti fajl čita mock (import) i izvoz (run_script → assets/*.svg). Sve u px baze 1080 × 1920.

// ── Tokeni (isti kao popupi / Run HUD v2) ─────────────────────────────────────
export const INK = '#2D3436', CREAM = '#FFF8F0', RIM = '#FFF6D6', PEACH = '#FFB88C', LAV = '#D4A5FF', LAV_L = '#EAD2FF',
  GOLD = '#FFD56B', MINT = '#A8E6CF', PINK = '#FFCCD5', SOFT = '#555C5E', WHITE = '#FFFFFF', CHIP_RIM = '#CBC2B6';
export const SEASONS = ['country_bloom', 'frost_orchard', 'lantern_meadow', 'amber_canopy', 'moonlit_warren', 'coral_tide', 'starfall_glade', 'ember_fen'];
export const NAMES = { country_bloom: 'Country Bloom', frost_orchard: 'Frost Orchard', lantern_meadow: 'Lantern Meadow', amber_canopy: 'Amber Canopy', moonlit_warren: 'Moonlit Warren', coral_tide: 'Coral Tide', starfall_glade: 'Starfall Glade', ember_fen: 'Ember Fen' };
export const SHORT = { country_bloom: 'Country', frost_orchard: 'Frost', lantern_meadow: 'Lantern', amber_canopy: 'Amber', moonlit_warren: 'Moonlit', coral_tide: 'Coral', starfall_glade: 'Starfall', ember_fen: 'Ember' };
export const DARK = { lantern_meadow: 1, moonlit_warren: 1, starfall_glade: 1, ember_fen: 1 };

// ── Pojasevi (A1) — pojas = ceil(level / 5); boja + broj strelica (nikad samo boja) ──
export const BANDS = [
  { n: 1, id: 'stroll', name: 'Stroll', from: 1, to: 5, fill: '#A8E6CF', chev: 1 },
  { n: 2, id: 'jog', name: 'Jog', from: 6, to: 10, fill: '#FFD56B', chev: 2 },
  { n: 3, id: 'dash', name: 'Dash', from: 11, to: 15, fill: '#FF9F5A', chev: 3 },
  { n: 4, id: 'sprint', name: 'Sprint', from: 16, to: 20, fill: '#F27C8E', chev: 4 }
];
export const bandOf = lvl => Math.min(4, Math.max(1, Math.ceil(Math.min(20, Math.max(1, lvl)) / 5)));
export const isPeak = lvl => lvl % 5 === 0;
// Endless: boja stepenice prati „toplinu" pojaseva (0–2 · 3–5 · 6–8 · 9+); Endless na 3:00 ≈ kraj levela 20 (balans §3.3)
export const paceBand = tier => tier < 3 ? 1 : tier < 6 ? 2 : tier < 9 ? 3 : 4;

// ── §4 · leveli 1–20 (fiksno) ──────────────────────────────────────────────
// [n, trajanje s, v start, v kraj, prepreka/min, parova %, prolaz [casual, average, skilled] %, coina, sjemena, ★3 %]
const LT = [
  [1, 60, 400, 424, 1.6, 0, [98, 100, 100], 21, 7.1, 3.1], [2, 64, 408, 443, 2.0, 0, [98, 99, 99], 22, 7.6, 3.3],
  [3, 66, 412, 449, 2.3, 0, [97, 99, 100], 23, 7.7, 3.5], [4, 70, 420, 458, 2.5, 0, [97, 99, 100], 23, 8.5, 3.7],
  [5, 72, 424, 464, 3.1, 0, [95, 98, 99], 25, 8.9, 4.0], [6, 76, 432, 486, 3.6, 4, [96, 98, 98], 26, 9.5, 4.2],
  [7, 78, 436, 493, 4.2, 5, [93, 96, 98], 28, 9.9, 4.4], [8, 82, 444, 505, 5.0, 7, [88, 97, 97], 29, 10.7, 4.6],
  [9, 86, 452, 514, 5.6, 9, [88, 95, 97], 30, 11.4, 4.8], [10, 88, 456, 521, 6.5, 11, [86, 94, 96], 31, 11.3, 5.0],
  [11, 92, 464, 548, 7.5, 12, [85, 91, 93], 33, 12.2, 5.0], [12, 94, 468, 556, 8.7, 14, [78, 89, 96], 34, 12.8, 5.2],
  [13, 98, 476, 565, 9.5, 16, [76, 89, 95], 35, 13.4, 5.4], [14, 102, 484, 578, 10.8, 18, [69, 82, 92], 36, 14.4, 5.6],
  [15, 104, 488, 586, 12.2, 20, [62, 81, 93], 37, 14.2, 5.7], [16, 108, 496, 618, 13.8, 22, [62, 79, 88], 38, 15.2, 5.9],
  [17, 110, 500, 628, 15.3, 24, [59, 74, 87], 39, 15.8, 6.1], [18, 114, 508, 638, 16.7, 26, [53, 67, 85], 41, 16.3, 6.3],
  [19, 116, 512, 647, 19.0, 28, [41, 67, 80], 41, 16.3, 6.5], [20, 120, 520, 662, 20.6, 30, [39, 61, 74], 42, 17.5, 6.7]
];
export const LEVELS = LT.map(([n, dur, v0, v1, obst, pairs, pass, coins, seeds, r3]) => ({ n, dur, v0, v1, obst, pairs, pass, coins, seeds, r3 }));
// levels.json: scroll_speed_mult i speed_ramp (×(1 + ramp) svakih 15 s)
const MULT = [1.0, 1.02, 1.03, 1.05, 1.06, 1.08, 1.09, 1.11, 1.13, 1.14, 1.16, 1.17, 1.19, 1.21, 1.22, 1.24, 1.25, 1.27, 1.28, 1.3];
const RAMP = [0.02, 0.021, 0.022, 0.022, 0.023, 0.024, 0.025, 0.026, 0.026, 0.027, 0.028, 0.029, 0.029, 0.03, 0.031, 0.032, 0.033, 0.033, 0.034, 0.035];
export const RAMP_EVERY = 15, PIP_Y = 1574, SPAWN_Y = -80, GATE_DIST = PIP_Y - SPAWN_Y; // 1654
export const LANES = [270, 540, 810], SEAMS = [405, 675];
export function speedAt(n, t) { return 400 * MULT[n - 1] * Math.pow(1 + RAMP[n - 1], Math.floor(Math.max(0, t) / RAMP_EVERY)); }
// put koji staza još pređe od t do kraja levela (stepenice brzine uključene)
export function remainDist(n, t) { const dur = LEVELS[n - 1].dur; let d = 0, x = Math.max(0, t); while (x < dur - 1e-9) { const nx = Math.min(dur, (Math.floor(x / RAMP_EVERY + 1e-9) + 1) * RAMP_EVERY); d += speedAt(n, x) * (nx - x); x = nx; } return d; }
// trenutak pojave cilja: preostali put = 1654 px (cilj na y −80, ide sa stazom, traka na y 1574 tačno na kraju)
export function gateT(n) { let lo = 0, hi = LEVELS[n - 1].dur; for (let i = 0; i < 48; i++) { const m = (lo + hi) / 2; if (remainDist(n, m) > GATE_DIST) lo = m; else hi = m; } return hi; }
export const gateLead = n => LEVELS[n - 1].dur - gateT(n);
export const fmtDur = s => Math.floor(s / 60) + ':' + String(Math.round(s % 60)).padStart(2, '0');

// ── §4 · Endless (fiksno) ─────────────────────────────────────────────────
export const ENDLESS_KEYS = [
  { t: 0, m: 1.0, spawn: 32, obst: 8, pairs: 0, r3: 3.7 }, { t: 60, m: 1.15, spawn: 38, obst: 16, pairs: 6, r3: 4.8 },
  { t: 120, m: 1.35, spawn: 45, obst: 24, pairs: 15, r3: 6.2 }, { t: 180, m: 1.55, spawn: 53, obst: 30, pairs: 24, r3: 7.5 },
  { t: 300, m: 1.9, spawn: 62, obst: 36, pairs: 32, r3: 9.5 }, { t: 480, m: 2.3, spawn: 70, obst: 40, pairs: 38, r3: 11.1 }
];
export const TIER_SEC = 20, AFTER_LAST = 0.04;
export const tierOf = t => Math.max(0, Math.floor(t / TIER_SEC));
function endlessKey(t, f) { const T = tierOf(t) * TIER_SEC, K = ENDLESS_KEYS, last = K[K.length - 1]; if (T >= last.t) return f === 'm' ? last.m + AFTER_LAST * Math.floor((T - last.t) / TIER_SEC) : last[f]; let i = 0; while (i + 1 < K.length && K[i + 1].t <= T) i++; const a = K[i], b = K[i + 1]; return a[f] + (b[f] - a[f]) * (T - a.t) / (b.t - a.t); }
export const endlessSpeed = t => 400 * endlessKey(t, 'm');
export const endlessAt = t => ({ tier: tierOf(t), v: endlessSpeed(t), spawn: endlessKey(t, 'spawn'), obst: Math.min(45, endlessKey(t, 'obst')), pairs: Math.min(45, endlessKey(t, 'pairs')), r3: endlessKey(t, 'r3') });
export const SIM_SEC = { casual: 197, average: 265, skilled: 328 }; // medijan preživljenog (simulacija)
export const LOOT_PER_MIN = { coins: 21.5, seeds: 8 };            // average, ≈ level 20 (balans izvještaj §3.3)
export function clock(sec) { const s = Math.max(0, Math.floor(sec)); if (s >= 3600) return Math.floor(s / 3600) + ':' + String(Math.floor(s / 60) % 60).padStart(2, '0') + ':' + String(s % 60).padStart(2, '0'); return Math.floor(s / 60) + ':' + String(s % 60).padStart(2, '0'); }
export const ENDLESS_UNLOCK_LEVEL = 15;
export const unlockProgress = lvl => Math.min(15, Math.max(0, lvl - 1)); // pređenih levela do otključavanja (Pip na 16 = 15/15)

// ── Tajming (sve s; ključevi se prepisuju u godot/*.json) ──────────────────
export const TIME = {
  intro: { pop: 0.18, sub: [0.10, 0.30], hold: 0.74, fly: [0.74, 1.12], total: 1.12, chipBump: [1.06, 1.18] },
  gust: { total: 0.42, streak: 0.36, lean: 0.30, jolt: 0.16, stagger: 0.03 },
  pace: { in: 0.16, hold: 0.62, out: [0.70, 0.92], total: 0.92 },
  best: { total: 0.90, ring: 0.36, confetti: 0.86, trophy: 0.40 },
  unlock: { delay: 0.40, shake: 0.18, pop: [0.18, 0.44], flip: [0.30, 0.66], burst: [0.48, 0.92], bubble: 0.62, total: 1.10, bubbleHold: 2.2 },
  finish: { tape: 0.36, confetti: 0.90, arch: 0.24, banner: 0.12, total: 1.0 },
  chest: { cycle: 1.8, big: 1.5, phase: 0.23 },
  lockTap: { shake: 0.30, toastHold: 1.6 }
};

// ── SVG primitivi ───────────────────────────────────────────────────────────
const q = v => +(+v).toFixed(1);
const A = o => Object.keys(o).map(k => o[k] == null ? '' : ' ' + k + '="' + o[k] + '"').join('');
const S = (s, w) => s ? { stroke: s, 'stroke-width': w, 'stroke-linejoin': 'round', 'stroke-linecap': 'round' } : {};
const rect = (x, y, w, h, rx, f, s, sw) => '<rect' + A({ x: q(x), y: q(y), width: q(w), height: q(h), rx: rx ? q(rx) : null, fill: f || 'none', ...S(s, sw) }) + '/>';
const ell = (cx, cy, rx, ry, f, s, sw) => '<ellipse' + A({ cx: q(cx), cy: q(cy), rx: q(rx), ry: q(ry), fill: f || 'none', ...S(s, sw) }) + '/>';
const circ = (cx, cy, r, f, s, sw) => '<circle' + A({ cx: q(cx), cy: q(cy), r: q(r), fill: f || 'none', ...S(s, sw) }) + '/>';
const path = (d, f, s, sw) => '<path' + A({ d, fill: f || 'none', ...S(s, sw) }) + '/>';
const pl = pts => 'M' + pts.map(p => q(p[0]) + ',' + q(p[1])).join('L');
const pg = pts => pl(pts) + 'Z';
const grp = (tr, body) => '<g transform="' + tr + '">' + body + '</g>';
const svg = (w, h, body) => '<svg xmlns="http://www.w3.org/2000/svg" width="' + w + '" height="' + h + '" viewBox="0 0 ' + w + ' ' + h + '">' + body + '</svg>';
const starPts = (cx, cy, R, r, n = 5, rot = -90) => Array.from({ length: n * 2 }, (_, i) => { const a = (rot + i * 180 / n) * Math.PI / 180, rr = i % 2 ? r : R; return [cx + Math.cos(a) * rr, cy + Math.sin(a) * rr]; });
const star = (cx, cy, R, r, f, s, sw, n) => path(pg(starPts(cx, cy, R, r, n)), f, s, sw);
const chevs = (k, cx, cy, cw, ch, gap) => { const tw = (k - 1) * gap + cw, x0 = cx - tw / 2; let d = ''; for (let i = 0; i < k; i++) { const x = x0 + i * gap; d += 'M' + q(x) + ',' + q(cy - ch / 2) + 'L' + q(x + cw) + ',' + q(cy) + 'L' + q(x) + ',' + q(cy + ch / 2); } return d; };
const dome = (x0, x1, yTop, yG, k = 0.55) => { const m = (x0 + x1) / 2, h = yG - yTop; return 'M' + q(x0) + ',' + q(yG) + 'C' + q(x0) + ',' + q(yG - h * k) + ' ' + q(x0 + (m - x0) * 0.35) + ',' + q(yTop) + ' ' + q(m) + ',' + q(yTop) + 'S' + q(x1) + ',' + q(yG - h * k) + ' ' + q(x1) + ',' + q(yG) + 'Z'; };

// ── A1 · oznake pojasa ──────────────────────────────────────────────────────
// Pločica na kamenu i u LevelChipu: 72 × 30 (kraj pojasa 86 × 30 sa zvjezdicom).
export function bandTag(n, peak) {
  const B = BANDS[n - 1], w = peak ? 86 : 72, h = 30;
  let b = rect(1.5, 1.5, w - 3, h - 3, 13.5, B.fill, INK, 3);
  b += path(chevs(B.chev, peak ? (w - 20) / 2 + 3 : w / 2, 15, 8, 14, 11), null, INK, 3.5);
  if (peak) b += star(w - 17, 15, 9, 4, CREAM, INK, 2.5);
  return svg(w, h, b);
}
// Zastavica pojasa uz prvi kamen pojasa (1 / 6 / 11 / 16): stub + barjak; ime je Label (34/900) na (86, 44).
export function bandFlag(n) {
  const B = BANDS[n - 1];
  let b = ell(16, 206, 22, 6, 'rgba(26,26,20,.28)');
  b += rect(9, 10, 12, 196, 6, CREAM, INK, 4);
  b += path('M21,22H170L151,63L170,104H21Z', B.fill, INK, 4);
  b += path('M30,31H138', null, 'rgba(255,255,255,.55)', 5);
  b += path(chevs(B.chev, 84, 84, 9, 15, 13), null, INK, 4);
  b += circ(15, 12, 9, GOLD, INK, 3.5);
  return svg(180, 214, b);
}

// ── A4 · parovi prepreka ────────────────────────────────────────────────────
// wide 460 × 220 (dvije susjedne staze; centri staza x 95 i 365; otvoreni kraj DESNO), side 240 × 220 (jedna staza; centar x 120;
// otvoreni kraj DESNO). Tlo na y 214 = y prepreke + 69 (kao singl), centar sudara y 151. Lijevo-sredina = wide; sredina-desno = wide flip_h;
// lijevo-desno = side (lijevo) + side flip_h (desno). Mint zastavica stoji na kraju koji gleda u slobodnu stazu.
export const ART = {
  country_bloom: { ol: '#5A4A3A', post: '#F4EAD6', rail: '#E6D8BC', brace: '#D8C7A4', cap: '#C9B48F', hay: '#E2C878', hayL: '#F0DC98', hayLn: '#C4A85A', band: '#B5543A', hayOl: '#5A4A2A', leaf: '#6FA86A', leafL: '#9BCF8E', petal: '#FFF8F0', eye: '#FFD56B', tulip: '#FF9BB0', pole: '#F4EAD6' },
  frost_orchard: { ol: '#2B3550', ice: '#BFD9F2', iceL: '#E8F3FD', iceD: '#94B8DC', iceLn: '#7FA6CE', snow: '#F7FAFE', wood: '#9C7A5C', woodD: '#7E5E42', pole: '#9C7A5C' },
  lantern_meadow: { ol: '#24192F', post: '#8A7AA8', postL: '#B3A6CC', bar: '#A898C4', lamp: '#FFB88C', lampL: '#FFE3B8', lampD: '#B9A6E0', lampDL: '#DCCEF2', stone: '#9A90B4', stoneL: '#C6BEDC', stoneD: '#7A6F96', moss: '#7FBF8C', mossL: '#B8E6C0', pole: '#8A7AA8' },
  amber_canopy: { ol: '#3F2716', bark: '#B07A44', barkLn: '#8A5A30', cut: '#F2D2A0', ring: '#C99A60', hl: '#D49A62', leafA: '#E07B39', leafB: '#F0A04B', leafC: '#C9602A', cap: '#E8805A', dot: '#FFF1DC', cap2: '#F2A65A', pole: '#8A5A30' },
  moonlit_warren: { ol: '#221B3A', mound: '#8189CF', moundL: '#AEB4F0', hole: '#0F1228', holeRim: '#8C93D8', moss: '#2E4F5A', mossL: '#4F8590', stem: '#E9E1FF', cap: '#B8BDFF', moon: '#EDEBFF', stone: '#9A8BBA', stoneL: '#C9BDE6', pole: '#C9BDE6' },
  coral_tide: { ol: '#2E3542', rock: '#7E8A98', rockL: '#B4BEC8', rockD: '#66717E', shell: '#FFF1E8', shellLn: '#E9C2AE', star: '#F29B80', pink: '#FFCCD5', coral: '#F58A78', coralL: '#FFC5B8', sand: '#E0BC9A', drift: '#C9A27E', driftD: '#9E7A58', rope: '#F2E3C6', pole: '#C9A27E' },
  starfall_glade: { ol: '#1C1534', met: '#8C84B8', metL: '#B8B0DC', metD: '#6A6296', crater: '#5A5288', glow: '#FFF2BF', glow2: '#E9E0FF', wood: '#7A6A9A', woodLn: '#5E5080', cut: '#C9BDE6', ring: '#9A8CC2', fir: '#4A6E78', firL: '#6A929C', pole: '#7A6A9A' },
  ember_fen: { ol: '#2A140E', mud: '#6A4A3A', mudLn: '#8A6A58', rush: '#93AE62', cat: '#C98A55', wood: '#8A6A58', woodLn: '#6A4E40', top: '#4A2E24', ember: '#FF8A3D', emberL: '#FFD08A', spark: '#FFB074', smoke: '#B8A49A', pole: '#C98A55' }
};
// mint zastavica prolaza: stub (dno na x, y) visok 62, barjak prema dir (+1 desno)
function gapFlag(x, y, dir, ol, pole) {
  return rect(x - 5, y - 62, 10, 64, 5, pole, ol, 4) + path('M' + q(x + dir * 4) + ',' + q(y - 60) + 'L' + q(x + dir * 50) + ',' + q(y - 47) + 'L' + q(x + dir * 4) + ',' + q(y - 33) + 'Z', MINT, ol, 4) + circ(x, y - 63, 6, CREAM, ol, 3);
}
const daisy = (x, y, r, P) => Array.from({ length: 6 }, (_, i) => { const a = i * Math.PI / 3; return circ(x + Math.cos(a) * r * 0.62, y + Math.sin(a) * r * 0.62, r * 0.5, P.petal || CREAM, P.ol, 2.5); }).join('') + circ(x, y, r * 0.42, P.eye || GOLD, P.ol, 2.5);
const tulip = (x, y, s, col, ol) => path('M' + q(x) + ',' + q(y + 14 * s) + 'V' + q(y + 30 * s), null, '#6FA86A', 4) + path('M' + q(x - 11 * s) + ',' + q(y - 8 * s) + 'L' + q(x - 6 * s) + ',' + q(y + 2 * s) + 'L' + q(x) + ',' + q(y - 9 * s) + 'L' + q(x + 6 * s) + ',' + q(y + 2 * s) + 'L' + q(x + 11 * s) + ',' + q(y - 8 * s) + 'Q' + q(x + 12 * s) + ',' + q(y + 15 * s) + ' ' + q(x) + ',' + q(y + 15 * s) + 'Q' + q(x - 12 * s) + ',' + q(y + 15 * s) + ' ' + q(x - 11 * s) + ',' + q(y - 8 * s) + 'Z', col, ol, 3);
const leaf = (x, y, rot, col, ol, s = 1) => grp('translate(' + q(x) + ' ' + q(y) + ') rotate(' + rot + ')', path('M0,' + q(-16 * s) + 'Q' + q(13 * s) + ',' + q(-4 * s) + ' 0,' + q(16 * s) + 'Q' + q(-13 * s) + ',' + q(-4 * s) + ' 0,' + q(-16 * s) + 'Z', col, ol, 3) + path('M0,' + q(-10 * s) + 'V' + q(11 * s), null, ol, 2));
const mushroom = (x, y, s, P) => rect(x - 7 * s, y - 20 * s, 14 * s, 22 * s, 5 * s, P.dot, P.ol, 3) + path('M' + q(x - 24 * s) + ',' + q(y - 18 * s) + 'C' + q(x - 24 * s) + ',' + q(y - 44 * s) + ' ' + q(x + 24 * s) + ',' + q(y - 44 * s) + ' ' + q(x + 24 * s) + ',' + q(y - 18 * s) + 'Z', P.cap, P.ol, 4) + circ(x - 8 * s, y - 29 * s, 4 * s, P.dot) + circ(x + 9 * s, y - 26 * s, 3 * s, P.dot);
const hayBale = (x, y, w, h, P) => rect(x, y, w, h, 18, P.hay, P.hayOl, 5) + path('M' + (x + 12) + ',' + (y + 18) + 'H' + (x + w - 12) + 'M' + (x + 12) + ',' + (y + 36) + 'H' + (x + w - 12) + 'M' + (x + 12) + ',' + (y + 54) + 'H' + (x + w - 16), null, P.hayLn, 5) + rect(x + w * 0.3, y, 10, h, 0, P.band, P.hayOl, 3) + path('M' + (x + 14) + ',' + (y + 9) + 'Q' + (x + w * 0.25) + ',' + (y + 4) + ' ' + (x + w * 0.45) + ',' + (y + 8), null, '#FFF2C4', 5);
const coralBr = (x, y, s, P) => { const d = 'M' + q(x) + ',' + q(y) + 'V' + q(y - 40 * s) + 'M' + q(x) + ',' + q(y - 18 * s) + 'L' + q(x - 22 * s) + ',' + q(y - 38 * s) + 'V' + q(y - 56 * s) + 'M' + q(x) + ',' + q(y - 26 * s) + 'L' + q(x + 22 * s) + ',' + q(y - 46 * s) + 'V' + q(y - 64 * s); return path(d, null, P.ol, 20 * s) + path(d, null, P.coral, 12 * s) + circ(x, y - 40 * s, 6 * s, P.coralL) + circ(x - 22 * s, y - 56 * s, 5 * s, P.coralL) + circ(x + 22 * s, y - 64 * s, 5 * s, P.coralL); };
const shellFan = (x, y, s, P) => path('M' + q(x - 24 * s) + ',' + q(y) + 'C' + q(x - 26 * s) + ',' + q(y - 30 * s) + ' ' + q(x + 26 * s) + ',' + q(y - 30 * s) + ' ' + q(x + 24 * s) + ',' + q(y) + 'Z', P.shell, P.ol, 4) + path('M' + q(x) + ',' + q(y - 2) + 'L' + q(x - 12 * s) + ',' + q(y - 20 * s) + 'M' + q(x) + ',' + q(y - 2) + 'V' + q(y - 24 * s) + 'M' + q(x) + ',' + q(y - 2) + 'L' + q(x + 12 * s) + ',' + q(y - 20 * s), null, P.shellLn, 3.5);
const starfish = (x, y, r, P, rot = -90) => path(pg(starPts(x, y, r, r * 0.45, 5, rot)), P.star, P.ol, 4);
const crystal = (x, y, s, f, ol) => path(pg([[x, y - 16 * s], [x + 8 * s, y], [x, y + 12 * s], [x - 8 * s, y]]), f, ol, 3);
const rushes = (pts, P, w = 13) => { const d = pts.map(([x0, y0, x1, y1]) => 'M' + x0 + ',' + y0 + 'L' + x1 + ',' + y1).join(''); return path(d, null, P.ol, w) + path(d, null, P.rush, w - 7); };
const cattail = (x, y, rot, P) => grp('rotate(' + rot + ' ' + x + ' ' + y + ')', rect(x - 8, y - 20, 16, 40, 8, P.cat, P.ol, 4));
const lantern = (x, y, s, lit, P) => path('M' + q(x) + ',' + q(y - 30 * s) + 'V' + q(y - 22 * s), null, P.ol, 3) + rect(x - 9 * s, y - 24 * s, 18 * s, 6 * s, 2, P.ol) + ell(x, y, 17 * s, 21 * s, lit ? P.lamp : P.lampD, P.ol, 4) + ell(x, y + 2 * s, 7 * s, 11 * s, lit ? P.lampL : P.lampDL) + rect(x - 8 * s, y + 18 * s, 16 * s, 6 * s, 2, P.ol);

const PAIRS = {
  country_bloom: {
    wide(P) { let b = ''; [100, 136, 172].forEach(y => b += rect(24, y, 410, 24, 8, P.rail, P.ol, 5)); b += path(pg([[42, 192], [208, 108], [216, 120], [50, 204]]) + pg([[240, 192], [406, 108], [414, 120], [248, 204]]), P.brace, P.ol, 4); [16, 216, 416].forEach(x => { b += rect(x, 80, 28, 134, 6, P.post, P.ol, 5) + path('M' + x + ',82L' + (x + 14) + ',64L' + (x + 28) + ',82Z', P.cap, P.ol, 4); }); b += path('M23,92V202M223,92V202', null, 'rgba(255,255,255,.75)', 4); b += hayBale(38, 150, 118, 64, P); b += daisy(190, 204, 10, P) + daisy(306, 206, 9, P) + tulip(352, 186, 0.9, P.tulip, P.ol); b += gapFlag(430, 64, 1, P.ol, P.pole); return b; },
    side(P) { let b = ''; [100, 136, 172].forEach(y => b += rect(22, y, 190, 24, 8, P.rail, P.ol, 5)); b += path(pg([[40, 192], [190, 108], [198, 120], [48, 204]]), P.brace, P.ol, 4); [12, 196].forEach(x => { b += rect(x, 80, 28, 134, 6, P.post, P.ol, 5) + path('M' + x + ',82L' + (x + 14) + ',64L' + (x + 28) + ',82Z', P.cap, P.ol, 4); }); b += path('M19,92V202', null, 'rgba(255,255,255,.75)', 4); b += hayBale(54, 150, 112, 64, P) + daisy(184, 206, 9, P); b += gapFlag(210, 64, 1, P.ol, P.pole); return b; }
  },
  frost_orchard: {
    wide(P) { const sil = [[10, 214], [16, 108], [64, 86], [130, 98], [198, 72], [264, 94], [330, 78], [396, 98], [446, 116], [452, 214]]; let b = path(pg(sil), P.ice); b += path(pg([[16, 108], [64, 86], [130, 98], [86, 124]]) + pg([[130, 98], [198, 72], [264, 94], [206, 120]]) + pg([[264, 94], [330, 78], [396, 98], [342, 122]]), P.iceL); b += path(pg([[86, 124], [130, 98], [152, 214], [102, 214]]) + pg([[206, 120], [264, 94], [286, 214], [224, 214]]) + pg([[342, 122], [396, 98], [446, 116], [452, 214], [362, 214]]), P.iceD); b += path('M44,142L54,190M172,134L182,188M302,138L312,184', null, P.iceL, 6) + path('M112,162L134,148M392,152L414,142', null, P.iceLn, 4); b += path(pg(sil), null, P.ol, 6); b += path('M40,98Q64,76 98,92Q76,104 52,104Z M170,82Q198,60 232,84Q206,94 184,92Z M304,88Q330,68 362,88Q340,98 318,96Z', P.snow, P.ol, 4); b += path('M8,206Q58,190 112,200T230,196T346,202T454,194V216H8Z', P.snow, P.ol, 4); b += gapFlag(436, 120, 1, P.ol, P.pole); return b; },
    side(P) { const sil = [[10, 214], [18, 104], [70, 82], [150, 92], [208, 116], [214, 214]]; let b = path(pg(sil), P.ice); b += path(pg([[18, 104], [70, 82], [150, 92], [100, 122]]), P.iceL) + path(pg([[100, 122], [150, 92], [208, 116], [214, 214], [118, 214]]), P.iceD); b += path('M46,140L56,190', null, P.iceL, 6) + path('M150,160L172,146', null, P.iceLn, 4); b += path(pg(sil), null, P.ol, 6); b += path('M44,94Q70,72 104,88Q82,100 58,100Z', P.snow, P.ol, 4) + path('M8,206Q60,190 120,200T216,196V216H8Z', P.snow, P.ol, 4); b += gapFlag(206, 120, 1, P.ol, P.pole); return b; }
  },
  lantern_meadow: {
    wide(P) { let b = ''; const st = (x0, x1, yt) => path(dome(x0, x1, yt, 214), P.stone, P.ol, 6) + path('M' + q(x0 + 26) + ',' + q(yt + 44) + 'C' + q(x0 + 40) + ',' + q(yt + 22) + ' ' + q((x0 + x1) / 2 - 20) + ',' + q(yt + 12) + ' ' + q((x0 + x1) / 2 + 6) + ',' + q(yt + 14), null, P.stoneL, 7) + path('M' + q(x1 - 50) + ',' + q(yt + 70) + 'L' + q(x1 - 30) + ',' + q(yt + 86), null, P.stoneD, 5); b += st(140, 332, 98) + st(6, 178, 120) + st(292, 420, 128); b += path('M168,116C186,96 222,88 252,92C276,96 300,106 312,118C290,114 268,120 246,114C222,108 196,120 168,116Z', P.moss, P.ol, 4) + path('M30,138C44,124 70,118 92,122C110,126 124,132 132,140C114,138 96,142 80,138C62,134 46,142 30,138Z', P.moss, P.ol, 4) + circ(200, 104, 5, P.mossL) + circ(64, 128, 4, P.mossL); b += rect(422, 64, 26, 150, 7, P.post, P.ol, 5) + path('M432,74V204', null, P.postL, 4) + path('M422,84H392', null, P.ol, 5) + lantern(392, 118, 1, true, P) + path('M408,212H462', null, P.ol, 9); b += gapFlag(435, 64, 1, P.ol, P.pole); return b; },
    side(P) { let b = path(dome(8, 196, 104, 214), P.stone, P.ol, 6) + path('M34,150C46,124 76,112 104,116', null, P.stoneL, 7) + path('M150,168L168,184', null, P.stoneD, 5); b += path('M36,124C52,106 84,98 112,102C136,106 154,114 166,124C146,120 126,126 106,120C84,114 60,128 36,124Z', P.moss, P.ol, 4) + circ(80, 110, 5, P.mossL); b += rect(202, 64, 26, 150, 7, P.post, P.ol, 5) + path('M212,74V204', null, P.postL, 4) + path('M202,84H176', null, P.ol, 5) + lantern(176, 118, 0.9, true, P); b += gapFlag(215, 64, 1, P.ol, P.pole); return b; }
  },
  amber_canopy: {
    wide(P) { let b = rect(8, 120, 404, 94, 26, P.bark, P.ol, 6) + path('M32,150H330M50,178H362M30,200H300', null, P.barkLn, 5) + path('M32,136Q62,128 98,132', null, P.hl, 5); b += ell(408, 167, 36, 47, P.cut, P.ol, 6) + ell(408, 167, 22, 29, null, P.ring, 5) + ell(408, 167, 8, 11, P.ring); b += leaf(128, 116, -24, P.leafA, P.ol) + leaf(156, 112, 28, P.leafB, P.ol) + leaf(258, 118, -12, P.leafC, P.ol) + leaf(296, 112, 34, P.leafA, P.ol) + leaf(214, 120, 70, P.leafB, P.ol, 0.8); b += mushroom(54, 124, 1, P) + mushroom(86, 126, 0.68, Object.assign({}, P, { cap: P.cap2 })); b += gapFlag(378, 124, 1, P.ol, P.pole); return b; },
    side(P) { let b = rect(10, 120, 184, 94, 26, P.bark, P.ol, 6) + path('M30,150H150M42,178H160M28,200H130', null, P.barkLn, 5); b += ell(192, 167, 34, 47, P.cut, P.ol, 6) + ell(192, 167, 20, 28, null, P.ring, 5) + ell(192, 167, 7, 10, P.ring); b += leaf(84, 116, -20, P.leafA, P.ol) + leaf(112, 114, 30, P.leafB, P.ol) + mushroom(44, 124, 0.9, P); b += gapFlag(162, 124, 1, P.ol, P.pole); return b; }
  },
  moonlit_warren: {
    wide(P) { const sil = 'M4,214C4,150 30,92 104,88C150,86 178,118 226,118C272,118 298,90 346,92C410,96 454,150 454,214Z'; let b = path(sil, P.mound, P.ol, 6); b += path('M40,144C56,114 78,102 106,102M296,120C308,106 324,102 344,102', null, P.moundL, 8); [[110, 176], [346, 178]].forEach(([x, y]) => { b += ell(x, y, 38, 26, P.ol) + ell(x, y + 2, 31, 20, P.hole) + path('M' + (x - 34) + ',' + (y - 4) + 'Q' + x + ',' + (y - 38) + ' ' + (x + 34) + ',' + (y - 4), null, P.holeRim, 5); }); b += circ(52, 160, 11, P.moss, P.ol, 3) + circ(66, 150, 8, P.mossL, P.ol, 3) + circ(228, 138, 9, P.moss, P.ol, 3) + circ(404, 150, 10, P.moss, P.ol, 3) + circ(396, 140, 7, P.mossL, P.ol, 3); b += rect(220, 98, 12, 20, 4, P.stem, P.ol, 3) + path('M208,100Q226,76 244,100Z', P.cap, P.ol, 3); b += gapFlag(432, 156, 1, P.ol, P.pole); return b; },
    side(P) { const sil = 'M6,214C6,140 40,96 118,96C196,96 232,150 234,214Z'; let b = path(sil, P.mound, P.ol, 6) + path('M40,150C56,118 82,108 118,108', null, P.moundL, 8); b += ell(112, 178, 38, 26, P.ol) + ell(112, 180, 31, 20, P.hole) + path('M78,174Q112,140 146,174', null, P.holeRim, 5); b += circ(48, 166, 10, P.moss, P.ol, 3) + circ(176, 140, 9, P.mossL, P.ol, 3); b += gapFlag(212, 160, 1, P.ol, P.pole); return b; }
  },
  coral_tide: {
    wide(P) { const sil = 'M4,214C6,160 30,118 90,110C130,104 160,124 210,112C260,100 300,104 340,112C400,124 440,160 452,214Z'; let b = path(sil, P.rock) + path('M10,186C100,172 330,170 448,186V214H8Z', P.rockD) + path('M44,146C58,126 80,120 104,122M262,118C286,110 310,112 330,120', null, P.rockL, 8) + path(sil, null, P.ol, 6); b += coralBr(132, 122, 1, P) + coralBr(300, 118, 0.7, P); b += shellFan(214, 190, 1, P) + starfish(84, 178, 18, P, -70) + circ(360, 176, 8, P.pink, P.ol, 3.5) + circ(376, 186, 6, P.pink, P.ol, 3); b += rect(430, 122, 18, 92, 7, P.drift, P.ol, 5) + path('M432,146H446M432,156H446', null, P.rope, 4) + path('M434,132V206', null, P.driftD, 3); b += gapFlag(439, 124, 1, P.ol, P.pole); return b; },
    side(P) { const sil = 'M6,214C8,150 40,110 104,106C160,104 200,144 210,214Z'; let b = path(sil, P.rock) + path('M10,188C70,176 160,176 208,188V214H8Z', P.rockD) + path('M40,150C54,130 78,120 104,120', null, P.rockL, 8) + path(sil, null, P.ol, 6); b += coralBr(150, 130, 0.7, P) + shellFan(80, 190, 0.9, P) + starfish(120, 160, 15, P); b += rect(212, 122, 18, 92, 7, P.drift, P.ol, 5) + path('M214,146H228M214,156H228', null, P.rope, 4); b += gapFlag(221, 124, 1, P.ol, P.pole); return b; }
  },
  starfall_glade: {
    wide(P) { const sil = [[8, 214], [14, 150], [44, 112], [102, 98], [162, 110], [216, 90], [288, 100], [342, 92], [402, 114], [440, 148], [450, 214]]; let b = path(pg(sil), P.met); b += path(pg([[44, 112], [102, 98], [162, 110], [104, 132]]) + pg([[162, 110], [216, 90], [288, 100], [222, 126]]) + pg([[288, 100], [342, 92], [402, 114], [340, 132]]), P.metL); b += path(pg([[104, 132], [162, 110], [178, 214], [120, 214]]) + pg([[340, 132], [402, 114], [440, 148], [450, 214], [356, 214]]), P.metD); b += circ(76, 168, 16, P.crater, P.ol, 4) + circ(250, 176, 12, P.crater, P.ol, 4) + circ(394, 182, 10, P.crater, P.ol, 4); b += path(pg(sil), null, P.ol, 6); b += crystal(160, 154, 1.3, P.glow, P.ol) + crystal(300, 150, 1, P.glow, P.ol) + crystal(214, 196, 0.8, P.glow2, P.ol) + star(122, 84, 9, 4, P.glow, P.ol, 2.5) + star(268, 76, 7, 3, P.glow2, P.ol, 2.5); b += gapFlag(432, 150, 1, P.ol, P.pole); return b; },
    side(P) { let b = path('M30,214L38,118H178L186,214Z', P.wood, P.ol, 6) + path('M62,126V206M100,126V208M140,126V204', null, P.woodLn, 5); b += ell(108, 118, 74, 22, P.cut, P.ol, 6) + ell(108, 118, 40, 9, null, P.ring, 4); b += path('M144,104L168,64L186,104Z', P.fir, P.ol, 4) + path('M150,82L168,52L184,82Z', P.firL, P.ol, 4); b += path('M10,214C10,192 22,182 38,182S62,192 62,214Z', P.fir, P.ol, 4); b += star(70, 96, 14, 6, P.glow, P.ol, 3); b += gapFlag(206, 150, 1, P.ol, P.pole); return b; }
  },
  ember_fen: {
    wide(P) { let b = path('M4,214C8,186 40,174 100,172H360C420,174 452,190 454,214Z', P.mud, P.ol, 6) + path('M40,200Q200,188 420,200', null, P.mudLn, 5); b += rect(26, 116, 370, 74, 24, P.wood, P.ol, 6) + path('M48,146H300M60,170H330', null, P.woodLn, 5); b += ell(394, 153, 26, 37, P.top, P.ol, 6) + ell(394, 153, 15, 22, null, P.ember, 5); b += path('M70,118C80,106 98,110 106,102C116,110 132,104 142,112C152,108 166,112 170,118Z M232,118C242,108 256,112 262,104C272,112 284,106 294,114Z', P.ember, P.ol, 3) + path('M92,116C100,110 110,112 118,108C124,112 132,110 138,116Z', P.emberL); b += path('M120,96Q110,82 122,70M260,92Q270,78 258,66', null, P.ol, 11) + path('M120,96Q110,82 122,70M260,92Q270,78 258,66', null, P.smoke, 4); b += rushes([[10, 206, 0, 140], [24, 206, 22, 126], [38, 208, 52, 146]], P); b += cattail(22, 120, -4, P) + cattail(52, 140, 12, P); b += gapFlag(440, 178, 1, P.ol, P.pole); return b; },
    side(P) { let b = path('M8,214C8,186 40,172 110,172S212,186 214,214Z', P.mud, P.ol, 6) + path('M36,198Q110,186 190,198', null, P.mudLn, 5); b += rushes([[64, 180, 44, 96], [88, 178, 84, 76], [112, 178, 120, 84], [136, 180, 160, 104], [76, 180, 60, 118], [124, 180, 142, 124]], P, 14); b += cattail(84, 80, -6, P) + cattail(120, 88, 10, P); b += gapFlag(206, 178, 1, P.ol, P.pole); return b; }
  }
};
export const PAIR_BOX = { wide: [460, 220], side: [240, 220], ground: 214, hitY: 151, lanes_in_wide: [95, 365], lane_in_side: 120 };
export const pairWide = s => svg(460, 220, PAIRS[s].wide(ART[s]));
export const pairSide = s => svg(240, 220, PAIRS[s].side(ART[s]));

// ── A6 · cilj na kraju levela ───────────────────────────────────────────────
// Stub 120 × 440 (dno na y 436 = y cilja + 64; lijevi na x 138, desni = flip_h na x 942), luk 900 × 240 (gornji lijevi ugao na
// (90, y − 480)), traka 800 × 80 centrirana na (540, y). y cilja = linija trake; prelazi PIP_Y tačno na kraju levela.
const medal = (P, emblem) => circ(450, 150, 56, CREAM, P.ol, 5) + circ(450, 150, 44, null, MINT, 10) + emblem;
const GATES = {
  country_bloom: {
    post(P) { let b = rect(38, 34, 44, 402, 8, P.post, P.ol, 5) + path('M38,36L60,12L82,36Z', P.cap, P.ol, 4) + path('M48,48V424', null, 'rgba(255,255,255,.75)', 5); b += path('M38,110Q86,134 38,166Q86,192 38,224Q86,250 38,282Q86,306 38,338', null, P.ol, 12) + path('M38,110Q86,134 38,166Q86,192 38,224Q86,250 38,282Q86,306 38,338', null, P.leaf, 6); b += leaf(78, 128, 50, P.leafL, P.ol, 0.8) + leaf(80, 238, 40, P.leafL, P.ol, 0.8) + leaf(36, 300, -50, P.leafL, P.ol, 0.8); b += path('M14,436L26,404L36,436L48,396L60,436L72,404L84,436L96,398L108,436Z', P.leaf, P.ol, 4); b += daisy(60, 20, 18, P); return b; },
    arch(P) { const d = 'M40,150Q245,214 450,150Q655,214 860,150'; let b = path(d, null, P.ol, 22) + path(d, null, P.leaf, 13) + path('M60,152Q245,200 430,150M470,150Q655,200 840,152', null, P.leafL, 4); [[120, 172], [200, 188], [300, 186], [380, 168], [520, 168], [600, 186], [700, 188], [780, 172]].forEach(([x, y], i) => { b += i % 2 ? tulip(x, y - 8, 1, P.tulip, P.ol) : daisy(x, y, 15, P); }); [[160, 178, -30], [340, 178, 30], [560, 178, -30], [740, 178, 30]].forEach(([x, y, r]) => b += leaf(x, y + 10, r, P.leafL, P.ol, 0.9)); b += medal(P, daisy(450, 150, 30, P)); return b; }
  },
  frost_orchard: {
    post(P) { let b = path(pg([[34, 436], [38, 50], [60, 30], [84, 48], [88, 436]]), P.ice) + path(pg([[38, 50], [60, 30], [62, 436], [38, 436]]), P.iceL) + path(pg([[62, 436], [60, 30], [84, 48], [88, 436]]), P.iceD) + path('M48,120V220M50,280V380', null, P.iceL, 6) + path('M72,160L80,150M70,320L80,306', null, P.iceLn, 4) + path(pg([[34, 436], [38, 50], [60, 30], [84, 48], [88, 436]]), null, P.ol, 6); b += path('M26,52Q60,18 96,52Q84,64 60,60Q38,64 26,52Z', P.snow, P.ol, 4) + path('M36,58L42,84L48,60M70,62L76,92L82,58', P.iceL, P.ol, 3); b += path('M8,436Q30,404 60,410T112,436Z', P.snow, P.ol, 4); return b; },
    arch(P) { let b = path('M28,134H872V170H28Z', P.ice, P.ol, 6) + path('M36,140H864', null, P.iceL, 6) + path('M36,160H864', null, P.iceD, 6) + path('M28,134H872V170H28Z', null, P.ol, 6); b += path('M18,138Q60,104 120,122T260,116T420,118T580,116T740,120T884,138Z', P.snow, P.ol, 4); let ic = ''; for (let x = 60; x <= 840; x += 52) { if (Math.abs(x - 450) < 70) continue; const h = 22 + ((x * 7) % 3) * 12; ic += 'M' + (x - 10) + ',168L' + x + ',' + (168 + h) + 'L' + (x + 10) + ',168Z'; } b += path(ic, P.iceL, P.ol, 3); const flake = 'M450,118V182M422,134L478,166M422,166L478,134M440,122L450,132L460,122M440,178L450,168L460,178'; b += medal(P, path(flake, null, P.ol, 9) + path(flake, null, P.iceL, 4)); return b; }
  },
  lantern_meadow: {
    post(P) { let b = rect(42, 28, 36, 408, 8, P.post, P.ol, 5) + path('M54,40V424', null, P.postL, 5) + rect(28, 22, 64, 18, 7, P.bar, P.ol, 4) + path('M78,92H104', null, P.ol, 5) + lantern(104, 126, 0.9, true, P); b += path(dome(10, 110, 404, 436), P.stoneD, P.ol, 5); return b; },
    arch(P) { let b = rect(24, 132, 852, 32, 12, P.post, P.ol, 6) + path('M34,141H866', null, P.postL, 5); [[110, 1], [190, 0], [270, 1], [350, 0], [550, 0], [630, 1], [710, 0], [790, 1]].forEach(([x, lit], i) => { const y = 198 + (i % 2) * 10; b += path('M' + x + ',164V' + (y - 24), null, P.ol, 3) + lantern(x, y, 0.85, !!lit, P); }); b += medal(P, lantern(450, 154, 1.05, true, P)); return b; }
  },
  amber_canopy: {
    post(P) { let b = rect(36, 30, 48, 406, 14, P.bark, P.ol, 6) + path('M50,60V420M68,90V400', null, P.barkLn, 5) + path('M46,44Q60,36 74,44', null, P.hl, 5); b += leaf(30, 44, -40, P.leafA, P.ol) + leaf(88, 40, 40, P.leafB, P.ol) + leaf(60, 22, 0, P.leafC, P.ol) + mushroom(86, 428, 0.9, P) + mushroom(28, 432, 0.6, Object.assign({}, P, { cap: P.cap2 })); return b; },
    arch(P) { let b = rect(24, 128, 852, 34, 16, P.bark, P.ol, 6) + path('M44,140H420M480,140H856', null, P.hl, 4) + path('M120,152H300M600,152H780', null, P.barkLn, 4); const cols = [P.leafA, P.leafB, P.dot]; let x = 44, i = 0; while (x < 846) { if (Math.abs(x + 26 - 450) < 74) { x += 52; continue; } b += path('M' + x + ',160L' + (x + 52) + ',160L' + (x + 26) + ',214Z', cols[i % 3], P.ol, 4); x += 52; i++; } b += leaf(40, 124, -30, P.leafA, P.ol, 1.1) + leaf(860, 124, 30, P.leafB, P.ol, 1.1); const ml = 'M450,116L458,136L478,130L470,148L488,156L466,162L470,180L450,170L430,180L434,162L412,156L430,148L422,130L442,136Z'; b += medal(P, path(ml, P.leafA, P.ol, 3.5) + path('M450,140V188', null, P.ol, 3.5)); return b; }
  },
  moonlit_warren: {
    post(P) { let b = ''; [[30, 360, 76], [36, 284, 76], [32, 208, 76], [38, 132, 76], [34, 60, 72]].forEach(([x, y, h]) => b += rect(x, y, 56, h, 18, P.stone, P.ol, 5) + path('M' + (x + 12) + ',' + (y + 16) + 'H' + (x + 34), null, P.stoneL, 5)); b += path('M74,24A26,26 0 1 1 74,62A20,20 0 1 0 74,24Z', P.moon, P.ol, 4) + rect(16, 426, 88, 12, 6, P.mound, P.ol, 4); return b; },
    arch(P) { const d = 'M40,146Q450,200 860,146'; let b = path(d, null, P.ol, 8) + path(d, null, P.stoneL, 3); for (let i = 0; i < 12; i++) { const t = (i + 0.5) / 12, x = 40 + 820 * t, y = 146 + 54 * 4 * t * (1 - t) * 0.5 + 2; if (Math.abs(x - 450) < 76) continue; b += i % 2 ? star(x, y + 24, 16, 7, P.moon, P.ol, 3) : path(pg([[x - 22, y], [x + 22, y], [x, y + 44]]), P.cap, P.ol, 4); } b += medal(P, path('M462,118A36,36 0 1 0 462,182A28,28 0 1 1 462,118Z', P.moon, P.ol, 4)); return b; }
  },
  coral_tide: {
    post(P) { let b = rect(40, 30, 40, 406, 12, P.drift, P.ol, 5) + path('M52,50V420', null, P.driftD, 4) + path('M42,120H78M42,132H78M42,300H78M42,312H78', null, P.rope, 5); b += coralBr(60, 70, 0.9, P) + starfish(84, 380, 16, P, -60) + shellFan(32, 430, 0.8, P); return b; },
    arch(P) { const d = 'M40,146Q450,214 860,146'; let b = path(d, null, P.ol, 16) + path(d, null, P.rope, 9) + path('M40,146Q450,214 860,146', null, P.driftD, 2); [[110, 0], [180, 1], [250, 2], [330, 0], [570, 2], [650, 0], [720, 1], [790, 2]].forEach(([x, k]) => { const t = (x - 40) / 820, y = 146 + 68 * 4 * t * (1 - t) * 0.5 + 6; b += path('M' + x + ',' + q(y) + 'V' + q(y + 16), null, P.ol, 3); b += k === 0 ? shellFan(x, y + 44, 0.9, P) : k === 1 ? starfish(x, y + 34, 18, P) : circ(x, y + 28, 11, P.pink, P.ol, 3.5); }); b += medal(P, starfish(450, 152, 32, P)); return b; }
  },
  starfall_glade: {
    post(P) { let b = rect(40, 30, 40, 406, 10, P.wood, P.ol, 5) + path('M52,60V420M68,90V400', null, P.woodLn, 4); b += path('M60,0L100,70H20Z', P.fir, P.ol, 4) + path('M60,36L96,100H24Z', P.firL, P.ol, 4) + star(60, 14, 12, 5, P.glow, P.ol, 3); b += path('M14,436C14,412 30,402 48,402S82,412 82,436Z', P.fir, P.ol, 4); return b; },
    arch(P) { const d = 'M40,146Q450,206 860,146'; let b = path(d, null, P.ol, 18) + path(d, null, P.fir, 10) + path('M60,150Q450,198 840,150', null, P.firL, 3); for (let i = 0; i < 9; i++) { const t = (i + 0.5) / 9, x = 40 + 820 * t, y = 146 + 60 * 4 * t * (1 - t) * 0.5 + 4; if (Math.abs(x - 450) < 76) continue; b += path('M' + q(x) + ',' + q(y) + 'V' + q(y + 22), null, P.glow2, 3) + star(x, y + 36, i % 2 ? 13 : 17, i % 2 ? 6 : 7, i % 2 ? P.glow2 : P.glow, P.ol, 3); } b += medal(P, star(450, 152, 32, 14, P.glow, P.ol, 4)); return b; }
  },
  ember_fen: {
    post(P) { let b = rect(36, 40, 48, 396, 12, P.rush, P.ol, 5) + path('M48,60V420M60,60V420M72,60V420', null, '#7A944E', 4) + path('M36,140H84M36,300H84', null, P.cat, 7); b += cattail(46, 26, -10, P) + cattail(74, 22, 12, P); b += path('M8,436C8,414 30,404 60,404S112,414 112,436Z', P.mud, P.ol, 5); return b; },
    arch(P) { let b = rect(24, 130, 852, 32, 14, P.rush, P.ol, 6) + path('M120,130V162M300,130V162M600,130V162M780,130V162', null, P.cat, 7); [[110, 1], [190, 0], [270, 1], [350, 0], [550, 0], [630, 1], [710, 0], [790, 1]].forEach(([x, k], i) => { const y = 198 + (i % 2) * 8; b += path('M' + x + ',162V' + (y - 20), null, P.ol, 3); b += k ? rect(x - 14, y - 20, 28, 36, 10, P.emberL, P.ol, 4) + circ(x, y, 7, P.ember) + rect(x - 10, y - 26, 20, 8, 3, P.top, P.ol, 3) : path(pg([[x - 20, y - 20], [x + 20, y - 20], [x, y + 24]]), P.ember, P.ol, 4); }); b += medal(P, path('M450,112C470,136 484,152 478,170C474,184 462,190 450,190C438,190 426,184 422,170C418,156 430,146 436,134C440,146 446,150 450,148C452,136 446,124 450,112Z', P.ember, P.ol, 4) + path('M450,154C460,164 462,174 456,180C452,184 448,184 444,180C440,174 444,166 450,154Z', P.emberL)); return b; }
  }
};
export const GATE_BOX = { post: [120, 440], post_ground: 436, post_x: [138, 942], arch: [900, 240], arch_at: [90, -480], tape: [800, 80], tape_center: [540, 0], ground_below_tape: 64 };
export const gatePost = s => svg(120, 440, GATES[s].post(ART[s]));
export const gateArch = s => svg(900, 240, GATES[s].arch(ART[s]));
// Traka (ista za svih 8): mint s kremastim kockicama, ink rub, tvrda sjena ispod.
export function tape() {
  let sq = ''; for (let i = 0; i < 52; i++) { const x = 14 + i * 15; sq += 'M' + x + ',' + (i % 2 ? 26 : 40) + 'h15v14h-15Z'; }
  return svg(800, 80, rect(14, 58, 772, 10, 5, 'rgba(26,26,20,.24)') + rect(8, 24, 784, 32, 6, MINT, INK, 4) + path(sq, CREAM) + rect(8, 24, 784, 32, 6, null, INK, 4) + circ(10, 40, 10, CREAM, INK, 4) + circ(790, 40, 10, CREAM, INK, 4));
}
// Pola trake poslije prolaska: pivot (12, 40) = čvor na stubu; desna = flip_h.
export function tapeHalf() {
  let sq = ''; for (let i = 0; i < 25; i++) { const x = 14 + i * 15; sq += 'M' + x + ',' + (i % 2 ? 26 : 40) + 'h15v14h-15Z'; }
  const sil = 'M8,24H396L388,32L398,40L386,48L396,56H8Z';
  return svg(420, 80, path(sil, MINT) + path(sq, CREAM) + path(sil, null, INK, 4) + circ(10, 40, 10, CREAM, INK, 4));
}

// ── A3 / B4 · fx ────────────────────────────────────────────────────────────
export const gustStreak = () => svg(18, 240, rect(3, 3, 12, 234, 6, CREAM));
export const burstRing = () => svg(200, 200, circ(100, 100, 92, null, CREAM, 10));
export const paceUp = () => svg(32, 32, path('M6,16L16,6L26,16M6,27L16,17L26,27', null, INK, 5));

// ── B · Endless ─────────────────────────────────────────────────────────────
export const rings = () => svg(54, 30, circ(15, 15, 11.5, null, INK, 6) + circ(39, 15, 11.5, null, INK, 6));
export const lockBody = () => svg(48, 42, rect(3, 3, 42, 36, 10, GOLD, INK, 4) + circ(24, 18, 5, INK) + rect(22, 20, 4, 10, 2, INK) + path('M10,12H22', null, 'rgba(255,255,255,.7)', 4));
export const lockShackle = () => svg(36, 30, path('M7,30V15A11,11 0 0 1 29,15V30', null, INK, 8) + path('M7,30V15A11,11 0 0 1 29,15V30', null, CHIP_RIM, 3));
export const ringTrack = () => svg(92, 92, circ(46, 46, 39, null, 'rgba(45,52,54,.18)', 9));
export const ringFill = () => svg(92, 92, circ(46, 46, 39, null, INK, 13) + circ(46, 46, 39, null, MINT, 7));
export const trophy = () => svg(44, 44, path('M8,10H3Q2,19 11,21M36,10H41Q42,19 33,21', null, INK, 4) + path('M10,5H34V15Q34,28 22,29Q10,28 10,15Z', GOLD, INK, 3.5) + rect(18, 29, 8, 6, 1, GOLD, INK, 3) + rect(12, 34, 20, 7, 3, GOLD, INK, 3.5) + path('M16,10V17', null, 'rgba(255,255,255,.8)', 3.5));
export const stampBest = () => svg(220, 220, path(pg(starPts(110, 110, 104, 90, 16, -90)), MINT, INK, 5) + circ(110, 110, 76, CREAM, INK, 4) + circ(110, 110, 64, null, MINT, 5));

// ── C · spremni sanduk (frejmovi bez sjene; sjena je zaseban sprite koji ostaje na tlu) ─────────
const CH_BODY = rect(32, 92, 136, 78, 14, GOLD, INK, 4) + rect(58, 94, 16, 74, 0, RIM) + rect(126, 94, 16, 74, 0, RIM);
const CH_LID = path('M28,98L28,70Q28,40 58,40L142,40Q172,40 172,70L172,98Z', '#E8C44A', INK, 4) + rect(58, 42, 16, 54, 0, RIM) + rect(126, 42, 16, 54, 0, RIM);
const CH_LOCKPLATE = rect(83, 80, 34, 38, 9, CREAM, INK, 3) + path(pg(starPts(100, 98, 10, 4.4)), PEACH, INK, 2.5);
const CH_BIGSTAR = path(pg(starPts(100, 64, 15, 6.6)), CREAM, INK, 3);
const CH_INSIDE = rect(40, 80, 120, 22, 6, '#9E6645', INK, 3) + circ(76, 82, 11, GOLD, INK, 3) + circ(100, 77, 12, GOLD, INK, 3) + circ(124, 82, 11, GOLD, INK, 3);
const CH_RAYS = path('M38,86L4,66L6,82ZM36,96L2,98L8,110ZM162,86L196,66L194,82ZM164,96L198,98L192,110Z', RIM, INK, 2.5);
export const chestClosed = big => svg(200, 190, CH_BODY + CH_LID + (big ? CH_BIGSTAR + rect(83, 92, 34, 38, 9, CREAM, INK, 3) + path(pg(starPts(100, 110, 10, 4.4)), PEACH, INK, 2.5) : CH_LOCKPLATE));
export const chestPeek = big => svg(200, 190, CH_RAYS + CH_BODY + CH_INSIDE + grp('translate(0 -' + (big ? 26 : 18) + ') rotate(' + (big ? -7 : -5) + ' 100 98)', CH_LID + (big ? CH_BIGSTAR : '')) + rect(83, 110, 34, 30, 9, CREAM, INK, 3) + path(pg(starPts(100, 125, 9, 4)), PEACH, INK, 2.5));
export const chestShadow = () => svg(160, 28, ell(80, 14, 78, 13, 'rgba(26,26,20,.24)'));

// ── Manifest (izvoz u assets/) ───────────────────────────────────────────────
export function ASSETS() {
  const out = [];
  BANDS.forEach(B => { out.push(['bands/tag_' + B.n + '.svg', bandTag(B.n, false)]); out.push(['bands/tag_' + B.n + '_peak.svg', bandTag(B.n, true)]); out.push(['bands/flag_' + B.n + '.svg', bandFlag(B.n)]); });
  SEASONS.forEach(s => { out.push(['obstacles/' + s + '_pair_wide.svg', pairWide(s)]); out.push(['obstacles/' + s + '_pair_side.svg', pairSide(s)]); });
  SEASONS.forEach(s => { out.push(['finish/' + s + '_post.svg', gatePost(s)]); out.push(['finish/' + s + '_arch.svg', gateArch(s)]); });
  out.push(['finish/tape.svg', tape()], ['finish/tape_half.svg', tapeHalf()]);
  out.push(['fx/gust_streak.svg', gustStreak()], ['fx/burst_ring.svg', burstRing()], ['fx/pace_up.svg', paceUp()]);
  out.push(['endless/rings.svg', rings()], ['endless/lock_body.svg', lockBody()], ['endless/lock_shackle.svg', lockShackle()], ['endless/ring_track.svg', ringTrack()], ['endless/ring_fill.svg', ringFill()], ['endless/trophy.svg', trophy()], ['endless/stamp_best.svg', stampBest()]);
  out.push(['chest/ready_closed.svg', chestClosed(false)], ['chest/ready_peek.svg', chestPeek(false)], ['chest/big_ready_closed.svg', chestClosed(true)], ['chest/big_ready_peek.svg', chestPeek(true)], ['chest/shadow.svg', chestShadow()]);
  return out;
}

// ── Run scena za mock (iz seasons_kit KITS[id].run): statični sloj + slojevi koji se pomjeraju ─────
// K = seasons_kit modul. Vraća SVG string-ove; po frejmu mock mijenja samo translateY sloja.
export function runLayers(K, season) {
  const R = K.KITS[season].run, out = { ground: R.ground, lane: R.lane, edge: R.laneEdge, seam: R.seam, collar: R.collar };
  const lanesX = [170, 440, 710];
  const m = K.laneTile(R.material, 200), mp = m.period;
  let t = ''; for (let y = 0; y < 1920 + mp; y += mp) lanesX.forEach(x0 => m.items.forEach(it => { t += it.k === 'rect' ? rect(x0 + it.x, y + it.y, it.w, it.h, it.r || 0, it.f) : circ(x0 + it.x, y + it.y, it.r, it.f); }));
  out.tile = { period: mp, svg: t };
  let s = ''; for (let y = -108; y < 1920 + 108; y += 108) SEAMS.forEach(x => s += rect(x - 3, y, 6, 46, 3, R.seam)); out.seams = { period: 108, svg: s };
  const cache = new Map(), shp = (shape, pal, size) => { const k = shape + '|' + pal + '|' + size; if (!cache.has(k)) cache.set(k, K.shapePaths(shape, pal, size).map(gp => ' d="' + gp.d + '" fill="' + (gp.f || 'none') + '"' + (gp.s ? ' stroke="' + gp.s + '" stroke-width="' + gp.sw + '" stroke-linejoin="round" stroke-linecap="round"' : '') + '/>').join('\u0001')); return cache.get(k).split('\u0001'); };
  const layer = L => { if (!L) return null; const P = L.period, items = K.runItems(L); let one = ''; items.forEach(it => (it.at || []).forEach(a => { const [x, y, size] = a; shp(it.shape, it.pal, size).forEach(gp => { one += '<path transform="translate(' + q(x - size) + ' ' + q(y - size) + ')"' + gp; }); })); let b = ''; for (let y0 = -P; y0 < 1920 + P; y0 += P) b += '<g transform="translate(0 ' + y0 + ')">' + one + '</g>'; return { period: P, speed: L.speed || 1, svg: b }; };
  out.near = layer(R.near); out.far = layer(R.far);
  out.obstacles = (R.obstacles || []).map(o => 'ref/obstacles/' + season + '__obstacle_' + o.id + '.svg');
  return out;
}
