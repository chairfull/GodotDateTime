class_name Schedule
extends Resource
## Schedule multiple events in the future, then trigger them.
##
## Example:
##		while not is_finished():
##			advance()

signal event_occured(event: Variant)

@export var _seconds := -1
@export var _events: Dictionary[int, Array]

func add_event(event: Variant, date: DateTime):
	var seconds := date.total_seconds
	if not seconds in _events:
		_events[seconds] = []
	_events[seconds].append(event)

func is_finished() -> bool:
	return get_time_of_next_event() == -1

func get_time_of_next_event() -> int:
	var min_event := _seconds
	var event_seconds := _events.keys()
	event_seconds.sort()
	for sec in event_seconds:
		if sec > min_event:
			return sec
	return -1

func advance():
	var next_time := get_time_of_next_event()
	if next_time != -1:
		advance_to_seconds(next_time)

func advance_by_seconds(by: int, stop_at_first := true, erase_events := false):
	advance_to_seconds(_seconds + by)

func advance_to_seconds(to: int, stop_at_first := true, erase_events := false):
	var events_sorted: Array[int]
	events_sorted.assign(_events.keys())
	events_sorted.sort()
	
	for sec in events_sorted:
		if sec > _seconds and sec <= to:
			for ev in _events[sec]:
				event_occured.emit(ev)
			
			if erase_events:
				_events.erase(sec)
			
			if stop_at_first:
				to = sec
				break
	
	_seconds = to
