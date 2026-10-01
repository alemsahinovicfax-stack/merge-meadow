// Wardrobe — podaci i logika za mockup. NIJE tokens fajl: stilovi su inline u .dc.html.
// CATALOG je doslovna kopija godot/cosmetics.json (Specs provjerava da su isti).
export const CATALOG = {
  "schema": 1,
  "catalog_version": 1,
  "surfaces": {
    "field": "Home",
    "season_card": "Home",
    "arena": "Arena",
    "run": "Runs",
    "run_hud": "Runs",
    "camp": "Camp",
    "journal": "Journal",
    "shop": "Shop"
  },
  "preview_kinds": {
    "companion": { "args": ["subject"], "look": ["recolor"] },
    "meadow": { "args": ["scene"], "look": ["tint"] },
    "album": { "args": [], "look": ["frame", "paper", "title_modulate"] },
    "swatch": { "args": [], "look": ["colors"] }
  },
  "slots": [
    {
      "id": "pip_skin",
      "title": "Pip",
      "icon": "res://assets/ui/wardrobe/slot_pip.svg",
      "order": 10,
      "preview": "companion",
      "preview_args": { "subject": "pip" },
      "applies_to": ["field", "season_card", "arena", "run", "run_hud", "camp", "shop"],
      "allow_default": true,
      "default_title": "Classic Pip",
      "toast": "Pip wears {title}",
      "empty_text": "Pip's looks come from the Shop."
    },
    {
      "id": "meadow_bg",
      "title": "Meadow",
      "icon": "res://assets/ui/wardrobe/slot_meadow.svg",
      "order": 20,
      "preview": "meadow",
      "preview_args": { "scene": "run" },
      "applies_to": ["run", "shop"],
      "allow_default": true,
      "default_title": "Season colors",
      "toast": "Runs use {title}",
      "empty_text": "Meadow tints come from the Shop."
    },
    {
      "id": "journal_frame",
      "title": "Album",
      "icon": "res://assets/ui/wardrobe/slot_album.svg",
      "order": 30,
      "preview": "album",
      "preview_args": {},
      "applies_to": ["journal", "shop"],
      "allow_default": true,
      "default_title": "Plain Album",
      "toast": "Your Album wears {title}",
      "empty_text": "Album frames come from the Shop."
    }
  ],
  "items": [
    {
      "id": "pip_blossom",
      "slot": "pip_skin",
      "title": "Pip Blossom",
      "description": "Soft pink accents for Pip in runs.",
      "coin_cost": 250,
      "source": "shop",
      "order": 10,
      "new_since": null,
      "look": { "recolor": { "#A8E6CF": "#FFD3DE", "#D4F5E4": "#FFF0F3", "#FFB88C": "#FF94AE" } }
    },
    {
      "id": "pip_sky",
      "slot": "pip_skin",
      "title": "Pip Sky",
      "description": "Cool blue palette for Pip.",
      "coin_cost": 200,
      "source": "shop",
      "order": 20,
      "new_since": null,
      "look": { "recolor": { "#A8E6CF": "#C2E2FA", "#D4F5E4": "#EAF5FE" } }
    },
    {
      "id": "meadow_sunset",
      "slot": "meadow_bg",
      "title": "Sunset Meadow",
      "description": "Warm golden lane background tint.",
      "coin_cost": 150,
      "source": "shop",
      "order": 10,
      "new_since": null,
      "look": { "tint": [1.08, 0.94, 0.86] }
    },
    {
      "id": "meadow_lavender",
      "slot": "meadow_bg",
      "title": "Lavender Meadow",
      "description": "Soft purple lane mood.",
      "coin_cost": 180,
      "source": "shop",
      "order": 20,
      "new_since": null,
      "look": { "tint": [0.94, 0.92, 1.06] }
    },
    {
      "id": "journal_gold",
      "slot": "journal_frame",
      "title": "Golden Album",
      "description": "Gold accents on the Bloom Album.",
      "coin_cost": 120,
      "source": "shop",
      "order": 10,
      "new_since": null,
      "look": { "frame": { "color": "#E8C44A", "width": 10, "radius": 14 }, "title_modulate": [0.8, 0.8, 0.8] }
    }
  ]
};

// ── Demo (§5.3) — SAMO podaci. Ne ulazi u katalog. ─────────────────────────
const lighten = (hex, k) => { const c = rgb(hex); return toHex(c.map(v => v + (255 - v) * k)); };
const pipSkin = (id, title, body, order, extra) => Object.assign({ id, slot: 'pip_skin', title, description: '', coin_cost: 0, source: 'shop', order, new_since: null,
  look: { recolor: { '#A8E6CF': body, '#D4F5E4': lighten(body, 0.6) } } }, extra || {});
export const DEMO = {
  slots: [
    { id: 'mochi_skin', title: 'Mochi', icon: 'res://demo/slot_mochi.svg', order: 40, preview: 'companion', preview_args: { subject: 'mochi' }, applies_to: ['camp', 'run', 'run_hud'], allow_default: true, default_title: 'Classic Mochi', toast: 'Mochi wears {title}', empty_text: "Mochi's looks come from the Shop." },
    { id: 'album_paper', title: 'Paper', icon: 'res://demo/slot_paper.svg', order: 50, preview: 'album', preview_args: {}, applies_to: ['journal'], allow_default: true, default_title: 'Cream paper', toast: 'Your Album uses {title}', empty_text: 'Album papers come from the Shop.' },
    { id: 'basket_cloth', title: 'Cloth', icon: 'res://demo/slot_cloth.svg', order: 60, preview: 'swatch', preview_args: {}, applies_to: ['arena'], allow_default: true, default_title: 'Peach cloth', toast: 'Your basket wears {title}', empty_text: 'Basket cloths come from the Shop.' },
    { id: 'gift_ribbon', title: 'Ribbon', icon: 'res://demo/slot_ribbon.svg', order: 70, preview: 'swatch', preview_args: {}, applies_to: ['field'], allow_default: true, default_title: 'Cream ribbon', toast: 'Gifts wear {title}', empty_text: 'Ribbons come from the Shop.' },
    { id: 'combo_ring', title: 'Ring', icon: 'res://demo/slot_ring.svg', order: 80, preview: 'swatch', preview_args: {}, applies_to: ['arena'], allow_default: true, default_title: 'Cream ring', toast: 'Combos ring in {title}', empty_text: 'Combo rings come from the Shop.' }
  ],
  items: [
    pipSkin('demo_pip_peach', 'Pip Peach', '#FFD9C4', 30), pipSkin('demo_pip_lilac', 'Pip Lilac', '#E9D6FF', 40),
    pipSkin('demo_pip_butter', 'Pip Butter', '#FFF1BA', 50), pipSkin('demo_pip_lime', 'Pip Lime', '#DDF3B5', 60),
    pipSkin('demo_pip_coral', 'Pip Coral', '#FFD3C9', 70), pipSkin('demo_pip_snow', 'Pip Snow', '#F2F5F8', 80),
    pipSkin('demo_pip_oat', 'Pip Oat', '#F0DFCC', 90), pipSkin('demo_pip_aqua', 'Pip Aqua', '#C6F0EC', 100),
    pipSkin('demo_pip_honey', 'Pip Honey', '#FFE3A8', 110, { new_since: 2 }),
    pipSkin('demo_pip_frost', 'Pip Frost', '#DCE6EE', 120, { source: 'season', source_ref: 'frost_orchard' }),
    { id: 'demo_mochi_cocoa', slot: 'mochi_skin', title: 'Mochi Cocoa', order: 10, source: 'shop', new_since: null, look: { recolor: { '#EBE6F0': '#F0DFCC', '#E0D6E6': '#E3CDB6' } } },
    { id: 'demo_mochi_snow', slot: 'mochi_skin', title: 'Mochi Snow', order: 20, source: 'shop', new_since: null, look: { recolor: { '#EBE6F0': '#F7F9FB', '#E0D6E6': '#E6ECF2' } } },
    { id: 'demo_paper_mint', slot: 'album_paper', title: 'Mint paper', order: 10, source: 'shop', new_since: null, look: { paper: '#E3F6EC' } },
    { id: 'demo_paper_sky', slot: 'album_paper', title: 'Sky paper', order: 20, source: 'shop', new_since: null, look: { paper: '#E6F1FC' } },
    { id: 'demo_cloth_mint', slot: 'basket_cloth', title: 'Mint cloth', order: 10, source: 'shop', new_since: null, look: { colors: ['#A8E6CF', '#7FC9AC'] } },
    { id: 'demo_cloth_lilac', slot: 'basket_cloth', title: 'Lilac cloth', order: 20, source: 'shop', new_since: null, look: { colors: ['#D4A5FF', '#AA84CC'] } },
    { id: 'demo_ribbon_gold', slot: 'gift_ribbon', title: 'Gold ribbon', order: 10, source: 'shop', new_since: null, look: { colors: ['#FFD56B', '#D6A82F'] } },
    { id: 'demo_ribbon_pink', slot: 'gift_ribbon', title: 'Pink ribbon', order: 20, source: 'shop', new_since: null, look: { colors: ['#FFCCD5', '#E89AAA'] } },
    { id: 'demo_ring_gold', slot: 'combo_ring', title: 'Gold ring', order: 10, source: 'shop', new_since: null, look: { colors: ['#FFD56B'] } }
  ],
  owned: ['demo_pip_peach', 'demo_pip_lilac', 'demo_pip_butter', 'demo_pip_lime', 'demo_pip_coral', 'demo_pip_snow', 'demo_pip_oat', 'demo_pip_aqua', 'demo_pip_honey',
    'demo_mochi_cocoa', 'demo_paper_mint', 'demo_cloth_mint', 'demo_cloth_lilac', 'demo_ribbon_gold', 'demo_ring_gold'],
  seen_version: 1
};
// N stavki u slotu Pip — za pravilo mreže (1 / 5 / 30). Samo podaci.
export function demoN(n) {
  const items = [], owned = [];
  for (let i = 0; i < n; i++) {
    const h = (i * 0.618034) % 1; const c = hsv(h, 0.2, 1);
    const id = 'n_pip_' + i; items.push(pipSkin(id, 'Pip No. ' + (i + 1), c, 10 + i)); owned.push(id);
  }
  return { slots: [], items, owned, replaceSlotItems: 'pip_skin' };
}

export const SEASONS = {
  country_bloom: { n: 'Country Bloom', g: '#E6F2DB', r: ['clover', 'daisy', 'buttercup', 'tulip', 'sunflower', 'pumpkin'] },
  frost_orchard: { n: 'Frost Orchard', g: '#D1E6FF', r: ['frost_snowdrop', 'silver_aconite', 'clover', 'daisy', 'tulip', 'sunflower'] },
  lantern_meadow: { n: 'Lantern Meadow', g: '#EBD6FF', r: ['clover', 'buttercup', 'daisy', 'tulip', 'silver_aconite', 'sunflower'] },
  amber_canopy: { n: 'Amber Canopy', g: '#FFEBC7', r: ['clover', 'daisy', 'tulip', 'buttercup', 'sunflower', 'pumpkin'] },
  moonlit_warren: { n: 'Moonlit Warren', g: '#B8BDFF', r: ['clover', 'silver_aconite', 'frost_snowdrop', 'tulip', 'daisy', 'sunflower'] },
  coral_tide: { n: 'Coral Tide', g: '#FFE0D6', r: ['daisy', 'clover', 'tulip', 'buttercup', 'sunflower', 'pumpkin'] },
  starfall_glade: { n: 'Starfall Glade', g: '#DBCCFF', r: ['silver_aconite', 'clover', 'daisy', 'tulip', 'sunflower', 'frost_snowdrop'] },
  ember_fen: { n: 'Ember Fen', g: '#FFC79E', r: ['clover', 'silver_aconite', 'buttercup', 'tulip', 'daisy', 'pumpkin'] }
};
// = SeasonTheme.bg_modulate()
export const SEASON_MOD = { country_bloom: [1, 1, 1], frost_orchard: [0.82, 0.90, 1.05], lantern_meadow: [0.92, 0.84, 1.06], amber_canopy: [1.08, 0.92, 0.78],
  moonlit_warren: [0.72, 0.74, 1.08], coral_tide: [1.06, 0.88, 0.84], starfall_glade: [0.86, 0.80, 1.12], ember_fen: [1.12, 0.78, 0.62] };

// ── Boje ───────────────────────────────────────────────────────────────────
export function rgb(h) { const s = h.replace('#', ''); return [0, 2, 4].map(i => parseInt(s.substr(i, 2), 16)); }
export function toHex(a) { return '#' + a.map(v => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, '0')).join('').toUpperCase(); }
export function hsv(h, s, v) { h = (h % 1) * 6; const i = Math.floor(h), f = h - i, p = v * (1 - s), q = v * (1 - s * f), t = v * (1 - s * (1 - f)); const m = [[v, t, p], [q, v, p], [p, v, t], [p, q, v], [t, p, v], [v, p, q]][i % 6]; return toHex(m.map(x => x * 255)); }
export function mul(hex, m) { const c = rgb(hex); return toHex(c.map((v, i) => v * m[i])); }
export function mix(a, b, t) { const A = rgb(a), B = rgb(b); return toHex(A.map((v, i) => v + (B[i] - v) * t)); }
export function lum(hex) { return rgb(hex).map(c => { c /= 255; return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4); }).reduce((s, v, i) => s + v * [0.2126, 0.7152, 0.0722][i], 0); }
export function contrast(a, b) { const x = lum(a), y = lum(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); }
// Pravilo dvostrukog ruba (Arena v2): najgori slučaj za ink + svijetlu traku.
export function dualEdge(light, ink = '#2D3436') { return Math.sqrt((lum(light) + 0.05) / (lum(ink) + 0.05)); }
export function bands(g) { const c = rgb(g); return { sky: toHex(c.map(v => v + (255 - v) * 0.30)), far: toHex(c), near: toHex(c.map(v => v * 0.93)) }; }
// = UiShop.preview_lane_colors(): UiRun × cosmetic tint × season modulate
export function runColors(tint, season) {
  const s = SEASON_MOD[season] || [1, 1, 1], t = tint || [1, 1, 1], m = [t[0] * s[0], t[1] * s[1], t[2] * s[2]];
  const LANE = '#3A5C41', CREAM = '#FFF8F0';
  return { ground: mul('#26382C', m), lane: mul(LANE, m), edge: mul(mix(LANE, CREAM, 0.20), m), mow: mul(mix(LANE, CREAM, 0.055), m), tuft: mul('#436B4A', m), petal: mul('#7FB98B', m), blob: mul(mix('#26382C', CREAM, 0.05), m), seam: mul(mix('#26382C', CREAM, 0.16), m) };
}

// ── Art: pravi pip_idle.svg + zamjena boja po mapi (isto radi PipAssets.get_texture(skin)) ──
export const PIP_SVG = "<svg width=\"256\" height=\"256\" viewBox=\"0 0 256 256\" xmlns=\"http://www.w3.org/2000/svg\" fill=\"none\">\n  <ellipse cx=\"176\" cy=\"198\" rx=\"17\" ry=\"15\" fill=\"#D4F5E4\" stroke=\"#2D3436\" stroke-width=\"3\" stroke-linejoin=\"round\"></ellipse>\n  <g transform=\"rotate(-14, 104, 104)\">\n    <ellipse cx=\"104\" cy=\"62\" rx=\"14\" ry=\"40\" fill=\"#A8E6CF\" stroke=\"#2D3436\" stroke-width=\"3\" stroke-linejoin=\"round\"></ellipse>\n    <ellipse cx=\"104\" cy=\"65\" rx=\"7\" ry=\"27\" fill=\"#D4F5E4\"></ellipse>\n  </g>\n  <g transform=\"rotate(10, 154, 104)\">\n    <ellipse cx=\"154\" cy=\"58\" rx=\"14\" ry=\"40\" fill=\"#A8E6CF\" stroke=\"#2D3436\" stroke-width=\"3\" stroke-linejoin=\"round\"></ellipse>\n    <ellipse cx=\"154\" cy=\"61\" rx=\"7\" ry=\"27\" fill=\"#D4F5E4\"></ellipse>\n  </g>\n  <ellipse cx=\"128\" cy=\"188\" rx=\"52\" ry=\"50\" fill=\"#A8E6CF\" stroke=\"#2D3436\" stroke-width=\"3\" stroke-linejoin=\"round\"></ellipse>\n  <ellipse cx=\"128\" cy=\"194\" rx=\"30\" ry=\"36\" fill=\"#D4F5E4\"></ellipse>\n  <ellipse cx=\"100\" cy=\"226\" rx=\"20\" ry=\"11\" fill=\"#A8E6CF\" stroke=\"#2D3436\" stroke-width=\"3\" stroke-linejoin=\"round\"></ellipse>\n  <ellipse cx=\"156\" cy=\"226\" rx=\"20\" ry=\"11\" fill=\"#A8E6CF\" stroke=\"#2D3436\" stroke-width=\"3\" stroke-linejoin=\"round\"></ellipse>\n  <circle cx=\"128\" cy=\"116\" r=\"46\" fill=\"#A8E6CF\" stroke=\"#2D3436\" stroke-width=\"3\"></circle>\n  <ellipse cx=\"110\" cy=\"112\" rx=\"11\" ry=\"12\" fill=\"#FFFFFF\" stroke=\"#2D3436\" stroke-width=\"2\"></ellipse>\n  <circle cx=\"111\" cy=\"113\" r=\"6.5\" fill=\"#4A4A4A\"></circle>\n  <circle cx=\"113.5\" cy=\"110\" r=\"2.5\" fill=\"#FFFFFF\"></circle>\n  <ellipse cx=\"148\" cy=\"112\" rx=\"11\" ry=\"12\" fill=\"#FFFFFF\" stroke=\"#2D3436\" stroke-width=\"2\"></ellipse>\n  <circle cx=\"149\" cy=\"113\" r=\"6.5\" fill=\"#4A4A4A\"></circle>\n  <circle cx=\"151.5\" cy=\"110\" r=\"2.5\" fill=\"#FFFFFF\"></circle>\n  <ellipse cx=\"94\" cy=\"124\" rx=\"14\" ry=\"9\" fill=\"#FFB88C\" opacity=\"0.32\"></ellipse>\n  <ellipse cx=\"164\" cy=\"124\" rx=\"14\" ry=\"9\" fill=\"#FFB88C\" opacity=\"0.32\"></ellipse>\n  <ellipse cx=\"128\" cy=\"130\" rx=\"5\" ry=\"4\" fill=\"#2D3436\"></ellipse>\n  <path d=\"M 121 135 Q 128 142 135 135\" stroke=\"#2D3436\" stroke-width=\"2.5\" stroke-linecap=\"round\" fill=\"none\"></path>\n</svg>";
// MochiDraw (mochi_draw.gd) prenesen 1:1 u SVG 256 — samo za demo slota Mochi.
export const MOCHI_SVG = '<svg width="256" height="256" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">' +
  '<circle cx="68.2" cy="45.8" r="41.4" fill="#E0D6E6"/><circle cx="187.8" cy="45.8" r="41.4" fill="#E0D6E6"/>' +
  '<circle cx="68.2" cy="45.8" r="20.7" fill="#FFC7D1"/><circle cx="187.8" cy="45.8" r="20.7" fill="#FFC7D1"/>' +
  '<circle cx="128" cy="147" r="96.6" fill="#EBE6F0" stroke="#736B85" stroke-opacity=".85" stroke-width="9.2"/>' +
  '<circle cx="72.8" cy="142.4" r="18.4" fill="#FFB8C7" fill-opacity=".45"/><circle cx="183.2" cy="142.4" r="18.4" fill="#FFB8C7" fill-opacity=".45"/>' +
  '<circle cx="95.8" cy="119.4" r="14.7" fill="#38334A"/><circle cx="160.2" cy="119.4" r="14.7" fill="#38334A"/>' +
  '<circle cx="128" cy="147" r="13.8" fill="#F28C9E"/>' +
  '<path d="M128 160.8 L109.6 174.6 M128 160.8 L146.4 174.6" stroke="#736B85" stroke-opacity=".85" stroke-width="6.9" stroke-linecap="round"/></svg>';
export function recolor(svg, map) { let s = svg; Object.keys(map || {}).forEach(k => { s = s.split(k).join(map[k]); }); return s; }
const _art = new Map();
export function creatureUrl(subject, map) {
  const key = subject + '|' + JSON.stringify(map || {});
  if (!_art.has(key)) _art.set(key, 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(recolor(subject === 'mochi' ? MOCHI_SVG : PIP_SVG, map)));
  return _art.get(key);
}
export function iconUrl(res) { if (!res) return 'icons/slot_generic.svg'; const b = res.split('/').pop(); return res.indexOf('/demo/') >= 0 ? 'demo/' + b : 'icons/' + b; }

// ── Katalog ────────────────────────────────────────────────────────────────
let _load = null;
export function loadCatalog() {
  if (!_load) _load = fetch('../godot/cosmetics.json', { cache: 'no-store' }).then(r => { if (!r.ok) throw 0; return r.json(); })
    .then(j => ({ cat: j, source: 'godot/cosmetics.json', same: JSON.stringify(j) === JSON.stringify(CATALOG) }))
    .catch(() => ({ cat: CATALOG, source: 'embedded copy', same: true }));
  return _load;
}
// Spaja katalog s demo zakrpom. Komponente dobiju isti oblik objekta — ništa drugo se ne mijenja.
export function withPatch(cat, patch) {
  if (!patch) return cat;
  let items = cat.items.slice();
  if (patch.replaceSlotItems) items = items.filter(i => i.slot !== patch.replaceSlotItems);
  return Object.assign({}, cat, { slots: cat.slots.concat(patch.slots || []), items: items.concat(patch.items || []) });
}
// Ono što ekran gradi: slotovi po order, stavke po order, stanje kartice.
export function view(cat, owned, pending, seen) {
  const own = new Set(owned || []);
  return cat.slots.slice().sort((a, b) => a.order - b.order).map(s => {
    const items = cat.items.filter(i => i.slot === s.id).sort((a, b) => a.order - b.order).map(i => ({
      item: i, owned: own.has(i.id),
      // Pravilo: stavka iz Shopa koju nemaš se NE crta (Shop je jedini put); druge izvore crtamo pod velom.
      visible: own.has(i.id) || i.source !== 'shop',
      isNew: own.has(i.id) && i.new_since != null && i.new_since > (seen || 0)
    }));
    return { slot: s, items, worn: pending[s.id] || '' };
  });
}
