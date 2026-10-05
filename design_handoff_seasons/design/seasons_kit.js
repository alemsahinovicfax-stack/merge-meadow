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
export function ridgeY(r, x) { let y = r.y; for (const [a, f, p] of r.w || []) y += a * Math.sin(2 * Math.PI * f * x / 100 + p); return y; }
function ridgePts(r, step = 2.5) { const pts = []; for (let x = -2; x <= 102.01; x += step) pts.push([r2(x), r2(ridgeY(r, x))]); return pts; }

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
        { k: 'band', y0: 0, y1: 24, c: MW_SKY[0] }, { k: 'band', y0: 24, y1: 46, c: MW_SKY[1] }, { k: 'band', y0: 46, y1: 64, c: MW_SKY[2] }, { k: 'band', y0: 64, y1: 101, c: MW_SKY[3] },
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
// Keepout kontrola polja (v2) u % stranice — rasuti elementi tu ne crtaju centar (mirne zone)
export const FIELD_AVOID = [[0.7, 0.5, 19.6, 25], [79.6, 0.5, 19.6, 13], [19.6, 1.2, 60.7, 11.3], [5, 88.5, 90, 11.5]];
// rect = {w, h}: slojevi u % recta, oblici uniformno k = w / baseW. Isti poziv za polje, karticu (minijatura) i prelaz.
export function buildScene(recipe, w, h, baseW = W, avoid = FIELD_AVOID) {
  const k = w / baseW, X = x => x * w / 100, Y = y => y * h / 100;
  const groups = [], byKey = new Map();
  const push = (key, mk, d) => { let g = byKey.get(key); if (!g) { g = mk(); byKey.set(key, g); groups.push(g); } g.d += d; };
  const fillD = (c, d) => push('f|' + c + '|' + groups.length, () => ({ d: '', f: c, s: 'none', sw: '0' }), d);
  const prims = (shape, pal, T) => { for (const p of SHAPES[shape]) { const ci = p[p.length - 1], col = pal[Math.min(ci, pal.length - 1)], a = primAbs(p, T); if (!a) continue; if (a.fill) push('F|' + col, () => ({ d: '', f: col, s: 'none', sw: '0' }), a.d); else { const sw = String(Math.round(a.w * 2) / 2); push('S|' + col + '|' + sw, () => ({ d: '', f: 'none', s: col, sw }), a.d); } } };
  const flush = () => byKey.clear(); // novi sloj = nova grupa (redoslijed crtanja)
  for (const L of recipe.layers) {
    flush();
    if (L.k === 'band') fillD(L.c, 'M0,' + f2(Y(L.y0)) + 'H' + f2(w) + 'V' + f2(Y(Math.min(101, L.y1 + 0.6))) + 'H0Z'); // preklop: bez AA šava
    else if (L.k === 'ridge') {
      const pts = ridgePts(L.r);
      fillD(L.c, 'M' + pts.map(q => f2(X(q[0])) + ',' + f2(Y(q[1]))).join('L') + 'L' + f2(X(102)) + ',' + f2(Y(101)) + 'L' + f2(X(-2)) + ',' + f2(Y(101)) + 'Z');
      if (L.rim) groups.push({ d: 'M' + pts.map(q => f2(X(q[0])) + ',' + f2(Y(q[1]))).join('L'), f: 'none', s: L.rim[0], sw: String(L.rim[1] * k) });
    } else if (L.k === 'mow') {
      for (let i = 0; i < L.ys.length; i++) {
        const t = i / (L.ys.length - 1), y0 = L.ys[i], y1 = i + 1 < L.ys.length ? L.ys[i + 1] : 101;
        const r0 = { y: y0, w: L.r.w.map(([a, f, p]) => [a * (1 - t * (1 - L.flat)), f, p]) };
        const pts = ridgePts(r0);
        const col = i === L.ys.length - 1 ? L.last : L.c[i % 2];
        fillD(col, 'M' + pts.map(q => f2(X(q[0])) + ',' + f2(Y(q[1]))).join('L') + 'L' + f2(X(102)) + ',' + f2(Y(101)) + 'L' + f2(X(-2)) + ',' + f2(Y(101)) + 'Z');
        void y1;
      }
    } else if (L.k === 'fence') {
      for (const [fr0, rw] of L.rails) { const pts = ridgePts(L.r).filter(q => q[0] >= L.x0 - 0.5 && q[0] <= L.x1 + 0.5); groups.push({ d: 'M' + pts.map(q => f2(X(q[0])) + ',' + f2(Y(q[1]) + 2 * k - fr0 * L.size * k)).join('L'), f: 'none', s: L.rail, sw: String(r2(rw * k)) }); }
      flush();
      for (let x = L.x0; x <= L.x1 + 0.01; x += L.step) prims('post', L.pal, mkT(X(x), Y(ridgeY(L.r, x)) + 2 * k, 0, L.size * k));
    } else if (L.k === 'shape') prims(L.shape, L.pal, mkT(X(L.at[0]), Y(L.at[1]), 0, L.size * k));
    else if (L.k === 'scatter') {
      for (let i = 0; i < L.n; i++) { const it = scatterAt(L, i); if (avoid && avoid.some(a => inRect(it.x, it.y, a))) continue; prims(L.shape, L.pal, mkT(X(it.x), Y(it.y), it.rot, it.size * k)); }
    }
  }
  return { groups, w, h };
}

// 13 mjesta u px recta (baza cvijeta) — isti % kao SeasonField._spot_position, veličina uniformno k
export function spotRects(kit, w, h) { const k = w / W; return kit.spots.map((s, i) => { const size = s[2] * k, cx = s[0] / 100 * w, by = h - s[1] / 100 * h; return { i, cx, by, size, idx: s[3], need: s[4] }; }); }

// Ambijent: deterministički (R2), po frejmu samo pomak + alpha. Vraća čestice u % stranice.
export function ambientParticles(kit) {
  const A = kit.ambient, out = [];
  if (A.id === 'petals') for (let i = 0; i < A.n; i++) out.push({ i, x: A.zone[0] + fr(0.21 + R2.a1 * (i + 1)) * A.zone[2], y: A.zone[1] + fr(0.63 + R2.a2 * (i + 1)) * A.zone[3], size: A.size[0] + (A.size[1] - A.size[0]) * fr(R2.size * (i + 1)), col: A.pal[i % 2], delay: -fr(R2.rot * (i + 1)) * A.sec, kind: 'petal' });
  else { for (let i = 0; i < A.twinkle; i++) out.push({ i, x: A.zone[0] + fr(0.4 + R2.a1 * (i + 1)) * A.zone[2], y: A.zone[1] + fr(0.1 + R2.a2 * (i + 1)) * A.zone[3], size: 7 + 5 * fr(R2.size * (i + 1)), col: A.pal[0], delay: -fr(R2.rot * (i + 1)) * A.sec, kind: 'twinkle' }); for (let i = 0; i < A.motes; i++) out.push({ i: A.twinkle + i, x: A.moteZone[0] + fr(0.7 + R2.a1 * (i + 1)) * A.moteZone[2], y: A.moteZone[1] + fr(0.3 + R2.a2 * (i + 1)) * A.moteZone[3], size: 6 + 4 * fr(R2.size * (i + 2)), col: A.pal[1], delay: -fr(R2.rot * (i + 3)) * A.sec * 2, kind: 'mote' }); }
  return out;
}
export const BUDGET = { ambient_max: 24, loops_max: 2, flower_kb_max: 12 };
