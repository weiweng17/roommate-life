extends RefCounted

static func build() -> RoomModel:
	var room := RoomModel.new()
	room.id = "starter_apartment"
	room.display_name = "雨夜出租屋"
	room.bounds = Vector3(12, 4.5, 9)
	room.spawn = Vector3(5.6, 0, 5.0)
	room.walk_rects = [Rect2(0.6, 0.6, 10.8, 7.8)]
	room.ambient_tint = Color("#383044")

	room.add(PropDef.make({"id":"floor","kind":PropDef.Kind.FLOOR,"origin":Vector3(0,0,0),"size":Vector3(12,0.05,9),"base_color":Color("#685648"),"blocks":false}))
	room.add(PropDef.make({"id":"rug","kind":PropDef.Kind.RUG,"origin":Vector3(4.1,0.06,4.0),"size":Vector3(3.4,0.02,2.2),"base_color":Color("#80585e"),"blocks":false}))
	room.add(PropDef.make({"id":"back_wall","kind":PropDef.Kind.WALL,"origin":Vector3(0,0,0),"size":Vector3(12,4.0,0.18),"base_color":Color("#645a65"),"blocks":true}))
	room.add(PropDef.make({"id":"left_wall","kind":PropDef.Kind.WALL,"origin":Vector3(0,0,0),"size":Vector3(0.18,4.0,9),"base_color":Color("#5c5360"),"blocks":true}))

	room.add(PropDef.make({"id":"bed","kind":PropDef.Kind.SOFT,"origin":Vector3(1.0,0,1.1),"size":Vector3(3.1,0.75,2.2),"base_color":Color("#9aa88e"),"accent_color":Color("#e8d9c5"),"interact_id":"sleep","interact_label":"睡觉","interact_radius":2.0,"interact_offset":Vector2(0,1.55)}))
	room.add(PropDef.make({"id":"desk","kind":PropDef.Kind.BOX,"origin":Vector3(6.6,0,1.0),"size":Vector3(2.6,0.95,1.2),"base_color":Color("#6f4b36"),"interact_id":"computer","interact_label":"玩电脑","interact_radius":1.8,"interact_offset":Vector2(0,1.25)}))
	room.add(PropDef.make({"id":"computer","kind":PropDef.Kind.BOX,"origin":Vector3(7.25,0.95,1.18),"size":Vector3(1.1,0.9,0.18),"base_color":Color("#252331"),"accent_color":Color("#896fe5"),"blocks":false}))
	room.add(PropDef.make({"id":"fridge","kind":PropDef.Kind.BOX,"origin":Vector3(9.5,0,1.0),"size":Vector3(1.25,2.2,1.25),"base_color":Color("#c9c6bb"),"interact_id":"eat","interact_label":"吃东西","interact_radius":1.9,"interact_offset":Vector2(0,1.25)}))
	room.add(PropDef.make({"id":"shower","kind":PropDef.Kind.BOX,"origin":Vector3(9.35,0,6.25),"size":Vector3(1.45,2.35,1.6),"base_color":Color("#7295a0"),"accent_color":Color("#bfe7ef"),"interact_id":"shower","interact_label":"洗澡","interact_radius":1.9,"interact_offset":Vector2(0,-1.25)}))
	room.add(PropDef.make({"id":"sofa","kind":PropDef.Kind.SOFT,"origin":Vector3(3.2,0,6.1),"size":Vector3(3.2,0.9,1.45),"base_color":Color("#896c66"),"interact_id":"chat","interact_label":"聊天","interact_radius":2.1,"interact_offset":Vector2(0,-1.35)}))
	room.add(PropDef.make({"id":"window","kind":PropDef.Kind.BOX,"origin":Vector3(5.0,1.2,0.08),"size":Vector3(2.5,1.8,0.08),"base_color":Color("#28364f"),"accent_color":Color("#6f86ab"),"blocks":false,"interact_id":"relax","interact_label":"看雨","interact_radius":2.3,"interact_offset":Vector2(0,1.4)}))
	room.add(PropDef.make({"id":"plant","kind":PropDef.Kind.ROUND,"origin":Vector3(1.0,0,6.2),"size":Vector3(0.9,1.5,0.9),"base_color":Color("#5a6d50")}))
	return room
