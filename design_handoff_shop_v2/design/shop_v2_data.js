// Shop v2 — podaci i logika mockupa. NIJE tokens fajl: stilovi su inline u .dc.html.
// CATALOG = doslovna kopija game/data/cosmetics/cosmetics.json (ref/cosmetics.json); Specs provjerava da su isti.
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
      "description": "Soft pink accents for Pip.",
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

let _load = null;
export function loadCatalog() {
  if (!_load) _load = fetch('ref/cosmetics.json', { cache: 'no-store' }).then(r => { if (!r.ok) throw 0; return r.json(); })
    .then(j => ({ cat: j, source: 'ref/cosmetics.json', same: JSON.stringify(j) === JSON.stringify(CATALOG) }))
    .catch(() => ({ cat: CATALOG, source: 'embedded copy', same: true }));
  return _load;
}
export function iconUrl(res) { if (!res) return 'icons/slot_generic.svg'; return 'icons/' + res.split('/').pop(); }

// game/data/seasons/seasons.json (display_name, rarity) + mood boja kartice (Home v3)
export const SEASONS = {
  country_bloom: { name: 'Country Bloom', g: '#E6F2DB', kind: 'free', roster: [['clover', 1], ['daisy', 1], ['buttercup', 1], ['tulip', 2], ['sunflower', 2], ['pumpkin', 3]] },
  frost_orchard: { name: 'Frost Orchard', g: '#D1E6FF', kind: 'free', roster: [['frost_snowdrop', 1], ['ice_crocus', 1], ['silver_aconite', 1], ['winter_camellia', 2], ['hoarfrost_rose', 2], ['crystal_peony', 3]] },
  lantern_meadow: { name: 'Lantern Meadow', g: '#EBD6FF', kind: 'free', roster: [['dusk_firefly_grass', 1], ['paper_lantern_bloom', 1], ['evening_primrose', 1], ['foxfire_lily', 2], ['glow_wisteria', 2], ['midnight_lotus', 3]] },
  amber_canopy: { name: 'Amber Canopy', g: '#FFEBC7', kind: 'free', roster: [['copper_leaf', 1], ['maple_aster', 1], ['russet_mallow', 1], ['cider_dahlia', 2], ['golden_oak_bloom', 2], ['amber_magnolia', 3]] },
  moonlit_warren: { name: 'Moonlit Warren', g: '#B8BDFF', kind: 'paid', sku: 'season_pack_moonlit_warren', roster: [['moon_moss', 1], ['nightshade_petal', 1], ['silver_harebell', 1], ['lunar_orchid', 2], ['star_jasmine', 2], ['umbral_lily', 3]] },
  coral_tide: { name: 'Coral Tide Garden', g: '#FFE0D6', kind: 'paid', sku: 'season_pack_coral_tide', roster: [['sea_thrift', 1], ['salt_daisy', 1], ['tide_anemone', 1], ['coral_hibiscus', 2], ['pearl_waterlily', 2], ['reef_crown', 3]] },
  starfall_glade: { name: 'Starfall Glade', g: '#DBCCFF', kind: 'paid', sku: 'season_pack_starfall_glade', roster: [['comet_sprig', 1], ['nebula_clover', 1], ['meteor_daisy', 1], ['aurora_tulip', 2], ['galaxy_sunburst', 2], ['nova_bloom', 3]] },
  ember_fen: { name: 'Ember Fen', g: '#FFC79E', kind: 'paid', sku: 'season_pack_ember_fen', soon: true, roster: [['marsh_rush', 1], ['peat_violet', 1], ['cinder_buttercup', 1], ['flame_iris', 2], ['smoke_lotus', 2], ['fenfire_crown', 3]] }
};
export const FREE = ['country_bloom', 'frost_orchard', 'lantern_meadow', 'amber_canopy'];
export const PREMIUM = ['moonlit_warren', 'coral_tide', 'starfall_glade', 'ember_fen'];
export const FLOWER_NAME = { pumpkin: 'Harvest Pumpkin', crystal_peony: 'Crystal Peony', midnight_lotus: 'Midnight Lotus', amber_magnolia: 'Amber Magnolia' };
export function star3Of(season) { return SEASONS[season].roster.find(r => r[1] === 3)[0]; }
// Loot Burst: ★3 sezone koja je uslov za sljedecu zakljucanu besplatnu (Seasons.next_locked_free_id()). null = kartica se ne crta.
export function lootTarget(unlocked) {
  const next = FREE.find(id => !unlocked.includes(id));
  if (!next) return null;
  const from = FREE[FREE.indexOf(next) - 1];
  const flower = star3Of(from);
  return { next, nextName: SEASONS[next].name, from, flower, flowerName: FLOWER_NAME[flower] || flower };
}

// Cijene = store stringovi (IAPManager.get_price_label). Iznosi iz §2, KM i Rp samo za provjeru duzine.
export const PRICES = {
  eur: { season_pack_moonlit_warren: '€2.99', season_pack_coral_tide: '€3.49', season_pack_starfall_glade: '€2.99', booster_merge_hint: '€0.99', booster_loot_burst: '€0.99', remove_ads: '€3.99', starter_pack: '€1.99' },
  km: { season_pack_moonlit_warren: '5,85 KM', season_pack_coral_tide: '6,83 KM', season_pack_starfall_glade: '5,85 KM', booster_merge_hint: '1,94 KM', booster_loot_burst: '1,94 KM', remove_ads: '7,80 KM', starter_pack: '3,89 KM' },
  long: { season_pack_moonlit_warren: 'Rp 49.900', season_pack_coral_tide: 'Rp 57.900', season_pack_starfall_glade: 'Rp 49.900', booster_merge_hint: 'Rp 16.500', booster_loot_burst: 'Rp 16.500', remove_ads: 'Rp 64.900', starter_pack: 'Rp 32.900' }
};
export const PRICE_LONG_CHARS = 7;
export function priceFont(s) { return String(s || '').length > PRICE_LONG_CHARS ? 44 : 52; }

// ── Boje ──
const fr = x => x - Math.floor(x);
export function rgb(h) { const s = h.replace('#', ''); return [0, 2, 4].map(i => parseInt(s.substr(i, 2), 16)); }
export function toHex(a) { return '#' + a.map(v => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, '0')).join('').toUpperCase(); }
export function hsv(h, s, v) { h = fr(h) * 6; const i = Math.floor(h), f = h - i, p = v * (1 - s), q = v * (1 - s * f), t = v * (1 - s * (1 - f)); const m = [[v, t, p], [q, v, p], [p, v, t], [p, q, v], [t, p, v], [v, p, q]][i % 6]; return toHex(m.map(x => x * 255)); }
export function mix(a, b, t) { const A = rgb(a), B = rgb(b); return toHex(A.map((v, i) => v + (B[i] - v) * t)); }
export function lum(hex) { return rgb(hex).map(c => { c /= 255; return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4); }).reduce((s, v, i) => s + v * [0.2126, 0.7152, 0.0722][i], 0); }
export function contrast(a, b) { const x = lum(a), y = lum(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); }
// Kartica sezone = Home v3 trake: nebo +30 % bijele, daljina = g, blizina g x 0,93
export function bands(g) { const c = rgb(g); return { sky: toHex(c.map(v => v + (255 - v) * 0.30)), far: toHex(c), near: toHex(c.map(v => v * 0.93)) }; }

// ── Portret cvijeta = UiHomeV3.draw_flower() -> CampPlantDraw.draw_cropped_plant(type, 3, d * 0.78) ──
// SVG postoji samo za Country Bloom 6 (game/assets/sprites/flowers/<type>_t3.svg); ostalo je proceduralni ★3 (_draw_crystal).
export const ART_FILL = 0.78;
const SVG_T3 = { pumpkin: [30, 47, 197, 181], clover: [65, 52, 139, 202] }; // vidljivi piksel u 256 platnu (= arena_v2_data CROP)
const SEASON_HUE = { frost_orchard: 0.55, lantern_meadow: 0.10, amber_canopy: 0.06, moonlit_warren: 0.65, coral_tide: 0.97, starfall_glade: 0.78, ember_fen: 0.02 };
// Godot String.hash() = djb2 nad UTF-32 (uint32)
export function godotHash(s) { let h = 5381; for (const ch of s) h = (Math.imul(h, 33) + ch.codePointAt(0)) >>> 0; return h; }
export function seasonalPalette(type, season) {
  const hash = godotHash(type);
  let base = SEASON_HUE[season]; if (base == null) base = (hash % 360) / 360;
  const hue = fr(base + ((hash % 100) / 100 - 0.5) * 0.08 + 1);
  return { petal: hsv(hue, 0.55, 0.92), center: hsv(fr(hue + 0.08), 0.65, 0.78), seed: hsv(hue, 0.48, 0.85), crystal: hsv(fr(hue + 0.15), 0.55, 0.96) };
}
const lighten = (hex, k) => toHex(rgb(hex).map(v => v + (255 - v) * k));
// Sve sto FlowerPortrait treba (bez importa u djetetu).
export function portrait(type, season, rarity, d) {
  const inner = d - 8;
  if (SVG_T3[type]) {
    const c = SVG_T3[type], box = d * ART_FILL, s = box / Math.max(c[2], c[3]);
    const r2 = v => Math.round(v * 100) / 100;
    return { svg: false, src: 'icons/flowers/' + type + '_t3.svg', size: r2(256 * s), left: r2((inner - c[2] * s) / 2 - c[0] * s), top: r2((inner - c[3] * s) / 2 - c[1] * s), d };
  }
  const u = 60 / (d * ART_FILL) * inner;
  const p = seasonalPalette(type, season);
  return { svg: true, vb: (-u / 2).toFixed(2) + ' ' + (-6 - u / 2).toFixed(2) + ' ' + u.toFixed(2) + ' ' + u.toFixed(2), crystal: p.crystal, ring: lighten(p.crystal, 0.2), sparkle: rarity >= 3, d };
}
export function seasonPortraits(season) {
  return SEASONS[season].roster.map(([type, rar]) => Object.assign({ type, rarity: rar }, portrait(type, season, rar, rar >= 3 ? 172 : 148)));
}
