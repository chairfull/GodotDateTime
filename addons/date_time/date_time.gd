@tool
class_name DateTime
extends Resource
## Godot's built in Time class starts Months and Weekdays at 1, while this starts at 0.
## So be careful combining the two.

enum Weekday { SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY }
enum Month { JANUARY, FEBRUARY, MARCH, APRIL, MAY, JUNE, JULY, AUGUST, SEPTEMBER, OCTOBER, NOVEMBER, DECEMBER }
enum Period { DAWN, MORNING, DAY, DUSK, EVENING, NIGHT }
enum Season { SPRING, SUMMER, AUTUMN, WINTER }
enum Planet { SUN, MOON, MARS, MERCURY, JUPITER, VENUS, SATURN }
enum Horoscope { ARIES, TAURUS, GEMINI, CANCER, LEO, VIRGO, LIBRA, SCORPIUS, SAGITARIUS, CAPRICORN, AQUARIUS, PISCES, OPHIUCHUS }
enum Zodiac { RAT, OX, TIGER, RABBIT, DRAGON, SNAKE, HORSE, GOAT, MONKEY, ROOSTER, DOG, PIG }
enum Relation { PAST, PRESENT, FUTURE }
enum Epoch { SECOND, MINUTE, HOUR, DAY, WEEK, MONTH, YEAR, DECADE, CENTURY }
enum Meridiem { AM, PM }

const WEEKEND := [ Weekday.SATURDAY, Weekday.SUNDAY ]

# These are the only true properties that should be serialized.
# Everything else is a helper for these.
# Though total_seconds is the smallest way to serialize.
const PROPERTIES := [&"years", &"days", &"hours", &"minutes", &"seconds"]

const DAYS_IN_YEAR := 365
const DAYS_IN_SEASON := 91
const DAYS_IN_WEEK := 7
const HOURS_IN_DAY := 24
const HOURS_IN_YEAR := HOURS_IN_DAY * 365 # 8_760
const MINUTES_IN_HOUR := 60
const MINUTES_IN_DAY := MINUTES_IN_HOUR * HOURS_IN_DAY # 1_440
const MINUTES_IN_YEAR := MINUTES_IN_DAY * 365 # 525_600
const SECONDS_IN_MINUTE := 60
const SECONDS_IN_HOUR := SECONDS_IN_MINUTE * MINUTES_IN_HOUR # 3_600
const SECONDS_IN_PERIOD := SECONDS_IN_HOUR * 4 # 14_400
const SECONDS_IN_DAY := SECONDS_IN_MINUTE * MINUTES_IN_HOUR * HOURS_IN_DAY # 86_400
const SECONDS_IN_WEEK := SECONDS_IN_DAY * DAYS_IN_WEEK # 604_800
const SECONDS_IN_MONTH := SECONDS_IN_DAY * 30 # 2_592_000
const SECONDS_IN_YEAR := SECONDS_IN_MINUTE * MINUTES_IN_HOUR * HOURS_IN_DAY * DAYS_IN_YEAR # 31_540_000
const SECONDS_IN_DECADE := SECONDS_IN_YEAR * 10
const SECONDS_IN_CENTURY := SECONDS_IN_YEAR * 100

const DAYS_IN_MONTH := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
const DAYS_UNTIL_MONTH := [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]

const EPOCH_SECONDS := {
	Epoch.CENTURY: SECONDS_IN_CENTURY,
	Epoch.DECADE: SECONDS_IN_DECADE,
	Epoch.YEAR: SECONDS_IN_YEAR,
	Epoch.MONTH: SECONDS_IN_MONTH,
	Epoch.WEEK: SECONDS_IN_WEEK,
	Epoch.DAY: SECONDS_IN_DAY,
	Epoch.HOUR: SECONDS_IN_HOUR,
	Epoch.MINUTE: SECONDS_IN_MINUTE,
	Epoch.SECOND: 1,
}

const HOROSCOPE_UNICODE := [0x2648, 0x2649, 0x264A, 0x264B, 0x264C, 0x264D, 0x264E, 0x264F, 0x2650, 0x2651, 0x2652, 0x2653, 0x26CE]
const ANIMAL_UNICODE := ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
const ANIMAL_EMOJI := "🐀🐂🐅🐇🐉🐍🐎🐐🐒🐓🐕🐖"

@export var years := 0: set=set_years
@export_range(0, 365) var days := 0: set=set_days
@export_range(0, 24) var hours := 0: set=set_hours
@export_range(0, 60) var minutes := 0: set=set_minutes
@export_range(0, 60) var seconds := 0: set=set_seconds

var total_seconds: int: get=get_total_seconds, set=set_total_seconds
## Ante meridiem. Post meridiem.
var ampm: Meridiem: get=get_ampm, set=advance_to_ampm
var daytime: bool: get=is_daytime, set=advance_to_daytime
var nighttime: bool: get=is_nighttime, set=advance_to_nighttime
var period_name: String: get=get_period_name, set=advance_to_period_named
var period: Period: get=get_period, set=advance_to_period
var weekend: bool: get=is_weekend, set=advance_to_weekend
var weekday: Weekday: get=get_weekday, set=advance_to_weekday
var weekday_name: String: get=get_weekday_name, set=advance_to_weekday_named
var day_of_month: int: get=get_day_of_month, set=advance_to_day_of_month
var day_of_month_ordinal: String: get=get_day_of_month_ordinal, set=advance_to_day_of_month_ordinal
var months: int: get=get_months, set=set_months
var month: Month: get=get_month, set=advance_to_month
var month_name: String: get=get_month_name, set=advance_to_month_named
var date: String: get=get_date, set=set_date
var season: Season: get=get_season, set=advance_to_season
var season_name: String: get=get_season_name, set=advance_to_season_named
var year: int: get=get_year, set=set_year

func _init(input: Variant = null):
	init(input)

func init(input: Variant):
	match typeof(input):
		TYPE_INT:
			total_seconds = input
		
		TYPE_DICTIONARY:
			for key in input:
				self[key] = input[key]
		
		TYPE_OBJECT:
			if input is DateTime:
				copy(input)
		
		TYPE_STRING_NAME:
			if input in Season.keys():
				season_name = input
			elif input in Month.keys():
				month_name = input
			elif input in Weekday.keys():
				weekday_name = input
			elif input in Period.keys():
				period_name = input
			else:
				push_error("Unkown StringName: %s." % input)
		
		TYPE_STRING:
			set_date(input)

func set_years(y: int):
	years = y
	_flag_changed()

func set_days(d: int):
	var add_years := d / DAYS_IN_YEAR
	days = wrapi(d, 0, DAYS_IN_YEAR)
	if add_years:
		years += add_years
	_flag_changed()

func set_hours(h: int):
	var add_days := h / HOURS_IN_DAY
	hours = wrapi(h, 0, HOURS_IN_DAY)
	if add_days:
		days += add_days
	_flag_changed()

func set_minutes(m: int):
	var add_hours := m / MINUTES_IN_HOUR
	minutes = wrapi(m, 0, MINUTES_IN_HOUR)
	if add_hours:
		hours += add_hours
	_flag_changed()

func set_seconds(s: int):
	var add_minutes := s / SECONDS_IN_MINUTE
	seconds = wrapi(s, 0, SECONDS_IN_MINUTE)
	if add_minutes:
		minutes += add_minutes
	_flag_changed()

## Trick to prevent multiple calls to the signal.
func _flag_changed():
	if not has_meta(&"changed"):
		set_meta(&"changed", true)
		_changed.call_deferred()
		changed.emit.call_deferred()
		remove_meta.call_deferred(&"changed")

## Will only be called once at the end of the tick.
func _changed():
	pass

func reset():
	for prop in PROPERTIES:
		self[prop] = 0

func copy(dt: DateTime):
	for prop in PROPERTIES:
		self[prop] = dt[prop]

func get_total_seconds() -> int:
	return seconds +\
			(minutes * SECONDS_IN_MINUTE) +\
			(hours * SECONDS_IN_HOUR) +\
			(days * SECONDS_IN_DAY) +\
			(years * SECONDS_IN_YEAR)

func set_total_seconds(s: int):
	reset()
	seconds = s

func get_total_minutes() -> int:
	return minutes +\
			(hours * MINUTES_IN_HOUR) +\
			(days * MINUTES_IN_DAY) +\
			(years * MINUTES_IN_YEAR)

func get_seconds_until_next_minute() -> int:
	return SECONDS_IN_MINUTE - seconds

## Advances to the start of the next minute.
func advance_to_next_minute():
	seconds += get_seconds_until_next_minute()

func get_total_hours() -> int:
	return hours +\
			(days * HOURS_IN_DAY) +\
			(years * HOURS_IN_YEAR)

func get_seconds_until_next_hour() -> int:
	return SECONDS_IN_HOUR - minutes * SECONDS_IN_MINUTE

## Advances to the start of the next hour.
func advance_to_next_hour():
	seconds += get_seconds_until_next_hour()

func get_ampm() -> Meridiem:
	return Meridiem.AM if hours < 12 else Meridiem.PM

func advance_to_ampm(m: Meridiem):
	for i in 12:
		if ampm != m:
			advance_to_next_hour()

func is_am() -> bool:
	return ampm == Meridiem.AM

func is_pm() -> bool:
	return ampm == Meridiem.PM

func is_daytime() -> bool:
	return hours >= 5 and hours <= 16

func advance_to_daytime(dt: bool = true):
	for i in 12:
		if daytime != dt:
			advance_to_next_hour()
		else:
			break

func is_nighttime() -> bool:
	return not is_daytime()

func advance_to_nighttime(nt: bool = true):
	advance_to_daytime(not nt)

## 0-1 float that can be used for a day night cycle.
func get_day_delta() -> float:
	return get_seconds_into_day() / float(SECONDS_IN_DAY)

func is_weekend() -> bool:
	return weekday in WEEKEND

## False will advance to monday.
func advance_to_weekend(w := true):
	for i in 12:
		if weekend == w:
			break
		advance_to_next_day()

func get_total_days() -> int:
	return days +\
			(years * DAYS_IN_YEAR)

func get_seconds_into_day() -> int:
	return seconds +\
			(minutes * SECONDS_IN_MINUTE) +\
			(hours * SECONDS_IN_HOUR)

func get_seconds_until_next_day() -> int:
	return SECONDS_IN_DAY - get_seconds_into_day()

func get_days_until_weekend() -> int:
	var d := weekday
	for i in 7:
		if wrapi(d+i, 0, 7) in WEEKEND:
			return i
	return 7

## Advance to the start of the next day.
func advance_to_next_day():
	seconds += get_seconds_until_next_day()

func get_days_until(other: DateTime) -> int:
	return other.get_total_days() - get_total_days()

func get_seconds_until_next_week() -> int:
	return SECONDS_IN_WEEK - get_seconds_into_week()

func get_seconds_into_week() -> int:
	return weekday * SECONDS_IN_DAY

func get_weekday_planet() -> Planet:
	return Planet.keys()[weekday]

func get_weekday_name() -> String:
	return Weekday.keys()[weekday]
	
func advance_to_weekday_named(wd: String):
	var index := Weekday.keys().find(wd)
	if index == -1:
		push_error("No weekday: %s" % wd)
	else:
		advance_to_weekday(index as Weekday)

func get_weekday() -> Weekday:
	# Zeller's congruence.
	var m := month - 1
	var y := years
	var d := day_of_month
	
	if m < 1:
		m += 12
		y -= 1
	
	var z = 13 * m - 1
	z = int(z / 5)
	z += d
	z += y
	z += int(y / 4)
	return wrapi(z - 1, 0, 7)

func advance_to_weekday(w: Weekday):
	for i in len(Weekday):
		if weekday == w:
			break
		advance_to_next_day()

## Advance to the start of the next week.
## Can also set: weekend = false
func advance_to_next_week():
	seconds += get_seconds_until_next_week()

func get_day_of_month() -> int:
	return days - _days_until_month(years, month) + 1

func advance_to_day_of_month(d: int):
	var y := years
	days = _days_until_month(y, month) + d - 1
	years = y

func get_day_of_month_ordinal() -> String:
	return ordinal(day_of_month)
	
func advance_to_day_of_month_ordinal(s: String):
	var num := ""
	for c in s:
		if c in "1234567890":
			num += c
		else:
			break
	day_of_month = num.to_int()

func get_months() -> int:
	return years * 12 + month

func set_months(m):
	month = wrapi(m, 0, 12)
	years = m / 12

func get_month_name() -> String:
	return Month.keys()[month]

func advance_to_month_named(m: String):
	var index = get_month_from_str(m)
	if index == -1:
		push_error("No month: %s." % m)
	else:
		advance_to_month(index as Month)

func get_month() -> Month:
	for i in range(11, -1, -1):
		if days >= _days_until_month(years, i):
			return i
	return -1

## Advance to the start of the next month.
func advance_to_month(m: Month):
	var d := day_of_month
	for i in 12:
		if month == m:
			break
		advance_to_next_month()
	day_of_month = d

func advance_to_next_month():
	seconds += get_seconds_until_next_month()

func get_seconds_until_next_month() -> int:
	var m: int = month
	var days_until := DAYS_IN_YEAR if m == Month.DECEMBER else _days_until_month(years, m+1)
	return (days_until - days) * SECONDS_IN_DAY

func get_months_until(other: DateTime) -> int:
	var dummy: DateTime = duplicate()
	var m := 0
	for i in 12:
		if dummy.month != other.month:
			m += 1
			dummy.next_month()
		else:
			break
	return m

func get_date() -> String:
	return "%s %s" % [month, day_of_month]
	
func set_date(s: String):
	var p := s.split(" ", false)
	# First part is month.
	if len(p) > 0:
		month_name = p[0]
	# Second part is day.
	if len(p) > 1:
		day_of_month_ordinal = p[1]
	# Optional third part is year.
	if len(p) > 2:
		years = p[2].to_int()

func get_months_until_date(m: String, _d := 1) -> int:
	# TODO: Take _d into account.
	var dummy: DateTime = duplicate()
	var mon := 0
	for i in len(Month):
		if dummy.month_name != m:
			dummy.next_month()
			mon += 1
		else:
			break
	return mon

func get_days_until_date(m: String, d := 1) -> int:
	return get_seconds_until_date(m, d) / SECONDS_IN_DAY

func get_seconds_until_date(m: String, d := 1) -> int:
	var dummy: DateTime = duplicate()
	var last_seconds := dummy.total_seconds
	dummy.month_name = m
	dummy.day_of_month = d
	return dummy.total_seconds - last_seconds

func get_period() -> Period:
	return (wrapi(hours-1, 0, 24) * len(Period)) / 24

func advance_to_period(p: Period):
	for i in len(Period):
		if period != p:
			advance_to_next_period()

func get_seconds_until_next_period() -> int:
	var p := period
	var next = SECONDS_IN_PERIOD * (p + 1)
	var curr = SECONDS_IN_PERIOD * p
	return next - curr

func get_period_name() -> String:
	return Period.keys()[period]

func advance_to_period_named(p: String):
	var index := Period.keys().find(p)
	if index == -1:
		push_error("No period: %s." % p)
	else:
		advance_to_period(index as Period)

func advance_to_next_period():
	seconds += get_seconds_until_next_period()

func get_seconds_until_next_season() -> int:
	var s := season
	var next = SECONDS_IN_DAY * DAYS_IN_SEASON * (s + 1)
	return next - SECONDS_IN_DAY * DAYS_IN_SEASON * s

func get_season() -> Season:
	return wrapi(month - 2, 0, 12) / 3

func advance_to_season(s: Season):
	for i in len(Season):
		if season == s:
			break
		advance_to_next_season()

func get_season_name() -> String:
	return Season.keys()[season]
	
func advance_to_season_named(s: String):
	var index := Season.keys().find(s)
	if index != -1:
		advance_to_season(index as Season)
	else:
		push_error("No season: %s" % s)

func advance_to_next_season():
	seconds += get_seconds_until_next_season()

func get_year() -> int:
	return years

func set_year(y: int):
	years = y

func get_year_delta() -> float:
	return get_seconds_into_year() / float(SECONDS_IN_YEAR)

func get_seconds_into_year() -> int:
	return get_seconds_into_day() + (days * SECONDS_IN_DAY)

func get_seconds_until_next_year() -> int:
	return SECONDS_IN_YEAR - get_seconds_into_year()

func advance_to_next_year():
	seconds += get_seconds_until_next_year()

# TODO:
func format(f := "{year} {month_short_capitalized} {day_of_month_ordinal}") -> String:
	return f.format(self)

func difference(other: DateTime) -> DateTime:
	return DateTime.new(abs(total_seconds - other.total_seconds))

## Does this occur at the same time?
func is_now(other: DateTime) -> bool:
	return total_seconds == other.total_seconds

## Is this DateTime occuring before another?
func is_before(other: DateTime) -> bool:
	return total_seconds < other.total_seconds

## Is this DateTime occuring after another?
func is_after(other: DateTime) -> bool:
	return total_seconds > other.total_seconds

## Is other date in the past, future, or presenet.
func get_relation(other: DateTime = create_from_current()) -> Relation:
	var t1 := total_seconds
	var t2 := other.total_seconds
	if t1 > t2:
		return Relation.PAST
	elif t1 < t2:
		return Relation.FUTURE
	else:
		return Relation.PRESENT

## Time until this DateTime.
func get_relation_difference_string(other: DateTime) -> String:
	var r := get_relation_difference(other)
	var epo_name: String = Epoch.keys()[r[1]]
	var epochs: int = r[2]
	match r[0]:
		Relation.PRESENT: return "Now"
		Relation.PAST: return "%s %s%s ago" % [epochs, epo_name.to_lower(), "" if epochs==1 else "s"]
		Relation.FUTURE: return "in %s %s%s" % [epochs, epo_name.to_lower(), "" if epochs==1 else "s"]
	push_error("Shouldn't happen.")
	return "???"

## Returns: [Relation, Maximum Epoch Type, Total of Maximum Epochs Type]
func get_relation_difference(other: DateTime) -> Array:
	var t1 := total_seconds
	var t2 = other.total_seconds
	
	# Now?
	if t1 == t2:
		return [Relation.PRESENT, Epoch.SECOND, 0]
	
	var rel: Relation = Relation.PAST if t2 < t1 else Relation.FUTURE
	var dif := absi(t1 - t2)
	for k in EPOCH_SECONDS:
		if dif >= EPOCH_SECONDS[k]:
			return [rel, k, dif / EPOCH_SECONDS[k]]
	
	return []

func get_horoscope() -> Horoscope:
	const c := [[9, 19, 10], [10, 18, 11], [11, 20, 0], [0, 19, 1], [1, 20, 2], [2, 20, 3], [3, 22, 4], [4, 22, 5], [5, 22, 6], [6, 22, 7], [7, 21, 8], [8, 21, 9]]
	var h = c[month]
	return h[0] if day_of_month <= h[1] else h[2]

func get_horoscope_unicode() -> String:
	return char(HOROSCOPE_UNICODE[get_horoscope()])

func get_horoscope_name() -> String:
	return Horoscope.keys()[get_horoscope()]

func get_zodiac() -> Zodiac:
	return wrapi(years - 4, 0, 12) # int(floor(fposmod(z, 12)))

func get_zodiac_name() -> String:
	return Zodiac.keys()[get_zodiac()]

func get_zodiac_unicode() -> String:
	return ANIMAL_UNICODE[get_zodiac()]

func get_zodiac_emoji() -> String:
	return ANIMAL_EMOJI[get_zodiac()]

## Advance any number of properties by an amount.
func _advance(properties := {}):
	for prop in properties:
		self[prop] += properties[prop]

func _to_string() -> String:
	return "DateTime(years:%s, days:%s, hours:%s, minutes:%s, seconds:%s)" % [years, days, hours, minutes, seconds]

static func get_month_from_str(mon: String) -> Month:
	for i in 12:
		var mname: String = Month.keys()[i].to_lower()
		if mon.to_lower() == mname or mon.to_lower() == mname.substr(0, 3):
			return Month.values()[i]
	push_error("Can't find month %s." % [mon])
	return Month.JANUARY

static func _is_leap_year(y: int) -> bool:
	return y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)

static func _days_until_month(y: int, m: int) -> int:
	return DAYS_UNTIL_MONTH[m] + (1 if m == Month.FEBRUARY and _is_leap_year(y) else 0)

static func _days_in_month(y: int, m: int) -> int:
	return 29 if m == Month.FEBRUARY and _is_leap_year(y) else DAYS_IN_MONTH[m]

static func create_from_current() -> DateTime:
	return create_from_datetime(Time.get_datetime_dict_from_system())

static func create_from_datetime(d: Dictionary) -> DateTime:
	d.day = d.day - 1 + _days_until_month(d.year, d.month - 1)
	d.hour -= 1
	if "dst" in d and d.dst:
		var tz = Time.get_time_zone_from_system()
		d.minute = wrapi(d.minute + tz.bias, 0, MINUTES_IN_HOUR)
	
	var out := DateTime.new()
	out.years = d.year
	out.days = d.day
	out.hours = d.hour
	out.minutes = d.minute
	out.seconds = d.second
	return out

static func sort(list: Array, obj_property := "datetime", reverse := false, sort_on := "total_seconds"):
	if reverse:
		list.sort_custom(func(a, b): return a[obj_property][sort_on] > b[obj_property][sort_on])
	else:
		list.sort_custom(func(a, b): return a[obj_property][sort_on] < b[obj_property][sort_on])

static func ordinal(n: Variant, one := "%sst", two := "%snd", three := "%srd", other := "%sth") -> String:
	if n is String:
		n = n.to_int()
	var ord = {1: one, 2: two, 3: three}.get(n if n % 100 < 20 else n % 10, other)
	return ord % str(n) if "%s" in ord else ord
