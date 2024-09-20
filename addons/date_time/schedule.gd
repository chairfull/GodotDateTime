class_name Schedule
extends DateTime

signal event_occured(event: Variant)

@export_storage var _last_time := DateTime.new()
@export var _events: Dictionary[int, Array]

func _changed():
	print("Changed")
	var diff := _last_time.get_relation_difference(self)
	_last_time.copy(self)
	var r = _last_time.Relation.keys()[diff[0]]
	var e = _last_time.Epoch.keys()[diff[1]]
	prints(r, e, diff[2], diff)

func add_event(event: Variant, date: DateTime):
	var seconds := date.total_seconds
	if not seconds in _events:
		_events[seconds] = []
	_events[seconds].append(event)

func advance(seconds: int, stop_at_first := true, erase_events := false):
	var curr_seconds := total_seconds
	var next_seconds := curr_seconds + seconds
	var events_sorted: Array[int]
	events_sorted.assign(_events.keys())
	events_sorted.sort()
	
	for sec in events_sorted:
		if sec > curr_seconds and sec <= next_seconds:
			for ev in _events[sec]:
				event_occured.emit(ev)
				print("EVENT ", ev)
			
			if erase_events:
				_events.erase(sec)
			
			if stop_at_first:
				next_seconds = sec
				return
	
	total_seconds = next_seconds
