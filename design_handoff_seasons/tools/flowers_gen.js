// Season Kit — cvijeće (faza 1): Country Bloom + Moonlit Warren, 6 tipova x T1/T2/T3.
// Pokretanje:  node design_handoff_seasons/tools/flowers_gen.js   -> assets/flowers/*.svg + flowers_meta.json
// Isti jezik kao scripts/art/flowers_gen.py (naljepnica: jedan debeli rub siluete po grupi, tanke unutrašnje
// linije, ravni odsjaji), uz pravila kita: taman vanjski rub (OUT po sezoni), T3 = isti cvijet + brušeni kristal
// (fasete, bez krugova/prstenova i iskrica preko cvijeta), rijetkost -> kompleksnost, viewBox 256, baza (128,244),
// bez gradijenata, <= 12 KB.
'use strict';

function generateFlowers() {
  const RIM = 5;           // vanjski rub siluete: 5 px sa svake strane (na 128 px rasteru = 2,5 px)
  const IW = 3;            // unutrašnja linija
  const n = v => { const r = Math.round(v * 10) / 10; const s = String(r); return s === '-0' ? '0' : s; };
  const rgb = h => [1, 3, 5].map(i => parseInt(h.substr(i, 2), 16));
  const hex = a => '#' + a.map(v => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, '0')).join('').toUpperCase();
  const mix = (a, b, t) => { const A = rgb(a), B = rgb(b); return hex(A.map((v, i) => v + (B[i] - v) * t)); };
  const D2R = Math.PI / 180;

  // ---------- geometrija: komande u lokalnom prostoru -> apsolutne putanje ----------
  const T = (x, y, rot = 0, sx = 1, sy = sx) => { const c = Math.cos(rot * D2R), s = Math.sin(rot * D2R); return (px, py) => [x + px * sx * c - py * sy * s, y + px * sx * s + py * sy * c]; };
  // rotacija pa vertikalno sabijanje (pogled 3/4) pa nagib cijelog cvijeta
  const TS = (x, y, rot, sq, tilt = 0, k = 1) => { const c = Math.cos(rot * D2R), s = Math.sin(rot * D2R), ct = Math.cos(tilt * D2R), st = Math.sin(tilt * D2R); return (px, py) => { const rx = (px * c - py * s) * k, ry = (px * s + py * c) * sq * k; return [x + rx * ct - ry * st, y + rx * st + ry * ct]; }; };
  const ID = (px, py) => [px, py];
  let BB = null; // bbox sakupljač (uzorkuje krive)
  const bbAdd = (x, y, pad) => { if (!BB) return; BB[0] = Math.min(BB[0], x - pad); BB[1] = Math.min(BB[1], y - pad); BB[2] = Math.max(BB[2], x + pad); BB[3] = Math.max(BB[3], y + pad); };
  function toD(cmds, tf = ID, pad = 0) {
    let d = '', last = [0, 0];
    for (const c of cmds) {
      const k = c[0];
      if (k === 'Z') { d += 'Z'; continue; }
      const pts = [];
      for (let i = 1; i < c.length; i += 2) pts.push(tf(c[i], c[i + 1]));
      if (k === 'C') { for (let t = 0.25; t < 1; t += 0.25) { const u = 1 - t; bbAdd(u * u * u * last[0] + 3 * u * u * t * pts[0][0] + 3 * u * t * t * pts[1][0] + t * t * t * pts[2][0], u * u * u * last[1] + 3 * u * u * t * pts[0][1] + 3 * u * t * t * pts[1][1] + t * t * t * pts[2][1], pad); } }
      if (k === 'Q') { for (let t = 0.25; t < 1; t += 0.25) { const u = 1 - t; bbAdd(u * u * last[0] + 2 * u * t * pts[0][0] + t * t * pts[1][0], u * u * last[1] + 2 * u * t * pts[0][1] + t * t * pts[1][1], pad); } }
      const end = pts[pts.length - 1]; bbAdd(end[0], end[1], pad); last = end;
      d += k + pts.map(p => n(p[0]) + ',' + n(p[1])).join(' ');
    }
    return d;
  }
  // oblici (lokalno; vrh latice = -y)
  const K = 0.5523;
  const ell = (cx, cy, rx, ry) => [['M', cx - rx, cy], ['C', cx - rx, cy - ry * K, cx - rx * K, cy - ry, cx, cy - ry], ['C', cx + rx * K, cy - ry, cx + rx, cy - ry * K, cx + rx, cy], ['C', cx + rx, cy + ry * K, cx + rx * K, cy + ry, cx, cy + ry], ['C', cx - rx * K, cy + ry, cx - rx, cy + ry * K, cx - rx, cy], ['Z']];
  const petal = (l, w, b = 0.28) => [['M', 0, 0], ['C', w, -l * b, w * 0.95, -l * 0.78, 0, -l], ['C', -w * 0.95, -l * 0.78, -w, -l * b, 0, 0], ['Z']];
  const rpetal = (l, w) => [['M', 0, 0], ['C', w * 0.9, -l * 0.12, w * 1.15, -l * 0.86, 0, -l], ['C', -w * 1.15, -l * 0.86, -w * 0.9, -l * 0.12, 0, 0], ['Z']];
  const leaf = (l, w) => [['M', 0, 0], ['C', l * 0.28, -w, l * 0.72, -w, l, 0], ['C', l * 0.72, w, l * 0.28, w, 0, 0], ['Z']];
  const heart = s => [['M', 0, 0], ['C', s * 0.16, -s * 0.3, s * 0.64, -s * 0.42, s * 0.56, -s * 0.82], ['C', s * 0.5, -s * 1.08, s * 0.12, -s * 1.08, 0, -s * 0.84], ['C', -s * 0.12, -s * 1.08, -s * 0.5, -s * 1.08, -s * 0.56, -s * 0.82], ['C', -s * 0.64, -s * 0.42, -s * 0.16, -s * 0.3, 0, 0], ['Z']];
  const poly = pts => [['M', pts[0][0], pts[0][1]], ...pts.slice(1).map(p => ['L', p[0], p[1]]), ['Z']];
  const line = pts => [['M', pts[0][0], pts[0][1]], ...pts.slice(1).map(p => ['L', p[0], p[1]])];
  const star = (k, ro, ri, rot = -90) => { const p = []; for (let i = 0; i < k * 2; i++) { const a = (rot + i * 180 / k) * D2R, r = i % 2 ? ri : ro; p.push([Math.cos(a) * r, Math.sin(a) * r]); } return poly(p); };
  const ngon = (k, r, rot = -90 + 180 / 8) => { const p = []; for (let i = 0; i < k; i++) { const a = (rot + i * 360 / k) * D2R; p.push([Math.cos(a) * r, Math.sin(a) * r]); } return p; };
  const smoothPoly = pts => { // zatvorena glatka kriva kroz tačke (Catmull-Rom -> bezier)
    const c = [['M', pts[0][0], pts[0][1]]], k = pts.length;
    for (let i = 0; i < k; i++) { const p0 = pts[(i - 1 + k) % k], p1 = pts[i], p2 = pts[(i + 1) % k], p3 = pts[(i + 2) % k]; c.push(['C', p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6, p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6, p2[0], p2[1]]); }
    c.push(['Z']); return c;
  };

  // ---------- dijelovi i crtanje (naljepnica) ----------
  // F = popunjen dio (rub + fill), S = linija (rub + boja); det = detalji bez ruba.
  const F = (cmds, fill, o = {}) => ({ k: 'f', cmds, tf: o.tf || ID, fill, ink: o.ink, det: o.det || [] });
  const S = (cmds, color, w, o = {}) => ({ k: 's', cmds, tf: o.tf || ID, color, w });
  const DF = (cmds, fill, tf = ID, op = 1) => ({ k: 'df', cmds, tf, fill, op });
  const DS = (cmds, color, w, tf = ID, op = 1) => ({ k: 'ds', cmds, tf, color, w, op });
  const op = v => v < 1 ? ` opacity="${n(v)}"` : '';
  function group(parts, OUT) {
    let a = '', b = '';
    for (const p of parts) {
      if (p.k === 'f') {
        const d = toD(p.cmds, p.tf, RIM);
        a += `<path d="${d}" fill="${OUT}" stroke="${OUT}" stroke-width="${RIM * 2}" stroke-linejoin="round"/>`;
        b += `<path d="${d}" fill="${p.fill}" stroke="${p.ink || mix(p.fill, OUT, 0.34)}" stroke-width="${IW}" stroke-linejoin="round"/>`;
        for (const q of p.det) b += detail(q);
      } else {
        const d = toD(p.cmds, p.tf, p.w / 2 + RIM);
        a += `<path d="${d}" fill="none" stroke="${OUT}" stroke-width="${n(p.w + RIM * 2)}" stroke-linecap="round" stroke-linejoin="round"/>`;
        b += `<path d="${d}" fill="none" stroke="${p.color}" stroke-width="${n(p.w)}" stroke-linecap="round" stroke-linejoin="round"/>`;
      }
    }
    return a + b;
  }
  function detail(q) {
    const save = BB; BB = null; // detalji su unutar siluete — ne šire bbox
    const d = toD(q.cmds, q.tf);
    BB = save;
    if (q.k === 'df') return `<path d="${d}" fill="${q.fill}"${op(q.op)}/>`;
    return `<path d="${d}" fill="none" stroke="${q.color}" stroke-width="${n(q.w)}" stroke-linecap="round" stroke-linejoin="round"${op(q.op)}/>`;
  }

  // ---------- kristal (T3): fasete; svjetlo gore-lijevo ----------
  // gem = { body, light, dark, top, edge }
  function crystalPetal(l, w, tf, gem, OUT) {
    const P = [[0, 0], [w, -l * 0.36], [w * 0.62, -l * 0.86], [0, -l], [-w * 0.62, -l * 0.86], [-w, -l * 0.36]];
    const c = [0, -l * 0.6];
    // koja polovina gleda u svjetlo: uporedi x lijeve tačke u apsolutnom prostoru
    const L = tf(-w, -l * 0.36), R = tf(w, -l * 0.36);
    const leftLit = (L[0] + L[1]) < (R[0] + R[1]);
    const lit = leftLit ? gem.light : gem.dark, sh = leftLit ? gem.dark : gem.light;
    return F(poly(P), gem.body, { tf, ink: gem.edge || mix(gem.body, OUT, 0.45), det: [
      DF(poly([P[0], P[5], P[4], c]), lit, tf),
      DF(poly([P[0], P[1], P[2], c]), sh, tf),
      DF(poly([P[4], P[3], P[2], c]), gem.top, tf),
      DS(line([P[0], c, P[3]]), mix(gem.body, OUT, 0.3), 1.6, tf, 0.7)
    ] });
  }
  function crystalLite(l, w, tf, gem, OUT, shape) {
    const P = [[0, 0], [w, -l * 0.36], [w * 0.62, -l * 0.86], [0, -l], [-w * 0.62, -l * 0.86], [-w, -l * 0.36]];
    const L = tf(-w, -l * 0.36), R = tf(w, -l * 0.36), leftLit = (L[0] + L[1]) < (R[0] + R[1]);
    return F(poly(P), gem.body, { tf, ink: mix(gem.body, OUT, 0.45), det: [DF(poly([P[0], P[5], P[4], P[3]]), leftLit ? gem.light : gem.dark, tf), DF(poly([P[4], P[3], [0, -l * 0.62]]), gem.top, tf)] });
  }
  function gemSmall(cx, cy, r, gem, OUT) {
    const o = ngon(8, r), t = ngon(8, r * 0.5);
    return F(poly(o), gem.body, { tf: T(cx, cy), ink: mix(gem.body, OUT, 0.45), det: [DF(poly([o[4], o[5], o[6], o[7], o[0], t[0], t[7], t[6], t[5], t[4]]), gem.light, T(cx, cy)), DF(poly(t), gem.top, T(cx, cy))] });
  }
  function gemCenter(cx, cy, r, gem, OUT) {
    const o = ngon(8, r), t = ngon(8, r * 0.52);
    const det = [];
    for (let i = 0; i < 8; i++) { const j = (i + 1) % 8; det.push(DF(poly([o[i], o[j], t[j], t[i]]), [gem.light, gem.body, gem.dark, gem.dark, gem.body, gem.light, gem.top, gem.light][i], T(cx, cy))); }
    det.push(DF(poly(t), gem.top, T(cx, cy)));
    det.push(DF(poly([t[6], t[7], [t[7][0] * 0.2, t[7][1] * 0.2]]), '#FFFFFF', T(cx, cy), 0.85));
    return F(poly(o), gem.body, { tf: T(cx, cy), ink: gem.edge || mix(gem.body, OUT, 0.45), det });
  }

  // ---------- zajedničko ----------
  const stem = (d, color, w) => S(d, color, w);
  const C = (...a) => a;
  function leafPart(x, y, ang, l, w, P, flip = false) {
    const tf = T(x, y, ang, 1, flip ? -1 : 1);
    return F(leaf(l, w), P.leaf, { tf, det: [
      DF([['M', 0, 0], ['C', l * 0.28, -w, l * 0.72, -w, l, 0], ['Q', l * 0.5, -w * 0.12, 0, 0], ['Z']], P.leafHi, tf),
      DS([['M', l * 0.1, -w * 0.02], ['Q', l * 0.5, -w * 0.12, l * 0.86, -w * 0.02]], mix(P.leaf, P.out, 0.34), 2.2, tf, 0.8)
    ] });
  }
  const svg = body => `<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 256 256">${body}</svg>`;

  // ---------- palete ----------
  const CB = { out: '#3D2B3D', stem: '#5FA357', leaf: '#72C266', leafHi: '#A8DE9E' };
  const MW = { out: '#221B3A', stem: '#7BA7A0', leaf: '#6E9F98', leafHi: '#A9D3CB' };
  const GEM = {
    emerald: { body: '#5FD08A', light: '#B9F5CB', dark: '#2E9E62', top: '#E4FFEC' },
    quartz: { body: '#EEEBFA', light: '#FFFFFF', dark: '#C9C3E6', top: '#FFFFFF' },
    citrine: { body: '#FFC93D', light: '#FFE58F', dark: '#E09A12', top: '#FFF4C7' },
    topaz: { body: '#FFD51F', light: '#FFF09A', dark: '#E3A400', top: '#FFFBD6' },
    ruby: { body: '#E8436A', light: '#FF9DB4', dark: '#A81C46', top: '#FFD6E0' },
    amber: { body: '#FFB62E', light: '#FFDA85', dark: '#D9830A', top: '#FFF0C9' },
    smoky: { body: '#8A5A2E', light: '#B9874F', dark: '#5C3618', top: '#D9B17C' },
    opalFire: { body: '#FF8B2C', light: '#FFC37C', dark: '#D45A0A', top: '#FFE2BC' },
    moonstone: { body: '#DCD9FF', light: '#FFFFFF', dark: '#A9A3EE', top: '#F6F5FF' },
    amethyst: { body: '#A68AF0', light: '#E3D8FF', dark: '#6C4BC6', top: '#F5F0FF' },
    iolite: { body: '#C3C8FA', light: '#F4F5FF', dark: '#858CE0', top: '#FFFFFF' },
    opal: { body: '#EEEAFF', light: '#FFFFFF', dark: '#C2B9F0', top: '#FFFFFF' },
    diamond: { body: '#F4F4FF', light: '#FFFFFF', dark: '#CDD1F0', top: '#FFFFFF' },
    tanzanite: { body: '#8670E4', light: '#D6CCFF', dark: '#553FB4', top: '#EFEAFF' },
    goldGem: { body: '#FFD45E', light: '#FFEDA6', dark: '#E0A82A', top: '#FFF8DC' }
  };

  const out = {};
  const meta = {};
  function emit(id, season, rarity, tier, groups, OUT) {
    BB = [999, 999, -999, -999];
    let body = '', parts = 0;
    for (const g of groups) { body += group(g, OUT); parts += g.length; }
    const s = svg(body);
    const bb = BB.map(v => Math.round(v));
    const box = [Math.max(0, bb[0]), Math.max(0, bb[1]), Math.min(256, bb[2]) - Math.max(0, bb[0]), Math.min(256, bb[3]) - Math.max(0, bb[1])];
    const key = id + '_t' + tier;
    out[key + '.svg'] = s;
    meta[key] = { season, rarity, tier, bytes: s.length, parts, crop: box, out: OUT };
    BB = null;
  }

  // ======================= COUNTRY BLOOM =======================
  // clover ★1 — Meadow Clover
  {
    const P = CB, leafG = '#8CD980', vmark = '#D4F5CC';
    const trefoil = (cx, cy, s, crystal) => [0, 120, -120].map(a => {
      const tf = T(cx, cy, a);
      if (crystal) {
        // brušeno srce: dva režnja s ravnim fasetama, ista silueta kao T2
        const g = GEM.emerald;
        const Pp = [[0, 0], [s * 0.5, -s * 0.36], [s * 0.62, -s * 0.74], [s * 0.42, -s * 1.0], [s * 0.16, -s * 1.02], [0, -s * 0.84], [-s * 0.16, -s * 1.02], [-s * 0.42, -s * 1.0], [-s * 0.62, -s * 0.74], [-s * 0.5, -s * 0.36]];
        const c = [0, -s * 0.56];
        const lit = a === 120 ? g.dark : g.light, sh = a === 120 ? g.light : g.dark;
        return F(poly(Pp), g.body, { tf, ink: mix(g.body, P.out, 0.45), det: [
          DF(poly([Pp[0], Pp[9], Pp[8], c]), lit, tf),
          DF(poly([Pp[0], Pp[1], Pp[2], c]), sh, tf),
          DF(poly([Pp[8], Pp[7], Pp[6], Pp[5], c]), g.top, tf),
          DF(poly([Pp[2], Pp[3], Pp[4], Pp[5], c]), g.body, tf),
          DS(line([Pp[0], c, Pp[5]]), mix(g.body, P.out, 0.3), 1.6, tf, 0.7)
        ] });
      }
      return F(heart(s), leafG, { tf, det: [
        DS([['M', -s * 0.3, -s * 0.62], ['L', 0, -s * 0.4], ['L', s * 0.3, -s * 0.62]], vmark, s * 0.07, tf, 0.9),
        DS([['M', 0, -s * 0.06], ['L', 0, -s * 0.7]], mix(leafG, P.out, 0.3), 2, tf, 0.6)
      ] });
    });
    emit('clover', 'country_bloom', 1, 1, [[stem([['M', 128, 244], ['C', 127, 226, 130, 204, 128, 182]], P.stem, 7), leafPart(128, 232, -36, 22, 8, P)], trefoil(128, 170, 32)], P.out);
    const st2 = [stem([['M', 128, 244], ['C', 124, 212, 134, 170, 127, 126]], P.stem, 8), leafPart(129, 214, -32, 36, 13, P)];
    emit('clover', 'country_bloom', 1, 2, [st2, trefoil(127, 110, 52)], P.out);
    emit('clover', 'country_bloom', 1, 3, [st2, [...trefoil(127, 110, 52, true), gemSmall(127, 110, 10, GEM.citrine, P.out)]], P.out);
  }
  // daisy ★1 — Field Daisy
  {
    const P = CB, white = '#FAFAF5', gold = '#FFD133';
    const leaves = [leafPart(128, 226, -150, 36, 13, P, true), leafPart(128, 226, -30, 36, 13, P)];
    const bud = [
      F(ell(128, 150, 13, 16), white, { det: [DS([['M', 124, 138], ['L', 125, 156]], '#D9D6CC', 2), DS([['M', 132, 138], ['L', 131, 156]], '#D9D6CC', 2)] }),
      F([['M', 111, 154], ['C', 112, 172, 144, 172, 145, 154], ['C', 138, 158, 118, 158, 111, 154], ['Z']], '#7CC46F', { det: [DF([['M', 115, 158], ['C', 120, 166, 130, 166, 134, 162], ['L', 118, 158], ['Z']], '#A8DE9E')] })
    ];
    emit('daisy', 'country_bloom', 1, 1, [[stem([['M', 128, 244], ['C', 126, 226, 130, 200, 128, 166]], P.stem, 7), ...leaves], bud], P.out);
    const st = [stem([['M', 128, 244], ['C', 125, 212, 132, 170, 128, 114]], P.stem, 8), leafPart(129, 206, -28, 42, 15, P), leafPart(127, 228, -152, 34, 12, P, true)];
    const petals = []; for (let i = 0; i < 12; i++) { const tf = T(128, 100, i * 30 + 15); petals.push(F(petal(50, 11.5, 0.22), white, { tf, det: [DS([['M', 0, -8], ['L', 0, -40]], '#E2DED2', 2, tf, 0.9)] })); }
    const center = F(ell(128, 100, 19, 19), gold, { det: [DF(ell(122, 94, 7, 5), '#FFE98A'), ...[[134, 104], [126, 108], [136, 96], [120, 102]].map(([x, y]) => DF(ell(x, y, 2.6, 2.6), '#D9A214'))] });
    emit('daisy', 'country_bloom', 1, 2, [st, petals, [center]], P.out);
    const cp = []; for (let i = 0; i < 12; i++) cp.push(crystalPetal(50, 12, T(128, 100, i * 30 + 15), GEM.quartz, P.out));
    emit('daisy', 'country_bloom', 1, 3, [st, cp, [gemCenter(128, 100, 20, GEM.citrine, P.out)]], P.out);
  }
  // buttercup ★1 — Buttercup Lane
  {
    const P = CB, y = '#FFE026', c = '#F2A61A';
    const leaves = [leafPart(128, 224, -148, 34, 13, P, true), leafPart(128, 224, -32, 34, 13, P)];
    const bud = [
      F(ell(128, 162, 16, 16), y, { det: [DF(ell(122, 156, 6, 4.5), '#FFF4A8')] }),
      F([['M', 112, 166], ['C', 116, 182, 140, 182, 144, 166], ['C', 136, 172, 120, 172, 112, 166], ['Z']], '#7CC46F')
    ];
    emit('buttercup', 'country_bloom', 1, 1, [[stem([['M', 128, 244], ['C', 127, 224, 131, 198, 128, 176]], P.stem, 7), ...leaves], bud], P.out);
    const st = [stem([['M', 128, 244], ['C', 126, 214, 132, 170, 128, 122]], P.stem, 8), leafPart(129, 208, -32, 40, 15, P), leafPart(127, 226, -150, 32, 12, P, true)];
    const pet = []; for (let i = 0; i < 5; i++) { const tf = T(128, 106, i * 72); pet.push(F(rpetal(42, 25), y, { tf, det: [DF(ell(-8, -28, 6, 9), '#FFF6B5', tf, 0.95)] })); }
    const cen = F(ell(128, 106, 15, 15), c, { det: [...[0, 1, 2, 3, 4, 5, 6, 7].map(i => DF(ell(128 + Math.cos(i * 45 * D2R) * 9, 106 + Math.sin(i * 45 * D2R) * 9, 2.6, 2.6), '#FFE98A')), DF(ell(128, 106, 5, 5), '#C97E0E')] });
    emit('buttercup', 'country_bloom', 1, 2, [st, pet, [cen]], P.out);
    const cpt = []; for (let i = 0; i < 5; i++) cpt.push(crystalPetal(44, 26, T(128, 106, i * 72), GEM.topaz, P.out));
    emit('buttercup', 'country_bloom', 1, 3, [st, cpt, [gemCenter(128, 106, 16, GEM.amber, P.out)]], P.out);
  }
  // tulip ★2 — Barn Tulip
  {
    const P = CB, red = '#EB476B', back = '#C8304F', hi = '#FF8FA6';
    const blade = (x0, y0, x1, y1, w, flip) => { const mx = (x0 + x1) / 2, my = (y0 + y1) / 2, s = flip ? -1 : 1; return F([['M', x0, y0], ['C', mx - w * s, my + 10, x1 - w * 0.4 * s, y1 + 18, x1, y1], ['C', x1 + w * 0.2 * s, y1 + 30, mx + w * 0.35 * s, my + 30, x0 + 10 * s, y0], ['Z']], P.leaf, { det: [DS([['M', x0 + 3 * s, y0 - 6], ['Q', mx - w * 0.2 * s, my + 14, x1 - 2 * s, y1 + 10]], mix(P.leaf, P.out, 0.3), 2.2, ID, 0.7)] }); };
    const leaves1 = [blade(124, 240, 94, 170, 18, false), blade(132, 240, 160, 180, 16, true)];
    const budAt = (x, y, k) => F([['M', x, y - 46 * k], ['C', x + 13 * k, y - 38 * k, x + 18 * k, y - 18 * k, x + 14 * k, y - 4 * k], ['C', x + 10 * k, y + 7 * k, x - 10 * k, y + 7 * k, x - 14 * k, y - 4 * k], ['C', x - 18 * k, y - 18 * k, x - 13 * k, y - 38 * k, x, y - 46 * k], ['Z']], red, { det: [DS([['M', x, y - 40 * k], ['C', x - 6 * k, y - 26 * k, x - 6 * k, y - 10 * k, x - 2 * k, y + 4 * k]], back, 2.4), DF(ell(x - 7 * k, y - 24 * k, 4 * k, 9 * k), hi, ID, 0.9)] });
    emit('tulip', 'country_bloom', 2, 1, [[stem([['M', 128, 244], ['C', 127, 222, 130, 194, 128, 168]], P.stem, 7), S([['M', 129, 210], ['C', 140, 202, 150, 196, 156, 186]], P.stem, 5), ...leaves1], [budAt(156, 188, 0.62), budAt(128, 164, 1)]], P.out);
    const st = [stem([['M', 128, 244], ['C', 127, 214, 131, 170, 128, 126]], P.stem, 8), S([['M', 129, 196], ['C', 146, 188, 160, 178, 166, 160]], P.stem, 5), blade(123, 242, 78, 142, 26, false), blade(133, 242, 186, 178, 20, true)];
    const sideBud = budAt(166, 162, 0.66);
    // čaša: 2 zadnje latice, 2 bočne prednje, 1 srednja
    const backL = F([['M', 104, 116], ['C', 98, 96, 104, 76, 112, 64], ['C', 120, 74, 126, 88, 126, 104], ['Z']], back);
    const backR = F([['M', 152, 116], ['C', 158, 96, 152, 76, 144, 64], ['C', 136, 74, 130, 88, 130, 104], ['Z']], back);
    const sideL = F([['M', 128, 132], ['C', 104, 132, 94, 112, 98, 82], ['C', 110, 88, 122, 100, 128, 118], ['Z']], red, { det: [DF(ell(106, 100, 4, 10), hi, ID, 0.85)] });
    const sideR = F([['M', 128, 132], ['C', 152, 132, 162, 112, 158, 82], ['C', 146, 88, 134, 100, 128, 118], ['Z']], red);
    const mid = F([['M', 128, 132], ['C', 114, 128, 110, 104, 116, 86], ['C', 120, 78, 124, 72, 128, 68], ['C', 132, 72, 136, 78, 140, 86], ['C', 146, 104, 142, 128, 128, 132], ['Z']], '#F25A7B', { det: [DF(ell(122, 98, 4, 11), hi, ID, 0.9), DS([['M', 128, 76], ['L', 128, 126]], back, 2, ID, 0.6)] });
    emit('tulip', 'country_bloom', 2, 2, [st, [sideBud], [backL, backR, sideL, sideR, mid]], P.out);
    const g = GEM.ruby;
    const facetCup = (pts, cIn) => { const det = []; for (let i = 0; i < pts.length; i++) { const j = (i + 1) % pts.length; det.push(DF(poly([pts[i], pts[j], cIn]), [g.light, g.top, g.body, g.dark, g.dark, g.body][i % 6])); } return F(poly(pts), g.body, { ink: mix(g.body, P.out, 0.45), det }); };
    const cBackL = facetCup([[104, 116], [100, 88], [112, 64], [126, 92], [126, 108]], [114, 96]);
    const cBackR = facetCup([[152, 116], [156, 88], [144, 64], [130, 92], [130, 108]], [142, 96]);
    const cSideL = facetCup([[128, 132], [104, 128], [96, 104], [98, 82], [116, 96], [128, 118]], [110, 110]);
    const cSideR = facetCup([[128, 132], [152, 128], [160, 104], [158, 82], [140, 96], [128, 118]], [146, 110]);
    const cMid = facetCup([[128, 132], [114, 124], [112, 98], [120, 80], [128, 68], [136, 80], [144, 98], [142, 124]], [128, 104]);
    const cBud = facetCup([[166, 132], [175, 138], [178, 152], [174, 162], [158, 162], [154, 152], [157, 138]], [164, 148]);
    emit('tulip', 'country_bloom', 2, 3, [st, [cBud], [cBackL, cBackR, cSideL, cSideR, cMid]], P.out);
  }
  // sunflower ★2 — Sunfence
  {
    const P = CB, y = '#FFC71F', yb = '#F2A814', disc = '#73471F';
    const hl = (x, y0, a, l, w, flip) => leafPart(x, y0, a, l, w, P, flip);
    const bud = [
      F(star(8, 24, 15, -90), '#FFC71F'),
      F(star(8, 19, 12, -67.5), '#6DBE5F', { tf: T(128, 152), det: [] }),
      F(ell(128, 152, 9, 9), '#4E8F45')
    ];
    bud[0].tf = T(128, 152);
    emit('sunflower', 'country_bloom', 2, 1, [[stem([['M', 128, 244], ['C', 126, 222, 131, 196, 128, 168]], P.stem, 8), hl(128, 216, -150, 40, 17, true), hl(128, 216, -30, 40, 17)], bud], P.out);
    const st = [stem([['M', 128, 244], ['C', 125, 210, 132, 166, 128, 128]], P.stem, 10), hl(128, 202, -146, 54, 24, true), hl(128, 186, -34, 54, 24), hl(127, 226, -160, 34, 14, true)];
    const back = [], front = [];
    for (let i = 0; i < 10; i++) back.push(F(petal(56, 11, 0.32), yb, { tf: T(128, 96, i * 36 + 18) }));
    for (let i = 0; i < 10; i++) { const tf = T(128, 96, i * 36); front.push(F(petal(52, 11.5, 0.32), y, { tf, det: [DS([['M', 0, -30], ['L', 0, -46]], '#FFE07A', 2.4, tf, 0.9)] })); }
    const dsc = F(ell(128, 96, 26, 26), disc, { det: [DF(ell(128, 96, 18, 18), '#5E3A19'), ...[[121, 89], [134, 91], [128, 101], [119, 102], [137, 103], [127, 109]].map(([x, yy]) => DF(ell(x, yy, 2.4, 2.4), '#9A6A34')), DS([['M', 110, 90], ['Q', 113, 79, 124, 75]], '#A87A44', 3, ID, 0.9)] });
    emit('sunflower', 'country_bloom', 2, 2, [st, back, front, [dsc]], P.out);
    const cfront = []; for (let i = 0; i < 10; i++) cfront.push(crystalLite(54, 13, T(128, 96, i * 36), GEM.amber, P.out));
    emit('sunflower', 'country_bloom', 2, 3, [st, back, cfront, [gemCenter(128, 96, 27, GEM.smoky, P.out)]], P.out);
  }
  // pumpkin ★3 — Harvest Pumpkin
  {
    const P = CB, org = '#F2851F', lob = '#E06F14', hi = '#FFB566', brown = '#7A5A2A', bloom = '#FFB43D';
    const vineLeaf = (cx, cy, s, rot) => { const k = s / 50, tf = T(cx, cy, rot); const pts = [[0, 6 * k]]; for (let i = 0; i < 5; i++) { const a = (-162 + i * 36) * D2R; pts.push([Math.cos(a) * 50 * k, Math.sin(a) * 46 * k]); if (i < 4) { const b = (-162 + i * 36 + 18) * D2R; pts.push([Math.cos(b) * 30 * k, Math.sin(b) * 28 * k]); } } return F(smoothPoly(pts), '#6BB85F', { tf, det: [DS([['M', 0, 4 * k], ['L', 0, -38 * k]], '#4E9445', 2.4, tf, 0.8), DS([['M', 0, 0], ['L', -30 * k, -28 * k]], '#4E9445', 2, tf, 0.7), DS([['M', 0, 0], ['L', 30 * k, -28 * k]], '#4E9445', 2, tf, 0.7), DF(ell(-14 * k, -22 * k, 7 * k, 4 * k), '#A6DA9A', tf, 0.9)] }); };
    const tendril = (x, yy, s, flip) => S([['M', x, yy], ['C', x + 14 * s * (flip ? -1 : 1), yy - 4 * s, x + 18 * s * (flip ? -1 : 1), yy - 18 * s, x + 8 * s * (flip ? -1 : 1), yy - 22 * s], ['C', x + 1 * s * (flip ? -1 : 1), yy - 24 * s, x - 1 * s * (flip ? -1 : 1), yy - 15 * s, x + 6 * s * (flip ? -1 : 1), yy - 13 * s]], '#6BB85F', 4);
    const blossom = (cx, cy, r, gem) => { const parts = []; for (let i = 0; i < 5; i++) { const tf = T(cx, cy, i * 72); parts.push(gem ? crystalPetal(r, r * 0.55, tf, gem, P.out) : F(petal(r, r * 0.5, 0.26), bloom, { tf, det: [DS([['M', 0, -3], ['L', 0, -r * 0.72]], '#FFD58A', 1.8, tf, 0.9)] })); } parts.push(F(ell(cx, cy, r * 0.28, r * 0.28), '#F28C1A')); return parts; };
    // pumpkin tijelo: režnjevi od nazad ka naprijed
    const pumpkinBody = (cx, by, w, h, k, gem) => {
      const lobes = k === 5 ? [[-0.36, 0.42, lob], [0.36, 0.42, lob], [-0.2, 0.44, org], [0.2, 0.44, org], [0, 0.4, '#F7922E']] : [[-0.26, 0.5, lob], [0.26, 0.5, lob], [0, 0.46, org]];
      return lobes.map(([dx, rw, col]) => {
        const cx2 = cx + dx * w, rx = rw * w * 0.62, ry = h * 0.5, cy = by - ry;
        if (gem) {
          const pts = [[cx2 - rx, cy + ry * 0.1], [cx2 - rx * 0.7, cy - ry * 0.78], [cx2, cy - ry], [cx2 + rx * 0.7, cy - ry * 0.78], [cx2 + rx, cy + ry * 0.1], [cx2 + rx * 0.62, cy + ry * 0.94], [cx2, cy + ry], [cx2 - rx * 0.62, cy + ry * 0.94]];
          const ci = [cx2 - rx * 0.12, cy - ry * 0.12];
          const tints = [gem.light, gem.top, gem.light, gem.body, gem.dark, gem.dark, gem.body, gem.body];
          return F(poly(pts), gem.body, { ink: mix(gem.body, P.out, 0.45), det: pts.map((p, i) => DF(poly([p, pts[(i + 1) % 8], ci]), tints[i])) });
        }
        return F(ell(cx2, cy, rx, ry), col, { det: [DF(ell(cx2 - rx * 0.42, cy - ry * 0.38, rx * 0.2, ry * 0.28), hi, ID, 0.85), DS([['M', cx2, cy - ry * 0.86], ['Q', cx2 - rx * 0.16, cy, cx2, cy + ry * 0.9]], mix(col, P.out, 0.25), 2, ID, 0.6)] });
      });
    };
    // T1
    emit('pumpkin', 'country_bloom', 3, 1, [
      [vineLeaf(98, 206, 34, -24), S([['M', 150, 236], ['C', 158, 214, 158, 194, 150, 178]], '#6BB85F', 4), tendril(166, 214, 0.8, false)],
      [...blossom(150, 166, 16), ...pumpkinBody(122, 244, 62, 40, 3, null), S([['M', 122, 206], ['C', 122, 198, 126, 194, 130, 192]], brown, 6)]
    ], P.out);
    // T2
    const t2back = [vineLeaf(90, 158, 56, -18), S([['M', 166, 206], ['C', 180, 188, 180, 172, 172, 158]], '#6BB85F', 5), tendril(188, 176, 1, false), tendril(78, 200, 0.85, true)];
    const stalk = S([['M', 128, 178], ['C', 127, 164, 132, 154, 140, 148]], brown, 9);
    emit('pumpkin', 'country_bloom', 3, 2, [t2back, blossom(172, 150, 22), [...pumpkinBody(128, 244, 112, 70, 5, null), stalk]], P.out);
    emit('pumpkin', 'country_bloom', 3, 3, [t2back, blossom(172, 150, 22, GEM.amber), [...pumpkinBody(128, 244, 112, 70, 5, GEM.opalFire), stalk]], P.out);
  }

  // ======================= MOONLIT WARREN =======================
  const crescent = (cx, cy, r, th, rot) => { // polumjesec: vanjski luk r, unutrašnji pomaknut
    const a0 = (rot - 70) * D2R, a1 = (rot + 70) * D2R, ri = r * 0.86;
    const ox = Math.cos(rot * D2R) * th, oy = Math.sin(rot * D2R) * th;
    const p0 = [cx + Math.cos(a0 + Math.PI) * r * -1, cy + Math.sin(a0 + Math.PI) * r * -1];
    // jednostavnije: poligon po uzorcima
    const pts = [];
    for (let i = 0; i <= 12; i++) { const a = (rot + 180 - 110 + i * 220 / 12) * D2R; pts.push([cx + Math.cos(a) * r, cy + Math.sin(a) * r]); }
    for (let i = 12; i >= 0; i--) { const a = (rot + 180 - 78 + i * 156 / 12) * D2R; pts.push([cx - ox + Math.cos(a) * ri * 0.92, cy - oy + Math.sin(a) * ri * 0.92]); }
    return pts;
  };
  // (smoothPoly je gore)
  // moon_moss ★1
  {
    const P = MW, moss = '#6FA494', mossD = '#55897B', stalk = '#D8C98E', moon = '#ECEAFF';
    const cushion = (w, h, bumps) => { const pts = [[128 - w / 2, 244], [128 + w / 2, 244]]; const top = []; for (let i = 0; i <= bumps; i++) { const t = i / bumps, x = 128 + w / 2 - t * w; const yy = 244 - Math.sin(Math.PI * t) * h - (i % 2 ? h * 0.12 : 0); top.push([x, yy]); } return F([['M', 128 - w / 2, 244], ['L', 128 + w / 2, 244], ...top.slice(1).map((p, i) => { const q = top[i]; return ['Q', (p[0] + q[0]) / 2 + 2, Math.min(p[1], q[1]) - h * 0.22, p[0], p[1]]; }), ['Z']], moss, { det: [DF(ell(128 - w * 0.18, 244 - h * 0.62, w * 0.12, h * 0.16), '#9CCDBE', ID, 0.9), DF(ell(128 + w * 0.2, 244 - h * 0.3, 3, 3), '#E6E4FF'), DF(ell(128 - w * 0.32, 244 - h * 0.24, 2.4, 2.4), '#E6E4FF')] }); };
    const cap = (cx, cy, r, rot, gem) => { const pts = crescent(cx, cy, r, r * 0.5, rot); if (!gem) return F(poly(pts), moon, { det: [DF(poly(pts.slice(0, 7).concat([[cx + Math.cos((rot + 180) * D2R) * r * 0.55, cy + Math.sin((rot + 180) * D2R) * r * 0.55]])), '#C9C5F2', ID, 0.8)] }); const g = GEM.moonstone, mid = Math.floor(pts.length / 2), q = Math.floor(mid / 2); return F(poly(pts), g.body, { ink: mix(g.body, P.out, 0.45), det: [DF(poly(pts.slice(0, q + 1).concat(pts.slice(pts.length - q - 1))), g.light), DF(poly(pts.slice(q, mid + 1).concat(pts.slice(mid, pts.length - q))), g.dark), DS(line([pts[q], pts[pts.length - q - 1]]), mix(g.body, P.out, 0.3), 1.6, ID, 0.7)] }); };
    emit('moon_moss', 'moonlit_warren', 1, 1, [[S([['M', 128, 222], ['C', 127, 204, 131, 186, 128, 166]], stalk, 4)], [cushion(92, 34, 4)], [cap(128, 156, 15, -30)]], P.out);
    const stalks = [S([['M', 128, 222], ['C', 126, 190, 132, 150, 128, 116]], stalk, 4), S([['M', 108, 226], ['C', 104, 200, 96, 172, 92, 148]], stalk, 3.5), S([['M', 150, 226], ['C', 154, 200, 164, 176, 168, 134]], stalk, 3.5)];
    emit('moon_moss', 'moonlit_warren', 1, 2, [stalks, [cushion(150, 44, 6)], [cap(128, 104, 18, -30), cap(91, 138, 13, -60), cap(168, 122, 14, 0)]], P.out);
    emit('moon_moss', 'moonlit_warren', 1, 3, [stalks, [cushion(150, 44, 6)], [cap(128, 104, 18, -30, true), cap(91, 138, 13, -60, true), cap(168, 122, 14, 0, true)]], P.out);
  }
  // nightshade_petal ★1
  {
    const P = MW, vio = '#A98CEB', vioD = '#7A5CCB', gold = '#FFD45E';
    const bud = [F([['M', 128, 132], ['C', 140, 142, 144, 160, 138, 170], ['L', 118, 170], ['C', 112, 160, 116, 142, 128, 132], ['Z']], vio, { det: [DS([['M', 128, 138], ['L', 128, 168]], vioD, 2.2), DF(ell(122, 152, 3.5, 8), '#C7B6FF', ID, 0.9)] }), F(star(5, 16, 7, 90), '#8FC7B9', { tf: T(128, 172) })];
    emit('nightshade_petal', 'moonlit_warren', 1, 1, [[stem([['M', 128, 244], ['C', 127, 224, 131, 200, 128, 176]], P.stem, 7), leafPart(128, 222, -148, 34, 13, P, true), leafPart(128, 222, -32, 34, 13, P)], bud], P.out);
    const st = [stem([['M', 128, 244], ['C', 125, 212, 132, 170, 128, 118]], P.stem, 8), leafPart(129, 208, -30, 42, 15, P), leafPart(127, 186, -154, 34, 13, P, true)];
    const pet = []; for (let i = 0; i < 5; i++) { const tf = T(128, 104, i * 72); pet.push(F(petal(46, 16, 0.2), vio, { tf, det: [DS([['M', 0, -4], ['L', 0, -36]], '#C9B8FF', 2.4, tf, 0.9), DF(poly([[0, 0], [8, -12], [0, -18], [-8, -12]]), vioD, tf)] })); }
    const cone = F([['M', 128, 86], ['C', 136, 94, 138, 110, 134, 118], ['L', 122, 118], ['C', 118, 110, 120, 94, 128, 86], ['Z']], gold, { det: [DF(ell(125, 102, 2.5, 7), '#FFF0B8')] });
    emit('nightshade_petal', 'moonlit_warren', 1, 2, [st, pet, [cone]], P.out);
    const cp = []; for (let i = 0; i < 5; i++) cp.push(crystalPetal(48, 17, T(128, 104, i * 72), GEM.amethyst, P.out));
    emit('nightshade_petal', 'moonlit_warren', 1, 3, [st, cp, [gemCenter(128, 104, 13, GEM.goldGem, P.out)]], P.out);
  }
  // silver_harebell ★1
  {
    const P = MW, bell = '#C7CBF4', inner = '#7F86D6';
    const blades = [F([['M', 122, 244], ['C', 112, 226, 104, 210, 98, 194], ['C', 110, 206, 120, 222, 128, 244], ['Z']], P.leaf), F([['M', 134, 244], ['C', 142, 228, 150, 216, 160, 206], ['C', 150, 220, 142, 232, 140, 244], ['Z']], P.leaf)];
    const budT1 = F([['M', 164, 178], ['C', 178, 183, 181, 200, 176, 210], ['L', 164, 218], ['L', 152, 210], ['C', 147, 200, 150, 183, 164, 178], ['Z']], bell, { det: [DS([['M', 164, 183], ['L', 164, 213]], '#9FA5E8', 2), DF(ell(157, 194, 2.6, 7), '#EEF0FF', ID, 0.9)] });
    emit('silver_harebell', 'moonlit_warren', 1, 1, [[S([['M', 128, 244], ['C', 126, 212, 132, 184, 148, 172], ['C', 156, 166, 164, 170, 164, 180]], P.stem, 5), ...blades], [budT1]], P.out);
    const st = [S([['M', 128, 244], ['C', 124, 200, 128, 150, 150, 120], ['C', 160, 108, 172, 110, 176, 122]], P.stem, 5), ...blades, leafPart(127, 196, -150, 28, 9, P, true)];
    const bellPts = [[176, 122], [196, 132], [204, 160], [210, 184], [200, 180], [194, 192], [184, 184], [176, 196], [168, 184], [158, 192], [152, 180], [142, 184], [148, 160], [156, 132]];
    const bellShape = smoothPoly([[176, 122], [196, 132], [204, 160], [212, 186], [198, 182], [188, 192], [176, 186], [164, 192], [154, 182], [140, 186], [148, 160], [156, 132]]);
    const b2 = F(bellShape, bell, { det: [DF(ell(176, 184, 22, 5), inner), DS([['M', 176, 182], ['L', 177, 202]], '#FFE7A0', 3), DF(ell(162, 150, 4, 12), '#EEF0FF', ID, 0.9)] });
    emit('silver_harebell', 'moonlit_warren', 1, 2, [st, [b2]], P.out);
    const g = GEM.iolite;
    const bp = [[176, 122], [194, 130], [204, 158], [212, 186], [176, 188], [140, 186], [148, 158], [158, 130]];
    const crys = F(poly(bp), g.body, { ink: mix(g.body, P.out, 0.45), det: [DF(poly([[176, 122], [158, 130], [148, 158], [140, 186], [162, 187], [166, 140]]), g.light), DF(poly([[176, 122], [166, 140], [162, 187], [190, 187], [186, 140]]), g.body), DF(poly([[176, 122], [186, 140], [190, 187], [212, 186], [204, 158], [194, 130]]), g.dark), DF(poly([[166, 140], [176, 122], [186, 140], [176, 152]]), g.top), DF(ell(176, 186, 20, 4), inner), DS([['M', 176, 186], ['L', 177, 204]], '#FFE7A0', 3)] });
    emit('silver_harebell', 'moonlit_warren', 1, 3, [st, [crys]], P.out);
  }
  // lunar_orchid ★2
  {
    const P = MW, white = '#F3F0FF', lip = '#8B67D8', gold = '#FFE08A';
    const broad = [leafPart(126, 238, -168, 62, 20, P, true), leafPart(130, 238, -12, 62, 20, P), leafPart(128, 240, -96, 40, 14, P)];
    emit('lunar_orchid', 'moonlit_warren', 2, 1, [[S([['M', 128, 232], ['C', 124, 200, 134, 168, 158, 150]], P.stem, 5), ...broad], [F(ell(160, 146, 11, 10), white, { det: [DF(ell(156, 142, 4, 3), '#FFFFFF')] }), F(ell(142, 160, 8, 8), '#E3DCFF'), F(ell(170, 160, 6, 6), '#D9D0FF')]], P.out);
    const st = [S([['M', 128, 232], ['C', 122, 190, 128, 150, 140, 126]], P.stem, 6), S([['M', 140, 126], ['C', 152, 112, 166, 112, 176, 122]], P.stem, 4), ...broad];
    const ox = 128, oy = 104;
    const parts = [
      F(petal(40, 14, 0.3), white, { tf: T(ox, oy, 0) }),
      F(petal(36, 12, 0.3), white, { tf: T(ox, oy, 140) }), F(petal(36, 12, 0.3), white, { tf: T(ox, oy, -140) }),
      F(rpetal(40, 22), '#FBF9FF', { tf: T(ox, oy, -78), det: [DS([['M', 0, -6], ['L', 0, -32]], '#D9D2FF', 2, T(ox, oy, -78))] }),
      F(rpetal(40, 22), '#FBF9FF', { tf: T(ox, oy, 78), det: [DS([['M', 0, -6], ['L', 0, -32]], '#D9D2FF', 2, T(ox, oy, 78))] }),
      F([['M', ox - 13, oy + 4], ['C', ox - 18, oy + 22, ox - 6, oy + 32, ox, oy + 32], ['C', ox + 6, oy + 32, ox + 18, oy + 22, ox + 13, oy + 4], ['C', ox + 6, oy + 10, ox - 6, oy + 10, ox - 13, oy + 4], ['Z']], lip, { det: [DF(ell(ox, oy + 20, 5, 6), '#C9B4FF'), DS([['M', ox - 6, oy + 14], ['L', ox - 3, oy + 24]], '#6A48BE', 1.8)] }),
      F(ell(ox, oy + 2, 6, 7), gold)
    ];
    const bud = F(ell(178, 128, 8, 9), '#E3DCFF');
    emit('lunar_orchid', 'moonlit_warren', 2, 2, [st, [bud], parts], P.out);
    const g = GEM.opal, cparts = [
      crystalPetal(40, 14, T(ox, oy, 0), g, P.out), crystalPetal(36, 12, T(ox, oy, 140), g, P.out), crystalPetal(36, 12, T(ox, oy, -140), g, P.out),
      crystalPetal(40, 22, T(ox, oy, -78), g, P.out), crystalPetal(40, 22, T(ox, oy, 78), g, P.out),
      gemCenter(ox, oy + 18, 13, GEM.amethyst, P.out), gemCenter(ox, oy + 1, 6, GEM.goldGem, P.out)
    ];
    emit('lunar_orchid', 'moonlit_warren', 2, 3, [st, [bud], cparts], P.out);
  }
  // star_jasmine ★2
  {
    const P = MW, white = '#FFFCF2', cen = '#FFE39A', gl = '#5F948A', glHi = '#9CCBC2';
    const oval = (x, y, a, l, w) => { const tf = T(x, y, a); return F(leaf(l, w), gl, { tf, det: [DF([['M', 0, 0], ['C', l * 0.28, -w, l * 0.72, -w, l, 0], ['Q', l * 0.5, -w * 0.2, 0, 0], ['Z']], glHi, tf, 0.85)] }); };
    const pinPetal = (l, w) => [['M', 0, 0], ['C', w * 0.9, -l * 0.18, w * 1.15, -l * 0.74, w * 0.25, -l], ['C', -w * 0.2, -l * 0.86, -w * 0.34, -l * 0.42, 0, 0], ['Z']];
    const pin = (cx, cy, r, rot, gem) => { const ps = []; for (let i = 0; i < 5; i++) { const tf = T(cx, cy, rot + i * 72); ps.push(gem ? crystalLite(r, r * 0.46, tf, gem, P.out) : F(pinPetal(r, r * 0.46), white, { tf, det: [DS([['M', 0, -3], ['Q', r * 0.2, -r * 0.5, r * 0.18, -r * 0.82]], '#E8E0C8', 1.8, tf)] })); } ps.push(gem ? gemSmall(cx, cy, r * 0.26, GEM.goldGem, P.out) : F(star(5, r * 0.26, r * 0.12, rot - 90), cen, { tf: T(cx, cy) })); return ps; };
    const budS = (x, y, a, l) => { const tf = T(x, y, a); return F([['M', 0, 0], ['C', 5, -l * 0.3, 5, -l * 0.8, 0, -l], ['C', -5, -l * 0.8, -5, -l * 0.3, 0, 0], ['Z']], white, { tf, det: [DF(ell(0, -l * 0.86, 2.6, 3.4), '#F6C9D6', tf)] }); };
    const st1 = [S([['M', 128, 244], ['C', 118, 216, 140, 196, 128, 170], ['C', 122, 158, 130, 148, 136, 142]], P.stem, 6), oval(124, 208, -160, 30, 11), oval(134, 184, -20, 28, 10), oval(128, 160, -150, 24, 9)];
    emit('star_jasmine', 'moonlit_warren', 2, 1, [st1, [budS(136, 142, -10, 24), budS(134, 146, -50, 20), budS(138, 146, 30, 20)]], P.out);
    const st = [S([['M', 128, 244], ['C', 116, 214, 142, 188, 128, 152], ['C', 120, 132, 130, 114, 138, 104]], P.stem, 6), S([['M', 128, 154], ['C', 142, 146, 158, 140, 172, 130]], P.stem, 4.5), S([['M', 126, 168], ['C', 114, 160, 106, 150, 100, 140]], P.stem, 4), oval(124, 214, -160, 32, 12), oval(134, 192, -24, 32, 12), oval(152, 146, -70, 24, 9), oval(110, 154, -120, 22, 8)];
    emit('star_jasmine', 'moonlit_warren', 2, 2, [st, [budS(184, 138, 40, 18)], pin(172, 128, 22, 10), pin(100, 138, 21, -14), pin(138, 96, 28, 0)], P.out);
    emit('star_jasmine', 'moonlit_warren', 2, 3, [st, [budS(184, 138, 40, 18)], pin(172, 128, 22, 10, GEM.diamond), pin(100, 138, 21, -14, GEM.diamond), pin(138, 96, 28, 0, GEM.diamond)], P.out);
  }
  // umbral_lily ★3
  {
    const P = MW, vio = '#7E68DA', vioB = '#6853C2', edge = '#D8CEFF', throat = '#E9E1FF', fil = '#F2E8D0', anth = '#FFC85A';
    const narrow = (x, y, a, l, flip) => leafPart(x, y, a, l, 9, P, flip);
    const budL = (x, y, a, l, w) => { const tf = T(x, y, a); return F([['M', 0, 0], ['C', w, -l * 0.25, w * 0.8, -l * 0.8, 0, -l], ['C', -w * 0.8, -l * 0.8, -w, -l * 0.25, 0, 0], ['Z']], vio, { tf, det: [DS([['M', 0, -4], ['L', 0, -l * 0.9]], edge, 2, tf), DS([['M', -w * 0.45, -l * 0.2], ['Q', -w * 0.55, -l * 0.6, -w * 0.15, -l * 0.86]], edge, 1.6, tf, 0.8)] }); };
    emit('umbral_lily', 'moonlit_warren', 3, 1, [[stem([['M', 128, 244], ['C', 127, 210, 131, 170, 128, 122]], P.stem, 7), S([['M', 129, 150], ['C', 140, 142, 148, 138, 152, 128]], P.stem, 4), narrow(128, 216, -150, 48, true), narrow(128, 196, -30, 46), narrow(128, 176, -152, 40, true)], [budL(152, 130, 20, 30, 8), budL(128, 124, 0, 46, 11)]], P.out);
    const st = [stem([['M', 128, 244], ['C', 126, 206, 132, 160, 128, 120]], P.stem, 8), S([['M', 129, 156], ['C', 146, 152, 160, 142, 166, 130]], P.stem, 4), narrow(128, 222, -150, 52, true), narrow(128, 204, -30, 50), narrow(128, 180, -154, 44, true)];
    const cx = 126, cy = 94;
    // 3/4 pogled odozgo (TS: rotacija, sabijanje .72, nagib -10): ne čita se kao zvijezda
    const tepal = (a, l, w, col, gem, x0 = cx, y0 = cy, k = 1) => { const tf = TS(x0, y0, a, 0.72, -10, k); if (gem) return crystalLite(l, w, tf, gem, P.out); if (k < 1) return F([['M', 0, 0], ['C', w, -l * 0.3, w * 0.9, -l * 0.72, 0, -l], ['C', -w * 0.9, -l * 0.72, -w, -l * 0.3, 0, 0], ['Z']], col, { tf }); return F([['M', 0, 0], ['C', w, -l * 0.3, w * 0.9, -l * 0.72, w * 0.25, -l * 0.94], ['Q', 0, -l * 1.08, -w * 0.4, -l * 0.86], ['C', -w * 0.95, -l * 0.7, -w, -l * 0.3, 0, 0], ['Z']], col, { tf, det: [DS([['M', -w * 0.62, -l * 0.3], ['C', -w * 0.75, -l * 0.6, -w * 0.4, -l * 0.84, 0, -l * 0.9]], edge, 2.2, tf, 0.9), DF(ell(0, -l * 0.22, w * 0.42, l * 0.16), throat, tf, 0.95)] }); };
    const bloomAt = (x0, y0, k, gem) => k < 1 ? [200, 300, 250].map(a => tepal(a, 50, 15, a === 250 ? vio : vioB, gem && a === 250 ? GEM.amethyst : null, x0, y0, k)) : [
      ...[180, 300, 60].map((a, i) => tepal(a, 54, 15, vioB, gem ? GEM.tanzanite : null, x0, y0, k)),
      ...[240, 0, 120].map(a => tepal(a, 52, 17, vio, gem ? GEM.amethyst : null, x0, y0, k))
    ];
    const stamenSet = (x0, y0, k, gem) => { const det = [], extra = []; for (let i = 0; i < (k < 1 ? 3 : 5); i++) { const a = (-130 + i * (k < 1 ? 40 : 20)) * D2R, x2 = x0 + Math.cos(a) * 38 * k, y2 = y0 + Math.sin(a) * 34 * k; det.push(DS([['M', x0, y0], ['Q', x0 + Math.cos(a) * 14 * k, y0 + Math.sin(a) * 26 * k, x2, y2]], fil, 2.4)); if (gem) { det.push(DF(poly([[x2, y2 - 5], [x2 + 4, y2], [x2, y2 + 5], [x2 - 4, y2]]), GEM.goldGem.body)); det.push(DF(poly([[x2, y2 - 5], [x2 - 4, y2], [x2, y2]]), GEM.goldGem.top)); } else det.push(DF(ell(x2, y2, 4.2, 3), anth)); } return [F(ell(x0, y0 + 2, 6 * k, 5 * k), '#D9E8A8', { det }), ...extra]; };
    const bud2 = budL(178, 150, 34, 26, 7);
    emit('umbral_lily', 'moonlit_warren', 3, 2, [st, [bud2], bloomAt(166, 128, 0.58), stamenSet(166, 128, 0.58), bloomAt(cx, cy, 1), stamenSet(cx, cy, 1)], P.out);
    emit('umbral_lily', 'moonlit_warren', 3, 3, [st, [bud2], bloomAt(166, 128, 0.58, true), stamenSet(166, 128, 0.58, true), bloomAt(cx, cy, 1, true), stamenSet(cx, cy, 1, true)], P.out);
  }
  // ======================= FAZA 2 — arhetipovi (isti jezik: jedan debeli rub siluete, tanke unutrašnje linije, ravni odsjaji; T3 = isti crtež kao brušeni kristal) =======================
  Object.assign(GEM, {
    aquamarine: { body: '#9FE3F0', light: '#E3FAFF', dark: '#5EB3CC', top: '#F4FDFF' },
    sapphire: { body: '#7F9CF0', light: '#CCD9FF', dark: '#4A68C9', top: '#EDF1FF' },
    garnet: { body: '#E0505F', light: '#FF9EA8', dark: '#A42840', top: '#FFD4DA' },
    peridot: { body: '#B6E04A', light: '#E6FA9E', dark: '#7FA82A', top: '#F6FFD0' },
    roseq: { body: '#F7B3C6', light: '#FFE1EA', dark: '#D97E9A', top: '#FFF2F6' },
    copper: { body: '#E8914F', light: '#FFC896', dark: '#B05E22', top: '#FFE6CC' },
    tourmaline: { body: '#F07AA0', light: '#FFC2D4', dark: '#BD4772', top: '#FFE6EE' },
    pearl: { body: '#F4EEE6', light: '#FFFFFF', dark: '#D6CBBE', top: '#FFFFFF' },
    coralG: { body: '#FF8A73', light: '#FFC5B8', dark: '#D9573F', top: '#FFE4DD' },
    teal: { body: '#5FD1C2', light: '#B8F5EC', dark: '#2E9C8E', top: '#E6FFFB' },
    fire: { body: '#FF7A3D', light: '#FFC08F', dark: '#D24A12', top: '#FFE0C7' },
    smokeQ: { body: '#C2BACF', light: '#ECE8F3', dark: '#948AA6', top: '#F7F5FB' },
    violet: { body: '#B98CF0', light: '#E8D8FF', dark: '#8558C9', top: '#F6F0FF' },
    navy: { body: '#7684EA', light: '#C3CAFF', dark: '#4A55C2', top: '#E9ECFF' }
  });
  const notchP = (l, w) => [['M', 0, 0], ['C', w * 0.9, -l * 0.18, w * 1.12, -l * 0.8, w * 0.48, -l], ['Q', 0, -l * 0.84, -w * 0.48, -l], ['C', -w * 1.12, -l * 0.8, -w * 0.9, -l * 0.18, 0, 0], ['Z']];
  const SHP = { petal: (l, w) => petal(l, w, 0.3), pin: (l, w) => petal(l, w, 0.2), round: rpetal, notch: notchP };
  function gemStar(cx, cy, r, gem, OUT, k = 5) { const pts = []; for (let i = 0; i < k * 2; i++) { const a = (-90 + i * 180 / k) * D2R, rr = i % 2 ? r * 0.46 : r; pts.push([Math.cos(a) * rr, Math.sin(a) * rr]); } const det = []; for (let i = 0; i < k * 2; i++) det.push(DF(poly([[0, 0], pts[i], pts[(i + 1) % (k * 2)]]), i === 0 ? gem.top : i % 2 ? gem.dark : gem.light, T(cx, cy))); return F(poly(pts), gem.body, { tf: T(cx, cy), ink: mix(gem.body, OUT, 0.45), det }); }
  function facetPoly(pts, gem, OUT) { const c = pts.reduce((a, p) => [a[0] + p[0] / pts.length, a[1] + p[1] / pts.length], [0, 0]); const ci = [c[0] - 3, c[1] - 4]; const tints = [gem.light, gem.top, gem.light, gem.body, gem.dark, gem.dark, gem.body, gem.body]; return F(poly(pts), gem.body, { ink: mix(gem.body, OUT, 0.45), det: pts.map((p, i) => DF(poly([p, pts[(i + 1) % pts.length], ci]), tints[Math.floor(i * 8 / pts.length) % 8])) }); }
  function centerParts(c, cx, cy, k, stage, P) {
    const r = c.r * k, x = cx + (c.dx || 0) * k, y = cy + (c.dy || 0) * k, sy = c.sq ?? 1;
    if (stage === 3) return [c.kind === 'star' ? gemStar(x, y, r, c.gem, P.out) : r >= 16 ? gemCenter(x, y, r, c.gem, P.out) : gemSmall(x, y, r, c.gem, P.out)];
    if (c.kind === 'star') return [F(star(5, r, r * 0.46, -90), c.col, { tf: T(x, y), det: [DF(ell(0, 0, r * 0.28, r * 0.28), c.col2, T(x, y))] })];
    if (c.kind === 'stamens') { const det = [], n2 = c.n || 6, sp = c.spread || 60; for (let i = 0; i < n2; i++) { const a = (-90 - sp + i * 2 * sp / Math.max(1, n2 - 1)) * D2R, L = r * (c.len || 2.4), x2 = x + Math.cos(a) * L, y2 = y + Math.sin(a) * L; det.push(DS([['M', x, y], ['Q', x + Math.cos(a) * L * 0.5, y + Math.sin(a) * L * 0.62, x2, y2]], c.col2, 2.4)); det.push(DF(ell(x2, y2, 3.8, 3), c.tip || c.col)); } return [F(ell(x, y, r * 0.7, r * 0.6), c.col, { det })]; }
    if (c.kind === 'swirl') return [F(ell(x, y, r, r * sy), c.col, { det: [DS([['M', x - r * 0.62, y], ['Q', x - r * 0.2, y - r * 0.85 * sy, x + r * 0.5, y - r * 0.25 * sy], ['Q', x + r * 0.25, y + r * 0.5 * sy, x - r * 0.15, y + r * 0.1 * sy]], c.col2, 2.4)] })];
    const det = [DF(ell(x - r * 0.3, y - r * 0.3 * sy, r * 0.32, r * 0.24 * sy), c.hi || '#FFFFFF', ID, 0.5)];
    if (c.kind === 'dots') for (let i = 0; i < 6; i++) { const a = i * 60 * D2R; det.push(DF(ell(x + Math.cos(a) * r * 0.56, y + Math.sin(a) * r * 0.56 * sy, Math.max(2, r * 0.13), Math.max(2, r * 0.13)), c.col2)); }
    return [F(ell(x, y, r, r * sy), c.col, { det })];
  }
  // glava: prstenovi latica (puni krug ili lepeza `span`), 3/4 pogled preko sq/tilt. stage 1 = pupoljak (latice se skupe prema gore), 2 = cvijet, 3 = kristal
  function head(o, cx, cy, k, stage, P) {
    const groups = [], sq = o.sq ?? 1, tilt = o.tilt || 0, dir = o.dir || 0;
    o.rings.forEach(R => {
      if (stage === 1 && R.t1 === false) return;
      const items = [];
      for (let i = 0; i < R.n; i++) {
        let a = R.span != null ? (R.n === 1 ? 0 : -R.span + i * 2 * R.span / (R.n - 1)) : (R.rot || 0) + i * 360 / R.n, l = R.l * k, w = R.w * k;
        if (stage === 1) { a = ((((a + 180) % 360) + 360) % 360) - 180; a *= R.span != null ? 0.55 : 0.24; l *= 0.8; w *= 0.88; }
        items.push({ a, l, w });
      }
      const fan = R.span != null || stage === 1;
      items.sort((p, q) => fan ? Math.abs(q.a) - Math.abs(p.a) : Math.cos(q.a * D2R) - Math.cos(p.a * D2R));
      groups.push(items.map(({ a, l, w }) => {
        const tf = TS(cx, cy, a + dir, stage === 1 ? 1 : sq, stage === 1 ? 0 : tilt, 1);
        if (stage === 3 && !R.keep) return crystalLite(l, w, tf, R.gem || o.gem, P.out);
        const det = [];
        if (R.blot) det.push(DF(ell(0, -l * 0.2, w * 0.42, l * 0.17), R.blot, tf, 0.95));
        if (R.vein) det.push(DS([['M', 0, -l * 0.14], ['L', 0, -l * 0.74]], R.vein, 2.2, tf, 0.9));
        if (R.hi) det.push(DF(ell(-w * 0.36, -l * 0.56, w * 0.17, l * 0.16), R.hi, tf, 0.9));
        return F(SHP[R.shape || o.shape || 'petal'](l, w), R.col, { tf, det });
      }));
    });
    if (stage === 1 && o.calyx !== false) groups.push([F(star(5, 13 * k, 6 * k, 90), P.leaf, { tf: T(cx, cy + 4 * k) })]);
    if (o.center && stage !== 1) groups.push(centerParts(o.center, cx, cy, k, stage, P));
    return groups;
  }
  function closedBud(x, y, a, l, w, col, stage, gem, P) { const tf = T(x, y, a); if (stage === 3) return crystalLite(l, w, tf, gem, P.out); return F([['M', 0, 0], ['C', w, -l * 0.25, w * 0.8, -l * 0.8, 0, -l], ['C', -w * 0.8, -l * 0.8, -w, -l * 0.25, 0, 0], ['Z']], col, { tf, det: [DS([['M', 0, -3], ['L', 0, -l * 0.85]], mix(col, P.out, 0.3), 2, tf, 0.7), DF(ell(-w * 0.35, -l * 0.5, w * 0.16, l * 0.16), mix(col, '#FFFFFF', 0.5), tf, 0.8)] }); }
  function colLeaf(x, y, ang, l, w, col, P, stage, gem, flip = false) { if (stage === 3 && gem) return crystalLite(l, w * 0.9, T(x, y, ang + 90), gem, P.out); const tf = T(x, y, ang, 1, flip ? -1 : 1); return F(leaf(l, w), col, { tf, det: [DS([['M', l * 0.08, 0], ['L', l * 0.86, 0]], mix(col, P.out, 0.35), 2.2, tf, 0.8), DS([['M', l * 0.4, 0], ['L', l * 0.56, -w * 0.5]], mix(col, P.out, 0.35), 1.8, tf, 0.6), DS([['M', l * 0.28, 0], ['L', l * 0.44, w * 0.5]], mix(col, P.out, 0.35), 1.8, tf, 0.6), DF(ell(l * 0.36, -w * 0.32, l * 0.14, w * 0.14), mix(col, '#FFFFFF', 0.45), tf, 0.85)] }); }
  function lobedLeaf(x, y, ang, l, w, col, P, lobes = 4) { const pts = [[0, 0]]; for (let i = 1; i <= lobes; i++) { const t = i / (lobes + 1); pts.push([w * (i % 2 ? 1 : 0.6) * Math.sin(Math.PI * t) * 1.1, -l * t]); } pts.push([0, -l]); for (let i = lobes; i >= 1; i--) { const t = i / (lobes + 1); pts.push([-w * (i % 2 ? 1 : 0.6) * Math.sin(Math.PI * t) * 1.1, -l * t]); } const tf = T(x, y, ang); return F(smoothPoly(pts), col, { tf, det: [DS([['M', 0, -2], ['L', 0, -l * 0.86]], mix(col, P.out, 0.35), 2.2, tf, 0.8), DF(ell(-w * 0.3, -l * 0.45, w * 0.18, l * 0.12), mix(col, '#FFFFFF', 0.4), tf, 0.8)] }); }
  const padPart = (x, y, rx, ry, col, P) => F([['M', x, y], ['L', x + rx * 0.2, y - ry], ['C', x + rx * 0.9, y - ry * 1.05, x + rx * 1.05, y + ry * 0.7, x + rx * 0.2, y + ry], ['C', x - rx * 0.6, y + ry * 1.1, x - rx * 1.05, y + ry * 0.4, x - rx, y - ry * 0.1], ['C', x - rx * 0.9, y - ry * 0.8, x - rx * 0.35, y - ry * 1.05, x - rx * 0.1, y - ry], ['Z']], col, { det: [DS([['M', x, y], ['L', x - rx * 0.6, y + ry * 0.5]], mix(col, P.out, 0.25), 2, ID, 0.6), DS([['M', x, y], ['L', x + rx * 0.5, y + ry * 0.6]], mix(col, P.out, 0.25), 2, ID, 0.6), DF(ell(x - rx * 0.42, y - ry * 0.3, rx * 0.2, ry * 0.25), mix(col, '#FFFFFF', 0.35), ID, 0.8)] });
  // biljka s glavom: stabljika, listovi, pupoljci, druge glave (rijetkost), kuke back/front(stage, hx, hy, hk)
  function plant(o) {
    const P = o.P, sw = o.stemW || 8, sc = o.stemCol || P.stem;
    for (let stage = 1; stage <= 3; stage++) {
      const [mx, my, mk] = o.main;
      const hx = stage === 1 ? 128 + (mx - 128) * 0.7 : mx, hy = stage === 1 ? 244 - (244 - my) * (o.t1h || 0.66) : my, hk = stage === 1 ? mk * (o.t1k || 1.05) : mk;
      const sp = [];
      if (!o.noStem) sp.push(S([['M', 128, 244], ['C', 128 + (o.bend || 0), 244 - (244 - hy) * 0.4, hx - (o.bend || 0) * 0.5, hy + (244 - hy) * 0.3, hx, hy]], sc, sw));
      const extras = stage === 1 ? [] : (o.extra || []);
      extras.forEach(([ex, ey, , eb]) => sp.push(S([['M', 128, 244 - (244 - ey) * 0.4], ['Q', ex + (eb || 0), ey + 34, ex, ey]], sc, sw * 0.72)));
      const buds = stage === 1 ? [] : (o.buds || []);
      buds.forEach(([bx, by, ba, bl]) => { const r = ba * D2R; sp.push(S([['M', o.noStem ? bx : 128, o.noStem ? 244 : Math.min(236, by + 46)], ['Q', bx - Math.sin(r) * 14, by + 22, bx, by]], sc, sw * 0.6)); });
      const lv = stage === 1 ? (o.leaves || []).slice(0, o.t1leaves || 2).map(L => [L[0], 244 - (244 - L[1]) * 0.7, L[2], L[3] * 0.8, L[4] * 0.8, L[5]]) : (o.leaves || []);
      lv.forEach(([x, y, a, l, w, flip]) => sp.push(o.leafCol ? colLeaf(x, y, a, l, w, o.leafCol, P, 2, null, flip) : leafPart(x, y, a, l, w, P, flip)));
      const g = [];
      if (o.back) g.push(...o.back(stage, hx, hy, hk));
      if (sp.length) g.push(sp);
      if (o.mid) g.push(...o.mid(stage, hx, hy, hk));
      if (buds.length) g.push(buds.map(([bx, by, ba, bl, bw]) => closedBud(bx, by, ba, bl, bw, o.budCol, stage, o.budGem || o.head.gem || o.head.rings[0].gem, P)));
      extras.forEach(([ex, ey, ek]) => g.push(...head(o.head2 || o.head, ex, ey, ek, stage, P)));
      g.push(...head(o.head, hx, hy, hk, stage, P));
      if (o.front) g.push(...o.front(stage, hx, hy, hk));
      emit(o.id, o.season, o.rarity, stage, g, P.out);
    }
  }
  // vlati s vrhom (svitac, rogoz, kometa)
  function spikePlant(o) {
    const P = o.P;
    for (let stage = 1; stage <= 3; stage++) {
      const bl = stage === 1 ? o.blades.slice(0, o.t1n || 3).map(b => [b[0], b[1] * 0.8, b[2] * 0.66, b[3] * 0.9]) : o.blades;
      const blades = [], tips = [], tails = [];
      bl.forEach(([x0, ang, len, w], i) => {
        const tf = T(x0, 244, ang), bc = o.bladeCol || P.leaf;
        blades.push(F(petal(len, w, 0.14), bc, { tf, det: [DS([['M', 0, -6], ['L', 0, -len * 0.8]], mix(bc, P.out, 0.3), 2, tf, 0.7)] }));
        const on = stage === 1 ? i === 0 : (!o.tipOn || o.tipOn.includes(i));
        if (!on) return;
        const [tx, ty] = tf(0, -len * 0.97), r = (o.tipR || 9) * (stage === 1 ? 0.8 : 1);
        if (o.tip === 'glow') tips.push(stage === 3 ? gemSmall(tx, ty, r, o.gem, P.out) : F(ell(tx, ty, r, r), o.tipCol, { det: [DF(ell(tx - r * 0.3, ty - r * 0.3, r * 0.36, r * 0.3), o.tipHi)] }));
        if (o.tip === 'seed') { const q = tf(0, -len * 0.6); tips.push(stage === 3 ? crystalLite(len * 0.32, w * 1.6, T(q[0], q[1], ang), o.gem, P.out) : F(ell(0, -len * 0.76, w * 1.3, len * 0.15), o.tipCol, { tf, det: [DS([['M', -w * 0.5, -len * 0.84], ['L', -w * 0.5, -len * 0.68]], o.tipHi, 2.2, tf, 0.9)] })); }
        if (o.tip === 'comet') { tails.push(S([['M', tx, ty], ['Q', tx - 8, ty + 18, tx - 22, ty + 34]], o.tailCol, 5)); tips.push(stage === 3 ? gemStar(tx, ty, r * 1.35, o.gem, P.out) : F(star(5, r * 1.35, r * 0.62, -90), o.tipCol, { tf: T(tx, ty), det: [DF(ell(0, 0, r * 0.36, r * 0.36), o.tipHi, T(tx, ty))] })); }
      });
      if (o.extraGlow && stage > 1) o.extraGlow.forEach(([x, y, r]) => tips.push(stage === 3 ? gemSmall(x, y, r, o.gem, P.out) : F(ell(x, y, r, r), o.tipCol, { det: [DF(ell(x - r * 0.3, y - r * 0.3, r * 0.36, r * 0.3), o.tipHi)] })));
      const g = [blades]; if (tails.length) g.push(tails); g.push(tips);
      if (o.front) g.push(...o.front(stage));
      emit(o.id, o.season, o.rarity, stage, g, P.out);
    }
  }
  function podPts(x, y, w, h) { return [[x, y], [x + w * 0.62, y + h * 0.16], [x + w, y + h * 0.48], [x + w * 0.6, y + h * 0.84], [x, y + h], [x - w * 0.6, y + h * 0.84], [x - w, y + h * 0.48], [x - w * 0.62, y + h * 0.16]]; }
  function pod(x, y, w, h, col, rib, glow, stage, gem, P) { const pts = podPts(x, y, w, h); if (stage === 3) return facetPoly(pts, gem, P.out); return F(smoothPoly(pts), col, { det: [DF(ell(x, y + h * 0.58, w * 0.42, h * 0.26), glow, ID, 0.9), DS([['M', x, y + 2], ['Q', x - w * 0.62, y + h * 0.5, x, y + h - 2]], rib, 2.2), DS([['M', x, y + 2], ['Q', x + w * 0.62, y + h * 0.5, x, y + h - 2]], rib, 2.2)] }); }
  function floret(x, y, r, col, hi, stage, gem, P) { return stage === 3 ? gemSmall(x, y, r, gem, P.out) : F(ell(x, y, r, r * 0.88), col, { det: [DF(ell(x - r * 0.3, y - r * 0.3, r * 0.34, r * 0.26), hi, ID, 0.9)] }); }
  function raceme(x, y, len, r0, n, cols, stage, gem, P, sway = 8) { const out2 = []; for (let i = 0; i < n; i++) { const t = i / Math.max(1, n - 1), rr = r0 * (1 - t * 0.5), px = x + Math.sin(t * 2.6) * sway + (i % 2 ? -1 : 1) * rr * 0.5, py = y + t * len; out2.push(floret(px, py, rr, t < 0.5 ? cols[0] : cols[1], cols[2], stage, gem, P)); } return out2; }
  function ball(x, y, r, col, fl, stage, gem, P) { if (stage === 3) return gemCenter(x, y, r, gem, P.out); const det = [DF(ell(x - r * 0.3, y - r * 0.32, r * 0.3, r * 0.22), mix(col, '#FFFFFF', 0.5), ID, 0.8)]; for (let i = 0; i < 6; i++) { const a = (i * 60 + 20) * D2R, d = r * (i % 2 ? 0.5 : 0.62); det.push(DF(star(5, r * 0.18, r * 0.08, -90 + i * 12).map(c => c), fl, T(x + Math.cos(a) * d, y + Math.sin(a) * d))); } return F(ell(x, y, r, r), col, { det }); }
  const blade = (x, ang, len, w, col, P) => { const tf = T(x, 244, ang); return F(petal(len, w, 0.14), col, { tf, det: [DS([['M', 0, -5], ['L', 0, -len * 0.8]], mix(col, P.out, 0.3), 2, tf, 0.7)] }); };
  function trefoilPlant(o) {
    const P = o.P;
    const leaflets = (cx, cy, s, stage) => [0, 120, -120].map(a => { const tf = T(cx, cy, a); if (stage === 3) return crystalLite(s * 1.02, s * 0.6, tf, o.gem, P.out); return F(heart(s), o.col, { tf, det: [DS([['M', -s * 0.3, -s * 0.62], ['L', 0, -s * 0.4], ['L', s * 0.3, -s * 0.62]], o.mark, s * 0.07, tf, 0.9), DF(ell(-s * 0.26, -s * 0.78, 2.4, 2.4), o.speck, tf), DF(ell(s * 0.3, -s * 0.66, 2, 2), o.speck, tf)] }); });
    for (let stage = 1; stage <= 3; stage++) {
      const g = [];
      if (stage === 1) { g.push([S([['M', 128, 244], ['C', 127, 226, 130, 204, 128, 184]], P.stem, 7)]); g.push(leaflets(128, 172, 32, 1)); }
      else { g.push([S([['M', 128, 244], ['C', 124, 212, 134, 170, 127, 128]], P.stem, 8), S([['M', 128, 230], ['C', 140, 220, 158, 210, 168, 196]], P.stem, 6), leafPart(126, 222, -150, 30, 11, P, true)]); g.push(leaflets(170, 184, 24, stage)); g.push(leaflets(127, 112, 50, stage)); g.push([stage === 3 ? gemStar(127, 112, 11, GEM.goldGem, P.out) : F(star(5, 11, 5, -90), o.star, { tf: T(127, 112) })]); }
      emit(o.id, o.season, o.rarity, stage, g, P.out);
    }
  }

  const FP = { out: '#2B3550', stem: '#6FA39C', leaf: '#86B9AE', leafHi: '#C4E3DA' };
  const LP = { out: '#24192F', stem: '#6E9B76', leaf: '#7FAF84', leafHi: '#BFE0B8' };
  const AP = { out: '#3F2716', stem: '#7E9A4A', leaf: '#9DB55A', leafHi: '#D5E39A' };
  const CP = { out: '#2E3542', stem: '#6FA88E', leaf: '#82BFA0', leafHi: '#C2E8D2' };
  const SP = { out: '#1C1534', stem: '#6D9FA6', leaf: '#7DB3B3', leafHi: '#BDE3DE' };
  const EP = { out: '#2A140E', stem: '#7C9654', leaf: '#93AE62', leafHi: '#CFE3A0' };
  const two = (P, y = 222, l = 34, w = 12) => [[128, y, -150, l, w, true], [128, y, -30, l, w, false]];

  // ── Frost Orchard ──
  plant({ id: 'frost_snowdrop', season: 'frost_orchard', rarity: 1, P: FP, main: [160, 118, 1], bend: 34, stemW: 6, t1h: 0.72, head: { dir: 180, gem: GEM.quartz, rings: [{ span: 30, n: 3, l: 44, w: 17, shape: 'round', col: '#FAFCFF', vein: '#D2DDEC', hi: '#FFFFFF' }], center: { kind: 'disc', r: 8, col: '#9CCB8C', dy: -3, gem: GEM.peridot } }, leaves: [[122, 240, -104, 72, 9, true], [134, 240, -74, 62, 9, false]] });
  plant({ id: 'ice_crocus', season: 'frost_orchard', rarity: 1, P: FP, main: [128, 132, 1], stemW: 7, head: { gem: GEM.sapphire, rings: [{ span: 40, n: 2, l: 46, w: 16, shape: 'round', col: '#9FB0EC', vein: '#7686D2' }, { span: 18, n: 3, l: 50, w: 17, shape: 'round', col: '#BDCBF7', vein: '#8796D8', hi: '#E8EEFF' }] }, leaves: [[124, 240, -102, 64, 7, true], [132, 240, -78, 60, 7, false], [128, 240, -92, 48, 6, false]], front: (st, hx, hy) => st === 1 ? [] : [[F(ell(hx, hy - 40, 5, 9), st === 3 ? GEM.amber.body : '#FF9E3D', { det: [DF(ell(hx - 1.5, hy - 44, 1.6, 3), '#FFE0B0')] })]] });
  plant({ id: 'silver_aconite', season: 'frost_orchard', rarity: 1, P: FP, main: [128, 120, 1], head: { sq: 0.7, gem: GEM.goldGem, rings: [{ n: 6, l: 32, w: 15, shape: 'round', col: '#FFE98C', vein: '#D9C25C', rot: 30 }], center: { kind: 'dots', r: 10, sq: 0.7, col: '#F2B21C', col2: '#FFF2B0', gem: GEM.citrine } }, back: (st, hx, hy, hk) => [Array.from({ length: 8 }, (_, i) => F(petal(30 * hk, 8 * hk, 0.3), FP.leaf, { tf: TS(hx, hy + 6, i * 45 + 22, 0.6, 0, 1) }))], leaves: two(FP, 226, 30, 11) });
  plant({ id: 'winter_camellia', season: 'frost_orchard', rarity: 2, P: { ...FP, leaf: '#5E9C88', leafHi: '#A9D6C6' }, main: [126, 104, 1], head: { sq: 0.8, tilt: -6, rings: [{ n: 6, l: 38, w: 21, shape: 'round', col: '#E5486A', hi: '#FF8FA5', gem: GEM.ruby }, { n: 5, l: 25, w: 15, shape: 'round', col: '#F2627F', rot: 36, hi: '#FFA3B6', gem: GEM.garnet }], center: { kind: 'stamens', r: 6, n: 7, spread: 70, col: '#FFE38A', col2: '#FFE38A', tip: '#F2B21C', gem: GEM.goldGem } }, buds: [[170, 150, 34, 26, 11]], budCol: '#E5486A', leaves: [[129, 200, -26, 46, 18], [127, 222, -154, 40, 15, true], [150, 168, -40, 30, 12]] });
  plant({ id: 'hoarfrost_rose', season: 'frost_orchard', rarity: 2, P: FP, main: [130, 100, 1], head: { sq: 0.76, tilt: 6, rings: [{ n: 5, l: 42, w: 23, shape: 'round', col: '#E6D6F4', hi: '#FFFFFF', gem: GEM.opal }, { n: 5, l: 29, w: 17, shape: 'round', col: '#D8C2EE', rot: 36, gem: GEM.moonstone }, { n: 4, l: 17, w: 12, shape: 'round', col: '#C9AEE4', rot: 12, gem: GEM.iolite, t1: false }], center: { kind: 'swirl', r: 9, col: '#B994DA', col2: '#8E68B8', sq: 0.76, gem: GEM.amethyst } }, buds: [[88, 146, -30, 28, 11]], budCol: '#D8C2EE', leaves: [[129, 204, -28, 42, 16], [127, 222, -152, 38, 14, true]] });
  plant({ id: 'crystal_peony', season: 'frost_orchard', rarity: 3, P: FP, main: [128, 96, 1], stemW: 9, head: { sq: 0.72, rings: [{ n: 8, l: 46, w: 21, shape: 'round', col: '#F7C6D6', hi: '#FFE6EE', gem: GEM.roseq }, { n: 6, l: 33, w: 18, shape: 'round', col: '#F2ABC2', rot: 22, gem: GEM.tourmaline }, { n: 4, l: 20, w: 13, shape: 'round', col: '#E68DAA', rot: 10, gem: GEM.garnet, t1: false }], center: { kind: 'swirl', r: 10, col: '#D9739A', col2: '#A84A72', sq: 0.72, gem: GEM.ruby } }, buds: [[66, 150, -34, 30, 13], [192, 158, 36, 26, 11]], budCol: '#F2ABC2', leaves: [[129, 196, -24, 48, 18], [127, 214, -156, 46, 17, true], [128, 232, -40, 34, 12]], t1leaves: 3 });

  // ── Lantern Meadow ──
  spikePlant({ id: 'dusk_firefly_grass', season: 'lantern_meadow', rarity: 1, P: LP, tip: 'glow', tipCol: '#FFE27A', tipHi: '#FFF8D6', tipR: 10, gem: GEM.peridot, blades: [[128, 4, 150, 7], [118, -14, 128, 6.5], [138, 18, 134, 6.5], [110, -30, 100, 6], [146, 32, 104, 6], [124, -4, 116, 6]], tipOn: [0, 1, 2, 4], extraGlow: [[92, 112, 6], [172, 98, 7]] });
  (() => { const P = LP; for (let st = 1; st <= 3; st++) { const g = []; const sp = [S([['M', 128, 244], ['C', 124, 200, 136, 140, 168, 104], ['C', 180, 92, 194, 96, 198, 108]], P.stem, 7)]; if (st > 1) sp.push(S([['M', 140, 150], ['Q', 114, 132, 100, 136]], P.stem, 5), leafPart(130, 214, -150, 40, 15, P, true), leafPart(148, 128, -30, 34, 12, P)); else sp.push(leafPart(128, 222, -150, 30, 11, P, true)); g.push(sp); if (st === 1) g.push([pod(198, 110, 15, 30, '#B8D98A', '#86A85A', '#E2F2C0', 1, null, P)]); else { g.push([S([['M', 198, 108], ['L', 198, 116]], '#86A85A', 4), S([['M', 100, 136], ['L', 100, 142]], '#86A85A', 4)]); g.push([pod(100, 142, 22, 44, '#FF9A4A', '#D2661E', '#FFE0A8', st, GEM.amber, P), pod(198, 114, 28, 56, '#FF8A3D', '#CC5A16', '#FFE0A8', st, GEM.opalFire, P)]); g.push([st === 3 ? gemSmall(198, 112, 7, GEM.goldGem, P.out) : F(star(5, 9, 4, -90), '#86A85A', { tf: T(198, 114) })]); } emit('paper_lantern_bloom', 'lantern_meadow', 1, st, g, P.out); } })();
  plant({ id: 'evening_primrose', season: 'lantern_meadow', rarity: 1, P: LP, main: [128, 108, 1], head: { sq: 0.86, gem: GEM.topaz, rings: [{ n: 4, l: 42, w: 25, shape: 'notch', col: '#FFE45C', vein: '#F2C230', hi: '#FFF6B8', rot: 45 }], center: { kind: 'stamens', r: 6, n: 5, spread: 60, col: '#F2C230', col2: '#FFF3A8', tip: '#E8A814', gem: GEM.goldGem } }, leaves: [[128, 220, -150, 40, 12, true], [128, 200, -28, 38, 11]] });
  plant({ id: 'foxfire_lily', season: 'lantern_meadow', rarity: 2, P: LP, main: [124, 100, 1], head: { sq: 0.72, tilt: -10, rings: [{ n: 6, l: 54, w: 14, shape: 'petal', col: '#FF8A3D', vein: '#FFD08A', hi: '#FFC28A', gem: GEM.fire }], center: { kind: 'stamens', r: 6, n: 5, spread: 50, len: 3, col: '#9CE0C8', col2: '#B8F0DC', tip: '#5FD1C2', gem: GEM.teal } }, buds: [[172, 146, 30, 34, 9]], budCol: '#FF8A3D', leaves: [[128, 226, -150, 52, 9, true], [128, 206, -30, 50, 9], [128, 184, -152, 44, 8, true]], t1leaves: 2 });
  (() => { const P = LP, cols = ['#D7BCFF', '#B48CF5', '#F2E8FF']; for (let st = 1; st <= 3; st++) { const g = []; const sp = [S([['M', 128, 244], ['C', 120, 200, 112, 150, 128, 104], ['C', 140, 74, 176, 66, 196, 80]], '#8A6E58', 8)]; if (st > 1) sp.push(S([['M', 124, 130], ['Q', 96, 112, 74, 116]], '#8A6E58', 6)); sp.push(leafPart(122, 200, -150, 36, 12, P, true), leafPart(150, 84, -10, 32, 11, P)); if (st > 1) sp.push(leafPart(96, 116, -160, 30, 10, P, true)); g.push(sp); if (st === 1) g.push(raceme(176, 84, 40, 9, 4, ['#BFE0B8', '#C9B2F0', '#F2E8FF'], 1, null, P, 4)); else g.push([...raceme(74, 120, 56, 13, 4, cols, st, GEM.amethyst, P, 6), ...raceme(190, 84, 84, 15, 6, cols, st, GEM.violet, P), ...raceme(140, 96, 56, 13, 4, cols, st, GEM.opal, P, 6)]); emit('glow_wisteria', 'lantern_meadow', 2, st, g, P.out); } })();
  plant({ id: 'midnight_lotus', season: 'lantern_meadow', rarity: 3, P: LP, main: [128, 212, 1], noStem: true, t1h: 1, t1k: 0.85, head: { rings: [{ span: 72, n: 5, l: 54, w: 20, shape: 'petal', col: '#9C8CF5', vein: '#C9C0FF', gem: GEM.tanzanite }, { span: 42, n: 4, l: 50, w: 19, shape: 'petal', col: '#B3A6FF', vein: '#DCD6FF', gem: GEM.amethyst }, { span: 14, n: 2, l: 42, w: 16, shape: 'petal', col: '#D2CBFF', hi: '#F2F0FF', gem: GEM.opal, t1: false }], calyx: false }, back: (st) => [[padPart(128, 228, 92, 16, '#4F8F80', LP), ...(st > 1 ? [padPart(204, 236, 40, 8, '#4F8F80', LP)] : [])]], buds: [[204, 196, 14, 30, 10]], budCol: '#B3A6FF', front: (st, hx, hy) => st === 1 ? [] : [[st === 3 ? gemSmall(hx, hy - 22, 8, GEM.goldGem, LP.out) : F(ell(hx, hy - 22, 9, 6), '#FFE27A', { det: [DF(ell(hx - 3, hy - 24, 3, 2), '#FFF8D6')] })]] });

  // ── Amber Canopy ──
  (() => { const P = AP, twig = '#7A4E2C', cols = ['#E07B39', '#C9602A', '#F0A04B', '#D86B30', '#EE9440']; for (let st = 1; st <= 3; st++) { const g = []; const L = st === 1 ? [[132, 170, -60, 40, 16], [124, 196, -130, 34, 14, true]] : [[136, 120, -70, 52, 20], [126, 150, -126, 48, 19, true], [134, 176, -40, 46, 18], [126, 202, -142, 40, 16, true], [130, 104, -100, 40, 16]]; g.push([S([['M', 128, 244], ['C', 126, 210, 134, 150, 132, st === 1 ? 166 : 104]], twig, st === 1 ? 6 : 7)]); g.push(L.map(([x, y, a, l, w, f], i) => colLeaf(x, y, a, l, w, cols[i], P, st, i % 2 ? GEM.copper : GEM.amber, f))); emit('copper_leaf', 'amber_canopy', 1, st, g, P.out); } })();
  plant({ id: 'maple_aster', season: 'amber_canopy', rarity: 1, P: AP, main: [128, 104, 1], head: { gem: GEM.garnet, rings: [{ n: 16, l: 36, w: 6, shape: 'pin', col: '#E0604A', vein: '#FF9C86' }], center: { kind: 'dots', r: 12, col: '#FFC53D', col2: '#E8901C', gem: GEM.citrine } }, leaves: two(AP, 214, 36, 12) });
  plant({ id: 'russet_mallow', season: 'amber_canopy', rarity: 1, P: AP, main: [128, 108, 1], head: { sq: 0.9, gem: GEM.coralG, rings: [{ n: 5, l: 42, w: 23, shape: 'notch', col: '#EE9A86', vein: '#C25A4E', blot: '#C24E42' }], center: { kind: 'stamens', r: 5, n: 5, spread: 30, len: 2.6, col: '#FFE9D6', col2: '#FFF2E6', tip: '#FFD2B0', gem: GEM.roseq } }, leaves: [[128, 220, -150, 36, 15, true], [128, 198, -30, 34, 14]] });
  plant({ id: 'cider_dahlia', season: 'amber_canopy', rarity: 2, P: AP, main: [128, 100, 1], head: { sq: 0.82, rings: [{ n: 8, l: 44, w: 13, shape: 'petal', col: '#F28A2E', vein: '#FFC27A', gem: GEM.opalFire }, { n: 6, l: 31, w: 12, shape: 'petal', col: '#F7A043', rot: 22, gem: GEM.amber }, { n: 4, l: 19, w: 9, shape: 'petal', col: '#FFBE63', rot: 10, gem: GEM.goldGem, t1: false }], center: { kind: 'disc', r: 7, col: '#B85A12', gem: GEM.smoky } }, buds: [[176, 154, 32, 28, 11]], budCol: '#F28A2E', leaves: [[129, 200, -26, 44, 16], [127, 220, -154, 40, 15, true]] });
  (() => { const P = AP, gold = '#FFC93D', fl = '#E89A1C', oak = '#C98A3A', twig = '#7A4E2C'; for (let st = 1; st <= 3; st++) { const g = []; const sp = [S([['M', 128, 244], ['C', 124, 200, 132, 150, 128, 112]], twig, 8)]; if (st > 1) sp.push(S([['M', 128, 150], ['Q', 150, 130, 170, 112]], twig, 6), S([['M', 127, 176], ['Q', 104, 160, 88, 140]], twig, 5)); g.push(sp); g.push(st === 1 ? [lobedLeaf(128, 220, -40, 44, 14, oak, P)] : [lobedLeaf(128, 216, -44, 58, 18, oak, P), lobedLeaf(128, 200, 40, 52, 16, '#B87A30', P), lobedLeaf(126, 140, -70, 44, 14, '#D69A48', P)]); if (st === 1) g.push([ball(128, 104, 15, gold, fl, 1, null, P)]); else { g.push([ball(170, 104, 15, gold, fl, st, GEM.goldGem, P), ball(88, 132, 14, gold, fl, st, GEM.citrine, P), ball(110, 98, 13, '#FFD966', fl, st, GEM.topaz, P), ball(128, 94, 19, gold, fl, st, GEM.goldGem, P)]); g.push(st === 3 ? [crystalLite(22, 13, T(150, 196, 180), GEM.smoky, P.out)] : [F(ell(150, 206, 10, 12), '#B07A44', { det: [DF(ell(146, 202, 3, 4), '#D9A46A')] }), F([['M', 138, 196], ['C', 140, 186, 160, 186, 162, 196], ['Z']], '#6E4A28')]); } emit('golden_oak_bloom', 'amber_canopy', 2, st, g, P.out); } })();
  plant({ id: 'amber_magnolia', season: 'amber_canopy', rarity: 3, P: AP, main: [134, 112, 1], stemCol: '#6E4A2C', stemW: 10, head: { rings: [{ span: 58, n: 4, l: 60, w: 23, shape: 'round', col: '#FFE2B8', hi: '#FFF4E0', gem: GEM.pearl }, { span: 26, n: 3, l: 58, w: 22, shape: 'round', col: '#FFD49A', blot: '#F2A65A', gem: GEM.amber }, { span: 0, n: 1, l: 52, w: 20, shape: 'round', col: '#FFEBD0', hi: '#FFFFFF', gem: GEM.goldGem, t1: false }], calyx: false }, head2: { rings: [{ span: 44, n: 3, l: 40, w: 17, shape: 'round', col: '#FFE2B8', gem: GEM.pearl }, { span: 0, n: 1, l: 38, w: 16, shape: 'round', col: '#FFD49A', gem: GEM.amber }], calyx: false }, extra: [[62, 140, 0.8, -12]], buds: [[198, 128, 28, 30, 12]], budCol: '#B98A5A', budGem: GEM.smoky, leaves: [[132, 196, -24, 54, 20], [126, 218, -158, 48, 18, true]] });

  // ── Coral Tide Garden ──
  (() => { const P = CP, pink = '#FF9EB6', fl = '#FFD6E0'; for (let st = 1; st <= 3; st++) { const g = []; const tuft = [blade(118, -26, 54, 8, P.leaf, P), blade(128, -6, 62, 8, P.leaf, P), blade(138, 20, 56, 8, P.leaf, P)]; if (st > 1) tuft.push(blade(110, -44, 44, 7, P.leaf, P), blade(146, 38, 46, 7, P.leaf, P)); const stalks = st === 1 ? [S([['M', 128, 236], ['C', 127, 200, 130, 170, 130, 150]], '#8FBF9F', 4)] : [S([['M', 126, 236], ['C', 120, 190, 104, 150, 96, 116]], '#8FBF9F', 4), S([['M', 130, 236], ['C', 134, 180, 148, 130, 160, 92]], '#8FBF9F', 4)]; g.push([...stalks, ...tuft]); g.push(st === 1 ? [ball(130, 144, 14, '#F7C1CF', fl, 1, null, P)] : [ball(96, 112, 20, pink, fl, st, GEM.roseq, P), ball(160, 88, 23, pink, fl, st, GEM.tourmaline, P)]); emit('sea_thrift', 'coral_tide', 1, st, g, P.out); } })();
  plant({ id: 'salt_daisy', season: 'coral_tide', rarity: 1, P: CP, main: [128, 102, 1], head: { gem: GEM.diamond, rings: [{ n: 14, l: 42, w: 9, shape: 'round', col: '#FFFFFF', vein: '#D8E6EA' }], center: { kind: 'dots', r: 14, col: '#7FD6CC', col2: '#3FA79C', gem: GEM.teal } }, leaves: two(CP, 214, 36, 11) });
  plant({ id: 'tide_anemone', season: 'coral_tide', rarity: 1, P: CP, main: [128, 108, 1], head: { sq: 0.9, gem: GEM.coralG, rings: [{ n: 6, l: 36, w: 20, shape: 'round', col: '#FF7A6B', vein: '#FFB3A8', hi: '#FFC4BA' }], center: { kind: 'dots', r: 13, col: '#3D3354', col2: '#9C8AC2', hi: '#9C8AC2', gem: GEM.tanzanite } }, leaves: [[128, 222, -150, 34, 13, true], [128, 222, -30, 34, 13]] });
  plant({ id: 'coral_hibiscus', season: 'coral_tide', rarity: 2, P: CP, main: [126, 106, 1], head: { sq: 0.84, tilt: -8, gem: GEM.coralG, rings: [{ n: 5, l: 52, w: 31, shape: 'round', col: '#FF7A5E', blot: '#C2304A', vein: '#FFB0A0', hi: '#FFC9BC' }], center: { kind: 'stamens', r: 5, n: 5, spread: 22, len: 4.2, col: '#FFE38A', col2: '#FFE38A', tip: '#F2B21C', gem: GEM.goldGem } }, buds: [[176, 160, 36, 30, 11]], budCol: '#FF7A5E', leaves: [[129, 206, -26, 46, 18], [127, 224, -154, 40, 16, true]] });
  plant({ id: 'pearl_waterlily', season: 'coral_tide', rarity: 2, P: CP, main: [126, 204, 1.25], noStem: true, t1h: 1, t1k: 0.9, head: { sq: 0.64, rings: [{ n: 8, l: 46, w: 14, shape: 'petal', col: '#FFF6EE', vein: '#E6D8CA', gem: GEM.pearl }, { n: 6, l: 32, w: 12, shape: 'petal', col: '#FFE2D4', rot: 30, gem: GEM.roseq }], center: { kind: 'disc', r: 10, sq: 0.64, col: '#FFD45E', gem: GEM.goldGem }, calyx: false }, back: (st) => [[padPart(124, 228, 84, 15, '#5FAE8C', CP), ...(st > 1 ? [padPart(206, 236, 42, 8, '#5FAE8C', CP)] : [])]], buds: [[204, 196, 12, 30, 10]], budCol: '#FFE2D4' });
  plant({ id: 'reef_crown', season: 'coral_tide', rarity: 3, P: CP, main: [128, 104, 1], stemCol: '#E8836E', stemW: 11, head: { sq: 0.76, rings: [{ n: 9, l: 42, w: 10, shape: 'petal', col: '#FF8FA3', vein: '#FFD0DA', gem: GEM.tourmaline }, { n: 7, l: 28, w: 9, shape: 'petal', col: '#FFB46B', rot: 18, gem: GEM.amber }], center: { kind: 'dots', r: 11, sq: 0.76, col: '#FFE08A', col2: '#F2A63D', gem: GEM.goldGem } }, back: (st) => st === 1 ? [] : [[S([['M', 126, 220], ['C', 104, 196, 82, 186, 70, 150], ['M', 92, 182], ['Q', 72, 186, 58, 176]], '#F59A8B', 10), S([['M', 132, 214], ['C', 156, 196, 176, 176, 186, 140], ['M', 168, 180], ['Q', 190, 182, 202, 168]], '#F59A8B', 10)]], front: (st) => st === 1 ? [] : [[st === 3 ? crystalLite(26, 14, T(70, 150, -20), GEM.coralG, CP.out) : F(ell(70, 146, 9, 9), '#FFC5B8'), st === 3 ? crystalLite(26, 14, T(186, 140, 20), GEM.coralG, CP.out) : F(ell(186, 136, 9, 9), '#FFC5B8')]], leaves: [[128, 230, -150, 34, 12, true], [128, 230, -30, 34, 12]] });

  // ── Starfall Glade ──
  spikePlant({ id: 'comet_sprig', season: 'starfall_glade', rarity: 1, P: SP, tip: 'comet', tipCol: '#FFF2BF', tipHi: '#FFFFFF', tailCol: '#AFC0FF', tipR: 10, gem: GEM.diamond, bladeCol: '#7DB3B3', blades: [[128, 8, 160, 5], [120, -20, 126, 4.5], [136, 26, 120, 4.5], [112, -38, 90, 4], [144, 44, 88, 4]], tipOn: [0, 1, 2] });
  trefoilPlant({ id: 'nebula_clover', season: 'starfall_glade', rarity: 1, P: SP, col: '#A68CF5', mark: '#E3D8FF', speck: '#FFFFFF', star: '#FFE27A', gem: GEM.amethyst });
  plant({ id: 'meteor_daisy', season: 'starfall_glade', rarity: 1, P: SP, main: [128, 104, 1], head: { tilt: -16, sq: 0.9, gem: GEM.moonstone, rings: [{ n: 10, l: 44, w: 9, shape: 'pin', col: '#E9E0FF', vein: '#B8A8F0' }], center: { kind: 'star', r: 13, col: '#FFE27A', col2: '#FFF6C7', gem: GEM.goldGem } }, leaves: two(SP, 216, 36, 11) });
  plant({ id: 'aurora_tulip', season: 'starfall_glade', rarity: 2, P: SP, main: [128, 128, 1], head: { rings: [{ span: 36, n: 2, l: 54, w: 22, shape: 'round', col: '#5FD1C2', vein: '#A68CF5', gem: GEM.teal }, { span: 0, n: 1, l: 58, w: 24, shape: 'round', col: '#8DE6C9', blot: '#C9A8FF', hi: '#D6FFF2', vein: '#A68CF5', gem: GEM.aquamarine }] }, buds: [[170, 160, 28, 34, 11]], budCol: '#8DE6C9', budGem: GEM.amethyst, leaves: [[124, 240, -112, 70, 13, true], [134, 240, -64, 64, 12, false]] });
  plant({ id: 'galaxy_sunburst', season: 'starfall_glade', rarity: 2, P: SP, main: [128, 98, 1], stemW: 10, head: { rings: [{ n: 10, l: 50, w: 11, shape: 'petal', col: '#7684EA', rot: 18, keep: true }, { n: 10, l: 46, w: 11, shape: 'petal', col: '#FFC93D', vein: '#FFE79A', gem: GEM.goldGem }], center: { kind: 'dots', r: 22, col: '#2E2878', col2: '#E9E0FF', hi: '#8E84F0', gem: GEM.tanzanite } }, leaves: [[128, 200, -146, 52, 22, true], [128, 186, -34, 52, 22], [127, 226, -160, 34, 14, true]], t1leaves: 2 });
  plant({ id: 'nova_bloom', season: 'starfall_glade', rarity: 3, P: SP, main: [128, 100, 1], head: { sq: 0.86, rings: [{ n: 8, l: 50, w: 14, shape: 'petal', col: '#FFE27A', vein: '#FFF6C7', gem: GEM.goldGem }, { n: 6, l: 34, w: 12, shape: 'petal', col: '#FFB4E0', rot: 30, gem: GEM.tourmaline }, { n: 4, l: 20, w: 9, shape: 'petal', col: '#FFFFFF', rot: 45, gem: GEM.diamond, t1: false }], center: { kind: 'star', r: 9, col: '#FFF2C7', col2: '#FFE27A', gem: GEM.diamond } }, buds: [[66, 156, -38, 30, 10], [192, 150, 38, 30, 10]], budCol: '#FFB4E0', leaves: [[129, 200, -26, 46, 16], [127, 220, -154, 42, 15, true], [128, 236, -36, 30, 11]], t1leaves: 2 });

  // ── Ember Fen ──
  spikePlant({ id: 'marsh_rush', season: 'ember_fen', rarity: 1, P: EP, tip: 'seed', tipCol: '#C98A55', tipHi: '#F2C08A', gem: GEM.copper, blades: [[128, 3, 168, 7], [118, -12, 136, 6.5], [138, 14, 144, 6.5], [110, -26, 96, 6], [146, 30, 100, 6]], tipOn: [0, 2] });
  plant({ id: 'peat_violet', season: 'ember_fen', rarity: 1, P: EP, main: [128, 120, 1], head: { sq: 0.9, gem: GEM.violet, rings: [{ n: 5, l: 32, w: 18, shape: 'round', col: '#B98CF0', vein: '#7E5CC9', hi: '#E3D2FF', rot: 180 }], center: { kind: 'disc', r: 6, col: '#FFD45E', gem: GEM.goldGem } }, leaves: [[128, 226, -150, 36, 17, true], [128, 226, -30, 36, 17]] });
  plant({ id: 'cinder_buttercup', season: 'ember_fen', rarity: 1, P: EP, main: [128, 110, 1], head: { gem: GEM.amber, rings: [{ n: 5, l: 36, w: 21, shape: 'round', col: '#FF9A4A', hi: '#FFCB96' }], center: { kind: 'dots', r: 12, col: '#4A2A20', col2: '#FFB074', hi: '#FFB074', gem: GEM.opalFire } }, leaves: two(EP, 220, 34, 13) });
  plant({ id: 'flame_iris', season: 'ember_fen', rarity: 2, P: EP, main: [128, 108, 1], head: { sq: 0.8, rings: [{ n: 3, rot: 0, l: 40, w: 16, shape: 'round', col: '#FFA552', vein: '#FFD9A8', gem: GEM.amber }, { n: 3, rot: 60, l: 52, w: 21, shape: 'round', col: '#FF6E3D', blot: '#FFD08A', vein: '#FFE4C2', gem: GEM.fire }] }, buds: [[172, 150, 26, 34, 10]], budCol: '#FF6E3D', leaves: [[124, 240, -106, 84, 12, true], [134, 240, -72, 76, 12, false]] });
  plant({ id: 'smoke_lotus', season: 'ember_fen', rarity: 2, P: EP, main: [128, 214, 1], noStem: true, t1h: 1, t1k: 0.85, head: { rings: [{ span: 64, n: 4, l: 48, w: 19, shape: 'petal', col: '#B7AFC4', vein: '#E6E1EE', gem: GEM.smokeQ }, { span: 28, n: 3, l: 44, w: 18, shape: 'petal', col: '#D2CBDD', hi: '#F2EFF7', gem: GEM.pearl }], calyx: false }, back: () => [[padPart(128, 230, 88, 15, '#6E8A5A', EP)]], front: (st, hx, hy) => st === 1 ? [] : [[st === 3 ? gemSmall(hx, hy - 20, 8, GEM.fire, EP.out) : F(ell(hx, hy - 20, 9, 6), '#FF9A4A', { det: [DF(ell(hx - 3, hy - 22, 3, 2), '#FFD3A8')] })]], buds: [[202, 200, 14, 28, 9]], budCol: '#D2CBDD' });
  plant({ id: 'fenfire_crown', season: 'ember_fen', rarity: 3, P: EP, main: [128, 98, 1], stemW: 9, head: { sq: 0.8, rings: [{ n: 6, l: 52, w: 16, shape: 'petal', col: '#FF6A3D', vein: '#FFC28A', gem: GEM.fire }, { n: 6, l: 35, w: 12, shape: 'petal', col: '#FFA040', rot: 25, gem: GEM.amber }, { n: 3, l: 20, w: 10, shape: 'petal', col: '#FFE08A', rot: 0, gem: GEM.goldGem, t1: false }], center: { kind: 'star', r: 8, col: '#FFF2C7', col2: '#FFD45E', gem: GEM.goldGem } }, back: (st) => st === 1 ? [] : [[blade(96, -30, 120, 6, '#8A5536', EP), blade(162, 32, 116, 6, '#8A5536', EP)], [F(ell(0, -116 * 0.76, 8, 18), '#C98A55', { tf: T(96, 244, -30) }), F(ell(0, -112 * 0.76, 8, 18), '#C98A55', { tf: T(162, 244, 32) })]], buds: [[60, 162, -36, 30, 10], [198, 166, 36, 28, 10]], budCol: '#FF8A3D', leaves: [[129, 202, -26, 46, 14], [127, 222, -154, 42, 13, true]] });

  return { files: out, meta };
}

if (typeof module !== 'undefined' && typeof require !== 'undefined' && require.main === module) {
  const fs = require('fs'), path = require('path');
  const dir = path.join(__dirname, '..', 'assets', 'flowers');
  fs.mkdirSync(dir, { recursive: true });
  const r = generateFlowers();
  for (const [k, v] of Object.entries(r.files)) fs.writeFileSync(path.join(dir, k), v);
  fs.writeFileSync(path.join(dir, 'flowers_meta.json'), JSON.stringify(r.meta, null, 1));
  console.log(Object.keys(r.files).length + ' flowers ->', dir);
}
