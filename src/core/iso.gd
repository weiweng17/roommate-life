class_name Iso
extends RefCounted
## Derived from lutherfourie/net-ninja-godot (MIT), source-code portion only.
## Isometric projection maths — world data stays renderer-independent.

const TILE_W := 64.0
const TILE_H := 32.0
const TILE_Z := 38.0

static func to_screen(w: Vector3) -> Vector2:
	return Vector2(
		(w.x - w.z) * (TILE_W * 0.5),
		(w.x + w.z) * (TILE_H * 0.5) - w.y * TILE_Z
	)

static func to_ground(screen: Vector2) -> Vector3:
	var a := screen.x / (TILE_W * 0.5)
	var b := screen.y / (TILE_H * 0.5)
	return Vector3((b + a) * 0.5, 0.0, (b - a) * 0.5)

static func depth(origin: Vector3, size: Vector3) -> float:
	return (origin.x + size.x) + (origin.z + size.z) + origin.y * 0.5

static func depth_to_z_index(key: float) -> int:
	return clampi(int(round(key * 16.0)), -4000, 4000)

static func top_face(origin: Vector3, size: Vector3) -> PackedVector2Array:
	var y := origin.y + size.y
	return PackedVector2Array([
		to_screen(Vector3(origin.x, y, origin.z)),
		to_screen(Vector3(origin.x + size.x, y, origin.z)),
		to_screen(Vector3(origin.x + size.x, y, origin.z + size.z)),
		to_screen(Vector3(origin.x, y, origin.z + size.z)),
	])

static func left_face(origin: Vector3, size: Vector3) -> PackedVector2Array:
	var z := origin.z + size.z
	return PackedVector2Array([
		to_screen(Vector3(origin.x, origin.y + size.y, z)),
		to_screen(Vector3(origin.x + size.x, origin.y + size.y, z)),
		to_screen(Vector3(origin.x + size.x, origin.y, z)),
		to_screen(Vector3(origin.x, origin.y, z)),
	])

static func right_face(origin: Vector3, size: Vector3) -> PackedVector2Array:
	var x := origin.x + size.x
	return PackedVector2Array([
		to_screen(Vector3(x, origin.y + size.y, origin.z)),
		to_screen(Vector3(x, origin.y + size.y, origin.z + size.z)),
		to_screen(Vector3(x, origin.y, origin.z + size.z)),
		to_screen(Vector3(x, origin.y, origin.z)),
	])
