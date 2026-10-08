// Pip runtime: Godot-equivalent cutout player (node transforms only, sprites never redrawn),
// behaviour brain, and exporter for godot/*.json + assets/pip/**.svg.
(function (G) {
'use strict';
const A = G.PipArt;
// Godot ease(x, c) — key "transition" in Animation tracks. 1 linear · 0 hold · <1 out · >1 in · <0 in-out.
function ease(x, c) {
  x = x < 0 ? 0 : x > 1 ? 1 : x;
  if (c > 0) return c < 1 ? 1 - Math.pow(1 - x, 1 / c) : Math.pow(x, c);
  if (c < 0) return x < .5 ? Math.pow(x * 2, -c) * .5 : (1 - Math.pow(1 - (x - .5) * 2, -c)) * .5 + .5;
  return 0;
}
const TR = { lin: 1, hold: 0, in: 2, out: .5, io: -2, in3: 3, out3: .33, io3: -3, in15: 1.5, out15: .66 };
const DEF_TR = -2;
const ARITY = { p: 2, s: 2, r: 1, a: 1, v: 1, f: 1 };
const GODOT_PROP = { p: 'position', r: 'rotation_degrees', s: 'scale', a: 'modulate:a', v: 'visible', f: 'frame' };

// ── animation definitions
const ANIMS = {}, ORDER = [];
class B {
  constructor() { this.tracks = {}; this.events = []; this.ex = []; }
  k(node, prop, keys) { (this.tracks[node] = this.tracks[node] || {})[prop] = keys; return this; }
  x() { for (let i = 0; i < arguments.length; i += 2) this.ex.push([arguments[i], arguments[i + 1]]); return this; }
  ev(t, name, arg) { this.events.push([t, name, arg === undefined ? null : arg]); return this; }
  fx(node, frame, keys, o) { // convenience: show fx/prop node with frame for its key span
    const ls = ['p', 's', 'a', 'r'].filter(q => keys[q]).map(q => keys[q]);
    const t0 = Math.min(...ls.map(k => k[0][0])), t1 = keys.end != null ? keys.end : Math.max(...ls.map(k => k[k.length - 1][0]));
    const tr = this.tracks[node] = this.tracks[node] || {};
    tr.v = [[0, 0], [t0, 1], [t1, 0]]; tr.f = [[0, frame]];
    ['p', 's', 'r', 'a'].forEach(q => { if (keys[q]) tr[q] = keys[q]; });
    return this;
  }
}
function def(id, len, meta, build) {
  const b = new B(); if (build) build(b);
  const a = Object.assign({ id, len, loop: false, layer: 'base', view: 'front', ctx: 'shared', desc: '', rm: { type: 'damp', k: .3 } }, meta, { tracks: b.tracks, events: b.events, ex: b.ex });
  // expand expression track → swap tracks
  if (a.ex.length) A.EXPR_NODES.forEach((n, i) => { const tr = a.tracks[n] = a.tracks[n] || {}; if (!tr.f) tr.f = a.ex.map(([t, e]) => [t, (A.EXPR[e] || A.EXPR.neutral)[i]]); });
  ANIMS[id] = a; ORDER.push(id); return a;
}
function sampleTrack(keys, t, ar, hold) {
  if (!keys || !keys.length) return null;
  if (t <= keys[0][0] || keys.length === 1) return keys[0].slice(1, 1 + ar);
  const L = keys[keys.length - 1]; if (t >= L[0]) return L.slice(1, 1 + ar);
  let i = 0; while (i < keys.length - 2 && keys[i + 1][0] <= t) i++;
  const a = keys[i], b = keys[i + 1];
  if (hold || typeof a[1] === 'string') return a.slice(1, 1 + ar);
  const tr = a.length > 1 + ar ? a[1 + ar] : DEF_TR;
  if (tr === 0) return a.slice(1, 1 + ar);
  const e = ease((t - a[0]) / (b[0] - a[0]), tr);
  const out = []; for (let j = 1; j <= ar; j++) out.push(a[j] + (b[j] - a[j]) * e); return out;
}
// sample anim into pose dict {node:{p,r,s,a,v,f}}
function sample(anim, t, pose, rm) {
  const mode = rm ? (anim.rm || {}).type : null, k = rm ? ((anim.rm || {}).k != null ? anim.rm.k : .3) : 1;
  for (const n in anim.tracks) {
    const tr = anim.tracks[n], o = pose[n] = pose[n] || {};
    const isFx = /^(fx_|prop|emote)/.test(n);
    for (const q in tr) {
      if (mode === 'expr' && q !== 'f') continue;
      if (rm && isFx && !(anim.rm && anim.rm.fx)) { if (q === 'v') o.v = 0; continue; }
      const kk = rm && anim.rm && anim.rm.keep && anim.rm.keep.includes(n) ? 1 : k, md = kk === 1 && mode === 'damp' ? null : mode;
      const v = sampleTrack(tr[q], t, ARITY[q], q === 'v' || q === 'f'); if (!v) continue;
      if (q === 'p') o.p = md === 'damp' ? [v[0] * k, v[1] * k] : v;
      else if (q === 's') o.s = md === 'damp' ? [1 + (v[0] - 1) * k, 1 + (v[1] - 1) * k] : v;
      else if (q === 'r') o.r = md === 'damp' ? v[0] * k : v[0];
      else o[q] = v[0];
    }
  }
  return pose;
}

// ── matrices
const mul = (m, n) => [m[0] * n[0] + m[2] * n[1], m[1] * n[0] + m[3] * n[1], m[0] * n[2] + m[2] * n[3], m[1] * n[2] + m[3] * n[3], m[0] * n[4] + m[2] * n[5] + m[4], m[1] * n[4] + m[3] * n[5] + m[5]];
const loc = (x, y, r, sx, sy) => { const c = Math.cos(r * Math.PI / 180), s = Math.sin(r * Math.PI / 180); return [c * sx, s * sx, -s * sy, c * sy, x, y]; };
const r3 = v => Math.round(v * 1000) / 1000;

const REG = new Set(); let last = 0, raf = 0;
function loop(ts) { const dt = last ? Math.min(.05, (ts - last) / 1000) : 0; last = ts; REG.forEach(i => { if (!i.el.isConnected) { REG.delete(i); return; } if (!i.paused) i.tick(dt); }); raf = requestAnimationFrame(loop); }

function abz(rig, n) { let z = 0, c = n; while (c) { z += c.z; c = c.parent ? rig.map[c.parent] : null; } return z; }
function rigOf(view) { const r = A.RIGS[view]; if (!r.map) { r.map = {}; r.nodes.forEach(n => r.map[n.id] = n); } return r; }

class Inst {
  constructor(el, o) {
    this.el = el; this.o = Object.assign({ view: 'front', skin: 'classic', size: 190, crop: null, flip: false, shadow: true, face: 'neutral', loop: null, still: false }, o);
    this.base = null; this.over = null; this.lookT = null; this.lk = { r: 0, ex: 0, ey: 0 }; this.speed = 1; this.paused = false; this.listeners = [];
    this.build();
    if (this.o.loop) this.play(this.o.loop);
    if (!this.o.still) { REG.add(this); if (!raf && typeof requestAnimationFrame !== 'undefined') raf = requestAnimationFrame(loop); }
  }
  get skin() { return A.SKINS.find(s => s.key === this.o.skin) || A.SKINS[0]; }
  build() {
    const rig = rigOf(this.o.view), sk = this.skin, tk = sk.tokens; this.rig = rig;
    const fr = rig.frame, vb = this.o.crop || [0, 0, fr[0], fr[1]];
    const ns = 'http://www.w3.org/2000/svg';
    const svg = document.createElementNS(ns, 'svg');
    svg.setAttribute('viewBox', vb.join(' ')); svg.setAttribute('width', this.o.size); svg.setAttribute('height', this.o.size * vb[3] / vb[2]);
    svg.style.overflow = 'visible'; svg.style.display = 'block';
    const list = rig.nodes.filter(n => n.sprite && !(n.ov && !sk.overlays.includes(n.ov)) && !(n.id === 'shadow' && !this.o.shadow))
      .map((n, i) => ({ n, i, z: abz(rig, n) })).sort((a, b) => a.z - b.z || a.i - b.i);
    this.els = {}; this.cur = {};
    for (const { n } of list) {
      const g = document.createElementNS(ns, 'g'); g.setAttribute('data-node', n.id);
      if (n.sprite === 'ov') g.innerHTML = A.OV[n.ov].art(tk);
      else if (n.sprite === 'fx') g.innerHTML = '';
      else { const sp = A.SPR[n.sprite]; const names = Object.keys(sp.frames);
        if (names.length === 1) g.innerHTML = sp.frames[names[0]](tk);
        else g.innerHTML = names.map(f => '<g data-f="' + f + '" style="display:none">' + sp.frames[f](tk) + '</g>').join(''); }
      svg.appendChild(g); this.els[n.id] = g;
    }
    if (this.o.sil) svg.querySelectorAll('[fill],[stroke]').forEach(e => { if (e.getAttribute('fill') && e.getAttribute('fill') !== 'none') { e.setAttribute('fill', this.o.sil); e.removeAttribute('fill-opacity'); } if (e.getAttribute('stroke')) e.setAttribute('stroke', this.o.sil); });
    this.el.innerHTML = ''; this.el.appendChild(svg); this.svg = svg; this.world = {};
    this.render({});
  }
  set(o) { const rb = ['view', 'skin', 'size', 'crop', 'shadow'].some(k => k in o && o[k] !== this.o[k]); Object.assign(this.o, o); if (rb) { this.build(); } }
  on(fn) { this.listeners.push(fn); return this; }
  emit(name, arg) { this.listeners.forEach(f => f(name, arg, this)); }
  play(id, opt) {
    const a = ANIMS[id]; if (!a) { console.warn('Pip: no anim', id); return this; } opt = opt || {};
    const rm = G.Pip.reduceMotion;
    if (rm && a.rm && a.rm.type === 'skip') { opt.then && opt.then(); return this; }
    const st = { a, t: rm && a.rm && a.rm.type === 'end' ? a.len : 0, cb: opt.then, hold: opt.hold || a.hold, speed: opt.speed || 1 };
    if (a.layer === 'overlay') this.over = st; else { this.base = st; if (a.loop) this.loopId = id; }
    return this;
  }
  setLoop(id) { this.loopId = id; return this.play(id); }
  lookAt(p) { this.lookT = p; }
  tick(dt) {
    const step = (st) => {
      const pt = st.t; st.t += dt * this.speed * st.speed;
      const a = st.a;
      let wrapped = false;
      if (a.loop) { if (st.t >= a.len) { st.t %= a.len; wrapped = true; } }
      a.events.forEach(([et, name, arg]) => { if ((!wrapped && pt < et && st.t >= et) || (wrapped && (et > pt || et <= st.t))) this.emit(name, arg); });
      return !a.loop && st.t >= a.len;
    };
    if (this.base && step(this.base)) {
      if (!this.base.hold) { const cb = this.base.cb; this.base = null; if (this.loopId) this.play(this.loopId); cb && cb(); }
      else this.base.t = this.base.a.len;
    }
    if (this.over && step(this.over)) { const cb = this.over.cb; this.over = null; cb && cb(); }
    // look-at (head.r + eye offset) — procedural, additive
    const h = this.world.head, lt = this.lookT; let d = { r: 0, ex: 0, ey: 0 };
    if (lt && h) { const dx = (lt[0] - h[4]) * (this.o.flip ? -1 : 1), dy = lt[1] - (h[5] - 40); d = { r: Math.max(-7, Math.min(7, dx * .05)), ex: Math.max(-3.5, Math.min(3.5, dx * .03)), ey: Math.max(-3, Math.min(3, dy * .03)) }; }
    const q = Math.min(1, dt * 9); this.lk.r += (d.r - this.lk.r) * q; this.lk.ex += (d.ex - this.lk.ex) * q; this.lk.ey += (d.ey - this.lk.ey) * q;
    this.render();
  }
  pose() {
    const rm = G.Pip.reduceMotion, pose = {};
    if (this.base) sample(this.base.a, this.base.t, pose, rm);
    if (this.over) sample(this.over.a, this.over.t, pose, rm);
    if (this.lk && (Math.abs(this.lk.r) > .01 || Math.abs(this.lk.ex) > .01)) {
      const hd = pose.head = pose.head || {}; hd.r = (hd.r || 0) + this.lk.r;
      ['eye_L', 'eye_R'].forEach(e => { const o = pose[e] = pose[e] || {}; const p = o.p || [0, 0]; o.p = [p[0] + this.lk.ex, p[1] + this.lk.ey]; });
    }
    return pose;
  }
  seek(id, t) { const a = ANIMS[id]; this.base = { a, t: t == null ? a.len : t, hold: true, speed: 0 }; this.render(); return this; }
  render(forcePose) {
    const rig = this.rig, pose = forcePose || this.pose(), face = A.EXPR[this.o.face] || A.EXPR.neutral;
    const W = this.world;
    for (const n of rig.nodes) {
      const o = pose[n.id] || {};
      const p = o.p || [0, 0], s = o.s || [1, 1];
      let m = loc(n.x + p[0], n.y + p[1], n.rot + (o.r || 0), n.sx * s[0], n.sy * s[1]);
      if (!n.parent) m = mul([this.o.flip ? -1 : 1, 0, 0, 1, rig.origin[0], rig.origin[1]], m);
      else m = mul(W[n.parent], m);
      W[n.id] = m;
      const g = this.els[n.id]; if (!g) continue;
      let vis = o.v != null ? !!o.v : !n.hide; const al = o.a != null ? o.a : 1;
      if (al <= .001) vis = false;
      const c = this.cur[n.id] = this.cur[n.id] || {};
      const ts = 'matrix(' + m.map(r3).join(' ') + ')';
      if (c.t !== ts) { g.setAttribute('transform', ts); c.t = ts; }
      if (c.v !== vis) { g.style.display = vis ? '' : 'none'; c.v = vis; }
      if (c.a !== al) { g.style.opacity = al < 1 ? al : ''; c.a = al; }
      let f = o.f;
      if (n.swap && f == null) { const i = A.EXPR_NODES.indexOf(n.id); f = i >= 0 ? face[i] : null; }
      if (n.sprite === 'fx') { if (f && c.f !== f) { g.innerHTML = A.FX[f] ? A.FX[f](this.skin.tokens) : ''; c.f = f; } }
      else if (n.swap) { const fr = f || (n.swap === 'eye' ? 'open' : n.swap === 'mouth' ? 'w' : 'none'); if (c.f !== fr) { for (const ch of g.children) ch.style.display = ch.getAttribute('data-f') === fr ? '' : 'none'; c.f = fr; } }
    }
  }
  destroy() { REG.delete(this); this.el.innerHTML = ''; }
}

// ── behaviour brain (field / arena / run …) reads PipBehaviors data
class Brain {
  constructor(inst, data, ctx) { this.i = inst; this.d = data; this.ctx = ctx || {}; this.state = 'idle'; this.tapN = 0; this.tapT = -99; this.idleT = 0; this.now = 0; this.cool = {}; this.nextIdle = this.rnd(this.d.idle.gap_s); this.nextSeason = this.rnd(this.d.season.gap_s); this.busy = false; this.log = []; }
  rnd(r) { return r[0] + Math.random() * (r[1] - r[0]); }
  pick(list) { const ok = list.filter(v => !(this.cool[v.anim] > this.now)); const tot = ok.reduce((a, v) => a + v.w, 0); let x = Math.random() * tot; for (const v of ok) { if ((x -= v.w) <= 0) return v; } return ok[0]; }
  run(anim, then, why) { this.busy = true; this.log.unshift([Math.round(this.now * 10) / 10, anim, why || '']); this.log.length = Math.min(this.log.length, 8); this.i.play(anim, { then: () => { this.busy = false; then && then(); } }); }
  tick(dt) {
    this.now += dt; if (this.busy || this.state === 'sleep' || this.state === 'walk') { if (this.state === 'walk') this.walkTick(dt); return; }
    this.idleT += dt;
    const d = this.d;
    if (this.idleT > d.sleep.after_idle_s) { this.state = 'sleep'; this.run(d.sleep.enter, () => { this.i.setLoop(d.sleep.loop); this.busy = false; }, 'idle ' + d.sleep.after_idle_s + ' s'); this.busy = false; return; }
    if (this.now > this.nextSeason && this.ctx.season) {
      this.nextSeason = this.now + this.rnd(d.season.gap_s);
      const opts = (d.season.by_season[this.ctx.season] || []).filter(o => !(this.cool[o.anim] > this.now));
      if (opts.length) { const o = opts[Math.floor(Math.random() * opts.length)]; this.cool[o.anim] = this.now + o.cooldown_s; this.run(o.anim, null, 'season · ' + this.ctx.season); return; }
    }
    if (this.now > this.nextIdle) {
      this.nextIdle = this.now + this.rnd(d.idle.gap_s);
      if (this.ctx.walk && Math.random() < d.move.walk_chance) { this.startWalk(); return; }
      const v = this.pick(d.idle.variants); if (v) { if (v.cooldown_s) this.cool[v.anim] = this.now + v.cooldown_s; this.run(v.anim, null, 'idle variant'); }
    }
  }
  startWalk() { const z = this.ctx.zone; if (!z) return; this.state = 'walk'; const tx = z[0] + Math.random() * z[2]; this.walk = { tx }; this.i.set({ view: this.d.move.view }); this.i.o.flip = tx < this.ctx.x; this.i.setLoop(this.d.move.anim); this.log.unshift([Math.round(this.now * 10) / 10, this.d.move.anim, 'walk → x ' + Math.round(tx)]); }
  walkTick(dt) {
    const sp = this.d.move.speed_px_s, dx = this.walk.tx - this.ctx.x, st = Math.sign(dx) * Math.min(Math.abs(dx), sp * dt);
    this.ctx.x += st; this.ctx.onMove && this.ctx.onMove(this.ctx.x);
    if (Math.abs(dx) < 1) { this.state = 'idle'; this.i.set({ view: this.d.rest_view }); this.i.o.flip = false; this.i.setLoop(this.d.idle.loop); this.idleT = 0; }
  }
  event(name, arg) {
    const d = this.d; this.idleT = 0;
    if (this.state === 'sleep') { this.state = 'idle'; this.i.loopId = d.idle.loop; this.run(d.sleep.exit, () => { if (name === 'tap') return; this.event(name, arg); }, 'wake on ' + name); return; }
    if (this.state === 'walk') { this.state = 'idle'; this.i.set({ view: d.rest_view }); this.i.o.flip = false; this.i.loopId = d.idle.loop; }
    if (name === 'tap') { if (this.now - this.tapT > d.tap.window_s) this.tapN = 0; this.tapT = this.now; const a = d.tap.steps[Math.min(this.tapN, d.tap.steps.length - 1)]; this.tapN++; this.run(a, null, 'tap ×' + this.tapN); return; }
    const m = d.events && d.events[name]; if (m) this.run(m, null, name);
  }
}

// ── export helpers
function bbox(svg) {
  let x0 = 1e9, y0 = 1e9, x1 = -1e9, y1 = -1e9, sw = 0;
  const add = (x, y) => { if (x < x0) x0 = x; if (x > x1) x1 = x; if (y < y0) y0 = y; if (y > y1) y1 = y; };
  svg.replace(/stroke-width="([\d.]+)"/g, (m, w) => { sw = Math.max(sw, +w); });
  svg.replace(/<ellipse cx="([-\d.]+)" cy="([-\d.]+)" rx="([\d.]+)" ry="([\d.]+)"/g, (m, cx, cy, rx, ry) => { add(+cx - +rx, +cy - +ry); add(+cx + +rx, +cy + +ry); });
  svg.replace(/ d="([^"]+)"/g, (m, d) => { const nums = d.replace(/[A-Za-z]/g, ' ').trim().split(/[\s,]+/).map(Number); for (let i = 0; i + 1 < nums.length; i += 2) add(nums[i], nums[i + 1]); });
  if (x0 > x1) return [0, 0, 1, 1];
  const pad = sw / 2 + 1; return [Math.floor(x0 - pad), Math.floor(y0 - pad), Math.ceil(x1 - x0 + 2 * pad), Math.ceil(y1 - y0 + 2 * pad)];
}
function svgFile(content) { const b = bbox(content); return { box: b, svg: '<svg xmlns="http://www.w3.org/2000/svg" width="' + b[2] + '" height="' + b[3] + '" viewBox="' + b.join(' ') + '">' + content + '</svg>' }; }
function partList() { // [{file, kind, sprite, frame, content(tokens)}]
  const out = [];
  for (const s in A.SPR) for (const f in A.SPR[s].frames) { const fn = A.SPR[s].frames[f]; const one = Object.keys(A.SPR[s].frames).length === 1; out.push({ file: 'parts/' + s + (one ? '' : '__' + f) + '.svg', kind: 'part', sprite: s, frame: one ? 'default' : f, fn }); }
  for (const o in A.OV) out.push({ file: 'overlays/' + o + '.svg', kind: 'overlay', sprite: o, frame: 'default', fn: A.OV[o].art, skin: A.OV[o].skin });
  for (const f in A.FX) out.push({ file: 'fx/' + f + '.svg', kind: 'fx', sprite: 'fx', frame: f, fn: A.FX[f] });
  return out;
}
function shelfPack(boxes, W, scale) { let x = 0, y = 0, rh = 0, pad = 2; const s = [...boxes].sort((a, b) => b[1] - a[1]); for (const [w0, h0] of s) { const w = Math.ceil(w0 * scale) + pad, h = Math.ceil(h0 * scale) + pad; if (x + w > W) { x = 0; y += rh; rh = 0; } x += w; rh = Math.max(rh, h); } return { w: W, h: y + rh }; }
function atlasFor(skinKey, scale) {
  const sk = A.SKINS.find(s => s.key === skinKey); const parts = partList().filter(p => p.kind === 'part' || (p.kind === 'overlay' && sk.overlays.includes(p.sprite)));
  const boxes = parts.map(p => { const b = svgFile(p.fn(sk.tokens)).box; return [b[2], b[3]]; });
  return Object.assign(shelfPack(boxes, 1024, scale), { sprites: boxes.length, scale });
}
function exportAll() {
  const files = {}, partsIdx = {};
  partList().forEach(p => { const f = svgFile(p.fn(A.SKINS[0].tokens)); files['assets/pip/' + p.file] = f.svg; partsIdx[p.kind + ':' + p.sprite + ':' + p.frame] = { file: 'res://assets/pip/' + p.file, offset: [f.box[0], f.box[1]], size: [f.box[2], f.box[3]] }; });
  const rig = { schema: 1, units: 'px of the view frame (256 for front/three_q/side/back, 150 for top = run game px)', views: {} };
  for (const v in A.RIGS) { const r = rigOf(v); rig.views[v] = { frame: r.frame, origin: r.origin, nodes: r.nodes.map(n => {
    const o = { id: n.id, parent: n.parent, pos: [n.x, n.y], rot_deg: n.rot, scale: [n.sx, n.sy], z: n.z };
    if (n.sprite === 'fx') { o.sprite = 'fx'; o.swap_group = 'fx'; }
    else if (n.sprite === 'ov') { o.overlay = n.ov; o.sprite = partsIdx['overlay:' + n.ov + ':default']; }
    else if (n.sprite) { const fr = Object.keys(A.SPR[n.sprite].frames); if (n.swap) { o.swap_group = n.swap; o.frames = {}; fr.forEach(f => o.frames[f] = partsIdx['part:' + n.sprite + ':' + f]); o.default_frame = n.swap === 'eye' ? 'open' : n.swap === 'mouth' ? 'w' : 'none'; } else o.sprite = partsIdx['part:' + n.sprite + ':default']; }
    if (n.hide) o.visible = false; return o; }) }; }
  const fxIdx = {}; for (const f in A.FX) fxIdx[f] = partsIdx['fx:fx:' + f];
  rig.fx_frames = fxIdx; rig.expressions = { nodes: A.EXPR_NODES, sets: A.EXPR };
  const anims = { schema: 1, values: 'deltas from the rest pose of the node in the current view: position += [dx,dy], rotation_degrees += r, scale *= [sx,sy]; modulate:a, visible, frame are absolute',
    key_format: '[t_sec, value..., transition]; transition = Godot Animation key transition (ease curve): 1 linear, 0 constant/hold, 0.5 ease-out, 2 ease-in, -2 ease-in-out (same as Godot ease())',
    layers: 'base = AnimationPlayer "Body" (one loop at a time); overlay = AnimationPlayer "Overlay" (one-shots on pip.r / pip.s / head.r / fx / swaps only)', default_transition: DEF_TR, list: [] };
  ORDER.forEach(id => { const a = ANIMS[id]; const tracks = [];
    for (const n in a.tracks) for (const q in a.tracks[n]) tracks.push({ node: n, prop: GODOT_PROP[q], keys: a.tracks[n][q] });
    anims.list.push({ id, length: a.len, loop: a.loop, layer: a.layer, view: a.view, context: a.ctx, desc: a.desc, speed_bind: a.speed_bind || null, hold_last: !!a.hold, tracks, events: a.events.map(([t, n, g]) => ({ t, name: n, arg: g })), reduce_motion: a.rm }); });
  const skins = { schema: 1, rule: 'new skin = one entry: tokens (7 hex) + overlays[] (+ optional showcase / signature anim ids). Parts are drawn in classic hexes; recolor = PipAssets.recolor_svg(part, classic→skin).', token_names: A.TOKENS, classic: A.SKINS[0].tokens,
    skins: A.SKINS.map(s => { const rec = {}; A.TOKENS.forEach(t => { if (s.tokens[t].toUpperCase() !== A.SKINS[0].tokens[t].toUpperCase()) rec[A.SKINS[0].tokens[t]] = s.tokens[t]; }); return { key: s.key, cosmetic_id: s.id, title: s.title, coin_cost: s.coin_cost, tokens: s.tokens, recolor: rec, overlays: s.overlays.map(o => ({ id: o, file: partsIdx['overlay:' + o + ':default'], attach: Object.fromEntries(Object.keys(A.RIGS).map(v => { const n = rigOf(v).map[o]; return [v, n ? { parent: n.parent, pos: [n.x, n.y], z: n.z, scale: [n.sx, n.sy] } : null]; })) })), showcase_anim: s.showcase, signature_anim: s.signature, detail: s.detail }; }) };
  return { files, rig, anims, skins, partsIdx };
}

G.Pip = { ease, TR, ANIMS, ORDER, def, create: (el, o) => new Inst(el, o), Inst, Brain, reduceMotion: false, sample, bbox, svgFile, partList, atlasFor, exportAll, rigOf, abz };
})(typeof window !== 'undefined' ? window : globalThis);
