@tool
class_name DateTime extends Resource
## WARNING: Godot's built in Time class starts Months and Weekdays at 1, while this starts at 0. So be careful combining the two.

enum Weekday { SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY }
enum Month { JANUARY, FEBRUARY, MARCH, APRIL, MAY, JUNE, JULY, AUGUST, SEPTEMBER, OCTOBER, NOVEMBER, DECEMBER }
enum Period { DAWN, MORNING, DAY, DUSK, EVENING, NIGHT }
enum Season { SPRING, SUMMER, AUTUMN, WINTER }
enum Planet { SUN, MOON, MARS, MERCURY, JUPITER, VENUS, SATURN }
enum Horoscope { ARIES, TAURUS, GEMINI, CANCER, LEO, VIRGO, LIBRA, SCORPIUS, SAGITARIUS, CAPRICORN, AQUARIUS, PISCES, OPHIUCHUS }
enum Zodiac { RAT, OX, TIGER, RABBIT, DRAGON, SNAKE, HORSE, GOAT, MONKEY, ROOSTER, DOG, PIG }
enum Relation { PAST, PRESENT, FUTURE }
enum Epoch { MILLISECOND, SECOND, MINUTE, HOUR, DAY, WEEK, MONTH, YEAR, DECADE, CENTURY }
enum Meridiem { AM, PM }

const WEEKEND := [ Weekday.SATURDAY, Weekday.SUNDAY ]

# These are the only true properties that should be serialized.
# Everything else is a helper for these.
# total_milliseconds is the best property to serialize.
const PROPERTIES := [ &"years", &"days", &"hours", &"minutes", &"seconds", &"milliseconds" ]

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
const SECONDS_IN_YEAR := SECONDS_IN_MINUTE * MINUTES_IN_HOUR * HOURS_IN_DAY * DAYS_IN_YEAR # 31_536_000
const SECONDS_IN_DECADE := SECONDS_IN_YEAR * 10 # 315_360_000
const SECONDS_IN_CENTURY := SECONDS_IN_YEAR * 100 # 3_153_600_000
const MILLISECONDS_IN_SECOND := 1000

const DAYS_IN_MONTH := [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]
const DAYS_UNTIL_MONTH := [ 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 ]

const EPOCH_MILLISECONDS := {
	Epoch.CENTURY: SECONDS_IN_CENTURY * MILLISECONDS_IN_SECOND,
	Epoch.DECADE: SECONDS_IN_DECADE * MILLISECONDS_IN_SECOND,
	Epoch.YEAR: SECONDS_IN_YEAR * MILLISECONDS_IN_SECOND,
	Epoch.MONTH: SECONDS_IN_MONTH * MILLISECONDS_IN_SECOND,
	Epoch.WEEK: SECONDS_IN_WEEK * MILLISECONDS_IN_SECOND,
	Epoch.DAY: SECONDS_IN_DAY * MILLISECONDS_IN_SECOND,
	Epoch.HOUR: SECONDS_IN_HOUR * MILLISECONDS_IN_SECOND,
	Epoch.MINUTE: SECONDS_IN_MINUTE * MILLISECONDS_IN_SECOND,
	Epoch.SECOND: MILLISECONDS_IN_SECOND,
	Epoch.MILLISECOND: 1
}

const HOROSCOPE_UNICODE := [0x2648, 0x2649, 0x264A, 0x264B, 0x264C, 0x264D, 0x264E, 0x264F, 0x2650, 0x2651, 0x2652, 0x2653, 0x26CE]
const ANIMAL_UNICODE := ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
const ANIMAL_EMOJI := "🐀🐂🐅🐇🐉🐍🐎🐐🐒🐓🐕🐖"

## Used by init() or get_formatted()
static var format_default := "%day_of_month_ordinal %month_name (%weekday_name), %year"
## Used when str(DateTime).
static var format_datetime_str := "DateTime(yr:%years dy:%days hr:%hours mn:%minutes sc:%seconds ml:%milliseconds)"
## An output with bbcode.
static var format_datetime_richstr := ""

@export var years := 0: set=set_years
@export_range(0, 365) var days := 0: set=set_days
@export_range(0, 24) var hours := 0: set=set_hours
@export_range(0, 60) var minutes := 0: set=set_minutes
@export_range(0, 60) var seconds := 0: set=set_seconds
@export_range(0, 1000) var milliseconds := 0: set=set_milliseconds

var total_milliseconds: int: get=get_total_milliseconds, set=set_total_milliseconds
var total_seconds: int: get=get_total_seconds, set=set_total_seconds
var ampm: Meridiem: get=get_ampm, set=advance_to_ampm ## Ante meridiem. Post meridiem.
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
		TYPE_NIL:
			pass
		
		TYPE_INT:
			total_milliseconds = input
		
		TYPE_FLOAT:
			push_warning("DateTime initialised with a float. Assuming Unix time.")
			set_from_unix_time(input)
		
		TYPE_DICTIONARY:
			set_from_dict(input)
		
		TYPE_OBJECT:
			if input is DateTime:
				copy(input)
			else:
				push_error("Can't init DateTime with object %s." % [input])
		
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
		
		_:
			push_error("Can't init DateTime with %s %s." % [type_string(typeof(input)), input])

func set_years(y: int):
	years = y
	changed.emit()

func set_days(d: int):
	var add_years := d / DAYS_IN_YEAR
	days = wrapi(d, 0, DAYS_IN_YEAR)
	if add_years:
		years += add_years
	changed.emit()

func set_hours(h: int):
	var add_days := h / HOURS_IN_DAY
	hours = wrapi(h, 0, HOURS_IN_DAY)
	if add_days:
		days += add_days
	changed.emit()

func set_minutes(m: int):
	var add_hours := m / MINUTES_IN_HOUR
	minutes = wrapi(m, 0, MINUTES_IN_HOUR)
	if add_hours:
		hours += add_hours
	changed.emit()

func set_seconds(s: int):
	var add_minutes := s / SECONDS_IN_MINUTE
	seconds = wrapi(s, 0, SECONDS_IN_MINUTE)
	if add_minutes:
		minutes += add_minutes
	changed.emit()

func set_milliseconds(s: int):
	var add_seconds := s / MILLISECONDS_IN_SECOND
	milliseconds = wrapi(s, 0, MILLISECONDS_IN_SECOND)
	if add_seconds:
		seconds += add_seconds
	changed.emit()

func reset():
	for prop in PROPERTIES:
		self[prop] = 0

func copy(dt: DateTime):
	for prop in PROPERTIES:
		self[prop] = dt[prop]

func get_total_milliseconds() -> int:
	return get_total_seconds() * MILLISECONDS_IN_SECOND +\
		milliseconds

func set_total_milliseconds(s: int):
	reset()
	milliseconds = s

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
	for key in Weekday.keys():
		if wd.to_lower() == key or wd.to_lower().substr(0, 3) == key:
			advance_to_weekday(Weekday[key])
			return true
	push_error("No weekday: %s." % wd)

func get_weekday() -> Weekday:
	# Sakamoto
	var t := [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
	var m := month
	var y := years
	if m < 2:
		y -= 1
	return (y + int(y/4) - int(y/100) + int(y/400) + t[m] + day_of_month) % 7
	# Zeller's congruence.
	#var m := month - 1
	#var y := years
	#var d := day_of_month
	#
	#if m < 1:
		#m += 12
		#y -= 1
	#
	#var z = 13 * m - 1
	#z = int(z / 5)
	#z += d
	#z += y
	#z += int(y / 4)
	#return wrapi(z - 1, 0, 7)

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
	for mname in Month.keys():
		if mname.to_lower() == m.to_lower() or mname.to_lower().substr(0, 3) == m.to_lower():
			advance_to_month(Month[mname])
			return
	push_error("No month: %s." % m)

func get_month() -> Month:
	for i in range(11, -1, -1):
		if days >= _days_until_month(years, i):
			return i
	return -1

## Advance to the start of the next month.
func advance_to_month(m: Month):
	for i in 12:
		if month == m:
			break
		advance_to_next_month()

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

# TODO: Remove and just use format()
func get_date() -> String:
	return "%s %s" % [month_name.capitalize(), day_of_month]

# TODO: Remove and just use format()
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

func difference(other: DateTime) -> DateTime:
	return DateTime.new(abs(total_milliseconds - other.total_milliseconds))

## Does this occur at the same time?
func is_now(other: DateTime) -> bool:
	return total_milliseconds == other.total_milliseconds

## Is this DateTime occuring before another?
func is_before(other: DateTime) -> bool:
	return total_milliseconds < other.total_milliseconds

## Is this DateTime occuring after another?
func is_after(other: DateTime) -> bool:
	return total_milliseconds > other.total_milliseconds

## Is other date in the past, future, or presenet.
func get_relation(other: DateTime = create_from_system()) -> Relation:
	var t1 := total_milliseconds
	var t2 := other.total_milliseconds
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
	var t1 := total_milliseconds
	var t2 = other.total_milliseconds
	
	# Now?
	if t1 == t2:
		return [Relation.PRESENT, Epoch.SECOND, 0]
	
	var rel: Relation = Relation.PAST if t2 < t1 else Relation.FUTURE
	var dif := absi(t1 - t2)
	for k in EPOCH_MILLISECONDS:
		if dif >= EPOCH_MILLISECONDS[k]:
			return [rel, k, dif / EPOCH_MILLISECONDS[k]]
	
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

## Safely advances any number of properties by modifying from highest # seconds to lowest.
func advance(dict := {}):
	var list := get_property_list()
	var modified: PackedStringArray
	for i in range(list.size()-1, -1, -1):
		var prop: Dictionary = list[i]
		if prop.name in dict and prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			if prop.type == TYPE_INT:
				self[prop.name] += dict[prop.name]
				modified.append(prop.name)
			elif prop.type == TYPE_STRING:
				self[prop.name] = dict[prop.name]
				modified.append(prop.name)
	for key in dict:
		if not key in modified:
			push_error("DateTime has no \"%s\". Couldn't set to %s." % [key, dict[key]])

func set_from_unix_time(u_secs: float):
	var secs := int(floor(u_secs))
	var ms   := int(round((u_secs - float(secs)) * 1000.0))
	var d := Time.get_datetime_dict_from_unix_time(secs)
	copy(DateTime.create_from_datetime(d))
	milliseconds += ms

## Safely sets any number of properties by modifying from highest # of seconds to lowest.
func set_from_dict(dict: Dictionary):
	var list := get_property_list()
	var modified: PackedStringArray
	for i in range(list.size()-1, -1, -1):
		var prop: Dictionary = list[i]
		if prop.name in dict and prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			self[prop.name] = dict[prop.name]
			modified.append(prop.name)
	for key in dict:
		if not key in modified:
			push_error("DateTime has no \"%s\". Couldn't set to %s." % [key, dict[key]])

func _to_string() -> String:
	return format(format_datetime_str)

func to_richstring() -> String:
	return format(format_datetime_richstr)

func to_dict() -> Dictionary[StringName, int]:
	var out: Dictionary[StringName, int]
	for prop in PROPERTIES:
		out[prop] = self[prop]
	return out

#region Formatting

func format(format_str: String = format_default) -> String:
	var i := 0
	var output := ""
	while i < format_str.length():
		if format_str[i] == "%":
			var j := i+1
			var tag := ""
			while j < format_str.length() and format_str[j].to_lower() in "_abcdefghijklmnopqrstuvwxyz":
				tag += format_str[j]
				j += 1
			output += _to_format(tag)
			i = j
		else:
			output += format_str[i]
			i += 1
	return output

func set_from_format(dt_str: String, format_str: String = format_default):
	var properties := _get_format_parts(dt_str, format_str)
	set_from_dict(properties)

func _tokenize_format(format_str: String) -> PackedStringArray:
	var tokens: PackedStringArray
	var i := 0
	while i < format_str.length():
		if format_str[i] == "%":
			# Collect token until non-letter (or end)
			var j := i + 1
			while j < format_str.length() and format_str[j].to_lower() in "abcdefghijklmnopqrstuvwxyz_":
				j += 1
			tokens.append(format_str.substr(i, j - i)) # include '%'
			i = j
		else:
			# Collect literal until next '%'
			var j := i
			while j < format_str.length() and format_str[j] != "%":
				j += 1
			tokens.append(format_str.substr(i, j - i))
			i = j
	return tokens

func _get_format_parts(text: String, format_str: String) -> Dictionary:
	var tokens := _tokenize_format(format_str)
	var output := {}
	var pos = 0
	for i in tokens.size():
		var tok = tokens[i]
		if tok.begins_with("%"):
			var key = tok.substr(1) # remove "%"
			var next_literal = ""
			if i+1 < tokens.size() and not tokens[i+1].begins_with("%"):
				next_literal = tokens[i+1]
			var end = text.length() if next_literal == "" else text.find(next_literal, pos)
			if end == -1:
				push_error("Format mismatch at " + key)
				return {}
			output[key] = _from_format(key, text.substr(pos, end - pos))
			pos = end
		else:
			if not text.substr(pos, tok.length()) == tok:
				push_error("Literal mismatch: " + tok)
				return {}
			pos += tok.length()
	return output

func _to_format(code: String) -> String:
	match code:
		"Y": return "%04d" % year # Year with century.
		"y": return "%02d" % (year % 100) # Year without century (00-99).
		"m": return "%02d" % (month + 1) # Month as a zero-padded number (01-12).
		"B": return month_name.capitalize() # Full month name.
		"b": return month_name.substr(0, 3).capitalize() # Abbreviated month name.
		"d": return "%02d" % day_of_month # Day of the month as a zero-padded number (01-31).
		"A": return weekday_name.capitalize() # Full weekday name.
		"a": return weekday_name.substr(0, 3).capitalize() # Abbreviated weekday name.
		"w": return str(weekday) # Weekday as a number (0-6, Sunday is 0).
		"H": return "%02d" % hours # Hour (24-hour clock) as a zero-padded number (00-23).
		"I": # Hour (12-hour clock) as a zero-padded number (01-12).
			var h12 = hours % 12
			if h12 == 0: h12 = 12
			return "%02d" % h12
		"p": return str(get_ampm()) # AM or PM.
		"M": return "%02d" % minutes # Minute as a zero-padded number (00-59).
		"S": return "%02d" % seconds # Second as a zero-padded number (00-59).
		#"f": return "%03d" % microseconds # TODO: Microseconds. Use %06d for microseconds.
		"j": return "%03d" % (days + 1) # Day of the year (001-366).
		"U": return "??_U" # TODO: Week number of the year (Sunday as the first day).
		"W": return "??_W" # TODO: Week number of the year (Monday as the first day).
		"c": return format("%a %b %d %H:%M:%S %Y") # Locale's appropriate date and time.
		"x": return format("%m/%d/%y") # Locale's date representation.
		"X": return format("%H:%M:%S") # Locale's time representation.
		"%": return "%" # A literal '%' character.
		_: return str(self[code]) if code in self else ("%" + code)

func _from_format(code: String, token: String) -> Variant:
	match code:
		"Y": return int(token) # Year with century.
		"y":  # Year without century (00-99).
			var yy = int(token)
			return (2000 + yy) if yy < 70 else (1900 + yy) # python-like cutoff
		"m": return int(token) - 1  # Month as a zero-padded number (01-12).
		"B": return token # Full month name.
		"b": return token # Abbreviated month name.
		"d": return int(token) # Day of the month as a zero-padded number (01-31).
		"A": return token # Full weekday name.
		"a": return token # Abbreviated weekday name.
		"w": return int(token) # Weekday as a number (0-6, Sunday is 0).
		"H": return int(token) # Hour (24-hour clock) as a zero-padded number (00-23).
		"I": return int(token) % 12  # Hour (12-hour clock) as a zero-padded number (01-12).
		"p": return token # AM or PM.
		"M": return int(token) # Minute as a zero-padded number (00-59).
		"S": return int(token) # Second as a zero-padded number (00-59).
		#"f": milliseconds = int(token) # TODO
		"j": return int(token) - 1 # Day of the year (001-366).
		#"U": return int(token), 0) # TODO: Sunday-start weeks
		#"W": return int(token), 1) # TODO: Monday-start weeks
		#"c": parse("%a %b %d %H:%M:%S %Y", token) # TODO: Locale's appropriate date and time.
		#"x": parse("%m/%d/%y", token) # TODO: Locale's date representation.
		#"X": parse("%H:%M:%S", token) # TODO: Locale's time representation.
		"%": return token # A literal '%' character.
		_: return convert(token, typeof(self[code])) if code in self else token

#endregion

## Can handle full "January" or first 3 letters "Jan".
#static func get_month_from_str(mon: String) -> Month:
	#for i in 12:
		#var mname: String = Month.keys()[i].to_lower()
		#if mon.to_lower() == mname or mon.to_lower() == mname.substr(0, 3):
			#return Month.values()[i]
	#push_error("Can't find month %s." % [mon])
	#return Month.JANUARY

static func _is_leap_year(y: int) -> bool:
	return y % 4 == 0 and (y % 100 != 0 or y % 400 == 0)

static func _days_until_month(y: int, m: int) -> int:
	return DAYS_UNTIL_MONTH[m] + (1 if m == Month.FEBRUARY and _is_leap_year(y) else 0)

static func _days_in_month(y: int, m: int) -> int:
	return 29 if m == Month.FEBRUARY and _is_leap_year(y) else DAYS_IN_MONTH[m]

static func create_from_system() -> DateTime:
	return create_from_datetime(Time.get_datetime_dict_from_system())

static func create_from_datetime(d: Dictionary) -> DateTime:
	d.day = d.day - 1 + _days_until_month(d.year, d.month - 1)
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

static func sort(list: Array[Array], obj_property := "datetime", reverse := false, sort_on := "total_milliseconds"):
	if reverse:
		list.sort_custom(func(a, b): return a[obj_property][sort_on] > b[obj_property][sort_on])
	else:
		list.sort_custom(func(a, b): return a[obj_property][sort_on] < b[obj_property][sort_on])

static func ordinal(n: Variant, one := "%sst", two := "%snd", three := "%srd", other := "%sth") -> String:
	if n is String:
		n = n.to_int()
	var ord = {1: one, 2: two, 3: three}.get(n if n % 100 < 20 else n % 10, other)
	return ord % str(n) if "%s" in ord else ord
