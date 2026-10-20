// Season Kit — jedan red podataka po sezoni; svaka površina je rez istog kita.
// Faza 1: country_bloom i moonlit_warren su puni kitovi; ostalih 6 nose današnji izgled (LEGACY) dok ne stigne njihov red.
// Recept = brojevi (poligoni u %, rasuti elementi po R2 nizu, oblici od 6 primitiva) — isti format kao Arena v2,
// prošireno za grebene (zbir sinusa), red stubova uz greben i ambijent. 0 PNG. Računa se jednom; po frejmu samo pomak/alpha.

const fr = x => x - Math.floor(x);
const r2 = v => Math.round(v * 100) / 100;
const clamp01 = x => Math.max(0, Math.min(1, x));
function parseHex(h) { const s = h.replace('#', ''); return [0, 2, 4, 6].map(i => i < s.length ? parseInt(s.substr(i, 2), 16) : 255); }
function toHex(v) { return '#' + v.slice(0, 3).map(x => Math.round(Math.max(0, Math.min(255, x))).toString(16).padStart(2, '0')).join('').toUpperCase(); }
export function lerpHex(a, b, t) { const A = parseHex(a), B = parseHex(b); return toHex(A.map((x, i) => x + (B[i] - x) * t)); }
export function lum(hex) { const v = parseHex(hex).slice(0, 3).map(c => { c /= 255; return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4); }); return 0.2126 * v[0] + 0.7152 * v[1] + 0.0722 * v[2]; }
export function contrast(a, b) { const x = lum(a), y = lum(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); }
// Naljepnica (kontrola) prema livadi: dvostruki rub = jači od (ink rub, fill)
export function stickerContrast(fill, bg, ink = '#2D3436') { return Math.max(contrast(ink, bg), contrast(fill, bg)); }

export const W = 1080, H = 1633;
export const R2 = { a1: 0.7548776662466927, a2: 0.5698402909980532, size: 0.6180339887498949, rot: 0.41421356237309515 };

// ── Oblici (jedinica = veličina elementa; y raste nadole; [..., ci] = indeks boje u paleti) ──
const halfEll = (cx, cy, rx, ry, n = 14) => Array.from({ length: n + 1 }, (_, k) => { const a = Math.PI + Math.PI * k / n; return [r2(cx + Math.cos(a) * rx), r2(cy + Math.sin(a) * ry)]; });
const petals5 = (dist, r, ci) => Array.from({ length: 5 }, (_, k) => { const a = (-90 + k * 72) * Math.PI / 180; return ['c', r2(Math.cos(a) * dist), r2(Math.sin(a) * dist), r, ci]; });
export const SHAPES = {
  tuft: [['p', [[-0.5, 0], [-0.3, -0.78], [-0.12, 0]], 0], ['p', [[-0.18, 0], [0.02, -1], [0.2, 0]], 0], ['p', [[0.1, 0], [0.34, -0.7], [0.5, 0]], 0]],
  blade: [['p', [[-0.07, 0], [0.03, -1], [0.09, 0]], 0]],
  daisy: [...petals5(0.28, 0.18, 0), ['c', 0, 0, 0.15, 1]],
  dot: [['c', 0, 0, 0.5, 0]],
  sparkle: [['p', [[0, -0.5], [0.085, -0.085], [0.5, 0], [0.085, 0.085], [0, 0.5], [-0.085, 0.085], [-0.5, 0], [-0.085, -0.085]], 0]],
  cloud: [['e', -0.24, 0, 0.3, 0.16, 0], ['e', 0.06, -0.08, 0.3, 0.2, 0], ['e', 0.32, 0.01, 0.2, 0.12, 0], ['r', -0.5, 0, 1, 0.12, 0.06, 0]],
  // stub ograde (sidrište = dno): tijelo + kapa + sjena na desnoj strani
  post: [['r', -0.09, -1, 0.18, 1, 0.03, 0], ['r', 0.02, -1, 0.07, 1, 0.02, 1], ['p', [[-0.11, -1], [0, -1.1], [0.11, -1]], 0]],
  // okrugla bala (sidrište = dno, pogled sprijeda-bočno): plašt + čelo sa spiralom
  bale: [['r', -0.56, -0.62, 0.86, 0.62, 0.12, 0], ['e', 0.3, -0.31, 0.24, 0.31, 1], ['a', 0.3, -0.31, 0.15, 0, 300, 0.05, 2], ['a', 0.3, -0.31, 0.07, 40, 320, 0.04, 2], ['r', -0.5, -0.58, 0.6, 0.08, 0.04, 2]],
  moon: [['c', 0, 0, 0.5, 0], ['c', -0.16, -0.08, 0.1, 1], ['c', 0.18, 0.14, 0.07, 1], ['c', 0.06, -0.26, 0.05, 1], ['c', -0.2, 0.22, 0.06, 1]],
  // humka (sidrište = dno): kupola + osvijetljen rub prema mjesecu
  mound: [['p', halfEll(0, 0, 0.5, 0.3), 0], ['p', halfEll(0.07, -0.02, 0.4, 0.26).slice(5), 1]],
  burrow: [['e', 0, 0, 0.5, 0.32, 1], ['e', 0, 0.06, 0.38, 0.22, 0]],
  moss: [['c', -0.22, 0, 0.24, 0], ['c', 0.1, -0.06, 0.28, 0], ['c', 0.34, 0.05, 0.18, 0]],
  pebble: [['e', 0, 0, 0.5, 0.34, 0]],
  petal: [['e', 0, 0, 0.5, 0.26, 0]],
  stripe: [['r', -0.5, -0.08, 1, 0.16, 0.08, 0]]
};

// ── Greben = zbir sinusa: y(x) = y0 + Σ a·sin(2π·f·x/100 + p), sve u % ──
export function ridgeY(r, x) { let y = r.y + (r.tilt || 0) * (x - 50) / 100; for (const [a, f, p] of r.w || []) y += a * Math.sin(2 * Math.PI * f * x / 100 + p); return y; }
function ridgePts(r, step = 2.5) { const pts = []; for (let x = 0; x <= 100.01; x += step) pts.push([r2(x), r2(ridgeY(r, x))]); return pts; } // faza 2: sve unutar 0–100 % recta (lekcija §10.1/2)

// ── KITOVI ───────────────────────────────────────────────────────────────
const CB_SKY = ['#E3F0EE', '#EAF4EA', '#F0F7E6', '#F5F9E2'];
const MW_SKY = ['#141833', '#191E3D', '#1F2547', '#262C53'];
const CB_RIDGE = { y: 39.2, w: [[1.0, 0.9, 2.2], [0.5, 1.9, 0.7]] };
const CB_MOW = [39.2, 45.3, 51.4, 58.8, 67.4, 77.8, 88.2];

export const KITS = {
  country_bloom: {
    id: 'country_bloom', name: 'Country Bloom', kind: 'free', order: 1, phase: 1,
    place: 'Pašnjak kod kuće: valoviti brežuljci, ograda na grebenu, pokošena trava u prugama.',
    palette: {
      sky: CB_SKY, cloud: '#FBFCF4', hill_far: '#D3E7C0', hill_mid: '#C3DDA8', ridge: '#B4D497',
      mow_light: '#BCDCA0', mow_dark: '#ACD18F', near: '#C3E0A8', tuft: '#93C27A',
      fence: '#F4EAD6', fence_shade: '#C9B48F', rail: '#E6D8BC', hay: '#E8D28C', hay_shade: '#CDB46A', hay_light: '#F5E6B0',
      daisy: '#FFF8F0', daisy_eye: '#FFD56B', petal_pink: '#FFCCD5', ink_field: '#1A1A14', page: '#F4F9EF', flower_out: '#3D2B3D'
    },
    motifs: [
      { id: 'ridge_fence', name: 'Ograda na grebenu', how: 'recept: stubovi `post` po grebenu svakih 7 %, dvije letve (linija) prate greben' },
      { id: 'mown_stripes', name: 'Pokošene pruge', how: 'recept: 7 poligona između pomaknutih grebena, svijetlo/tamno naizmjenično' },
      { id: 'hay_bale', name: 'Okrugla bala sijena', how: 'recept: oblik `bale` na srednjem brežuljku; u runu prepreka (SVG)' }
    ],
    ambient: { id: 'petals', name: 'Latice na vjetru', n: 14, shape: 'petal', size: [12, 18], pal: ['#FFCCD5', '#FFF8F0'], zone: [0, 18, 100, 62], drift: [180, 40], sec: 11, alpha: [0, 0.9] },
    field: {
      layers: [
        { k: 'band', y0: 0, y1: 10.4, c: CB_SKY[0] }, { k: 'band', y0: 10.4, y1: 20.2, c: CB_SKY[1] }, { k: 'band', y0: 20.2, y1: 28.2, c: CB_SKY[2] }, { k: 'band', y0: 28.2, y1: 40, c: CB_SKY[3] },
        { k: 'shape', shape: 'cloud', at: [30, 18.6], size: 190, pal: ['#FBFCF4'] }, { k: 'shape', shape: 'cloud', at: [70, 16.2], size: 150, pal: ['#FBFCF4'] },
        { k: 'ridge', r: { y: 30.5, w: [[1.4, 1.1, 0.4], [0.8, 2.7, 2.0]] }, c: '#D3E7C0' },
        { k: 'ridge', r: { y: 34.2, w: [[1.2, 0.8, 1.3], [0.7, 2.1, 0.2]] }, c: '#C3DDA8' },
        { k: 'shape', shape: 'bale', at: [21, 35.4], size: 46, pal: ['#E8D28C', '#CDB46A', '#F5E6B0'] }, { k: 'shape', shape: 'bale', at: [79, 34.6], size: 38, pal: ['#E8D28C', '#CDB46A', '#F5E6B0'] },
        { k: 'mow', r: CB_RIDGE, ys: CB_MOW, flat: 0.12, c: ['#BCDCA0', '#ACD18F'], last: '#C3E0A8' },
        { k: 'fence', r: CB_RIDGE, x0: 3, x1: 97, step: 7, size: 50, rails: [[0.74, 7], [0.36, 6]], pal: ['#F4EAD6', '#C9B48F'], rail: '#E6D8BC' },
        { k: 'scatter', shape: 'tuft', n: 22, size: [30, 48], rot: [-6, 6], phase: [0.11, 0.37, 0.53, 0.71], zones: [[2, 46, 96, 40]], pal: ['#9CC983'] },
        { k: 'scatter', shape: 'daisy', n: 16, size: [16, 22], rot: [0, 72], phase: [0.47, 0.05, 0.9, 0.33], zones: [[2, 45, 96, 42]], pal: ['#FFF8F0', '#FFD56B'] }
      ]
    },
    // 13 mjesta = home_field_v2 (broj, dubine, pragovi, indeksi u seed_type_ids). CB: isti raspored — F red stoji ispred ograde.
    spots: [[10, 55, 88, 3, 5], [26, 54, 88, 0, 5], [42, 55, 88, 1, 5], [58, 54, 88, 4, 5], [74, 55, 88, 2, 5], [90, 54, 88, 5, 5], [18, 40, 116, 0, 1], [50, 42, 116, 1, 1], [82, 40, 116, 2, 1], [12, 29, 136, 3, 1], [66, 28, 136, 4, 1], [88, 30, 136, 5, 1], [34, 26, 168, 5, 10]],
    shop: null,
    arena: {
      base: ['#EEF6E6', '#F2F8EA'],
      layers: { hills_far: ['#D3E7C0', '#CBE3B4'], hills_mid: ['#C3DDA8', '#B8D899'], pasture: ['#B4D497', '#A9CF8A'] },
      addLayers: [{ id: 'mow', kind: 'poly', fill: ['#A9CD8C', '#9FC781'], after: 'pasture', stripes: [[26, 31.5], [38, 45], [53, 61.5], [71, 81], [91, 101]] }],
      scatter: { fence: ['#F4EAD6', '#C9B48F'], tuft: ['#93C27A'], clover: ['#A3CC8A'], stone: ['#A9C79A', '#C4DAB6'] },
      addScatter: [{ id: 'bale', shape: 'bale', n: [2, 2], size: [44, 44], grow: [1, 1], rot: [0, 0], phase: [0, 0, 0, 0], at: [[12, 18.6], [88, 18.2]], noAvoid: true, palette: ['#E8D28C', '#CDB46A', '#F5E6B0'] }],
      combo: { light: '#FFEAA7', ring: '#FFF8F0' }
    },
    run: {
      ground: '#2F4A33', lane: '#44663F', laneEdge: 'rgba(255,248,240,.20)', seam: 'rgba(255,248,240,.16)',
      material: { id: 'mown', name: 'Pokošena traka', stripe: 'rgba(255,248,240,.07)', on: 40, period: 124 },
      far: { id: 'clover_patches', name: 'Mrlje djeteline', speed: 0.35, period: 720, shape: 'moss', pal: ['#36553A'], at: [[16, 6, 180], [60, 32, 220], [86, 14, 160], [22, 62, 200], [72, 76, 210], [10, 88, 150]] },
      near: { id: 'fence_edge', name: 'Ograda uz rub', speed: 1, period: 480, posts: { x: [62, 1018], every: 240, size: 92, pal: ['#E9DCC0', '#B9A47E'], rail: '#D8C9A6' }, tufts: { shape: 'tuft', pal: ['#4E7A4F'], at: [[30, 40, 40], [140, 210, 34], [96, 370, 38], [950, 90, 36], [1050, 280, 40], [930, 420, 34]] }, flowers: { shape: 'daisy', pal: ['#FFF8F0', '#FFD56B'], at: [[150, 120, 22], [40, 300, 20], [990, 200, 22], [1040, 430, 20]] } },
      ambient: { id: 'petals', n: 12, shape: 'petal', size: [14, 20], pal: ['#FFCCD5', '#FFF8F0'], drift: [120, 900], sec: 6 },
      collar: ['#C9B98A', '#A99A6A'],
      obstacles: [{ id: 'hay_bale', name: 'Bala sijena', svg: 'assets/seasons/country_bloom/obstacle_hay_bale.svg' }, { id: 'fence_gate', name: 'Kapija ograde', svg: 'assets/seasons/country_bloom/obstacle_fence_gate.svg' }]
    }
  },
  moonlit_warren: {
    id: 'moonlit_warren', name: 'Moonlit Warren', kind: 'paid', order: -1, phase: 1,
    place: 'Zečje brdo noću: veliki mjesec, humke s jazbinama, mahovina i rosa.',
    palette: {
      sky: MW_SKY, star: '#DCDDFF', moon: '#EDEBFF', moon_crater: '#D2D0F2', mound_far: '#2B3263', rim: '#4A5290', ground: '#232955',
      mound: '#2E3566', mound_rim: '#4A5290', burrow: '#0F1228', burrow_rim: '#4D5698', moss: '#2E4F5A', glint: '#CFD3FF', near: '#1A1E3E',
      ink_field: '#FFF8F0', page: '#DFE1FF', flower_out: '#221B3A'
    },
    motifs: [
      { id: 'big_moon', name: 'Veliki mjesec', how: 'recept: oblik `moon` (krug + 4 kratera), uvijek desno gore, nikad iza kontrole' },
      { id: 'mounds_burrows', name: 'Humke s jazbinama', how: 'recept: `mound` (kupola + osvijetljen rub) + `burrow` (tamna rupa s rubom)' },
      { id: 'moss_dew', name: 'Mjesečeva mahovina i rosa', how: 'recept: `moss` jastučići + `sparkle` kapi rose' }
    ],
    ambient: { id: 'stars_motes', name: 'Zvijezde trepere + mrvice mjesečine', n: 18, twinkle: 10, motes: 8, pal: ['#DCDDFF', '#EDEBFF'], zone: [4, 2, 92, 24], moteZone: [6, 40, 88, 36], sec: 4.5 },
    field: {
      layers: [
        { k: 'band', y0: 0, y1: 9.8, c: MW_SKY[0] }, { k: 'band', y0: 9.8, y1: 18.4, c: MW_SKY[1] }, { k: 'band', y0: 18.4, y1: 26.3, c: MW_SKY[2] }, { k: 'band', y0: 26.3, y1: 40, c: MW_SKY[3] },
        { k: 'scatter', shape: 'dot', n: 16, size: [5, 8], rot: [0, 0], phase: [0.61, 0.24, 0.5, 0], zones: [[21, 13, 56, 13], [2, 26, 18, 8], [64, 27, 16, 6]], pal: ['#DCDDFF'] },
        { k: 'shape', shape: 'moon', at: [90.3, 20.2], size: 160, pal: ['#EDEBFF', '#D2D0F2'] },
        { k: 'ridge', r: { y: 35.2, w: [[2.0, 1.6, 0.4], [1.0, 3.3, 1.7]] }, c: '#2B3263', rim: ['#4A5290', 5] },
        { k: 'ridge', r: { y: 40.4, w: [[0.7, 1.2, 2.4], [0.4, 2.6, 0.9]] }, c: '#232955' },
        { k: 'shape', shape: 'mound', at: [21, 64], size: 440, pal: ['#2E3566', '#3B4380'] }, { k: 'shape', shape: 'mound', at: [80, 58], size: 360, pal: ['#2E3566', '#3B4380'] },
        { k: 'shape', shape: 'burrow', at: [26, 62.6], size: 112, pal: ['#0F1228', '#4D5698'] }, { k: 'shape', shape: 'burrow', at: [75, 57], size: 88, pal: ['#0F1228', '#4D5698'] },
        { k: 'scatter', shape: 'moss', n: 14, size: [30, 46], rot: [0, 0], phase: [0.83, 0.07, 0.39, 0], zones: [[3, 44, 94, 34]], pal: ['#2E4F5A'] },
        { k: 'scatter', shape: 'sparkle', n: 10, size: [12, 18], rot: [0, 45], phase: [0.12, 0.88, 0.63, 0.5], zones: [[3, 44, 94, 34]], pal: ['#CFD3FF'] },
        { k: 'ridge', r: { y: 79.6, w: [[0.5, 1.4, 0.2], [0.3, 3.1, 1.2]] }, c: '#1A1E3E' },
        { k: 'scatter', shape: 'blade', n: 24, size: [34, 58], rot: [-8, 8], phase: [0.15, 0.62, 0.8, 0.45], zones: [[1, 80.4, 98, 1.2]], pal: ['#262B55'] }
      ]
    },
    // MW: M red sjeda na humke (x 20 / 80), ostalo kao v2; dubine i pragovi isti.
    spots: [[10, 55, 88, 3, 5], [26, 54, 88, 0, 5], [42, 55, 88, 1, 5], [58, 54, 88, 4, 5], [74, 55, 88, 2, 5], [90, 54, 88, 5, 5], [20, 41, 116, 0, 1], [50, 42, 116, 1, 1], [80, 45, 116, 2, 1], [12, 29, 136, 3, 1], [64, 28, 136, 4, 1], [88, 30, 136, 5, 1], [36, 26, 168, 5, 10]],
    // Shop: panorama 1032 x 364 — mjesec izlazi između imena i dugmeta, humke na horizontu
    shop: {
      w: 1032, h: 364,
      layers: [
        { k: 'band', y0: 0, y1: 24, c: MW_SKY[0] }, { k: 'band', y0: 24, y1: 46, c: MW_SKY[1] }, { k: 'band', y0: 46, y1: 64, c: MW_SKY[2] }, { k: 'band', y0: 64, y1: 100, c: MW_SKY[3] },
        { k: 'scatter', shape: 'dot', n: 22, size: [4, 7], rot: [0, 0], phase: [0.3, 0.7, 0.2, 0], zones: [[1, 3, 98, 54]], pal: ['#DCDDFF'] },
        { k: 'shape', shape: 'moon', at: [57, 82], size: 150, pal: ['#EDEBFF', '#D2D0F2'] },
        { k: 'ridge', r: { y: 84, w: [[2.6, 1.8, 0.3], [1.4, 3.6, 1.1]] }, c: '#2B3263', rim: ['#4A5290', 4] },
        { k: 'shape', shape: 'burrow', at: [33, 90], size: 46, pal: ['#0F1228', '#4D5698'] }, { k: 'shape', shape: 'burrow', at: [80, 89], size: 38, pal: ['#0F1228', '#4D5698'] },
        { k: 'ridge', r: { y: 93, w: [[0.8, 2.2, 0.9]] }, c: '#1A1E3E' }
      ]
    },
    arena: {
      base: ['#191E3D', '#1F2547'],
      layers: { mounds_far: ['#2B3263', '#2E3568'], warren_ground: ['#232955', '#262C5B'], mounds_near: ['#2E3566', '#333B70'] },
      scatter: { burrow: ['#0F1228', '#4D5698'], moss: ['#2E4F5A'], glint: ['#CFD3FF'], sky_star: ['#DCDDFF'] },
      combo: { light: '#B8BDFF', ring: '#E6E4FF' }
    },
    run: {
      ground: '#1A1E3E', lane: '#323A6E', laneEdge: 'rgba(237,235,255,.24)', seam: 'rgba(237,235,255,.16)',
      material: { id: 'moon_path', name: 'Staza od mjesečevog kamenčića', pebble: 'rgba(237,235,255,.14)', period: 96 },
      far: { id: 'burrows', name: 'Jazbine u tlu', speed: 0.35, period: 720, shape: 'burrow', pal: ['#0F1228', '#2E3566'], at: [[14, 8, 120], [62, 30, 150], [88, 16, 110], [20, 60, 140], [74, 74, 130], [8, 90, 100]] },
      near: { id: 'moss_edge', name: 'Mahovina i rosa uz rub', speed: 1, period: 480, moss: { shape: 'moss', pal: ['#2E4F5A'], at: [[50, 60, 70], [120, 260, 60], [70, 420, 66], [980, 120, 64], [1040, 330, 70], [940, 440, 58]] }, glints: { shape: 'sparkle', pal: ['#CFD3FF'], at: [[150, 160, 18], [30, 350, 16], [1000, 40, 18], [920, 280, 16]] } },
      ambient: { id: 'motes', n: 14, shape: 'dot', size: [6, 10], pal: ['#EDEBFF', '#DCDDFF'], drift: [-60, 700], sec: 7 },
      collar: ['#3B4380', '#5A62A8'],
      obstacles: [{ id: 'burrow_mound', name: 'Humka s jazbinom', svg: 'assets/seasons/moonlit_warren/obstacle_burrow_mound.svg' }, { id: 'mossy_log', name: 'Oboreno deblo s mahovinom', svg: 'assets/seasons/moonlit_warren/obstacle_mossy_log.svg' }]
    }
  }
};

// Danas (Home v3 mood boje) — sezone bez kita u fazi 1: kartica/polje = 3 trake, run = tint.
export const LEGACY = {
  frost_orchard: { name: 'Frost Orchard', g: '#D1E6FF', kind: 'free', phase: 2 }, lantern_meadow: { name: 'Lantern Meadow', g: '#EBD6FF', kind: 'free', phase: 2 },
  amber_canopy: { name: 'Amber Canopy', g: '#FFEBC7', kind: 'free', phase: 2 }, coral_tide: { name: 'Coral Tide', g: '#FFE0D6', kind: 'paid', phase: 3 },
  starfall_glade: { name: 'Starfall Glade', g: '#DBCCFF', kind: 'paid', phase: 3 }, ember_fen: { name: 'Ember Fen', g: '#FFC79E', kind: 'paid', phase: 3 }
};
export function legacyBands(g) { const c = parseHex(g); return { sky: toHex(c.map(v => v + (255 - v) * 0.30)), far: g, near: toHex(c.map(v => v * 0.93)), page: toHex(c.map(v => v + (255 - v) * 0.55)) }; }

// Cvijeće: roster (seasons.json) + red na kartici (season_stage.gd _roster: ★1 prvi, ★3 oko, ★2 prvi, ostali)
export const ROSTER = {
  country_bloom: [['clover', 'Meadow Clover', 1], ['daisy', 'Field Daisy', 1], ['buttercup', 'Buttercup Lane', 1], ['tulip', 'Barn Tulip', 2], ['sunflower', 'Sunfence', 2], ['pumpkin', 'Harvest Pumpkin', 3]],
  moonlit_warren: [['moon_moss', 'Moon Moss', 1], ['nightshade_petal', 'Nightshade Petal', 1], ['silver_harebell', 'Silver Harebell', 1], ['lunar_orchid', 'Lunar Orchid', 2], ['star_jasmine', 'Star Jasmine', 2], ['umbral_lily', 'Umbral Lily', 3]]
};
export function cardOrder(id) { const r = ROSTER[id]; const s1 = r.filter(x => x[2] === 1), s2 = r.filter(x => x[2] === 2), s3 = r.filter(x => x[2] === 3); const first = [s1[0], s3[0], s2[0]]; return first.concat(r.filter(x => !first.includes(x))); }
export const FLOWER_DIR = '../assets/flowers/';

// ── Graditelj scene: recept -> SVG putanje spojene po boji (malo DOM čvorova) ──
const f2 = v => (Math.round(v * 100) / 100).toString();
function mkT(tx, ty, rotDeg, sc) { const r = rotDeg * Math.PI / 180, c = Math.cos(r), sn = Math.sin(r); return { pt: (x, y) => [tx + sc * (c * x - sn * y), ty + sc * (sn * x + c * y)], sc, rot: rotDeg }; }
function rectPts(x, y, w, h, rad) { const r = Math.min(rad, w / 2, h / 2); if (r <= 0) return [[x, y], [x + w, y], [x + w, y + h], [x, y + h]]; const out = []; [[x + w - r, y + r, -90], [x + w - r, y + h - r, 0], [x + r, y + h - r, 90], [x + r, y + r, 180]].forEach(([cx, cy, a0]) => { for (let k = 0; k <= 4; k++) { const a = (a0 + k * 22.5) * Math.PI / 180; out.push([cx + Math.cos(a) * r, cy + Math.sin(a) * r]); } }); return out; }
function ellD(c, rx, ry, rot) { const r = rot * Math.PI / 180, dx = Math.cos(r) * rx, dy = Math.sin(r) * rx; return 'M' + f2(c[0] - dx) + ',' + f2(c[1] - dy) + 'a' + f2(rx) + ',' + f2(ry) + ' ' + f2(rot) + ' 1,0 ' + f2(2 * dx) + ',' + f2(2 * dy) + 'a' + f2(rx) + ',' + f2(ry) + ' ' + f2(rot) + ' 1,0 ' + f2(-2 * dx) + ',' + f2(-2 * dy) + 'Z'; }
const polyD = pts => 'M' + pts.map(q => f2(q[0]) + ',' + f2(q[1])).join('L') + 'Z';
function primAbs(p, T) {
  switch (p[0]) {
    case 'c': return { fill: true, d: ellD(T.pt(p[1], p[2]), p[3] * T.sc, p[3] * T.sc, 0) };
    case 'e': return { fill: true, d: ellD(T.pt(p[1], p[2]), p[3] * T.sc, p[4] * T.sc, T.rot) };
    case 'p': return { fill: true, d: polyD(p[1].map(q => T.pt(q[0], q[1]))) };
    case 'r': return { fill: true, d: polyD(rectPts(p[1], p[2], p[3], p[4], p[5]).map(q => T.pt(q[0], q[1]))) };
    case 'l': { const s0 = T.pt(p[1], p[2]), s1 = T.pt(p[3], p[4]); return { fill: false, w: p[5] * T.sc, d: 'M' + f2(s0[0]) + ',' + f2(s0[1]) + 'L' + f2(s1[0]) + ',' + f2(s1[1]) }; }
    case 'a': { const pts = []; for (let k = 0; k <= 10; k++) { const a = (p[4] + (p[5] - p[4]) * k / 10) * Math.PI / 180; pts.push(T.pt(p[1] + Math.cos(a) * p[3], p[2] + Math.sin(a) * p[3])); } return { fill: false, w: p[6] * T.sc, d: 'M' + pts.map(q => f2(q[0]) + ',' + f2(q[1])).join('L') }; }
  }
  return null;
}
export function scatterAt(L, i) {
  const z = L.zones[i % L.zones.length], k = Math.floor(i / L.zones.length), ph = L.phase;
  const x = z[0] + fr(ph[0] + R2.a1 * (k + 1)) * z[2], y = z[1] + fr(ph[1] + R2.a2 * (k + 1)) * z[3];
  const size = L.size[0] + (L.size[1] - L.size[0]) * fr(ph[2] + R2.size * (i + 1));
  const rot = (L.rot || [0, 0])[0] + ((L.rot || [0, 0])[1] - (L.rot || [0, 0])[0]) * fr(ph[3] + R2.rot * (i + 1));
  return { x, y, size, rot };
}
const inRect = (x, y, a) => x >= a[0] && x <= a[0] + a[2] && y >= a[1] && y <= a[1] + a[3];
// Catmull-Rom kroz tačke -> gusta lista (otvorena ili zatvorena); računa se jednom pri gradnji
export function smoothPts(pts, closed, seg = 6) {
  const n = pts.length, out = [], P = i => closed ? pts[(i + n) % n] : pts[Math.max(0, Math.min(n - 1, i))];
  const last = closed ? n : n - 1;
  for (let i = 0; i < last; i++) { const p0 = P(i - 1), p1 = P(i), p2 = P(i + 1), p3 = P(i + 2); for (let s2 = 0; s2 < seg; s2++) { const t = s2 / seg, t2 = t * t, t3 = t2 * t; out.push([0, 1].map(j => 0.5 * (2 * p1[j] + (-p0[j] + p2[j]) * t + (2 * p0[j] - 5 * p1[j] + 4 * p2[j] - p3[j]) * t2 + (-p0[j] + 3 * p1[j] - 3 * p2[j] + p3[j]) * t3))); } }
  if (!closed) out.push(pts[n - 1]);
  return out.map(q => [r2(q[0]), r2(q[1])]);
}
// y linije (lista tačaka u %) na x — za red motiva duž girlande
function lineY(pts, x) { for (let i = 1; i < pts.length; i++) if (x <= pts[i][0]) { const a = pts[i - 1], b = pts[i], t = (x - a[0]) / ((b[0] - a[0]) || 1); return a[1] + (b[1] - a[1]) * t; } return pts[pts.length - 1][1]; }
// Keepout kontrola polja (v2 + Looks) u % stranice — rasuti elementi tu ne crtaju centar (mirne zone)
export const FIELD_AVOID = [[0.7, 0.5, 19.6, 25], [79.6, 0.5, 19.6, 13], [19.6, 1.2, 60.7, 11.3], [5, 88.5, 90, 11.5], [79.6, 76.5, 19.6, 13]];
// rect = {w, h}: slojevi u % recta (0–100), oblici uniformno k = w / baseW. Isti poziv za polje, karticu (minijatura), prelaz, Shop i Camp.
// Vrste slojeva: band · ridge (+rim, up, tilt) · mow · fence · row · poly (smooth) · ellipse · line · shape (at = tačka ili lista) · scatter
export function buildScene(recipe, w, h, baseW = W, avoid = FIELD_AVOID) {
  const k = w / baseW, X = x => x * w / 100, Y = y => y * h / 100;
  const groups = [], byKey = new Map();
  const push = (key, mk, d) => { let g = byKey.get(key); if (!g) { g = mk(); byKey.set(key, g); groups.push(g); } g.d += d; };
  const fillD = (c, d) => push('f|' + c + '|' + groups.length, () => ({ d: '', f: c, s: 'none', sw: '0' }), d);
  const prims = (shape, pal, T) => { for (const p of SHAPES[shape]) { const ci = p[p.length - 1], col = pal[Math.min(ci, pal.length - 1)], a = primAbs(p, T); if (!a) continue; if (a.fill) push('F|' + col, () => ({ d: '', f: col, s: 'none', sw: '0' }), a.d); else { const sw = String(Math.round(a.w * 2) / 2); push('S|' + col + '|' + sw, () => ({ d: '', f: 'none', s: col, sw }), a.d); } } };
  const flush = () => byKey.clear(); // novi sloj = nova grupa (redoslijed crtanja)
  const P = pts => pts.map(q => f2(X(q[0])) + ',' + f2(Y(q[1]))).join('L');
  const closeD = (pts, up) => 'M' + P(pts) + 'L' + f2(X(100)) + ',' + f2(Y(up ? 0 : 100)) + 'L' + f2(X(0)) + ',' + f2(Y(up ? 0 : 100)) + 'Z';
  for (const L of recipe.layers) {
    flush();
    if (L.k === 'band') fillD(L.c, 'M0,' + f2(Y(L.y0)) + 'H' + f2(w) + 'V' + f2(Y(Math.min(100, L.y1 + 0.6))) + 'H0Z'); // preklop: bez AA šava
    else if (L.k === 'ridge') {
      const pts = ridgePts(L.r);
      fillD(L.c, closeD(pts, L.up));
      if (L.rim) groups.push({ d: 'M' + P(pts), f: 'none', s: L.rim[0], sw: String(L.rim[1] * k) });
    } else if (L.k === 'mow') {
      for (let i = 0; i < L.ys.length; i++) {
        const t = i / (L.ys.length - 1);
        const r0 = { y: L.ys[i], tilt: L.r.tilt, w: L.r.w.map(([a, f, p]) => [a * (1 - t * (1 - L.flat)), f, p]) };
        fillD(i === L.ys.length - 1 ? L.last : L.c[i % 2], closeD(ridgePts(r0)));
      }
    } else if (L.k === 'fence') {
      for (const [fr0, rw] of L.rails) { const pts = ridgePts(L.r).filter(q => q[0] >= L.x0 - 0.5 && q[0] <= L.x1 + 0.5); groups.push({ d: 'M' + pts.map(q => f2(X(q[0])) + ',' + f2(Y(q[1]) + 2 * k - fr0 * L.size * k)).join('L'), f: 'none', s: L.rail, sw: String(r2(rw * k)) }); }
      flush();
      for (let x = L.x0; x <= L.x1 + 0.01; x += L.step) prims('post', L.pal, mkT(X(x), Y(ridgeY(L.r, x)) + 2 * k, 0, L.size * k));
    } else if (L.k === 'row') { // motiv u redu duž grebena (r) ili linije (pts); veličina varira po R2 (vary), bez RNG-a
      let i = 0;
      for (let x = L.x0; x <= L.x1 + 0.01; x += L.step, i++) {
        const y = L.r ? ridgeY(L.r, x) : L.pts ? lineY(L.pts, x) : L.y;
        const sz = L.size * (1 + (L.vary || 0) * (fr(R2.size * (i + 1)) - 0.5));
        prims(L.shape, L.alt && i % 2 ? L.alt : L.pal, mkT(X(x), Y(y + (L.dy || 0)), 0, sz * k));
      }
    } else if (L.k === 'poly') fillD(L.c, 'M' + P(L.smooth ? smoothPts(L.pts, true) : L.pts) + 'Z');
    else if (L.k === 'ellipse') fillD(L.c, ellD([X(L.at[0]), Y(L.at[1])], X(L.r[0]), Y(L.r[1]), 0));
    else if (L.k === 'line') groups.push({ d: 'M' + P(L.smooth ? smoothPts(L.pts, false) : L.pts), f: 'none', s: L.c, sw: String(r2(L.w * k)) });
    else if (L.k === 'shape') { const ats = Array.isArray(L.at[0]) ? L.at : [L.at]; ats.forEach((q, i) => prims(L.shape, L.pal, mkT(X(q[0]), Y(q[1]), q[3] || 0, (q[2] || L.size) * k))); }
    else if (L.k === 'scatter') {
      for (let i = 0; i < L.n; i++) { const it = scatterAt(L, i); if (!L.noAvoid && avoid && avoid.some(a => inRect(it.x, it.y, a))) continue; prims(L.shape, L.pal, mkT(X(it.x), Y(it.y), it.rot, it.size * k)); }
    }
  }
  return { groups, w, h };
}

// Jedan oblik -> putanje (čestice ambijenta, run). Isti primitivi kao livada.
export function shapePaths(shape, pal, size, rot = 0) { const s = { layers: [{ k: 'shape', shape, at: [50, 50], size, pal }] }; return buildScene(s, size * 2, size * 2, size * 2, null).groups.map(g => ({ ...g, d: g.d })); }

// 13 mjesta u px recta (baza cvijeta) — isti % kao SeasonField._spot_position, veličina uniformno k
export function spotRects(kit, w, h) { const k = w / W; return kit.spots.map((s, i) => { const size = s[2] * k, cx = s[0] / 100 * w, by = h - s[1] / 100 * h; return { i, cx, by, size, idx: s[3], need: s[4] }; }); }

export const BUDGET = { ambient_max: 24, loops_max: 2, flower_kb_max: 12 };

// ════════════════════════════ FAZA 2 ════════════════════════════
// Novi oblici (isti 6 primitiva; [..., ci] = indeks boje)
const arcPts = (cx, cy, r, a0, a1, n) => Array.from({ length: n + 1 }, (_, i) => { const a = (a0 + (a1 - a0) * i / n) * Math.PI / 180; return [r2(cx + Math.cos(a) * r), r2(cy + Math.sin(a) * r)]; });
const starPts = (k, ro, ri, rot = -90) => Array.from({ length: k * 2 }, (_, i) => { const a = (rot + i * 180 / k) * Math.PI / 180, r = i % 2 ? ri : ro; return [r2(Math.cos(a) * r), r2(Math.sin(a) * r)]; });
Object.assign(SHAPES, {
  // voćka (sidrište = dno): deblo, krošnja od 3 kruga, kapa snijega
  tree: [['r', -0.05, -0.46, 0.1, 0.46, 0.02, 1], ['c', -0.19, -0.54, 0.22, 0], ['c', 0.19, -0.54, 0.22, 0], ['c', 0, -0.66, 0.28, 0], ['e', 0, -0.88, 0.2, 0.07, 2], ['e', -0.24, -0.72, 0.12, 0.05, 2], ['e', 0.24, -0.72, 0.12, 0.05, 2]],
  // jela (sidrište = dno): 3 sprata + deblo
  fir: [['r', -0.04, -0.14, 0.08, 0.14, 0.01, 1], ['p', [[-0.36, -0.12], [0, -0.52], [0.36, -0.12]], 0], ['p', [[-0.29, -0.4], [0, -0.78], [0.29, -0.4]], 0], ['p', [[-0.2, -0.68], [0, -1], [0.2, -0.68]], 0]],
  drift: [['p', halfEll(0, 0, 0.5, 0.15), 0], ['p', halfEll(-0.08, -0.012, 0.32, 0.1).slice(2, 12), 1]],
  puddle: [['e', 0, 0, 0.5, 0.18, 0], ['e', -0.14, -0.04, 0.2, 0.045, 1], ['l', 0.08, 0.05, 0.3, 0.03, 0.03, 1]],
  flake: [['l', 0, -0.5, 0, 0.5, 0.2, 1], ['l', -0.43, -0.25, 0.43, 0.25, 0.2, 1], ['l', -0.43, 0.25, 0.43, -0.25, 0.2, 1], ['l', 0, -0.44, 0, 0.44, 0.08, 0], ['l', -0.38, -0.22, 0.38, 0.22, 0.08, 0], ['l', -0.38, 0.22, 0.38, -0.22, 0.08, 0]],
  // fenjer (sidrište = tačka na girlandi)
  lantern: [['l', 0, 0, 0, 0.16, 0.035, 2], ['r', -0.15, 0.13, 0.3, 0.07, 0.02, 2], ['e', 0, 0.44, 0.27, 0.3, 0], ['e', 0, 0.45, 0.12, 0.18, 1], ['r', -0.11, 0.71, 0.22, 0.07, 0.02, 2]],
  firefly: [['c', 0, 0, 0.5, 1], ['c', 0, 0, 0.22, 0]],
  leaf: [['p', [[0, -0.5], [0.22, -0.26], [0.34, 0.02], [0.17, 0.3], [0, 0.5], [-0.17, 0.3], [-0.34, 0.02], [-0.22, -0.26]], 0], ['l', 0, -0.4, 0, 0.46, 0.06, 1]],
  acorn: [['e', 0, 0.08, 0.26, 0.32, 0], ['r', -0.3, -0.28, 0.6, 0.2, 0.1, 1], ['l', 0, -0.28, 0.05, -0.46, 0.07, 1]],
  mushroom: [['r', -0.1, -0.48, 0.2, 0.48, 0.06, 1], ['p', halfEll(0, -0.42, 0.42, 0.38), 0], ['c', -0.15, -0.6, 0.06, 1], ['c', 0.14, -0.66, 0.05, 1], ['c', 0.02, -0.52, 0.05, 1]],
  dapple: [['e', 0, 0, 0.5, 0.2, 0]],
  trunk: [['r', -0.07, -1, 0.14, 1, 0.02, 0], ['r', 0.02, -1, 0.04, 1, 0.01, 1]],
  ripple: [['a', 0, 0, 0.5, 200, 340, 0.07, 0], ['a', 0, 0.14, 0.3, 215, 325, 0.06, 0]],
  shell: [['p', [[0, 0.32], ...arcPts(0, 0.1, 0.5, 200, 340, 8)], 0], ['l', 0, 0.3, -0.36, -0.14, 0.05, 1], ['l', 0, 0.3, 0, -0.38, 0.05, 1], ['l', 0, 0.3, 0.36, -0.14, 0.05, 1], ['r', -0.12, 0.26, 0.24, 0.1, 0.04, 1]],
  starfish: [['p', starPts(5, 0.5, 0.21), 0], ['c', 0, 0, 0.08, 1]],
  coral: [['l', 0, 0, 0, -0.62, 0.13, 0], ['l', 0, -0.26, -0.3, -0.62, 0.11, 0], ['l', 0, -0.32, 0.3, -0.76, 0.11, 0], ['l', -0.18, -0.46, -0.4, -0.5, 0.09, 0], ['l', 0.18, -0.52, 0.38, -0.5, 0.09, 0], ['c', 0, -0.66, 0.08, 1], ['c', -0.3, -0.66, 0.07, 1], ['c', 0.3, -0.8, 0.07, 1]],
  thrift: [['l', 0, 0, 0, -0.62, 0.07, 1], ['c', 0, -0.74, 0.22, 0], ['c', -0.07, -0.8, 0.07, 2]],
  rock: [['p', [[-0.5, 0], [-0.42, -0.3], [-0.12, -0.46], [0.24, -0.4], [0.5, -0.12], [0.46, 0]], 0], ['p', [[-0.36, -0.28], [-0.12, -0.4], [0.1, -0.36], [-0.16, -0.24]], 1]],
  meteor: [['p', [[0.44, -0.07], [-0.5, -0.02], [-0.5, 0.02], [0.44, 0.07]], 1], ['c', 0.42, 0, 0.09, 0]],
  fern: [['l', 0, 0, 0.04, -1, 0.05, 0], ['p', [[0, -0.1], [-0.36, -0.42], [-0.02, -0.3]], 0], ['p', [[0.01, -0.14], [0.36, -0.48], [0.02, -0.34]], 0], ['p', [[0.01, -0.4], [-0.3, -0.74], [0.02, -0.58]], 0], ['p', [[0.02, -0.44], [0.3, -0.8], [0.03, -0.62]], 0]],
  cattail: [['l', 0, 0, 0.02, -1, 0.05, 1], ['r', -0.07, -0.88, 0.14, 0.36, 0.07, 0], ['p', [[0.02, 0], [0.32, -0.68], [0.07, -0.08]], 1], ['p', [[-0.02, 0], [-0.24, -0.52], [-0.06, -0.06]], 1]],
  ember: [['p', [[0, -0.5], [0.28, 0], [0, 0.5], [-0.28, 0]], 0], ['p', [[0, -0.24], [0.12, 0], [0, 0.24], [-0.12, 0]], 1]],
  bubble: [['a', 0, 0, 0.38, 0, 360, 0.16, 0], ['c', -0.13, -0.13, 0.09, 0]],
  glint: [['e', 0, 0, 0.5, 0.1, 0]],
  pad: [['p', [[0, 0], ...arcPts(0, 0, 0.5, -70, 250, 16)], 0], ['l', 0, 0, -0.3, 0.2, 0.04, 1], ['l', 0, 0, 0.32, 0.12, 0.04, 1]],
  smoke: [['e', -0.24, 0, 0.3, 0.16, 0], ['e', 0.1, -0.05, 0.34, 0.18, 0], ['e', 0.36, 0.02, 0.18, 0.11, 0]]
});
// Silueta šiljaka (trava, trska) kao poligon u %: zupci po R2 nizu, bez RNG-a
export function spikes(x0, x1, step, yTop, yLow, yBase, ph = 0) { const pts = [[x0, yBase]]; let i = 0; for (let x = x0; x <= x1 + 0.01; x += step, i++) { pts.push([r2(x), r2(yLow - (yLow - yTop) * (0.55 + 0.45 * fr(ph + R2.a1 * (i + 1))))]); pts.push([r2(Math.min(x1, x + step / 2)), yLow]); } pts.push([x1, yBase]); return pts; }
// Bočna trava (lijevo; desna = ogledalo): zupci prema unutra
export function sideGrass(y0, y1, depth, n, ph = 0, right = false) { const pts = [[0, y0]]; for (let i = 0; i < n; i++) { const t = (i + 0.5) / n, t2 = (i + 1) / n; pts.push([r2(depth * (0.55 + 0.45 * fr(ph + R2.a1 * (i + 1)))), r2(y0 + (y1 - y0) * t)]); pts.push([r2(depth * 0.25), r2(y0 + (y1 - y0) * t2)]); } pts.push([0, y1]); return right ? pts.map(p => [r2(100 - p[0]), p[1]]) : pts; }

// ── Generički ambijent (faza 2): čestica = oblik iz SHAPES + kretanje. Isti format za polje i run, svih 8 sezona. ──
// motion: drift (klizi drift px po ciklusu, ivice fade) · fall (= drift + njihanje sway) · rise (= drift prema gore + sway)
//         float (ljulja se oko tačke ±drift, alpha diše) · twinkle (stoji, alpha + pulse) · streak (preleti drift za duty dio ciklusa)
// polja: n, shape, size [a,b], pal (ci 0), pal2 (ci 1+), zone [x,y,w,h] %, drift [dx,dy] px, sway [amp px, talasa],
//        sec, rot (° po ciklusu), angle [a,b] (stalni nagib), alpha [min,max], fade, pulse (± skala), duty, ph [x,y]
export function ambientLayers(def) {
  if (!def) return [];
  let left = BUDGET.ambient_max;
  return (def.layers || []).map(L0 => {
    const L = { fade: 0.12, alpha: [0, 0.9], sway: [0, 1], rot: 0, pulse: 0, angle: [0, 0], ph: [0, 0], drift: [0, 0], duty: 1, pal2: [], ...L0 };
    const n = Math.min(L.n, left); left -= n;
    const z = L.zone, parts = [];
    for (let i = 0; i < n; i++) parts.push({ i, x: z[0] + fr(L.ph[0] + R2.a1 * (i + 1)) * z[2], y: z[1] + fr(L.ph[1] + R2.a2 * (i + 1)) * z[3], size: L.size[0] + (L.size[1] - L.size[0]) * fr(R2.size * (i + 1)), col: L.pal[i % L.pal.length], angle: L.angle[0] + (L.angle[1] - L.angle[0]) * fr(0.5 + R2.rot * (i + 1)), delay: -fr(R2.rot * (i + 1)) * L.sec });
    return { ...L, parts };
  });
}
// Stanje čestice u trenutku t ∈ [0,1) ciklusa: pomak px, rotacija °, skala, alpha. Petlja bez šava.
export function ambientAt(L, t) {
  const edge = t < L.fade ? t / L.fade : t > 1 - L.fade ? (1 - t) / L.fade : 1, wave = 0.5 - 0.5 * Math.cos(2 * Math.PI * t);
  const sw = L.sway[0] * Math.sin(2 * Math.PI * L.sway[1] * t), pul = 1 + L.pulse * Math.sin(2 * Math.PI * t);
  switch (L.motion) {
    case 'float': return { dx: L.drift[0] * Math.sin(2 * Math.PI * t), dy: L.drift[1] * Math.sin(4 * Math.PI * t) * 0.5, rot: L.rot * Math.sin(2 * Math.PI * t), s: pul, a: L.alpha[0] + (L.alpha[1] - L.alpha[0]) * wave };
    case 'twinkle': return { dx: 0, dy: 0, rot: 0, s: 1 + L.pulse * wave, a: L.alpha[0] + (L.alpha[1] - L.alpha[0]) * wave };
    case 'streak': { if (t > L.duty) return { dx: L.drift[0], dy: L.drift[1], rot: 0, s: 1, a: 0 }; const u = t / L.duty; return { dx: L.drift[0] * u, dy: L.drift[1] * u, rot: 0, s: 1, a: L.alpha[1] * Math.sin(Math.PI * u) }; }
    default: return { dx: L.drift[0] * t + sw, dy: L.drift[1] * t, rot: L.rot * t, s: pul, a: L.alpha[0] + (L.alpha[1] - L.alpha[0]) * edge };
  }
}
export function ambientCount(def) { return ambientLayers(def).reduce((a, L) => a + L.parts.length, 0); }

// ── Run: materijal staze (generički). Pločica širine staze × period, ponavlja se vertikalno, po frejmu samo pomak. ──
// kind: stripe {stripe, on, period} · pebble {pal, dots [[x%, y px, r]], period} · plank {fill, plank, gap, seam, knot, period} · rut {col, xs [%], w, dash, period}
export function laneTile(m, laneW = 192) {
  const out = [], p = m.period, kind = m.kind || (m.on ? 'stripe' : 'pebble');
  if (kind === 'stripe') out.push({ k: 'rect', x: 0, y: 0, w: laneW, h: m.on, f: m.stripe });
  else if (kind === 'pebble') { const dots = m.dots || [[16, 30, 7], [68, 78, 6], [44, 54, 5]]; const pal = m.pal || [m.pebble]; dots.forEach((d, i) => out.push({ k: 'circle', x: d[0] / 100 * laneW, y: d[1], r: d[2], f: pal[i % pal.length] })); }
  else if (kind === 'plank') { for (let y = 0; y < p; y += m.plank + m.gap) { out.push({ k: 'rect', x: 4, y, w: laneW - 8, h: m.plank, f: m.fill, r: 6 }); out.push({ k: 'rect', x: 4, y: y + m.plank - 7, w: laneW - 8, h: 7, f: m.seam, r: 3 }); if (m.knot) out.push({ k: 'circle', x: laneW * (0.25 + 0.5 * fr(R2.a1 * (y + 1))), y: y + m.plank * 0.42, r: 5, f: m.knot }); } }
  else if (kind === 'rut') m.xs.forEach(x => out.push({ k: 'rect', x: x / 100 * laneW - m.w / 2, y: 0, w: m.w, h: m.dash, f: m.col, r: m.w / 2 }));
  return { period: p, items: out };
}
// Run far/near: generički "items" [{shape, pal, at: [[x px, y px u pločici, size, rot°]]}]; stari ključevi faze 1 (posts, tufts, moss, flowers, glints, far.at) se prevode ovdje.
export function runItems(layer) {
  if (layer.items) return layer.items;
  const out = [];
  if (layer.at) out.push({ shape: layer.shape, pal: layer.pal, at: layer.at.map(([x, y, s]) => [x * 10.8, y * 7.2, s]) });
  if (layer.posts) { const at = []; for (let y = 0; y < layer.period; y += layer.posts.every) layer.posts.x.forEach(x => at.push([x, y + 150, layer.posts.size])); out.push({ shape: 'post', pal: layer.posts.pal, at }); }
  ['tufts', 'moss', 'flowers', 'glints'].forEach(key => { if (layer[key]) out.push({ shape: layer[key].shape, pal: layer[key].pal, at: layer[key].at }); });
  return out;
}

// ── Kitovi faze 2 ──
const STD_SPOTS = [[10, 55, 88, 3, 5], [26, 54, 88, 0, 5], [42, 55, 88, 1, 5], [58, 54, 88, 4, 5], [74, 55, 88, 2, 5], [90, 54, 88, 5, 5], [18, 40, 116, 0, 1], [50, 42, 116, 1, 1], [82, 40, 116, 2, 1], [12, 29, 136, 3, 1], [66, 28, 136, 4, 1], [88, 30, 136, 5, 1], [34, 26, 168, 5, 10]];
Object.assign(ROSTER, {
  frost_orchard: [['frost_snowdrop', 'Frost Snowdrop', 1], ['ice_crocus', 'Ice Crocus', 1], ['silver_aconite', 'Silver Aconite', 1], ['winter_camellia', 'Winter Camellia', 2], ['hoarfrost_rose', 'Hoarfrost Rose', 2], ['crystal_peony', 'Crystal Peony', 3]],
  lantern_meadow: [['dusk_firefly_grass', 'Dusk Firefly Grass', 1], ['paper_lantern_bloom', 'Paper Lantern Bloom', 1], ['evening_primrose', 'Evening Primrose', 1], ['foxfire_lily', 'Foxfire Lily', 2], ['glow_wisteria', 'Glow Wisteria', 2], ['midnight_lotus', 'Midnight Lotus', 3]],
  amber_canopy: [['copper_leaf', 'Copper Leaf', 1], ['maple_aster', 'Maple Aster', 1], ['russet_mallow', 'Russet Mallow', 1], ['cider_dahlia', 'Cider Dahlia', 2], ['golden_oak_bloom', 'Golden Oak Bloom', 2], ['amber_magnolia', 'Amber Magnolia', 3]],
  coral_tide: [['sea_thrift', 'Sea Thrift', 1], ['salt_daisy', 'Salt Daisy', 1], ['tide_anemone', 'Tide Anemone', 1], ['coral_hibiscus', 'Coral Hibiscus', 2], ['pearl_waterlily', 'Pearl Waterlily', 2], ['reef_crown', 'Reef Crown', 3]],
  starfall_glade: [['comet_sprig', 'Comet Sprig', 1], ['nebula_clover', 'Nebula Clover', 1], ['meteor_daisy', 'Meteor Daisy', 1], ['aurora_tulip', 'Aurora Tulip', 2], ['galaxy_sunburst', 'Galaxy Sunburst', 2], ['nova_bloom', 'Nova Bloom', 3]],
  ember_fen: [['marsh_rush', 'Marsh Rush', 1], ['peat_violet', 'Peat Violet', 1], ['cinder_buttercup', 'Cinder Buttercup', 1], ['flame_iris', 'Flame Iris', 2], ['smoke_lotus', 'Smoke Lotus', 2], ['fenfire_crown', 'Fenfire Crown', 3]]
});
// Generički ambijent i za fazu 1 (isti izgled; legacy id-evi petals / stars_motes ostaju radi postojećeg season_ambient.gd)
KITS.country_bloom.ambient.layers = [{ motion: 'drift', n: 14, shape: 'petal', size: [12, 18], pal: ['#FFCCD5', '#FFF8F0'], zone: [0, 18, 100, 62], drift: [180, 40], sec: 11, rot: 220, alpha: [0, 0.9], fade: 0.12, ph: [0.21, 0.63] }];
KITS.moonlit_warren.ambient.layers = [{ motion: 'twinkle', n: 10, shape: 'sparkle', size: [7, 12], pal: ['#DCDDFF'], zone: [4, 2, 92, 24], sec: 4.5, alpha: [0.2, 1], ph: [0.4, 0.1] }, { motion: 'rise', n: 8, shape: 'dot', size: [6, 10], pal: ['#EDEBFF'], zone: [6, 40, 88, 36], drift: [-24, -170], sec: 9, alpha: [0, 0.85], fade: 0.2, ph: [0.7, 0.3] }];
KITS.country_bloom.run.ambient.layers = [{ motion: 'drift', n: 12, shape: 'petal', size: [14, 20], pal: ['#FFCCD5', '#FFF8F0'], zone: [4, 0, 92, 90], drift: [120, 900], sec: 6, rot: 220, alpha: [0, 0.85], fade: 0.1, ph: [0.21, 0.63] }];
KITS.moonlit_warren.run.ambient.layers = [{ motion: 'drift', n: 14, shape: 'dot', size: [6, 10], pal: ['#EDEBFF', '#DCDDFF'], zone: [4, 0, 92, 90], drift: [-60, 700], sec: 7, alpha: [0, 0.85], fade: 0.1, ph: [0.21, 0.63] }];
KITS.country_bloom.run.material.kind = 'stripe'; KITS.moonlit_warren.run.material.kind = 'pebble';
KITS.country_bloom.camp = null; KITS.moonlit_warren.camp = null;
// Redoslijed u trakama (Home tabovi Free / Premium), unlock lanac, cijene (store), soon
export const BANDS = { free: ['country_bloom', 'frost_orchard', 'lantern_meadow', 'amber_canopy'], premium: ['moonlit_warren', 'coral_tide', 'starfall_glade', 'ember_fen'] };
export const PREV_FREE = { frost_orchard: 'country_bloom', lantern_meadow: 'frost_orchard', amber_canopy: 'lantern_meadow' };
export const SEASON_IDS = BANDS.free.concat(BANDS.premium);
export const PRICES = { moonlit_warren: '€2.99', coral_tide: '€3.49', starfall_glade: '€2.99' };
export const SOON = { ember_fen: true };

// Kompatibilnost sa SeasonScreen faze 1 (do prelaska na ambientLayers): stari oblik čestica za CB/MW
export function ambientParticles(kit) {
  const A = kit.ambient, out = [];
  if (A.id === 'petals') for (let i = 0; i < A.n; i++) out.push({ i, x: A.zone[0] + fr(0.21 + R2.a1 * (i + 1)) * A.zone[2], y: A.zone[1] + fr(0.63 + R2.a2 * (i + 1)) * A.zone[3], size: A.size[0] + (A.size[1] - A.size[0]) * fr(R2.size * (i + 1)), col: A.pal[i % 2], delay: -fr(R2.rot * (i + 1)) * A.sec, kind: 'petal' });
  else if (A.id === 'stars_motes') { for (let i = 0; i < A.twinkle; i++) out.push({ i, x: A.zone[0] + fr(0.4 + R2.a1 * (i + 1)) * A.zone[2], y: A.zone[1] + fr(0.1 + R2.a2 * (i + 1)) * A.zone[3], size: 7 + 5 * fr(R2.size * (i + 1)), col: A.pal[0], delay: -fr(R2.rot * (i + 1)) * A.sec, kind: 'twinkle' }); for (let i = 0; i < A.motes; i++) out.push({ i: A.twinkle + i, x: A.moteZone[0] + fr(0.7 + R2.a1 * (i + 1)) * A.moteZone[2], y: A.moteZone[1] + fr(0.3 + R2.a2 * (i + 1)) * A.moteZone[3], size: 6 + 4 * fr(R2.size * (i + 2)), col: A.pal[1], delay: -fr(R2.rot * (i + 3)) * A.sec * 2, kind: 'mote' }); }
  return out;
}

// ── Frost Orchard ──
const FROST_SKY = ['#D9E7F6', '#E0ECF8', '#E7F0FA', '#EEF5FC'];
KITS.frost_orchard = {
  id: 'frost_orchard', name: 'Frost Orchard', kind: 'free', order: 2, phase: 2,
  place: 'Zaleđeni voćnjak: ravan bijeli horizont, dva reda voćki sa snijegom na krošnjama, nanosi i zaleđena bara u sredini.',
  palette: { sky: FROST_SKY, cloud: '#F6FAFE', tree_far: '#B9CBE0', tree_near: '#A7BDD6', trunk: '#7D93AE', snow: '#F7FAFE', ground: '#EAF1F9', ground_far: '#E2EAF4', drift: '#DCE7F4', ice: '#C6D8EC', ice_shine: '#F2F7FD', near: '#F3F7FC', frost_grass: '#B5C7DC', ink_field: '#1A1A14', page: '#EEF4FB', flower_out: '#2B3550' },
  motifs: [
    { id: 'orchard_rows', name: 'Dva reda voćki', how: 'recept: row oblika tree na grebenu horizonta (13 malih) i na drugom grebenu (8 većih), kape snijega' },
    { id: 'frozen_pond', name: 'Zaleđena bara', how: 'recept: ellipse leda + dva odsjaja (puddle)' },
    { id: 'snow_drifts', name: 'Nanosi', how: 'recept: scatter oblika drift (sjena + svijetli vrh)' }
  ],
  ambient: { id: 'snow', name: 'Pahulje padaju i njišu se', n: 18, layers: [{ motion: 'fall', n: 18, shape: 'flake', size: [12, 20], pal: ['#FFFFFF'], pal2: ['#9DB3CF'], zone: [0, 0, 100, 56], drift: [40, 560], sway: [18, 1.5], sec: 10, rot: 140, alpha: [0, 0.95], fade: 0.1, ph: [0.13, 0.41] }] },
  field: { layers: [
    { k: 'band', y0: 0, y1: 9, c: FROST_SKY[0] }, { k: 'band', y0: 9, y1: 17, c: FROST_SKY[1] }, { k: 'band', y0: 17, y1: 25, c: FROST_SKY[2] }, { k: 'band', y0: 25, y1: 36, c: FROST_SKY[3] },
    { k: 'shape', shape: 'cloud', at: [[36, 15.6, 180], [70, 21, 130]], pal: ['#F6FAFE'] },
    { k: 'ridge', r: { y: 34.6, w: [[0.12, 2, 0.3]] }, c: '#E2EAF4' },
    { k: 'row', shape: 'tree', r: { y: 34.8, w: [[0.12, 2, 0.3]] }, x0: 3, x1: 97, step: 7.8, size: 72, vary: 0.25, pal: ['#B9CBE0', '#8EA3BC', '#F7FAFE'] },
    { k: 'ridge', r: { y: 40.2, w: [[0.3, 1.4, 1.1]] }, c: '#EAF1F9' },
    { k: 'row', shape: 'tree', r: { y: 40.6, w: [[0.3, 1.4, 1.1]] }, x0: 6, x1: 94, step: 12.6, size: 124, vary: 0.2, pal: ['#A7BDD6', '#7D93AE', '#F7FAFE'] },
    { k: 'ellipse', at: [52, 62.5], r: [21, 5.2], c: '#C6D8EC' },
    { k: 'shape', shape: 'puddle', at: [[46, 61.6, 150], [60, 63.6, 110]], pal: ['#C6D8EC', '#F2F7FD'] },
    { k: 'scatter', shape: 'drift', n: 9, size: [120, 190], rot: [0, 0], phase: [0.21, 0.66, 0.35, 0], zones: [[2, 46, 96, 38]], pal: ['#DCE7F4', '#F7FAFE'] },
    { k: 'scatter', shape: 'sparkle', n: 10, size: [12, 18], rot: [0, 45], phase: [0.05, 0.93, 0.44, 0.3], zones: [[4, 44, 92, 40]], pal: ['#FFFFFF'] },
    { k: 'ridge', r: { y: 84, w: [[0.6, 1.8, 0.4], [0.3, 4.2, 1.7]] }, c: '#F3F7FC' },
    { k: 'scatter', shape: 'tuft', n: 14, size: [26, 40], rot: [-6, 6], phase: [0.31, 0.12, 0.6, 0.2], zones: [[2, 84.6, 96, 2]], noAvoid: true, pal: ['#B5C7DC'] }
  ] },
  spots: STD_SPOTS,
  camp: { w: 1032, h: 318, layers: [
    { k: 'band', y0: 0, y1: 20, c: FROST_SKY[1] }, { k: 'band', y0: 20, y1: 40, c: FROST_SKY[2] }, { k: 'band', y0: 40, y1: 56, c: FROST_SKY[3] },
    { k: 'ridge', r: { y: 54, w: [[0.4, 2, 0.3]] }, c: '#E2EAF4' },
    { k: 'row', shape: 'tree', r: { y: 54.4, w: [[0.4, 2, 0.3]] }, x0: 2, x1: 98, step: 6.4, size: 92, vary: 0.25, pal: ['#C6D5E7', '#9FB2C8', '#F7FAFE'] },
    { k: 'ridge', r: { y: 66, w: [[0.6, 1.6, 1.1]] }, c: '#EAF1F9' },
    { k: 'shape', shape: 'drift', at: [[18, 86, 300], [74, 92, 360], [46, 98, 260]], pal: ['#DCE7F4', '#F7FAFE'] }
  ] },
  shop: null,
  arena: { base: ['#E3EEFB', '#E9F2FC'], layers: { snowfield: ['#E2EAF4', '#E6EDF6'], frost_ground: ['#C6D6E8', '#CCDCEE'] }, scatter: { trees_far: ['#B9CBE0', '#8EA3BC'], trees_near: ['#A7BDD6', '#7D93AE'] }, combo: { light: '#FFFFFF', ring: '#FFFFFF' } },
  run: {
    ground: '#DCE7F3', lane: '#5F7894', laneEdge: 'rgba(255,255,255,.55)', seam: 'rgba(255,255,255,.30)',
    material: { kind: 'rut', name: 'Ugažen snijeg s tragom sanki', col: '#7890AC', xs: [30, 70], w: 12, dash: 124, period: 124 },
    far: { id: 'frozen_puddles', name: 'Zaleđene lokve i nanosi', speed: 0.35, period: 720, items: [{ shape: 'puddle', pal: ['#C3D5EA', '#F2F7FD'], at: [[130, 60, 150], [960, 260, 130], [60, 470, 120], [1010, 610, 140]] }, { shape: 'drift', pal: ['#CCDBEC', '#F7FAFE'], at: [[40, 200, 170], [1050, 420, 180], [120, 680, 150]] }] },
    near: { id: 'orchard_edge', name: 'Voćke uz rub', speed: 1, period: 480, items: [{ shape: 'tree', pal: ['#A7BDD6', '#7D93AE', '#F7FAFE'], at: [[70, 200, 190], [1010, 440, 200]] }, { shape: 'tuft', pal: ['#9CB0C8'], at: [[140, 80, 40], [30, 360, 34], [940, 140, 38], [1060, 300, 34]] }] },
    ambient: { id: 'snow', n: 14, layers: [{ motion: 'fall', n: 14, shape: 'flake', size: [16, 24], pal: ['#FFFFFF'], pal2: ['#9DB3CF'], zone: [0, 0, 100, 40], drift: [60, 1100], sway: [24, 1.5], sec: 6, rot: 160, alpha: [0, 0.95], fade: 0.08, ph: [0.4, 0.2] }] },
    collar: ['#C9D7E6', '#9FB2C8'],
    obstacles: [{ id: 'ice_block', name: 'Blok leda', svg: 'assets/seasons/frost_orchard/obstacle_ice_block.svg' }, { id: 'snow_stump', name: 'Panj pod snijegom', svg: 'assets/seasons/frost_orchard/obstacle_snow_stump.svg' }]
  }
};

// ── Lantern Meadow (tamna) ──
const LANTERN_SKY = ['#120E22', '#171229', '#1D1631', '#241B3A'];
const LANTERN_GARLAND = [[0, 13.5], [12, 16.8], [25, 18.8], [38, 16.6], [50, 15.2], [62, 16.6], [75, 18.8], [88, 16.8], [100, 13.5]];
KITS.lantern_meadow = {
  id: 'lantern_meadow', name: 'Lantern Meadow', kind: 'free', order: 3, phase: 2,
  place: 'Livada u sumrak: visoka trava sa strana, girlanda papirnih fenjera preko sredine, svici iznad trave.',
  palette: { sky: LANTERN_SKY, hill: '#191329', ground: '#1C1730', grass: '#120E1E', blade: '#2A2244', garland: '#0B0814', lantern_lit: '#FFB88C', lantern_glow: '#FFE3B8', lantern_dim: '#7E6698', lantern_cap: '#3B2F55', primrose: '#FFEAA7', primrose_eye: '#E8C44A', near: '#15112A', firefly: '#FFE27A', ink_field: '#FFF8F0', page: '#E9E1F5', flower_out: '#24192F' },
  motifs: [
    { id: 'lantern_garland', name: 'Girlanda fenjera', how: 'recept: line (girlanda) + row oblika lantern duž iste linije, svaki drugi fenjer upaljen (alt paleta)' },
    { id: 'tall_grass', name: 'Visoka trava sa strana', how: 'recept: poly sideGrass lijevo i desno (zupci po R2), skoro crna silueta' },
    { id: 'primrose', name: 'Noćurke u travi', how: 'recept: scatter oblika daisy u boji noćurke' }
  ],
  ambient: { id: 'fireflies', name: 'Svici lebde i trepere', n: 16, layers: [{ motion: 'float', n: 16, shape: 'firefly', size: [14, 22], pal: ['#FFF8D6'], pal2: ['#FFE27A'], zone: [6, 30, 88, 50], drift: [26, 18], sec: 5.5, alpha: [0.25, 1], pulse: 0.12, ph: [0.42, 0.28] }] },
  field: { layers: [
    { k: 'band', y0: 0, y1: 10, c: LANTERN_SKY[0] }, { k: 'band', y0: 10, y1: 20, c: LANTERN_SKY[1] }, { k: 'band', y0: 20, y1: 29, c: LANTERN_SKY[2] }, { k: 'band', y0: 29, y1: 40, c: LANTERN_SKY[3] },
    { k: 'scatter', shape: 'dot', n: 12, size: [5, 8], rot: [0, 0], phase: [0.3, 0.7, 0.2, 0], zones: [[20, 20, 60, 14]], pal: ['#CFC4F0'] },
    { k: 'ridge', r: { y: 36, w: [[1.2, 1.3, 0.6], [0.5, 3.1, 1.4]] }, c: '#191329' },
    { k: 'ridge', r: { y: 41, w: [[0.5, 1.1, 2.1]] }, c: '#1C1730' },
    { k: 'scatter', shape: 'blade', n: 26, size: [50, 90], rot: [-8, 8], phase: [0.15, 0.62, 0.8, 0.45], zones: [[8, 44, 84, 40]], pal: ['#2A2244'] },
    { k: 'scatter', shape: 'daisy', n: 14, size: [18, 26], rot: [0, 72], phase: [0.9, 0.47, 0.31, 0.2], zones: [[8, 46, 84, 36]], pal: ['#FFEAA7', '#E8C44A'] },
    { k: 'line', pts: LANTERN_GARLAND, smooth: true, c: '#0B0814', w: 5 },
    { k: 'row', shape: 'lantern', pts: LANTERN_GARLAND, x0: 26, x1: 74, step: 8, size: 70, pal: ['#FFB88C', '#FFE3B8', '#3B2F55'], alt: ['#7E6698', '#958099', '#3B2F55'] },
    { k: 'poly', pts: sideGrass(34, 100, 15, 10, 0.3), c: '#120E1E' }, { k: 'poly', pts: sideGrass(34, 100, 15, 10, 0.7, true), c: '#120E1E' },
    { k: 'ridge', r: { y: 85, w: [[0.6, 1.8, 0.4], [0.3, 4.2, 1.7]] }, c: '#15112A' },
    { k: 'scatter', shape: 'tuft', n: 14, size: [30, 46], rot: [-6, 6], phase: [0.31, 0.12, 0.6, 0.2], zones: [[2, 85.6, 96, 2]], noAvoid: true, pal: ['#221B38'] }
  ] },
  spots: STD_SPOTS,
  camp: { w: 1032, h: 318, layers: [
    { k: 'band', y0: 0, y1: 34, c: '#EEE6F7' }, { k: 'band', y0: 34, y1: 66, c: '#E6DBF3' }, { k: 'band', y0: 66, y1: 100, c: '#DDCFEE' },
    { k: 'line', pts: [[0, 3], [16, 9], [33, 11], [50, 8], [67, 11], [84, 9], [100, 3]], smooth: true, c: '#8C7AA8', w: 3 },
    { k: 'row', shape: 'lantern', pts: [[0, 3], [16, 9], [33, 11], [50, 8], [67, 11], [84, 9], [100, 3]], x0: 6, x1: 94, step: 8, size: 36, pal: ['#FFC9A0', '#FFEBD0', '#8C7AA8'], alt: ['#C9B6E6', '#E2D6F3', '#8C7AA8'] },
    { k: 'ridge', r: { y: 86, w: [[1.2, 1.6, 0.4]] }, c: '#D2C2E6' },
    { k: 'poly', pts: spikes(0, 100, 2.2, 82, 92, 100, 0.4), c: '#C6B4DE' }
  ] },
  shop: null,
  arena: { base: ['#1C1730', '#1F1934'], layers: { far_grass: ['#191329', '#1B152C'], dusk_ground: ['#1C1730', '#1F1934'], side_grass: ['#120E1E', '#120E1E'], garland: ['#0B0814', '#0B0814'] }, scatter: { blade: ['#2A2244'], lantern_dim: ['#7E6698', '#958099', '#3B2F55'], lantern_lit: ['#FFB88C', '#FFE3B8', '#3B2F55'] }, combo: { light: '#FFD08A', ring: '#FFE3B8' } },
  run: {
    ground: '#15112A', lane: '#2C2450', laneEdge: 'rgba(255,227,184,.26)', seam: 'rgba(255,227,184,.16)',
    material: { kind: 'pebble', name: 'Staza od kamenčića s mahovinom', pal: ['#463C74', '#3A3266', '#4F5A6E'], dots: [[18, 22, 9], [70, 70, 8], [42, 104, 7], [84, 28, 6], [30, 64, 5]], period: 124 },
    far: { id: 'grass_tufts', name: 'Busenje i noćurke', speed: 0.35, period: 720, items: [{ shape: 'tuft', pal: ['#241D3E'], at: [[120, 80, 70], [960, 300, 80], [60, 520, 64], [1010, 640, 70]] }, { shape: 'daisy', pal: ['#E8D48F', '#C9A84A'], at: [[150, 200, 22], [980, 120, 20], [40, 420, 22], [1040, 560, 20]] }] },
    near: { id: 'lantern_posts', name: 'Fenjeri na stubovima uz rub', speed: 1, period: 480, items: [{ shape: 'post', pal: ['#3B2F55', '#2A2142'], at: [[60, 240, 110], [1020, 480, 110]] }, { shape: 'lantern', pal: ['#FFB88C', '#FFE3B8', '#3B2F55'], at: [[60, 132, 64], [1020, 372, 64]] }, { shape: 'blade', pal: ['#2E2650'], at: [[30, 60, 80], [140, 300, 70], [960, 120, 76], [1050, 330, 80]] }] },
    ambient: { id: 'fireflies', n: 12, layers: [{ motion: 'float', n: 12, shape: 'firefly', size: [16, 22], pal: ['#FFF8D6'], pal2: ['#FFE27A'], zone: [2, 4, 96, 80], drift: [30, 24], sec: 4.5, alpha: [0.3, 1], pulse: 0.12, ph: [0.2, 0.6] }] },
    collar: ['#4A3E72', '#6E5F9C'],
    obstacles: [{ id: 'lantern_post', name: 'Stub s fenjerom', svg: 'assets/seasons/lantern_meadow/obstacle_lantern_post.svg' }, { id: 'mossy_stone', name: 'Kamen s mahovinom', svg: 'assets/seasons/lantern_meadow/obstacle_mossy_stone.svg' }]
  }
};

// ── Amber Canopy (svijetla, sunčana krošnja) ──
KITS.amber_canopy = {
  id: 'amber_canopy', name: 'Amber Canopy', kind: 'free', order: 4, phase: 2,
  place: 'Šumsko tlo pod visokom krošnjom: lišće visi odozgo, dva tamna debla sa strane, snopovi svjetla i mrlje sunca na tlu.',
  palette: { canopy: '#F2C46A', canopy_back: '#E8AE58', beam: '#FBF0D6', floor: ['#F7E8C9', '#F3DFB8', '#EED6A8'], trunk: '#3A2614', dapple: '#FCF1D9', leaf: '#E07B39', leaf2: '#F0A04B', acorn: '#B07A44', mushroom: '#E8805A', near: '#EACB97', ink_field: '#1A1A14', page: '#FBF1DE', flower_out: '#3F2716' },
  motifs: [
    { id: 'canopy', name: 'Krošnja odozgo', how: 'recept: dva cik-cak poligona prema gore + row oblika leaf koji visi s ruba (samo između gornjih kontrola)' },
    { id: 'twin_trunks', name: 'Dva debla sa strane', how: 'recept: poly lijevo i desno, skoro crno (≤ 0,036 L) — smije ispod kontrola' },
    { id: 'light_beams', name: 'Snopovi svjetla i mrlje sunca', how: 'recept: 3 kosa poligona svjetlije boje + scatter dapple' }
  ],
  ambient: { id: 'leaves', name: 'Lišće pada, prašina lebdi u snopu', n: 20, layers: [
    { motion: 'fall', n: 12, shape: 'leaf', size: [22, 32], pal: ['#E07B39', '#F0A04B', '#C9602A'], pal2: ['#8E4A1E'], zone: [6, 8, 88, 40], drift: [60, 620], sway: [30, 1.2], sec: 11, rot: 300, alpha: [0, 1], fade: 0.1, ph: [0.58, 0.36] },
    { motion: 'float', n: 8, shape: 'dot', size: [6, 10], pal: ['#FFF8E6'], zone: [16, 22, 60, 36], drift: [20, 30], sec: 7, alpha: [0.2, 0.9], ph: [0.1, 0.5] }
  ] },
  field: { layers: [
    { k: 'band', y0: 0, y1: 40, c: '#F7E8C9' }, { k: 'band', y0: 40, y1: 70, c: '#F3DFB8' }, { k: 'band', y0: 70, y1: 100, c: '#EED6A8' },
    { k: 'poly', pts: [[20, 10], [27, 10], [14, 72], [5, 72]], c: '#FBF0D6' }, { k: 'poly', pts: [[56, 11], [62, 11], [48, 76], [40, 76]], c: '#FBF0D6' }, { k: 'poly', pts: [[82, 10], [88, 10], [76, 68], [68, 68]], c: '#FBF0D6' },
    { k: 'scatter', shape: 'dapple', n: 10, size: [100, 170], rot: [0, 0], phase: [0.33, 0.12, 0.7, 0], zones: [[8, 40, 84, 44]], pal: ['#FCF1D9'] },
    { k: 'scatter', shape: 'leaf', n: 20, size: [26, 38], rot: [0, 360], phase: [0.58, 0.36, 0.14, 0.9], zones: [[7, 42, 86, 42]], pal: ['#E0904E', '#A9652F'] },
    { k: 'scatter', shape: 'acorn', n: 6, size: [20, 26], rot: [-25, 25], phase: [0.08, 0.77, 0.5, 0.25], zones: [[8, 44, 84, 40]], pal: ['#B07A44', '#6E4A28'] },
    { k: 'scatter', shape: 'mushroom', n: 5, size: [30, 42], rot: [0, 0], phase: [0.72, 0.55, 0.3, 0], zones: [[8, 46, 84, 38]], pal: ['#E8805A', '#FFF1DC'] },
    { k: 'poly', pts: [[0, 0], [2, 0], [2, 25.5], [4.8, 30], [5.6, 52], [4.6, 72], [2, 76.5], [2, 100], [0, 100]], c: '#3A2614' }, { k: 'poly', pts: [[100, 0], [98, 0], [98, 13.5], [95, 20], [94.4, 48], [95.6, 72], [98, 76.5], [98, 100], [100, 100]], c: '#3A2614' },
    { k: 'ridge', up: true, r: { y: 13, w: [[1.2, 6.5, 0.4], [0.5, 13, 1.1]] }, c: '#E8AE58' },
    { k: 'ridge', up: true, r: { y: 8.4, w: [[1.4, 7.5, 1.4], [0.5, 15, 0.2]] }, c: '#F2C46A' },
    { k: 'row', shape: 'leaf', r: { y: 9.6, w: [[1.4, 7.5, 1.4], [0.5, 15, 0.2]] }, x0: 22, x1: 78, step: 5, size: 34, vary: 0.3, pal: ['#F5B05C', '#F2C46A'], alt: ['#F7BE6E', '#F2C46A'] },
    { k: 'ridge', r: { y: 86, w: [[0.6, 1.8, 0.4], [0.3, 4.2, 1.7]] }, c: '#EACB97' },
    { k: 'scatter', shape: 'leaf', n: 10, size: [24, 32], rot: [0, 360], phase: [0.2, 0.8, 0.4, 0.6], zones: [[6, 86.4, 72, 2]], noAvoid: true, pal: ['#D98C4A', '#A9652F'] }
  ] },
  spots: STD_SPOTS,
  camp: { w: 1032, h: 318, layers: [
    { k: 'band', y0: 0, y1: 40, c: '#FBEFD6' }, { k: 'band', y0: 40, y1: 72, c: '#F7E6C4' }, { k: 'band', y0: 72, y1: 100, c: '#F2DDB4' },
    { k: 'poly', pts: [[30, 0], [36, 0], [26, 100], [18, 100]], c: '#FDF5E2' }, { k: 'poly', pts: [[72, 0], [77, 0], [68, 100], [61, 100]], c: '#FDF5E2' },
    { k: 'ridge', up: true, r: { y: 7, w: [[1.6, 9, 0.4], [0.8, 17, 1.2]] }, c: '#F2C46A' },
    { k: 'row', shape: 'leaf', r: { y: 8.6, w: [[1.6, 9, 0.4], [0.8, 17, 1.2]] }, x0: 4, x1: 96, step: 4.6, size: 30, vary: 0.3, pal: ['#F0A04B', '#E6AE55'], alt: ['#F5B964', '#E6AE55'] },
    { k: 'poly', pts: [[0, 0], [1.6, 0], [2, 100], [0, 100]], c: '#3A2614' }, { k: 'poly', pts: [[100, 0], [98.4, 0], [98, 100], [100, 100]], c: '#3A2614' }
  ] },
  shop: null,
  arena: { base: ['#F3DFB8', '#F5E3BE'], layers: { light_beams: ['#FBF0D6', '#FCF3DE'], trunks: ['#3A2614', '#3A2614'], canopy_back: ['#E8AE58', '#EBB35E'], canopy_front: ['#F2C46A', '#F4C970'] }, scatter: { dapple: ['#FCF1D9'] }, combo: { light: '#FFD56B', ring: '#FFEBC7' } },
  run: {
    ground: '#7A5434', lane: '#4A3220', laneEdge: 'rgba(255,235,199,.28)', seam: 'rgba(255,235,199,.16)',
    material: { kind: 'pebble', name: 'Staza prekrivena lišćem', pal: ['#8E5A30', '#A46A36', '#6E4524'], dots: [[20, 20, 10], [72, 62, 9], [46, 100, 8], [86, 18, 7], [30, 76, 6]], period: 124 },
    far: { id: 'dapple', name: 'Mrlje sunca', speed: 0.35, period: 720, items: [{ shape: 'dapple', pal: ['#8E6440'], at: [[130, 80, 200], [960, 300, 220], [70, 520, 180], [1000, 660, 200]] }] },
    near: { id: 'trunks_edge', name: 'Debla i gljive uz rub', speed: 1, period: 480, items: [{ shape: 'trunk', pal: ['#3A2614', '#2A1A0C'], at: [[40, 470, 420], [1044, 240, 420]] }, { shape: 'mushroom', pal: ['#E8805A', '#FFF1DC'], at: [[120, 300, 50], [960, 90, 46]] }, { shape: 'leaf', pal: ['#E0904E', '#A9652F'], at: [[150, 130, 34, 40], [60, 380, 30, 200], [930, 330, 34, 120], [1030, 420, 30, 300]] }] },
    ambient: { id: 'leaves', n: 12, layers: [{ motion: 'fall', n: 12, shape: 'leaf', size: [24, 34], pal: ['#E07B39', '#F0A04B', '#C9602A'], pal2: ['#8E4A1E'], zone: [2, 0, 96, 40], drift: [80, 1000], sway: [34, 1.4], sec: 7, rot: 320, alpha: [0, 1], fade: 0.08, ph: [0.4, 0.2] }] },
    collar: ['#9C6A3E', '#6E4524'],
    obstacles: [{ id: 'fallen_log', name: 'Srušeno deblo', svg: 'assets/seasons/amber_canopy/obstacle_fallen_log.svg' }, { id: 'mushroom_stump', name: 'Panj s gljivama', svg: 'assets/seasons/amber_canopy/obstacle_mushroom_stump.svg' }]
  }
};

// ── Coral Tide Garden (svijetla, plaćena) ──
const CORAL_TILT = -12;
KITS.coral_tide = {
  id: 'coral_tide', name: 'Coral Tide Garden', kind: 'paid', order: -2, phase: 2,
  place: 'Plićak i pijesak: obala dijagonalno preko polja, voda gore, pjena, mokar i suh pijesak dolje, školjke i koralj na rubu plime.',
  palette: { water: '#CDEEF2', shallows: '#93D7D4', ripple: '#E6F7F8', foam: '#F4FAF6', wet_sand: '#E8C2A6', dry_sand: '#F2D6BC', near: '#F5DEC8', shell: '#FFF1E8', shell2: '#FFCCD5', starfish: '#F29B80', coral: '#F59A8B', thrift: '#FFB3C1', ink_field: '#1A1A14', page: '#EAF7F6', flower_out: '#2E3542' },
  motifs: [
    { id: 'diagonal_shore', name: 'Obala dijagonalno', how: 'recept: 4 grebena s istim nagibom (ridge.tilt) — plićak, pjena, mokar i suh pijesak' },
    { id: 'shells', name: 'Školjke i zvjezdače', how: 'recept: scatter shell + starfish na pijesku' },
    { id: 'coral_edge', name: 'Koralj na rubu plime', how: 'recept: row oblika coral duž ruba pjene' }
  ],
  ambient: { id: 'sea', name: 'Odsjaji na vodi trepere, mjehurići se dižu', n: 16, layers: [
    { motion: 'twinkle', n: 8, shape: 'glint', size: [28, 44], pal: ['#FFFFFF'], zone: [22, 10, 56, 18], sec: 3.6, alpha: [0, 0.95], pulse: 0.2, ph: [0.19, 0.4] },
    { motion: 'rise', n: 8, shape: 'bubble', size: [10, 16], pal: ['#FFFFFF'], zone: [24, 18, 52, 14], drift: [0, -140], sway: [8, 1], sec: 6, alpha: [0, 0.9], fade: 0.2, ph: [0.6, 0.2] }
  ] },
  field: { layers: [
    { k: 'band', y0: 0, y1: 14, c: '#CDEEF2' }, { k: 'band', y0: 14, y1: 46, c: '#C2EAEC' },
    { k: 'ridge', r: { y: 30, tilt: CORAL_TILT, w: [[0.6, 1.4, 0.4]] }, c: '#93D7D4' },
    { k: 'scatter', shape: 'ripple', n: 8, size: [60, 100], rot: [0, 0], phase: [0.19, 0.4, 0.6, 0], zones: [[20, 12, 60, 18]], pal: ['#E6F7F8'] },
    { k: 'ridge', r: { y: 42, tilt: CORAL_TILT, w: [[0.7, 2.2, 0.4], [0.35, 4.1, 1.2]] }, c: '#F4FAF6' },
    { k: 'ridge', r: { y: 43.4, tilt: CORAL_TILT, w: [[0.7, 2.2, 0.4], [0.35, 4.1, 1.2]] }, c: '#E8C2A6' },
    { k: 'row', shape: 'coral', r: { y: 43.2, tilt: CORAL_TILT, w: [[0.7, 2.2, 0.4], [0.35, 4.1, 1.2]] }, x0: 24, x1: 76, step: 13, size: 58, vary: 0.3, pal: ['#F59A8B', '#FFC5B8'] },
    { k: 'ridge', r: { y: 50, tilt: CORAL_TILT * 0.8, w: [[0.5, 1.6, 2.2]] }, c: '#F2D6BC' },
    { k: 'scatter', shape: 'pebble', n: 7, size: [16, 30], rot: [0, 0], phase: [0.7, 0.2, 0.45, 0], zones: [[4, 54, 92, 32]], pal: ['#E3BFA4'] },
    { k: 'scatter', shape: 'shell', n: 10, size: [30, 44], rot: [-30, 30], phase: [0.36, 0.81, 0.27, 0.6], zones: [[4, 54, 92, 32]], pal: ['#FFF1E8', '#E9C2AE'] },
    { k: 'scatter', shape: 'starfish', n: 4, size: [34, 46], rot: [0, 72], phase: [0.93, 0.52, 0.15, 0.37], zones: [[6, 56, 88, 28]], pal: ['#F29B80', '#FFD0BE'] },
    { k: 'scatter', shape: 'thrift', n: 9, size: [30, 40], rot: [-8, 8], phase: [0.11, 0.29, 0.73, 0.2], zones: [[4, 56, 92, 30]], pal: ['#FFB3C1', '#7FA46E', '#FFE0E6'] },
    { k: 'ridge', r: { y: 86, w: [[0.6, 1.8, 0.4], [0.3, 4.2, 1.7]] }, c: '#F5DEC8' }
  ] },
  spots: STD_SPOTS,
  camp: null,
  shop: { w: 1032, h: 364, layers: [
    { k: 'band', y0: 0, y1: 30, c: '#CDEEF2' }, { k: 'band', y0: 30, y1: 70, c: '#C2EAEC' },
    { k: 'ridge', r: { y: 30, tilt: -16, w: [[0.8, 1.4, 0.4]] }, c: '#93D7D4' },
    { k: 'shape', shape: 'ripple', at: [[30, 18, 90], [62, 12, 70], [84, 22, 80]], pal: ['#E6F7F8'] },
    { k: 'ridge', r: { y: 52, tilt: -16, w: [[1.2, 2.2, 0.4], [0.6, 4.1, 1.2]] }, c: '#F4FAF6' },
    { k: 'ridge', r: { y: 55, tilt: -16, w: [[1.2, 2.2, 0.4], [0.6, 4.1, 1.2]] }, c: '#E8C2A6' },
    { k: 'ridge', r: { y: 66, tilt: -12, w: [[0.8, 1.6, 2.2]] }, c: '#F2D6BC' },
    { k: 'shape', shape: 'shell', at: [[52, 92, 40, -20], [96, 80, 34, 20]], pal: ['#FFF1E8', '#E9C2AE'] },
    { k: 'shape', shape: 'starfish', at: [[57, 78, 38, 18]], pal: ['#F29B80', '#FFD0BE'] }
  ] },
  arena: { base: ['#93D7D4', '#97DAD7'], layers: { shallows: ['#CDEEF2', '#D1F0F4'], wet_sand: ['#E8C2A6', '#EAC6AA'], dry_sand: ['#F2D6BC', '#F4D9C0'] }, scatter: { ripple: ['#E6F7F8'], pebble: ['#E3BFA4'] }, combo: { light: '#FFCCD5', ring: '#FFFFFF' } },
  run: {
    ground: '#E8C9A8', lane: '#3B6F78', laneEdge: 'rgba(255,255,255,.40)', seam: 'rgba(255,255,255,.22)',
    material: { kind: 'plank', name: 'Daščana staza preko plićaka', fill: '#4A7F88', seam: '#2C5A62', knot: '#3B6F78', plank: 54, gap: 8, period: 124 },
    far: { id: 'tide_pools', name: 'Plimne lokve i školjke', speed: 0.35, period: 720, items: [{ shape: 'puddle', pal: ['#B4E5E6', '#F4FAF6'], at: [[120, 120, 170], [970, 340, 150], [60, 560, 140]] }, { shape: 'shell', pal: ['#FFF1E8', '#E9C2AE'], at: [[170, 300, 40, 20], [1020, 120, 36, -20], [930, 600, 40, 10]] }] },
    near: { id: 'coral_edge', name: 'Koralj i karanfili uz rub', speed: 1, period: 480, items: [{ shape: 'coral', pal: ['#F59A8B', '#FFC5B8'], at: [[60, 220, 120], [1020, 440, 120]] }, { shape: 'thrift', pal: ['#FFB3C1', '#7FA46E', '#FFE0E6'], at: [[140, 90, 46], [30, 380, 42], [950, 150, 46], [1050, 300, 42]] }, { shape: 'starfish', pal: ['#F29B80', '#FFD0BE'], at: [[150, 420, 44, 20]] }] },
    ambient: { id: 'foam', n: 10, layers: [{ motion: 'rise', n: 10, shape: 'bubble', size: [14, 22], pal: ['#FFFFFF'], zone: [2, 20, 96, 76], drift: [0, -300], sway: [12, 1], sec: 5, alpha: [0, 0.85], fade: 0.2, ph: [0.4, 0.2] }] },
    collar: ['#E0BC9A', '#B8916E'],
    obstacles: [{ id: 'shell_rock', name: 'Stijena sa školjkama', svg: 'assets/seasons/coral_tide/obstacle_shell_rock.svg' }, { id: 'coral_branch', name: 'Koralj', svg: 'assets/seasons/coral_tide/obstacle_coral_branch.svg' }]
  }
};

// ── Starfall Glade (tamna, plaćena) ──
const STAR_SKY = ['#0C0A1F', '#100D26', '#14102D', '#191434'];
const STAR_SIDE = [[0, 30], [7, 36], [3, 37], [9, 46], [4, 47], [10, 57], [4, 58], [9, 68], [0, 73]];
KITS.starfall_glade = {
  id: 'starfall_glade', name: 'Starfall Glade', kind: 'paid', order: -3, phase: 2,
  place: 'Proplanak u šumi jela: jele u prstenu oko čistine, nebo puno zvijezda, meteori preko neba.',
  palette: { sky: STAR_SKY, fir: '#0B0919', ground: '#1E1840', clearing: '#261F4C', fern: '#342C5C', star: '#FFF2BF', star2: '#E9E0FF', meteor: '#FFF2BF', near: '#171233', ink_field: '#FFF8F0', page: '#E6E0FA', flower_out: '#1C1534' },
  motifs: [
    { id: 'fir_ring', name: 'Prsten jela', how: 'recept: poly spikes (jele u pozadini) + dva bočna poligona jela (ogledalo)' },
    { id: 'star_sky', name: 'Zvjezdano nebo i meteori', how: 'recept: scatter dot + sparkle na nebu, shape meteor (statični) — ambijent dodaje padajuće' },
    { id: 'clearing', name: 'Čistina', how: 'recept: ellipse svjetlijeg tla + scatter fern i zvjezdane latice' }
  ],
  ambient: { id: 'starfall', name: 'Zvijezde trepere, meteori prelijeću, latice padaju', n: 22, layers: [
    { motion: 'twinkle', n: 12, shape: 'sparkle', size: [12, 22], pal: ['#FFF2BF', '#E9E0FF'], zone: [22, 13, 56, 12], sec: 3.8, alpha: [0.15, 1], pulse: 0.25, ph: [0.66, 0.13] },
    { motion: 'streak', n: 2, shape: 'meteor', size: [120, 150], pal: ['#FFF2BF'], pal2: ['#FFF2BF'], zone: [40, 12, 40, 6], drift: [-420, 240], angle: [150, 150], duty: 0.22, sec: 7, alpha: [0, 1], ph: [0.2, 0.5] },
    { motion: 'fall', n: 8, shape: 'sparkle', size: [12, 18], pal: ['#D9CCFF'], zone: [10, 34, 80, 20], drift: [30, 380], sway: [16, 1.2], sec: 9, rot: 180, alpha: [0, 0.9], fade: 0.12, ph: [0.81, 0.36] }
  ] },
  field: { layers: [
    { k: 'band', y0: 0, y1: 8, c: STAR_SKY[0] }, { k: 'band', y0: 8, y1: 16, c: STAR_SKY[1] }, { k: 'band', y0: 16, y1: 24, c: STAR_SKY[2] }, { k: 'band', y0: 24, y1: 34, c: STAR_SKY[3] },
    { k: 'scatter', shape: 'dot', n: 20, size: [5, 9], rot: [0, 0], phase: [0.3, 0.7, 0.2, 0], zones: [[20, 12, 60, 18], [2, 26, 18, 6], [80, 26, 18, 6]], pal: ['#E9E0FF'] },
    { k: 'shape', shape: 'meteor', at: [[64, 16, 150, 150]], pal: ['#FFF2BF', '#B8A8F0'] },
    { k: 'poly', pts: spikes(0, 100, 5, 22, 31, 40, 2.0), c: '#0B0919' },
    { k: 'ridge', r: { y: 35, w: [[0.4, 1.2, 0.4]] }, c: '#1E1840' },
    { k: 'ellipse', at: [50, 64], r: [40, 22], c: '#261F4C' },
    { k: 'scatter', shape: 'fern', n: 12, size: [40, 60], rot: [-8, 8], phase: [0.57, 0.91, 0.62, 0], zones: [[4, 40, 92, 44]], pal: ['#342C5C'] },
    { k: 'scatter', shape: 'sparkle', n: 14, size: [12, 18], rot: [0, 45], phase: [0.81, 0.36, 0.09, 0.2], zones: [[10, 44, 80, 38]], pal: ['#D9CCFF'] },
    { k: 'poly', pts: STAR_SIDE, c: '#0B0919' }, { k: 'poly', pts: STAR_SIDE.map(p => [100 - p[0], p[1]]), c: '#0B0919' },
    { k: 'ridge', r: { y: 86, w: [[0.6, 1.8, 0.4], [0.3, 4.2, 1.7]] }, c: '#171233' },
    { k: 'scatter', shape: 'fern', n: 10, size: [40, 56], rot: [-8, 8], phase: [0.2, 0.4, 0.6, 0], zones: [[2, 86.8, 96, 2]], noAvoid: true, pal: ['#221C42'] }
  ] },
  spots: STD_SPOTS,
  camp: null,
  shop: { w: 1032, h: 364, layers: [
    { k: 'band', y0: 0, y1: 25, c: STAR_SKY[0] }, { k: 'band', y0: 25, y1: 50, c: STAR_SKY[1] }, { k: 'band', y0: 50, y1: 72, c: STAR_SKY[2] }, { k: 'band', y0: 72, y1: 100, c: STAR_SKY[3] },
    { k: 'scatter', shape: 'dot', n: 26, size: [4, 7], rot: [0, 0], phase: [0.3, 0.7, 0.2, 0], zones: [[1, 3, 98, 54]], pal: ['#E9E0FF'] },
    { k: 'shape', shape: 'sparkle', at: [[60, 60, 26], [74, 52, 18], [92, 64, 22], [52, 10, 16]], pal: ['#FFF2BF'] },
    { k: 'shape', shape: 'meteor', at: [[70, 22, 150, 150]], pal: ['#FFF2BF', '#B8A8F0'] },
    { k: 'poly', pts: spikes(0, 100, 4, 70, 84, 100, 1.2), c: '#0B0919' }
  ] },
  arena: { base: ['#14102D', '#161131'], layers: { firs_back: ['#0B0919', '#0B0919'], glade_ground: ['#1E1840', '#201A44'], firs_sides: ['#0B0919', '#0B0919'], clearing: ['#261F4C', '#282150'] }, combo: { light: '#DBCCFF', ring: '#FFF2BF' } },
  run: {
    ground: '#100D26', lane: '#2A2456', laneEdge: 'rgba(233,224,255,.26)', seam: 'rgba(233,224,255,.16)',
    material: { kind: 'pebble', name: 'Staza od zvjezdane prašine', pal: ['#4A4288', '#E9E0FF', '#3D366E'], dots: [[16, 24, 7], [70, 70, 4], [44, 100, 6], [86, 30, 3], [30, 80, 5]], period: 124 },
    far: { id: 'ferns', name: 'Paprat i zvjezdane latice', speed: 0.35, period: 720, items: [{ shape: 'fern', pal: ['#241E48'], at: [[120, 160, 90], [960, 380, 100], [60, 600, 80]] }, { shape: 'sparkle', pal: ['#8E84C8'], at: [[160, 320, 18], [1000, 120, 16], [920, 620, 18]] }] },
    near: { id: 'firs_edge', name: 'Jele uz rub', speed: 1, period: 480, items: [{ shape: 'fir', pal: ['#0B0919', '#1A1436'], at: [[56, 300, 260], [1024, 470, 260]] }, { shape: 'fern', pal: ['#2E2754'], at: [[150, 120, 60], [940, 210, 60]] }] },
    ambient: { id: 'starfall', n: 12, layers: [{ motion: 'twinkle', n: 10, shape: 'sparkle', size: [12, 20], pal: ['#FFF2BF', '#E9E0FF'], zone: [2, 2, 96, 86], sec: 3.2, alpha: [0.1, 1], pulse: 0.25, ph: [0.2, 0.6] }, { motion: 'streak', n: 2, shape: 'meteor', size: [140, 160], pal: ['#FFF2BF'], pal2: ['#FFF2BF'], zone: [30, 4, 50, 10], drift: [-500, 300], angle: [150, 150], duty: 0.2, sec: 6, alpha: [0, 1], ph: [0.5, 0.3] }] },
    collar: ['#3D366E', '#5E569C'],
    obstacles: [{ id: 'meteorite', name: 'Meteorit', svg: 'assets/seasons/starfall_glade/obstacle_meteorite.svg' }, { id: 'fir_stump', name: 'Panj jele', svg: 'assets/seasons/starfall_glade/obstacle_fir_stump.svg' }]
  }
};

// ── Ember Fen (tamna, plaćena, uskoro) ──
const EMBER_SKY = ['#160B08', '#1C0F0B', '#22120D', '#2A1610'];
KITS.ember_fen = {
  id: 'ember_fen', name: 'Ember Fen', kind: 'paid', order: -4, phase: 2, soon: true,
  place: 'Močvara u sumrak vatre: tresetno tlo, tamne lokve, rogoz uz rubove, dva pojasa dima, žeravica se diže.',
  palette: { sky: EMBER_SKY, reeds: '#120806', peat: '#24130E', pool: '#120808', pool_glint: '#C8643A', smoke: '#3A221C', cattail: '#8A5536', ember: '#FFB074', near: '#1A0D09', ink_field: '#FFF8F0', page: '#F7E4D8', flower_out: '#2A140E' },
  motifs: [
    { id: 'pools', name: 'Lokve s odsjajem vatre', how: 'recept: tri glatka poligona (smooth) + puddle odsjaj' },
    { id: 'cattails', name: 'Rogoz uz rubove', how: 'recept: scatter cattail u dvije bočne zone + daleki rogoz kao spikes' },
    { id: 'smoke_bands', name: 'Dva pojasa dima', how: 'recept: dva glatka pojasa tamnije-svijetle boje (bez alpha, bez blura)' }
  ],
  ambient: { id: 'embers', name: 'Žeravica se diže, dim klizi', n: 18, layers: [
    { motion: 'rise', n: 14, shape: 'ember', size: [10, 16], pal: ['#FFB074', '#FFD3A8'], pal2: ['#FFE0B8'], zone: [8, 50, 84, 34], drift: [30, -460], sway: [14, 1], sec: 7, rot: 90, alpha: [0, 1], fade: 0.15, ph: [0.14, 0.73] },
    { motion: 'drift', n: 4, shape: 'smoke', size: [140, 200], pal: ['#3A221C'], zone: [0, 24, 70, 40], drift: [220, 0], sec: 18, alpha: [0, 0.8], fade: 0.3, ph: [0.3, 0.6] }
  ] },
  field: { layers: [
    { k: 'band', y0: 0, y1: 6, c: EMBER_SKY[0] }, { k: 'band', y0: 6, y1: 12, c: EMBER_SKY[1] }, { k: 'band', y0: 12, y1: 18, c: EMBER_SKY[2] }, { k: 'band', y0: 18, y1: 24, c: EMBER_SKY[3] },
    { k: 'poly', pts: spikes(0, 100, 2.4, 13, 19, 24, 1.8), c: '#120806' },
    { k: 'ridge', r: { y: 22, w: [[0.3, 1.4, 0.2]] }, c: '#24130E' },
    { k: 'poly', smooth: true, pts: [[0, 26.4], [20, 25], [46, 26.2], [72, 24.6], [100, 25.6], [100, 30], [74, 30.8], [46, 29.4], [20, 31], [0, 29.8]], c: '#3A221C' },
    { k: 'poly', smooth: true, pts: [[12, 44], [24, 41.6], [36, 43.6], [40, 48], [30, 51.4], [16, 50.4]], c: '#120808' },
    { k: 'poly', smooth: true, pts: [[58, 50], [72, 47.6], [86, 50.2], [88, 55.5], [74, 58.6], [60, 56.4]], c: '#120808' },
    { k: 'poly', smooth: true, pts: [[16, 70], [30, 68.4], [38, 71.6], [34, 76.8], [20, 77.2], [12, 74]], c: '#120808' },
    { k: 'shape', shape: 'puddle', at: [[26, 46.6, 100], [73, 53, 110], [25, 72.8, 90]], pal: ['#120808', '#C8643A'] },
    { k: 'poly', smooth: true, pts: [[0, 60.5], [24, 59], [52, 60.6], [78, 58.8], [100, 60], [100, 64.4], [78, 63.2], [52, 65], [24, 63.6], [0, 64.6]], c: '#3A221C' },
    { k: 'scatter', shape: 'tuft', n: 12, size: [30, 46], rot: [-6, 6], phase: [0.68, 0.2, 0.84, 0], zones: [[4, 32, 92, 50]], pal: ['#3E261C'] },
    { k: 'scatter', shape: 'cattail', n: 16, size: [80, 120], rot: [-6, 6], phase: [0.24, 0.55, 0.47, 0.3], zones: [[1, 30, 13, 52], [86, 30, 13, 40]], pal: ['#8A5536', '#2E1E1C'] },
    { k: 'scatter', shape: 'ember', n: 10, size: [10, 16], rot: [0, 0], phase: [0.14, 0.73, 0.28, 0], zones: [[4, 42, 92, 42]], pal: ['#FFB074', '#FFE0B8'] },
    { k: 'ridge', r: { y: 86, w: [[0.6, 1.8, 0.4], [0.3, 4.2, 1.7]] }, c: '#1A0D09' },
    { k: 'scatter', shape: 'cattail', n: 8, size: [70, 96], rot: [-6, 6], phase: [0.2, 0.4, 0.6, 0], zones: [[2, 87, 96, 2]], noAvoid: true, pal: ['#4A2E22', '#24130E'] }
  ] },
  spots: STD_SPOTS,
  camp: null,
  shop: { w: 1032, h: 364, layers: [
    { k: 'band', y0: 0, y1: 25, c: EMBER_SKY[0] }, { k: 'band', y0: 25, y1: 50, c: EMBER_SKY[1] }, { k: 'band', y0: 50, y1: 100, c: EMBER_SKY[2] },
    { k: 'poly', smooth: true, pts: [[0, 40], [30, 37], [60, 41], [100, 38], [100, 46], [60, 49], [30, 45], [0, 48]], c: '#3A221C' },
    { k: 'poly', pts: spikes(0, 100, 2.2, 56, 68, 100, 1.4), c: '#120806' },
    { k: 'ridge', r: { y: 78, w: [[0.6, 1.4, 0.2]] }, c: '#24130E' },
    { k: 'shape', shape: 'cattail', at: [[56, 100, 120], [60, 100, 96], [94, 100, 110]], pal: ['#8A5536', '#2E1E1C'] },
    { k: 'shape', shape: 'ember', at: [[40, 20, 14], [66, 30, 12], [82, 14, 14], [30, 54, 10]], pal: ['#FFB074', '#FFE0B8'] }
  ] },
  arena: { base: ['#1C0F0B', '#200F0C'], layers: { far_reeds: ['#120806', '#120806'], peat: ['#24130E', '#26140F'], pools: ['#120808', '#140909'], smoke: ['#3A221C', '#3A221C'] }, scatter: { pool_glint: ['#C8643A'], peat_tuft: ['#3E261C'] }, combo: { light: '#FFB88C', ring: '#FFC79E' } },
  run: {
    ground: '#1C0F0B', lane: '#3E2A22', laneEdge: 'rgba(255,199,158,.26)', seam: 'rgba(255,199,158,.16)',
    material: { kind: 'plank', name: 'Daščana staza preko močvare', fill: '#4E362A', seam: '#2A1A14', knot: '#2E1E18', plank: 52, gap: 10, period: 124 },
    far: { id: 'pools', name: 'Lokve s odsjajem', speed: 0.35, period: 720, items: [{ shape: 'puddle', pal: ['#120808', '#A8542E'], at: [[120, 140, 180], [960, 380, 170], [70, 600, 150]] }] },
    near: { id: 'cattail_edge', name: 'Rogoz uz rub', speed: 1, period: 480, items: [{ shape: 'cattail', pal: ['#8A5536', '#2E1E1C'], at: [[40, 200, 170], [110, 260, 130], [1030, 420, 170], [960, 460, 130]] }, { shape: 'tuft', pal: ['#3E261C'], at: [[150, 60, 46], [920, 200, 44]] }] },
    ambient: { id: 'embers', n: 14, layers: [{ motion: 'rise', n: 14, shape: 'ember', size: [12, 18], pal: ['#FFB074', '#FFD3A8'], pal2: ['#FFE0B8'], zone: [2, 40, 96, 56], drift: [30, -700], sway: [18, 1], sec: 5, rot: 90, alpha: [0, 1], fade: 0.15, ph: [0.4, 0.2] }] },
    collar: ['#5A3E30', '#7E5844'],
    obstacles: [{ id: 'smoldering_stump', name: 'Panj koji tinja', svg: 'assets/seasons/ember_fen/obstacle_smoldering_stump.svg' }, { id: 'rush_tussock', name: 'Busen rogoza u blatu', svg: 'assets/seasons/ember_fen/obstacle_rush_tussock.svg' }]
  }
};
// Arena: ključevi slojeva koji ne postoje u Arena v2 receptu se ignorišu (Lantern: Arena v2 recept ostaje izvor mjesta)
