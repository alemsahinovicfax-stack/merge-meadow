"""Koliko će ljudi igrati — retencija → DAU (RET-01).

    python scripts/analytics/retention_forecast.py scenarios
    python scripts/analytics/retention_forecast.py scenarios --d1 0.28 --d7 0.07
    python scripts/analytics/retention_forecast.py forecast --d1 0.25 --d7 0.06 --installs 20
    python scripts/analytics/retention_forecast.py forecast --d1 25% --d7 6% --d30 1.5% \\
        --launch 200 --decay 0.9 --floor 5 --days 180 --out prognoza.md --csv dau.csv
    python scripts/analytics/retention_forecast.py cohort --csv testeri.csv --today 2026-11-20
    python scripts/analytics/retention_forecast.py cohort --csv testeri.csv --forecast --installs 20
    python -m unittest discover scripts/analytics

Udio se piše kao 0.25, 0,25, 25% ili 25 (veće od 1 = posto). Ispis je markdown, UTF-8; u fajl ide
preko --out (PowerShell 5.1 `>` pokvari slova; za pipe postavi $env:PYTHONIOENCODING = "utf-8").

Model: R(t) = a·t^(−b) je udio instalacija aktivan na dan t, R(0) = 1. Iz D1 i D7 zatvorena forma
b = ln(D1/D7)/ln 7, a = D1; s D14/D30 najmanji kvadrati u log-log. Očekivani aktivni dani po
instalaciji za H dana = 1 + Σ R(t), t = 1…H. DAU(d) = Σ instalacije(i)·R(d − i).

Red testera (mm1) je dugme Copy na skrivenom ekranu statistike (Settings → 5 dodira na verziju);
format i značenje polja: game/scripts/economy/activity_log.gd (CSV_HEADER, csv_row). Jedan red po
testeru (najnoviji). Strategija: docs/06-production/procjena-igraca.md.
"""
import argparse
import csv
import math
import statistics
import sys
from dataclasses import dataclass
from datetime import date
from itertools import accumulate

Z95 = 1.959963984540054
HEADER = ["mm1", "version", "first_day", "days", "sessions", "minutes", "runs", "season", "level",
          "tut_day", "end_day", "merge_sec", "late_days", "last_day"]
INT_FIELDS = ("sessions", "minutes", "runs", "level", "tut_day", "end_day", "merge_sec",
              "late_days", "last_day")
TRACKED_DAYS = 31
RETENTION_DAYS = (1, 3, 7, 14, 30)
CURVE_DAYS = (1, 7, 14, 30, 60, 90)
HORIZONS = (30, 90, 180)
SCENARIOS = (("slaba", 0.15, 0.025), ("prosječna", 0.22, 0.04), ("dobra", 0.25, 0.06))
SCENARIO_INSTALLS = (5, 20, 50)
SCENARIO_HORIZON = 90
# KPI prvog iskustva (docs/03-content/ideje-prvo-iskustvo.md).
MERGE_GOAL_SEC = 240
DEFAULT_DECAY = 0.9
DEFAULT_FLOOR = 5.0

NOTE_D30 = ("Napomena: kriva iz samo D1 i D7 obično precijeni D30 i dalje (stvarne kohorte poslije "
            "druge sedmice padaju strmije), pa je DAU poslije prvog mjeseca gornja granica. Kad imaš "
            "pravi D14/D30, dodaj --d14/--d30 i kriva se ispravi.")
NOTE_FITTED = ("Napomena: kriva je ispravljena s D14/D30; sve poslije zadnje izmjerene tačke je i dalje "
               "ekstrapolacija.")


# --- formatiranje ------------------------------------------------------------

def pct(x: float, nd: int = 1) -> str:
    return f"{x * 100:.{nd}f} %".replace(".", ",")


def num(x: float, nd: int = 2) -> str:
    return f"{x:.{nd}f}".replace(".", ",")


def whole(x: float) -> str:
    return f"{round(x):,}".replace(",", " ")


def qty(x: float) -> str:
    """Cijeli broj bez decimala, inače jedna decimala."""
    return whole(x) if float(x).is_integer() else num(x, 1)


def mmss(sec: float) -> str:
    s = round(sec)
    return f"{s // 60}:{s % 60:02d}"


def table(headers: list, rows: list, left: int = 1) -> list:
    """Markdown tabela; prvih `left` kolona lijevo, ostale desno."""
    out = ["| " + " | ".join(headers) + " |",
           "|" + "|".join("---" if i < left else "---:" for i in range(len(headers))) + "|"]
    out += ["| " + " | ".join(str(c) for c in row) + " |" for row in rows]
    return out


# --- kriva -------------------------------------------------------------------

@dataclass(frozen=True)
class Curve:
    a: float
    b: float
    method: str

    def r(self, t: int) -> float:
        if t <= 0:
            return 1.0
        return min(1.0, self.a * t ** -self.b)

    def active_days(self, horizon: int) -> float:
        """Očekivani aktivni dani po instalaciji: dan 0 (= 1) + dani 1…horizon."""
        return 1.0 + sum(self.r(t) for t in range(1, horizon + 1))


def fit_d1_d7(d1: float, d7: float) -> tuple:
    """Zatvorena forma kroz D1 i D7 → (a, b)."""
    if not 0 < d7 < d1 <= 1:
        raise ValueError(f"treba 0 < D7 < D1 ≤ 100 % (D1 = {pct(d1)}, D7 = {pct(d7)})")
    return d1, math.log(d1 / d7) / math.log(7)


def fit_power(points: list) -> tuple:
    """Najmanji kvadrati za ln R = ln a − b·ln t; points = [(dan, udio), …] → (a, b)."""
    for t, r in points:
        if t < 1 or not 0 < r <= 1:
            raise ValueError(f"tačka D{t} = {pct(r)} ne valja (dan ≥ 1, udio između 0 i 100 %)")
    if len({t for t, _ in points}) < 2:
        raise ValueError("treba bar dva različita dana")
    xs = [math.log(t) for t, _ in points]
    ys = [math.log(r) for _, r in points]
    mx, my = statistics.fmean(xs), statistics.fmean(ys)
    slope = (sum((x - mx) * (y - my) for x, y in zip(xs, ys))
             / sum((x - mx) ** 2 for x in xs))
    a, b = math.exp(my - slope * mx), -slope
    if b <= 0:
        raise ValueError("kriva ne pada (b ≤ 0) — provjeri unose")
    return a, b


def make_curve(d1: float, d7: float, d14: float = None, d30: float = None) -> Curve:
    extra = [(t, r) for t, r in ((14, d14), (30, d30)) if r is not None]
    if not extra:
        a, b = fit_d1_d7(d1, d7)
        return Curve(a, b, "D1 + D7, zatvorena forma")
    a, b = fit_power([(1, d1), (7, d7)] + extra)
    return Curve(a, b, f"najmanji kvadrati u log-log, {2 + len(extra)} tačke")


def install_schedule(days: int, installs: float = None, launch: float = None,
                     decay: float = DEFAULT_DECAY, floor: float = DEFAULT_FLOOR) -> list:
    """Instalacije po danu: stalno `installs`, ili `launch` na dan 0 pa ×decay dnevno do `floor`."""
    if installs is not None:
        return [float(installs)] * days
    return [max(launch * decay ** i, floor) for i in range(days)]


def simulate_dau(curve: Curve, schedule: list) -> list:
    r = [curve.r(t) for t in range(len(schedule))]
    return [sum(schedule[i] * r[d - i] for i in range(d + 1)) for d in range(len(schedule))]


def wilson(k: int, n: int, z: float = Z95) -> tuple:
    """Wilsonov interval (95 %) za udio k/n."""
    if n <= 0:
        raise ValueError("n mora biti > 0")
    p = k / n
    z2 = z * z
    den = 1 + z2 / n
    center = (p + z2 / (2 * n)) / den
    half = z * math.sqrt(p * (1 - p) / n + z2 / (4 * n * n)) / den
    return max(0.0, center - half), min(1.0, center + half)


# --- izvještaji --------------------------------------------------------------

def forecast_lines(curve: Curve, schedule: list, schedule_text: str, measured: dict = None,
                   fitted: bool = False) -> tuple:
    """Markdown prognoze (kriva, aktivni dani, DAU svakih 7 dana) → (linije, DAU po danu)."""
    measured = measured or {}
    days = len(schedule)
    dau = simulate_dau(curve, schedule)
    out = ["## Kriva zadržavanja", "",
           f"R(t) = a·t^(−b), R(0) = 1 · a = {num(curve.a, 3)} · b = {num(curve.b, 3)} · {curve.method}", ""]
    out += table(["Dan", "R(t) kriva", "ulaz / izmjereno"],
                 [[f"D{t}", pct(curve.r(t)), pct(measured[t]) if t in measured else "—"]
                  for t in CURVE_DAYS])
    out += ["", "## Očekivani aktivni dani po instalaciji", ""]
    out += table(["Horizont", "aktivnih dana"],
                 [[f"{h} dana", num(curve.active_days(h))] for h in HORIZONS])
    out += ["", "Dan 0 se broji kao 1 (svaka instalacija igra prvi dan). Uz stalni priliv N instalacija "
            "dnevno DAU poslije H dana = N × aktivnih dana za H.", ""]
    cum = list(accumulate(schedule))
    shown = list(range(0, days, 7))
    if shown[-1] != days - 1:
        shown.append(days - 1)
    out += [f"## DAU po danu — {schedule_text}", ""]
    out += table(["Dan", "instalacije tog dana", "ukupno instalacija", "DAU", "od toga povratni"],
                 [[d, qty(round(schedule[d], 1)), whole(cum[d]), whole(dau[d]), whole(dau[d] - schedule[d])]
                  for d in shown])
    peak = max(range(days), key=dau.__getitem__)
    out += ["", f"Ukupno instalacija za {days} dana: {whole(cum[-1])} · najveći DAU {whole(dau[peak])} "
            f"(dan {peak}) · DAU zadnjeg dana (dan {days - 1}): {whole(dau[-1])}", "",
            "> " + (NOTE_FITTED if fitted else NOTE_D30)]
    return out, dau


def scenarios_lines(d1: float = None, d7: float = None) -> list:
    items = list(SCENARIOS)
    if d1 is not None:
        items.append(("tvoja", d1, d7))
    rows = []
    for name, s1, s7 in items:
        c = make_curve(s1, s7)
        m = c.active_days(SCENARIO_HORIZON)
        rows.append([name, pct(s1), pct(s7), pct(c.r(30)), num(m)]
                    + [whole(n * m) for n in SCENARIO_INSTALLS])
    out = ["# Scenariji retencije", ""]
    out += table(["Scenarij", "D1", "D7", "D30 (kriva)", f"aktivnih dana / instalaciji ({SCENARIO_HORIZON} d)"]
                 + [f"DAU uz {n}/dan" for n in SCENARIO_INSTALLS], rows)
    out += ["", f"DAU uz N/dan = stanje na dan {SCENARIO_HORIZON} kad od lansiranja svaki dan stigne N "
            f"novih instalacija (= N × aktivnih dana po instalaciji). Za drugi priliv ili lansiranje: "
            f"`forecast`.", "", "> " + NOTE_D30]
    return out


# --- kohorta -----------------------------------------------------------------

@dataclass
class Tester:
    line: int
    version: str
    first_day: date
    days: str
    sessions: int
    minutes: int
    runs: int
    season: str
    level: int
    tut_day: int
    end_day: int
    merge_sec: int
    late_days: int
    last_day: int

    @property
    def copy_day(self) -> int:
        """Dan kopiranja reda: igra je tada bila otvorena, pa je to zadnji dan s aktivnošću."""
        if self.last_day >= 0:
            return self.last_day
        known = [i for i, ch in enumerate(self.days) if ch != "-"]
        return known[-1] if known else -1

    @property
    def fresh(self) -> bool:
        """Brojač radi od prvog pokretanja (dan 0 poznat); stari save ne zna prvo iskustvo."""
        return self.days[0] != "-"

    def active_days(self) -> int:
        return self.days.count("1") + max(0, self.late_days)

    def day_status(self, n: int, today: date, count_copy_day: bool = False):
        """'1' / '0' za dan n, ili None kad se ne broji (nije prošao, nepoznat, dan kopiranja)."""
        if n >= len(self.days) or (today - self.first_day).days < n:
            return None
        ch = self.days[n]
        if ch == "-" or (n == self.copy_day and not count_copy_day):
            return None
        return ch


def parse_row(cells: list, line: int) -> Tester:
    if len(cells) != len(HEADER):
        raise ValueError(f"{len(cells)} polja, treba {len(HEADER)}")
    v = dict(zip(HEADER, cells))
    try:
        first = date.fromisoformat(v["first_day"])
    except ValueError:
        raise ValueError(f"first_day nije datum YYYY-MM-DD: {v['first_day']!r}") from None
    days = v["days"]
    if not days or set(days) - set("01-"):
        hint = " (Excel ga je pretvorio u broj? otvori CSV kao tekst)" if set(days) & set("Ee+.,") else ""
        raise ValueError(f"days mora biti niz znakova 0/1/-{hint}: {days!r}")
    if len(days) != TRACKED_DAYS:
        raise ValueError(f"days ima {len(days)} znakova, treba {TRACKED_DAYS}")
    ints = {}
    for name in INT_FIELDS:
        try:
            ints[name] = int(v[name])
        except ValueError:
            raise ValueError(f"{name} nije cijeli broj: {v[name]!r}") from None
    return Tester(line=line, version=v["version"], first_day=first, days=days, season=v["season"], **ints)


def parse_csv_text(text: str) -> tuple:
    """Redovi mm1 → (testeri, upozorenja). Preskače zaglavlje, prazne redove i redove s #; red može
    biti i jedna ćelija `mm1,…` (npr. kolona iz Google Forms exporta)."""
    testers, warnings = [], []
    for line, row in enumerate(csv.reader(text.lstrip("﻿").splitlines()), start=1):
        cells = [c.strip() for c in row]
        if not any(cells) or cells[0].startswith("#"):
            continue
        if cells[0] != HEADER[0]:
            embedded = next((c for c in cells if c.startswith(HEADER[0] + ",")), None)
            if embedded is None:
                warnings.append(f"red {line}: nije {HEADER[0]} red — preskočen")
                continue
            cells = [c.strip() for c in next(csv.reader([embedded]))]
        if cells[2:3] == ["first_day"]:
            continue
        try:
            testers.append(parse_row(cells, line))
        except ValueError as e:
            warnings.append(f"red {line}: {e} — preskočen")
    return testers, warnings


def read_testers(path: str) -> tuple:
    with open(path, encoding="utf-8-sig", newline="") as f:
        return parse_csv_text(f.read())


def cohort_retention(testers: list, today: date, count_copy_day: bool = False) -> dict:
    """Dan N → (k, n): koliko je igralo dan N od testera kod kojih se taj dan broji."""
    out = {}
    for n in RETENTION_DAYS:
        known = [s for s in (t.day_status(n, today, count_copy_day) for t in testers) if s is not None]
        out[n] = (known.count("1"), len(known))
    return out


def _day(x: int) -> str:
    return str(x) if x >= 0 else "—"


def _stat(x: float) -> str:
    return whole(x) if float(x).is_integer() else num(x, 1)


def cohort_lines(testers: list, warnings: list, today: date, source: str,
                 count_copy_day: bool = False) -> tuple:
    """Markdown kohorte → (linije, retencija)."""
    ret = cohort_retention(testers, today, count_copy_day)
    out = ["# Kohorta testera", "",
           f"Fajl: `{source}` · danas: {today.isoformat()} · testera: {len(testers)}"
           + (f" · preskočeno redova: {len(warnings)}" if warnings else ""), ""]
    if warnings:
        out += ["**Upozorenja**", ""] + [f"- {w}" for w in warnings] + [""]
    if not testers:
        return out + ["Nema ispravnih redova."], ret

    out += ["## Retencija", ""]
    rows = []
    for n, (k, m) in ret.items():
        if m == 0:
            rows.append([f"D{n}", "0/0", "—", "—"])
            continue
        lo, hi = wilson(k, m)
        rows.append([f"D{n}", f"{k}/{m}", pct(k / m), f"{num(lo * 100, 1)}–{num(hi * 100, 1)} %"])
    out += table(["Dan", "k/n", "udio", "Wilson 95 %"], rows)
    copy_rule = ("dan kopiranja se broji (--count-copy-day)" if count_copy_day else
                 "dan kopiranja reda se ne broji (tester je tada otvorio igru zbog reda; "
                 "--count-copy-day ga uključi)")
    out += ["", f"Dan N se broji kad je prošao (danas − prvi dan ≥ N), u redu nije `-`, a {copy_rule}. "
            "Mali uzorak: gledaj interval, ne samo udio; prijatelji igraju više od stranaca.", ""]

    out += ["## Testeri", ""]
    rows = []
    for i, t in enumerate(testers, start=1):
        rows.append([i, t.version, t.first_day.isoformat(), _day(t.copy_day), f"`{t.days}`",
                     t.active_days(), t.sessions, t.minutes, t.runs,
                     f"{t.season} {t.level}" if t.season else "—", _day(t.tut_day), _day(t.end_day),
                     mmss(t.merge_sec) if t.merge_sec >= 0 else "—"])
    out += table(["#", "verzija", "prvi dan", "dan kopiranja", "dani 0–30", "aktivnih dana", "sesije",
                  "minute", "runovi", "sezona / nivo", "tutorijal (dan)", "Endless (dan)", "prvi merge"],
                 rows, left=5)
    out += ["", "`dani 0–30`: 1 igrao, 0 nije, - nepoznato (prije brojača ili poslije kopiranja). "
            "Aktivni dani uključuju i dane poslije 30. (late_days).", ""]

    out += ["## Prosjek po testeru", ""]
    metrics = [("sesije", [t.sessions for t in testers]),
               ("minute", [t.minutes for t in testers]),
               ("runovi", [t.runs for t in testers]),
               ("aktivni dani", [t.active_days() for t in testers]),
               ("minuta po aktivnom danu", [t.minutes / t.active_days() for t in testers if t.active_days()]),
               ("nivo u najdaljoj sezoni", [t.level for t in testers])]
    out += table(["Metrika", "prosjek", "medijan", "min", "max"],
                 [[name, _stat(round(statistics.fmean(xs), 1)), _stat(statistics.median(xs)),
                   _stat(round(min(xs), 1)), _stat(round(max(xs), 1))]
                  for name, xs in metrics if xs])

    fresh = [t for t in testers if t.fresh]
    out += ["", "## Lijevak prvog iskustva", ""]
    if not fresh:
        return out + ["Nijedan tester nema brojač od prvog pokretanja (svi su sa starim saveom)."], ret
    steps = [("prvi merge", [t for t in fresh if t.merge_sec >= 0]),
             ("tutorijal završen", [t for t in fresh if t.tut_day >= 0]),
             ("Endless otključan", [t for t in fresh if t.end_day >= 0])]
    out += table(["Korak", "k/n", "udio"],
                 [[name, f"{len(xs)}/{len(fresh)}", pct(len(xs) / len(fresh))] for name, xs in steps])
    out.append("")
    merged = [t.merge_sec for t in steps[0][1]]
    if merged:
        out.append(f"Medijan do prvog mergea: {mmss(statistics.median(merged))} igre (n = {len(merged)}, "
                   f"cilj < {mmss(MERGE_GOAL_SEC)}).")
    endless = [t.end_day for t in steps[2][1]]
    if endless:
        out.append(f"Medijan dana do Endlessa: {_stat(statistics.median(endless))} (n = {len(endless)}).")
    if len(fresh) < len(testers):
        out.append(f"Lijevak broji samo testere s brojačem od prvog pokretanja ({len(fresh)}/{len(testers)}); "
                   "stari save ne zna prvo iskustvo.")
    return out, ret


def cohort_forecast_lines(ret: dict, schedule: list, schedule_text: str) -> list:
    out = ["", "# Prognoza s izmjerenim D1/D7", ""]
    (k1, n1), (k7, n7) = ret[1], ret[7]
    if not (n1 and n7 and k7):
        return out + ["Prognoza nije moguća: treba izmjereni D1 i D7 > 0 "
                      f"(D1 {k1}/{n1}, D7 {k7}/{n7}). Probaj `forecast` s pretpostavljenim D7."]
    d1, d7 = k1 / n1, k7 / n7
    try:
        curve = make_curve(d1, d7)
    except ValueError as e:
        return out + [f"Prognoza nije moguća: {e} — uzorak je premali ili šarolik."]
    measured = {n: k / m for n, (k, m) in ret.items() if m}
    body, dau = forecast_lines(curve, schedule, schedule_text, measured)
    out += body
    rows = [[f"D{n}", f"{ret[n][0]}/{ret[n][1]}", pct(measured[n]), pct(curve.r(n))]
            for n in RETENTION_DAYS if n not in (1, 7) and n in measured]
    if rows:
        out += ["", "## Izmjereno vs kriva", ""]
        out += table(["Dan", "k/n", "izmjereno", "kriva"], rows)
    bounds = []
    for pick in (0, 1):
        try:
            c = make_curve(wilson(k1, n1)[pick], wilson(k7, n7)[pick])
        except ValueError:
            return out
        bounds.append((c.active_days(SCENARIO_HORIZON), simulate_dau(c, schedule)[-1]))
    (m_lo, dau_lo), (m_hi, dau_hi) = bounds
    out += ["", f"Grubi raspon (donje pa gornje Wilson granice D1 i D7): aktivnih dana / instalaciji "
            f"({SCENARIO_HORIZON} d) {num(m_lo)}–{num(m_hi)}, DAU zadnjeg dana {whole(dau_lo)}–{whole(dau_hi)}."]
    return out


# --- CLI ---------------------------------------------------------------------

def rate(text: str) -> float:
    s = str(text).strip().replace(",", ".")
    percent = s.endswith("%")
    try:
        v = float(s.rstrip("%").strip())
    except ValueError:
        raise argparse.ArgumentTypeError(f"nije broj: {text!r}") from None
    if percent or v > 1:
        v /= 100
    if not 0 < v <= 1:
        raise argparse.ArgumentTypeError(f"udio mora biti između 0 i 1 (ili 0–100 %): {text!r}")
    return v


def iso_date(text: str) -> date:
    try:
        return date.fromisoformat(text)
    except ValueError:
        raise argparse.ArgumentTypeError(f"datum mora biti YYYY-MM-DD: {text!r}") from None


def add_install_args(p: argparse.ArgumentParser, required: bool) -> None:
    g = p.add_mutually_exclusive_group(required=required)
    g.add_argument("--installs", type=float, metavar="N", help="stalno N instalacija dnevno")
    g.add_argument("--launch", type=float, metavar="N", help="N instalacija na dan 0, pa pada")
    p.add_argument("--decay", type=float, help=f"uz --launch: dnevni množilac (default {DEFAULT_DECAY})")
    p.add_argument("--floor", type=float, help=f"uz --launch: najmanje dnevno (default {qty(DEFAULT_FLOOR)})")
    p.add_argument("--days", type=int, default=180, help="koliko dana simulirati (default 180)")


def schedule_from_args(parser: argparse.ArgumentParser, args) -> tuple:
    if args.days < 1:
        parser.error("--days mora biti ≥ 1")
    if args.installs is not None:
        if args.decay is not None or args.floor is not None:
            parser.error("--decay i --floor idu samo uz --launch")
        if args.installs < 0:
            parser.error("--installs ne može biti negativan")
        return install_schedule(args.days, installs=args.installs), \
            f"stalno {qty(args.installs)} instalacija dnevno"
    decay = DEFAULT_DECAY if args.decay is None else args.decay
    floor = DEFAULT_FLOOR if args.floor is None else args.floor
    if args.launch <= 0 or not 0 < decay <= 1 or floor < 0:
        parser.error("treba --launch > 0, 0 < --decay ≤ 1, --floor ≥ 0")
    return install_schedule(args.days, launch=args.launch, decay=decay, floor=floor), \
        f"lansiranje {qty(args.launch)} na dan 0, pa ×{num(decay)} dnevno, najmanje {qty(floor)}"


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="retention_forecast.py",
                                description="Retencija → aktivni dani po instalaciji → DAU (RET-01).")
    sub = p.add_subparsers(dest="cmd", required=True)

    f = sub.add_parser("forecast", help="kriva iz D1/D7 (+D14/D30) i DAU po danu")
    f.add_argument("--d1", type=rate, required=True)
    f.add_argument("--d7", type=rate, required=True)
    f.add_argument("--d14", type=rate)
    f.add_argument("--d30", type=rate)
    add_install_args(f, required=True)
    f.add_argument("--out", help="zapiši markdown i u ovaj fajl")
    f.add_argument("--csv", help="DAU za sve dane u CSV")

    s = sub.add_parser("scenarios", help="slaba / prosječna / dobra retencija (+ tvoja)")
    s.add_argument("--d1", type=rate)
    s.add_argument("--d7", type=rate)
    s.add_argument("--out", help="zapiši markdown i u ovaj fajl")

    c = sub.add_parser("cohort", help="retencija i lijevak iz mm1 redova testera")
    c.add_argument("--csv", required=True, help="fajl s mm1 redovima (prvi red zaglavlje)")
    c.add_argument("--today", type=iso_date, default=date.today(), help="YYYY-MM-DD (default danas)")
    c.add_argument("--count-copy-day", action="store_true",
                   help="broji i dan kopiranja reda (inače se ne broji)")
    c.add_argument("--forecast", action="store_true", help="prognoza s izmjerenim D1/D7")
    add_install_args(c, required=False)
    c.add_argument("--out", help="zapiši markdown i u ovaj fajl")
    return p


def emit(lines: list, out_path: str = None) -> None:
    text = "\n".join(lines) + "\n"
    sys.stdout.write(text)
    if out_path:
        with open(out_path, "w", encoding="utf-8", newline="\n") as f:
            f.write(text)
        print(f"Zapisano: {out_path}", file=sys.stderr)


def write_dau_csv(path: str, schedule: list, dau: list, curve: Curve) -> None:
    with open(path, "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["dan", "instalacije", "ukupno_instalacija", "dau", "r"])
        for d, (n, cum, x) in enumerate(zip(schedule, accumulate(schedule), dau)):
            w.writerow([d, f"{n:.2f}", f"{cum:.2f}", f"{x:.2f}", f"{curve.r(d):.5f}"])
    print(f"Zapisano: {path}", file=sys.stderr)


def main(argv: list = None) -> None:
    for stream in (sys.stdout, sys.stderr):
        if hasattr(stream, "reconfigure"):
            stream.reconfigure(encoding="utf-8")
    parser = build_parser()
    args = parser.parse_args(argv)

    if args.cmd == "forecast":
        try:
            curve = make_curve(args.d1, args.d7, args.d14, args.d30)
        except ValueError as e:
            parser.error(str(e))
        schedule, text = schedule_from_args(parser, args)
        measured = {t: v for t, v in ((1, args.d1), (7, args.d7), (14, args.d14), (30, args.d30))
                    if v is not None}
        head = ["# Prognoza igrača", "",
                "Ulaz: " + " · ".join(f"D{t} {pct(v)}" for t, v in measured.items())
                + f" · {text} · {args.days} dana", ""]
        body, dau = forecast_lines(curve, schedule, text, measured,
                                   fitted=args.d14 is not None or args.d30 is not None)
        emit(head + body, args.out)
        if args.csv:
            write_dau_csv(args.csv, schedule, dau, curve)

    elif args.cmd == "scenarios":
        if (args.d1 is None) != (args.d7 is None):
            parser.error("--d1 i --d7 idu zajedno")
        try:
            lines = scenarios_lines(args.d1, args.d7)
        except ValueError as e:
            parser.error(str(e))
        emit(lines, args.out)

    elif args.cmd == "cohort":
        if args.forecast and args.installs is None and args.launch is None:
            parser.error("--forecast traži --installs N ili --launch N")
        try:
            testers, warnings = read_testers(args.csv)
        except OSError as e:
            parser.error(f"ne mogu pročitati {args.csv}: {e}")
        lines, ret = cohort_lines(testers, warnings, args.today, args.csv, args.count_copy_day)
        if args.forecast and testers:
            schedule, text = schedule_from_args(parser, args)
            lines += cohort_forecast_lines(ret, schedule, text)
        emit(lines, args.out)


if __name__ == "__main__":
    main()
