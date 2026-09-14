class_name ResidentBrain
extends RefCounted

func choose_action(state: ResidentState) -> String:
	var scores := {
		"eat": 100.0 - state.fullness,
		"sleep": 100.0 - state.energy,
		"shower": 100.0 - state.hygiene,
		"computer": 100.0 - state.fun,
		"relax": 35.0 + (100.0 - state.mood) * 0.35,
	}
	var best := "relax"
	var best_score := -INF
	for action_id in scores.keys():
		var score := float(scores[action_id]) + randf_range(-5.0, 5.0)
		if score > best_score:
			best_score = score
			best = action_id
	return best
