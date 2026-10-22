// Level Path · jedini izvor brojeva: raspored 20 checkpointa, ruta, recepti kits[id].path (8 sezona),
// stanja, sprite SVG-ovi (assets/path, assets/fx) i godot/*.json. Isti modul čitaju LevelPath, RewardPopup i Specs.
// Recept = format Season Kita (band · ridge · mow · fence · row · poly · ellipse · line · shape · scatter) + 3 nove vrste
// sloja vezane za rutu: route (traka duž rute), route_marks (oblik iz SHAPES na svakih N px rute), spurs (krak do sanduka).
// Sve se računa jednom (keš po sezoni). Po frejmu: samo transform.
import * as K from './seasons_kit.js';
export { K };

// ── Osnovno ──────────────────────────────────────────────────────────────
export const W = 1080, H = 4900;                 // sadržaj skrola (3,0 stranice od 1633)
export const PAGE_Y = 143, PAGE_H = 1633;        // stranica huba (između headera 143 i footera 144)
export const SCROLL_MAX = H - PAGE_H;            // 3267
export const OPEN_Y = 1100;                      // y stranice Pipovog checkpointa na otvaranju (donja trećina, iznad Play)
export const VIEW_SAFE = [150, 1440];            // Pip se smatra vidljivim između ovih y stranice (ispod pločice, iznad donjeg reda)
export const SEASONS = K.SEASON_IDS;
export const ROW = { back: [70, 1477, 236, 124], play: [324, 1461, 432, 140], endless: [774, 1477, 236, 124] }; // = UiHomeField (stranica)
export const BAR = { coin: [66, 70], seed: [378, 70], flower: [690, 70] }; // artboard: centri ikona chipova u headeru
export const REWARD = { 5: [2, 200], 10: [4, 400], 15: [6, 600], 20: [10, 1000] }; // [★3 cvjetova sezone, coina]
export const REWARD_LEVELS = [5, 10, 15, 20];
export const STAR3 = Object.fromEntries(SEASONS.map(s => [s, K.ROSTER[s].find(r => r[2] === 3)]));
export const INK = '#2D3436', CREAM = '#FFF8F0', PEACH = '#FFB88C', PEACH_EDGE = '#E8A374', GOLD = '#FFD56B', UI_GOLD = '#E8C44A',
  MINT = '#A8E6CF', LAV = '#D4A5FF', PINK = '#FFCCD5', RIM = '#FFF6D6', SOFT = '#555C5E', BROWN = '#9E6645';

const r1 = v => Math.round(v * 10) / 10;
const fr = x => x - Math.floor(x);
const X = px => Math.round(px / W * 10000) / 100;      // px → % širine
const Y = px => Math.round(px / H * 100000) / 1000;    // px → % visine (1 % = 49 px)
const at = list => list.map(([x, y, s, r]) => [X(x), Y(y), s, r || 0]);

// ── 20 checkpointa: vijuga s periodom 8 (jedna stranica), korak 204, amplituda 2 × 140 ──
const OFF = [-1, -2, -1, 0, 1, 2, 1, 0, -1, -2, -1, 0, 1, 2, 1, 0, -1, -2, -1, 0];
const JX = [0, 2, -4, 0, 4, -2, -4, -4, 2, 2, -2, 2, 2, 0, 0, -2, -2, 0, 0, 0];
const JY = [0, -4, 6, -2, 4, 0, -6, 2, 6, -2, 4, -6, 2, -4, 6, 0, -4, 4, -2, 0];
export const CP = OFF.map((o, i) => ({ n: i + 1, x: 540 + o * 140 + JX[i], y: 4430 - i * 204 + JY[i], reward: REWARD_LEVELS.includes(i + 1) }));
// Sanduk stoji uz svoj kamen, na slobodnoj strani zavoja; (x, y) = sredina dna sanduka.
export const CHEST = { 5: { x: 440, y: 3612, big: false }, 10: { x: 620, y: 2530, big: false }, 15: { x: 440, y: 1572, big: false }, 20: { x: 792, y: 560, big: true } };
export const FLAG = { x: 296, y: 566 };                  // dno stuba zastavice cilja (lijevo od 20)
export const ROUTE_HEAD = [[540, 4960], [486, 4700]];     // ruta ulazi odozdo (iz polja)
export const SEG = 14;                                    // Catmull-Rom uzoraka po rasponu

export const ROUTE = (() => {
  const pts = ROUTE_HEAD.concat(CP.map(c => [c.x, c.y]));
  const d = K.smoothPts(pts, false, SEG);
  const len = [0];
  for (let i = 1; i < d.length; i++) len.push(len[i - 1] + Math.hypot(d[i][0] - d[i - 1][0], d[i][1] - d[i - 1][1]));
  return { pts: d, len, cpIdx: CP.map((c, i) => (i + ROUTE_HEAD.length) * SEG), total: len[len.length - 1] };
})();
export function routeD(i0, i1) { const p = ROUTE.pts.slice(i0, i1 + 1); return 'M' + p.map(q => r1(q[0]) + ',' + r1(q[1])).join('L'); }
// Pređeni put: od ulaza do checkpointa trenutnog levela (complete → do 20)
export function passedD(lvl) { const n = Math.max(1, Math.min(20, lvl)); return routeD(0, ROUTE.cpIdx[n - 1]); }
export function segD(n) { return routeD(ROUTE.cpIdx[n - 1], ROUTE.cpIdx[n]); } // od n do n+1
export function marksAlong(every, offset, skipR) {
  const P = ROUTE.pts, L = ROUTE.len, out = []; let next = offset;
  for (let i = 1; i < P.length; i++) {
    while (L[i] >= next) {
      const t = (next - L[i - 1]) / ((L[i] - L[i - 1]) || 1), x = P[i - 1][0] + (P[i][0] - P[i - 1][0]) * t, y = P[i - 1][1] + (P[i][1] - P[i - 1][1]) * t;
      const ang = Math.atan2(P[i][1] - P[i - 1][1], P[i][0] - P[i - 1][0]) * 180 / Math.PI;
      if (y < H + 30 && !CP.some(c => Math.hypot(c.x - x, (c.y - y) * 1.25) < skipR)) out.push([r1(x), r1(y), Math.round(ang)]);
      next += every;
    }
  }
  return out;
}
export function spursD() { return REWARD_LEVELS.map(n => { const c = CP[n - 1], s = CHEST[n]; return 'M' + c.x + ',' + c.y + 'L' + s.x + ',' + (s.y - 14); }).join(''); }
const pr = (x, y, w, h) => [x / W * 100, y / H * 100, w / W * 100, h / H * 100];
// Mirne zone: rasuti dekor (scatter) ne stavlja sidrište na rutu, kamenje, sanduke ni zastavicu.
export const AVOID = (() => {
  const a = [];
  for (let i = 0; i < ROUTE.pts.length; i += 2) { const [x, y] = ROUTE.pts[i]; a.push(pr(x - 84, y - 54, 168, 118)); }
  CP.forEach(c => a.push(pr(c.x - 104, c.y - 86, 208, 156)));
  Object.values(CHEST).forEach(c => { const s = c.big ? 1.3 : 1; a.push(pr(c.x - 140 * s, c.y - 220 * s, 280 * s, 310 * s)); });
  REWARD_LEVELS.forEach(n => { const c = CP[n - 1], s = CHEST[n]; for (let k = 0; k <= 4; k++) { const x = c.x + (s.x - c.x) * k / 4, y = c.y + (s.y - c.y) * k / 4; a.push(pr(x - 60, y - 50, 120, 100)); } });
  a.push(pr(FLAG.x - 70, FLAG.y - 250, 140, 280));
  return a;
})();
// Kolona motiva uz rub (R2 niz, bez RNG-a)
function column(x0, x1, y0, y1, step, s0, s1, ph = 0) {
  const out = []; let i = 0;
  for (let y = y0; y <= y1; y += step, i++) out.push([x0 + (x1 - x0) * fr(ph + 0.7548776662 * (i + 1)), y + (fr(ph + 0.5698402909 * (i + 1)) - 0.5) * step * 0.4, Math.round(s0 + (s1 - s0) * fr(ph + 0.6180339887 * (i + 1)))]);
  return out;
}

// ── Recepti kits[id].path · 8 sezona ──────────────────────────────────────────
// road: bed (podloga nepređene rute) · marks (isprekidani materijal) · passed (pređeno: puna traka, 2–3 poteza) · spur (krak do sanduka)
// stone: oblik lica checkpointa + boje po stanju (current je isti za svih 8: breskva kao Play)
const HAY = ['#E8D28C', '#CDB46A', '#F5E6B0'];
const CBR = { y: 8.9, w: [[0.25, 0.9, 2.2], [0.12, 1.9, 0.7]] };
const LG = [[0, 3.1], [12, 3.9], [25, 4.4], [38, 3.9], [50, 3.55], [62, 3.9], [75, 4.4], [88, 3.9], [100, 3.1]];
const STAR_SKY = ['#0C0A1F', '#100D26', '#14102D', '#191434'];
const MW_SKY = ['#141833', '#191E3D', '#1F2547', '#262C53'];
const LM_SKY = ['#120E22', '#171229', '#1D1631', '#241B3A'];
const EF_SKY = ['#160B08', '#1C0F0B', '#22120D', '#2A1610'];
const FO_SKY = ['#D9E7F6', '#E0ECF8', '#E7F0FA', '#EEF5FC'];
const CB_SKY = ['#E3F0EE', '#EAF4EA', '#F0F7E6', '#F5F9E2'];
const bands = (sky, y1) => sky.map((c, i) => ({ k: 'band', y0: y1 * i / sky.length, y1: y1 * (i + 1) / sky.length, c }));
const blob = (cx, cy, rw, rh, ph) => Array.from({ length: 8 }, (_, i) => { const a = i / 8 * 2 * Math.PI, k = 0.82 + 0.18 * fr(ph + 0.61803 * (i + 1)); return [X(cx + Math.cos(a) * rw * k), Y(cy + Math.sin(a) * rh * k)]; });
const smokeBand = (yc, ph) => { const top = [], bot = []; for (let i = 0; i <= 5; i++) { const x = i * 20, w = 0.5 * Math.sin(ph + i * 1.3); top.push([x, Y(yc) - 0.7 + w * 0.6]); bot.unshift([x, Y(yc) + 0.7 + w * 0.4]); } return top.concat(bot); };
const ZONES = [[1, 9.6, 98, 90]];

export const PATHS = {
  country_bloom: {
    place: 'Pašnjak: pokošene pruge niz livadu, ograda na vrhu, bale sijena uz zavoje.',
    road: { bed: [104, '#A9CF8A'], marks: { shape: 'pebble', every: 52, size: 46, pal: ['#F4EAD6'], rot: 0 }, spur: [60, '#A9CF8A'], passed: [[96, '#CDB46A'], [78, '#E8D28C']] },
    stone: { shape: 'round', done: { face: '#FFF8F0', rim: '#DCCFB9' }, locked: { face: '#D3E6C2', rim: '#B9D3A2', edge: '#A3C489', num: '#3E5A35' } },
    layers: [
      ...bands(CB_SKY, 9.6),
      { k: 'shape', shape: 'cloud', at: at([[290, 150, 220], [770, 104, 170], [968, 262, 118]]), pal: ['#FBFCF4'] },
      { k: 'ridge', r: { y: 6.6, w: [[0.45, 1.1, 0.4], [0.22, 2.7, 2.0]] }, c: '#D3E7C0' },
      { k: 'ridge', r: { y: 7.7, w: [[0.35, 0.8, 1.3], [0.18, 2.1, 0.2]] }, c: '#C3DDA8' },
      { k: 'shape', shape: 'bale', at: at([[170, 396, 54], [936, 382, 44], [880, 4200, 124], [990, 4440, 84], [168, 3380, 128], [300, 3220, 76], [884, 2560, 116], [176, 1770, 124], [900, 1010, 112], [994, 1190, 72], [150, 660, 84], [900, 4780, 96]]), pal: HAY },
      { k: 'stripes', r: CBR, ys: [8.9, 23.5, 38.1, 52.7, 67.3, 81.9, 96.5, 100], c: ['#BCDCA0', '#ACD18F'] },
      { k: 'fence', r: CBR, x0: 3, x1: 97, step: 6.2, size: 56, rails: [[0.74, 7], [0.36, 6]], pal: ['#F4EAD6', '#C9B48F'], rail: '#E6D8BC' },
      { k: 'scatter', shape: 'moss', n: 30, size: [70, 112], rot: [0, 0], phase: [0.21, 0.43, 0.7, 0], zones: ZONES, pal: ['#A3CC8A'] },
      { k: 'route', w: 104, c: '#A9CF8A' },
      { k: 'route_marks', shape: 'pebble', every: 52, size: 46, pal: ['#F4EAD6'], rot: 0, offset: 26, skip: 80 },
      { k: 'spurs', w: 60, c: '#A9CF8A' },
      { k: 'scatter', shape: 'tuft', n: 110, size: [36, 58], rot: [-6, 6], phase: [0.11, 0.37, 0.53, 0.71], zones: ZONES, pal: ['#93C27A'] },
      { k: 'scatter', shape: 'daisy', n: 84, size: [18, 27], rot: [0, 72], phase: [0.47, 0.05, 0.9, 0.33], zones: ZONES, pal: ['#FFF8F0', '#FFD56B'] },
      { k: 'scatter', shape: 'daisy', n: 36, size: [16, 22], rot: [0, 72], phase: [0.81, 0.62, 0.15, 0.4], zones: ZONES, pal: ['#FFCCD5', '#FFF8F0'] }
    ]
  },
  frost_orchard: {
    place: 'Zaleđeni voćnjak: drvored voćki sa snijegom uz oba ruba, zaleđene bare u zavojima, nanosi.',
    road: { bed: [104, '#DCE7F4'], marks: { shape: 'pebble', every: 50, size: 42, pal: ['#B9CBE0'] }, spur: [60, '#DCE7F4'], passed: [[96, '#7D93AE'], [78, '#C6D8EC'], [16, '#F2F7FD']] },
    stone: { shape: 'hex', done: { face: '#F7FAFE', rim: '#B9CBE0' }, locked: { face: '#E2EAF4', rim: '#CCDAEA', edge: '#B4C6DB', num: '#3E526E' } },
    layers: [
      ...bands(FO_SKY, 8.8),
      { k: 'shape', shape: 'cloud', at: at([[330, 128, 210], [812, 210, 150]]), pal: ['#F6FAFE'] },
      { k: 'ridge', r: { y: 7.3, w: [[0.06, 2, 0.3]] }, c: '#E2EAF4' },
      { k: 'row', shape: 'tree', r: { y: 7.35, w: [[0.06, 2, 0.3]] }, x0: 3, x1: 97, step: 5.6, size: 86, vary: 0.25, pal: ['#B9CBE0', '#8EA3BC', '#F7FAFE'] },
      { k: 'ridge', r: { y: 8.8, w: [[0.12, 1.4, 1.1]] }, c: '#EAF1F9' },
      { k: 'ellipse', at: [X(850), Y(4262)], r: [X(150), Y(70)], c: '#C6D8EC' },
      { k: 'ellipse', at: [X(862), Y(2600)], r: [X(140), Y(64)], c: '#C6D8EC' },
      { k: 'ellipse', at: [X(196), Y(1786)], r: [X(130), Y(60)], c: '#C6D8EC' },
      { k: 'shape', shape: 'puddle', at: at([[820, 4252, 190], [890, 4282, 110], [842, 2594, 170], [180, 1780, 150]]), pal: ['#C6D8EC', '#F2F7FD'] },
      { k: 'scatter', shape: 'drift', n: 40, size: [130, 214], rot: [0, 0], phase: [0.21, 0.66, 0.35, 0], zones: ZONES, pal: ['#DCE7F4', '#F7FAFE'] },
      { k: 'route', w: 104, c: '#DCE7F4' },
      { k: 'route_marks', shape: 'pebble', every: 50, size: 42, pal: ['#B9CBE0'], rot: 0, offset: 25, skip: 80 },
      { k: 'spurs', w: 60, c: '#DCE7F4' },
      { k: 'shape', shape: 'tree', at: at(column(26, 98, 640, 4860, 236, 156, 206, 0.1).concat(column(982, 1054, 600, 4860, 236, 156, 206, 0.6), [[214, 3370, 196], [110, 3570, 170], [900, 3060, 176], [904, 960, 196], [186, 610, 168]])), pal: ['#A7BDD6', '#7D93AE', '#F7FAFE'] },
      { k: 'scatter', shape: 'sparkle', n: 44, size: [12, 18], rot: [0, 45], phase: [0.05, 0.93, 0.44, 0.3], zones: ZONES, pal: ['#FFFFFF'] },
      { k: 'scatter', shape: 'tuft', n: 60, size: [26, 42], rot: [-6, 6], phase: [0.31, 0.12, 0.6, 0.2], zones: ZONES, pal: ['#B5C7DC'] }
    ]
  },
  lantern_meadow: {
    place: 'Livada u sumrak: visoka trava uz rubove, girlanda fenjera na vrhu, fenjeri na stubovima uz zavoje.',
    road: { bed: [104, '#251C3C'], marks: { shape: 'pebble', every: 50, size: 42, pal: ['#4F4482'] }, spur: [60, '#251C3C'], passed: [[96, '#7E6698'], [78, '#FFE3B8']] },
    stone: { shape: 'lobe', done: { face: '#E9E1F5', rim: '#A898C8' }, locked: { face: '#2F2648', rim: '#221A38', edge: '#43376A', num: '#D9D0F2' } },
    layers: [
      ...bands(LM_SKY, 9.2),
      { k: 'scatter', shape: 'dot', n: 22, size: [5, 8], rot: [0, 0], phase: [0.3, 0.7, 0.2, 0], zones: [[3, 0.5, 94, 6]], noAvoid: true, pal: ['#CFC4F0'] },
      { k: 'line', pts: LG, smooth: true, c: '#0B0814', w: 5 },
      { k: 'row', shape: 'lantern', pts: LG, x0: 6, x1: 94, step: 7.4, size: 72, pal: ['#FFB88C', '#FFE3B8', '#3B2F55'], alt: ['#7E6698', '#958099', '#3B2F55'] },
      { k: 'ridge', r: { y: 7.9, w: [[0.4, 1.3, 0.6], [0.2, 3.1, 1.4]] }, c: '#191329' },
      { k: 'ridge', r: { y: 9.2, w: [[0.15, 1.1, 2.1]] }, c: '#1C1730' },
      { k: 'scatter', shape: 'blade', n: 80, size: [50, 92], rot: [-8, 8], phase: [0.15, 0.62, 0.8, 0.45], zones: ZONES, pal: ['#2A2244'] },
      { k: 'route', w: 104, c: '#251C3C' },
      { k: 'route_marks', shape: 'pebble', every: 50, size: 42, pal: ['#4F4482'], rot: 0, offset: 25, skip: 80 },
      { k: 'spurs', w: 60, c: '#251C3C' },
      { k: 'poly', pts: K.sideGrass(9.2, 100, 10.5, 46, 0.3), c: '#120E1E' }, { k: 'poly', pts: K.sideGrass(9.2, 100, 10.5, 46, 0.7, true), c: '#120E1E' },
      { k: 'shape', shape: 'post', at: at([[712, 4150, 122], [300, 3420, 122], [724, 3010, 122], [790, 2480, 122], [300, 1850, 122], [770, 1330, 122], [726, 890, 122], [236, 520, 110]]), pal: ['#3B2F55', '#2A2142'] },
      { k: 'shape', shape: 'lantern', at: at([[712, 4040, 66], [724, 2900, 66], [300, 1740, 66], [726, 780, 66]]), pal: ['#FFB88C', '#FFE3B8', '#3B2F55'] },
      { k: 'shape', shape: 'lantern', at: at([[300, 3310, 66], [790, 2370, 66], [770, 1220, 66], [236, 420, 60]]), pal: ['#7E6698', '#958099', '#3B2F55'] },
      { k: 'scatter', shape: 'daisy', n: 70, size: [18, 26], rot: [0, 72], phase: [0.9, 0.47, 0.31, 0.2], zones: ZONES, pal: ['#FFEAA7', '#E8C44A'] },
      { k: 'scatter', shape: 'firefly', n: 26, size: [14, 20], rot: [0, 0], phase: [0.42, 0.28, 0.66, 0], zones: ZONES, pal: ['#FFF8D6', '#FFE27A'] }
    ]
  },
  amber_canopy: {
    place: 'Šumsko tlo pod krošnjom: lišće visi s vrha, tamna debla uz rubove, snopovi svjetla preko staze, gljive u zavojima.',
    road: { bed: [104, '#EACB97'], marks: { shape: 'leaf', every: 44, size: 36, pal: ['#D98C4A', '#A9652F'], rot: 34 }, spur: [60, '#EACB97'], passed: [[96, '#9C6A3E'], [78, '#F0A04B']] },
    stone: { shape: 'stump', done: { face: '#FBE3B4', rim: '#B07A44', ring: '#D9A066' }, locked: { face: '#E2C79A', rim: '#CBAE82', edge: '#BC9C6E', ring: '#D0B486', num: '#55361C' } },
    layers: [
      { k: 'band', y0: 0, y1: 100, c: '#F3DFB8' },
      { k: 'poly', pts: [[16, 3], [28, 3], [92, 100], [76, 100]], c: '#F7E8C9' },
      { k: 'poly', pts: [[60, 3], [70, 3], [40, 100], [26, 100]], c: '#FBF0D6' },
      { k: 'poly', pts: [[2, 30], [8, 30], [36, 100], [26, 100]], c: '#FBF0D6' },
      { k: 'scatter', shape: 'dapple', n: 44, size: [120, 204], rot: [0, 0], phase: [0.33, 0.12, 0.7, 0], zones: ZONES, pal: ['#FCF1D9'] },
      { k: 'route', w: 104, c: '#EACB97' },
      { k: 'route_marks', shape: 'leaf', every: 44, size: 36, pal: ['#D98C4A', '#A9652F'], rot: 34, offset: 22, skip: 80 },
      { k: 'spurs', w: 60, c: '#EACB97' },
      { k: 'scatter', shape: 'leaf', n: 100, size: [26, 38], rot: [0, 360], phase: [0.58, 0.36, 0.14, 0.9], zones: ZONES, pal: ['#E0904E', '#A9652F'] },
      { k: 'scatter', shape: 'acorn', n: 22, size: [20, 27], rot: [-25, 25], phase: [0.08, 0.77, 0.5, 0.25], zones: ZONES, pal: ['#B07A44', '#6E4A28'] },
      { k: 'scatter', shape: 'mushroom', n: 18, size: [30, 44], rot: [0, 0], phase: [0.72, 0.55, 0.3, 0], zones: ZONES, pal: ['#E8805A', '#FFF1DC'] },
      { k: 'shape', shape: 'mushroom', at: at([[860, 4190, 76], [912, 4224, 52], [170, 3420, 80], [222, 3446, 50], [884, 2560, 70], [200, 1790, 76], [252, 1812, 48], [872, 966, 70], [168, 640, 60]]), pal: ['#E8805A', '#FFF1DC'] },
      { k: 'poly', pts: [[0, 0], [3, 0], [3, 12], [5.4, 20], [4.4, 38], [5.8, 56], [4.2, 74], [5.2, 90], [3, 100], [0, 100]], c: '#3A2614' },
      { k: 'poly', pts: [[100, 0], [97, 0], [97, 16], [94.8, 26], [95.6, 44], [94.2, 62], [95.8, 80], [94.6, 94], [97, 100], [100, 100]], c: '#3A2614' },
      { k: 'ridge', up: true, r: { y: 3.8, w: [[0.5, 6.5, 0.4], [0.2, 13, 1.1]] }, c: '#E8AE58' },
      { k: 'ridge', up: true, r: { y: 2.6, w: [[0.6, 7.5, 1.4], [0.2, 15, 0.2]] }, c: '#F2C46A' },
      { k: 'row', shape: 'leaf', r: { y: 2.95, w: [[0.6, 7.5, 1.4], [0.2, 15, 0.2]] }, x0: 2, x1: 98, step: 3.4, size: 38, vary: 0.3, pal: ['#F5B05C', '#F2C46A'], alt: ['#F7BE6E', '#F2C46A'] }
    ]
  },
  moonlit_warren: {
    place: 'Zečje brdo noću: veliki mjesec iznad cilja, humke s jazbinama u zavojima, mahovina i rosa.',
    road: { bed: [104, '#1A1E3E'], marks: { shape: 'pebble', every: 50, size: 40, pal: ['#4A5290'] }, spur: [60, '#1A1E3E'], passed: [[96, '#4D5698'], [78, '#CFD3FF']] },
    stone: { shape: 'moon', done: { face: '#EDEBFF', rim: '#A9AEF0', crater: '#D2D0F2' }, locked: { face: '#2E3566', rim: '#222852', edge: '#454E8A', crater: '#283063', num: '#DCDDFF' } },
    layers: [
      ...bands(MW_SKY, 9),
      { k: 'scatter', shape: 'dot', n: 26, size: [5, 8], rot: [0, 0], phase: [0.61, 0.24, 0.5, 0], zones: [[2, 0.5, 96, 6.2]], noAvoid: true, pal: ['#DCDDFF'] },
      { k: 'shape', shape: 'moon', at: at([[884, 176, 184]]), pal: ['#EDEBFF', '#D2D0F2'] },
      { k: 'ridge', r: { y: 7.4, w: [[0.5, 1.6, 0.4], [0.25, 3.3, 1.7]] }, c: '#2B3263', rim: ['#4A5290', 5] },
      { k: 'ridge', r: { y: 8.8, w: [[0.2, 1.2, 2.4], [0.1, 2.6, 0.9]] }, c: '#232955' },
      { k: 'shape', shape: 'mound', at: at([[880, 4320, 470], [150, 3480, 380], [884, 2720, 440], [150, 1930, 380], [884, 1200, 420], [140, 700, 280]]), pal: ['#2E3566', '#3B4380'] },
      { k: 'shape', shape: 'burrow', at: at([[852, 4284, 112], [178, 3450, 96], [860, 2686, 104], [176, 1900, 96], [860, 1166, 100]]), pal: ['#0F1228', '#4D5698'] },
      { k: 'route', w: 104, c: '#1A1E3E' },
      { k: 'route_marks', shape: 'pebble', every: 50, size: 40, pal: ['#4A5290'], rot: 0, offset: 25, skip: 80 },
      { k: 'spurs', w: 60, c: '#1A1E3E' },
      { k: 'scatter', shape: 'moss', n: 56, size: [30, 48], rot: [0, 0], phase: [0.83, 0.07, 0.39, 0], zones: ZONES, pal: ['#2E4F5A'] },
      { k: 'scatter', shape: 'blade', n: 60, size: [34, 58], rot: [-8, 8], phase: [0.15, 0.62, 0.8, 0.45], zones: ZONES, pal: ['#2A3060'] },
      { k: 'scatter', shape: 'sparkle', n: 40, size: [12, 18], rot: [0, 45], phase: [0.12, 0.88, 0.63, 0.5], zones: ZONES, pal: ['#CFD3FF'] }
    ]
  },
  coral_tide: {
    place: 'Plaža uz plićak: more na vrhu i uz desni rub, koralj na rubu plime, plimne lokve, školjke i zvjezdače.',
    road: { bed: [104, '#E8C2A6'], marks: { shape: 'pebble', every: 50, size: 42, pal: ['#FFF1E8'] }, spur: [60, '#E8C2A6'], passed: [[96, '#2C5A62'], [78, '#4A7F88']] },
    stone: { shape: 'scallop', done: { face: '#FFF1E8', rim: '#E9B9A2' }, locked: { face: '#EBCDB4', rim: '#DDB89C', edge: '#CFA88A', num: '#6B4A36' } },
    layers: [
      { k: 'band', y0: 0, y1: 100, c: '#CDEEF2' },
      { k: 'ridge', r: { y: 3.9, tilt: -2.2, w: [[0.3, 1.4, 0.4]] }, c: '#93D7D4' },
      { k: 'scatter', shape: 'ripple', n: 12, size: [60, 104], rot: [0, 0], phase: [0.19, 0.4, 0.6, 0], zones: [[6, 0.5, 88, 2.8]], noAvoid: true, pal: ['#E6F7F8'] },
      { k: 'ridge', r: { y: 6.3, tilt: -2.2, w: [[0.35, 2.2, 0.4], [0.18, 4.1, 1.2]] }, c: '#F4FAF6' },
      { k: 'ridge', r: { y: 6.65, tilt: -2.2, w: [[0.35, 2.2, 0.4], [0.18, 4.1, 1.2]] }, c: '#E8C2A6' },
      { k: 'ridge', r: { y: 8.6, tilt: -1.6, w: [[0.3, 1.6, 2.2]] }, c: '#F2D6BC' },
      { k: 'line', smooth: true, pts: [[94.4, 8.4], [91.4, 16], [89.2, 28], [92.2, 40], [88.6, 52], [91.2, 64], [88.2, 77], [91.6, 89], [90.2, 100]], c: '#E8C2A6', w: 64 },
      { k: 'poly', smooth: true, pts: [[100, 8.2], [96.4, 10], [93.6, 16], [91.4, 28], [94.4, 40], [90.8, 52], [93.4, 64], [90.4, 77], [93.8, 89], [92.4, 100], [100, 100]], c: '#93D7D4' },
      { k: 'line', smooth: true, pts: [[96.4, 10], [93.6, 16], [91.4, 28], [94.4, 40], [90.8, 52], [93.4, 64], [90.4, 77], [93.8, 89], [92.4, 100]], c: '#F4FAF6', w: 14 },
      { k: 'shape', shape: 'puddle', at: at([[192, 3420, 250], [186, 1822, 240], [800, 4262, 250]]), pal: ['#93D7D4', '#E6F7F8'] },
      { k: 'route', w: 104, c: '#E8C2A6' },
      { k: 'route_marks', shape: 'pebble', every: 50, size: 42, pal: ['#FFF1E8'], rot: 0, offset: 25, skip: 80 },
      { k: 'spurs', w: 60, c: '#E8C2A6' },
      { k: 'shape', shape: 'coral', at: at([[962, 1240, 96], [930, 2240, 104], [956, 3300, 96], [932, 4420, 100], [968, 640, 84]]).concat([14, 26, 38, 50, 62, 74, 86].map((x, i) => [x, +(K.ridgeY({ y: 6.6, tilt: -2.2, w: [[0.35, 2.2, 0.4], [0.18, 4.1, 1.2]] }, x)).toFixed(3), [54, 66, 58, 70, 56, 64, 60][i], 0])), pal: ['#F59A8B', '#FFC5B8'] },
      { k: 'scatter', shape: 'pebble', n: 34, size: [16, 30], rot: [0, 0], phase: [0.7, 0.2, 0.45, 0], zones: [[1, 9, 86, 91]], pal: ['#E3BFA4'] },
      { k: 'scatter', shape: 'shell', n: 50, size: [30, 44], rot: [-30, 30], phase: [0.36, 0.81, 0.27, 0.6], zones: [[1, 9, 86, 91]], pal: ['#FFF1E8', '#E9C2AE'] },
      { k: 'scatter', shape: 'starfish', n: 18, size: [34, 48], rot: [0, 72], phase: [0.93, 0.52, 0.15, 0.37], zones: [[1, 9, 86, 91]], pal: ['#F29B80', '#FFD0BE'] },
      { k: 'scatter', shape: 'thrift', n: 44, size: [30, 42], rot: [-8, 8], phase: [0.11, 0.29, 0.73, 0.2], zones: [[1, 9, 86, 91]], pal: ['#FFB3C1', '#7FA46E', '#FFE0E6'] }
    ]
  },
  starfall_glade: {
    place: 'Proplanak u jelama: zvjezdano nebo i meteori iznad cilja, jele uz rubove, čistine i paprat.',
    road: { bed: [104, '#171233'], marks: { shape: 'sparkle', every: 46, size: 36, pal: ['#8E84C8'], fixed: true }, spur: [60, '#171233'], passed: [[96, '#4A4288'], [78, '#E9E0FF']] },
    stone: { shape: 'star', done: { face: '#FFF2BF', rim: '#CDB677' }, locked: { face: '#2A2456', rim: '#1D1840', edge: '#453D7A', num: '#E9E0FF' } },
    layers: [
      ...bands(STAR_SKY, 8.8),
      { k: 'scatter', shape: 'dot', n: 32, size: [5, 9], rot: [0, 0], phase: [0.3, 0.7, 0.2, 0], zones: [[2, 0.4, 96, 6.4]], noAvoid: true, pal: ['#E9E0FF'] },
      { k: 'shape', shape: 'sparkle', at: at([[150, 92, 26], [384, 210, 18], [640, 72, 22], [966, 140, 24], [830, 296, 16]]), pal: ['#FFF2BF'] },
      { k: 'shape', shape: 'meteor', at: at([[300, 160, 164, 150], [764, 100, 132, 150]]), pal: ['#FFF2BF', '#B8A8F0'] },
      { k: 'poly', pts: K.spikes(0, 100, 4, 5.4, 7.4, 9.6, 2.0), c: '#0B0919' },
      { k: 'ridge', r: { y: 8.9, w: [[0.15, 1.2, 0.4]] }, c: '#1E1840' },
      { k: 'ellipse', at: [X(850), Y(4262)], r: [X(176), Y(92)], c: '#261F4C' },
      { k: 'ellipse', at: [X(856), Y(2624)], r: [X(170), Y(90)], c: '#261F4C' },
      { k: 'ellipse', at: [X(196), Y(1806)], r: [X(160), Y(86)], c: '#261F4C' },
      { k: 'ellipse', at: [X(192), Y(3424)], r: [X(160), Y(86)], c: '#261F4C' },
      { k: 'route', w: 104, c: '#171233' },
      { k: 'route_marks', shape: 'sparkle', every: 46, size: 36, pal: ['#8E84C8'], rot: 'fixed', offset: 23, skip: 80 },
      { k: 'spurs', w: 60, c: '#171233' },
      { k: 'scatter', shape: 'fern', n: 56, size: [40, 62], rot: [-8, 8], phase: [0.57, 0.91, 0.62, 0], zones: ZONES, pal: ['#342C5C'] },
      { k: 'shape', shape: 'fir', at: at(column(20, 92, 660, 4880, 210, 210, 290, 0.2).concat(column(988, 1060, 640, 4880, 210, 210, 290, 0.7))), pal: ['#0B0919', '#1A1436'] },
      { k: 'scatter', shape: 'sparkle', n: 46, size: [12, 18], rot: [0, 45], phase: [0.81, 0.36, 0.09, 0.2], zones: ZONES, pal: ['#D9CCFF'] },
      { k: 'scatter', shape: 'dot', n: 30, size: [5, 8], rot: [0, 0], phase: [0.14, 0.5, 0.77, 0], zones: ZONES, pal: ['#8E84C8'] }
    ]
  },
  ember_fen: {
    place: 'Močvara u sumrak vatre: daščana staza preko tresetišta, tamne lokve u zavojima, rogoz uz rubove, pojasevi dima, žeravica.',
    road: { bed: [104, '#1A0D09'], marks: { shape: 'stripe', every: 30, size: 74, pal: ['#55392B'], rot: 90 }, spur: [60, '#1A0D09'], passed: [[96, '#5A3E30'], [78, '#C8643A']] },
    stone: { shape: 'plank', done: { face: '#F7E4D8', rim: '#C29A84', seam: '#DCC1AE' }, locked: { face: '#3E2A22', rim: '#2A1A14', edge: '#5A3E30', seam: '#4E362A', num: '#FFD3B0' } },
    layers: [
      ...bands(EF_SKY, 7.2),
      { k: 'poly', pts: K.spikes(0, 100, 2.4, 3.4, 5.6, 7.4, 1.8), c: '#120806' },
      { k: 'ridge', r: { y: 6.9, w: [[0.1, 1.4, 0.2]] }, c: '#24130E' },
      { k: 'poly', smooth: true, pts: smokeBand(1180, 0.3), c: '#3A221C' },
      { k: 'poly', smooth: true, pts: smokeBand(2960, 1.7), c: '#3A221C' },
      { k: 'poly', smooth: true, pts: smokeBand(4040, 2.9), c: '#3A221C' },
      { k: 'poly', smooth: true, pts: blob(846, 4262, 168, 78, 0.2), c: '#120808' },
      { k: 'poly', smooth: true, pts: blob(194, 3424, 150, 72, 0.5), c: '#120808' },
      { k: 'poly', smooth: true, pts: blob(852, 2624, 160, 74, 0.8), c: '#120808' },
      { k: 'poly', smooth: true, pts: blob(196, 1806, 150, 70, 0.1), c: '#120808' },
      { k: 'shape', shape: 'puddle', at: at([[826, 4250, 150], [180, 3416, 130], [836, 2614, 140], [182, 1798, 130]]), pal: ['#120808', '#C8643A'] },
      { k: 'route', w: 104, c: '#1A0D09' },
      { k: 'route_marks', shape: 'stripe', every: 30, size: 74, pal: ['#55392B'], rot: 90, offset: 15, skip: 74 },
      { k: 'spurs', w: 60, c: '#1A0D09' },
      { k: 'scatter', shape: 'tuft', n: 50, size: [30, 46], rot: [-6, 6], phase: [0.68, 0.2, 0.84, 0], zones: ZONES, pal: ['#3E261C'] },
      { k: 'scatter', shape: 'cattail', n: 70, size: [84, 132], rot: [-6, 6], phase: [0.24, 0.55, 0.47, 0.3], zones: [[0, 9, 11, 91], [89, 9, 11, 91]], noAvoid: true, pal: ['#8A5536', '#2E1E1C'] },
      { k: 'shape', shape: 'cattail', at: at([[700, 4280, 110], [724, 4300, 84], [338, 3440, 104], [700, 2640, 108], [340, 1820, 104], [964, 1000, 120], [930, 1024, 90], [136, 650, 100]]), pal: ['#8A5536', '#2E1E1C'] },
      { k: 'scatter', shape: 'ember', n: 34, size: [10, 16], rot: [0, 0], phase: [0.14, 0.73, 0.28, 0], zones: ZONES, pal: ['#FFB074', '#FFE0B8'] }
    ]
  }
};

// ── Gradnja pozadine (jednom po sezoni) ─────────────────────────────────────────
// Potezi istog sloja i iste boje spajaju se u jednu putanju (širina = medijan, razlika ≤ 1 px) → ≤ 40 putanja po sezoni.
function mergeStrokes(gs) {
  const out = [], by = new Map();
  for (const g of gs) {
    if (g.s === 'none') { out.push(g); continue; }
    let m = by.get(g.s);
    if (!m) { m = { d: '', f: 'none', s: g.s, ws: [] }; by.set(g.s, m); out.push(m); }
    m.d += g.d; m.ws.push(+g.sw);
  }
  return out.map(g => g.ws ? { d: g.d, f: g.f, s: g.s, sw: String(g.ws.sort((a, b) => a - b)[g.ws.length >> 1]) } : g);
}
const CACHE = {};
export function buildPath(season) {
  if (CACHE[season]) return CACHE[season];
  const P = PATHS[season], groups = [];
  for (const L of P.layers) {
    if (L.k === 'route') groups.push({ d: routeD(0, ROUTE.pts.length - 1), f: 'none', s: L.c, sw: String(L.w) });
    else if (L.k === 'spurs') groups.push({ d: spursD(), f: 'none', s: L.c, sw: String(L.w) });
    else if (L.k === 'route_marks') {
      const pts = marksAlong(L.every, L.offset || L.every / 2, L.skip || 80);
      const rec = { layers: [{ k: 'shape', shape: L.shape, pal: L.pal, at: pts.map(([x, y, a], i) => [x / W * 100, y / H * 100, L.size, L.rot === 'fixed' ? (i % 2) * 45 : a + (L.rot || 0) * (L.shape === 'leaf' ? (i % 2 ? -1 : 1) : 1)]) }] };
      groups.push(...K.buildScene(rec, W, H, W, null).groups);
    } else if (L.k === 'stripes') { // pokošene pruge bez preklapanja: traka i između grebena ys[i] i ys[i+1], spojeno po boji
      const by = {};
      for (let i = 0; i < L.ys.length - 1; i++) {
        const top = [], bot = [];
        for (let x = 0; x <= 100.01; x += 2.5) { const r0 = { y: L.ys[i], w: L.r.w }, r9 = { y: L.ys[i + 1], w: L.r.w }; top.push([x * W / 100, (i === 0 ? K.ridgeY(r0, x) : K.ridgeY(r0, x)) * H / 100]); bot.unshift([x * W / 100, (i + 1 === L.ys.length - 1 ? 100.6 : K.ridgeY(r9, x) + 0.02) * H / 100]); }
        const c = L.c[i % 2]; by[c] = (by[c] || '') + pd(top.concat(bot));
      }
      Object.keys(by).forEach(c => groups.push({ d: by[c], f: c, s: 'none', sw: '0' }));
    } else groups.push(...mergeStrokes(K.buildScene({ layers: [L] }, W, H, W, AVOID).groups));
  }
  const polys = groups.reduce((a, g) => a + (g.d.match(/M/g) || []).length, 0);
  const bytes = groups.reduce((a, g) => a + g.d.length + 40, 0);
  return (CACHE[season] = { groups, stats: { layers: P.layers.length, nodes: groups.length, polys, bytes } });
}

// ── Stanja ──────────────────────────────────────────────────────────────────
// lvl = trenutni level 1…20, 21 = complete. claimed = [5, 10, …]
export function cpState(n, lvl) { return n < lvl ? 'done' : n === lvl ? 'current' : 'locked'; }
export function rewardState(n, lvl, claimed) { return n >= lvl ? 'reward_locked' : (claimed || []).includes(n) ? 'reward_claimed' : 'reward_ready'; }
export function readyList(lvl, claimed) { return REWARD_LEVELS.filter(n => rewardState(n, lvl, claimed) === 'reward_ready'); }
export function pipCp(lvl) { return CP[Math.min(20, Math.max(1, lvl)) - 1]; }
export function openScroll(lvl, claimed) {
  const c = pipCp(lvl); let y = c.y - OPEN_Y;
  // Neuzeta nagrada ispod Pipa (do 560 px) mora biti vidljiva iznad donjeg reda: spusti kadar tako da "Claim" stoji iznad Play reda.
  if (claimed) { const r = readyList(lvl, claimed).map(n => CHEST[n]).filter(ch => ch.y > c.y && ch.y - c.y < 560); if (r.length) { const bottom = Math.max(...r.map(ch => ch.y + 100)); if (bottom - y > VIEW_SAFE[1] - 20) y = bottom - (VIEW_SAFE[1] - 20); } }
  return Math.max(0, Math.min(SCROLL_MAX, y));
}
export function flowerSrc(season, base = 'flowers/') { return base + STAR3[season][0] + '_t3.svg'; }

// ── Sprite SVG (assets/path, assets/fx) ────────────────────────────────────────
const svgWrap = (w, h, body) => '<svg xmlns="http://www.w3.org/2000/svg" width="' + w + '" height="' + h + '" viewBox="0 0 ' + w + ' ' + h + '">' + body + '</svg>';
const pd = pts => 'M' + pts.map(p => r1(p[0]) + ',' + r1(p[1])).join('L') + 'Z';
export const STONE_BOX = [180, 140], STONE_FACE = { cx: 90, cy: 56, rx: 72, ry: 42, rim: 14 }, CURRENT_SCALE = 1.22;
function facePts(shape, cx, cy, rx, ry, n = 40) {
  const out = [];
  for (let i = 0; i < n; i++) {
    const a = i / n * 2 * Math.PI; let r = 1;
    if (shape === 'hex') { const s = (a % (Math.PI / 3)) - Math.PI / 6; r = 0.86 * (Math.cos(Math.PI / 6) / Math.cos(s)) + 0.14; }
    else if (shape === 'lobe') r = 0.93 + 0.07 * Math.cos(4 * a);
    else if (shape === 'scallop') r = 0.93 + 0.07 * Math.abs(Math.cos(5 * a));
    else if (shape === 'star') r = 0.8 + 0.2 * Math.cos(5 * (a + Math.PI / 2));
    else if (shape === 'plank') r = 0.97 * Math.pow(Math.pow(Math.abs(Math.cos(a)), 4) + Math.pow(Math.abs(Math.sin(a)), 4), -0.25) * 0.86;
    out.push([cx + Math.cos(a) * rx * r, cy + Math.sin(a) * ry * r]);
  }
  return out;
}
// state: locked | done | current
export function stoneSVG(season, state) {
  const S = PATHS[season].stone, F = STONE_FACE, sh = S.shape;
  const c = state === 'current' ? { face: PEACH, rim: PEACH_EDGE, edge: INK, ring: '#F2A273', crater: '#F4A57A', seam: '#F0A070' } : state === 'done' ? Object.assign({ edge: INK }, S.done) : S.locked;
  const face = facePts(sh, F.cx, F.cy, F.rx, F.ry), rim = facePts(sh, F.cx, F.cy + F.rim, F.rx, F.ry);
  const sw = state === 'locked' ? 3 : 4;
  let b = '<path d="' + pd(rim) + '" fill="' + c.rim + '" stroke="' + c.edge + '" stroke-width="' + sw + '" stroke-linejoin="round"/>';
  b += '<path d="' + pd(face) + '" fill="' + c.face + '" stroke="' + c.edge + '" stroke-width="' + sw + '" stroke-linejoin="round"/>';
  const det = c.ring || c.crater || c.seam || (S.done.ring || S.done.crater || S.done.seam);
  if (sh === 'stump') b += '<ellipse cx="90" cy="56" rx="52" ry="29" fill="none" stroke="' + (c.ring || S.done.ring) + '" stroke-width="3"/><ellipse cx="90" cy="56" rx="30" ry="16" fill="none" stroke="' + (c.ring || S.done.ring) + '" stroke-width="3"/>';
  if (sh === 'moon') b += '<circle cx="50" cy="44" r="9" fill="' + (c.crater || S.done.crater) + '"/><circle cx="134" cy="66" r="7" fill="' + (c.crater || S.done.crater) + '"/><circle cx="122" cy="34" r="5" fill="' + (c.crater || S.done.crater) + '"/>';
  if (sh === 'plank') b += '<path d="M64,20L64,92M116,20L116,92" stroke="' + (c.seam || S.done.seam) + '" stroke-width="4" stroke-linecap="round"/>';
  if (sh === 'hex' && state !== 'locked') b += '<path d="M44,40L66,28" stroke="#FFFFFF" stroke-width="5" stroke-linecap="round"/>';
  if (state === 'done') b += '<circle cx="152" cy="24" r="19" fill="' + MINT + '" stroke="' + INK + '" stroke-width="3"/><path d="M143,24.5L149.5,31L161,17.5" fill="none" stroke="' + INK + '" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>';
  void det;
  return svgWrap(STONE_BOX[0], STONE_BOX[1], b);
}
export const CHEST_BOX = [200, 190], CHEST_ANCHOR = [100, 176], CHEST_BIG_SCALE = 1.3;
const lockIcon = (x, y) => '<circle cx="' + x + '" cy="' + y + '" r="23" fill="' + CREAM + '" stroke="' + INK + '" stroke-width="3"/><path d="M' + (x - 8) + ',' + (y - 2) + 'L' + (x - 8) + ',' + (y - 8) + 'A8,8 0 0 1 ' + (x + 8) + ',' + (y - 8) + 'L' + (x + 8) + ',' + (y - 2) + '" fill="none" stroke="' + INK + '" stroke-width="4.5" stroke-linecap="round"/><rect x="' + (x - 12) + '" y="' + (y - 3) + '" width="24" height="17" rx="4" fill="' + INK + '"/>';
const star5 = (cx, cy, ro, ri) => pd(Array.from({ length: 10 }, (_, i) => { const a = (-90 + i * 36) * Math.PI / 180, r = i % 2 ? ri : ro; return [cx + Math.cos(a) * r, cy + Math.sin(a) * r]; }));
// state: reward_locked | reward_ready | reward_claimed | open (otvoren, bez značke — junak popupa) ; big = nagrada 20
export function chestSVG(state, big) {
  const open = state === 'reward_claimed' || state === 'open';
  let b = state === 'reward_ready' ? '<ellipse cx="100" cy="176" rx="78" ry="13" fill="#1A1A14" fill-opacity="0.24"/>' : '';
  if (open) {
    b += '<path d="M34,92L46,30Q48,22 58,22L142,22Q152,22 154,30L166,92Z" fill="#D9B23E" stroke="' + INK + '" stroke-width="4" stroke-linejoin="round"/>';
    b += '<rect x="40" y="82" width="120" height="22" rx="6" fill="' + BROWN + '" stroke="' + INK + '" stroke-width="3"/>';
  }
  b += '<rect x="32" y="92" width="136" height="78" rx="14" fill="' + GOLD + '" stroke="' + INK + '" stroke-width="4"/>';
  b += '<rect x="58" y="94" width="16" height="74" fill="' + RIM + '"/><rect x="126" y="94" width="16" height="74" fill="' + RIM + '"/>';
  if (!open) {
    b += '<path d="M28,98L28,70Q28,40 58,40L142,40Q172,40 172,70L172,98Z" fill="' + UI_GOLD + '" stroke="' + INK + '" stroke-width="4" stroke-linejoin="round"/>';
    b += '<rect x="58" y="42" width="16" height="54" fill="' + RIM + '"/><rect x="126" y="42" width="16" height="54" fill="' + RIM + '"/>';
    if (big) b += '<path d="' + star5(100, 66, 17, 7.5) + '" fill="' + CREAM + '" stroke="' + INK + '" stroke-width="3" stroke-linejoin="round"/>';
    b += '<rect x="83" y="' + (big ? 92 : 80) + '" width="34" height="38" rx="9" fill="' + CREAM + '" stroke="' + INK + '" stroke-width="3"/>';
    const py = big ? 111 : 99;
    b += state === 'reward_ready' ? '<path d="' + star5(100, py, 11, 5) + '" fill="' + PEACH + '" stroke="' + INK + '" stroke-width="2.5" stroke-linejoin="round"/>' : '<circle cx="100" cy="' + (py - 4) + '" r="5" fill="' + INK + '"/><rect x="98" y="' + (py - 2) + '" width="4" height="11" rx="2" fill="' + INK + '"/>';
  }
  if (state === 'reward_locked') b += lockIcon(166, 46);
  if (state === 'reward_claimed') b += '<circle cx="166" cy="52" r="21" fill="' + MINT + '" stroke="' + INK + '" stroke-width="3"/><path d="M156,52.5L163,59.5L176,44.5" fill="none" stroke="' + INK + '" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>';
  return svgWrap(CHEST_BOX[0], CHEST_BOX[1], b);
}
export const FLAG_BOX = [150, 250], FLAG_ANCHOR = [42, 240], PENNANT_BOX = [100, 64], PENNANT_AT = { up: [44, 22], down: [44, 128] };
// Zastavica cilja = stub + zastavica (zasebno, da se diže samo transformom: y 128 → 22, 0,4 s)
export function poleSVG() {
  let b = '<ellipse cx="42" cy="240" rx="30" ry="8" fill="#1A1A14" fill-opacity="0.22"/>';
  b += '<rect x="37" y="20" width="10" height="222" rx="5" fill="' + CREAM + '" stroke="' + INK + '" stroke-width="3"/>';
  b += '<circle cx="42" cy="16" r="10" fill="' + GOLD + '" stroke="' + INK + '" stroke-width="3"/>';
  return svgWrap(FLAG_BOX[0], FLAG_BOX[1], b);
}
export function pennantSVG() {
  let b = '<path d="M3,4L94,31L3,60Z" fill="' + PEACH + '" stroke="' + INK + '" stroke-width="4" stroke-linejoin="round"/>';
  b += '<path d="' + star5(30, 31, 12, 5.4) + '" fill="' + CREAM + '" stroke="' + INK + '" stroke-width="2.5" stroke-linejoin="round"/>';
  return svgWrap(PENNANT_BOX[0], PENNANT_BOX[1], b);
}
// Ravna zvijezda zraka iza sanduka u popupu (12 trouglova, bez gradijenta)
export function burstSVG() {
  let b = '';
  for (let i = 0; i < 12; i++) { const a0 = (i * 30 - 6) * Math.PI / 180, a1 = (i * 30 + 6) * Math.PI / 180; b += '<path d="M160,160L' + r1(160 + Math.cos(a0) * 156) + ',' + r1(160 + Math.sin(a0) * 156) + 'L' + r1(160 + Math.cos(a1) * 156) + ',' + r1(160 + Math.sin(a1) * 156) + 'Z" fill="' + (i % 2 ? GOLD : RIM) + '"/>'; }
  b += '<circle cx="160" cy="160" r="70" fill="' + RIM + '"/>';
  return svgWrap(320, 320, b);
}
export const FX = {
  hop_dust: [52, 36, '<path d="M8,26a10,10 0 0 1 10,-12a12,12 0 0 1 22,2a8,8 0 0 1 4,15Z" fill="' + CREAM + '" stroke="' + INK + '" stroke-width="3" stroke-linejoin="round"/>'],
  land_ring: [168, 64, '<ellipse cx="84" cy="32" rx="78" ry="26" fill="none" stroke="' + INK + '" stroke-width="3"/><ellipse cx="84" cy="32" rx="72" ry="21" fill="none" stroke="' + CREAM + '" stroke-width="7"/>'],
  ready_spark: [44, 44, '<path d="M22,3L26.5,17.5L41,22L26.5,26.5L22,41L17.5,26.5L3,22L17.5,17.5Z" fill="' + CREAM + '" stroke="' + INK + '" stroke-width="3" stroke-linejoin="round"/>'],
  confetti_peach: [30, 20, '<rect x="2" y="2" width="26" height="16" rx="4" fill="' + PEACH + '" stroke="' + INK + '" stroke-width="2.5"/>'],
  confetti_mint: [28, 26, '<path d="M14,2L26,24L2,24Z" fill="' + MINT + '" stroke="' + INK + '" stroke-width="2.5" stroke-linejoin="round"/>'],
  confetti_lav: [24, 24, '<circle cx="12" cy="12" r="10" fill="' + LAV + '" stroke="' + INK + '" stroke-width="2.5"/>']
};
export function fxSVG(name) { const f = FX[name]; return svgWrap(f[0], f[1], f[2]); }
// Uzorak staze (pređeno lijevo, nepređeno desno) — za poređenje materijala
export function roadSVG(season) {
  const R = PATHS[season].road, m = R.marks;
  let b = '<rect width="420" height="120" fill="' + R.bed[1] + '" fill-opacity="0"/>';
  b += '<path d="M20,60L200,60" stroke="' + R.passed[0][1] + '" stroke-width="' + R.passed[0][0] + '" stroke-linecap="round"/>';
  R.passed.slice(1).forEach(p => { b += '<path d="M20,60L200,60" stroke="' + p[1] + '" stroke-width="' + p[0] + '" stroke-linecap="round"/>'; });
  b += '<path d="M210,60L400,60" stroke="' + R.bed[1] + '" stroke-width="' + R.bed[0] + '" stroke-linecap="round"/>';
  const g = K.buildScene({ layers: [{ k: 'shape', shape: m.shape, pal: m.pal, at: [0, 1, 2, 3].map(i => [(236 + i * m.every) / 420 * 100, 50, m.size, m.rot === 'fixed' || m.fixed ? 0 : (m.rot || 0)]) }] }, 420, 120, 420, null).groups;
  g.forEach(q => { b += '<path d="' + q.d + '" fill="' + q.f + '"' + (q.s !== 'none' ? ' stroke="' + q.s + '" stroke-width="' + q.sw + '" stroke-linecap="round"' : '') + '/>'; });
  return svgWrap(420, 120, b);
}
export const uri = svg => 'data:image/svg+xml;utf8,' + encodeURIComponent(svg);
export function assetFiles() {
  const f = {};
  SEASONS.forEach(s => { ['locked', 'done', 'current'].forEach(st => { f['assets/path/' + s + '/checkpoint_' + st + '.svg'] = stoneSVG(s, st); }); f['assets/path/' + s + '/road.svg'] = roadSVG(s); });
  ['reward_locked', 'reward_ready', 'reward_claimed', 'open'].forEach(st => { const k = st.replace('reward_', ''); f['assets/path/chest_' + k + '.svg'] = chestSVG(st, false); f['assets/path/chest_big_' + k + '.svg'] = chestSVG(st, true); });
  f['assets/path/goal_pole.svg'] = poleSVG(); f['assets/path/goal_pennant.svg'] = pennantSVG();
  f['assets/fx/reward_burst.svg'] = burstSVG();
  Object.keys(FX).forEach(k => { f['assets/fx/' + k + '.svg'] = fxSVG(k); });
  return f;
}

// ── Kontrast (≥ 4,5 : 1) ─────────────────────────────────────────────────────
export function contrastRows() {
  return SEASONS.map(s => {
    const S = PATHS[s].stone;
    return { season: s, locked: K.contrast(S.locked.num, S.locked.face), done: K.contrast(INK, S.done.face), current: K.contrast(INK, PEACH), tag: K.contrast(INK, CREAM), claim: K.contrast(INK, PEACH) };
  });
}

// ── Vremena i budžeti (README § Performanse, level_path_states.json) ─────────────
export const TIME = {
  hop_total: 1.0, hop_wait: 0.12, hop_jump: 0.7, hop_settle: 0.18, hop_arc: 74, hop_pip_anim: 'card_jump',
  land_pop: 0.2, land_pop_scale: 1.12, ring: 0.36, dust: 0.32,
  ready_bounce: 1.1, ready_bounce_px: 14, spark: 1.6, highlight: 0.5, highlight_scale: 1.22,
  locked_shake: 0.3, toast_show: 1.6, toast_in: 0.18, toast_out: 0.16,
  modal_in: 0.22, modal_out: 0.16, chip_in: 0.24, chip_stagger: 0.09,
  fly: 0.36, fly_stagger: 0.05, punch: 0.12, punch_scale: 1.12, fly_big: 0.4, fly_stagger_big: 0.04, modal_in_big: 0.3,
  confetti: 0.9, to_path: 0.56, to_field: 0.44, scroll_to_pip: 0.36, flag_raise: 0.4, banner_in: 0.28
};
export const FLY = { normal: { flowers: 3, coins: 4, sparks: 1 }, big: { flowers: 5, coins: 5, confetti: 6 } };
export function budgets() {
  const per = SEASONS.map(s => ({ s, ...buildPath(s).stats }));
  return {
    content_h: H, pages: +(H / PAGE_H).toFixed(2), screens: +(H / 1920).toFixed(2),
    layers_max: Math.max(...per.map(p => p.layers)), nodes_max: Math.max(...per.map(p => p.nodes)), per,
    hop_sprites: 6, ready_sprites: 4, ready_max: 4,
    // popup: panel + zrake + sanduk + cvijet + 2 chipa + letači + 2 trzaja chipova u baru (+ iskra / konfeti)
    popup_sprites: 1 + 1 + 1 + 1 + 2 + FLY.normal.flowers + FLY.normal.coins + 2 + FLY.normal.sparks,
    popup_big_sprites: 1 + 1 + 1 + 1 + 2 + FLY.big.flowers + FLY.big.coins + 2 + FLY.big.confetti,
    popup_time: +(TIME.modal_in + TIME.fly + (FLY.normal.flowers + FLY.normal.coins - 1) * TIME.fly_stagger + TIME.punch).toFixed(2),
    popup_big_time: +(TIME.modal_in_big + TIME.fly_big + (FLY.big.flowers + FLY.big.coins - 1) * TIME.fly_stagger_big + TIME.punch).toFixed(2)
  };
}
