// Pip — every animation as data (keys in px of the view frame, degrees, scale factors, Godot transitions)
// + behaviours (behaviors.json). Loaded after pip_art.js and pip_runtime.js.
(function (G) {
'use strict';
const P = G.Pip, A = G.PipArt, def = P.def;
const L = 1, H = 0, O = .5, I = 2, IO = -2, O3 = .33, I3 = 3;
Object.assign(A.EXPR, { yawn: ['blink', 'blink', 'none', 'none', 'o'], blow: ['squint', 'squint_r', 'none', 'none', 'o'], wish: ['blink', 'blink', 'up', 'up', 'smile'], cross: ['open', 'open', 'up', 'up', 'o'] });
A.EXPR.asleep = ['blink', 'blink', 'none', 'none', 'w'];

// helpers ----------------------------------------------------------------
const cat = (...ls) => [].concat(...ls).sort((a, b) => a[0] - b[0]);
const neg = ks => ks.map(k => { const c = k.slice(); c[1] = -c[1]; return c; });           // r keys / p.x
const osc = (t0, amp, per, base) => { per = per || .12; base = base || 0; return [[t0, base], [t0 + per * .5, base + amp], [t0 + per, base - amp * .5], [t0 + per * 1.5, base + amp * .22], [t0 + per * 2, base]]; };
const r2 = v => Math.round(v * 100) / 100;
// sample fn(t) on a grid → linear keys; breaks = times where the value jumps (hold)
function samp(len, step, fn, breaks) {
  const ts = new Set(); for (let t = 0; t <= len + 1e-6; t += step) ts.add(r2(t)); (breaks || []).forEach(b => { ts.add(r2(Math.max(0, b - .01))); ts.add(r2(b)); });
  return [...ts].sort((a, b) => a - b).map(t => [t, ...fn(t).map(r2), L]);
}
const ZERO = n => ({ [n]: 1 });
// FRONT-frame landmarks (root = ground centre): nose ≈ (0,-109), head top ≈ (0,-172), ear_L tip ≈ (-36,-226)
const NOSE = [0, -109], CROWN = [0, -176];

// hop fragment: crouch at t0, leave ground at t0+.1, land at t0+.1+air
function hop(b, t0, h, air, o) {
  o = o || {}; const up = t0 + .1, ap = up + air * .45, dn = up + air;
  b.k('pip', 'p', [[0, 0, 0], [t0, 0, 0], [up, 0, 0, O], [ap, o.dx || 0, -h, I], [dn, o.dx2 || 0, 0], [dn + .3, o.dx2 || 0, 0]]);
  b.k('body', 's', [[0, 1, 1], [t0, 1, 1], [t0 + .08, 1.08, .9], [up, .92, 1.12, O], [ap, 1, 1.03], [dn - .03, .97, 1.06, O], [dn, 1.14, .84, O], [dn + .1, .97, 1.04], [dn + .2, 1, 1]]);
  b.k('foot_L', 'p', [[0, 0, 0], [up, 0, 0], [ap, -3, -7], [dn, 0, 0]]); b.k('foot_R', 'p', [[0, 0, 0], [up, 0, 0], [ap, 3, -7], [dn, 0, 0]]);
  b.k('ear_L', 'r', cat([[0, 0]], osc(up, -12, .16), osc(dn, 10, .16))); b.k('ear_R', 'r', cat([[0, 0]], osc(up, 12, .16), osc(dn, -10, .16)));
  b.k('ear_R_tip', 'r', cat([[0, 0]], osc(up + .04, -24, .2), osc(dn + .04, 18, .2)));
  b.k('head', 'p', [[0, 0, 0], [up, 0, 2], [ap, 0, -3], [dn + .04, 0, 4], [dn + .2, 0, 0]]);
  return dn;
}
function dust(b, node, x, y, t, dir) { b.fx(node, 'dust', { p: [[t, x, y, O], [t + .35, x + 16 * (dir || 1), y - 6]], s: [[t, .5, .5, O], [t + .35, 1.2, 1.2]], a: [[t, 1], [t + .2, 1], [t + .35, 0]] }); }

// ════ SHARED / HOME ════════════════════════════════════════════════════════
const IDLE = b => {
  b.k('body', 's', [[0, 1, 1], [1.6, .99, 1.022], [3.2, 1, 1]]);
  b.k('head', 'p', [[0, 0, 0], [1.75, 0, -1.8], [3.2, 0, 0]]);
  b.k('ear_L', 'r', [[0, 0], [1.9, -2.5], [3.2, 0]]); b.k('ear_R', 'r', [[0, 0], [2.0, 2.5], [3.2, 0]]); b.k('ear_R_tip', 'r', [[0, 0], [2.2, 7], [3.2, 0]]);
  b.k('tail', 'r', [[0, 0], [1.6, 4], [3.2, 0]]);
  b.k('nose', 's', [[0, 1, 1], [.6, 1, 1, L], [.66, 1.12, .84], [.72, 1, 1], [.78, 1.12, .84], [.84, 1, 1], [3.2, 1, 1]]);
  b.x(0, 'neutral', 2.3, 'blink', 2.42, 'neutral');
};
def('idle', 3.2, { loop: true, ctx: 'shared', desc: 'Breathing idle: chest rise, head lag, ear drift, nose twitch, one blink. Base loop on field, card, Arena, Wardrobe stage.', rm: { type: 'expr' } }, IDLE);
def('card_idle', 3.2, { loop: true, ctx: 'home_card', desc: 'Season card (230): same breathing idle, Pip looks at the player.', rm: { type: 'expr' } }, IDLE);
def('stage_idle', 3.2, { loop: true, view: 'three_q', ctx: 'wardrobe', desc: 'Wardrobe stage (1032×300) idle loop in 3/4.', rm: { type: 'expr' } }, IDLE);
def('arena_idle', 3.2, { loop: true, ctx: 'arena', desc: 'Arena idle. Leaves head.rotation and eye position free for look-at.', rm: { type: 'expr' } }, IDLE);
def('hud_idle', 3.2, { loop: true, ctx: 'run_hud', desc: 'HUD portrait (88) idle: breathing + blink.', rm: { type: 'expr' } }, IDLE);

def('idle_look', 2.6, { desc: 'Idle variant: glance left, then right, ears tracking.' }, b => {
  b.k('head', 'r', [[0, 0], [.3, -6, O], [1.1, -6], [1.4, 6, IO], [2.1, 6], [2.6, 0]]);
  b.k('eye_L', 'p', [[0, 0, 0], [.25, -3, 0, O], [1.1, -3, 0], [1.35, 3, 0], [2.1, 3, 0], [2.6, 0, 0]]); b.k('eye_R', 'p', b.tracks.eye_L.p);
  b.k('ear_L', 'r', [[0, 0], [.35, -6], [.5, -3], [1.45, 4], [1.6, 2], [2.6, 0]]); b.k('ear_R', 'r', [[0, 0], [.35, -4], [1.45, 6], [1.6, 3], [2.6, 0]]);
  b.k('ear_R_tip', 'r', [[0, 0], [.4, -10], [.6, 4], [1.5, 10], [1.7, -4], [2.6, 0]]);
  b.x(0, 'curious', .9, 'blink', 1.0, 'curious', 2.3, 'neutral');
});
def('ear_twitch', .7, { desc: 'Idle variant: left ear flicks, folded tip answers a beat later (overlap).' }, b => {
  b.k('ear_L', 'r', [[0, 0], [.06, -14, O], [.14, 6], [.22, -8], [.3, 3], [.45, 0]]); b.k('ear_L', 's', [[0, 1, 1], [.06, 1, .92], [.14, 1, 1]]);
  b.k('ear_R_tip', 'r', [[0, 0], [.1, 0], [.18, -18], [.3, 10], [.42, -4], [.55, 0]]);
});
def('groom', 2.4, { desc: 'Idle variant: grooming — paws scrub the face, eyes shut, head rocks.', rm: { type: 'expr' } }, b => {
  const sc = [[0, 0, 0], [.3, -6, -60, O]]; for (let i = 0; i < 4; i++) sc.push([r2(.48 + i * .35), -2, -66], [r2(.66 + i * .35), -7, -56]); sc.push([2.0, -6, -60], [2.4, 0, 0]);
  b.k('arm_L', 'p', sc); b.k('arm_R', 'p', neg(sc).map(k => [k[0], k[1], k[2]]));
  b.k('arm_L', 'r', [[0, 0], [.3, -20], [2.0, -20], [2.4, 0]]); b.k('arm_R', 'r', [[0, 0], [.3, 20], [2.0, 20], [2.4, 0]]);
  b.k('head', 'r', [[0, 0], [.3, 0], [.6, 6], [1.2, -4], [1.9, 5], [2.4, 0]]); b.k('head', 'p', [[0, 0, 0], [.3, 0, 5], [2.0, 0, 5], [2.4, 0, 0]]);
  b.k('body', 's', [[0, 1, 1], [.3, 1.02, .97], [2.0, 1.02, .97], [2.4, 1, 1]]);
  b.k('ear_L', 'r', [[0, 0], [.6, -8], [1.4, -2], [2.0, -6], [2.4, 0]]); b.k('ear_R', 'r', [[0, 0], [.7, 8], [1.5, 2], [2.0, 6], [2.4, 0]]);
  b.x(0, 'neutral', .32, 'asleep', 2.05, 'happy', 2.35, 'neutral');
});
def('periscope', 2.8, { desc: 'Idle variant: periscoping — rises on hind legs, paws tucked, scans the field.', rm: { type: 'expr' } }, b => {
  b.k('body', 'p', [[0, 0, 0], [.25, 0, 4, O], [.5, 0, -16, O], [2.2, 0, -16], [2.5, 0, 2], [2.8, 0, 0]]);
  b.k('body', 's', [[0, 1, 1], [.25, 1.06, .92], [.5, .94, 1.12], [2.2, .95, 1.1], [2.5, 1.05, .94], [2.8, 1, 1]]);
  b.k('arm_L', 'p', [[0, 0, 0], [.4, 0, 0], [.6, 4, -10], [2.2, 4, -10], [2.5, 0, 0]]); b.k('arm_L', 'r', [[0, 0], [.4, 0], [.6, -20], [2.2, -20], [2.5, 0]]);
  b.k('arm_R', 'p', [[0, 0, 0], [.4, 0, 0], [.6, -4, -10], [2.2, -4, -10], [2.5, 0, 0]]); b.k('arm_R', 'r', [[0, 0], [.4, 0], [.6, 20], [2.2, 20], [2.5, 0]]);
  b.k('head', 'r', [[0, 0], [.6, 0], [1.0, -8], [1.6, -8], [1.9, 8], [2.2, 0]]);
  b.k('eye_L', 'p', [[0, 0, 0], [.95, -3, -1], [1.6, -3, -1], [1.85, 3, -1], [2.2, 0, 0]]); b.k('eye_R', 'p', b.tracks.eye_L.p);
  b.k('ear_L', 'r', [[0, 0], [.5, 8, O], [.7, 3], [2.2, 3], [2.5, -4], [2.8, 0]]); b.k('ear_R', 'r', [[0, 0], [.5, -8, O], [.7, -3], [2.2, -3], [2.5, 4], [2.8, 0]]);
  b.k('ear_R_tip', 'r', [[0, 0], [.5, 0], [.62, -34], [.8, -14], [2.2, -14], [2.45, 8], [2.8, 0]]);
  b.k('nose', 's', [[1.2, 1, 1], [1.26, 1.14, .84], [1.32, 1, 1], [1.38, 1.14, .84], [1.44, 1, 1]]);
  b.x(0, 'neutral', .5, 'curious', 2.4, 'neutral');
});
def('flop', 3.4, { desc: 'Idle variant: the bunny flop — throws itself on its side, blissful, then rights itself.', rm: { type: 'expr' } }, b => {
  b.k('pip', 'r', [[0, 0], [.3, -6, O], [.56, 80, O3], [.64, 74], [.72, 78], [2.6, 78], [3.0, -5], [3.2, 2], [3.4, 0]]);
  b.k('pip', 'p', [[0, 0, 0], [.3, 0, 0], [.56, -14, -44, O3], [2.6, -14, -44], [3.0, 0, 0]]);
  b.k('body', 's', [[0, 1, 1], [.3, 1.04, .95], [.56, 1, 1], [.64, 1.06, .94], [.74, 1, 1], [2.6, 1, 1], [3.05, 1.06, .93], [3.25, 1, 1]]);
  b.k('ear_L', 'r', [[0, 0], [.56, 0], [.68, 26], [.8, 20], [2.6, 20], [3.0, -6], [3.2, 0]]); b.k('ear_R', 'r', [[0, 0], [.56, 0], [.7, 14], [2.6, 14], [3.0, 0]]);
  b.k('ear_R_tip', 'r', [[0, 0], [.6, 0], [.74, 24], [2.6, 24], [3.05, -10], [3.3, 0]]);
  b.k('foot_R', 'r', [[0, 0], [.56, 0], [.7, -24], [2.6, -24], [3.0, 0]]); b.k('foot_L', 'r', [[0, 0], [.56, 0], [.7, -10], [2.6, -10], [3.0, 0]]);
  b.x(0, 'neutral', .3, 'happy', .62, 'asleep', 2.6, 'blink', 2.75, 'happy', 3.3, 'neutral');
});
def('binky', 1.1, { desc: 'Idle variant / joy: binky — leap with a mid-air twist and kick, ears flailing.', rm: { type: 'expr' } }, b => {
  const dn = hop(b, 0, 46, .48);
  b.k('pip', 'r', [[0, 0], [.14, 0], [.28, -14], [.42, 16], [dn, 0]]);
  b.k('head', 'r', [[0, 0], [.2, 0], [.32, 10], [.46, -12], [dn + .04, 0]]);
  b.k('foot_L', 'r', [[0, 0], [.22, 0], [.34, -26], [.48, 0]]); b.k('foot_R', 'r', [[0, 0], [.22, 0], [.34, 26], [.48, 0]]);
  dust(b, 'fx_a', -24, -2, dn, -1); dust(b, 'fx_b', 24, -2, dn, 1);
  b.x(0, 'neutral', .12, 'joy', .8, 'happy', 1.05, 'neutral');
  b.ev(dn, 'sfx:land');
});
def('sniff', 1.6, { desc: 'Sniff a flower (field): lean 7° toward it, head dips, fast nose. Flower bows via SNIFF_BOW.', rm: { type: 'damp', k: .3 } }, b => {
  b.k('pip', 'r', [[0, 0], [.25, 7], [1.3, 7], [1.6, 0]]); b.k('head', 'p', [[0, 0, 0], [.25, 4, 8], [1.3, 4, 8], [1.6, 0, 0]]);
  const n = [[0, 1, 1], [.3, 1, 1, L]]; for (let t = .3; t < 1.2; t += .12) n.push([r2(t + .06), 1.16, .82], [r2(t + .12), 1, 1]); b.k('nose', 's', n);
  b.k('ear_L', 'r', [[0, 0], [.4, 6], [1.3, 6], [1.6, 0]]); b.k('ear_R', 'r', [[0, 0], [.4, 8], [1.3, 8], [1.6, 0]]); b.k('ear_R_tip', 'r', [[0, 0], [.45, 10], [1.3, 10], [1.6, 0]]);
  b.x(0, 'curious', .4, 'happy', 1.4, 'neutral'); b.ev(.35, 'flower_bow');
});
def('sneeze', 1.3, { desc: 'Pollen sneeze: nose builds up, "choo!" jerk, ears flap, puff.', rm: { type: 'expr' } }, b => {
  b.k('head', 'p', [[0, 0, 0], [.15, 0, -2], [.55, 0, -6, I], [.62, 0, 6, O3], [.8, 0, 2], [1.1, 0, 0]]);
  b.k('head', 'r', [[0, 0], [.55, -6, I], [.62, 8, O3], [.85, -2], [1.1, 0]]);
  b.k('body', 's', [[0, 1, 1], [.55, .96, 1.06, I], [.62, 1.1, .88, O3], [.8, .98, 1.02], [1.0, 1, 1]]);
  b.k('nose', 's', [[0, 1, 1], [.1, 1, 1], [.2, 1.15, .8], [.3, 1, 1], [.4, 1.2, .78], [.55, 1.25, .75], [.62, .85, 1.1], [.75, 1, 1]]);
  b.k('ear_L', 'r', cat([[0, 0]], osc(.62, -16, .18))); b.k('ear_R', 'r', cat([[0, 0]], osc(.62, 16, .18))); b.k('ear_R_tip', 'r', cat([[0, 0]], osc(.66, 30, .22)));
  b.fx('fx_a', 'dust', { p: [[.62, 0, -100, O], [1.0, 0, -84]], s: [[.62, .4, .4, O], [1.0, 1.5, 1.5]], a: [[.62, 1], [.8, 1], [1.0, 0]] });
  b.fx('fx_b', 'pollen', { p: [[.62, -10, -108, O], [1.2, -34, -150]], s: [[.62, .8, .8], [1.2, 1.2, 1.2]], a: [[.62, 1], [1.0, 1], [1.2, 0]] });
  b.x(0, 'neutral', .15, 'curious', .4, 'squint', .62, 'sneeze', .95, 'blink', 1.05, 'happy', 1.3, 'neutral'); b.ev(.62, 'sfx:sneeze');
});
def('thump', 1.0, { desc: 'Hind-foot thump (annoyed/alert): foot lifts and slams, dust, body jolts.', rm: { type: 'expr' } }, b => {
  b.k('foot_R', 'p', [[0, 0, 0], [.2, 4, -14, O], [.32, 4, -14], [.38, 0, 1, I3], [.46, 0, 0]]); b.k('foot_R', 'r', [[0, 0], [.2, -20], [.32, -20], [.38, 0]]);
  b.k('body', 's', [[0, 1, 1], [.2, .97, 1.04], [.38, 1.06, .92, O], [.5, 1, 1]]); b.k('body', 'p', [[0, 0, 0], [.38, 0, 0], [.42, 0, 2], [.5, 0, 0]]);
  b.k('pip', 'r', [[0, 0], [.2, -3], [.4, 0]]);
  b.k('ear_L', 'r', cat([[0, 0], [.3, 8]], osc(.38, -10, .14, 8), [[.8, 0]])); b.k('ear_R', 'r', cat([[0, 0], [.3, -8]], osc(.38, 10, .14, -8), [[.8, 0]]));
  dust(b, 'fx_a', 28, -2, .38, 1); dust(b, 'fx_b', 46, -4, .4, 1);
  b.x(0, 'annoyed', .95, 'neutral'); b.ev(.38, 'sfx:thump'); b.ev(.38, 'shake', 4);
});
def('yawn', 2.2, { desc: 'Idle variant: yawn and stretch — arms out, ears long.', rm: { type: 'expr' } }, b => {
  b.k('body', 's', [[0, 1, 1], [.4, 1.04, .95], [1.0, .94, 1.1], [1.6, .94, 1.1], [2.0, 1.02, .98], [2.2, 1, 1]]);
  b.k('head', 'p', [[0, 0, 0], [1.0, 0, -6], [1.6, 0, -6], [2.2, 0, 0]]); b.k('head', 'r', [[0, 0], [.9, -4], [1.7, 4], [2.2, 0]]);
  b.k('arm_L', 'r', [[0, 0], [.6, 0], [1.0, 50], [1.6, 50], [2.0, 0]]); b.k('arm_R', 'r', [[0, 0], [.6, 0], [1.0, -50], [1.6, -50], [2.0, 0]]);
  b.k('ear_L', 's', [[0, 1, 1], [.6, 1, 1], [1.0, 1, 1.08], [1.6, 1, 1.08], [2.0, 1, 1]]); b.k('ear_R', 's', b.tracks.ear_L.s);
  b.x(0, 'neutral', .5, 'sleepy', .85, 'yawn', 1.7, 'sleepy', 2.1, 'neutral');
});
def('admire', 2.2, { desc: 'A new flower grew: gasp, sparkle eyes, paws clasped, happy sway, a heart.', rm: { type: 'expr' } }, b => {
  b.k('pip', 'r', [[0, 0], [.3, 5], [1.8, 5], [2.2, 0]]);
  b.k('body', 's', [[0, 1, 1], [.15, 1.04, .95], [.3, .96, 1.06], [.5, 1, 1]]);
  b.k('arm_L', 'p', [[0, 0, 0], [.3, 9, -6, O], [1.8, 9, -6], [2.2, 0, 0]]); b.k('arm_L', 'r', [[0, 0], [.3, -30], [1.8, -30], [2.2, 0]]);
  b.k('arm_R', 'p', [[0, 0, 0], [.3, -9, -6, O], [1.8, -9, -6], [2.2, 0, 0]]); b.k('arm_R', 'r', [[0, 0], [.3, 30], [1.8, 30], [2.2, 0]]);
  b.k('head', 'r', [[0, 0], [.3, 0], [.6, -6], [1.0, 6], [1.4, -6], [1.8, 0]]);
  b.k('ear_L', 'r', [[0, 0], [.2, 8, O], [1.8, 6], [2.2, 0]]); b.k('ear_R', 'r', [[0, 0], [.2, -8, O], [1.8, -6], [2.2, 0]]); b.k('ear_R_tip', 'r', cat([[0, 0]], osc(.2, -20, .3)));
  b.fx('fx_a', 'heart', { p: [[.5, 22, -170, O], [1.4, 34, -214]], s: [[.5, .3, .3, O], [.7, 1, 1]], a: [[.5, 1], [1.1, 1], [1.4, 0]] });
  b.fx('fx_b', 'sparkle', { p: [[.35, -40, -160]], s: [[.35, .2, .2, O], [.5, 1.1, 1.1], [.8, 0, 0]], end: .8 });
  b.x(0, 'surprised', .3, 'admire', 1.9, 'happy', 2.2, 'neutral'); b.ev(.3, 'flower_admired');
});
// sleep: SLEEP_SQUASH (1.04, .94) + three "z" (2.4 s, stagger .6, flight (34,-90) field px = (46,-121) frame px)
def('sleep', 2.4, { loop: true, desc: 'Sleep loop: squashed loaf, ears down, slow breath, three z (same timing as UiSeasons.SLEEP_ZZZ).', rm: { type: 'expr' } }, b => {
  b.k('body', 's', [[0, 1.04, .94], [1.2, 1.06, .92], [2.4, 1.04, .94]]); b.k('head', 'p', [[0, 0, 7], [1.2, 0, 9], [2.4, 0, 7]]); b.k('head', 'r', [[0, 4]]);
  b.k('ear_L', 'r', [[0, -34], [1.3, -36], [2.4, -34]]); b.k('ear_R', 'r', [[0, 30], [1.3, 32], [2.4, 30]]); b.k('ear_R_tip', 'r', [[0, 22]]);
  ['fx_a', 'fx_b', 'fx_c'].forEach((n, i) => {
    const st = .6 * i, z = t => (((t - st) % 2.4) + 2.4) % 2.4 / 2.4;
    b.k(n, 'v', [[0, 1]]); b.k(n, 'f', [[0, 'zzz']]);
    b.k(n, 'p', samp(2.4, .3, t => { const u = z(t); return [34 + i * 24 + 46 * u, -160 - i * 22 - 121 * u]; }, i ? [st] : []));
    b.k(n, 's', samp(2.4, .3, t => { const v = (.6 + .5 * z(t)) * (1 + i * .23); return [v, v]; }, i ? [st] : []));
    b.k(n, 'a', samp(2.4, .15, t => { const u = z(t); return [u < .25 ? u / .25 : (1 - u) / .75]; }, i ? [st] : []));
  });
  b.x(0, 'asleep');
});
def('fall_asleep', 1.6, { desc: 'Drowsy nod into the sleep loaf.', rm: { type: 'expr' } }, b => {
  b.k('head', 'p', [[0, 0, 0], [.5, 0, 5], [.7, 0, 1], [1.2, 0, 7], [1.6, 0, 7]]); b.k('head', 'r', [[0, 0], [1.2, 4]]);
  b.k('body', 's', [[0, 1, 1], [.8, 1, 1], [1.4, 1.04, .94]]);
  b.k('ear_L', 'r', [[0, 0], [.6, -10], [1.4, -34]]); b.k('ear_R', 'r', [[0, 0], [.6, 10], [1.4, 30]]); b.k('ear_R_tip', 'r', [[0, 0], [1.4, 22]]);
  b.x(0, 'sleepy', .6, 'blink', .7, 'sleepy', 1.1, 'asleep');
});
def('wake', 1.0, { desc: 'Startled awake: ears snap up with overshoot, "!", head shake.', rm: { type: 'expr' } }, b => {
  b.k('body', 's', [[0, 1.04, .94], [.12, .94, 1.1, O], [.3, 1.02, .98], [.5, 1, 1]]); b.k('head', 'p', [[0, 0, 7], [.12, 0, -4], [.4, 0, 0]]);
  b.k('ear_L', 'r', [[0, -34], [.12, 8, O], [.24, -4], [.36, 2], [.5, 0]]); b.k('ear_R', 'r', [[0, 30], [.12, -8, O], [.24, 4], [.36, -2], [.5, 0]]);
  b.k('ear_R_tip', 'r', [[0, 22], [.14, -30, O], [.3, 10], [.46, -4], [.6, 0]]);
  b.k('head', 'r', [[0, 4], [.6, 0], [.68, -6], [.76, 6], [.84, -4], [.92, 0]]);
  b.fx('emote', 'bang', { p: [[.1, 40, -200]], s: [[.1, .3, .3, O], [.22, 1.1, 1.1], [.3, 1, 1]], a: [[.1, 1], [.5, 1], [.62, 0]] });
  b.x(0, 'asleep', .1, 'surprised', .5, 'blink', .6, 'neutral');
});
def('hop', .42, { loop: true, view: 'side', desc: 'Field walk = rabbit hop cycle, 0.42 s (= UiSeasons.PIP_BOB_SEC). Hind feet push, front paws reach, ears drag and whip.', speed_bind: 'field: 1.0 at 95 px/s', rm: { type: 'damp', k: .35 } }, b => {
  b.k('pip', 'p', [[0, 0, 0], [.06, 0, 0, O], [.19, 0, -16, I], [.34, 0, 0], [.42, 0, 0]]);
  b.k('body', 's', [[0, 1.06, .92], [.06, .94, 1.1, O], [.19, 1, 1.03], [.31, .98, 1.05, O], [.34, 1.1, .88, O], [.42, 1.06, .92]]);
  b.k('body', 'r', [[0, 0], [.06, -8], [.19, 0], [.32, 6], [.36, 2], [.42, 0]]);
  b.k('foot_L', 'p', [[0, 0, 0], [.06, -4, 0], [.12, -10, -4], [.26, -8, -8], [.34, 0, 0], [.42, 0, 0]]); b.k('foot_R', 'p', b.tracks.foot_L.p);
  b.k('foot_L', 'r', [[0, 0], [.06, -14], [.2, 10], [.34, 0], [.42, 0]]); b.k('foot_R', 'r', b.tracks.foot_L.r);
  b.k('arm_R', 'p', [[0, 0, 0], [.12, 6, -2], [.26, 10, 2], [.34, 2, 0], [.42, 0, 0]]); b.k('arm_R', 'r', [[0, 0], [.14, -30], [.3, -10], [.42, 0]]);
  b.k('arm_L', 'p', [[0, 0, 0], [.14, 6, -2], [.28, 10, 2], [.36, 2, 0], [.42, 0, 0]]); b.k('arm_L', 'r', [[0, 0], [.16, -30], [.32, -10], [.42, 0]]);
  b.k('head', 'p', [[0, 0, 2], [.08, 0, -1], [.2, 0, -3], [.34, 0, 3], [.42, 0, 2]]);
  b.k('ear_L', 'r', [[0, 2], [.1, -8], [.24, 4], [.34, 8], [.42, 2]]); b.k('ear_R', 'r', [[0, 3], [.12, -8], [.26, 4], [.36, 8], [.42, 3]]);
  b.k('ear_R_tip', 'r', [[0, 6], [.14, -14], [.28, 10], [.38, 14], [.42, 6]]);
  b.k('tail', 'p', [[0, 0, 0], [.2, 0, -2], [.34, 0, 1], [.42, 0, 0]]);
});
// tap reactions — escalate within 3 s
def('tap_giggle', .7, { desc: 'Tap 1: giggle — squash, happy eyes, wiggle, a note.', rm: { type: 'expr' } }, b => {
  b.k('body', 's', [[0, 1, 1], [.06, 1.1, .88, O], [.16, .94, 1.08], [.26, 1.03, .97], [.36, 1, 1]]);
  b.k('pip', 'r', [[0, 0], [.1, 0], [.2, -4], [.3, 4], [.4, -3], [.5, 0]]);
  b.k('ear_L', 'r', cat([[0, 0]], osc(.06, -10, .16))); b.k('ear_R', 'r', cat([[0, 0]], osc(.06, 10, .16))); b.k('ear_R_tip', 'r', cat([[0, 0]], osc(.1, -20, .2)));
  b.fx('emote', 'note', { p: [[.1, 40, -190, O], [.7, 52, -226]], a: [[.1, 1], [.5, 1], [.7, 0]] });
  b.x(0, 'happy', .62, 'neutral');
});
def('tap_hop', 1.0, { desc: 'Tap 2: surprised hop — "!", ears straight up, wide eyes.', rm: { type: 'expr' } }, b => {
  hop(b, 0, 30, .34); b.k('ear_L', 'r', [[0, 0], [.1, 10, O], [.5, 8], [.7, 0]]); b.k('ear_R', 'r', [[0, 0], [.1, -12, O], [.5, -10], [.7, 0]]);
  b.k('ear_R_tip', 'r', [[0, 0], [.1, -50, O], [.5, -40], [.7, 6], [.85, 0]]);
  b.fx('emote', 'bang', { p: [[.05, 42, -206]], s: [[.05, .3, .3, O], [.16, 1.1, 1.1], [.24, 1, 1]], a: [[.05, 1], [.6, 1], [.75, 0]] });
  b.x(0, 'surprised', .7, 'happy', .95, 'neutral');
});
def('tap_huff', 1.4, { desc: 'Tap 3: huff — turns face away, eyes shut, thump.', rm: { type: 'expr' } }, b => {
  b.k('head', 'r', [[0, 0], [.15, -12, O], [1.1, -12], [1.4, 0]]); b.k('head', 'p', [[0, 0, 0], [.15, -6, 0], [1.1, -6, 0], [1.4, 0, 0]]);
  b.k('arm_L', 'p', [[0, 0, 0], [.2, 12, -4], [1.1, 12, -4], [1.4, 0, 0]]); b.k('arm_R', 'p', [[0, 0, 0], [.2, -12, -2], [1.1, -12, -2], [1.4, 0, 0]]);
  b.k('foot_R', 'p', [[0, 0, 0], [.5, 4, -14, O], [.62, 4, -14], [.68, 0, 1, I3], [.76, 0, 0]]);
  b.k('body', 's', [[0, 1, 1], [.68, 1.06, .92, O], [.8, 1, 1]]);
  b.k('ear_L', 'r', [[0, 0], [.2, -14], [1.1, -14], [1.4, 0]]); b.k('ear_R', 'r', [[0, 0], [.2, 4], [1.1, 4], [1.4, 0]]);
  dust(b, 'fx_a', 30, -2, .68, 1);
  b.x(0, 'annoyed', .2, 'blink', 1.2, 'annoyed', 1.38, 'neutral'); b.ev(.68, 'sfx:thump');
});
def('tap_flop', 2.6, { desc: 'Tap 4+: dramatic faint — swoons over, peeks with one eye, gets up.', rm: { type: 'expr' } }, b => {
  b.k('pip', 'r', [[0, 0], [.25, 6, O], [.6, -82, I], [.68, -76], [.76, -80], [1.9, -80], [2.3, 4], [2.45, -2], [2.6, 0]]);
  b.k('pip', 'p', [[0, 0, 0], [.25, 0, 0], [.6, 14, -44, O3], [1.9, 14, -44], [2.3, 0, 0]]);
  b.k('ear_L', 'r', [[0, 0], [.6, 0], [.74, -20], [1.9, -20], [2.3, 0]]); b.k('ear_R_tip', 'r', [[0, 0], [.62, 0], [.78, -30], [1.9, -30], [2.4, 0]]);
  b.k('arm_L', 'r', [[0, 0], [.2, -160, O], [.6, -150], [.8, -40], [1.9, -40], [2.3, 0]]);
  b.x(0, 'dizzy', .62, 'asleep', 1.3, 'wink', 1.7, 'asleep', 2.0, 'happy', 2.55, 'neutral');
});
def('apply', .56, { ctx: 'home_field', desc: 'ApplyMoment (Wardrobe): hop in the new skin 1→1.18→1, 280 ms after 40 ms, feet pivot, + cream ring 90→220 field px / 500 ms (UiWardrobe).', rm: { type: 'expr' } }, b => {
  b.k('pip', 'p', [[0, 0, 0], [.04, 0, 0, O], [.18, 0, -38, I], [.32, 0, 0]]);
  b.k('pip', 's', [[0, 1, 1], [.04, 1, 1, O], [.18, 1.18, 1.18, I], [.32, 1, 1]]);
  b.k('body', 's', [[0, 1, 1], [.04, 1.06, .92], [.1, .94, 1.08], [.3, 1, 1], [.34, 1.1, .9], [.46, 1, 1]]);
  b.k('ear_R_tip', 'r', cat([[0, 0]], osc(.1, -30, .2), osc(.34, 16, .18)));
  b.fx('fx_ring', 'ring', { p: [[.04, 0, 0]], s: [[.04, 1.21, 1.21, O3], [.54, 2.96, 2.96]], a: [[.04, 1], [.54, 0]] });
  b.fx('fx_a', 'sparkle', { p: [[.12, -60, -150]], s: [[.12, .2, .2, O], [.26, 1, 1], [.46, 0, 0]], end: .46 });
  b.fx('fx_b', 'sparkle', { p: [[.18, 58, -180]], s: [[.18, .2, .2, O], [.32, .8, .8], [.5, 0, 0]], end: .5 });
  b.x(0, 'neutral', .06, 'admire', .5, 'happy');
});
def('greet', 1.4, { ctx: 'home', desc: 'Welcome back: happy bounce, paw wave, ear perk.', rm: { type: 'expr' } }, b => {
  b.k('pip', 'p', [[0, 0, 0], [.06, 0, 0, O], [.18, 0, -14, I], [.3, 0, 0]]); b.k('body', 's', [[0, 1, 1], [.06, 1.06, .92], [.14, .95, 1.06], [.3, 1.08, .92], [.42, 1, 1]]);
  b.k('arm_R', 'r', [[0, 0], [.25, -150, O], [.45, -118], [.65, -150], [.85, -118], [1.05, -150], [1.3, 0]]); b.k('arm_R', 'p', [[0, 0, 0], [.25, 2, -8], [1.05, 2, -8], [1.3, 0, 0]]);
  b.k('head', 'r', [[0, 0], [.3, 6], [1.1, 6], [1.4, 0]]);
  b.k('ear_L', 'r', [[0, 0], [.2, 8, O], [1.1, 6], [1.4, 0]]); b.k('ear_R_tip', 'r', cat([[0, 0]], osc(.25, -24, .3)));
  b.x(0, 'joy', .5, 'happy', 1.35, 'neutral');
});
def('card_jump', .7, { ctx: 'home_card', desc: 'Season card → field: crouch, leap (code moves the box along the Home v3 path), land.', rm: { type: 'expr' } }, b => {
  hop(b, 0, 54, .42); b.x(0, 'determined', .14, 'joy', .66, 'happy');
});

// ════ SEASON INTERACTIONS (each brings its own prop on node prop / prop2) ═══════════════
const flap = (t0, t1) => samp(t1 - t0, .08, t => [Math.round(t / .08) % 2 ? .45 : 1, 1]).map(k => [r2(k[0] + t0), k[1], k[2], H]);
def('cb_butterfly', 3.2, { ctx: 'season:country_bloom', desc: 'A butterfly lands on Pip\'s nose → cross-eyed → sneeze → it flutters off.', rm: { type: 'expr', fx: true } }, b => {
  b.fx('prop', 'butterfly', { p: [[0, 110, -230, IO], [.6, 60, -180], [1.2, 0, -116, O], [2.0, 0, -116], [2.1, 0, -126, O], [2.9, -110, -250]], s: flap(0, 3.0), end: 3.0 });
  b.k('eye_L', 'p', [[0, 0, 0], [.4, 3, -2], [1.2, 3, 2], [2.0, 3, 2], [2.2, 0, 0]]); b.k('eye_R', 'p', [[0, 0, 0], [.4, 3, -2], [1.2, -3, 2], [2.0, -3, 2], [2.2, 0, 0]]);
  b.k('head', 'r', [[0, 0], [.4, 5], [1.2, 0], [1.9, -5, I], [2.0, 8, O3], [2.3, 0]]); b.k('head', 'p', [[0, 0, 0], [1.9, 0, -4, I], [2.0, 0, 6, O3], [2.3, 0, 0]]);
  b.k('nose', 's', [[0, 1, 1], [1.3, 1, 1], [1.4, 1.2, .8], [1.5, 1, 1], [1.6, 1.25, .76], [1.9, 1.3, .74], [2.0, .85, 1.1], [2.1, 1, 1]]);
  b.k('ear_L', 'r', cat([[0, 0]], osc(2.0, -16, .2))); b.k('ear_R_tip', 'r', cat([[0, 0]], osc(2.0, 30, .24)));
  b.x(0, 'curious', 1.2, 'cross', 1.6, 'squint', 2.0, 'sneeze', 2.3, 'blink', 2.4, 'happy', 3.1, 'neutral'); b.ev(2.0, 'sfx:sneeze');
});
def('cb_dandelion', 3.0, { ctx: 'season:country_bloom', desc: 'Finds a dandelion clock, big breath, blows — five seeds drift off.', rm: { type: 'expr', fx: true } }, b => {
  b.fx('prop', 'dandelion', { p: [[0, 46, -34]], s: [[0, .2, .2, O], [.3, 1, 1]], a: [[0, 1], [2.6, 1], [3.0, 0]], end: 3.0 });
  b.k('pip', 'r', [[0, 0], [.4, 6], [2.4, 6], [2.8, 0]]);
  b.k('body', 's', [[0, 1, 1], [.6, 1, 1], [1.2, 1.07, 1.03, I], [1.45, .95, .98, O], [2.0, 1, 1]]);
  ['fx_a', 'fx_b', 'fx_c', 'fx_d', 'fx_e'].forEach((n, i) => b.fx(n, 'seedfluff', { p: [[1.4, 44, -48 - i * 4, O], [2.8, 110 + i * 22, -110 - i * 34]], r: [[1.4, 0], [2.8, (i % 2 ? 1 : -1) * 40]], a: [[1.4, 1], [2.4, 1], [2.8, 0]] }));
  b.x(0, 'curious', .6, 'happy', 1.1, 'blow', 1.9, 'happy', 2.9, 'neutral'); b.ev(1.4, 'sfx:blow');
});
def('fo_snowflake', 2.6, { ctx: 'season:frost_orchard', desc: 'Catches a falling snowflake on its tongue, shivers, grins.', rm: { type: 'expr', fx: true } }, b => {
  b.fx('prop', 'snowflake', { p: samp(1.6, .1, t => [Math.sin(t * 5) * 14, -270 + t / 1.6 * 168]), r: [[0, 0], [1.6, 160]], end: 1.6 });
  b.k('head', 'p', [[0, 0, 0], [.6, 0, -6], [1.6, 0, -6], [1.8, 0, 0]]); b.k('eye_L', 'p', [[0, 0, 0], [.4, 0, -3], [1.4, 0, -2], [1.7, 0, 0]]); b.k('eye_R', 'p', b.tracks.eye_L.p);
  b.k('body', 's', cat([[0, 1, 1], [1.6, 1, 1]], samp(.5, .05, t => [1 + (Math.round(t / .05) % 2 ? .03 : -.02), 1]).map(k => [r2(k[0] + 1.62), k[1], k[2], L]), [[2.2, 1, 1]]));
  b.x(0, 'curious', .9, 'cross', 1.2, 'wink', 1.62, 'squint', 2.1, 'happy', 2.55, 'neutral'); b.ev(1.6, 'caught');
});
def('fo_shake', 2.4, { ctx: 'season:frost_orchard', desc: 'A clump of snow drops on its head; Pip shakes it off like a wet dog.', rm: { type: 'expr', fx: true } }, b => {
  b.fx('prop', 'snowclump', { p: [[0, 0, -320, I], [.4, 0, -180], [1.1, 0, -180, O], [1.5, 70, -150]], r: [[1.1, 0], [1.5, 80]], a: [[0, 1], [1.2, 1], [1.5, 0]], end: 1.5 });
  b.k('body', 's', [[0, 1, 1], [.4, 1.1, .86, O], [.6, 1, 1]]); b.k('head', 'p', [[0, 0, 0], [.4, 0, 8], [.9, 0, 6], [1.0, 0, 0]]);
  b.k('pip', 'r', cat([[0, 0], [1.0, 0]], samp(.6, .06, t => [Math.round(t / .06) % 2 ? 8 : -8]).map(k => [r2(k[0] + 1.0), k[1], L]), [[1.7, 0]]));
  b.k('ear_L', 'r', cat([[0, 0], [.4, -26], [1.0, -26]], osc(1.1, 24, .2), [[1.8, 0]])); b.k('ear_R', 'r', cat([[0, 0], [.4, 22], [1.0, 22]], osc(1.1, -24, .2), [[1.8, 0]]));
  ['fx_a', 'fx_b', 'fx_c'].forEach((n, i) => b.fx(n, 'snowflake', { p: [[1.1, -10 + i * 10, -170, O], [1.6, -70 + i * 70, -210 + i * 10]], s: [[1.1, .7, .7]], a: [[1.1, 1], [1.6, 0]] }));
  b.x(0, 'neutral', .4, 'squint', .9, 'surprised', 1.0, 'squint', 1.7, 'happy', 2.35, 'neutral');
});
def('lm_firefly', 3.4, { ctx: 'season:lantern_meadow', desc: 'A firefly circles Pip\'s head (eyes follow), lands on the nose, gets a boop, floats away.', rm: { type: 'expr', fx: true } }, b => {
  const path = t => t < 2.0 ? [Math.cos(t * 3.2) * 70, -150 + Math.sin(t * 3.2) * 34] : t < 2.4 ? [0, -118] : [(t - 2.4) * 60, -118 - (t - 2.4) * 140];
  b.fx('prop', 'firefly', { p: samp(3.3, .1, path), end: 3.3 });
  b.k('eye_L', 'p', samp(2.4, .1, t => t < 2.0 ? [Math.cos(t * 3.2) * 3, Math.sin(t * 3.2) * 2] : [3, 2])); b.k('eye_R', 'p', samp(2.4, .1, t => t < 2.0 ? [Math.cos(t * 3.2) * 3, Math.sin(t * 3.2) * 2] : [-3, 2]));
  b.k('head', 'p', [[0, 0, 0], [2.4, 0, 0], [2.5, 0, -6, O], [2.65, 0, 0]]);
  b.x(0, 'curious', 2.0, 'cross', 2.5, 'joy', 3.3, 'neutral');
});
def('lm_eartip', 3.0, { ctx: 'season:lantern_meadow', desc: 'A firefly settles on the tip of the tall ear; Pip goes cross-eyed, holds still, then flicks it off.', rm: { type: 'expr', fx: true } }, b => {
  b.fx('prop', 'firefly', { p: [[0, -110, -260, O], [1.0, -38, -232], [2.2, -38, -232], [2.3, -50, -250, O], [3.0, -120, -300]], end: 3.0 });
  b.k('eye_L', 'p', [[0, 0, 0], [.5, -3, -3], [2.2, -3, -3], [2.5, 0, 0]]); b.k('eye_R', 'p', b.tracks.eye_L.p); b.k('head', 'r', [[0, 0], [.6, -6], [2.2, -6], [2.5, 0]]);
  b.k('ear_L', 'r', [[0, 0], [2.2, 0], [2.26, -14, O], [2.34, 6], [2.44, -3], [2.6, 0]]);
  b.x(0, 'curious', 1.0, 'admire', 2.2, 'surprised', 2.5, 'happy', 2.95, 'neutral');
});
def('ac_leafhat', 3.2, { ctx: 'season:amber_canopy', desc: 'A falling leaf lands on Pip\'s head; Pip wears it proudly until it slides off.', rm: { type: 'expr', fx: true } }, b => {
  b.fx('prop', 'leaf', { p: cat(samp(1.4, .1, t => [40 - t * 30 + Math.sin(t * 6) * 18, -300 + t / 1.4 * 122]), [[2.4, -2, -178, I], [3.0, 60, -100]]), r: [[0, 40], [.7, -30], [1.4, 18], [2.4, 18], [3.0, 90]], a: [[0, 1], [2.8, 1], [3.0, 0]], end: 3.0 });
  b.k('body', 's', [[0, 1, 1], [1.4, 1.04, .95], [1.6, .96, 1.06], [2.3, .96, 1.06], [2.6, 1, 1]]); b.k('head', 'r', [[0, 0], [2.3, 0], [2.6, 10], [3.0, 0]]);
  b.k('eye_L', 'p', [[0, 0, 0], [.4, 0, -3], [1.4, 0, -3], [1.6, 0, 0]]); b.k('eye_R', 'p', b.tracks.eye_L.p);
  b.x(0, 'curious', 1.4, 'surprised', 1.6, 'proud', 2.6, 'surprised', 3.1, 'neutral');
});
def('ac_acorn', 2.6, { ctx: 'season:amber_canopy', desc: 'An acorn bonks Pip on the head, bounces away; Pip winces, then sniffs it curiously.', rm: { type: 'expr', fx: true } }, b => {
  b.fx('prop', 'acorn', { p: [[0, -6, -320, I], [.5, 0, -182, O], [.8, 40, -210, I], [1.15, 60, -10, O], [1.4, 72, -8]], r: [[0, 0], [.5, 0], [1.4, 260]], end: 2.6 });
  b.k('body', 's', [[0, 1, 1], [.5, 1.1, .86, O], [.7, 1, 1]]); b.k('head', 'p', [[0, 0, 0], [.5, 0, 8], [.7, 0, 0]]);
  b.k('ear_L', 'r', [[0, 0], [.5, -20], [1.0, -20], [1.3, 0]]); b.k('ear_R', 'r', [[0, 0], [.5, 18], [1.0, 18], [1.3, 0]]);
  b.k('pip', 'r', [[0, 0], [1.4, 0], [1.7, 6], [2.3, 6], [2.6, 0]]); b.k('eye_L', 'p', [[0, 0, 0], [1.2, 3, 2], [2.3, 3, 2], [2.6, 0, 0]]); b.k('eye_R', 'p', b.tracks.eye_L.p);
  b.k('nose', 's', [[1.7, 1, 1], [1.78, 1.16, .82], [1.86, 1, 1], [1.94, 1.16, .82], [2.02, 1, 1]]);
  b.fx('fx_a', 'star', { p: [[.5, 18, -190, O], [.9, 30, -214]], s: [[.5, .4, .4, O], [.65, 1, 1]], a: [[.5, 1], [.9, 0]] });
  b.x(0, 'neutral', .5, 'squint', 1.1, 'curious', 2.0, 'happy', 2.55, 'neutral'); b.ev(.5, 'sfx:bonk');
});
def('mw_burrow', 3.4, { ctx: 'season:moonlit_warren', desc: 'Pip digs at its own little burrow: leans in, tail wiggling, flings dirt, pops up proud.', rm: { type: 'expr', fx: true } }, b => {
  b.fx('prop2', 'burrow', { p: [[0, 70, 0]], s: [[0, .3, .3, O], [.3, 1, 1], [3.0, 1, 1], [3.4, .3, .3]], end: 3.4 });
  b.k('pip', 'r', [[0, 0], [.4, 0], [.7, 22, O], [2.4, 22], [2.7, -4], [2.9, 0]]); b.k('pip', 'p', [[0, 0, 0], [.4, 0, 0], [.7, 30, 0], [2.4, 30, 0], [2.7, 0, 0]]);
  b.k('head', 'p', [[0, 0, 0], [.7, 0, 0], [.9, 6, 12], [2.4, 6, 12], [2.6, 0, 0]]);
  const dig = [[0, 0], [.9, 0]]; for (let i = 0; i < 6; i++) dig.push([r2(1.0 + i * .22), -60], [r2(1.11 + i * .22), 10]); dig.push([2.5, 0]); b.k('arm_R', 'r', dig); b.k('arm_L', 'r', dig.map(k => [r2(k[0] + .1), k[1]]));
  b.k('tail', 'r', cat([[0, 0]], samp(1.2, .1, t => [Math.round(t / .1) % 2 ? 14 : -14]).map(k => [r2(k[0] + 1.0), k[1], L]), [[2.4, 0]]));
  ['fx_a', 'fx_b', 'fx_c'].forEach((n, i) => b.fx(n, 'dirt', { p: [[1.1 + i * .4, 80, -6, O], [1.5 + i * .4, 40 - i * 30, -90 - i * 10]], r: [[1.1 + i * .4, 0], [1.5 + i * .4, 120]], a: [[1.1 + i * .4, 1], [1.5 + i * .4, 0]] }));
  b.x(0, 'curious', .9, 'blink', 2.4, 'proud', 3.3, 'neutral');
});
def('mw_moon', 3.4, { ctx: 'season:moonlit_warren', desc: 'Periscopes to gaze at the moon; three stars twinkle for Pip.', rm: { type: 'expr', fx: true } }, b => {
  const pr = P.ANIMS.periscope.tracks; ['body', 'arm_L', 'arm_R', 'ear_L', 'ear_R', 'ear_R_tip'].forEach(n => Object.keys(pr[n]).forEach(q => b.k(n, q, pr[n][q])));
  b.k('head', 'r', [[0, 0], [.6, -6], [2.2, -6], [2.6, 0]]); b.k('eye_L', 'p', [[0, 0, 0], [.6, 0, -3], [2.2, 0, -3], [2.6, 0, 0]]); b.k('eye_R', 'p', b.tracks.eye_L.p);
  [[-70, -250, .7], [70, -268, 1.1], [16, -296, 1.5]].forEach(([x, y, t], i) => b.fx(['fx_a', 'fx_b', 'fx_c'][i], 'sparkle', { p: [[t, x, y]], s: [[t, .2, .2, O], [t + .2, 1, 1], [t + .5, .6, .6], [t + .9, 0, 0]], end: t + .9 }));
  b.x(0, 'neutral', .5, 'admire', 2.4, 'happy', 3.3, 'neutral');
});
def('ct_bubble', 2.8, { ctx: 'season:coral_tide', desc: 'A sea bubble wobbles up; Pip watches, boops it with the nose — pop!', rm: { type: 'expr', fx: true } }, b => {
  b.fx('prop', 'bubble', { p: samp(1.8, .1, t => [-70 + t / 1.8 * 62 + Math.sin(t * 5) * 8, -10 - t / 1.8 * 104]), s: cat(samp(1.8, .15, t => [1 + Math.sin(t * 9) * .08, 1 - Math.sin(t * 9) * .08]), [[1.86, 1.5, 1.5, O]]), a: [[0, 1], [1.8, 1], [1.88, 0]], end: 1.9 });
  b.k('eye_L', 'p', samp(1.8, .2, t => [-3 + t / 1.8 * 3, 2 - t / 1.8 * 2])); b.k('eye_R', 'p', b.tracks.eye_L.p);
  b.k('head', 'p', [[0, 0, 0], [1.6, 0, 0], [1.8, -6, 2, O], [2.0, 0, 0]]); b.k('pip', 'r', [[0, 0], [1.6, 0], [1.8, -5], [2.1, 0]]);
  ['fx_a', 'fx_b', 'fx_c', 'fx_d'].forEach((n, i) => { const a = i * Math.PI / 2 + .6; b.fx(n, 'sparkle', { p: [[1.84, -8, -114, O], [2.2, -8 + Math.cos(a) * 40, -114 + Math.sin(a) * 40]], s: [[1.84, .5, .5], [2.2, 0, 0]], end: 2.2 }); });
  b.x(0, 'curious', 1.84, 'surprised', 2.1, 'joy', 2.75, 'neutral'); b.ev(1.84, 'sfx:pop');
});
def('ct_shell', 3.2, { ctx: 'season:coral_tide', desc: 'A seashell appears; Pip tilts its head and listens to the sea, eyes closed, notes rising.', rm: { type: 'expr', fx: true } }, b => {
  b.fx('prop', 'shell', { p: [[0, 54, -12]], s: [[0, .2, .2, O], [.3, 1, 1]], a: [[0, 1], [2.9, 1], [3.2, 0]], end: 3.2 });
  b.k('pip', 'r', [[0, 0], [.5, 10], [2.6, 10], [3.0, 0]]); b.k('head', 'r', [[0, 0], [.5, 14], [2.6, 14], [3.0, 0]]);
  b.k('ear_L', 'r', [[0, 0], [.6, 8], [2.6, 8], [3.0, 0]]); b.k('ear_R', 'r', [[0, 0], [.6, 14], [2.6, 14], [3.0, 0]]);
  b.fx('fx_a', 'note', { p: [[1.0, 58, -40, O], [2.0, 70, -130]], a: [[1.0, 1], [1.7, 1], [2.0, 0]] });
  b.fx('fx_b', 'note', { p: [[1.6, 50, -40, O], [2.6, 34, -140]], a: [[1.6, 1], [2.3, 1], [2.6, 0]] });
  b.x(0, 'curious', .7, 'asleep', 2.7, 'happy', 3.15, 'neutral');
});
def('sg_wish', 3.4, { ctx: 'season:starfall_glade', desc: 'A meteor streaks by; Pip gasps, clasps paws, closes eyes and makes a wish.', rm: { type: 'expr', fx: true } }, b => {
  b.fx('prop', 'meteor', { p: [[.1, -150, -310, L], [.9, 140, -230]], a: [[.1, 1], [.7, 1], [.9, 0]], end: .9 });
  b.k('eye_L', 'p', [[0, 0, 0], [.2, -3, -3], [.9, 3, -2], [1.2, 0, 0]]); b.k('eye_R', 'p', b.tracks.eye_L.p);
  b.k('arm_L', 'p', [[0, 0, 0], [1.1, 0, 0], [1.3, 10, -8, O], [2.6, 10, -8], [2.9, 0, 0]]); b.k('arm_L', 'r', [[0, 0], [1.1, 0], [1.3, -34], [2.6, -34], [2.9, 0]]);
  b.k('arm_R', 'p', [[0, 0, 0], [1.1, 0, 0], [1.3, -10, -8, O], [2.6, -10, -8], [2.9, 0, 0]]); b.k('arm_R', 'r', [[0, 0], [1.1, 0], [1.3, 34], [2.6, 34], [2.9, 0]]);
  b.k('head', 'p', [[0, 0, 0], [1.3, 0, 4], [2.6, 0, 4], [2.9, 0, 0]]); b.k('ear_L', 'r', [[0, 0], [1.3, -6], [2.6, -6], [2.9, 0]]); b.k('ear_R', 'r', [[0, 0], [1.3, 6], [2.6, 6], [2.9, 0]]);
  b.fx('fx_a', 'sparkle', { p: [[2.3, 0, -230]], s: [[2.3, .2, .2, O], [2.5, 1.2, 1.2], [3.0, 0, 0]], end: 3.0 });
  b.x(0, 'neutral', .2, 'surprised', 1.2, 'wish', 2.7, 'joy', 3.35, 'neutral');
});
def('sg_petal', 3.0, { ctx: 'season:starfall_glade', desc: 'A star petal drifts down; Pip cups its paws and catches it, it glows, then floats back up.', rm: { type: 'expr', fx: true } }, b => {
  b.fx('prop', 'starpetal', { p: cat(samp(1.8, .1, t => [Math.sin(t * 4) * 30, -290 + t / 1.8 * 230]), [[2.4, 0, -60, O], [3.0, 20, -240]]), s: [[1.8, 1, 1], [2.0, 1.3, 1.3], [2.2, 1, 1], [2.4, 1.3, 1.3]], a: [[0, 1], [2.7, 1], [3.0, 0]], end: 3.0 });
  b.k('eye_L', 'p', [[0, 0, 0], [.4, 0, -3], [1.4, 0, 3], [2.4, 0, 3], [2.8, 0, -2]]); b.k('eye_R', 'p', b.tracks.eye_L.p);
  b.k('arm_L', 'p', [[0, 0, 0], [1.2, 0, 0], [1.4, 8, -6], [2.4, 8, -6], [2.7, 0, 0]]); b.k('arm_L', 'r', [[0, 0], [1.2, 0], [1.4, -40], [2.4, -40], [2.7, 0]]);
  b.k('arm_R', 'p', [[0, 0, 0], [1.2, 0, 0], [1.4, -8, -6], [2.4, -8, -6], [2.7, 0, 0]]); b.k('arm_R', 'r', [[0, 0], [1.2, 0], [1.4, 40], [2.4, 40], [2.7, 0]]);
  b.k('head', 'p', [[0, 0, 0], [1.4, 0, 4], [2.4, 0, 4], [2.7, 0, 0]]);
  b.x(0, 'curious', 1.8, 'admire', 2.5, 'happy', 2.95, 'neutral');
});
def('ef_smoke', 2.8, { ctx: 'season:ember_fen', desc: 'A drift of marsh smoke reaches Pip; three little coughs, a paw waves it away.', rm: { type: 'expr', fx: true } }, b => {
  b.fx('prop', 'smoke', { p: [[0, -130, -130, O], [1.0, -16, -116], [1.6, -26, -126], [2.6, -110, -170]], s: [[0, .6, .6], [1.0, 1.4, 1.4], [2.6, 2, 2]], a: [[0, 0], [.3, 1], [1.8, 1], [2.6, 0]], end: 2.6 });
  b.k('body', 's', [[0, 1, 1], [1.05, 1, 1], [1.1, 1.06, .92, O], [1.22, 1, 1], [1.35, 1.06, .92, O], [1.47, 1, 1], [1.6, 1.06, .92, O], [1.72, 1, 1]]);
  b.k('head', 'p', [[0, 0, 0], [1.1, 0, 4], [1.22, 0, 0], [1.35, 0, 4], [1.47, 0, 0], [1.6, 0, 4], [1.72, 0, 0]]);
  b.k('arm_L', 'r', [[0, 0], [1.6, 0], [1.75, -150, O], [1.9, -110], [2.05, -150], [2.2, -110], [2.5, 0]]);
  b.x(0, 'neutral', .8, 'squint', 1.8, 'annoyed', 2.5, 'neutral'); b.ev(1.1, 'sfx:cough');
});
def('ef_ember', 3.0, { ctx: 'season:ember_fen', desc: 'A warm ember floats up; Pip holds its paws out to it, cosy sway, it drifts away.', rm: { type: 'expr', fx: true } }, b => {
  b.fx('prop', 'ember', { p: [[0, 50, -10, O], [1.0, 0, -60], [2.3, 0, -64], [3.0, 30, -220]], s: samp(2.3, .1, t => { const v = 1 + Math.sin(t * 14) * .12; return [v, v]; }), a: [[0, 1], [2.7, 1], [3.0, 0]], end: 3.0 });
  b.k('arm_L', 'p', [[0, 0, 0], [.9, 0, 0], [1.1, 10, -10], [2.3, 10, -10], [2.6, 0, 0]]); b.k('arm_L', 'r', [[0, 0], [.9, 0], [1.1, -60], [2.3, -60], [2.6, 0]]);
  b.k('arm_R', 'p', [[0, 0, 0], [.9, 0, 0], [1.1, -10, -10], [2.3, -10, -10], [2.6, 0, 0]]); b.k('arm_R', 'r', [[0, 0], [.9, 0], [1.1, 60], [2.3, 60], [2.6, 0]]);
  b.k('pip', 'r', [[0, 0], [1.1, 0], [1.5, -3], [1.9, 3], [2.3, 0]]); b.k('eye_L', 'p', [[0, 0, 0], [.6, 0, 3], [2.3, 0, 3], [2.6, 0, -3], [3.0, 0, 0]]); b.k('eye_R', 'p', b.tracks.eye_L.p);
  b.x(0, 'curious', 1.1, 'happy', 2.9, 'neutral');
});

// ════ ARENA ═══════════════════════════════════════════════════════════════
def('merge_t2', .6, { ctx: 'arena', desc: 'Merge to ★2: small happy hop.', rm: { type: 'expr' } }, b => { hop(b, 0, 22, .25); b.x(0, 'happy', .55, 'neutral'); });
def('merge_t3', 1.1, { ctx: 'arena', desc: 'Merge to ★3: full binky, sparkles.', rm: { type: 'expr' } }, b => {
  const dn = hop(b, 0, 46, .48); b.k('pip', 'r', [[0, 0], [.14, 0], [.28, -14], [.42, 16], [dn, 0]]);
  b.fx('fx_a', 'sparkle', { p: [[.2, -60, -170]], s: [[.2, .2, .2, O], [.35, 1.1, 1.1], [.7, 0, 0]], end: .7 });
  b.fx('fx_b', 'star', { p: [[.3, 60, -190]], s: [[.3, .2, .2, O], [.45, 1, 1], [.8, 0, 0]], end: .8 });
  b.x(0, 'joy', .9, 'happy', 1.05, 'neutral');
});
def('combo_hop', .28, { ctx: 'arena', layer: 'overlay', desc: 'Combo ×2–4, ×6: COMBO_PIP.hop 1.18 / 0.28 s (pivot feet) — overlay on idle.', rm: { type: 'expr' } }, b => {
  b.k('pip', 's', [[0, 1, 1, O], [.126, 1.18, 1.18, I], [.28, 1, 1]]); b.x(0, 'happy', .27, 'neutral');
});
def('combo_big', .36, { ctx: 'arena', layer: 'overlay', desc: 'Combo ×5: COMBO_PIP.big 1.26 / 0.36 s + lift.', rm: { type: 'expr' } }, b => {
  b.k('pip', 's', [[0, 1, 1, O], [.16, 1.26, 1.26, I], [.36, 1, 1]]); b.k('pip', 'p', [[0, 0, 0, O], [.16, 0, -18, I], [.36, 0, 0]]); b.x(0, 'joy', .35, 'neutral');
});
def('muncher_wake', 1.0, { ctx: 'arena', desc: 'Muncher wakes: Pip startles, ears bolt upright, "!".', rm: { type: 'expr' } }, b => {
  b.k('body', 's', [[0, 1, 1], [.08, 1.06, .92], [.18, .94, 1.1, O], [.4, 1, 1]]);
  b.k('ear_L', 'r', [[0, 0], [.16, 10, O], [.3, 6], [.8, 6], [1.0, 0]]); b.k('ear_R', 'r', [[0, 0], [.16, -12, O], [.3, -8], [.8, -8], [1.0, 0]]);
  b.k('ear_R_tip', 'r', [[0, 0], [.16, -60, O], [.32, -40], [.8, -40], [1.0, 0]]);
  b.fx('emote', 'bang', { p: [[.08, 42, -206]], s: [[.08, .3, .3, O], [.2, 1.1, 1.1], [.28, 1, 1]], a: [[.08, 1], [.8, 1], [.95, 0]] });
  b.x(0, 'surprised', .7, 'worried');
});
def('muncher_eat', 1.4, { ctx: 'arena', desc: 'Muncher eats a seed: worried, paws to chest, trembling, sweat drop.', rm: { type: 'expr' } }, b => {
  b.k('arm_L', 'p', [[0, 0, 0], [.2, 10, -8], [1.2, 10, -8], [1.4, 0, 0]]); b.k('arm_R', 'p', [[0, 0, 0], [.2, -10, -8], [1.2, -10, -8], [1.4, 0, 0]]);
  b.k('arm_L', 'r', [[0, 0], [.2, -30], [1.2, -30], [1.4, 0]]); b.k('arm_R', 'r', [[0, 0], [.2, 30], [1.2, 30], [1.4, 0]]);
  b.k('body', 's', [[0, 1, 1], [.2, .97, .96], [1.2, .97, .96], [1.4, 1, 1]]); b.k('head', 'p', [[0, 0, 0], [.2, 0, 4], [1.2, 0, 4], [1.4, 0, 0]]);
  b.k('pip', 'p', cat([[0, 0, 0]], samp(1.0, .05, t => [Math.round(t / .05) % 2 ? 1.5 : -1.5, 0]).map(k => [r2(k[0] + .2), k[1], k[2], L]), [[1.3, 0, 0]]));
  b.k('ear_L', 'r', [[0, 0], [.2, -20], [1.2, -20], [1.4, 0]]); b.k('ear_R', 'r', [[0, 0], [.2, 18], [1.2, 18], [1.4, 0]]);
  b.fx('fx_a', 'sweat', { p: [[.3, -50, -170, I], [1.0, -54, -140]], a: [[.3, 1], [.8, 1], [1.0, 0]] });
  b.x(0, 'worried', 1.35, 'neutral');
});
def('muncher_frozen', .9, { ctx: 'arena', desc: 'Muncher frozen: relief, proud little hop.', rm: { type: 'expr' } }, b => { hop(b, 0, 18, .24); b.x(0, 'surprised', .2, 'proud', .85, 'neutral'); });
def('new_seeds', .9, { ctx: 'arena', desc: 'New seeds arrive in the basket: double bounce, sparkle eyes.', rm: { type: 'expr' } }, b => {
  b.k('pip', 'p', [[0, 0, 0], [.04, 0, 0, O], [.14, 0, -14, I], [.26, 0, 0, O], [.36, 0, -10, I], [.46, 0, 0]]);
  b.k('body', 's', [[0, 1, 1], [.04, 1.06, .93], [.12, .95, 1.06], [.26, 1.08, .92], [.34, .96, 1.05], [.46, 1.06, .94], [.6, 1, 1]]);
  b.k('ear_R_tip', 'r', cat([[0, 0]], osc(.14, -24, .2), osc(.46, 14, .2)));
  b.fx('fx_a', 'sparkle', { p: [[.1, 50, -170]], s: [[.1, .2, .2, O], [.25, 1, 1], [.5, 0, 0]], end: .5 });
  b.x(0, 'admire', .8, 'happy');
});
def('need_more_seeds', 1.8, { ctx: 'arena', desc: '"Need more seeds": ears droop, eyes down, sigh.', rm: { type: 'expr' } }, b => {
  b.k('ear_L', 'r', [[0, 0], [.4, -30, O], [1.5, -30], [1.8, -26]]); b.k('ear_R', 'r', [[0, 0], [.45, 26, O], [1.5, 26], [1.8, 22]]); b.k('ear_R_tip', 'r', [[0, 0], [.5, 20], [1.8, 20]]);
  b.k('head', 'p', [[0, 0, 0], [.4, 0, 6], [1.8, 0, 6]]);
  b.k('body', 's', [[0, 1, 1], [.4, 1.03, .96], [1.0, 1.03, .96], [1.2, .98, 1.03], [1.5, 1.04, .95], [1.8, 1.03, .96]]);
  b.x(0, 'worried', .3, 'sad', 1.1, 'blink', 1.2, 'sad');
});
def('doze', 3.6, { loop: true, ctx: 'arena', desc: 'No input for 20 s: dozes in the corner — slow nods that snap back up.', rm: { type: 'expr' } }, b => {
  b.k('head', 'p', [[0, 0, 0], [1.4, 0, 8, I], [1.5, 0, 0, O3], [2.6, 0, 9, I], [2.7, 0, 1, O3], [3.6, 0, 0]]);
  b.k('ear_L', 'r', [[0, -10], [1.4, -22, I], [1.5, -8, O3], [2.6, -24, I], [2.7, -10, O3], [3.6, -10]]); b.k('ear_R', 'r', neg(b.tracks.ear_L.r));
  b.k('body', 's', [[0, 1.02, .97], [1.8, 1.03, .96], [3.6, 1.02, .97]]);
  b.x(0, 'sleepy', 1.2, 'asleep', 1.5, 'wide', 1.62, 'sleepy', 2.4, 'asleep', 2.7, 'half', 3.0, 'sleepy');
});

// ════ RUN (top view; 150-frame px = game px) ══════════════════════════════
// Gallop: stride 96 px per 0.24 s at 400 px/s. Feet in contact move +48 px LINEAR = exactly 400 px/s → no slide.
def('run_gallop', .24, { loop: true, view: 'top', ctx: 'run', speed_bind: 'speed_scale = scroll_speed / 400', desc: 'Rabbit gallop seen from above: hind pair pushes together, front paws alternate, spine flexes, ears flap. Contact phases are linear so feet stay locked to the ground at any scroll speed.', rm: { type: 'damp', k: .4, keep: ['foot_L', 'foot_R', 'arm_L', 'arm_R'] } }, b => {
  b.k('foot_L', 'p', [[0, 0, -24, L], [.12, 0, 24, IO], [.24, 0, -24]]); b.k('foot_R', 'p', b.tracks.foot_L.p);
  b.k('foot_L', 's', [[0, 1, 1], [.12, 1, 1, IO], [.18, 1.14, 1.1, IO], [.24, 1, 1]]); b.k('foot_R', 's', b.tracks.foot_L.s);
  b.k('arm_L', 'p', [[0, 0, 24, IO], [.12, 0, -24, L], [.24, 0, 24]]); b.k('arm_L', 's', [[0, 1, 1, IO], [.06, 1.12, 1.12, IO], [.12, 1, 1], [.24, 1, 1]]);
  b.k('arm_R', 'p', [[0, 0, 8, L], [.04, 0, 24, IO], [.16, 0, -24, L], [.24, 0, 8]]); b.k('arm_R', 's', [[0, 1, 1], [.04, 1, 1, IO], [.1, 1.12, 1.12, IO], [.16, 1, 1], [.24, 1, 1]]);
  b.k('body', 's', [[0, 1, 1], [.06, .95, 1.08], [.12, 1, 1], [.18, 1.05, .93], [.24, 1, 1]]); b.k('body', 'p', [[0, 0, 0], [.06, 0, -3], [.18, 0, 2], [.24, 0, 0]]);
  b.k('head', 'p', [[0, 0, 0], [.08, 0, -3], [.2, 0, 1], [.24, 0, 0]]);
  b.k('ear_L', 'r', [[0, 0], [.08, -6], [.2, 4], [.24, 0]]); b.k('ear_R', 'r', [[0, 0], [.08, 6], [.2, -4], [.24, 0]]); b.k('ear_R_tip', 'r', [[0, 0], [.1, -12], [.22, 8], [.24, 0]]);
  b.k('tail', 'p', [[0, 0, 0], [.12, 0, 3], [.24, 0, 0]]);
  b.x(0, 'determined');
});
def('lane_left', .22, { view: 'top', ctx: 'run', layer: 'overlay', desc: 'Lane change ←: lean + squash in the first 0.12 s (player.gd tween 0.12 quad-out moves x), settle by 0.22. Overlay: pip.r / pip.s / head.r only.', rm: { type: 'damp', k: .3 } }, b => {
  b.k('pip', 'r', [[0, 0], [.06, -14, O], [.12, -6], [.22, 0]]); b.k('pip', 's', [[0, 1, 1], [.05, .92, 1.05], [.12, 1.02, .99], [.22, 1, 1]]); b.k('head', 'r', [[0, 0], [.04, -8], [.14, 2], [.22, 0]]);
});
def('lane_right', .22, { view: 'top', ctx: 'run', layer: 'overlay', desc: 'Lane change → (mirror of lane_left).', rm: { type: 'damp', k: .3 } }, b => {
  b.k('pip', 'r', neg(P.ANIMS.lane_left.tracks.pip.r)); b.k('pip', 's', P.ANIMS.lane_left.tracks.pip.s); b.k('head', 'r', neg(P.ANIMS.lane_left.tracks.head.r));
});
def('pickup_coin', .22, { view: 'top', ctx: 'run', layer: 'overlay', desc: 'Coin: quick pop + happy blink.', rm: { type: 'expr' } }, b => { b.k('pip', 's', [[0, 1, 1], [.07, 1.07, 1.07, O], [.22, 1, 1]]); b.x(0, 'happy', .2, 'determined'); });
def('pickup_seed', .36, { view: 'top', ctx: 'run', layer: 'overlay', desc: 'Seed: bigger pop, head wiggle, joy.', rm: { type: 'expr' } }, b => { b.k('pip', 's', [[0, 1, 1], [.08, 1.1, 1.1, O], [.36, 1, 1]]); b.k('head', 'r', [[0, 0], [.08, -8], [.16, 8], [.24, -4], [.32, 0]]); b.x(0, 'joy', .34, 'determined'); });
def('pickup_diamond', .5, { view: 'top', ctx: 'run', layer: 'overlay', desc: 'Diamond: big pop, admire eyes, two sparkles.', rm: { type: 'expr' } }, b => {
  b.k('pip', 's', [[0, 1, 1], [.1, 1.16, 1.16, O], [.25, .98, .98], [.5, 1, 1]]); b.k('head', 'r', [[0, 0], [.1, -10], [.22, 10], [.34, -4], [.46, 0]]);
  b.fx('fx_a', 'sparkle', { p: [[.05, -34, -62]], s: [[.05, .2, .2, O], [.2, .9, .9], [.45, 0, 0]], end: .45 });
  b.fx('fx_b', 'sparkle', { p: [[.12, 36, -70]], s: [[.12, .2, .2, O], [.27, .8, .8], [.5, 0, 0]], end: .5 });
  b.x(0, 'admire', .48, 'determined');
});
def('run_start', .5, { view: 'top', ctx: 'run', desc: 'Start: crouch, ears pressed back, launch into the gallop (event "go").', rm: { type: 'expr' } }, b => {
  b.k('body', 's', [[0, 1, 1], [.18, 1.08, .88, O], [.3, .92, 1.12, O3], [.5, 1, 1]]);
  b.k('foot_L', 'p', [[0, 0, 0], [.18, 0, -8], [.3, 0, 16], [.5, 0, -24]]); b.k('foot_R', 'p', b.tracks.foot_L.p);
  b.k('ear_L', 'r', [[0, 0], [.18, 10], [.3, -8], [.5, 0]]); b.k('ear_R', 'r', neg(b.tracks.ear_L.r));
  b.k('pip', 's', [[0, 1, 1], [.3, 1.06, 1.06, O], [.5, 1, 1]]);
  b.x(0, 'determined'); b.ev(.3, 'go');
});
// Fail: matches UiRun beat (freeze .20 → shake .24 → total .46). Pip tumbles back inside its own lane; last frame is held = Loot backdrop.
const FAIL_END = { pip: { p: [0, 44], r: -372 }, ear_L: 40, ear_R: -40, foot_L: 30, foot_R: -30 };
def('fail', .46, { view: 'top', ctx: 'run', hold: true, desc: 'Hit: impact squash (0–0.06), knocked back and tumbling (0.06–0.40), lands dizzy and splayed. Stays inside the lane (±0 x, +44 y). Last frame held → Loot screen backdrop.', rm: { type: 'end' } }, b => {
  b.k('pip', 's', [[0, 1.28, .72, O], [.06, .9, 1.12], [.2, 1.05, .95], [.32, .95, 1.05], [.4, 1.08, .92], [.46, 1, 1]]);
  b.k('pip', 'r', [[0, 0], [.06, 0, O], [.4, -372, O], [.46, -372]]); b.k('pip', 'p', [[0, 0, 0], [.06, 0, 16, O], [.4, 0, 44], [.46, 0, 44]]);
  b.k('ear_L', 'r', [[0, 0], [.12, 40, O], [.46, 40]]); b.k('ear_R', 'r', [[0, 0], [.12, -40, O], [.46, -40]]);
  b.k('foot_L', 'r', [[0, 0], [.3, 0], [.46, 30]]); b.k('foot_R', 'r', [[0, 0], [.3, 0], [.46, -30]]);
  b.k('arm_L', 'p', [[0, 0, 0], [.4, -8, -4], [.46, -8, -4]]); b.k('arm_R', 'p', [[0, 0, 0], [.4, 8, -4], [.46, 8, -4]]);
  b.fx('fx_a', 'star', { p: [[0, 0, -70]], s: [[0, .4, .4, O], [.1, 1.4, 1.4], [.24, 0, 0]], end: .24 });
  ['fx_b', 'fx_c'].forEach((n, i) => { b.k(n, 'v', [[0, 0], [.4, 1]]); b.k(n, 'f', [[0, 'star']]); b.k(n, 'p', [[0, i ? 24 : -24, 4]]); b.k(n, 's', [[.4, 0, 0, O], [.46, .7, .7]]); });
  b.x(0, 'surprised', .06, 'squint', .32, 'dizzy'); b.ev(0, 'impact'); b.ev(.46, 'fail_end');
});
def('fail_dizzy', 1.2, { loop: true, view: 'top', ctx: 'run/loot', desc: 'Held dizzy pose behind the Loot screen: head wobble, two stars orbit.', rm: { type: 'expr', fx: true } }, b => {
  const e = FAIL_END; b.k('pip', 'p', [[0, ...e.pip.p]]); b.k('pip', 'r', [[0, e.pip.r]]);
  ['ear_L', 'ear_R', 'foot_L', 'foot_R'].forEach(n => b.k(n, 'r', [[0, e[n]]])); b.k('arm_L', 'p', [[0, -8, -4]]); b.k('arm_R', 'p', [[0, 8, -4]]);
  b.k('head', 'r', samp(1.2, .1, t => [Math.sin(t / 1.2 * Math.PI * 2) * 6]));
  ['fx_b', 'fx_c'].forEach((n, i) => { b.k(n, 'v', [[0, 1]]); b.k(n, 'f', [[0, 'star']]); b.k(n, 's', [[0, .7, .7]]); b.k(n, 'p', samp(1.2, .1, t => { const a = t / 1.2 * Math.PI * 2 + i * Math.PI; return [Math.cos(a) * 30, 4 + Math.sin(a) * 12]; })); });
  b.x(0, 'dizzy');
});
def('finish', .62, { view: 'top', ctx: 'run', hold: true, desc: 'Goal (FINISH_TOTAL 0.62): world slows to 0 in 0.3 s (speed_scale follows), Pip sits up — head comes closer, ears perk sideways, a happy hop.', rm: { type: 'end' } }, b => {
  b.k('body', 's', [[0, 1, 1], [.2, .94, .86], [.3, .96, .9], [.62, .96, .9]]);
  b.k('head', 'p', [[0, 0, 0], [.2, 0, 6], [.62, 0, 4]]); b.k('head', 's', [[0, 1, 1], [.1, 1, 1], [.3, 1.12, 1.12, O], [.62, 1.1, 1.1]]);
  b.k('ear_L', 'r', [[0, 0], [.1, 0], [.3, 60, O], [.4, 52], [.62, 56]]); b.k('ear_R', 'r', neg(b.tracks.ear_L.r));
  b.k('arm_L', 'p', [[0, 0, 0], [.3, 6, -8], [.62, 6, -8]]); b.k('arm_R', 'p', [[0, 0, 0], [.3, -6, -8], [.62, -6, -8]]);
  b.k('foot_L', 'p', [[0, 0, 0], [.3, 0, -10], [.62, 0, -10]]); b.k('foot_R', 'p', b.tracks.foot_L.p);
  b.k('pip', 's', [[0, 1, 1], [.3, 1, 1, O], [.42, 1.14, 1.14, I], [.54, 1, 1], [.62, 1, 1]]);
  b.fx('fx_a', 'sparkle', { p: [[.3, -40, -70]], s: [[.3, .2, .2, O], [.45, 1, 1], [.62, .8, .8]], end: .62 });
  b.fx('fx_b', 'star', { p: [[.36, 44, -64]], s: [[.36, .2, .2, O], [.5, .9, .9], [.62, .8, .8]], end: .62 });
  b.x(0, 'determined', .25, 'joy'); b.ev(.62, 'finish_end');
});
def('revive_getup', .9, { view: 'top', ctx: 'run', desc: 'After Revive: from the dizzy pose, head shake, ears snap back, hop into the gallop.', rm: { type: 'expr' } }, b => {
  const e = FAIL_END; b.k('pip', 'p', [[0, ...e.pip.p], [.3, ...e.pip.p], [.6, 0, -4, O], [.75, 0, 0]]); b.k('pip', 'r', [[0, e.pip.r], [.3, -360], [.9, -360]]);
  ['ear_L', 'ear_R', 'foot_L', 'foot_R'].forEach(n => b.k(n, 'r', [[0, e[n]], [.5, e[n]], [.65, 0, O]]));
  b.k('head', 'r', [[0, 0], [.2, 0], [.28, -14], [.36, 14], [.44, -10], [.52, 6], [.6, 0]]);
  b.k('pip', 's', [[0, 1, 1], [.6, 1, 1, O], [.7, 1.1, 1.1, I], [.82, 1, 1]]);
  b.x(0, 'dizzy', .2, 'squint', .6, 'determined');
});
// HUD portrait (front rig, head crop) — expressions on the CompanionChip
const hud = (id, len, ex, d) => def(id, len, { ctx: 'run_hud', layer: 'overlay', desc: d, rm: { type: 'expr' } }, b => { b.k('pip', 's', [[0, 1, 1], [.08, 1.08, 1.08, O], [len, 1, 1]]); b.x(0, ex, len - .02, 'neutral'); });
hud('hud_happy', .4, 'happy', 'HUD: coin / seed picked up.'); hud('hud_wow', .6, 'admire', 'HUD: diamond.');
hud('hud_worried', 1.2, 'worried', 'HUD: last 17 % of time (RING_LOW).'); hud('hud_proud', .9, 'proud', 'HUD: finish.');
def('hud_hit', .5, { ctx: 'run_hud', layer: 'overlay', hold: true, desc: 'HUD: hit — dizzy, held into Loot.', rm: { type: 'expr' } }, b => { b.k('head', 'r', [[0, 0], [.1, -10], [.2, 8], [.3, -4], [.4, 0]]); b.x(0, 'dizzy'); });
def('hud_go', .5, { ctx: 'run_hud', layer: 'overlay', desc: 'HUD: run start — determined nod.', rm: { type: 'expr' } }, b => { b.k('head', 'r', [[0, 0], [.15, 6], [.3, 0]]); b.x(0, 'determined', .48, 'determined'); });

// ════ SHOP / WARDROBE (three_q) ═══════════════════════════════════════════
def('pose_classic', .01, { view: 'three_q', ctx: 'shop', hold: true, desc: 'Showcase pose Classic: friendly wave, folded tip swung.', rm: { type: 'end' } }, b => {
  b.k('arm_R', 'r', [[0, -140]]); b.k('arm_R', 'p', [[0, 2, -8]]); b.k('head', 'r', [[0, 6]]); b.k('ear_R_tip', 'r', [[0, -14]]); b.k('pip', 'r', [[0, -2]]); b.x(0, 'happy');
});
def('pose_blossom', .01, { view: 'three_q', ctx: 'shop', hold: true, desc: 'Showcase pose Blossom: head tilted to show the sprig, paws clasped, dreamy.', rm: { type: 'end' } }, b => {
  b.k('head', 'r', [[0, -10]]); b.k('arm_L', 'p', [[0, 9, -6]]); b.k('arm_L', 'r', [[0, -30]]); b.k('arm_R', 'p', [[0, -9, -6]]); b.k('arm_R', 'r', [[0, 30]]);
  b.k('body', 's', [[0, .98, 1.02]]); b.k('ear_L', 'r', [[0, -6]]); b.x(0, 'happy');
});
def('pose_sky', .01, { view: 'three_q', ctx: 'shop', hold: true, desc: 'Showcase pose Sky: periscoped tall, looking up at the sky, cloud tips high.', rm: { type: 'end' } }, b => {
  b.k('body', 'p', [[0, 0, -14]]); b.k('body', 's', [[0, .95, 1.1]]); b.k('arm_L', 'p', [[0, 4, -10]]); b.k('arm_L', 'r', [[0, -20]]); b.k('arm_R', 'p', [[0, -4, -10]]); b.k('arm_R', 'r', [[0, 20]]);
  b.k('head', 'r', [[0, -8]]); b.k('eye_L', 'p', [[0, 1, -3]]); b.k('eye_R', 'p', [[0, 1, -3]]); b.k('ear_L', 'r', [[0, 8]]); b.k('ear_R', 'r', [[0, -6]]); b.k('ear_R_tip', 'r', [[0, -30]]); b.x(0, 'admire');
});
def('sig_classic', 1.3, { view: 'three_q', ctx: 'shop', desc: 'Signature Classic (tap, 1.3 s): the ear-flip — folded tip springs straight up during a binky, then flops back with a bounce.', rm: { type: 'expr' } }, b => {
  const dn = hop(b, 0, 40, .44);
  b.k('ear_R_tip', 'r', [[0, 0], [.15, -122, O], [.52, -122], [.64, 12, I], [.74, -14], [.86, 6], [.98, 0]]);
  b.k('pip', 'r', [[0, 0], [.14, 0], [.3, -10], [.46, 8], [dn, 0]]);
  b.x(0, 'joy', .7, 'wink', 1.25, 'happy');
});
def('sig_blossom', 1.4, { view: 'three_q', ctx: 'shop', desc: 'Signature Blossom (tap, 1.4 s): a twirl on the spot that sheds six petals.', rm: { type: 'expr', fx: false } }, b => {
  b.k('pip', 's', [[0, 1, 1], [.12, 1, 1, IO], [.34, -1, 1, IO], [.56, 1, 1]]); b.k('pip', 'p', [[0, 0, 0], [.1, 0, 0, O], [.32, 0, -14, I], [.56, 0, 0]]);
  b.k('body', 's', [[0, 1, 1], [.08, 1.05, .94], [.56, 1, 1], [.62, 1.06, .94], [.74, 1, 1]]);
  b.k('ear_L', 'r', cat([[0, 0]], osc(.2, -18, .26), osc(.6, 12, .2))); b.k('ear_R_tip', 'r', cat([[0, 0]], osc(.24, 30, .3)));
  ['fx_a', 'fx_b', 'fx_c', 'fx_d', 'fx_e', 'fx_f'].forEach((n, i) => { const a = -Math.PI * .9 + i * Math.PI * .36; b.fx(n, i % 2 ? 'petal2' : 'petal', { p: [[.34, 0, -130, O], [.8, Math.cos(a) * 110, -130 + Math.sin(a) * 70], [1.35, Math.cos(a) * 130 + 10, -40 + Math.sin(a) * 30]], r: [[.34, 0], [1.35, (i % 2 ? 1 : -1) * 220]], a: [[.34, 1], [1.1, 1], [1.35, 0]] }); });
  b.x(0, 'happy', .56, 'love', 1.2, 'happy');
});
def('sig_sky', 1.5, { view: 'three_q', ctx: 'shop', desc: 'Signature Sky (tap, 1.5 s): cloud hop — springs up on two puffs and floats down slowly, swaying.', rm: { type: 'expr', fx: false } }, b => {
  b.k('pip', 'p', [[0, 0, 0], [.12, 0, 0, O], [.42, 0, -62, L], [1.0, 0, -40, I], [1.3, 0, 0], [1.5, 0, 0]]);
  b.k('pip', 'r', [[0, 0], [.42, 0], [.7, -5], [1.0, 5], [1.3, 0]]);
  b.k('body', 's', [[0, 1, 1], [.1, 1.08, .9], [.14, .92, 1.12], [.42, 1, 1.02], [1.27, .98, 1.04], [1.32, 1.12, .88, O], [1.44, 1, 1]]);
  b.k('ear_L', 'r', [[0, 0], [.2, -14], [.6, 6], [1.0, 2], [1.3, -8], [1.5, 0]]); b.k('ear_R', 'r', [[0, 0], [.22, 14], [.62, -6], [1.0, -2], [1.3, 8], [1.5, 0]]); b.k('ear_R_tip', 'r', [[0, 0], [.25, 30], [.7, -20], [1.2, 10], [1.5, 0]]);
  b.k('foot_L', 'p', [[0, 0, 0], [.14, 0, 0], [.4, 0, -6], [1.25, 0, -6], [1.3, 0, 0]]); b.k('foot_R', 'p', b.tracks.foot_L.p);
  [['fx_a', -34, 0], ['fx_b', 30, 4], ['fx_c', 0, 10]].forEach(([n, x, y], i) => b.fx(n, 'cloud', { p: [[.12 + i * .04, x, y, O], [1.3, x * 1.8, y - 30 - i * 6]], s: [[.12 + i * .04, .2, .2, O], [.3 + i * .04, .9, .9], [1.3, 1.2, 1.2]], a: [[.12, 1], [1.0, 1], [1.3, 0]] }));
  b.x(0, 'joy', .42, 'admire', 1.3, 'happy');
});
def('stage_hop', .28, { view: 'three_q', ctx: 'wardrobe', layer: 'overlay', desc: 'Wardrobe stage pick: 1 → 1.12 → 1, y −11 % (T_STAGE_HOP 0.28).', rm: { type: 'expr' } }, b => {
  b.k('pip', 's', [[0, 1, 1, O], [.14, 1.12, 1.12, I], [.28, 1, 1]]); b.k('pip', 'p', [[0, 0, 0, O], [.14, 0, -26, I], [.28, 0, 0]]); b.x(0, 'happy', .27, 'neutral');
});

// ════ BEHAVIOURS (behaviors.json) ═════════════════════════════════════════
const SEASON = {
  country_bloom: [{ anim: 'cb_butterfly', prop: 'butterfly', cooldown_s: 40 }, { anim: 'cb_dandelion', prop: 'dandelion', cooldown_s: 50 }],
  frost_orchard: [{ anim: 'fo_snowflake', prop: 'snowflake', cooldown_s: 35 }, { anim: 'fo_shake', prop: 'snowclump', cooldown_s: 50 }],
  lantern_meadow: [{ anim: 'lm_firefly', prop: 'firefly', cooldown_s: 35 }, { anim: 'lm_eartip', prop: 'firefly', cooldown_s: 50 }],
  amber_canopy: [{ anim: 'ac_leafhat', prop: 'leaf', cooldown_s: 40 }, { anim: 'ac_acorn', prop: 'acorn', cooldown_s: 50 }],
  moonlit_warren: [{ anim: 'mw_burrow', prop: 'burrow + dirt', cooldown_s: 50 }, { anim: 'mw_moon', prop: 'sparkle ×3', cooldown_s: 40 }],
  coral_tide: [{ anim: 'ct_bubble', prop: 'bubble', cooldown_s: 35 }, { anim: 'ct_shell', prop: 'shell + notes', cooldown_s: 50 }],
  starfall_glade: [{ anim: 'sg_wish', prop: 'meteor', cooldown_s: 45 }, { anim: 'sg_petal', prop: 'starpetal', cooldown_s: 40 }],
  ember_fen: [{ anim: 'ef_smoke', prop: 'smoke', cooldown_s: 40 }, { anim: 'ef_ember', prop: 'ember', cooldown_s: 45 }]
};
G.PipBehaviors = {
  schema: 1,
  note: 'Seasonal interactions spawn their own prop on the Pip rig (nodes prop / prop2 / fx_*). They never read or drive SeasonAmbient particles.',
  field: {
    box: 190, view: 'front', rest_view: 'front', zone_feet: [151, 1306, 614, 131], default_base: [756, 1404],
    move: { anim: 'hop', view: 'side', speed_px_s: 95, walk_chance: .35, flip_when_left: true },
    idle: { loop: 'idle', gap_s: [3, 7], variants: [{ anim: 'idle_look', w: 3 }, { anim: 'ear_twitch', w: 3 }, { anim: 'groom', w: 2 }, { anim: 'periscope', w: 2 }, { anim: 'yawn', w: 1 }, { anim: 'binky', w: 1, cooldown_s: 30 }, { anim: 'flop', w: 1, cooldown_s: 60 }, { anim: 'thump', w: .5, cooldown_s: 45 }] },
    flower: { sniff: { anim: 'sniff', near_px: 120, chance: .35 }, sneeze: { anim: 'sneeze', after: 'sniff', chance: .3 }, admire: { anim: 'admire', on: 'flower_grown', walk_to: true } },
    sleep: { after_idle_s: 25, enter: 'fall_asleep', loop: 'sleep', exit: 'wake', wake_on: ['tap', 'apply', 'season_change', 'flower_grown'] },
    tap: { window_s: 3, steps: ['tap_giggle', 'tap_hop', 'tap_huff', 'tap_flop'] },
    season: { gap_s: [14, 28], by_season: SEASON },
    events: { apply: 'apply', return_home: 'greet', flower_grown: 'admire', sniff: 'sniff' }
  },
  card: { box: 230, loop: 'card_idle', events: { open_field: 'card_jump', return_home: 'greet', apply: 'apply' } },
  arena: { box: 150, anchor: 'bottom-left, inset (30, 26)', loop: 'arena_idle', look_at: { while: 'seed dragged', head_rot_max_deg: 7, eye_offset_max_px: [3.5, 3], follow_rate: 9 },
    events: { merge_t2: 'merge_t2', merge_t3: 'merge_t3', combo_hop: 'combo_hop', combo_big: 'combo_big', muncher_wake: 'muncher_wake', muncher_eat: 'muncher_eat', muncher_frozen: 'muncher_frozen', new_seeds: 'new_seeds', need_more_seeds: 'need_more_seeds' },
    doze: { after_no_input_s: 20, loop: 'doze', exit: 'wake' } },
  run: { view: 'top', loop: 'run_gallop', speed_scale: 'scroll_speed / 400', events: { start: 'run_start', lane_left: 'lane_left', lane_right: 'lane_right', coin: 'pickup_coin', seed: 'pickup_seed', diamond: 'pickup_diamond', hit: 'fail', finish: 'finish', revive: 'revive_getup' }, after: { fail: 'fail_dizzy (Loot backdrop)' },
    hud: { box: 88, loop: 'hud_idle', events: { start: 'hud_go', coin: 'hud_happy', seed: 'hud_happy', diamond: 'hud_wow', low_time: 'hud_worried', hit: 'hud_hit', finish: 'hud_proud' } } },
  shop: { looks_card: [984, 300], still: true, pose_by_skin: { classic: 'pose_classic', blossom: 'pose_blossom', sky: 'pose_sky' }, on_tap: 'signature (≤ 1.5 s), then back to pose', list_pips: 'static pose, no loop' },
  wardrobe: { stage: [1032, 300], loop: 'stage_idle', on_pick: 'stage_hop', thumbs: [210, 150], thumb: 'static pose_<skin>' }
};
})(typeof window !== 'undefined' ? window : globalThis);
