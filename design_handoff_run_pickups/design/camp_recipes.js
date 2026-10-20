// B · Season Kit recept "camp" za 4 plaćene sezone (isti format kao kits[id].camp u seasons_kit.json).
// Koordinate u % recta 1032 x 318 (crta se u 1026 x 312 unutar ruba 3), oblici iz SHAPES, ≤ 12 slojeva, statično.
// Mirne zone za tekst (ništa rasuto ne pada u njih): ime x 2–46 y 7–45 · dugme x 69–98 y 7–45 · red 2 x 2–98 y 51–93.
// ink = boja teksta kartice; ink_on = boje ispod teksta za provjeru kontrasta (≥ 4,5:1).
import { spikes, contrast } from './seasons_kit.js';

export const CAMP_PAID = {
  moonlit_warren: { w: 1032, h: 318, ink: '#FFF8F0', ink_on: ['#141833', '#191E3D', '#1F2547', '#2B3263', '#232955'], layers: [
    { k: 'band', y0: 0, y1: 30, c: '#141833' }, { k: 'band', y0: 30, y1: 56, c: '#191E3D' }, { k: 'band', y0: 56, y1: 100, c: '#1F2547' },
    { k: 'scatter', shape: 'dot', n: 16, size: [4, 7], rot: [0, 0], phase: [0.3, 0.7, 0.2, 0], zones: [[47, 4, 21, 40]], pal: ['#DCDDFF'], noAvoid: true },
    { k: 'shape', shape: 'moon', at: [[58, 30, 108]], pal: ['#EDEBFF', '#D2D0F2'] },
    { k: 'ridge', r: { y: 50, w: [[2.4, 1.8, 0.3], [1.2, 3.6, 1.1]] }, c: '#2B3263', rim: ['#4A5290', 4] },
    { k: 'shape', shape: 'burrow', at: [[37, 57, 44], [99, 55, 38]], pal: ['#0F1228', '#4D5698'] },
    { k: 'ridge', r: { y: 70, w: [[1, 2.2, 0.9]] }, c: '#232955' },
    { k: 'shape', shape: 'moss', at: [[1, 100, 64], [33, 100, 52]], pal: ['#2E4F5A'] }
  ] },
  coral_tide: { w: 1032, h: 318, ink: '#3D3D33', ink_on: ['#CDEEF2', '#C2EAEC', '#93D7D4', '#F4FAF6', '#E8C2A6', '#F2D6BC'], layers: [
    { k: 'band', y0: 0, y1: 40, c: '#CDEEF2' }, { k: 'band', y0: 40, y1: 100, c: '#C2EAEC' },
    { k: 'ridge', r: { y: 40, tilt: -14, w: [[0.8, 1.4, 0.4]] }, c: '#93D7D4' },
    { k: 'shape', shape: 'ripple', at: [[52, 18, 80], [64, 30, 56]], pal: ['#E6F7F8'] },
    { k: 'ridge', r: { y: 57, tilt: -14, w: [[1.2, 2.2, 0.4], [0.6, 4.1, 1.2]] }, c: '#F4FAF6' },
    { k: 'ridge', r: { y: 60, tilt: -14, w: [[1.2, 2.2, 0.4], [0.6, 4.1, 1.2]] }, c: '#E8C2A6' },
    { k: 'ridge', r: { y: 74, tilt: -10, w: [[0.8, 1.6, 2.2]] }, c: '#F2D6BC' },
    { k: 'shape', shape: 'coral', at: [[61, 52, 84]], pal: ['#F59A8B', '#FFC5B8'] },
    { k: 'shape', shape: 'shell', at: [[31, 99, 38, -20], [99, 72, 34, 20]], pal: ['#FFF1E8', '#E9C2AE'] },
    { k: 'shape', shape: 'starfish', at: [[2, 97, 40, 18]], pal: ['#F29B80', '#FFD0BE'] }
  ] },
  starfall_glade: { w: 1032, h: 318, ink: '#FFF8F0', ink_on: ['#0C0A1F', '#100D26', '#14102D', '#191434', '#0B0919', '#261F4C'], layers: [
    { k: 'band', y0: 0, y1: 25, c: '#0C0A1F' }, { k: 'band', y0: 25, y1: 50, c: '#100D26' }, { k: 'band', y0: 50, y1: 75, c: '#14102D' }, { k: 'band', y0: 75, y1: 100, c: '#191434' },
    { k: 'scatter', shape: 'dot', n: 20, size: [4, 7], rot: [0, 0], phase: [0.3, 0.7, 0.2, 0], zones: [[47, 3, 21, 42]], pal: ['#E9E0FF'], noAvoid: true },
    { k: 'shape', shape: 'meteor', at: [[64, 10, 120, 150]], pal: ['#FFF2BF', '#B8A8F0'] },
    { k: 'shape', shape: 'sparkle', at: [[51, 16, 22], [66, 38, 16], [55, 40, 12]], pal: ['#FFF2BF'] },
    { k: 'poly', pts: spikes(0, 100, 4, 46, 54, 60, 1.2), c: '#0B0919' },
    { k: 'ellipse', at: [50, 100], r: [44, 30], c: '#261F4C' },
    { k: 'shape', shape: 'fern', at: [[1, 100, 70], [99, 100, 64]], pal: ['#342C5C'] }
  ] },
  ember_fen: { w: 1032, h: 318, ink: '#FFF8F0', ink_on: ['#160B08', '#1C0F0B', '#22120D', '#3A221C', '#120806', '#24130E'], layers: [
    { k: 'band', y0: 0, y1: 30, c: '#160B08' }, { k: 'band', y0: 30, y1: 60, c: '#1C0F0B' }, { k: 'band', y0: 60, y1: 100, c: '#22120D' },
    { k: 'poly', smooth: true, pts: [[0, 36], [30, 33], [60, 37], [100, 34], [100, 42], [60, 45], [30, 41], [0, 44]], c: '#3A221C' },
    { k: 'poly', pts: spikes(0, 100, 2.2, 48, 58, 66, 1.4), c: '#120806' },
    { k: 'ridge', r: { y: 74, w: [[0.6, 1.4, 0.2]] }, c: '#24130E' },
    { k: 'ellipse', at: [36, 90], r: [12, 5], c: '#120808' },
    { k: 'line', pts: [[31, 89], [38, 88]], c: '#C8643A', w: 4 },
    { k: 'shape', shape: 'cattail', at: [[61, 64, 104], [64, 64, 82], [99, 100, 104]], pal: ['#8A5536', '#2E1E1C'] },
    { k: 'shape', shape: 'ember', at: [[50, 14, 14], [59, 28, 12], [66, 8, 14], [47, 36, 10]], pal: ['#FFB074', '#FFE0B8'] }
  ] }
};
export const ROSTER_PAID = {
  moonlit_warren: [['moon_moss', 1], ['nightshade_petal', 1], ['silver_harebell', 1], ['lunar_orchid', 2], ['star_jasmine', 2], ['umbral_lily', 3]],
  coral_tide: [['sea_thrift', 1], ['salt_daisy', 1], ['tide_anemone', 1], ['coral_hibiscus', 2], ['pearl_waterlily', 2], ['reef_crown', 3]],
  starfall_glade: [['comet_sprig', 1], ['nebula_clover', 1], ['meteor_daisy', 1], ['aurora_tulip', 2], ['galaxy_sunburst', 2], ['nova_bloom', 3]],
  ember_fen: [['marsh_rush', 1], ['peat_violet', 1], ['cinder_buttercup', 1], ['flame_iris', 2], ['smoke_lotus', 2], ['fenfire_crown', 3]]
};
export function inkReport(id) { const r = CAMP_PAID[id]; const vals = r.ink_on.map(c => [c, Math.round(contrast(r.ink, c) * 100) / 100]); return { ink: r.ink, min: Math.min(...vals.map(v => v[1])), vals, layers: r.layers.length }; }
