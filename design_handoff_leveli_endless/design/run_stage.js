// run_stage.js — mock motor runa za design_handoff_leveli_endless (DOM; po frejmu samo transform / opacity / tekst ≤ 1/s).
// Nije za Godot: pokazuje ritam, mjere i budžete. Brojevi i crteži dolaze iz le_kit.js i ../assets/**.
const A = '../assets/', R = 'ref/';
const clamp = (v, a = 0, b = 1) => Math.max(a, Math.min(b, v));
const f2 = v => (Math.round(v * 100) / 100).toString();
const outBack = t => { const c = 1.70158; return 1 + (c + 1) * Math.pow(t - 1, 3) + c * Math.pow(t - 1, 2); };
const out3 = t => 1 - Math.pow(1 - t, 3), in2 = t => t * t, io2 = t => t < .5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2;
const bell = (t, a, b) => t <= a || t >= b ? 0 : Math.sin(Math.PI * (t - a) / (b - a));
function el(tag, css, parent, html) { const e = document.createElement(tag); if (css) e.style.cssText = css; if (html != null) e.innerHTML = html; if (parent) parent.appendChild(e); return e; }
const IMG = (src, w, h, parent, extra) => { const e = el('img', 'position:absolute;left:0;top:0;width:' + w + 'px;height:' + h + 'px;display:block;will-change:transform;' + (extra || ''), parent); e.src = src; e.alt = ''; return e; };
const CHIP = 'position:absolute;box-sizing:border-box;border-radius:30px;background:#FFF8F0;border:3px solid #CBC2B6;box-shadow:0 6px 0 rgba(18,28,22,.42);display:flex;align-items:center;font-family:Nunito,system-ui,sans-serif;color:#2D3436;';

export class RunStage {
  constructor(host, LE, K, opts) {
    this.host = host; window.__stage = this; this.LE = LE; this.K = K; this.o = {}; this.t = 0; this.live = 0; this.maxLive = 0; this.fx = [];
    host.style.cssText = 'position:absolute;left:0;top:0;width:1080px;height:1920px;overflow:hidden;font-family:Nunito,system-ui,sans-serif';
    this.set(opts || {});
    this._alive = true; this._last = performance.now();
    const loop = () => { if (!this._alive) return; if (window.__pause) { this._last = performance.now(); this._raf = requestAnimationFrame(loop); return; } const now = performance.now(), dt = Math.min(0.05, (now - this._last) / 1000); this._last = now; this.step(dt); this._raf = requestAnimationFrame(loop); };
    if (window.__noStage) return;
    this._raf = requestAnimationFrame(loop);
    this._pump = setInterval(() => { if (this._alive && !window.__pause && performance.now() - this._last > 80) { const now = performance.now(); this.step(Math.min(0.05, (now - this._last) / 1000)); this._last = now; } }, 40);
  }
  destroy() { this._alive = false; cancelAnimationFrame(this._raf); clearInterval(this._pump); if (this.pip) this.pip.destroy(); this.host.innerHTML = ''; }
  set(o) {
    const prev = this.o; this.o = Object.assign({ season: 'country_bloom', mode: 'level', level: 7, speed: 436, loop: 6, items: [], lanes: [[0, 1]], t0: 0, slow: false, rail: true, best: 0, endlessT: 0 }, o);
    if (prev.season !== this.o.season || !this.built) this.build();
    this.items(); this.hud(); this.t = 0; this.fx = []; this.gateDone = false; this.bestDone = false; this.prevT = -1; this.preBest();
  }
  // ── statični i klizni slojevi ──
  build() {
    const L = this.LE.runLayers(this.K, this.o.season); this.L = L; const h = this.host; h.innerHTML = ''; this.built = true;
    h.style.background = L.ground;
    const mkLayer = (layer, z) => { if (!layer) return null; const H = 1920 + 2 * layer.period; const d = el('div', 'position:absolute;left:0;top:0;width:1080px;height:' + H + 'px;will-change:transform;z-index:' + z, h); const im = el('img', 'display:block;width:1080px;height:' + H + 'px', d); im.alt = ''; im.src = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" width="1080" height="' + H + '" viewBox="0 ' + (-layer.period) + ' 1080 ' + H + '">' + layer.svg + '</svg>'); d._p = layer.period; d._k = layer.speed || 1; return d; };
    this.far = mkLayer(L.far, 0);
    const lanes = el('img', 'position:absolute;left:0;top:0;width:1080px;height:1920px;z-index:1', h); lanes.alt = ''; lanes.src = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" width="1080" height="1920">' + [170, 440, 710].map(x => '<rect x="' + x + '" y="-10" width="200" height="1940" fill="' + L.lane + '" stroke="' + L.edge + '" stroke-width="4"/>').join('') + '</svg>');
    this.tile = mkLayer(L.tile, 2); this.seams = mkLayer(L.seams, 2); this.near = mkLayer(L.near, 2);
    this.world = el('div', 'position:absolute;inset:0;z-index:3', h);
    this.pipW = el('div', 'position:absolute;left:0;top:0;width:150px;height:150px;z-index:4;will-change:transform', h);
    this.fxL = el('div', 'position:absolute;inset:0;z-index:6;pointer-events:none', h);
    this.hudL = el('div', 'position:absolute;inset:0;z-index:7;pointer-events:none', h);
    this.topL = el('div', 'position:absolute;inset:0;z-index:8;pointer-events:none', h);
    if (this.pip) { this.pip.destroy(); this.pip = null; }
    const mount = () => { if (!this._alive && this._alive !== undefined) return; if (!window.Pip || !window.Pip.create) { setTimeout(mount, 80); return; } this.pip = window.Pip.create(this.pipW, { view: 'top', skin: 'classic', size: 150, loop: 'run_gallop', face: 'determined', still: !!window.__pipStill }); };
    mount();
    this.pool = {};
  }
  // ── prepreke, parovi, coini, cilj ──
  items() {
    this.world.innerHTML = ''; const L = this.L, s = this.o.season, LN = this.LE.LANES;
    const collar = (w, h) => el('div', 'position:absolute;left:0;top:0;width:' + w + 'px;height:' + h + 'px;border-radius:50%;box-sizing:border-box;background:' + L.collar[0] + ';border:3px solid ' + L.collar[1], null);
    const shadow = (w, h) => el('div', 'position:absolute;left:0;top:0;width:' + w + 'px;height:' + h + 'px;border-radius:50%;background:rgba(10,14,20,.30)', null);
    this.its = this.o.items.map(it => {
      const g = el('div', 'position:absolute;left:0;top:0;width:0;height:0;will-change:transform', this.world); it.g = g; it.draws = 0;
      if (it.kind === 'single') { const x = LN[it.lane]; const c = collar(240, 52); c.style.transform = 'translate(' + (x - 120) + 'px,' + (69 - 26) + 'px)'; g.appendChild(c); const sh = shadow(168, 40); sh.style.transform = 'translate(' + (x - 84) + 'px,35px)'; g.appendChild(sh); const im = IMG(L.obstacles[it.art || 0], 176, 150, g); im.style.transform = 'translate(' + (x - 88) + 'px,-81px)'; it.draws = 4; }
      else if (it.kind === 'pair') {
        const [a, b] = it.lanes;
        if (b - a === 1) { const mid = (LN[a] + LN[b]) / 2, flip = a === 1; const c = collar(510, 56); c.style.transform = 'translate(' + (mid - 255) + 'px,41px)'; g.appendChild(c); const sh = shadow(440, 44); sh.style.transform = 'translate(' + (mid - 220) + 'px,33px)'; g.appendChild(sh); const im = IMG(A + 'obstacles/' + s + '_pair_wide.svg', 460, 220, g); im.style.transform = 'translate(' + (mid - 230) + 'px,-151px)' + (flip ? ' scaleX(-1)' : ''); it.draws = 4; }
        else { [0, 2].forEach(l => { const x = LN[l]; const c = collar(240, 52); c.style.transform = 'translate(' + (x - 120) + 'px,43px)'; g.appendChild(c); const sh = shadow(168, 40); sh.style.transform = 'translate(' + (x - 84) + 'px,35px)'; g.appendChild(sh); const im = IMG(A + 'obstacles/' + s + '_pair_side.svg', 240, 220, g); im.style.transform = 'translate(' + (x - 120) + 'px,-151px)' + (l === 2 ? ' scaleX(-1)' : ''); }); it.draws = 8; }
      } else if (it.kind === 'coin') { const x = LN[it.lane]; const sh = shadow(64, 18); sh.style.transform = 'translate(' + (x - 32) + 'px,31px)'; g.appendChild(sh); const im = IMG('icons/icon_coin.svg', 84, 84, g); im.style.transform = 'translate(' + (x - 42) + 'px,-42px)'; }
      else if (it.kind === 'gate') {
        const arch = IMG(A + 'finish/' + s + '_arch.svg', 900, 240, g); arch.style.transform = 'translate(90px,-480px)'; arch.style.transformOrigin = '450px 150px';
        const p1 = IMG(A + 'finish/' + s + '_post.svg', 120, 440, g); p1.style.transform = 'translate(78px,-372px)';
        const p2 = IMG(A + 'finish/' + s + '_post.svg', 120, 440, g); p2.style.transform = 'translate(882px,-372px) scaleX(-1)';
        const tp = IMG(A + 'finish/tape.svg', 800, 80, g); tp.style.transform = 'translate(140px,-40px)';
        const h1 = IMG(A + 'finish/tape_half.svg', 420, 80, g, 'transform-origin:12px 40px;display:none'); const h2 = IMG(A + 'finish/tape_half.svg', 420, 80, g, 'transform-origin:12px 40px;display:none');
        it.parts = { arch, tp, h1, h2 }; it.draws = 4;
      }
      return it;
    });
  }
  // ── HUD (Run HUD v2) ──
  hud() {
    const H = this.hudL, LE = this.LE, o = this.o; H.innerHTML = '';
    this.chip = el('div', CHIP + 'left:40px;top:60px;height:128px;padding:0 32px;gap:12px;justify-content:center;transform-origin:50% 50%', H);
    if (o.mode === 'level') {
      const B = LE.bandOf(o.level);
      this.chip.innerHTML = '<img src="icons/progress_flag.svg" style="width:38px;height:57px;flex:0 0 auto"><div style="font:900 48px/1 Nunito,system-ui,sans-serif;white-space:nowrap">Level ' + o.level + '</div><img src="' + A + 'bands/tag_' + B + (LE.isPeak(o.level) ? '_peak' : '') + '.svg" style="height:40px;flex:0 0 auto">';
    } else {
      this.chip.style.flexDirection = 'column'; this.chip.style.alignItems = 'flex-start'; this.chip.style.gap = '6px'; this.chip.style.padding = '0 26px';
      this.chip.innerHTML = '<div style="display:flex;align-items:center;gap:10px"><img src="' + A + 'endless/rings.svg" style="width:46px;height:26px"><div data-r="clock" style="font:900 52px/1 Nunito,system-ui,sans-serif;font-variant-numeric:tabular-nums;min-width:112px">0:00</div><div data-r="pace" style="height:46px;box-sizing:border-box;padding:0 14px;border-radius:23px;border:3px solid #2D3436;display:flex;align-items:center;font:900 28px/1 Nunito,system-ui,sans-serif;white-space:nowrap">Pace 0</div></div><div data-r="best" style="display:flex;align-items:center;gap:8px;height:34px;font:800 28px/1 Nunito,system-ui,sans-serif;color:#555C5E;white-space:nowrap"><img src="' + A + 'endless/trophy.svg" style="width:30px;height:30px"><span data-r="bestT">Best 4:25</span></div>';
      this.cClock = this.chip.querySelector('[data-r=clock]'); this.cPace = this.chip.querySelector('[data-r=pace]'); this.cBest = this.chip.querySelector('[data-r=best]'); this.cBestT = this.chip.querySelector('[data-r=bestT]');
      if (!o.best) this.cBest.style.display = 'none';
    }
    const ch = (x, icon, n) => el('div', CHIP + 'left:' + x + 'px;top:60px;width:180px;height:128px;justify-content:center;gap:10px', H, '<img src="icons/' + icon + '.svg" style="width:52px;height:52px"><div style="font:900 56px/1 Nunito,system-ui,sans-serif;font-variant-numeric:tabular-nums">' + n + '</div>');
    ch(520, 'icon_coin', o.coins ?? 18); ch(716, 'icon_seed', o.seeds ?? 6);
    el('div', CHIP + 'left:912px;top:60px;width:128px;height:128px;justify-content:center', H, '<img src="icons/icon_pause.svg" style="width:60px;height:60px">');
    this.rail = null;
    if (o.mode === 'level' && o.rail) {
      const r = el('div', 'position:absolute;left:24px;top:200px;width:116px;height:1540px', H); this.rail = r;
      r.innerHTML = '<div style="position:absolute;left:46px;top:100px;width:28px;height:1400px;box-sizing:border-box;border-radius:14px;background:#FFF8F0;border:3px solid #2D3436;box-shadow:0 5px 0 rgba(18,28,22,.42);overflow:hidden"><div data-r="fill" style="position:absolute;left:3px;right:3px;bottom:3px;height:0;border-radius:9px;background:#A8E6CF"></div><div style="position:absolute;left:0;right:0;top:697px;height:4px;background:#2D3436"></div></div><img src="icons/progress_start.svg" style="position:absolute;left:36px;top:1488px;width:48px;height:24px"><div data-r="ring" style="position:absolute;left:4px;top:2px;width:108px;height:108px;box-sizing:border-box;border-radius:50%;border:6px solid #A8E6CF;display:none"></div><img data-r="flag" src="icons/progress_flag.svg" style="position:absolute;left:49px;top:6px;width:64px;height:96px;transform-origin:11px 92px"><div data-r="pip" style="position:absolute;left:12px;top:0;width:92px;height:92px;box-sizing:border-box;border-radius:50%;background:#FFF8F0;border:4px solid #2D3436;box-shadow:0 6px 0 rgba(18,28,22,.42);overflow:hidden;display:grid;place-items:center"><img src="icons/pip_hud_classic.svg" style="width:84px;height:84px;margin-top:2px"></div>';
      this.rFill = r.querySelector('[data-r=fill]'); this.rPip = r.querySelector('[data-r=pip]'); this.rFlag = r.querySelector('[data-r=flag]'); this.rRing = r.querySelector('[data-r=ring]');
    }
    this.lastSec = -1; this.lastTier = -1;
  }
  preBest() { const o = this.o; if (o.mode === 'endless' && o.best && o.endlessT > o.best) { this.bestDone = true; if (this.cBest) { this.cBest.style.display = 'flex'; this.cBest.innerHTML = '<div style="height:36px;box-sizing:border-box;padding:0 14px;border-radius:18px;background:#A8E6CF;border:3px solid #2D3436;display:flex;align-items:center;gap:6px;font:900 26px/1 Nunito,system-ui,sans-serif;color:#2D3436"><img src="../assets/endless/trophy.svg" style="width:26px;height:26px">New best!</div>'; } } }
  // ── efekti (bazen; svaki je čista funkcija vremena od starta) ──
  trigger(kind, arg) { this.fx.push({ kind, t0: this.t, arg }); }
  getPool(key, make) { if (!this.pool[key] || !this.pool[key].isConnected) this.pool[key] = make(); return this.pool[key]; }
  runFx() {
    let live = 0; const LE = this.LE, T = LE.TIME;
    const keep = [];
    for (const f of this.fx) {
      const u = this.t - f.t0;
      if (f.kind === 'gust') { const n = 5, xs = [178, 405, 675, 902, 540], y0 = [260, 120, 180, 300, 1180]; let any = false; for (let i = 0; i < n; i++) { const e = this.getPool('gust' + i, () => IMG(A + 'fx/gust_streak.svg', 18, 240, this.fxL)); const v = clamp((u - i * T.gust.stagger) / T.gust.streak); const on = v > 0 && v < 1; e.style.display = on ? 'block' : 'none'; if (on) { any = true; live++; e.style.transform = 'translate(' + (xs[i] - 9) + 'px,' + f2(y0[i] + 900 * out3(v)) + 'px) scaleY(' + f2(0.5 + 0.8 * bell(v, 0, 1)) + ')'; e.style.opacity = f2(0.62 * bell(v, 0, 1)); } } if (this.pip) { const l = bell(u, 0, T.gust.lean); this.pipW.style.scale = '1 ' + f2(1 - 0.06 * l); } const j = bell(u, 0, T.gust.jolt); this.world.style.translate = '0 ' + f2(10 * j) + 'px'; if (any || u < T.gust.total) keep.push(f); else { this.pipW.style.scale = ''; this.world.style.translate = ''; } continue; }
      if (f.kind === 'intro') {
        const card = this.getPool('intro', () => { const lv = this.o.level, B = LE.BANDS[LE.bandOf(lv) - 1], L = LE.LEVELS[lv - 1]; const c = el('div', 'position:absolute;left:0;top:0;width:1080px;display:flex;flex-direction:column;align-items:center;gap:22px;will-change:transform,opacity', this.topL); c.innerHTML = '<div data-r="plate" style="height:180px;box-sizing:border-box;padding:0 64px;border-radius:90px;background:#FFF8F0;border:5px solid #2D3436;box-shadow:0 12px 0 rgba(10,14,12,.55);display:flex;align-items:center;gap:28px"><div style="font:900 96px/1 Nunito,system-ui,sans-serif;color:#2D3436;white-space:nowrap">Level ' + lv + '</div><img src="' + A + 'bands/tag_' + B.n + (LE.isPeak(lv) ? '_peak' : '') + '.svg" style="height:60px"></div><div data-r="sub" style="height:88px;box-sizing:border-box;padding:0 34px 0 18px;border-radius:44px;background:#FFF8F0;border:4px solid #2D3436;display:flex;align-items:center;gap:14px;font:900 44px/1 Nunito,system-ui,sans-serif;color:#2D3436;white-space:nowrap"><div style="width:60px;height:60px;box-sizing:border-box;border-radius:30px;background:' + B.fill + ';border:3px solid #2D3436;display:grid;place-items:center"><div style="width:26px;height:26px;box-sizing:border-box;border-radius:13px;border:5px solid #2D3436;position:relative"><div style="position:absolute;left:8px;top:2px;width:4px;height:9px;background:#2D3436"></div></div></div>' + (this.o.replay ? 'Replay' : B.name) + ' · ' + LE.fmtDur(L.dur) + '</div>'; c._plate = c.querySelector('[data-r=plate]'); c._sub = c.querySelector('[data-r=sub]'); return c; });
        const I = T.intro, pop = outBack(clamp(u / I.pop)), sub = out3(clamp((u - I.sub[0]) / (I.sub[1] - I.sub[0]))), fly = io2(clamp((u - I.fly[0]) / (I.fly[1] - I.fly[0])));
        const y = 560 + (124 - 560) * fly - 100 * fly, x = (-540 + 240) * fly, sc = (0.9 + 0.1 * pop) * (1 - 0.64 * fly);
        card.style.display = u < I.total ? 'flex' : 'none'; card.style.transform = 'translate(' + f2(x) + 'px,' + f2(y) + 'px) scale(' + f2(sc) + ')'; card.style.opacity = f2(clamp(u / 0.08) * (1 - clamp((fly - 0.7) / 0.3))); card._sub.style.opacity = f2(sub * (1 - fly)); card._sub.style.transform = 'translateY(' + f2(-24 * (1 - sub)) + 'px)';
        if (u < I.total) { live += 6; keep.push(f); }
        const bump = bell(u, I.chipBump[0], I.chipBump[1]); this.chip.style.transform = 'scale(' + f2(1 + 0.08 * bump) + ')'; if (u >= I.chipBump[1]) this.chip.style.transform = ''; else if (u >= I.total) keep.includes(f) || keep.push(f);
        continue;
      }
      if (f.kind === 'pace') {
        const P = T.pace, e = this.getPool('pace', () => el('div', 'position:absolute;left:40px;top:214px;height:88px;box-sizing:border-box;padding:0 30px 0 18px;border-radius:44px;border:4px solid #2D3436;box-shadow:0 6px 0 rgba(10,14,12,.45);display:flex;align-items:center;gap:12px;font:900 48px/1 Nunito,system-ui,sans-serif;color:#2D3436;white-space:nowrap;transform-origin:20% 0;will-change:transform,opacity', this.topL));
        if (e._n !== f.arg) { e._n = f.arg; e.style.background = LE.BANDS[LE.paceBand(f.arg) - 1].fill; e.innerHTML = '<img src="' + A + 'fx/pace_up.svg" style="width:40px;height:40px">Pace ' + f.arg; }
        const i = outBack(clamp(u / P.in)), o2 = clamp((u - P.out[0]) / (P.out[1] - P.out[0]));
        e.style.display = u < P.total ? 'flex' : 'none'; e.style.transform = 'translateY(' + f2(-26 * (1 - i) - 30 * o2) + 'px) scale(' + f2(0.8 + 0.2 * i) + ')'; e.style.opacity = f2(clamp(u / 0.06) * (1 - o2));
        const pb = bell(u, 0, 0.2); if (this.cPace) this.cPace.style.transform = 'scale(' + f2(1 + 0.25 * pb) + ')';
        if (u < P.total) { live += 2; keep.push(f); } continue;
      }
      if (f.kind === 'best') {
        const B = T.best, c = { x: 40 + this.chip.offsetWidth / 2, y: 124 };
        const ring = this.getPool('bring', () => IMG(A + 'fx/burst_ring.svg', 200, 200, this.topL, 'filter:none'));
        const rv = clamp(u / B.ring); ring.style.display = rv < 1 ? 'block' : 'none'; ring.style.transform = 'translate(' + f2(c.x - 100) + 'px,' + f2(c.y - 100) + 'px) scale(' + f2(0.5 + 1.6 * out3(rv)) + ')'; ring.style.opacity = f2(1 - rv);
        const tro = this.getPool('btro', () => IMG(A + 'endless/trophy.svg', 64, 64, this.topL)); const tv = clamp(u / B.trophy); tro.style.display = u < B.total ? 'block' : 'none'; tro.style.transform = 'translate(' + f2(c.x + 150) + 'px,' + f2(150 - 40 * out3(tv)) + 'px) scale(' + f2(outBack(tv)) + ') rotate(' + f2(-12 + 12 * tv) + 'deg)'; tro.style.opacity = f2(1 - clamp((u - 0.7) / 0.2));
        const cols = ['confetti_mint', 'confetti_peach', 'confetti_lav']; for (let i = 0; i < 8; i++) { const e = this.getPool('bc' + i, () => IMG(R + 'fx/' + cols[i % 3] + '.svg', 24, 24, this.topL)); const v = clamp(u / B.confetti), a = (-160 + i * 26) * Math.PI / 180, d = 150 + (i % 3) * 40; e.style.display = v < 1 ? 'block' : 'none'; e.style.transform = 'translate(' + f2(c.x - 12 + Math.cos(a) * d * out3(v)) + 'px,' + f2(c.y - 12 + Math.sin(a) * d * out3(v) + 260 * in2(v)) + 'px) rotate(' + f2(360 * v * (i % 2 ? 1 : -1)) + 'deg)'; e.style.opacity = f2(1 - clamp((v - 0.75) / 0.25)); }
        if (u < 0.05 && this.cBest) { this.cBest.style.display = 'flex'; this.cBest.innerHTML = '<div style="height:36px;box-sizing:border-box;padding:0 14px;border-radius:18px;background:#A8E6CF;border:3px solid #2D3436;display:flex;align-items:center;gap:6px;font:900 26px/1 Nunito,system-ui,sans-serif;color:#2D3436"><img src="' + A + 'endless/trophy.svg" style="width:26px;height:26px">New best!</div>'; }
        this.chip.style.transform = 'scale(' + f2(1 + 0.1 * bell(u, 0, 0.24)) + ')';
        if (u < B.total) { live += 10; keep.push(f); } else this.chip.style.transform = ''; continue;
      }
      if (f.kind === 'finish') {
        const F = T.finish, g = f.arg, P = g.parts, c = { x: 540, y: this.LE.PIP_Y };
        P.tp.style.display = 'none'; P.h1.style.display = P.h2.style.display = 'block';
        const tv = outBack(clamp(u / F.tape)), fl = Math.sin(clamp((u - F.tape) / 0.5) * Math.PI * 3) * (1 - clamp((u - F.tape) / 0.5));
        P.h1.style.transform = 'translate(148px,-40px) rotate(' + f2(78 * tv + 6 * fl) + 'deg)'; P.h2.style.transform = 'translate(932px,-40px) scaleX(-1) rotate(' + f2(78 * tv + 6 * fl) + 'deg)';
        P.arch.style.scale = '1 ' + f2(1 + 0.06 * bell(u, 0, F.arch));
        const cols = ['confetti_mint', 'confetti_peach', 'confetti_lav']; for (let i = 0; i < 10; i++) { const e = this.getPool('fc' + i, () => IMG(R + 'fx/' + cols[i % 3] + '.svg', 26, 26, this.topL)); const v = clamp(u / F.confetti), a = (-170 + i * 18) * Math.PI / 180, d = 260 + (i % 4) * 60; e.style.display = v < 1 ? 'block' : 'none'; e.style.transform = 'translate(' + f2(c.x - 13 + Math.cos(a) * d * out3(v)) + 'px,' + f2(c.y - 60 + Math.sin(a) * d * out3(v) + 420 * in2(v)) + 'px) rotate(' + f2(400 * v * (i % 2 ? 1 : -1)) + 'deg)'; e.style.opacity = f2(1 - clamp((v - 0.8) / 0.2)); }
        const ban = this.getPool('banner', () => { const b = el('div', 'position:absolute;left:0;top:640px;width:1080px;display:flex;flex-direction:column;align-items:center;gap:24px;will-change:transform,opacity', this.topL); b.innerHTML = '<div style="height:180px;box-sizing:border-box;padding:0 85px;border-radius:90px;background:#A8E6CF;border:5px solid #2D3436;box-shadow:0 12px 0 rgba(10,14,12,.55);display:flex;align-items:center;font:900 104px/1 Nunito,system-ui,sans-serif;color:#2D3436">Time!</div><div style="height:88px;box-sizing:border-box;padding:0 34px 0 18px;border-radius:44px;background:#FFF8F0;border:4px solid #2D3436;display:flex;align-items:center;gap:14px;font:900 44px/1 Nunito,system-ui,sans-serif;color:#2D3436"><div style="width:60px;height:60px;box-sizing:border-box;border-radius:30px;background:#A8E6CF;border:3px solid #2D3436;display:grid;place-items:center"><img src="icons/icon_basket.svg" style="width:38px;height:38px"></div>Nothing lost</div>'; return b; });
        const bv = clamp((u - F.banner) / 0.22); ban.style.display = u > F.banner ? 'flex' : 'none'; ban.style.transform = 'scale(' + f2(0.9 + 0.1 * outBack(bv)) + ')'; ban.style.opacity = f2(clamp(bv * 3));
        if (this.rail) { const r = outBack(clamp(u / 0.2)); this.rFlag.style.transform = 'translateY(' + f2(-6 * r) + 'px) scale(' + f2(1 + 0.18 * r) + ') rotate(' + f2(-6 * r) + 'deg)'; this.rRing.style.display = 'block'; }
        live += u < F.confetti ? 12 : 2; keep.push(f); continue;
      }
    }
    this.fx = keep; this.live = live; this.maxLive = Math.max(this.maxLive, live);
  }
  // ── frejm ──
  step(dt0) {
    const o = this.o, dt = dt0 * (o.slow ? 0.25 : 1), LE = this.LE; let t = this.t + dt;
    const fin = o.finishAt != null && t >= o.finishAt;
    if (t >= o.loop) { t = 0; this.fx = []; this.gateDone = false; this.bestDone = false; this.lastTier = -1; this.hud(); this.preBest(); for (const k in this.pool) { const e = this.pool[k]; if (e && e.style) e.style.display = 'none'; } (this.its || []).forEach(it => { if (it.parts) { it.parts.tp.style.display = 'block'; it.parts.h1.style.display = it.parts.h2.style.display = 'none'; it.parts.arch.style.scale = ''; } }); if (o.onLoop) o.onLoop(); }
    this.t = t;
    // brzina (finish: svijet uspori i stane za 0,30 s)
    let v = o.speed; if (o.finishAt != null && t > o.finishAt) v *= 1 - clamp((t - o.finishAt) / 0.30);
    const dist = o.finishAt != null && t > o.finishAt ? o.speed * o.finishAt + o.speed * 0.15 * clamp((t - o.finishAt) / 0.30) * (2 - clamp((t - o.finishAt) / 0.30)) : o.speed * t;
    const layer = d => { if (d) d.style.transform = 'translateY(' + f2(((dist * d._k) % d._p) - d._p) + 'px)'; };
    layer(this.far); layer(this.tile); layer(this.seams); layer(this.near);
    (this.its || []).forEach(it => { const y = LE.SPAWN_Y + (dist - o.speed * it.t); const vis = y > -700 && y < 2100 && t >= it.t - 0.0001 || (it.kind === 'gate' && y > -700 && y < 2400); it.g.style.display = vis ? 'block' : 'none'; if (vis) it.g.style.transform = 'translateY(' + f2(y) + 'px)'; if (it.kind === 'gate' && !this.gateDone && o.finishAt != null && t >= o.finishAt) { this.gateDone = true; this.trigger('finish', it); if (this.pip) try { this.pip.play('finish'); } catch (e) {} } });
    // Pip: staza po rasporedu (0,12 s prelaz)
    const Ls = o.lanes; let x = LE.LANES[Ls[0][1]];
    for (let i = 1; i < Ls.length; i++) { const [tt, lane] = Ls[i]; if (t < tt) break; const from = LE.LANES[Ls[i - 1][1]], to = LE.LANES[lane]; x = from + (to - from) * out3(clamp((t - tt) / 0.12)); if (this.prevT < tt && t >= tt && this.pip) try { this.pip.play(lane < Ls[i - 1][1] ? 'lane_left' : 'lane_right'); } catch (e) {} }
    this.pipW.style.transform = 'translate(' + f2(x - 75) + 'px,' + f2(LE.PIP_Y - 75) + 'px)';
    // zakazani efekti
    (o.fxAt || []).forEach(([tt, kind, arg]) => { if (this.prevT < tt && t >= tt) this.trigger(kind, arg); });
    // HUD: traka napretka (po frejmu samo visina / y) i Endless tekst (≤ 1 / s)
    if (this.rail) { const L = LE.LEVELS[o.level - 1], el0 = (o.t0 || 0) + Math.min(t, o.finishAt ?? 1e9), p = clamp(el0 / L.dur); this.rFill.style.height = f2(Math.max(0, Math.round(p * 1394) - 6)) + 'px'; this.rFill.style.background = 1 - p < 0.17 ? '#FFB88C' : '#A8E6CF'; this.rPip.style.top = f2(1700 + (300 - 1700) * p - 46 - 200) + 'px'; }
    if (o.mode === 'endless' && this.cClock) { const et = (o.endlessT || 0) + t, sec = Math.floor(et); if (sec !== this.lastSec) { this.lastSec = sec; this.cClock.textContent = LE.clock(et); this.textChanges = (this.textChanges || 0) + 1; } const tier = LE.tierOf(et); if (tier !== this.lastTier) { const first = this.lastTier < 0; this.lastTier = tier; this.cPace.textContent = 'Pace ' + tier; this.cPace.style.background = LE.BANDS[LE.paceBand(tier) - 1].fill; if (!first) { this.trigger('pace', tier); this.trigger('gust'); } } if (o.best && !this.bestDone && et > o.best) { this.bestDone = true; this.trigger('best'); } else if (o.best && !this.bestDone && this.cBestT) this.cBestT.textContent = 'Best ' + LE.clock(o.best); }
    this.runFx();
    this.prevT = t;
    if (o.onStats && (!this._st || performance.now() - this._st > 250)) { this._st = performance.now(); o.onStats({ live: this.live, max: this.maxLive, t }); }
  }
}
