@tool
class_name Holidays extends RefCounted
# WARNING: WIP, NOT READY

enum HolidayType { FIXED_DATE, EASTER_RELATIVE, SOLSTICE }

const HOLIDAYS: Dictionary[StringName, Dictionary] = {
	# Fixed dates (month: int 0-11, day: int 1-31)
	&"New Year's Day": { type = HolidayType.FIXED_DATE, month = DateTime.Month.JANUARY, day = 1 },
	&"Valentine's Day": { type = HolidayType.FIXED_DATE, month = DateTime.Month.FEBRUARY, day = 14 },
	&"St. Patrick's Day": { type = HolidayType.FIXED_DATE, month = DateTime.Month.MARCH, day = 17 },
	&"April Fools' Day": { type = HolidayType.FIXED_DATE, month = DateTime.Month.APRIL, day = 1 },
	&"Mother's Day": { type = HolidayType.FIXED_DATE, month = DateTime.Month.MAY, day = 12 },  # 2nd Sunday
	&"Memorial Day": { type = HolidayType.FIXED_DATE, month = DateTime.Month.MAY, day = 27 },  # Last Monday
	&"Father's Day": { type = HolidayType.FIXED_DATE, month = DateTime.Month.JUNE, day = 16 },  # 3rd Sunday
	&"Independence Day": { type = HolidayType.FIXED_DATE, month = DateTime.Month.JULY, day = 4 },
	&"Halloween": { type = HolidayType.FIXED_DATE, month = DateTime.Month.OCTOBER, day = 31 },
	&"Veterans Day": { type = HolidayType.FIXED_DATE, month = DateTime.Month.NOVEMBER, day = 11 },
	&"Thanksgiving": { type = HolidayType.FIXED_DATE, month = DateTime.Month.NOVEMBER, day = 22 },  # 4th Thursday
	&"Christmas": { type = HolidayType.FIXED_DATE, month = DateTime.Month.DECEMBER, day = 25 },
	&"New Year's Eve": { type = HolidayType.FIXED_DATE, month = DateTime.Month.DECEMBER, day = 31 },
	
	# Easter relative (computed)
	&"Easter Sunday": { type = HolidayType.EASTER_RELATIVE, offset_days = 0 },
	&"Good Friday": { type = HolidayType.EASTER_RELATIVE, offset_days = -2 },
	
	# Solstice/Equinox (approx fixed, but could compute astronomically)
	&"Spring Equinox": { type = HolidayType.FIXED_DATE, month = DateTime.Month.MARCH, day = 20 },
	&"Summer Solstice": { type = HolidayType.FIXED_DATE, month = DateTime.Month.JUNE, day = 21 },
	&"Autumn Equinox": { type = HolidayType.FIXED_DATE, month = DateTime.Month.SEPTEMBER, day = 22 },
	&"Winter Solstice": { type = HolidayType.FIXED_DATE, month = DateTime.Month.DECEMBER, day = 21 },
}

## Check if a DateTime is a holiday.
static func is_holiday(dt: DateTime) -> bool:
	for name in HOLIDAYS:
		if _matches_holiday(dt, name):
			return true
	return false

## Get holiday name for a DateTime, or empty if none.
static func get_holiday(dt: DateTime) -> StringName:
	for name in HOLIDAYS:
		if _matches_holiday(dt, name):
			return name
	return ""

## Get all holidays in a year as Array[DateTime].
static func get_holidays_in_year(y: int) -> Array[DateTime]:
	var holidays: Array[DateTime] = []
	for name in HOLIDAYS:
		var h := _compute_holiday_date(y, name)
		if h and h.year == y:
			holidays.append(h)
	holidays.sort_custom(func(a, b): return a.total_milliseconds < b.total_milliseconds)
	return holidays

## Compute DateTime for a specific holiday in year y.
static func _compute_holiday_date(y: int, holiday_name: String) -> DateTime:
	if not holiday_name in HOLIDAYS:
		return null
	var hdata := HOLIDAYS[holiday_name]
	var dt := DateTime.new()
	dt.year = y
	
	match hdata.type:
		HolidayType.FIXED_DATE:
			dt.month = hdata.month
			dt.day_of_month = hdata.day
			if holiday_name == &"Memorial Day":
				dt.advance_to_month(hdata.month)
				dt.advance_to_weekday(DateTime.Weekday.MONDAY)
				dt.advance_to_day_of_month(31)
				while dt.day_of_month > 25:  # Last Monday in May
					dt.advance_to_previous_day()
			elif holiday_name in [&"Mother's Day", &"Father's Day"]:
				var sunday_offset := 2 if holiday_name == &"Mother's Day" else 3
				dt.advance_to_month(hdata.month)
				dt.advance_to_weekday(DateTime.Weekday.SUNDAY)
				dt.advance_to_day_of_month(1)
				for i in sunday_offset:
					dt.advance_to_next_week()
			elif holiday_name == &"Thanksgiving":
				dt.advance_to_month(hdata.month)
				dt.advance_to_weekday(DateTime.Weekday.THURSDAY)
				dt.advance_to_day_of_month(22)  # 4th Thu is 22-28
				while dt.day_of_month < 22:
					dt.advance_to_next_week()
			dt.advance_to_day_of_month(hdata.day)  # Reset time to start of day
		HolidayType.EASTER_RELATIVE:
			var easter := compute_easter_date(y)
			if easter:
				easter.advance({ days = hdata.offset_days })
				return easter
		_:
			pass
	
	return dt

## Gauss's Easter algorithm (simplified for Gregorian).
static func compute_easter_date(y: int) -> DateTime:
	var a := y % 19
	var b := y / 100
	var c := y % 100
	var d := b / 4
	var e := b % 4
	var f := (b + 8) / 25
	var g := (b - f + 1) / 3
	var h := (19 * a + b - d - g + 15) % 30
	var i := c / 4
	var k := c % 4
	var l := (32 + 2 * e + 2 * i - h - k) % 7
	var m := (a + 11 * h + 22 * l) / 451
	var month := (h + l - 7 * m + 114) / 31
	var day := ((h + l - 7 * m + 114) % 31) + 1
	
	var dt := DateTime.new()
	dt.year = y
	dt.month = month
	dt.day_of_month = day
	return dt

## Check if dt matches a holiday (for fixed/movable).
static func _matches_holiday(dt: DateTime, holiday_name: String) -> bool:
	var hdate := _compute_holiday_date(dt.year, holiday_name)
	return hdate and hdate.is_now(dt)
