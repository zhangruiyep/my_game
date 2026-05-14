extends Node2D

var unit_data: Dictionary = {}
var class_type: int = -1
var stats: Dictionary = {}
var current_stats: Dictionary = {}
var grid_position: Vector2i = Vector2i.ZERO
var allegiance: String = "player"
var has_moved: bool = false
var has_acted: bool = false
var weapon: Dictionary = {}
var level: int = 1
var exp: int = 0

var sprite: ColorRect
var label_ref: Label

signal unit_clicked(unit)
signal unit_died(unit)
signal leveled_up(unit)

func _init(preset: Dictionary = {}, pos: Vector2i = Vector2i.ZERO):
	grid_position = pos

func _ready():
	pass

func setup_from_preset(preset: Dictionary):
	class_type = preset["class"]
	unit_data = UnitData.get_class_data(class_type)
	level = preset.get("level", 1)
	allegiance = preset.get("allegiance", "player")

	var weapon_preset = preset.get("equipped_weapon", {})
	var wtype = weapon_preset.get("type", UnitData.WeaponType.SWORD)
	var tier = weapon_preset.get("tier", "iron")
	weapon = UnitData.get_weapon_data(wtype, tier)

	_generate_stats()
	_create_sprite()

func _generate_stats():
	var growths = unit_data["growths"]
	stats = {
		"hp": 18 + int(growths["hp"] / 10),
		"max_hp": 18 + int(growths["hp"] / 10),
		"str": 3 + int(growths["str"] / 10),
		"mag": 1 + int(growths["mag"] / 10),
		"skl": 3 + int(growths["skl"] / 10),
		"spd": 3 + int(growths["spd"] / 10),
		"def": 3 + int(growths["def"] / 10),
		"res": 1 + int(growths["res"] / 10),
		"mov": unit_data["base_movement"]
	}
	current_stats = stats.duplicate()
	current_stats["hp"] = stats["max_hp"]

func _create_sprite():
	if sprite:
		sprite.queue_free()
		label_ref = null

	sprite = ColorRect.new()
	var size = 48
	sprite.size = Vector2(size, size)
	sprite.position = Vector2(grid_position.x * 64 + 8, grid_position.y * 64 + 8)

	match unit_data.get("name", ""):
		"领主":
			sprite.color = Color(0.2, 0.4, 1.0)
		"骑士":
			sprite.color = Color(0.6, 0.8, 0.2)
		"重甲骑士":
			sprite.color = Color(0.5, 0.5, 0.6)
		"佣兵":
			sprite.color = Color(0.2, 0.6, 0.4)
		"弓箭手":
			sprite.color = Color(0.2, 0.7, 0.2)
		"法师":
			sprite.color = Color(0.6, 0.2, 0.7)
		"修女":
			sprite.color = Color(0.9, 0.9, 0.9)
		"山贼":
			sprite.color = Color(0.7, 0.2, 0.2)
		_:
			sprite.color = Color(0.5, 0.5, 0.5)

	sprite.mouse_filter = Control.MOUSE_FILTER_STOP
	sprite.gui_input.connect(_on_unit_input)

	label_ref = Label.new()
	label_ref.text = unit_data.get("name", "?")
	label_ref.add_theme_font_size_override("font_size", 10)
	label_ref.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_ref.size = Vector2(size, 14)
	label_ref.position = Vector2(0, size + 2)
	sprite.add_child(label_ref)

	add_child(sprite)

func _on_unit_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if TurnManager.state == TurnManager.TurnState.WAITING or TurnManager.state == TurnManager.TurnState.UNIT_SELECTED:
			unit_clicked.emit(self)

func set_grid_position(new_pos: Vector2i):
	grid_position = new_pos
	if sprite:
		sprite.position = Vector2(new_pos.x * 64 + 8, new_pos.y * 64 + 8)

func move_to(path: Array):
	for pos in path:
		set_grid_position(pos)
		await get_tree().create_timer(0.15).timeout

func get_attack() -> int:
	if weapon.get("type") in [UnitData.WeaponType.MAGIC, UnitData.WeaponType.STAFF]:
		return current_stats["mag"] + weapon.get("might", 0)
	return current_stats["str"] + weapon.get("might", 0)

func get_hit() -> int:
	return current_stats["skl"] * 2 + weapon.get("hit", 0)

func get_avoid() -> int:
	return current_stats["spd"] * 2 + current_stats.get("lck", 0)

func get_crit() -> int:
	return int(current_stats["skl"] / 2) + weapon.get("crit", 0)

func get_attack_speed() -> int:
	return current_stats["spd"] - weapon.get("weight", 0)

func get_defense() -> int:
	return current_stats["def"]

func get_resistance() -> int:
	return current_stats["res"]

func is_magic_weapon() -> bool:
	return weapon.get("type") in [UnitData.WeaponType.MAGIC, UnitData.WeaponType.STAFF]

func take_damage(amount: int):
	current_stats["hp"] = max(0, current_stats["hp"] - amount)

func heal_damage(amount: int):
	current_stats["hp"] = min(stats["max_hp"], current_stats["hp"] + amount)

func is_alive() -> bool:
	return current_stats["hp"] > 0

func reset_turn():
	has_moved = false
	has_acted = false

func apply_terrain_bonus(pos: Vector2i) -> Dictionary:
	var tiles_arr = GameState.current_map_data.get("tiles", [])
	if pos.y >= tiles_arr.size() or pos.x >= tiles_arr[pos.y].size():
		return UnitData.get_terrain_data(0)
	var terrain_id = tiles_arr[pos.y][pos.x]
	return UnitData.get_terrain_data(terrain_id)

func get_class_name_str() -> String:
	return unit_data.get("name", "?")

func gain_exp(amount: int):
	if not is_alive():
		return
	exp += amount
	var total = UnitData.get_total_exp_needed(level)
	if exp >= total:
		exp -= total
		_level_up()

func _level_up():
	level += 1
	stats["max_hp"] += _roll_growth("hp")
	stats["str"] += _roll_growth("str")
	stats["mag"] += _roll_growth("mag")
	stats["skl"] += _roll_growth("skl")
	stats["spd"] += _roll_growth("spd")
	stats["def"] += _roll_growth("def")
	stats["res"] += _roll_growth("res")
	current_stats = stats.duplicate()
	current_stats["hp"] = stats["max_hp"]
	_update_label()
	leveled_up.emit(self)

func _roll_growth(stat: String) -> int:
	var growth = unit_data.get("growths", {}).get(stat, 30)
	if randi() % 100 < growth:
		return 1
	return 0

func _update_label():
	if label_ref:
		label_ref.text = "%s Lv.%d" % [unit_data.get("name", "?"), level]
