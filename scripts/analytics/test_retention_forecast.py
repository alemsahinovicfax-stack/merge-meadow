"""Testovi kalkulatora retencije:  python -m unittest discover scripts/analytics"""
import contextlib
import io
import math
import os
import sys
import tempfile
import unittest
from datetime import date

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import retention_forecast as rf  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
TODAY = date(2026, 11, 20)


def row(first_day: str, days: str, last_day: int, tut: int = 0, end: int = -1, merge: int = 60,
        late: int = 0) -> str:
    return (f"mm1,0.1.0,{first_day},{days},5,40,10,country_bloom,3,{tut},{end},{merge},{late},"
            f"{last_day}")


class FitTest(unittest.TestCase):
    def test_power_fit_recovers_known_curve(self):
        a, b = 0.31, 0.62
        fa, fb = rf.fit_power([(t, a * t ** -b) for t in (1, 3, 7, 14, 30)])
        self.assertAlmostEqual(fa, a, places=9)
        self.assertAlmostEqual(fb, b, places=9)

    def test_closed_form_matches_two_point_fit(self):
        a, b = rf.fit_d1_d7(0.25, 0.06)
        self.assertAlmostEqual(a, 0.25)
        self.assertAlmostEqual(b, math.log(0.25 / 0.06) / math.log(7))
        la, lb = rf.fit_power([(1, 0.25), (7, 0.06)])
        self.assertAlmostEqual(la, a, places=12)
        self.assertAlmostEqual(lb, b, places=12)

    def test_extra_points_use_least_squares(self):
        a, b = 0.28, 0.8
        c = rf.make_curve(a, a * 7 ** -b, d14=a * 14 ** -b, d30=a * 30 ** -b)
        self.assertIn("najmanji kvadrati", c.method)
        self.assertAlmostEqual(c.a, a, places=9)
        self.assertAlmostEqual(c.b, b, places=9)

    def test_curve_must_fall(self):
        with self.assertRaises(ValueError):
            rf.fit_d1_d7(0.05, 0.10)
        with self.assertRaises(ValueError):
            rf.fit_power([(1, 0.1), (7, 0.2), (30, 0.3)])

    def test_r_of_day_zero_is_one(self):
        c = rf.make_curve(0.25, 0.06)
        self.assertEqual(c.r(0), 1.0)
        self.assertAlmostEqual(c.r(1), 0.25)
        self.assertAlmostEqual(c.r(7), 0.06)


class WilsonTest(unittest.TestCase):
    def test_six_of_fifteen(self):
        lo, hi = rf.wilson(6, 15)
        self.assertAlmostEqual(lo, 0.198, places=3)
        self.assertAlmostEqual(hi, 0.643, places=3)

    def test_edges(self):
        self.assertAlmostEqual(rf.wilson(0, 12)[0], 0.0, places=12)
        self.assertAlmostEqual(rf.wilson(12, 12)[1], 1.0, places=12)
        with self.assertRaises(ValueError):
            rf.wilson(0, 0)


class MultiplierTest(unittest.TestCase):
    def test_scenarios_90_days(self):
        for d1, d7, expected in ((0.25, 0.06, 3.3), (0.22, 0.04, 2.4), (0.15, 0.025, 1.9)):
            m = rf.make_curve(d1, d7).active_days(90)
            self.assertAlmostEqual(m, expected, delta=0.1, msg=f"{d1}/{d7}")

    def test_constant_installs_dau_equals_multiplier(self):
        c = rf.make_curve(0.25, 0.06)
        dau = rf.simulate_dau(c, rf.install_schedule(91, installs=20))
        self.assertAlmostEqual(dau[90], 20 * c.active_days(90), places=9)
        self.assertEqual(dau[0], 20)

    def test_launch_schedule_decays_to_floor(self):
        s = rf.install_schedule(60, launch=200, decay=0.9, floor=5)
        self.assertEqual(s[0], 200)
        self.assertAlmostEqual(s[1], 180)
        self.assertAlmostEqual(s[2], 162)
        self.assertEqual(s[-1], 5)
        self.assertTrue(all(x >= 5 for x in s))


class CohortParseTest(unittest.TestCase):
    def setUp(self):
        self.t1 = row("2026-11-01", "1101" + "0001" + "0" * 7 + "1" + "-" * 15, 15)
        self.t2 = row("2026-11-05", "--1011" + "0" * 8 + "1" + "-" * 16, 14, tut=2, merge=12)
        # Prozor nije prošao: prvi dan prije 3 dana, red kopiran na dan 2.
        self.t3 = row("2026-11-17", "111" + "-" * 28, 2)
        form = f'2026-11-17 10:00,5,"{row("2026-11-02", "1" + "0" * 14 + "1" + "-" * 15, 15, merge=-1)}"'
        text = "\n".join([",".join(rf.HEADER), "# komentar", self.t1, self.t2, self.t3, form, "",
                          "mm1,0.1.0,2026-13-01," + "1" * 31 + ",1,1,1,x,1,0,-1,5,0,0",
                          "mm1,0.1.0,2026-11-01,1.1E+30,1,1,1,x,1,0,-1,5,0,0",
                          "nesto,drugo"])
        self.testers, self.warnings = rf.parse_csv_text(text)

    def test_rows_and_warnings(self):
        self.assertEqual(len(self.testers), 4)
        self.assertEqual(len(self.warnings), 3)
        self.assertIn("first_day", self.warnings[0])
        self.assertIn("Excel", self.warnings[1])

    def test_unknown_days_and_copy_day(self):
        t2 = self.testers[1]
        self.assertFalse(t2.fresh)
        self.assertEqual(t2.copy_day, 14)
        self.assertIsNone(t2.day_status(1, TODAY))
        self.assertEqual(t2.day_status(3, TODAY), "0")
        self.assertIsNone(t2.day_status(14, TODAY))
        self.assertEqual(t2.day_status(14, TODAY, count_copy_day=True), "1")

    def test_window_not_passed(self):
        t1, t3 = self.testers[0], self.testers[2]
        self.assertEqual(t3.day_status(1, TODAY), "1")
        self.assertIsNone(t3.day_status(3, TODAY))
        self.assertIsNone(t3.day_status(7, TODAY))
        # Dan 7 je u redu poznat, ali danas = prvi dan + 5 → još ne broji.
        self.assertEqual(t1.day_status(7, TODAY), "1")
        self.assertIsNone(t1.day_status(7, date(2026, 11, 6)))

    def test_retention_counts(self):
        ret = rf.cohort_retention(self.testers, TODAY)
        self.assertEqual(ret[1], (2, 3))
        self.assertEqual(ret[3], (1, 3))
        self.assertEqual(ret[7], (1, 3))
        self.assertEqual(ret[14], (0, 2))
        self.assertEqual(ret[30], (0, 0))
        self.assertEqual(rf.cohort_retention(self.testers, TODAY, count_copy_day=True)[14], (1, 3))

    def test_example_file(self):
        testers, warnings = rf.read_testers(os.path.join(HERE, "testeri-primjer.csv"))
        self.assertEqual(warnings, [])
        self.assertEqual(len(testers), 6)
        ret = rf.cohort_retention(testers, TODAY)
        self.assertEqual(ret[1], (3, 5))
        self.assertEqual(ret[7], (1, 4))
        self.assertEqual(ret[30], (0, 1))


class CliTest(unittest.TestCase):
    def run_main(self, *argv) -> str:
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf), contextlib.redirect_stderr(io.StringIO()):
            rf.main(list(argv))
        return buf.getvalue()

    def test_rate_parser(self):
        for text in ("0.25", "0,25", "25%", "25"):
            self.assertAlmostEqual(rf.rate(text), 0.25)

    def test_scenarios(self):
        out = self.run_main("scenarios", "--d1", "28%", "--d7", "7%")
        for name in ("slaba", "prosječna", "dobra", "tvoja"):
            self.assertIn(f"| {name} |", out)

    def test_forecast_writes_csv(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "dau.csv")
            out = self.run_main("forecast", "--d1", "0.25", "--d7", "0.06", "--launch", "200",
                                "--days", "40", "--csv", path)
            with open(path, encoding="utf-8") as f:
                self.assertEqual(len(f.read().splitlines()), 41)
        self.assertIn("DAU po danu", out)
        self.assertIn("| 39 |", out)

    def test_cohort_with_forecast(self):
        out = self.run_main("cohort", "--csv", os.path.join(HERE, "testeri-primjer.csv"),
                            "--today", "2026-11-20", "--forecast", "--installs", "20", "--days", "90")
        self.assertIn("| D1 | 3/5 |", out)
        self.assertIn("Prognoza s izmjerenim D1/D7", out)
        self.assertIn("Izmjereno vs kriva", out)


if __name__ == "__main__":
    unittest.main()
