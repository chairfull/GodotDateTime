# DateTime
`v1.2` Godot4.5dev+

## Feature Overview
- Hours:
	- `is_am()` `is_pm()`
- Days:
	- `is_daytime()` `is_nighttime()`
- Periods: `DAWN, MORNING, DAY, DUSK, EVENING, NIGHT`
	- `period_name`
- Weeks:
	- `is_weekend()` `is_weekday()`
- Seasons: `SPRING, SUMMER, AUTUMN, WINTER`
	- `season_name`
- Horoscopes:
	- `get_horoscope_name()`
	- `get_horoscope_unicode()`
- Zodiac: 
	- `get_zodiac_name()`
	- `get_zodiac_unicode()`
	- `get_zodiac_emoji()`
- Advance Time:
	- `advance_to_next_period()`
	- `advance_to_next_day()`
	- `advance_to_next_month()`
	- `advance_to_next_season()`
	- `advance_to_next_year()`

## Setup
Currently `DateTime` can be initialised with:
- `int` = total milliseconds. Example: `DateTime.new(Time.get_unix_time_from_system())`
- `Dictionary` = properties. Example: `DateTime.new({ month_name="December", day_of_month=25, year=1991 })`
- `StringName` = [enum](#enum-overview). Example: `DateTime.new(&"JANUARY")`
- `String` = [formatted](#formatting) string. Example: `DateTime.new("Dec 25th 1991 10:30PM")`
- `DateTime` = properties to copy. Example: `DateTime.new(character.birthday)`

## Formatting

- `DateTime.format_default`
- `DateTime.format_datetime_str`

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

# Changes
- 1.2
	- Added `milliseconds` property.
	- `get_weekday()` swapped to Sakamoto from Zeller.
	- `weekday_name` can optionally be set with 3 letter short names "Wed", and case no longer matters.
	- `to_str()` modeled after pythons.
