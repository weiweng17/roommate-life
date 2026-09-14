extends Node2D

const RoomFactory = preload("res://src/room/room_factory.gd")
const SAVE_PATH := "user://roommate_life.json"
const CAMERA_OFFSET := Vector2(640, 175)
const GAME_MINUTES_PER_REAL_SECOND := 1.5

var room
var actor
var state
var brain
var target_prop = null
var queued_action := ""
var current_action := "idle"
var activity_left := 0.0
var brain_left := 1.0
var autosave_left := 8.0
var clock_minutes := 1290.0

var action_label: Label
var clock_label: Label
var toast_label: Label
var stat_labels := {}

func _ready() -> void:
	randomize()
	room = RoomFactory.build()
	actor = ActorBody.new()
	actor.position = room.spawn
	state = ResidentState.new()
	brain = ResidentBrain.new()
	_load_game()
	_build_ui()
	_set_toast("Roommate Life：小满会自己生活。")
	queue_redraw()

func _process(delta: float) -> void:
	var game_minutes := delta * GAME_MINUTES_PER_REAL_SECOND
	clock_minutes = fmod(clock_minutes + game_minutes, 1440.0)
	state.tick(game_minutes)

	if activity_left > 0.0:
		activity_left -= delta
		actor.step(delta, Vector2.ZERO, room)
		if activity_left <= 0.0:
			_finish_action()
	else:
		_update_target_and_move(delta)

	brain_left -= delta
	if brain_left <= 0.0:
		brain_left = 1.0
		if target_prop == null and queued_action == "" and current_action == "idle":
			request_action(brain.choose_action(state), false)

	autosave_left -= delta
	if autosave_left <= 0.0:
		autosave_left = 8.0
		_save_game()

	_refresh_ui()
	queue_redraw()

func _update_target_and_move(delta: float) -> void:
	if target_prop == null:
		actor.step(delta, Vector2.ZERO, room)
		return
	var here := Vector2(actor.position.x, actor.position.z)
	var there := target_prop.interaction_point()
	var d := there - here
	if d.length() <= 0.22:
		actor.step(delta, Vector2.ZERO, room)
		_start_activity(queued_action)
		return
	var world_dir := d.normalized()
	var screen_input := Vector2(world_dir.x - world_dir.y, world_dir.x + world_dir.y).normalized()
	actor.step(delta, screen_input, room)

func request_action(action_id: String, player_requested: bool = true) -> void:
	if activity_left > 0.0:
		return
	var prop = _find_prop(action_id)
	if prop == null:
		return
	target_prop = prop
	queued_action = action_id
	current_action = "going_" + action_id
	if player_requested:
		_set_toast("你安排了：" + prop.interact_label)

func _find_prop(action_id: String):
	for p in room.interactables():
		if p.interact_id == action_id:
			return p
	return null

func _start_activity(action_id: String) -> void:
	current_action = action_id
	queued_action = ""
	target_prop = null
	activity_left = {"sleep":5.5,"eat":3.5,"shower":4.5,"computer":4.5,"chat":3.5,"relax":3.0}.get(action_id, 2.0)
	_set_toast("小满正在" + _action_name(action_id) + "……")

func _finish_action() -> void:
	state.apply_action(current_action)
	_set_toast(_action_name(current_action) + "完成")
	current_action = "idle"
	activity_left = 0.0

func _action_name(action_id: String) -> String:
	return {
		"sleep":"睡觉", "eat":"吃东西", "shower":"洗澡", "computer":"玩电脑",
		"chat":"和你聊天", "relax":"看雨发呆", "idle":"发呆"
	}.get(action_id, action_id.replace("going_", "走向"))

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var left := PanelContainer.new()
	left.position = Vector2(18, 18)
	left.size = Vector2(248, 286)
	left.add_theme_stylebox_override("panel", _panel(Color(0.07,0.06,0.08,0.90), 16))
	layer.add_child(left)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	left.add_child(vb)
	var title := Label.new()
	title.text = "小满 · Roommate"
	title.add_theme_font_size_override("font_size", 24)
	vb.add_child(title)
	for item in [["mood","心情"],["fullness","饱食"],["energy","精力"],["hygiene","卫生"],["fun","娱乐"],["affection","亲密"]]:
		var l := Label.new()
		l.add_theme_font_size_override("font_size", 16)
		vb.add_child(l)
		stat_labels[item[0]] = l
	var top := PanelContainer.new()
	top.position = Vector2(500, 18)
	top.size = Vector2(280, 64)
	top.add_theme_stylebox_override("panel", _panel(Color(0.07,0.06,0.08,0.90), 18))
	layer.add_child(top)
	clock_label = Label.new()
	clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	clock_label.add_theme_font_size_override("font_size", 22)
	top.add_child(clock_label)
	var right := PanelContainer.new()
	right.position = Vector2(1002, 18)
	right.size = Vector2(260, 122)
	right.add_theme_stylebox_override("panel", _panel(Color(0.07,0.06,0.08,0.90), 16))
	layer.add_child(right)
	action_label = Label.new()
	action_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	action_label.add_theme_font_size_override("font_size", 17)
	right.add_child(action_label)
	var bar := PanelContainer.new()
	bar.position = Vector2(300, 642)
	bar.size = Vector2(680, 60)
	bar.add_theme_stylebox_override("panel", _panel(Color(0.07,0.06,0.08,0.92), 18))
	layer.add_child(bar)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 6)
	bar.add_child(hb)
	for action_id in ["eat","shower","computer","chat","relax","sleep"]:
		var b := Button.new()
		b.text = _action_name(action_id)
		b.custom_minimum_size = Vector2(108, 44)
		b.pressed.connect(Callable(self, "request_action").bind(action_id, true))
		hb.add_child(b)
	toast_label = Label.new()
	toast_label.position = Vector2(365, 586)
	toast_label.size = Vector2(550, 42)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.add_theme_font_size_override("font_size", 17)
	toast_label.add_theme_stylebox_override("normal", _panel(Color(0.98,0.93,0.86,0.95), 14))
	toast_label.add_theme_color_override("font_color", Color("#302a2a"))
	layer.add_child(toast_label)

func _panel(color: Color, radius: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.corner_radius_top_left = radius
	s.corner_radius_top_right = radius
	s.corner_radius_bottom_left = radius
	s.corner_radius_bottom_right = radius
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s

func _refresh_ui() -> void:
	var h := int(clock_minutes / 60.0)
	var m := int(clock_minutes) % 60
	clock_label.text = "雨夜  %02d:%02d   ¥%d" % [h, m, state.coins]
	action_label.text = "现在：%s\n\n小人会根据最低需求自己决定下一件事。" % _action_name(current_action)
	var values := {"mood":state.mood,"fullness":state.fullness,"energy":state.energy,"hygiene":state.hygiene,"fun":state.fun,"affection":state.affection}
	var names := {"mood":"心情","fullness":"饱食","energy":"精力","hygiene":"卫生","fun":"娱乐","affection":"亲密"}
	for k in stat_labels.keys():
		stat_labels[k].text = "%s  %3d" % [names[k], int(round(values[k]))]

func _set_toast(text: String) -> void:
	if toast_label != null:
		toast_label.text = text

func _save_game() -> void:
	var data := {"saved_at":Time.get_unix_time_from_system(),"clock_minutes":clock_minutes,"state":state.to_dict(),"actor":[actor.position.x,actor.position.y,actor.position.z]}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(data))
		f.close()

func _load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(data) != TYPE_DICTIONARY:
		return
	state.apply_dict(data.get("state", {}))
	clock_minutes = float(data.get("clock_minutes", clock_minutes))
	var a = data.get("actor", [])
	if typeof(a) == TYPE_ARRAY and a.size() >= 3:
		actor.position = Vector3(float(a[0]), float(a[1]), float(a[2]))
	var elapsed := clampf(Time.get_unix_time_from_system() - float(data.get("saved_at", Time.get_unix_time_from_system())), 0.0, 43200.0)
	state.tick(elapsed / 60.0)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280,720)), Color("#171622"))
	var props = room.props.duplicate()
	props.sort_custom(func(a, b): return Iso.depth(a.origin, a.size) < Iso.depth(b.origin, b.size))
	var actor_key := Iso.depth(actor.position + Vector3(-0.4,0,-0.4), Vector3(0.8,1.7,0.8))
	var actor_drawn := false
	for p in props:
		if not actor_drawn and Iso.depth(p.origin, p.size) >= actor_key:
			_draw_actor()
			actor_drawn = true
		_draw_prop(p)
	if not actor_drawn:
		_draw_actor()

func _with_offset(points: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in points:
		out.append(p + CAMERA_OFFSET)
	return out

func _draw_prop(p) -> void:
	if p.kind == PropDef.Kind.FLOOR or p.kind == PropDef.Kind.RUG:
		draw_colored_polygon(_with_offset(Iso.top_face(p.origin, p.size)), p.base_color.lightened(0.16))
		return
	if p.kind == PropDef.Kind.ROUND:
		var c := Iso.to_screen(p.centre()) + CAMERA_OFFSET
		draw_circle(c, maxf(10.0, p.size.x * 18.0), p.base_color)
		return
	draw_colored_polygon(_with_offset(Iso.left_face(p.origin, p.size)), p.base_color.darkened(0.12))
	draw_colored_polygon(_with_offset(Iso.right_face(p.origin, p.size)), p.base_color.darkened(0.24))
	draw_colored_polygon(_with_offset(Iso.top_face(p.origin, p.size)), p.base_color.lightened(0.16))
	if p.accent_color.a > 0.0:
		draw_circle(Iso.to_screen(p.centre()) + CAMERA_OFFSET + Vector2(0,-p.size.y*10.0), 6.0, p.accent_color)

func _draw_actor() -> void:
	var pos := Iso.to_screen(actor.position) + CAMERA_OFFSET
	var bob := sin(actor.travel * 8.0) * 2.0 if actor.is_moving() else 0.0
	_draw_ellipse(pos + Vector2(0,6), Vector2(18,7), Color(0,0,0,0.28))
	draw_rect(Rect2(pos + Vector2(-10,-42+bob), Vector2(20,32)), Color("#c57468"), true)
	draw_circle(pos + Vector2(0,-53+bob), 12.0, Color("#f0c4a8"))

func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(24):
		var a := TAU * float(i) / 24.0
		pts.append(center + Vector2(cos(a)*radii.x, sin(a)*radii.y))
	draw_colored_polygon(pts, color)
