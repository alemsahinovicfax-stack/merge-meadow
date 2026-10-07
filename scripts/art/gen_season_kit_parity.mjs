// Referentni brojevi za test/unit/test_season_kit_parity.gd iz CD-ovog izvora (seasons_kit.js).
// node scripts/art/gen_season_kit_parity.mjs > game/test/unit/fixtures/season_kit_parity.json
import * as K from '../../design_handoff_seasons/design/seasons_kit.js';
const IDS = ['country_bloom','frost_orchard','lantern_meadow','amber_canopy','moonlit_warren','coral_tide','starfall_glade','ember_fen'];
const r6 = v => Math.round(v * 1e6) / 1e6;
const out = {};
for (const id of IDS) {
  const kit = K.KITS[id];
  const ridges = kit.field.layers.filter(L => L.k === 'ridge');
  const ridge = ridges.find(L => L.r.tilt) || ridges[ridges.length - 1];
  const scat = kit.field.layers.find(L => L.k === 'scatter');
  const layers = K.ambientLayers(kit.ambient);
  const L = layers[layers.length - 1];
  out[id] = {
    ridge_layer: kit.field.layers.indexOf(ridge),
    ridge: [0, 13, 50, 77.5, 100].map(x => [x, r6(K.ridgeY(ridge.r, x))]),
    scatter_layer: kit.field.layers.indexOf(scat),
    scatter: [0, 1, 5, 9, 13].filter(i => i < scat.n).map(i => { const s = K.scatterAt(scat, i); return [i, r6(s.x), r6(s.y), r6(s.size), r6(s.rot)]; }),
    ambient_layer: layers.length - 1,
    parts: L.parts.slice(0, 5).map(p => [p.i, r6(p.x), r6(p.y), r6(p.size), r6(p.angle), r6(p.delay)]),
    at: layers.map((LL, li) => [0.05, 0.15, 0.3, 0.5, 0.77, 0.95].map(t => { const a = K.ambientAt(LL, t); return [li, t, r6(a.dx), r6(a.dy), r6(a.rot), r6(a.s), r6(a.a)]; })).flat(),
    motions: layers.map(LL => LL.motion),
  };
}
console.log(JSON.stringify(out));
