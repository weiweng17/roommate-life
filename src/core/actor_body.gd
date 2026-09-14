class_name ActorBody
extends RefCounted
## Derived from lutherfourie/net-ninja-godot (MIT), source-code portion only.

var position := Vector3.ZERO
var velocity := Vector3.ZERO
var radius := 0.42
var speed := 4.2
var accel := 26.0
var friction := 20.0
var facing := Vector2(0, 1)
var travel := 0.0

func is_moving() -> bool:
	return Vector2(velocity.x, velocity.z).length_squared() > 0.04

static func input_to_world(input: Vector2) -> Vector2:
	if input.length_squared() < 0.0001:
		return Vector2.ZERO
	var world := Vector2(input.x + input.y, input.y - input.x)
	return world.normalized() * minf(input.length(), 1.0)

func step(delta: float, input: Vector2, room: RoomModel) -> void:
	var wish := input_to_world(input)
	var target := Vector3(wish.x, 0.0, wish.y) * speed
	var rate := accel if wish.length_squared() > 0.0001 else friction
	velocity = velocity.move_toward(target, rate * delta)
	if wish.length_squared() > 0.0001:
		facing = wish.normalized()
	var motion := velocity * delta
	if motion.length_squared() > 0.0:
		_move_axis(Vector3(motion.x, 0, 0), room)
		_move_axis(Vector3(0, 0, motion.z), room)
		travel += Vector2(motion.x, motion.z).length()

func _move_axis(motion: Vector3, room: RoomModel) -> void:
	var next := position + motion
	var flat := Vector2(next.x, next.z)
	if not room.is_walkable(flat):
		if not is_zero_approx(motion.x): velocity.x = 0.0
		if not is_zero_approx(motion.z): velocity.z = 0.0
		return
	for rect in room.blockers():
		if _overlaps(flat, rect):
			if not is_zero_approx(motion.x): velocity.x = 0.0
			if not is_zero_approx(motion.z): velocity.z = 0.0
			return
	position = next

func _overlaps(point: Vector2, rect: Rect2) -> bool:
	var closest := Vector2(
		clampf(point.x, rect.position.x, rect.end.x),
		clampf(point.y, rect.position.y, rect.end.y)
	)
	return closest.distance_squared_to(point) < radius * radius

func nearest_interactable(room: RoomModel) -> PropDef:
	var best: PropDef = null
	var best_d := INF
	var here := Vector2(position.x, position.z)
	for p in room.interactables():
		var c := p.centre()
		var d := here.distance_to(Vector2(c.x, c.z))
		if d <= p.interact_radius and d < best_d:
			best_d = d
			best = p
	return best
