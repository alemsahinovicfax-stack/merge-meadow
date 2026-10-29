// Hero Pip v3 — store-only marketing illustration.
// Identity from game/assets/pip/parts (mint body, pink ears, cream belly, ink #2D3436, rosy cheeks, tuft);
// head outline redrawn (no collar spikes), painted soft shading, flower hugged at chest, bloom by the cheek.
async function buildHeroPipV3(readFile, o = {}) {
  const strip = s => s.replace(/<metadata>[\s\S]*?<\/metadata>/g, '');
  const inner = s => strip(s).replace(/^[\s\S]*?<svg[^>]*>/, '').replace(/<\/svg>\s*$/, '');
  const part = async n => inner(await readFile('game/assets/pip/parts/' + n + '.svg'));
  const fx = async n => inner(await readFile('sprites/fx/' + n + '.svg'));
  const flowerFile = o.flower || 'sprites/crystal_peony_t3.svg';
  const stemInk = o.stemInk || '#2B3550', stemFill = o.stemFill || '#6FA39C', leafFill = o.leafFill || '#86B9AE', leafHi = o.leafHi || '#C4E3DA';
  const glow = o.glow || '#FFE79A';
  const disc = !!o.disc;
  const H = o.height || 2160;
  const vb = o.viewBox || [-84, -262, 268, 274];
  const W = Math.round(H * vb[2] / vb[3]);
  const INK = '#2D3436', MINT = '#A8E6CF', SHADE = '#7CCBAE', DEEP = '#5DB394', CREAM = '#D4F5E4';
  const S = 'stroke="' + INK + '" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"';
  const blur = (id, d) => '<filter id="' + id + '" x="-60%" y="-60%" width="220%" height="220%"><feGaussianBlur stdDeviation="' + d + '"/></filter>';

  // ---- geometry (body space: origin at feet line, y up negative) ----
  const BODY = 'M0 -84 C 30 -84 54 -56 54 -30 C 54 -8 32 6 0 6 C -32 6 -54 -8 -54 -30 C -54 -56 -30 -84 0 -84 Z';
  const BELLY = 'M -12 -46 Q -6 -54 1 -48 Q 7 -56 12 -50 Q 18 -55 24 -47 Q 30 -50 33 -42 C 37 -26 30 -6 10 -2 C -14 -4 -18 -30 -12 -46 Z';
  // head (head space), redrawn: smooth jaw with soft cheek-fluff scallops instead of spikes
  const HEAD = 'M -4 -92 C 36 -93 64 -70 66 -40 C 67 -26 62 -14 54 -6 Q 58 0 52 4 Q 48 10 40 8 C 30 12 18 13 4 13 C -12 13 -24 11 -34 7 Q -42 11 -47 5 Q -55 4 -53 -3 C -59 -12 -62 -24 -62 -38 C -62 -68 -40 -91 -4 -92 Z';
  const MUZZLE = 'M 16 -27 C 10 -33 -6 -33 -8 -19 C -9 -7 4 -3 16 -9 C 26 -3 38 -7 37 -19 C 36 -32 22 -33 16 -27 Z';

  const [earL, earR, earTip, tuft, tail, foot, paw, eye, brow, mouth, nose, sparkle, star] = await Promise.all(
    ['ear_l', 'ear_rb', 'ear_tip', 'tuft', 'tail', 'foot_f', 'paw_f', 'eye__' + (o.eye || 'spark'), 'brow__up', 'mouth__' + (o.mouth || 'grin'), 'nose'].map(part).concat([fx('sparkle'), fx('star')]));

  // bloom only (side bud + sprite stem/leaves are clipped away)
  const fsrc = inner(await readFile(flowerFile));
  const bc = o.bloomClip || [128, 82, 66];
  const bloomR = o.bloomScale || 0.66;
  const bloomAt = o.bloomAt || [86, -98];
  const bloomRot = o.bloomRot ?? 52;

  // stem from below paws up to the bloom
  const stem = o.stem || 'M 2 -22 C 22 -44 52 -72 86 -98';
  const leaf = 'M 0 0 C 5 -11 19 -15 30 -9 C 22 2 9 5 0 0 Z';

  const head = (
    '<g transform="translate(4,-72) rotate(' + (o.headRot ?? -4) + ')">' +
    // ears behind head
    '<g transform="translate(-30,-76) rotate(-18)">' + earL + '</g>' +
    '<g transform="translate(16,-80) rotate(10)">' + earR + '<g transform="translate(0,-50) rotate(120)">' + earTip + '</g></g>' +
    '<path d="' + HEAD + '" fill="' + MINT + '"/>' +
    '<g clip-path="url(#cHead)">' +
      '<ellipse cx="62" cy="-38" rx="22" ry="56" fill="' + SHADE + '" filter="url(#b5)"/>' +
      '<ellipse cx="8" cy="16" rx="70" ry="13" fill="' + SHADE + '" opacity="0.85" filter="url(#b5)"/>' +
      '<ellipse cx="-30" cy="-72" rx="30" ry="16" fill="#E4FBF1" opacity="0.55" filter="url(#b8)"/>' +
    '</g>' +
    '<path d="' + MUZZLE + '" fill="' + CREAM + '"/>' +
    '<ellipse cx="-30" cy="-20" rx="10" ry="6.5" fill="#FFB88C"/><ellipse cx="49" cy="-19" rx="7" ry="6" fill="#FFB88C"/>' +
    '<path d="' + HEAD + '" fill="none" ' + S + '/>' +
    // inner cheek-fluff ticks
    '<path d="M -42 4 Q -40 0 -44 -3 M 46 2 Q 44 -2 48 -5" fill="none" stroke="' + INK + '" stroke-width="2" stroke-linecap="round" opacity="0.55"/>' +
    '<g transform="translate(-4,-88) rotate(-4)">' + tuft + '</g>' +
    '<g transform="translate(-12,-47)">' + eye + '</g><g transform="translate(35,-46) scale(0.78,0.97)">' + eye + '</g>' +
    '<g transform="translate(-12,-68)">' + brow + '</g><g transform="translate(35,-67) scale(-0.78,1)">' + brow + '</g>' +
    '<g transform="translate(16,-29)">' + nose + '</g><g transform="translate(16,-17)">' + mouth + '</g>' +
    '</g>');

  const glowC = '<circle cx="' + bloomAt[0] + '" cy="' + bloomAt[1] + '" r="' + (bc[2] * bloomR * 1.9) + '" fill="url(#gGlow)"/>';
  const body = (
    '<path d="' + BODY + '" fill="' + MINT + '"/>' +
    '<g clip-path="url(#cBody)">' +
      '<ellipse cx="52" cy="-30" rx="18" ry="50" fill="' + SHADE + '" filter="url(#b5)"/>' +
      '<ellipse cx="6" cy="-84" rx="60" ry="16" fill="' + DEEP + '" opacity="0.55" filter="url(#b6)"/>' +
      '<ellipse cx="0" cy="8" rx="60" ry="10" fill="' + SHADE + '" opacity="0.8" filter="url(#b5)"/>' +
      '<path d="' + BELLY + '" fill="' + CREAM + '"/>' +
      '<ellipse cx="-30" cy="-50" rx="14" ry="20" fill="#E4FBF1" opacity="0.5" filter="url(#b6)"/>' +
    '</g>' +
    '<path d="' + BODY + '" fill="none" ' + S + '/>');

  const flower = (
    // stem + one tucked leaf
    '<path d="' + stem + '" fill="none" stroke="' + stemInk + '" stroke-width="8" stroke-linecap="round"/>' +
    '<path d="' + stem + '" fill="none" stroke="' + stemFill + '" stroke-width="3.6" stroke-linecap="round"/>' +
    // glow + bloom
    
    '<g transform="translate(' + bloomAt[0] + ',' + bloomAt[1] + ') rotate(' + bloomRot + ') scale(' + bloomR + ') translate(' + (-bc[0]) + ',' + (-bc[1]) + ')"><g clip-path="url(#cBloom)">' + fsrc + '</g>' +
      '<circle cx="' + bc[0] + '" cy="' + bc[1] + '" r="' + (bc[2] * 0.7) + '" fill="url(#gCore)"/></g>');

  const paws = (
    '<g transform="translate(26,-60) rotate(-36) scale(1.14)">' + paw + '</g>' +
    '<g transform="translate(42,-75) rotate(-44) scale(-1.08,1.08)">' + paw + '</g>');

  const sparkles = (o.sparkles || [[128, -150, 0.8, 0, 's'], [142, -82, 0.5, 20, 's'], [106, -166, 0.42, 0, 't']])
    .map(([x, y, s, r, k]) => '<g transform="translate(' + x + ',' + y + ') rotate(' + r + ') scale(' + s + ')">' + (k === 't' ? star : sparkle) + '</g>').join('');

  const lean = o.lean ?? 5, lift = o.lift ?? 10;
  return '<svg xmlns="http://www.w3.org/2000/svg" width="' + W + '" height="' + H + '" viewBox="' + vb.join(' ') + '">' +
    '<defs>' + blur('b5', 5) + blur('b6', 6) + blur('b8', 8) +
    '<clipPath id="cHead"><path d="' + HEAD + '"/></clipPath><clipPath id="cBody"><path d="' + BODY + '"/></clipPath>' +
    '<clipPath id="cBloom"><circle cx="' + bc[0] + '" cy="' + bc[1] + '" r="' + bc[2] + '"/></clipPath>' +
    '<radialGradient id="gGlow"><stop offset="0" stop-color="' + glow + '" stop-opacity="0.85"/><stop offset="0.5" stop-color="' + glow + '" stop-opacity="0.32"/><stop offset="1" stop-color="' + glow + '" stop-opacity="0"/></radialGradient>' +
    '<radialGradient id="gCore"><stop offset="0" stop-color="#FFFFFF" stop-opacity="0.4"/><stop offset="1" stop-color="#FFFFFF" stop-opacity="0"/></radialGradient>' +
    '<radialGradient id="gDisc"><stop offset="0" stop-color="#FFF4C8" stop-opacity="0.95"/><stop offset="0.45" stop-color="#FFE48A" stop-opacity="0.5"/><stop offset="1" stop-color="#FFE48A" stop-opacity="0"/></radialGradient>' +
    '</defs>' +
    (disc ? '<circle cx="78" cy="-150" r="132" fill="url(#gDisc)"/>' : '') +
    '<ellipse cx="6" cy="2" rx="40" ry="7" fill="#1A1A14" fill-opacity="0.16"/>' +
    '<g transform="translate(0,' + (-lift) + ') rotate(' + lean + ')">' +
      // tail + lifted back foot behind
      '<g transform="translate(-50,-26)">' + tail + '</g>' +
      '<g transform="translate(26,-9) scale(-0.85,0.95)">' + foot + '</g>' +
      '<g transform="translate(0,-8)">' + glowC + body + head + flower + paws + '</g>' +
      '<g transform="translate(-30,-14) rotate(26)">' + foot + '</g>' +
      sparkles +
    '</g></svg>';
}
if (typeof module !== 'undefined') module.exports = { buildHeroPipV3 };
