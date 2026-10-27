## Lokalni brojač aktivnosti (RET-01, 2026-10-26) — dani igranja od prvog pokretanja, sesije,
## vrijeme igre, runovi, najdalji level, dan tutorijala / Endlessa i prvi merge. Radi i u release
## buildu (closed test ide preko Play Storea), ali ništa ne šalje: tester sam pošalje screenshot ili Copy
## red sa skrivenog ekrana (Settings → 5 dodira na verziju). Strategija i format reda:
## docs/06-production/procjena-igraca.md, kalkulator scripts/analytics/retention_forecast.py.
##
## Dan = razlika LOKALNIH datuma (isti ključ kao dnevni poklon, GameState._today_key), pa ponoć,
## putovanje kroz vremenske zone i sat vraćen unazad ne prave duple ni negativne dane.
## Vrijeme se daje izvana (today, now) — GUT test vrti dane i sat bez čekanja.
class_name ActivityLog
extends RefCounted

const SAVE_KEY := "activity"
const FORMAT := 1
## Dani 0…30 imaju svoj unos (D30 je zadnji standardni dan retencije); poslije toga samo broj.
const TRACKED_DAYS := 31
## Povratak iz pozadine poslije ovoliko sekundi je nova sesija.
const SESSION_GAP_SEC := 300
## Najviše sekundi igre po jednom ticku — skok sata ili uspavan telefon bez pauze ne smiju
## upisati sate igre.
const MAX_TICK_SEC := 90
## GameState tick (Timer); mora biti ispod MAX_TICK_SEC da se obična igra ne reže.
const TICK_SEC := 30.0
const CSV_TAG := "mm1"
const CSV_HEADER := "mm1,version,first_day,days,sessions,minutes,runs,season,level,tut_day,end_day,merge_sec,late_days,last_day"

var first_day: String = ""
## Od kog dana brojač zna — stari save (prije RET-01) ne zna šta je bilo ranije.
var since: int = 0
## dan (0…30) → {s, sec, r, lv, se}
var days: Dictionary = {}
var late_days: int = 0
var last_day: int = -1
var total_sessions: int = 0
var total_sec: int = 0
var total_runs: int = 0
var tutorial_day: int = -1
var endless_day: int = -1
## Sekunde igre do prvog mergea (KPI prvog iskustva: < 4 min).
var first_merge_sec: int = -1
var best_season: String = ""
## Pređenih levela u najdaljoj besplatnoj sezoni (0…20).
var best_level: int = 0

## Unix zadnjeg ticka; 0 = ne broji (pozadina ili još nije počelo).
var _last_tick: int = 0
var _background_since: int = 0


## Headless (testovi, simulator, alati) ne broji — dev save ostaje čist, GUT zove metode direktno.
static func enabled() -> bool:
	return DisplayServer.get_name() != "headless"


## "YYYY-MM-DD" → redni broj dana (UTC ponoć tog datuma / 86400); -1 kad ključ ne valja.
static func day_number(key: String) -> int:
	var parts := key.split("-")
	if parts.size() != 3 or not parts[0].is_valid_int() or not parts[1].is_valid_int() \
			or not parts[2].is_valid_int():
		return -1
	var month := int(parts[1])
	var day := int(parts[2])
	if month < 1 or month > 12 or day < 1 or day > 31:
		return -1
	var unix := Time.get_unix_time_from_datetime_dict({
		"year": int(parts[0]), "month": month, "day": day, "hour": 0, "minute": 0, "second": 0,
	})
	return int(floorf(float(unix) / 86400.0))


## Lokalni datum za unix vrijeme (stari save zna samo first_launch_unix).
static func local_day_key(unix: int) -> String:
	var bias := int(Time.get_time_zone_from_system().get("bias", 0))
	var d := Time.get_date_dict_from_unix_time(unix + bias * 60)
	return "%04d-%02d-%02d" % [int(d.year), int(d.month), int(d.day)]


func reset() -> void:
	first_day = ""
	since = 0
	days.clear()
	late_days = 0
	last_day = -1
	total_sessions = 0
	total_sec = 0
	total_runs = 0
	tutorial_day = -1
	endless_day = -1
	first_merge_sec = -1
	best_season = ""
	best_level = 0
	_last_tick = 0
	_background_since = 0


## Dan od prvog pokretanja; -1 kad brojač još nije počeo ili je datum prije prvog dana.
func day_index(today: String) -> int:
	if first_day.is_empty():
		return -1
	var a := day_number(first_day)
	var b := day_number(today)
	if a < 0 or b < 0 or b < a:
		return -1
	return b - a


func played_on(day: int) -> bool:
	return days.has(day)


func is_known(day: int) -> bool:
	return day >= since


## Pokretanje igre (poslije učitavanja savea). Novi igrač počinje danas; stari save od danas.
func start(today: String, now: int, first_launch_unix: int) -> void:
	if first_day.is_empty() or day_number(first_day) < 0:
		_begin_log(today, first_launch_unix)
	_begin_session(today, now)


func pause(today: String, now: int) -> void:
	tick(today, now)
	_last_tick = 0
	_background_since = now


func resume(today: String, now: int) -> void:
	var away := now - _background_since
	# Sat vraćen unazad dok je igra u pozadini: ne zna se koliko je prošlo — nova sesija.
	if _background_since <= 0 or away >= SESSION_GAP_SEC or away < 0:
		_begin_session(today, now)
	else:
		_entry(today, true)
		_last_tick = now
	_background_since = 0


## Doda vrijeme igre od zadnjeg ticka (najviše MAX_TICK_SEC).
func tick(today: String, now: int) -> void:
	if _last_tick <= 0:
		return
	var delta := clampi(now - _last_tick, 0, MAX_TICK_SEC)
	_last_tick = now
	var e := _entry(today, true)
	total_sec += delta
	if not e.is_empty():
		e["sec"] = int(e.sec) + delta


## Kraj runa. `level` = odigrani level kampanje (0 = tutorijal, Endless = level puta sezone).
func note_run(today: String, now: int, level: int, season_id: String) -> void:
	tick(today, now)
	total_runs += 1
	var e := _entry(today, true)
	if e.is_empty():
		return
	e["r"] = int(e.r) + 1
	if level >= int(e.lv):
		e["lv"] = maxi(0, level)
		e["se"] = season_id


## Stanje napretka poslije runa: prvi dan tutorijala / Endlessa i najdalja besplatna sezona.
func note_progress(today: String, tutorial_done: bool, endless_open: bool,
		furthest_season: String, furthest_passed: int) -> void:
	var day := maxi(0, day_index(today))
	if tutorial_done and tutorial_day < 0:
		tutorial_day = day
	if endless_open and endless_day < 0:
		endless_day = day
	if not furthest_season.is_empty():
		if furthest_season != best_season or furthest_passed > best_level:
			best_season = furthest_season
			best_level = clampi(furthest_passed, 0, 99)


func note_merge(today: String, now: int) -> void:
	if first_merge_sec >= 0:
		return
	tick(today, now)
	first_merge_sec = total_sec


func days_played() -> int:
	return days.size() + late_days


## Za ekran statistike: sve što treba za jedan screenshot.
func snapshot(today: String) -> Dictionary:
	var today_day := day_index(today)
	return {
		"first_day": first_day,
		"today_day": today_day,
		"since": since,
		"days_played": days_played(),
		"days_total": today_day + 1 - since if today_day >= since else 0,
		"sessions": total_sessions,
		"minutes": roundi(float(total_sec) / 60.0),
		"runs": total_runs,
		"best_season": best_season,
		"best_level": best_level,
		"tutorial_day": tutorial_day,
		"endless_day": endless_day,
		"first_merge_sec": first_merge_sec,
		"late_days": late_days,
		"days": days_string(today),
	}


## 31 znak za dane 0…30: 1 igrao, 0 nije, - nepoznato (prije `since` ili još nije došao).
func days_string(today: String) -> String:
	var today_day := day_index(today)
	var out := ""
	for d in TRACKED_DAYS:
		if d < since or d > today_day:
			out += "-"
		elif days.has(d):
			out += "1"
		else:
			out += "0"
	return out


## Jedan red za kalkulator (scripts/analytics/retention_forecast.py cohort); zarezi iz imena
## sezone / verzije se uklone da red ostane CSV.
func csv_row(version: String, today: String) -> String:
	var cells := PackedStringArray([
		CSV_TAG, version.replace(",", " "), first_day, days_string(today),
		str(total_sessions), str(roundi(float(total_sec) / 60.0)), str(total_runs),
		best_season.replace(",", " "), str(best_level), str(tutorial_day), str(endless_day),
		str(first_merge_sec), str(late_days), str(last_day),
	])
	return ",".join(cells)


func to_save_dict() -> Dictionary:
	var rows: Array = []
	var keys := days.keys()
	keys.sort()
	for d in keys:
		var e: Dictionary = days[d]
		rows.append({"d": int(d), "s": int(e.s), "sec": int(e.sec), "r": int(e.r), "lv": int(e.lv), "se": str(e.se)})
	return {SAVE_KEY: {
		"v": FORMAT,
		"first_day": first_day,
		"since": since,
		"days": rows,
		"late_days": late_days,
		"last_day": last_day,
		"tot": {"s": total_sessions, "sec": total_sec, "r": total_runs},
		"tut_day": tutorial_day,
		"end_day": endless_day,
		"merge_sec": first_merge_sec,
		"best": {"se": best_season, "lv": best_level},
	}}


## Stari save bez ključa ili pokvaren ključ → prazan log (start() ga pokrene od danas).
func apply_from_save(data: Dictionary) -> void:
	reset()
	var raw: Variant = data.get(SAVE_KEY)
	if not raw is Dictionary:
		return
	var a: Dictionary = raw
	first_day = str(a.get("first_day", ""))
	if day_number(first_day) < 0:
		first_day = ""
		return
	since = maxi(0, _int(a.get("since", 0)))
	late_days = maxi(0, _int(a.get("late_days", 0)))
	last_day = maxi(-1, _int(a.get("last_day", -1)))
	var rows: Variant = a.get("days", [])
	if rows is Array:
		for row in rows:
			if not row is Dictionary:
				continue
			var d := _int((row as Dictionary).get("d", -1))
			if d < 0 or d >= TRACKED_DAYS:
				continue
			days[d] = {
				"s": maxi(0, _int(row.get("s", 0))),
				"sec": maxi(0, _int(row.get("sec", 0))),
				"r": maxi(0, _int(row.get("r", 0))),
				"lv": maxi(0, _int(row.get("lv", 0))),
				"se": str(row.get("se", "")),
			}
	var tot: Variant = a.get("tot", {})
	if tot is Dictionary:
		total_sessions = maxi(0, _int((tot as Dictionary).get("s", 0)))
		total_sec = maxi(0, _int(tot.get("sec", 0)))
		total_runs = maxi(0, _int(tot.get("r", 0)))
	tutorial_day = maxi(-1, _int(a.get("tut_day", -1)))
	endless_day = maxi(-1, _int(a.get("end_day", -1)))
	first_merge_sec = maxi(-1, _int(a.get("merge_sec", -1)))
	var best: Variant = a.get("best", {})
	if best is Dictionary:
		best_season = str((best as Dictionary).get("se", ""))
		best_level = clampi(_int(best.get("lv", 0)), 0, 99)


# --- unutra ------------------------------------------------------------------

func _begin_log(today: String, first_launch_unix: int) -> void:
	reset()
	first_day = today
	if first_launch_unix > 0:
		var legacy := local_day_key(first_launch_unix)
		var a := day_number(legacy)
		var b := day_number(today)
		# Save stariji od brojača: prvi dan ostaje pravi, raniji dani su nepoznati.
		if a >= 0 and b > a:
			first_day = legacy
			since = b - a


func _begin_session(today: String, now: int) -> void:
	total_sessions += 1
	var e := _entry(today, false)
	if not e.is_empty():
		e["s"] = int(e.s) + 1
	_last_tick = now


## Unos za današnji dan (prazan rječnik za dan 31+ ili datum prije prvog dana). Novi dan usred
## sesije (ponoć) dobija s = 1 kad `carry_session`.
func _entry(today: String, carry_session: bool) -> Dictionary:
	var day := day_index(today)
	if day < 0:
		return {}
	if day >= TRACKED_DAYS:
		if day > last_day:
			late_days += 1
			last_day = day
		return {}
	if not days.has(day):
		days[day] = {"s": 1 if carry_session else 0, "sec": 0, "r": 0, "lv": 0, "se": ""}
	last_day = maxi(last_day, day)
	return days[day]


static func _int(v: Variant) -> int:
	if v is int or v is float:
		return int(v)
	if v is String and (v as String).is_valid_int():
		return int(v)
	return 0
