class_name PropDef
extends Resource
## Derived from lutherfourie/net-ninja-godot (MIT), source-code portion only.

enum Kind { BOX, FLOOR, RUG, WALL, SOFT, ROUND }

@export var id: String = ""
@export var kind: Kind = Kind.BOX
@export var origin: Vector3 = Vector3.ZERO
@export var size: Vector3 = Vector3.ONE
@export var base_color: Color = Color("6d4630")
@export var accent_color: Color = Color(0, 0, 0, 0)
@export var blocks: bool = true
@export var interact_id: String = ""
@export var interact_label: String = ""
@export var interact_radius: float = 1.6
@export var interact_offset: Vector2 = Vector2.ZERO
@export var light_color: Color = Color(0, 0, 0, 0)
@export var light_energy: float = 0.0
@export var light_scale: float = 1.0
@export var light_offset: Vector3 = Vector3.ZERO
@export var decal: String = ""
@export var reacts_to_possession: bool = false

func centre() -> Vector3:
	return origin + size * 0.5

func footprint() -> Rect2:
	return Rect2(Vector2(origin.x, origin.z), Vector2(size.x, size.z))

func interaction_point() -> Vector2:
	var c := centre()
	return Vector2(c.x, c.z) + interact_offset

static func make(cfg: Dictionary) -> PropDef:
	var p := PropDef.new()
	for key in cfg.keys():
		p.set(key, cfg[key])
	return p
