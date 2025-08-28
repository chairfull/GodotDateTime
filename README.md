# DateTime
`v1.2` Godot4.5dev+

`DateTime` and [`DateTimeline`](#datetimeline)

## DateTime Feature Overview
I can't remember all the features as this class was written over a number of years for various uses.

- Hours:
	- `is_am()` `is_pm()`
- Periods: `DAWN, MORNING, DAY, DUSK, EVENING, NIGHT`
	- `period_name`
- Days:
	- `is_daytime()` `is_nighttime()`
- Weeks:
	- `is_weekend()` `is_weekday()`
	- `weekend = true` easily advance to weekend or weekday by changing boolean.
	- `weekday_name` Can be set with 3 letters, any case: `weekday_name = "Tue"` `weekday_name = "sunday`
- Months:
	- `day_of_month`
	- `day_of_month_ordinal` returns as `1st` `22nd`. Can be set `day_of_month_ordinal = "25th"`.
	- `month_name` Can be set with 3 letter, any case: `month = "Dec"` `month = "december"`
- Advance Time:
	Along with calling `years += 1` `hours += 1` there are functions for advancing more precisley.
	- `advance_by_dict()`
	- `advance_to_next_minute()`
	- `advance_to_next_hour()`
	- `advance_to_period(Period)` `advance_to_next_period()`
	- `advance_to_weekday(Weekday)` `advance_to_next_day()` `advance_to_next_week()`
	- `advance_to_month(Month)` `advance_to_next_month()`
	- `advance_to_season(Season)` `advance_to_next_season()`
	- `advance_to_next_year()`
- [Formatting](#formatting): Python/Javascript style, or using property names.
	- `format("%year %month_name)`
	- `set_from_format("1991-12-01 00:00 (WED)", "%Y-%m-%d %H:%M (%a)")`
- Compare DateTimes:
	- `is_after(other)` other is in future?
	- `is_before(other)` other is in past?
	- `is_now(other)` other is now?
- Seasons: `SPRING, SUMMER, AUTUMN, WINTER`
	- `season_name`
- Horoscopes:
	- `get_horoscope_name()`
	- `get_horoscope_unicode()`
- Zodiac: 
	- `get_zodiac_name()`
	- `get_zodiac_unicode()`
	- `get_zodiac_emoji()`

## Setup
Currently `DateTime` can be initialised with:

- `Dictionary`: Properties. `DateTime.new({ month_name="December", day_of_month=25, year=1991 })`
- `String`: [formatted](#formatting) string. `DateTime.new("Dec 25th 1991 10:30PM")` (See `DateTime.format_default`)
- `int`: Total milliseconds. `DateTime.new(Time.get_ticks_msec())`
- `float`: Assumes Unix time. `DateTime.new(Time.get_unix_time_from_system())`
- `StringName`: [enum](#enum-overview). `DateTime.new(&"JANUARY")`
- `DateTime`: Properties to copy. `DateTime.new(character.birthday)`
- Nothing: Will just be `{years:0, days:0, hours:0, minutes:0, seconds:0, milliseconds: 0}`

## Formatting
These are `static var`s that can be overriden.

- `DateTime.format_default` used when calling `dt.format()`
- `DateTime.format_datetime_str` used when calling `str(dt)` or `dt.to_string()`

Format strings can include common tokens like `%y` `%B` and `%w` or property names like `%weekday_name` `%season_name`:

```gdscript
"Y": return "%04d" % year # Year with century.
"y": return "%02d" % (year % 100) # Year without century (00-99).
"m": return "%02d" % (month + 1) # Month as a zero-padded number (01-12).
"B": return month_name # Full month name.
"b": return month_name.substr(0, 3) # Abbreviated month name.
"d": return "%02d" % day_of_month # Day of the month as a zero-padded number (01-31).
"A": return weekday_name # Full weekday name.
"a": return weekday_name.substr(0, 3) # Abbreviated weekday name.
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
```

## Enum Overview
```gdscript
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
```

## Saving
While you can use `to_dir()` to get a dictionary, `get_total_milliseconds()` is probably the smallest for storage.

## DateTimeline
Meant as a calendar event system: You add events, advance time, and events fire as you go.

- Add events `add_event(date_in_future: Dictionary, event_data: Variant, relative: bool = true)`
- Advance time with `advance()` or by modifying `future`: `future.weekend = true` `future.days += 134`
- Call `catch_up()` to attempt to reach `future` time.
- If `stop_on_event == true` (default) the timeline stops at the last minute with events.
- Call `is_caught_up()` to see if timeline matches `future` or if `catch_up()` should be called again.
- Call `has_events()` to see if there is any use advancing.
- Events are `minute` based. The `seconds` and `milliseconds` are ignored.
- Events that share a `minute` are clumped together. The `event_occured` signal will fire seperately for each.

`add_event` assumes time is relative to `future`. Call `add_event({}, evnt, false)` if you want it relative to the initialisation time.

```gdscript
# Create timeline.
var dt := DateTimeline.new({ year=1989, month_name="oct" })

# Add events that occur in the future.
dt.add_event({ days=1 }, "It's Tomorrow!")
dt.add_event({ weekend=true }, "It's The Weekend!")
dt.add_event({ month_name="dec", day_of_month=25 }, "It's Christmas!")
dt.add_event({ month_name="apr", day_of_month=5 }, "It's Easter!")
dt.add_event({ month_name="oct", day_of_month=31 }, "It's Halloween!")
dt.add_event({ season=DateTime.Season.SUMMER }, "It's Summer!")
dt.add_event({ period=DateTime.Period.MORNING }, "It's Morning!")

# Event listener.
dt.event_occured.connect(func(e): print(e))

# You'll probably want to set this up differently.
while not dt.is_caught_up() or dt.has_events():
	dt.catch_up()
	if dt.has_events():
		dt.advance({ minutes=dt.get_minutes_until_next_event() })
```

### Signals
Whenever `catch_up` is called, these may emit, and in this order.

```gdscript
signal hour_ended(hour: int)
signal period_ended(period: Period)
signal day_ended(weekday: Weekday)
signal month_ended(month: Month)
signal year_ended(year: int)
signal year_started(year: int)
signal month_started(month: Month)
signal day_started(weekday: Weekday)
signal period_started(period: Period)
signal hour_started(hour: int)
```

# Changes
- 1.2
	- Added `milliseconds` property.
	- `get_weekday()` swapped to Sakamoto from Zeller.
	- `weekday_name` can optionally be set with 3 letter short names like "Wed", and case no longer matters.
	- `format()` `set_from_format()` modeled after pythons but allows for property names too.
	- Rewrote `DateTimeline` (Previously `Schedule`) to work better for me.
