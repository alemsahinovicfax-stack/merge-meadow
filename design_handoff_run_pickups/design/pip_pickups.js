// Pip · run pickup reactions (top view, OVERLAY layer). Replaces pickup_coin / pickup_seed, adds pickup_seed_rare / pickup_twin.
// Overlay rule (animations.json "layers"): only pip.r / pip.s / head.r / fx / swaps — feet, arms, body, ears stay on run_gallop,
// so a reaction never interrupts the gallop or a lane change (lane_left/right also only touch pip.r / pip.s / head.r: last writer wins for 0.12 s at most).
(function (G) {
'use strict';
const P = G.Pip, def = P.def, O = .5;
def('pickup_coin', .22, { view: 'top', ctx: 'run', layer: 'overlay', desc: 'Coin caught at the nose: squash-pop toward the coin, small head nod, happy blink.', rm: { type: 'expr' } }, b => {
  b.k('pip', 's', [[0, 1, 1], [.05, 1.08, .94, O], [.12, .98, 1.03], [.22, 1, 1]]);
  b.k('head', 'r', [[0, 0], [.05, -6], [.13, 4], [.22, 0]]);
  b.x(0, 'happy', .2, 'determined');
});
def('pickup_seed', .3, { view: 'top', ctx: 'run', layer: 'overlay', desc: 'Seed ★1 caught in the paws and tucked back: pop, head wiggle, joy.', rm: { type: 'expr' } }, b => {
  b.k('pip', 's', [[0, 1, 1], [.07, 1.1, 1.1, O], [.18, .97, .97], [.3, 1, 1]]);
  b.k('head', 'r', [[0, 0], [.07, -8], [.15, 8], [.23, -4], [.3, 0]]);
  b.x(0, 'joy', .28, 'determined');
});
def('pickup_seed_rare', .4, { view: 'top', ctx: 'run', layer: 'overlay', desc: 'Seed ★2 / ★3: bigger pop, whole-body wobble, admiring sparkle eyes.', rm: { type: 'expr' } }, b => {
  b.k('pip', 's', [[0, 1, 1], [.08, 1.16, 1.16, O], [.2, .95, .95], [.3, 1.03, 1.03], [.4, 1, 1]]);
  b.k('pip', 'r', [[0, 0], [.08, -6], [.18, 6], [.3, -2], [.4, 0]]);
  b.k('head', 'r', [[0, 0], [.08, -10], [.18, 10], [.28, -4], [.38, 0]]);
  b.x(0, 'admire', .38, 'determined');
});
def('pickup_twin', .36, { view: 'top', ctx: 'run', layer: 'overlay', desc: 'Twin +2: two quick pops, one per sapling (left, then right), joy.', rm: { type: 'expr' } }, b => {
  b.k('pip', 's', [[0, 1, 1], [.05, 1.08, 1.08, O], [.11, 1, 1], [.17, 1.12, 1.12, O], [.36, 1, 1]]);
  b.k('head', 'r', [[0, 0], [.05, -8], [.11, 0], [.17, 8], [.28, -3], [.36, 0]]);
  b.x(0, 'joy', .34, 'determined');
});
P.PICKUP_ANIMS = ['pickup_coin', 'pickup_seed', 'pickup_seed_rare', 'pickup_twin'];
})(typeof window !== 'undefined' ? window : globalThis);
