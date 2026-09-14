class_name ResidentState
extends RefCounted

var mood := 72.0
var fullness := 68.0
var energy := 74.0
var hygiene := 78.0
var fun := 55.0
var affection := 20.0
var coins := 120

func tick(minutes: float) -> void:
	fullness = clampf(fullness - minutes * 0.035, 0.0, 100.0)
	energy = clampf(energy - minutes * 0.028, 0.0, 100.0)
	hygiene = clampf(hygiene - minutes * 0.020, 0.0, 100.0)
	fun = clampf(fun - minutes * 0.018, 0.0, 100.0)
	var pressure := 0.0
	for v in [fullness, energy, hygiene, fun]:
		if v < 25.0:
			pressure += (25.0 - v) * 0.002
	mood = clampf(mood - minutes * pressure, 0.0, 100.0)

func apply_action(action_id: String) -> void:
	match action_id:
		"sleep":
			energy = clampf(energy + 48.0, 0.0, 100.0)
			mood = clampf(mood + 5.0, 0.0, 100.0)
		"eat":
			fullness = clampf(fullness + 42.0, 0.0, 100.0)
			mood = clampf(mood + 3.0, 0.0, 100.0)
		"shower":
			hygiene = clampf(hygiene + 55.0, 0.0, 100.0)
			mood = clampf(mood + 4.0, 0.0, 100.0)
		"computer":
			fun = clampf(fun + 38.0, 0.0, 100.0)
			energy = clampf(energy - 7.0, 0.0, 100.0)
		"chat":
			affection = clampf(affection + 7.0, 0.0, 100.0)
			mood = clampf(mood + 8.0, 0.0, 100.0)
		"relax":
			mood = clampf(mood + 12.0, 0.0, 100.0)
			fun = clampf(fun + 8.0, 0.0, 100.0)

func to_dict() -> Dictionary:
	return {
		"mood": mood, "fullness": fullness, "energy": energy,
		"hygiene": hygiene, "fun": fun, "affection": affection, "coins": coins,
	}

func apply_dict(data: Dictionary) -> void:
	mood = float(data.get("mood", mood))
	fullness = float(data.get("fullness", fullness))
	energy = float(data.get("energy", energy))
	hygiene = float(data.get("hygiene", hygiene))
	fun = float(data.get("fun", fun))
	affection = float(data.get("affection", affection))
	coins = int(data.get("coins", coins))
