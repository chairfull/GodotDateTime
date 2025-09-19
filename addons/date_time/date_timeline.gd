@tool
class_name DateTimeline extends DateTime
## WARNING: Work in progress.
## Schedule multiple events in the future, then trigger them.

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

signal event_occured(event: Variant)

## If true, use is_caught_up() and catch_up() to advance to desired time.
@export var stop_on_event := true

## Events in the future, stored in *minutes*.
## They are only triggered at the end of a Period.
@export_storage var _events: Dictionary[int, Array]
@export_storage var future: DateTime
@export_storage var _start_date: int

func _init(input: Variant = null):
	super(input)
	future = DateTime.new(input)
	_start_date = total_milliseconds

## Adjusts future instead of our own.
func advance(dict := {}):
	future.advance(dict)

func catch_up():
	var lyear := year
	var lmonth := month
	var lday := days
	var lperiod := period
	var lhour := hours
	var did_event := false
	var loops := 0
	while get_total_minutes() < future.get_total_minutes():
		loops += 1
		
		# Find next event.
		var next_seconds := get_seconds_until_next_hour()
		var tsecs := get_total_seconds()
		for emins in _events:
			var esecs := emins * DateTime.SECONDS_IN_MINUTE - tsecs
			if esecs > 0: next_seconds = mini(next_seconds, esecs)
		seconds += next_seconds
		
		# Trigger events signal.
		var mins := get_total_minutes()
		for emins in _events:
			if emins <= mins:
				for event in _events[emins]:
					event_occured.emit(event)
				_events.erase(emins)
				did_event = true
		# Triger period, day, month, year signals.
		if hours != lhour:
			lhour = hours
			hour_ended.emit(lhour)
			if period != lperiod:
				lperiod = period
				period_ended.emit(lperiod)
				if days != lday:
					day_ended.emit(lday)
					lday = days
					if month != lmonth:
						month_ended.emit(lmonth)
						lmonth = month
						if year != lyear:
							year_ended.emit(lyear)
							lyear = year
							year_started.emit(year)
						month_started.emit(month)
					day_started.emit(weekday)
				period_started.emit(period)
			hour_started.emit(hours)
		
		if stop_on_event and did_event:
			break
	
	print("Loops: ", loops)
	
	if stop_on_event and did_event:
		pass
	else:
		total_milliseconds = future.total_milliseconds

func is_caught_up() -> bool:
	return is_now(future)

func has_events() -> bool:
	return _events.size() > 0

## Must occur in the future.
func add_event(future_date: Dictionary, event: Variant, relative := true):
	var base_time := future.total_milliseconds if relative else _start_date
	var event_dt := DateTime.new(base_time)
	event_dt.advance(future_date)
	
	if event_dt.get_total_milliseconds() < future.get_total_milliseconds():
		push_error("Can't add events in the past. Event (%s) wasn't added." % [event])
		return
	
	var tot_mins := event_dt.get_total_minutes()
	if not tot_mins in _events:
		_events[tot_mins] = []
	_events[tot_mins].append(event)
	
	# Sort dictionary by event time.
	var items := []
	for mins in _events:
		items.append([mins, _events[mins]])
	items.sort_custom(func(a, b): return a[0] < b[0])
	_events.clear()
	for item in items:
		_events[item[0]] = item[1]

func advance_to_next_event():
	var event_dt := get_next_event_date()
	if event_dt:
		future.total_milliseconds = event_dt.total_milliseconds

func get_minutes_until_next_event() -> int:
	var dt := get_next_event_date()
	return dt.get_total_minutes() - get_total_minutes()
	
func get_next_event_date() -> DateTime:
	var earliest := INF
	var had_event := false
	for mins in _events:
		if mins < earliest:
			earliest = mins
			had_event = true
	if had_event:
		return DateTime.new({ minutes=earliest })
	return null

## All events and their date_times.
func get_all_event_date_times() -> Dictionary[DateTime, Variant]:
	var out: Dictionary[DateTime, Variant]
	for mins in _events:
		out[DateTime.new({ minutes=mins })] = _events[mins]
	return out
