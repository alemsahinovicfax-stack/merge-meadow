// Sir Pip — premium skin (real money, cosmetic only). Own parts per view, skin-only nodes (k_*),
// skin layer loop, idle detail, reactions. Same pivots as Classic: every shared animation runs unchanged.
// Load after pip_art.js, pip_runtime.js, pip_anim.js.
(function boot(G) {
'use strict';
// helmet scripts load in any order: wait for dependencies
if (!(G.PipArt && G.Pip && G.Pip.ANIMS.merge_t3 && G.Pip.ANIMS.finish && G.PipBehaviors)) { setTimeout(() => boot(G), 15); return; }
const A = G.PipArt, Pip = G.Pip, { P, E, S, star4, star5 } = A.helpers, INK = A.INK;
const K = {
  ACORN: '#B9824A', ACORN_SH: '#8E5C30', ACORN_LT: '#D8A76C',
  GOLD: '#F7CB5A', GOLD_SH: '#D29B2E',
  CAPE: '#7F86E6', CAPE_SH: '#5E63C4', CAPE_LT: '#B4B8F8',
  PEW: '#DCE3EA', PEW_SH: '#A7B4C2', PEW_LT: '#F7FAFC',
  PLUME: '#FF8A80', PLUME_SH: '#E0615E'
};
const clover = (cx, cy, r, fill, edge) => E(cx, cy - r * .9, r, r, fill, 2, edge) + E(cx - r * .85, cy + r * .2, r, r, fill, 2, edge) + E(cx + r * .85, cy + r * .2, r, r, fill, 2, edge) + E(cx, cy, r * .45, r * .45, fill);
const spr = (name, fn, note) => { A.SPR[name] = { frames: { default: fn }, note: note || '', skin: 'knight' }; };

// ── bodies (same silhouette as Classic so paws / feet / head sit on the same pivots)
const BODY = 'M0 -84 C 30 -84 54 -56 54 -30 C 54 -8 32 6 0 6 C -32 6 -54 -8 -54 -30 C -54 -56 -30 -84 0 -84 Z';
const belt = d => S(d, 9, INK) + S(d, 5, K.GOLD);
function plate(d, sh, hi, cx) { return P(d, K.PEW) + P(sh, K.PEW_SH) + S(hi, 4, K.PEW_LT) + P(d, 'none', 3) + clover(cx, -40, 5.2, K.GOLD, INK) + S('M ' + (cx - 1) + ' -35 Q ' + (cx + 1) + ' -29 ' + (cx + 4) + ' -26', 2.4); }
spr('k_body_f', k => P(BODY, k.fur) + P('M 29 -76 C 45 -64 54 -46 54 -30 C 54 -8 32 6 0 6 C 24 0 42 -16 44 -36 C 45 -52 40 -66 29 -76 Z', k.fur_sh) +
  belt('M -52 -20 C -30 -8 30 -8 52 -20') + P(BODY, 'none', 3) +
  plate('M -30 -64 C -12 -72 12 -72 30 -64 C 35 -42 28 -16 0 -6 C -28 -16 -35 -42 -30 -64 Z', 'M 14 -69 C 24 -67 30 -64 30 -64 C 35 -42 28 -16 0 -6 C 18 -18 26 -40 14 -69 Z', 'M -22 -58 C -24 -46 -21 -34 -15 -26', 0), 'front: fur + pewter breastplate, gold clover, gold belt');
spr('k_body_q', k => P(BODY, k.fur) + P('M 22 -80 C 44 -68 54 -46 54 -30 C 54 -8 32 6 0 6 C 30 -2 40 -20 42 -38 C 43 -54 36 -70 22 -80 Z', k.fur_sh) +
  belt('M -53 -22 C -30 -8 34 -8 53 -18') + P(BODY, 'none', 3) +
  plate('M -16 -64 C 0 -72 22 -72 38 -62 C 42 -40 34 -16 10 -6 C -14 -16 -20 -42 -16 -64 Z', 'M 26 -69 C 34 -66 38 -62 38 -62 C 42 -40 34 -16 10 -6 C 28 -18 36 -40 26 -69 Z', 'M -9 -58 C -11 -46 -8 -34 -3 -26', 11), 'three_q');
const BODY_S = 'M -52 -10 C -58 -44 -30 -70 4 -70 C 30 -70 46 -54 46 -30 C 46 -8 30 6 -2 6 C -34 6 -50 2 -52 -10 Z';
spr('k_body_s', k => P(BODY_S, k.fur) + P('M -50 -6 C -48 2 -34 6 -2 6 C 18 6 32 2 40 -6 C 24 -2 -20 0 -50 -6 Z', k.fur_sh) +
  belt('M -52 -16 C -24 -6 20 -6 45 -16') + P(BODY_S, 'none', 3) +
  P('M 18 -64 C 34 -62 47 -48 47 -30 C 47 -16 39 -6 26 -2 C 20 -20 16 -44 18 -64 Z', K.PEW) + P('M 40 -50 C 46 -40 48 -26 44 -16 C 40 -8 34 -4 26 -2 C 34 -14 40 -32 40 -50 Z', K.PEW_SH) +
  P('M 18 -64 C 34 -62 47 -48 47 -30 C 47 -16 39 -6 26 -2 C 20 -20 16 -44 18 -64 Z', 'none', 3) + clover(32, -40, 4.2, K.GOLD, INK), 'side');

// ── paws, boots
spr('k_paw_f', k => E(0, 9, 9.5, 9, k.fur) + P('M 2 16.5 C 7 15 9.5 11 9.5 8 C 8 13 5 15 2 16.5 Z', k.fur_sh) + E(0, 9, 9.5, 9, 'none', 3) + S('M -3 14.5 L -3 17.5 M 3 14.5 L 3 17.5', 2) +
  P('M -10 5 C -4 2 4 2 10 5 L 9.5 -1 C 4 -3.5 -4 -3.5 -9.5 -1 Z', K.GOLD, 2.2), 'paw + gold cuff');
spr('k_boot_f', k => E(0, 0, 25, 11, K.ACORN) + P('M -21 5 C -12 11 12 11 21 5 C 14 8 -14 8 -21 5 Z', K.ACORN_SH) + S('M -14 -5 C -8 -8 -2 -8 2 -7', 2.6, K.ACORN_LT) + E(0, 0, 25, 11, 'none', 3) + P('M -5 -4 L 5 -4 L 5 3 L -5 3 Z', K.GOLD, 2), 'acorn boot');
const FOOT_S = 'M -30 0 C -30 -8 -18 -12 0 -12 C 18 -12 31 -7 31 -1 C 31 5 20 7 0 7 C -20 7 -30 5 -30 0 Z';
spr('k_boot_s', k => P(FOOT_S, K.ACORN) + P('M -26 4 C -16 7 18 7 29 3 C 22 5 -16 5 -26 4 Z', K.ACORN_SH) + P(FOOT_S, 'none', 3) + P('M -14 -10 L -6 -10 L -6 -2 L -14 -2 Z', K.GOLD, 2) + S('M 18 -9 C 24 -8 28 -5 29 -2', 2.4, K.ACORN_LT));
spr('k_boot_b', k => E(0, 0, 22, 12, K.ACORN) + E(0, 2, 14, 7, K.ACORN_LT) + E(0, 0, 22, 12, 'none', 3) + S('M -8 2 L 8 2', 2.2, K.ACORN_SH));
const FOOT_T = 'M 0 -20 C 8 -20 10 -8 10 4 C 10 15 6 22 0 22 C -6 22 -10 15 -10 4 C -10 -8 -8 -20 0 -20 Z';
spr('k_boot_t', k => P(FOOT_T, K.ACORN) + P('M -5 6 C -5 14 -3 18 0 18 C 3 18 5 14 5 6 C 3 9 -3 9 -5 6 Z', K.ACORN_LT) + P(FOOT_T, 'none', 3) + S('M -8 -8 L 8 -8', 3, K.GOLD));

// ── ears with gold ear-cuffs (cuff sits where the ear leaves the helmet)
const EAR_L = 'M -13 6 C -20 -20 -18 -54 -5 -68 C 3 -76 13 -71 14 -54 C 15 -32 12 -10 12 6 Z';
const EAR_RB = 'M -13 6 C -18 -14 -17 -36 -12 -48 C -8 -58 8 -58 13 -48 C 15 -30 12 -10 12 6 Z';
const cuff = P('M -16.5 -30 C -8 -26 6 -26 14 -30 L 14.5 -38 C 6 -34 -8 -34 -17 -38 Z', K.GOLD, 2.4) + E(-1, -32, 2, 2, K.GOLD_SH);
spr('k_ear_l', k => P(EAR_L, k.fur) + P('M -6 2 C -10 -20 -9 -46 -3 -57 C 3 -61 7 -54 7 -42 C 7 -24 5 -8 5 2 Z', k.ear_in) + P('M 9 -64 C 14 -56 15 -34 12 6 L 8 6 C 10 -20 11 -46 9 -64 Z', k.fur_sh) + P(EAR_L, 'none', 3) + cuff);
spr('k_ear_rb', k => P(EAR_RB, k.fur) + P('M -6 2 C -9 -16 -8 -34 -5 -44 C -2 -48 4 -48 6 -44 C 7 -28 5 -8 5 2 Z', k.ear_in) + P('M 9.5 -50 C 11 -50 12 -49 13 -48 C 15 -30 12 -10 12 6 L 8.5 6 C 10 -16 10.5 -34 9.5 -50 Z', k.fur_sh) + P(EAR_RB, 'none', 3) + cuff);
spr('k_ear_back', k => P(EAR_L, k.fur) + P('M 9 -64 C 14 -56 15 -34 12 6 L 8 6 C 10 -20 11 -46 9 -64 Z', k.fur_sh) + P(EAR_L, 'none', 3) + cuff);
spr('k_ear_backb', k => P(EAR_RB, k.fur) + P('M 9.5 -50 C 11 -50 12 -49 13 -48 C 15 -30 12 -10 12 6 L 8.5 6 C 10 -16 10.5 -34 9.5 -50 Z', k.fur_sh) + P(EAR_RB, 'none', 3) + cuff);

// ── plume (replaces the forehead tuft — it rides every tuft key), helmets
const PL = 'M -7 -22 C -12 -36 -4 -48 10 -50 C 22 -52 32 -48 37 -42 C 28 -42 21 -38 16 -32 C 12 -26 8 -23 4 -21 Z';
spr('k_plume', k => P('M -3 -22 C -15 -30 -18 -40 -12 -48 C -8 -40 -3 -32 1 -24 Z', K.GOLD, 2.4) + P(PL, K.PLUME) + P('M 37 -42 C 28 -42 21 -38 16 -32 C 12 -26 8 -23 4 -21 L -7 -22 C 4 -28 16 -38 37 -42 Z', K.PLUME_SH) + P(PL, 'none', 3) +
  S('M 0 -27 C 7 -35 16 -41 26 -44', 2, K.PLUME_SH) + E(0, -21, 7.5, 4.5, K.GOLD, 2.6), 'coral plume + gold feather, on the tuft pivot');
spr('k_plume_t', k => P('M -7 0 C -11 18 -3 40 5 54 C 12 40 12 18 7 0 C 2 -3 -2 -3 -7 0 Z', K.PLUME, 3) + S('M 0 3 L 4 46', 2, K.PLUME_SH) + E(0, 0, 6, 5, K.GOLD, 2.4), 'top view: plume lies back');
const CAP = 'M -64 -4 C -66 -24 -48 -42 0 -42 C 48 -42 66 -24 64 -4 C 40 2 -40 2 -64 -4 Z';
const SCALES = 'M -46 -14 l 6 5 l 6 -5 M -22 -20 l 6 5 l 6 -5 M 4 -20 l 6 5 l 6 -5 M 28 -14 l 6 5 l 6 -5 M -34 -28 l 6 5 l 6 -5 M -8 -32 l 6 4 l 6 -4 M 18 -28 l 6 5 l 6 -5';
const BAND = 'M -72 -9 C -40 -1 40 -1 72 -9 L 73 0 C 40 8 -40 8 -73 0 Z';
spr('k_helm_f', k => P(CAP, K.ACORN) + P('M 34 -34 C 52 -28 63 -18 62 -4 C 54 -2 46 -1 38 0 C 46 -12 44 -24 34 -34 Z', K.ACORN_SH) + S('M -42 -26 C -32 -32 -18 -34 -8 -34', 4, K.ACORN_LT) + S(SCALES, 2.2, K.ACORN_SH) + P(CAP, 'none', 3) +
  P(BAND, K.GOLD, 3) + E(-52, -2, 2.6, 2.6, K.GOLD_SH) + E(-18, 1, 2.6, 2.6, K.GOLD_SH) + E(18, 1, 2.6, 2.6, K.GOLD_SH) + E(52, -2, 2.6, 2.6, K.GOLD_SH), 'acorn-cap helmet, flared gold brim');
const CAP_S = 'M -50 -4 C -54 -22 -36 -38 -4 -38 C 28 -38 50 -26 54 -10 L 68 -6 C 72 -2 66 3 56 1 C 30 4 -26 3 -50 -4 Z';
spr('k_helm_s', k => P(CAP_S, K.ACORN) + P('M 30 -32 C 44 -26 52 -18 54 -10 L 68 -6 C 72 -2 66 3 56 1 C 50 1 44 1 38 1 C 42 -10 40 -22 30 -32 Z', K.ACORN_SH) + S('M -34 -26 C -24 -32 -12 -34 -2 -34', 4, K.ACORN_LT) +
  S('M -36 -16 l 6 5 l 6 -5 M -12 -22 l 6 5 l 6 -5 M 14 -20 l 6 5 l 6 -5 M -22 -30 l 6 4 l 6 -4 M 2 -32 l 6 4 l 6 -4', 2.2, K.ACORN_SH) + P(CAP_S, 'none', 3) +
  P('M -52 -8 C -26 -1 30 -1 56 -6 L 56.5 2 C 30 7 -26 7 -52.5 0 Z', K.GOLD, 3) + E(-26, -1, 2.6, 2.6, K.GOLD_SH) + E(14, 0, 2.6, 2.6, K.GOLD_SH), 'side: visor peak forward');
spr('k_helm_t', k => E(0, 0, 32, 29, K.GOLD, 3) + E(0, -1, 22.5, 20.5, K.ACORN, 2.6) + P('M 10 -18 C 20 -12 23 -2 21 8 C 18 14 12 18 6 19 C 14 8 16 -6 10 -18 Z', K.ACORN_SH) +
  S('M -12 -8 l 5 4 l 5 -4 M 4 -8 l 5 4 l 5 -4 M -6 4 l 5 4 l 5 -4 M -16 6 l 4 4 M 14 6 l -3 4', 2, K.ACORN_SH) + S('M -14 -14 C -9 -18 -3 -19 2 -19', 3.4, K.ACORN_LT) + E(0, -1, 22.5, 20.5, 'none', 2.6), 'top: helmet from above');

// ── cape (poppy-blue, scalloped hem), collar clasp, shield
const capeEdge = (d, sh, extra) => P(d, K.CAPE) + P(sh, K.CAPE_SH) + (extra || '') + P(d, 'none', 3);
const HEM = (x0, x1, y, n) => { let s = ''; const w = (x1 - x0) / n; for (let i = 0; i < n; i++) s += ' Q ' + (x1 - w * (i + .5)).toFixed(1) + ' ' + (y + 8) + ' ' + (x1 - w * (i + 1)).toFixed(1) + ' ' + y; return s; };
const CAPE_F = 'M 40 0 C 52 20 62 48 66 72' + HEM(-66, 66, 72, 6) + ' C -62 48 -52 20 -40 0 Z';
spr('k_cape_f', k => capeEdge(CAPE_F, 'M 40 0 C 52 20 62 48 66 72 Q 60 78 54 74 C 54 48 48 22 38 4 Z'), 'front: peeks out behind the body');
const CAPE_Q = 'M 34 0 C 46 18 54 46 56 72' + HEM(-76, 56, 72, 6) + ' C -72 46 -56 18 -36 0 Z';
spr('k_cape_q', k => capeEdge(CAPE_Q, 'M 34 0 C 46 18 54 46 56 72 Q 50 78 44 74 C 44 48 40 22 32 4 Z', P('M -36 0 C -56 18 -72 46 -76 72 Q -70 78 -64 74 C -62 48 -50 22 -32 4 Z', K.CAPE_LT)));
const CAPE_S = 'M 8 0 C -2 24 -6 50 0 68' + HEM(-58, 0, 68, 3) + ' C -60 62 -60 48 -54 30 C -46 6 -18 -6 8 0 Z';
spr('k_cape_s', k => capeEdge(CAPE_S, 'M 8 0 C -2 24 -6 50 0 68 Q -5 74 -10 71 C -12 50 -8 24 2 2 Z', P('M -54 30 C -60 48 -60 62 -58 68 Q -54 72 -50 70 C -52 56 -50 42 -46 30 Z', K.CAPE_LT) + S('M -30 10 C -36 26 -38 44 -36 60 M -14 8 C -20 26 -22 46 -20 62', 2.2, K.CAPE_SH)), 'side: draped over the back');
const CAPE_B = 'M 42 0 C 54 22 60 48 62 72' + HEM(-62, 62, 72, 7) + ' C -60 48 -54 22 -42 0 Z';
spr('k_cape_b', k => capeEdge(CAPE_B, 'M 42 0 C 54 22 60 48 62 72 Q 57 78 52 74 C 52 48 46 22 36 6 Z',
  S('M -22 14 C -28 32 -30 52 -28 68 M 22 14 C 28 32 30 52 28 68', 2.2, K.CAPE_SH) + clover(0, 40, 6.5, K.GOLD, INK) + S('M 0 46 Q 2 52 6 56', 2.4)) + P('M -42 0 C -20 9 20 9 42 0 C 30 -7 -30 -7 -42 0 Z', K.CAPE_LT, 3), 'back: full cape, embroidered clover');
const CAPE_T = 'M 34 0 C 48 18 56 42 54 70' + HEM(-54, 54, 70, 5) + ' C -56 42 -48 18 -34 0 C -20 -6 20 -6 34 0 Z';
spr('k_cape_t', k => capeEdge(CAPE_T, 'M 34 0 C 48 18 56 42 54 70 Q 48 76 43 72 C 46 44 40 20 28 2 Z', S('M -14 8 C -18 26 -20 44 -18 60 M 14 8 C 18 26 20 44 18 60', 2.2, K.CAPE_SH) + clover(0, 34, 5, K.GOLD, INK)) + E(0, -2, 6, 5, K.GOLD, 2.4), 'top: cape over the back (run)');
spr('k_collar', k => S('M -34 -6 Q -16 3 0 3 Q 16 3 34 -6', 8, INK) + S('M -34 -6 Q -16 3 0 3 Q 16 3 34 -6', 3.6, K.CAPE) + E(0, 3, 7.5, 7.5, K.GOLD, 2.6) + E(-2, 1, 2.2, 2.2, K.PEW_LT), 'cape straps + gold clasp');
spr('k_shield', k => E(0, 0, 21, 21, K.PEW, 3) + E(0, 0, 15.5, 15.5, K.CAPE, 2.4) + P('M 6 -14 C 13 -10 16 -3 15.5 3 C 14 9 10 13 5 15 C 10 6 11 -4 6 -14 Z', K.CAPE_SH) +
  clover(0, 1, 4.4, K.GOLD, INK) + E(0, -18, 1.8, 1.8, K.PEW_SH) + E(18, 0, 1.8, 1.8, K.PEW_SH) + E(0, 18, 1.8, 1.8, K.PEW_SH) + E(-18, 0, 1.8, 1.8, K.PEW_SH) + S('M -15 -8 Q -11 -14 -5 -16.5', 2.6, K.PEW_LT), 'round shield on arm_L');
spr('k_shield_s', k => E(0, 0, 13, 21, K.PEW, 3) + E(1, 0, 8.5, 15.5, K.CAPE, 2.4) + clover(1, 1, 3.2, K.GOLD, INK) + S('M -9 -8 Q -7 -14 -3 -16', 2.4, K.PEW_LT));
spr('k_shield_t', k => P('M -4 -18 C 2 -18 4 -10 4 0 C 4 10 2 18 -4 18 C -8 18 -9 10 -9 0 C -9 -10 -8 -18 -4 -18 Z', K.PEW, 2.6) + S('M -3 -12 L -3 12', 2.6, K.CAPE));

// ── FX for this skin (props + bursts; same fx/prop swap nodes)
Object.assign(A.FX, {
  k_star: k => P(star5(0, 0, 12), K.GOLD, 2.4),
  k_tink: k => P(star4(0, 0, 10), '#FFF6D6', 2.2),
  k_flag: k => E(0, 40, 12, 4, K.ACORN_SH) + S('M 0 40 L 0 -36', 7, INK) + S('M 0 40 L 0 -36', 3, K.ACORN) + P('M 2 -34 L 36 -26 L 24 -18 L 36 -10 L 2 -4 Z', K.CAPE, 2.6) + clover(14, -19, 3.4, K.GOLD, INK) + E(0, -38, 4, 4, K.GOLD, 2.2)
});

// ── nodes (skin-only, children of shared nodes → they inherit every existing animation)
const N = (id, parent, x, y, z, sprite, o) => Object.assign({ id, parent, x, y, z, sprite, rot: 0, sx: 1, sy: 1, skin: 'knight' }, o || {});
const ADD = {
  front: [N('k_cape', 'body', 0, -68, -6, 'k_cape_f'), N('k_collar', 'body', 0, -58, 7, 'k_collar'), N('k_helm', 'head', 0, -72, 1, 'k_helm_f'), N('k_shield', 'arm_L', -2, 12, 2, 'k_shield')],
  three_q: [N('k_cape', 'body', -6, -68, -6, 'k_cape_q'), N('k_collar', 'body', 8, -57, 7, 'k_collar', { sx: .86 }), N('k_helm', 'head', 4, -72, 1, 'k_helm_f', { sx: .98 }), N('k_shield', 'arm_L', -2, 12, 2, 'k_shield', { sx: .9 })],
  side: [N('k_cape', 'body', 6, -64, 1, 'k_cape_s'), N('k_helm', 'head', 0, -72, 1, 'k_helm_s'), N('k_shield', 'arm_R', 2, 12, 2, 'k_shield_s')],
  back: [N('k_cape', 'body', 0, -68, 2, 'k_cape_b'), N('k_helm', 'head', 0, -72, 3, 'k_helm_f', { sx: -1 })],
  top: [N('k_cape', 'body', 0, -24, .5, 'k_cape_t'), N('k_helm', 'head', 0, -6, 2.5, 'k_helm_t'), N('k_shield', 'arm_L', -9, 2, 1, 'k_shield_t')]
};
for (const v in ADD) { const r = A.RIGS[v]; const fxAt = r.nodes.findIndex(n => n.id === 'fx_ring'); r.nodes.splice(fxAt, 0, ...ADD[v]); delete r.map; }

const TOKENS = { fur: '#F5D6A6', fur_sh: '#DDAF78', fur_lt: '#FFF2DE', ear_in: '#FFC6BE', cheek: '#FFA88E', nose: '#E77B8E', iris: '#5A4433' };
A.SKINS.push({ key: 'knight', id: 'pip_knight', title: 'Sir Pip', product: 'Sir Pip · Meadow Knight', coin_cost: 0, source: 'iap', sku: 'pip_knight',
  price: { eur: '€3.99', usd: '$3.99', note: 'proposal — Apple tier 4 / Google 3,99 €; final call: owner' },
  tokens: TOKENS, overlays: [], palette: K,
  parts: { body_f: 'k_body_f', body_q: 'k_body_q', body_s: 'k_body_s', paw_f: 'k_paw_f', foot_f: 'k_boot_f', foot_s: 'k_boot_s', foot_b: 'k_boot_b', foot_t: 'k_boot_t',
    ear_l: 'k_ear_l', ear_rb: 'k_ear_rb', ear_back: 'k_ear_back', ear_backb: 'k_ear_backb', tuft: 'k_plume', 'top:tuft': 'k_plume_t' },
  loops: { default: 'k_cape_idle', top: 'k_cape_run' },
  reactions: { merge_t3: 't3_knight', finish: 'goal_knight' },
  idle_detail: { anim: 'idle_knight', gap_s: [6, 10], first_s: 2.5, on: ['idle', 'card_idle', 'stage_idle', 'arena_idle', 'hud_idle'] },
  showcase: 'pose_knight', signature: 'sig_knight', hud: 'pip_hud_knight',
  detail: 'Meadow armour: acorn-cap helmet with a coral plume, pewter breastplate with a gold clover, poppy-blue cape, round shield and acorn boots. Signature: plants his banner and salutes.' });

// ── animations
const def = Pip.def, L = 1, O = .5, I = 2, IO = -2;
const osc = (t0, amp, per) => [[t0, 0], [t0 + per * .5, amp], [t0 + per, -amp * .5], [t0 + per * 1.5, amp * .22], [t0 + per * 2, 0]];
const cat = (...ls) => [].concat(...ls).sort((a, b) => a[0] - b[0]);
const meta = o => Object.assign({ skin: 'knight' }, o);
def('k_cape_idle', 2.4, meta({ loop: true, layer: 'skin', view: 'any', ctx: 'skin', desc: 'Skin layer (third player, only k_* nodes): cape breathes, sways 2.5°.', rm: { type: 'skip' } }), b => {
  b.k('k_cape', 'r', [[0, 0], [1.2, 2.5, IO], [2.4, 0]]); b.k('k_cape', 's', [[0, 1, 1], [1.2, 1.025, 1.012, IO], [2.4, 1, 1]]);
});
def('k_cape_run', .24, meta({ loop: true, layer: 'skin', view: 'top', ctx: 'skin', speed_bind: 'scroll_speed / 400 (same as run_gallop)', desc: 'Skin layer in the run: cape flutters twice per gallop stride.', rm: { type: 'skip' } }), b => {
  b.k('k_cape', 's', [[0, 1, 1], [.06, 1.03, 1.08], [.12, 1, 1], [.18, 1.03, 1.08], [.24, 1, 1]]); b.k('k_cape', 'r', [[0, -2], [.12, 2], [.24, -2]]);
});
def('pose_knight', .01, meta({ view: 'three_q', ctx: 'shop', hold: true, desc: 'Showcase Sir Pip: chest out, shield forward, paw on hip, chin up, cape flared.', rm: { type: 'end' } }), b => {
  b.k('body', 's', [[0, .98, 1.03]]); b.k('arm_L', 'r', [[0, 32]]); b.k('arm_L', 'p', [[0, 4, -6]]); b.k('arm_R', 'r', [[0, 34]]); b.k('arm_R', 'p', [[0, -4, 2]]);
  b.k('head', 'r', [[0, -6]]); b.k('pip', 'r', [[0, -1.5]]); b.k('k_cape', 'r', [[0, -6]]); b.k('k_cape', 's', [[0, 1.08, 1.02]]); b.k('ear_R_tip', 'r', [[0, -10]]); b.x(0, 'proud');
});
def('sig_knight', 1.5, meta({ view: 'three_q', ctx: 'shop', desc: 'Signature Sir Pip (tap, 1.5 s): leaps, plants his banner, salutes — three gold stars.', rm: { type: 'expr', fx: false } }), b => {
  b.k('pip', 'p', [[0, 0, 0], [.12, 0, 0, O], [.32, 10, -52, I], [.56, 18, 0], [1.3, 18, 0, IO], [1.5, 0, 0]]);
  b.k('body', 's', [[0, 1, 1], [.1, 1.08, .9, O], [.14, .92, 1.12], [.32, 1, 1.03], [.54, .97, 1.06, O], [.58, 1.14, .84, O], [.7, .98, 1.03], [.8, 1, 1]]);
  b.k('arm_R', 'r', [[0, 0], [.2, 0, O], [.34, -150], [1.1, -150, IO], [1.4, 0]]); b.k('arm_R', 'p', [[0, 0, 0], [.34, -2, -10], [1.1, -2, -10], [1.4, 0, 0]]);
  b.k('arm_L', 'r', [[0, 0], [.3, 20], [1.2, 20], [1.45, 0]]);
  b.k('ear_L', 'r', cat([[0, 0]], osc(.14, -12, .16), osc(.58, 10, .16))); b.k('ear_R', 'r', cat([[0, 0]], osc(.14, 12, .16), osc(.58, -10, .16)));
  b.k('k_cape', 'r', [[0, 0], [.3, -16, O], [.58, 10], [.8, -5], [1, 0]]); b.k('k_cape', 's', [[0, 1, 1], [.3, 1.12, .92], [.58, 1.04, 1.06], [.8, 1, 1]]);
  b.k('k_helm', 'p', [[0, 0, 0], [.56, 0, 0], [.6, 0, -4, O], [.72, 0, 0]]);
  b.fx('prop', 'k_flag', { p: [[.56, -74, -10]], s: [[.56, .3, .3, O], [.68, 1.55, 1.55], [.8, 1.4, 1.4], [1.32, 1.4, 1.4], [1.46, .4, .4]], a: [[1.3, 1], [1.46, 0]], end: 1.46 });
  b.fx('fx_a', 'k_star', { p: [[.62, -64, -60, O], [1, -96, -116]], s: [[.62, .2, .2, O], [.8, 1, 1], [1.1, .6, .6]], end: 1.1 });
  b.fx('fx_b', 'k_star', { p: [[.68, -64, -60, O], [1.06, -40, -132]], s: [[.68, .2, .2, O], [.86, .9, .9], [1.16, .5, .5]], end: 1.16 });
  b.fx('fx_c', 'k_star', { p: [[.74, -64, -60, O], [1.12, -10, -96]], s: [[.74, .2, .2, O], [.92, .8, .8], [1.22, .4, .4]], end: 1.22 });
  b.x(0, 'determined', .3, 'joy', .9, 'proud', 1.4, 'happy');
});
def('idle_knight', 1.4, meta({ layer: 'overlay', ctx: 'shared', desc: 'Idle detail Sir Pip (every 6–10 s while resting): the helmet slips askew, a head-shake, it clicks back with a tink.', rm: { type: 'skip' } }), b => {
  b.k('k_helm', 'r', [[0, 0], [.16, 22, I], [.6, 22], [.78, -6, O], [.92, 3], [1.06, 0]]); b.k('k_helm', 'p', [[0, 0, 0], [.16, 12, 9, I], [.6, 12, 9], [.78, 0, -5, O], [1.06, 0, 0]]);
  b.k('head', 'r', [[0, 0], [.6, 0], [.66, -8], [.73, 7], [.8, -4], [.88, 0]]);
  b.fx('fx_f', 'k_tink', { p: [[.8, 52, -186]], s: [[.8, .2, .2, O], [.92, 1, 1], [1.12, .3, .3]], end: 1.12 });
  b.x(0, 'neutral', .18, 'surprised', .58, 'determined', .92, 'proud', 1.36, 'neutral');
});
const clone = (id, nid, len, m, extra) => def(nid, len, meta(Object.assign({}, { view: Pip.ANIMS[id].view, ctx: Pip.ANIMS[id].ctx, hold: Pip.ANIMS[id].hold, rm: Pip.ANIMS[id].rm }, m)), b => {
  b.tracks = JSON.parse(JSON.stringify(Pip.ANIMS[id].tracks)); b.events = JSON.parse(JSON.stringify(Pip.ANIMS[id].events)); extra(b);
});
clone('merge_t3', 't3_knight', 1.1, { desc: 'Sir Pip on ★3 merge (replaces merge_t3 for this skin): the binky + shield raised high, cape flares, three gold stars. Events unchanged.' }, b => {
  b.k('arm_L', 'r', [[0, 0], [.12, 0], [.3, 150, O], [.82, 150], [1.05, 0]]); b.k('arm_L', 'p', [[0, 0, 0], [.3, -12, -36], [.82, -12, -36], [1.05, 0, 0]]);
  b.k('arm_R', 'r', [[0, 0], [.3, -28], [.82, -28], [1.05, 0]]);
  b.k('k_cape', 's', [[0, 1, 1], [.3, 1.14, 1.06, O], [.6, .98, 1], [.8, 1.06, 1.02], [1.1, 1, 1]]); b.k('k_cape', 'r', [[0, 0], [.3, -8], [.6, 6], [.9, 0]]);
  b.fx('fx_c', 'k_star', { p: [[.34, -60, -150, O], [.8, -92, -214]], s: [[.34, .2, .2, O], [.5, 1.1, 1.1], [.9, .4, .4]], end: .9 });
  b.fx('fx_d', 'k_star', { p: [[.4, -60, -150, O], [.86, -36, -232]], s: [[.4, .2, .2, O], [.56, 1, 1], [.96, .4, .4]], end: .96 });
  b.fx('fx_e', 'k_star', { p: [[.46, -60, -150, O], [.92, -112, -150]], s: [[.46, .2, .2, O], [.62, .9, .9], [1, .4, .4]], end: 1 });
});
clone('finish', 'goal_knight', .62, { desc: 'Sir Pip at the run goal (replaces finish for this skin): same sit-up + the cape spreads wide, plume springs, two gold stars. Holds.' }, b => {
  b.k('k_cape', 's', [[0, 1, 1], [.3, 1.26, 1.14, O], [.42, 1.18, 1.1], [.62, 1.2, 1.12]]);
  b.k('tuft', 's', [[0, 1, 1], [.3, 1.35, 1.35, O], [.42, 1.15, 1.15], [.62, 1.22, 1.22]]);
  b.fx('fx_c', 'k_star', { p: [[.32, -50, 20, O], [.62, -60, 4]], s: [[.32, .2, .2, O], [.48, 1, 1], [.62, .9, .9]], end: .62 });
  b.fx('fx_d', 'k_star', { p: [[.38, 50, 20, O], [.62, 60, 4]], s: [[.38, .2, .2, O], [.54, 1, 1], [.62, .9, .9]], end: .62 });
});

G.Knight = { K, ADD, TOKENS, key: 'knight',
  anims: ['k_cape_idle', 'k_cape_run', 'pose_knight', 'sig_knight', 'idle_knight', 't3_knight', 'goal_knight'],
  // every sprite the knight atlas needs (own parts + shared face/tail/head parts it keeps, recoloured)
  sprites() { const sk = A.SKINS.find(s => s.key === 'knight'), used = new Set();
    for (const v in A.RIGS) A.RIGS[v].nodes.forEach(n => { if (!n.sprite || n.sprite === 'fx' || n.sprite === 'ov' || (n.skin && n.skin !== 'knight')) return; used.add(Pip.partFor(sk, v, n.sprite)); });
    return [...used]; }
};
})(typeof window !== 'undefined' ? window : globalThis);
