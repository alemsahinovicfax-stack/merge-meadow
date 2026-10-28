// Merge Meadow · v1 bez kupovina — podaci mocka. NIJE tokens fajl: stilovi su inline u .dc.html.
// Cijene i pravila: ads-only-cd-brief §4 (fiksno). Boje sezona: design_handoff_seasons/design/seasons_kit.js.

export const PRICE = { theme: 10000, sir_pip: 3000, merge_hint: 1500, loot_burst: 1000 };
export const EUR = { moonlit_warren: '€2.99', coral_tide: '€3.49', starfall_glade: '€2.99', merge_hint: '€0.99', loot_burst: '€0.99', remove_ads: '€3.99' };
export const FREE_PATH = {
  frost_orchard: { coins: 2500, star3: 22, flower: 'pumpkin', flowerName: 'Harvest Pumpkin' },
  lantern_meadow: { coins: 4500, star3: 26, flower: 'crystal_peony', flowerName: 'Crystal Peony' },
  amber_canopy: { coins: 6500, star3: 30, flower: 'midnight_lotus', flowerName: 'Midnight Lotus' }
};
export const T = { confirm: 3.0, need: 1.6, shake: 0.32, pop: 0.22, buy: 0.6, tab: 0.2, toast: 1.6 };

// UiChrome.format_count — isti format kao header („12,000").
export function fmt(n) { return String(Math.round(+n || 0)).replace(/\B(?=(\d{3})+(?!\d))/g, ','); }
export function needText(price, wallet) { return 'Need ' + fmt(Math.max(1, price - wallet)) + ' more coins'; }

// A: tab širina = f(broj tabova). Isto pravilo daje današnji raspored za 4 (249 / 261 / 24).
export const TABBAR = { w: 1080, h: 172, awningH: 160, stripeW: 60, stripes: 18, x0: 24, inner: 1032, gap: 12, y: 10, tabH: 120 };
export function tabLayout(n) {
  const w = Math.floor((TABBAR.inner - (n - 1) * TABBAR.gap) / n);
  const step = w + TABBAR.gap;
  const used = n * w + (n - 1) * TABBAR.gap;
  const x0 = TABBAR.x0 + Math.round((TABBAR.inner - used) / 2);
  return { n, w, step, x0, xs: Array.from({ length: n }, (_, i) => x0 + i * step) };
}

// Season Kit (seasons_kit.js): nebo = 4 ravne trake, daljina, blizina, boja teksta, stranica.
export const SEASONS = {
  country_bloom: { name: 'Country Bloom', kind: 'free', sky: ['#E3F0EE', '#EAF4EA', '#F0F7E6', '#F5F9E2'], far: '#D3E7C0', near: '#C3E0A8', ink: '#1A1A14', page: '#F4F9EF', dark: false,
    roster: [['clover', 1, 'Meadow Clover'], ['daisy', 1, 'Field Daisy'], ['buttercup', 1, 'Buttercup Lane'], ['tulip', 2, 'Barn Tulip'], ['sunflower', 2, 'Sunfence'], ['pumpkin', 3, 'Harvest Pumpkin']] },
  frost_orchard: { name: 'Frost Orchard', kind: 'free', sky: ['#D9E7F6', '#E0ECF8', '#E7F0FA', '#EEF5FC'], far: '#EAF1F9', near: '#F3F7FC', ink: '#1A1A14', page: '#EEF4FB', dark: false,
    roster: [['frost_snowdrop', 1, 'Frost Snowdrop'], ['ice_crocus', 1, 'Ice Crocus'], ['silver_aconite', 1, 'Silver Aconite'], ['winter_camellia', 2, 'Winter Camellia'], ['hoarfrost_rose', 2, 'Hoarfrost Rose'], ['crystal_peony', 3, 'Crystal Peony']] },
  lantern_meadow: { name: 'Lantern Meadow', kind: 'free', sky: ['#120E22', '#171229', '#1D1631', '#241B3A'], far: '#1C1730', near: '#15112A', ink: '#FFF8F0', page: '#E9E1F5', dark: true, roster: [] },
  amber_canopy: { name: 'Amber Canopy', kind: 'free', sky: ['#F2C46A', '#F2C46A', '#E8AE58', '#E8AE58'], far: '#F7E8C9', near: '#EACB97', ink: '#1A1A14', page: '#FBF1DE', dark: false, roster: [] },
  moonlit_warren: { name: 'Moonlit Warren', kind: 'theme', sky: ['#141833', '#191E3D', '#1F2547', '#262C53'], far: '#232955', near: '#1A1E3E', ink: '#FFF8F0', page: '#DFE1FF', dark: true,
    roster: [['moon_moss', 1, 'Moon Moss'], ['nightshade_petal', 1, 'Nightshade Petal'], ['silver_harebell', 1, 'Silver Harebell'], ['lunar_orchid', 2, 'Lunar Orchid'], ['star_jasmine', 2, 'Star Jasmine'], ['umbral_lily', 3, 'Umbral Lily']] },
  coral_tide: { name: 'Coral Tide Garden', kind: 'theme', sky: ['#E6F7F8', '#CDEEF2', '#CDEEF2', '#93D7D4'], far: '#F2D6BC', near: '#F5DEC8', ink: '#1A1A14', page: '#EAF7F6', dark: false,
    roster: [['sea_thrift', 1, 'Sea Thrift'], ['salt_daisy', 1, 'Salt Daisy'], ['tide_anemone', 1, 'Tide Anemone'], ['coral_hibiscus', 2, 'Coral Hibiscus'], ['pearl_waterlily', 2, 'Pearl Waterlily'], ['reef_crown', 3, 'Reef Crown']] },
  starfall_glade: { name: 'Starfall Glade', kind: 'theme', sky: ['#0C0A1F', '#100D26', '#14102D', '#191434'], far: '#1E1840', near: '#171233', ink: '#FFF8F0', page: '#E6E0FA', dark: true,
    roster: [['comet_sprig', 1, 'Comet Sprig'], ['nebula_clover', 1, 'Nebula Clover'], ['meteor_daisy', 1, 'Meteor Daisy'], ['aurora_tulip', 2, 'Aurora Tulip'], ['galaxy_sunburst', 2, 'Galaxy Sunburst'], ['nova_bloom', 3, 'Nova Bloom']] },
  ember_fen: { name: 'Ember Fen', kind: 'theme', soon: true, sky: ['#160B08', '#1C0F0B', '#22120D', '#2A1610'], far: '#24130E', near: '#1A0D09', ink: '#FFF8F0', page: '#F7E4D8', dark: true, roster: [] }
};
export const THEMES = ['moonlit_warren', 'coral_tide', 'starfall_glade'];
export const ALL8 = ['country_bloom', 'frost_orchard', 'lantern_meadow', 'amber_canopy', 'moonlit_warren', 'coral_tide', 'starfall_glade', 'ember_fen'];
export const flowerSrc = t => 'flowers/' + t + '_t3.svg';
// Home v3 raspored 6 diskova: [r0, ★3, r3 | r1, r2, r4] (ROSTER6, UiHomeV3)
export function homeOrder(roster) { return [0, 5, 3, 1, 2, 4].map(i => roster[i]).filter(Boolean); }

// kontrast (WCAG)
const rgb = h => [0, 2, 4].map(i => parseInt(h.replace('#', '').substr(i, 2), 16));
const lum = h => rgb(h).map(c => { c /= 255; return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4); }).reduce((s, v, i) => s + v * [0.2126, 0.7152, 0.0722][i], 0);
export function contrast(a, b) { const x = lum(a), y = lum(b); return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05); }
