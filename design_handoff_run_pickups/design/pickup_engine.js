// Run pickups · preview engine. Deterministic: everything is sampled from scene time T (scrub / slow-mo safe).
// Reads PickupData (pickup_data.js) + Pip runtime. Idle = transforms only; fx sprites are pooled DOM nodes (= Godot Sprite2D pool).
(function (G) {
'use strict';
const D = G.PickupData;
const EASE = {
  lin: x => x, quad_in: x => x * x, quad_out: x => 1 - (1 - x) * (1 - x),
  quad_inout: x => x < .5 ? 2 * x * x : 1 - 2 * (1 - x) * (1 - x),
  back_out: x => { const c = 1.70158, y = x - 1; return 1 + (c + 1) * y * y * y + c * y * y; },
  sine_inout: x => .5 - .5 * Math.cos(Math.PI * x)
};
function key(keys, t, d) {
  if (!keys || !keys.length) return d;
  if (t <= keys[0][0]) return keys[0][1];
  for (let i = 1; i < keys.length; i++) { const b = keys[i]; if (t <= b[0]) { const a = keys[i - 1], u = (t - a[0]) / ((b[0] - a[0]) || 1); return a[1] + (b[1] - a[1]) * (EASE[a[2]] || EASE.lin)(u); } }
  return keys[keys.length - 1][1];
}
function frameAt(fr, t) { let f = fr[0][1]; for (const k of fr) if (t >= k[0]) f = k[1]; return f; }
const clamp = (x, a, b) => Math.max(a, Math.min(b, x));
const BUMP = (b) => [[0, 1, 'quad_out'], [0.06, b, 'back_out'], [0.2, 1]];
const SIDE = { country_bloom: '#4E7A4F', frost_orchard: '#9CB0C8', lantern_meadow: '#2E2650', amber_canopy: '#A9652F', moonlit_warren: '#2E4F5A', coral_tide: '#F59A8B', starfall_glade: '#2E2754', ember_fen: '#3E261C' };
const TUFTS = [[40, 260], [110, 520], [52, 880], [118, 1240], [44, 1660], [960, 330], [1030, 700], [948, 1060], [1020, 1420], [960, 1800]];

class Scene {
  constructor(el, cfg) {
    this.el = el; this.cfg = Object.assign({ season: 'country_bloom', magnet: 0, speed: 400, slow: false, scroll: true, pip: true, loop: 2, pickups: [], lanes: [[0, 1]], base: '../', hud: null, onStats: null }, cfg);
    this.T = 0; this.pool = new Map(); this.maxFx = 0; this.maxTouch = 0;
    el.style.position = 'absolute'; el.style.left = '0'; el.style.top = '0'; el.style.width = '1080px'; el.style.height = '1920px';
    this.build(); this.prepare(); this.frame = 0; if (!this.cfg.noDraw) this.draw(0, -1, false);
    this.vis = true;
    if (this.cfg.hoverPlay) { this.vis = false; if (this.cfg.stillT != null) this.draw(this.cfg.stillT, this.cfg.stillT - .001, false);
      const hz = this.cfg.hoverEl || el; hz.addEventListener('mouseenter', () => { this.vis = true; }); hz.addEventListener('mouseleave', () => { this.vis = false; }); }
    else if (G.IntersectionObserver) { this.io = new IntersectionObserver(es => { this.vis = es[0].isIntersecting; }); this.io.observe(el); }
    this.acc = 0; REG.add(this); start();
  }
  set(o) { Object.assign(this.cfg, o); this.build(); this.prepare(); this.T = 0; const t0 = this.cfg.hoverPlay && this.cfg.stillT != null ? this.cfg.stillT : 0; this.draw(t0, t0 - .001, false); }
  destroy() { REG.delete(this); if (this.io) this.io.disconnect(); this.el.innerHTML = ''; }
  // ── static layers
  build() {
    const c = this.cfg, S = D.KIT.run[c.season] || D.KIT.run.country_bloom, el = this.el;
    el.innerHTML = ''; this.pool.clear();
    el.style.background = S.ground;
    const mk = (css, parent) => { const d = document.createElement('div'); d.style.cssText = css; (parent || el).appendChild(d); return d; };
    [170, 440, 710].forEach(l => mk('position:absolute;left:' + l + 'px;top:0;width:200px;height:1920px;box-sizing:border-box;background:' + S.lane + ';border-left:4px solid ' + S.edge + ';border-right:4px solid ' + S.edge));
    this.dash = mk('position:absolute;left:0;top:0;width:1080px;height:2040px;will-change:transform');
    [405, 675].forEach(x => { for (let y = -128; y < 1920; y += 108) mk('position:absolute;left:' + (x - 3) + 'px;top:' + y + 'px;width:6px;height:46px;border-radius:3px;background:' + S.seam, this.dash); });
    this.tufts = mk('position:absolute;left:0;top:0;width:1080px;height:1920px');
    this.tuftEls = TUFTS.map(([x, y], i) => { const h = 38 + (i % 3) * 8; const d = mk('position:absolute;left:' + x + 'px;top:0;width:' + Math.round(h * .6) + 'px;height:' + h + 'px;background:' + (SIDE[c.season] || '#4E7A4F') + ';clip-path:polygon(50% 0%,100% 100%,0% 100%)', this.tufts); d._y = y; return d; });
    this.lowL = mk('position:absolute;inset:0'); // pickups + fx below Pip
    this.pipW = mk('position:absolute;left:0;top:0;width:150px;height:150px;will-change:transform');
    this.magEl = document.createElement('img'); this.magEl.style.cssText = 'position:absolute;left:0;top:0;pointer-events:none;will-change:transform'; el.insertBefore(this.magEl, this.pipW);
    const R = D.MAGNET.radius(c.magnet), sz = 2 * R + 8; this.magEl.src = c.base + D.MAGNET.files[c.magnet]; this.magEl.width = sz; this.magEl.height = sz; this.magSz = sz;
    this.magEl.style.display = c.pip ? 'block' : 'none';
    this.highL = mk('position:absolute;inset:0');
    this.hudL = mk('position:absolute;inset:0;z-index:20');
    if (c.pip && G.Pip) { this.pip = G.Pip.create(this.pipW, { view: 'top', size: 150, loop: 'run_gallop', face: 'determined' }); this.pip.paused = true; }
    else this.pip = null;
  }
  // ── capture / event schedule (pure function of cfg)
  pipX(T) {
    const L = this.cfg.lanes; let x = D.LANES[L[0][1]];
    for (let i = 1; i < L.length; i++) { const [t, lane] = L[i]; if (T < t) break; const from = D.LANES[L[i - 1][1]], to = D.LANES[lane]; x = from + (to - from) * EASE.quad_out(clamp((T - t) / .12, 0, 1)); }
    return x;
  }
  prepare() {
    const c = this.cfg, R = D.MAGNET.radius(c.magnet), M = D.MAGNET.fly, ev = [];
    this.items = c.pickups.map((p, i) => Object.assign({ i, rar: 1, twin: false, ph: (p.lane * 0.37 + i * 0.61) % 1 }, p));
    for (const it of this.items) {
      const rp = it.kind === 'coin' ? 18 : 26; it.tc = null;
      for (let T = 0; T < c.loop; T += 1 / 240) {
        const x = D.LANES[it.lane] + (it.dx || 0), y = it.y + (c.scroll ? c.speed * T : 0), px = this.pipX(T);
        const d = Math.hypot(x - px, y - D.PIP_Y);
        if (c.pip && d <= R + rp) { it.tc = T; it.S = [x - px, y - D.PIP_Y]; break; }
      }
      if (it.tc == null) continue;
      const dC = Math.hypot(it.S[0] - D.ANCHOR.C[0], it.S[1] - D.ANCHOR.C[1]);
      it.tf = M.t_min + (M.t_max - M.t_min) * clamp(dC / 232, 0, 1);
      it.te = it.tc + it.tf; ev.push(it);
    }
    ev.sort((a, b) => a.te - b.te);
    let lastCoin = -9, n = 0;
    for (const it of ev) {
      if (it.kind === 'coin') { n = it.te - lastCoin <= D.STREAK.window ? Math.min(n + 1, D.STREAK.max) : 1; lastCoin = it.te; it.ev = D.EVENTS['coin_n' + n]; }
      else it.ev = D.EVENTS['seed_r' + it.rar + (it.twin ? '_twin' : '')];
      it.seed = it.kind === 'seed' ? (it.seed || D.KIT.SEEDS[c.season][it.rar - 1]) : null;
      it.tArr = it.te + it.ev.hud.t0 + D.HUD.flight.dur;
    }
    this.events = ev;
  }
  // ── sprite pool
  spr(id, name, seed, layer) {
    let e = this.pool.get(id);
    const want = name + '|' + (seed || '');
    if (!e || e._want !== want) {
      if (e) e.remove();
      const base = this.cfg.base;
      if (name === 'sapling' || name === 'bloom') {
        const f = seed + (name === 'bloom' ? '_t3' : '_t1'), cr = D.KIT.crops[f] || [0, 0, 256, 256];
        const h = (D.SPRITES[name].h), w = Math.round(h * cr[2] / cr[3]);
        e = document.createElement('div'); e._w = w; e._h = h; e._bottom = true;
        const kk = h / cr[3]; e.style.overflow = 'hidden'; e.style.width = w + 'px'; e.style.height = h + 'px';
        e.innerHTML = '<img src="' + base + 'design/ref/flowers/' + f + '.svg" width="' + Math.round(256 * kk) + '" height="' + Math.round(256 * kk) + '" style="position:absolute;left:' + Math.round(-cr[0] * kk) + 'px;top:' + Math.round(-cr[1] * kk) + 'px;max-width:none">';
      } else if (name === 'pill') {
        e = document.createElement('div'); e._w = 0; e._h = 64; e._pill = true;
        e.style.cssText = 'height:64px;box-sizing:border-box;padding:0 18px 0 12px;border-radius:32px;background:#FFF8F0;border:3px solid #2D3436;box-shadow:0 4px 0 rgba(18,28,22,.42);display:flex;align-items:center;gap:8px;font:900 44px/1 Nunito,sans-serif;color:#2D3436;white-space:nowrap';
        e.innerHTML = '<img src="' + base + 'design/icons/' + (seed === 'coin' ? 'icon_coin' : 'icon_seed') + '.svg" width="44" height="44" style="display:block"><span></span>';
      } else {
        const s = D.SPRITES[name]; e = document.createElement('img'); e.src = base + s.file; e.width = s.w; e.height = s.h; e._w = s.w; e._h = s.h;
      }
      e.style.position = 'absolute'; e.style.left = '0'; e.style.top = '0'; e.style.willChange = 'transform'; e.style.pointerEvents = 'none';
      e._want = want; this.pool.set(id, e);
    }
    const L = layer === 'hud' ? this.hudL : layer === 'high' ? this.highL : this.lowL;
    if (e.parentNode !== L) L.appendChild(e);
    e._seen = this.frame; return e;
  }
  put(e, x, y, sx, sy, r, a, z) {
    e.style.display = e._pill ? 'flex' : 'block';
    if (e._pill && !e._w) e._w = 12 + 44 + 8 + 27 * (e.lastChild.textContent.length) + 18 + 6;
    const w = e._w, h = e._h, oy = e._bottom ? h : h / 2;
    e.style.transformOrigin = (w / 2) + 'px ' + oy + 'px';
    e.style.transform = 'translate(' + (x - w / 2).toFixed(1) + 'px,' + (y - oy).toFixed(1) + 'px) rotate(' + (r || 0).toFixed(1) + 'deg) scale(' + sx.toFixed(3) + ',' + sy.toFixed(3) + ')';
    e.style.opacity = a == null ? 1 : clamp(a, 0, 1); e.style.zIndex = z || 0;
  }
  // ── idle (transforms only)
  idleCoin(it, x, y, T, k) {
    const I = D.IDLE.coin, ph = it.ph * I.spin.period, dy = I.bob.amp * Math.sin(I.bob.w * T + it.ph * 6.28);
    const sh = this.spr(k + 'sh', 'shadow'); this.put(sh, x + I.shadow.at[0], y + I.shadow.at[1], 1, 1, 0, 1, 0);
    const u = ((T + ph) % I.spin.period) / I.spin.turn; let sx = 1, edge = false;
    if (u < 1) { const cc = Math.cos(2 * Math.PI * u); sx = Math.max(0.12, Math.abs(cc)); edge = Math.abs(cc) < 0.25; }
    const co = this.spr(k + 'c', edge ? 'coin_edge' : 'coin'); this.put(co, x, y + dy, edge ? 1 : sx, 1, 0, 1, 2);
    const g = I.glint, f = ((T + ph) % I.spin.period) / I.spin.period;
    const gl = this.spr(k + 'g', 'spark');
    if (f >= g.t[0] && f <= g.t[1]) { const s = key(g.s, f, 0); this.put(gl, x + g.at[0], y + dy + g.at[1], s, s, g.r[0] + (g.r[1] - g.r[0]) * (f - g.t[0]) / (g.t[1] - g.t[0]), 1, 3); } else gl.style.display = 'none';
    return 3;
  }
  idleSeed(it, x, y, T, k) {
    const I = D.IDLE.seed, H = I.halo[it.rar], tt = T + it.ph * 3;
    const sh = this.spr(k + 'sh', 'shadow'); this.put(sh, x + I.shadow.at[0], y + I.shadow.at[1], I.shadow.s[0], I.shadow.s[1], 0, 1, 0);
    let n = 1;
    if (H) {
      const p = 1 + H.pulse.amp * Math.sin(2 * Math.PI * tt / H.pulse.period);
      const ha = this.spr(k + 'h', H.sprite); this.put(ha, x + H.at[0], y + H.at[1], p, p, H.rot_deg_s * tt, 1, 1); n++;
      for (let i = 0; i < H.sparks.n; i++) { const a = (H.sparks.deg_s * tt + i * 360 / H.sparks.n) * Math.PI / 180, s = H.sparks.s * (0.75 + 0.25 * Math.sin(tt * 5 + i * 2));
        const sp = this.spr(k + 's' + i, 'spark'); this.put(sp, x + H.at[0] + Math.cos(a) * H.sparks.radius, y + H.at[1] + Math.sin(a) * H.sparks.radius * .8, s, s, a * 57, 1, 4); n++; }
    }
    const so = this.spr(k + 'so', 'soil'); this.put(so, x + I.soil_at[0], y + I.soil_at[1], 1, 1, 0, 1, 2); n++;
    const sc = (H && H.sapling_scale) || 1, bob = I.bob.amp * Math.sin(I.bob.w * tt);
    const sa = this.spr(k + 'sa', 'sapling', it.seed); this.put(sa, x + I.sapling_base[0], y + I.sapling_base[1] + Math.min(0, bob), sc, sc * (1 + 0.02 * Math.sin(I.bob.w * tt)), I.sway.deg * Math.sin(2 * Math.PI * tt / I.sway.period), 1, 3); n++;
    const dw = this.spr(k + 'dw', 'dew'); this.put(dw, x + I.dew.at[0] + I.sway.deg * .9 * Math.sin(2 * Math.PI * tt / I.sway.period), y + I.dew.at[1] + I.dew.bob.amp * Math.sin(I.dew.bob.w * tt), 1, 1, 0, 1, 4); n++;
    return n;
  }
  // ── frame
  tick(dt0) {
    this.acc += dt0; const fps = this.cfg.fps || 30;
    if (this.acc < 1 / fps - 0.002) return;
    const dt = Math.min(.1, this.acc); this.acc = 0;
    if (G.__pfPause || !this.vis) return;
    if (this.pip) this.pip.tick(dt * (this.cfg.slow ? .25 : 1) * this.cfg.speed / 400 / (this.pip.speed || 1));
    const c = this.cfg, scale = c.slow ? .25 : 1, prevT = this.T;
    let T = this.T + dt * scale; let wrapped = false;
    if (T >= c.loop) { T %= c.loop; wrapped = true; }
    this.draw(T, prevT, wrapped);
  }
  drawAt(T) { this.draw(T, T - 0.0001, false); }
  draw(T, prevT, wrapped) {
    const c = this.cfg, scale = c.slow ? .25 : 1;
    this.T = T; this.frame = (this.frame || 0) + 1;
    // scroll
    const off = c.scroll ? (c.speed * T) : 0;
    this.dash.style.transform = 'translateY(' + (off % 108).toFixed(1) + 'px)';
    this.tuftEls.forEach(d => { d.style.transform = 'translateY(' + (((d._y + off) % 1920 + 1920) % 1920).toFixed(1) + 'px)'; });
    // pip
    const px = this.pipX(T), py = D.PIP_Y;
    if (this.pip) {
      this.pipW.style.transform = 'translate(' + (px - 75) + 'px,' + (py - 75) + 'px)';
      for (let i = 1; i < c.lanes.length; i++) { const t = c.lanes[i][0]; if (crossed(prevT, T, wrapped, t)) this.pip.play(c.lanes[i][1] < c.lanes[i - 1][1] ? 'lane_left' : 'lane_right'); }
    }
    let pull = 0;
    // pickups
    let fx = 0, touches = 0, coins = 0, seeds = 0, bumps = { coin: 1, seed: 1 }, toasts = [];
    for (const it of this.items) {
      const k = 'p' + it.i + '_';
      const wx = D.LANES[it.lane] + (it.dx || 0), wy = it.y + (c.scroll ? c.speed * T : 0);
      if (it.tc == null || T < it.tc) { if (wy > -200 && wy < 2100) { if (it.kind === 'coin') this.idleCoin(it, wx, wy, T, k); else this.idleSeed(it, wx, wy, T, k); } continue; }
      if (T < it.te) { // magnet flight: whole pickup homes to C along a bulged arc
        const M = D.MAGNET.fly, u = EASE.quad_in(clamp((T - it.tc) / it.tf, 0, 1));
        const C = D.ANCHOR.C, S = it.S, dx = C[0] - S[0], dy = C[1] - S[1], dd = Math.hypot(dx, dy) || 1;
        const side = S[0] === 0 ? (it.i % 2 ? 1 : -1) : Math.sign(S[0]);
        const nx = -dy / dd * side, ny = dx / dd * side, bul = M.arc * dd * Math.sin(Math.PI * u);
        const x = px + S[0] + dx * u + nx * bul, y = py + S[1] + dy * u + ny * bul;
        const s = 1 + (M.scale_end - 1) * u;
        if (it.kind === 'coin') { const co = this.spr(k + 'c', 'coin'); this.put(co, x, y, s, s, 0, 1, 2); this.hide(k + 'g'); this.hide(k + 'sh'); }
        else { const so = this.spr(k + 'so', 'soil'); this.put(so, x, y + 18 * s, s, s, 0, 1, 2); const sa = this.spr(k + 'sa', 'sapling', it.seed); this.put(sa, x, y + 20 * s, s, s, -8 * Math.sin(Math.PI * u), 1, 3);
          ['sh', 'dw', 'h', 's0', 's1', 's2'].forEach(q => this.hide(k + q)); }
        if ((T - it.tc) < .1) pull = Math.max(pull, 1 - (T - it.tc) / .1);
        continue;
      }
      ['sh', 'dw', 'g', 'h', 's0', 's1', 's2'].forEach(q => this.hide(k + q));
      const e = T - it.te, E = it.ev;
      if (crossed(prevT, T, wrapped, it.te) && this.pip) this.pip.play(E.pip);
      if (e <= E.len) touches++;
      for (const sp of E.sprites) {
        const id = sp.own ? (sp.sprite === 'coin' ? k + 'c' : sp.sprite === 'soil' ? k + 'so' : sp.sprite === 'sapling' ? k + 'sa' : k + 'h') : k + 'fx_' + sp.id;
        if (e < sp.t0 || e > sp.t1) { this.hide(id); continue; }
        const A = D.ANCHOR[sp.at] || D.ANCHOR.C, K = sp.keys || {};
        let name = sp.frame ? frameAt(sp.frame, e) : sp.sprite;
        const s = key(K.s, e, 1), el = this.spr(id, name, it.seed, sp.z >= 2 ? 'high' : 'low');
        this.put(el, px + A[0] + key(K.x, e, 0), py + A[1] + key(K.y, e, 0), s * key(K.sx, e, 1), s * key(K.sy, e, 1), key(K.r, e, 0), key(K.a, e, 1), sp.z);
        fx++;
      }
      // HUD pill + chip bump
      const H = D.HUD, h = E.hud, tf = e - h.t0, dst = H.chips[h.chip];
      const pid = k + 'pill';
      if (c.hud && tf >= 0 && tf <= H.flight.dur) {
        const u = EASE.quad_inout(tf / H.flight.dur), x0 = px + D.ANCHOR.C[0], y0 = py + D.ANCHOR.C[1] - 40;
        const cx = x0 + 0.25 * (dst[0] - x0), cy = y0 - 260, x = (1 - u) * (1 - u) * x0 + 2 * (1 - u) * u * cx + u * u * dst[0], y = (1 - u) * (1 - u) * y0 + 2 * (1 - u) * u * cy + u * u * dst[1];
        const el = this.spr(pid, 'pill', h.chip, 'hud'); if (el.lastChild.textContent !== h.text) { el.lastChild.textContent = h.text; el._w = 0; } const s = key(H.flight.s, tf, 1) * h.pill_scale;
        this.put(el, x, y, s, s, 0, key(H.flight.a, tf, 1), 30); fx++;
      } else this.hide(pid);
      if (T >= it.tArr) {
        if (it.kind === 'coin') coins++; else seeds += it.twin ? 2 : 1;
        const tb = T - it.tArr; if (tb < .2) bumps[h.chip] = Math.max(bumps[h.chip], key(BUMP(h.bump), tb, 1));
        if (it.kind === 'seed' && tb < 1.4) toasts.push([it.tArr, (it.twin ? '+2 ' : '+1 ') + D.KIT.names[it.seed]]);
      }
    }
    // magnet ring
    if (this.pip) { const R = this.magSz / 2, ps = 1 + (D.MAGNET.ring.pull_pulse.s - 1) * pull; this.magEl.style.transform = 'translate(' + (px - R) + 'px,' + (py - R) + 'px) rotate(' + (D.MAGNET.ring.rot_deg_s * T).toFixed(1) + 'deg) scale(' + ps.toFixed(3) + ')'; }
    // HUD hooks
    const hud = c.hud;
    if (hud) {
      const w = (el, prop, v) => { if (!el) return; const kk = '_pf_' + prop; if (el[kk] === v) return; el[kk] = v; if (prop === 'text') el.textContent = v; else el.style.transform = v; };
      w(hud.coin, 'tf', 'scale(' + bumps.coin.toFixed(3) + ')'); w(hud.seed, 'tf', 'scale(' + bumps.seed.toFixed(3) + ')');
      w(hud.coinNum, 'text', String((hud.coins || 0) + coins)); w(hud.seedNum, 'text', String((hud.seeds || 0) + seeds));
      toasts.sort((a, b) => b[0] - a[0]); toasts = toasts.slice(0, 2);
      for (let i = 0; i < 2; i++) { const id = 'toast' + i; if (!toasts[i]) { this.hide(id); continue; }
        let el = this.pool.get(id); if (!el) { el = document.createElement('div'); el.style.cssText = 'position:absolute;left:0;top:0;padding:12px 26px;border-radius:22px;background:rgba(22,33,27,.78);font:800 38px/1.1 Nunito,sans-serif;color:#FFF8F0;white-space:nowrap'; this.pool.set(id, el); this.hudL.appendChild(el); }
        el._seen = this.frame; el.textContent = toasts[i][1]; el.style.display = 'block'; el.style.transform = 'translate(' + (806 - (52 + 19 * toasts[i][1].length) / 2) + 'px,' + (214 + i * 80) + 'px)'; }
    }
    // cleanup
    this.pool.forEach(e => { if (e._seen !== this.frame) e.style.display = 'none'; });
    this.maxFx = Math.max(this.maxFx, fx); this.maxTouch = Math.max(this.maxTouch, touches);
    if (c.onStats && this.frame % 30 === 0) c.onStats({ fx, maxFx: this.maxFx, touches, maxTouch: this.maxTouch, T });
  }
  hide(id) { const e = this.pool.get(id); if (e) { e.style.display = 'none'; e._seen = -1; } }
}
const REG = new Set(); let raf = 0, last = 0;
function loop(ts) { const dt = last ? Math.min(.1, (ts - last) / 1000) : 0; last = ts; REG.forEach(s => { if (!s.el.isConnected) { REG.delete(s); return; } s.tick(dt); }); raf = REG.size ? requestAnimationFrame(loop) : 0; }
function start() { if (!raf) { last = 0; raf = requestAnimationFrame(loop); } }
function crossed(a, b, wrapped, t) { return wrapped ? (t > a || t <= b) : (a < t && t <= b); }

// ── scenarios (world y at T = 0; Pip y 1574; scroll 400 px/s unless noted)
const Y = (tHit, extra) => D.PIP_Y - 66 - 400 * tHit + (extra || 0);
const SCENARIOS = {
  coin: { label: 'Coin', loop: 1.6, pickups: [{ kind: 'coin', lane: 1, y: Y(.7) }] },
  seed1: { label: 'Sjeme ★1', loop: 1.8, pickups: [{ kind: 'seed', rar: 1, lane: 1, y: Y(.7) }] },
  seed2: { label: 'Sjeme ★2', loop: 1.8, pickups: [{ kind: 'seed', rar: 2, lane: 1, y: Y(.7) }] },
  seed3: { label: 'Sjeme ★3', loop: 1.9, pickups: [{ kind: 'seed', rar: 3, lane: 1, y: Y(.7) }] },
  twin: { label: 'Twin +2', loop: 1.9, pickups: [{ kind: 'seed', rar: 1, twin: true, lane: 1, y: Y(.7) }] },
  streak: { label: 'Niz 5 coina / s', loop: 2.2, speed: 600, lanes: [[0, 1], [0.98, 2]],
    pickups: [0, 1, 2, 3, 4].map(i => ({ kind: 'coin', lane: i < 3 ? 1 : 2, y: D.PIP_Y - 66 - 600 * (0.5 + 0.2 * i) })) },
  magnet: { label: 'Magnet mix', loop: 2.6, lanes: [[0, 1], [1.2, 0]],
    pickups: [{ kind: 'coin', lane: 1, y: Y(.5) }, { kind: 'seed', rar: 2, lane: 1, y: Y(.85) }, { kind: 'coin', lane: 0, dx: 0, y: Y(1.55) }, { kind: 'seed', rar: 3, lane: 0, y: Y(1.95) }, { kind: 'coin', lane: 2, y: Y(1.0) }] },
  idle: { label: 'Idle', loop: 4, scroll: false, pip: false,
    pickups: [{ kind: 'coin', lane: 0, y: 200 }, { kind: 'coin', lane: 0, y: 360 }, { kind: 'seed', rar: 1, lane: 1, y: 260 }, { kind: 'seed', rar: 2, lane: 2, y: 200 }, { kind: 'seed', rar: 3, lane: 2, y: 420 }, { kind: 'coin', lane: 1, y: 440 }] }
};
G.PickupEngine = { Scene, SCENARIOS, EASE, key, REG };
})(typeof window !== 'undefined' ? window : globalThis);
