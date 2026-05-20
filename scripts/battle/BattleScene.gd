extends Node2D

var map_controller: Node
var units_node: Node
var combat_system: Node
var ai_controller: Node

var hud: Control
var turn_label: Label
var phase_label: Label
var end_turn_btn: Button
var info_panel: Panel
var info_label: RichTextLabel
var action_menu: Panel
var attack_btn: Button
var wait_btn: Button
var battle_preview: Panel
var preview_label: RichTextLabel
var confirm_btn: Button
var cancel_btn: Button
var game_over_panel: Panel
var result_label: Label
var next_chapter_btn: Button
var restart_btn: Button
var level_up_label: Label
var sidebar_left: Panel
var sidebar_right: Panel

var unit_scene = preload("res://scenes/battle/Unit.tscn")
var current_target: Vector2i = Vector2i.ZERO
var current_action_target: Node = null
var selecting_attack_target: bool = false
var attack_targets: Array = []
var original_position: Vector2i = Vector2i.ZERO

func _ready():
	map_controller = $Map
	units_node = $Units
	combat_system = $CombatSystem
	ai_controller = $AIController

	_create_ui()

	map_controller.tile_clicked.connect(_on_tile_clicked)
	end_turn_btn.pressed.connect(_on_end_turn)
	attack_btn.pressed.connect(_on_attack_pressed)
	wait_btn.pressed.connect(_on_wait_pressed)
	confirm_btn.pressed.connect(_on_confirm_attack)
	cancel_btn.pressed.connect(_on_cancel_attack)
	restart_btn.pressed.connect(_on_restart)
	next_chapter_btn.pressed.connect(_on_next_chapter)
	TurnManager.phase_changed.connect(_on_phase_changed)
	TurnManager.unit_acted.connect(_on_unit_acted)
	combat_system.combat_ended.connect(_on_combat_ended)
	_start_battle()

func _create_ui():
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	add_child(ui_layer)

	hud = Control.new()
	hud.name = "BattleHUD"
	hud.anchor_right = 1.0
	hud.anchor_bottom = 1.0
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(hud)

	turn_label = Label.new()
	turn_label.size = Vector2(200, 30)
	turn_label.add_theme_font_size_override("font_size", 18)
	turn_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	turn_label.text = "玩家回合"
	hud.add_child(turn_label)

	phase_label = Label.new()
	phase_label.size = Vector2(200, 20)
	phase_label.add_theme_font_size_override("font_size", 12)
	phase_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
	phase_label.text = "第1回合"
	hud.add_child(phase_label)

	end_turn_btn = Button.new()
	end_turn_btn.size = Vector2(110, 36)
	end_turn_btn.text = "结束回合"
	hud.add_child(end_turn_btn)

	sidebar_left = Panel.new()
	sidebar_left.visible = false
	hud.add_child(sidebar_left)

	sidebar_right = Panel.new()
	sidebar_right.visible = false
	hud.add_child(sidebar_right)

	info_panel = Panel.new()
	info_panel.visible = false
	hud.add_child(info_panel)

	info_label = RichTextLabel.new()
	info_label.anchor_right = 1.0
	info_label.anchor_bottom = 1.0
	info_label.offset_left = 8
	info_label.offset_top = 4
	info_label.offset_right = -4
	info_label.offset_bottom = -4
	info_label.bbcode_enabled = true
	info_label.fit_content = true
	info_label.scroll_active = false
	info_label.add_theme_font_size_override("normal_font_size", 12)
	info_panel.add_child(info_label)

	action_menu = Panel.new()
	action_menu.size = Vector2(240, 100)
	action_menu.visible = false
	ui_layer.add_child(action_menu)

	attack_btn = Button.new()
	attack_btn.position = Vector2(10, 10)
	attack_btn.size = Vector2(100, 36)
	attack_btn.text = "攻击"
	action_menu.add_child(attack_btn)

	wait_btn = Button.new()
	wait_btn.position = Vector2(130, 10)
	wait_btn.size = Vector2(100, 36)
	wait_btn.text = "待机"
	action_menu.add_child(wait_btn)

	battle_preview = Panel.new()
	battle_preview.size = Vector2(420, 240)
	battle_preview.visible = false
	ui_layer.add_child(battle_preview)

	preview_label = RichTextLabel.new()
	preview_label.anchor_right = 1.0
	preview_label.anchor_bottom = 1.0
	preview_label.offset_left = 10
	preview_label.offset_top = 10
	preview_label.offset_right = -10
	preview_label.offset_bottom = -10
	preview_label.bbcode_enabled = true
	preview_label.fit_content = true
	preview_label.scroll_active = false
	battle_preview.add_child(preview_label)

	confirm_btn = Button.new()
	confirm_btn.text = "确认攻击"
	confirm_btn.position = Vector2(130, 200)
	confirm_btn.size = Vector2(140, 30)
	battle_preview.add_child(confirm_btn)

	cancel_btn = Button.new()
	cancel_btn.text = "取消"
	cancel_btn.position = Vector2(290, 200)
	cancel_btn.size = Vector2(60, 30)
	battle_preview.add_child(cancel_btn)

	game_over_panel = Panel.new()
	game_over_panel.size = Vector2(400, 160)
	game_over_panel.visible = false
	ui_layer.add_child(game_over_panel)

	result_label = Label.new()
	result_label.position = Vector2(80, 30)
	result_label.size = Vector2(240, 50)
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 28)
	game_over_panel.add_child(result_label)

	next_chapter_btn = Button.new()
	next_chapter_btn.text = "下一章"
	next_chapter_btn.position = Vector2(120, 60)
	next_chapter_btn.size = Vector2(160, 40)
	next_chapter_btn.visible = false
	game_over_panel.add_child(next_chapter_btn)

	restart_btn = Button.new()
	restart_btn.text = "重新开始"
	restart_btn.position = Vector2(120, 110)
	restart_btn.size = Vector2(160, 40)
	game_over_panel.add_child(restart_btn)

	level_up_label = Label.new()
	level_up_label.size = Vector2(320, 40)
	level_up_label.visible = false
	level_up_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_up_label.add_theme_font_size_override("font_size", 20)
	level_up_label.add_theme_color_override("font_color", Color(0, 1, 0.4, 1))
	ui_layer.add_child(level_up_label)

func _start_battle():
	var map_data = MapData.new().get_map()
	map_controller.setup_map(map_data)
	_spawn_units(map_data)

	_center_map_and_setup_ui()

	ai_controller.setup(map_controller, combat_system)
	TurnManager.start_battle()
	_update_hud()

func _center_map_and_setup_ui():
	var window_size = DisplayServer.window_get_size()
	var map_pixel = map_controller.get_map_pixel_size()
	var map_origin = Vector2(
		max(0.0, (window_size.x - map_pixel.x) / 2),
		max(0.0, (window_size.y - map_pixel.y) / 2)
	)
	$Map.position = map_origin
	$Units.position = map_origin
	_position_ui(window_size, map_pixel, map_origin)

func _position_ui(window_size: Vector2, map_pixel: Vector2, map_origin: Vector2):
	var is_wide = window_size.x >= window_size.y
	var top_bar_h = 44
	var gap = 6
	var sidebar_margin = 4

	turn_label.position = Vector2(8, 6)
	phase_label.position = Vector2(8, 26)

	if is_wide:
		end_turn_btn.position = Vector2(window_size.x - end_turn_btn.size.x - 8, 4)

		var left_w = map_origin.x - gap
		var right_w = window_size.x - (map_origin.x + map_pixel.x) - gap

		sidebar_left.visible = true
		sidebar_left.position = Vector2(0, top_bar_h + gap)
		sidebar_left.size = Vector2(left_w, window_size.y - top_bar_h - gap)

		sidebar_right.visible = true
		sidebar_right.position = Vector2(map_origin.x + map_pixel.x + gap, top_bar_h + gap)
		sidebar_right.size = Vector2(right_w, window_size.y - top_bar_h - gap)

		info_panel.position = Vector2(map_origin.x + map_pixel.x + gap + sidebar_margin, top_bar_h + gap + sidebar_margin)
		info_panel.size = Vector2(right_w - sidebar_margin * 2, window_size.y - top_bar_h - gap * 2 - sidebar_margin * 2)
	else:
		end_turn_btn.position = Vector2(window_size.x - end_turn_btn.size.x - 8, 4)

		sidebar_left.visible = false
		sidebar_right.visible = false

		var panel_y = map_origin.y + map_pixel.y + gap
		var panel_h = window_size.y - panel_y

		info_panel.position = Vector2(4, panel_y + 2)
		info_panel.size = Vector2(window_size.x - 8, panel_h - 48)

	game_over_panel.position = Vector2((window_size.x - game_over_panel.size.x) / 2, (window_size.y - game_over_panel.size.y) / 2)
	battle_preview.position = Vector2((window_size.x - battle_preview.size.x) / 2, (window_size.y - battle_preview.size.y) / 2)

func _spawn_units(map_data: Dictionary):
	for child in units_node.get_children():
		child.queue_free()
	GameState.player_units.clear()
	GameState.enemy_units.clear()

	for dep in map_data.get("player_deployments", []):
		var unit = unit_scene.instantiate()
		unit.setup_from_preset(dep["preset"])
		unit.grid_position = dep["pos"]
		unit.set_grid_position(dep["pos"])
		unit.unit_clicked.connect(_on_unit_clicked)
		unit.unit_died.connect(_on_unit_died)
		unit.leveled_up.connect(_on_unit_leveled_up)
		units_node.add_child(unit)
		GameState.player_units.append(unit)

	for dep in map_data.get("enemy_deployments", []):
		var unit = unit_scene.instantiate()
		unit.setup_from_preset(dep["preset"])
		unit.grid_position = dep["pos"]
		unit.set_grid_position(dep["pos"])
		unit.unit_clicked.connect(_on_unit_clicked)
		unit.unit_died.connect(_on_unit_died)
		units_node.add_child(unit)
		GameState.enemy_units.append(unit)

func _on_tile_clicked(pos: Vector2i):
	if GameState.current_phase != GameState.Phase.PLAYER:
		return

	var selected = GameState.selected_unit
	if selected == null:
		return

	if TurnManager.has_unit_acted(selected):
		_clear_selection()
		return

	if selecting_attack_target:
		map_controller.clear_attack_highlights()
		selecting_attack_target = false
		attack_targets.clear()
		_show_action_menu(selected.grid_position)
		return

	if not action_menu.visible:
		return

	var move_range = map_controller.get_move_range(selected.grid_position, selected.current_stats["mov"], selected.unit_data["move_type"])
	if pos in move_range:
		_show_action_menu(pos)

func _on_unit_clicked(unit: Node):
	if GameState.current_phase != GameState.Phase.PLAYER:
		return
	if unit.allegiance != "player":
		if selecting_attack_target and unit in attack_targets:
			map_controller.clear_attack_highlights()
			selecting_attack_target = false
			current_action_target = unit
			_show_battle_preview(GameState.selected_unit, unit, current_target, unit.grid_position)
		else:
			_show_unit_info(unit)
		return
	if TurnManager.has_unit_acted(unit):
		return
	_select_unit(unit)

func _select_unit(unit: Node):
	_clear_selection()
	GameState.selected_unit = unit
	map_controller.clear_all_highlights()

	var move_range = map_controller.get_move_range(unit.grid_position, unit.current_stats["mov"], unit.unit_data["move_type"])
	map_controller.highlight_move_range(move_range)
	_show_unit_info(unit)
	_show_action_menu(unit.grid_position)

func _clear_selection():
	GameState.selected_unit = null
	map_controller.clear_all_highlights()
	info_panel.visible = false
	action_menu.visible = false
	battle_preview.visible = false
	selecting_attack_target = false
	attack_targets.clear()

func _show_unit_info(unit: Node):
	info_panel.visible = true
	var s = unit.current_stats
	var w = unit.weapon
	var terrain = unit.apply_terrain_bonus(unit.grid_position)

	var text = "[b]%s[/b]  Lv.%d  HP:%d/%d\n" % [unit.get_class_name_str(), unit.level, s["hp"], s["max_hp"]]
	text += "力:%d  魔:%d  技:%d  速:%d  防:%d  魔防:%d\n" % [s["str"], s["mag"], s["skl"], s["spd"], s["def"], s["res"]]
	text += "武器:%s  威力:%d  命中:%d\n" % [w.get("name", "无"), w.get("might", 0), w.get("hit", 0)]
	text += "地形:%s  防御+%d  回避+%d" % [terrain["name"], terrain["defense"], terrain["avoid"]]
	info_label.text = text

func _on_attack_pressed():
	action_menu.visible = false
	var selected = GameState.selected_unit
	if selected == null:
		return

	original_position = selected.grid_position
	selected.set_grid_position(current_target)
	selected.grid_position = current_target

	var weapon = selected.weapon
	var atk_range = map_controller.get_attack_range(current_target, weapon.get("range_min", 1), weapon.get("range_max", 1))

	attack_targets.clear()
	for pos in atk_range:
		var unit = GameState.get_unit_at(pos)
		if unit and unit.allegiance == "enemy":
			attack_targets.append(unit)

	if attack_targets.is_empty():
		_clear_selection()
		return

	if attack_targets.size() == 1:
		current_action_target = attack_targets[0]
		_show_battle_preview(selected, current_action_target, current_target, current_action_target.grid_position)
		return

	map_controller.highlight_attack_range(atk_range)
	selecting_attack_target = true

func _on_wait_pressed():
	action_menu.visible = false
	var selected = GameState.selected_unit
	if selected:
		selected.set_grid_position(current_target)
		selected.grid_position = current_target
		TurnManager.mark_unit_acted(selected)
	_clear_selection()

func _show_battle_preview(atk: Node, def: Node, atk_pos: Vector2i, def_pos: Vector2i):
	var preview = combat_system.calculate_preview(atk, def, atk_pos, def_pos)
	battle_preview.visible = true

	var text = "[center][b]战斗预览[/b][/center]\n\n"
	text += "攻击方: %s  伤害: %d  命中: %d%%\n" % [atk.get_class_name_str(), preview["damage"], preview["hit_rate"]]
	text += "防御方: %s\n" % def.get_class_name_str()

	if preview.get("triangle_bonus", 0) != 0:
		var tri_name = UnitData.get_triangle_advantage_name(preview["triangle_advantage"])
		var bonus_str = "+%d" % preview["triangle_bonus"] if preview["triangle_bonus"] > 0 else "%d" % preview["triangle_bonus"]
		text += "[color=orange]%s (攻击%s)[/color]\n" % [tri_name, bonus_str]

	if preview["can_double"]:
		text += "[color=red]追击可能![/color]\n"
	if preview["can_counter"]:
		text += "敌方可以反击\n"
	preview_label.text = text

func _on_confirm_attack():
	battle_preview.visible = false
	var selected = GameState.selected_unit
	if selected and current_action_target:
		combat_system.execute_combat(selected, current_action_target, selected.grid_position, current_action_target.grid_position)
		TurnManager.mark_unit_acted(selected)
	_clear_selection()

func _on_cancel_attack():
	battle_preview.visible = false
	var selected = GameState.selected_unit
	if selected and original_position != selected.grid_position:
		selected.set_grid_position(original_position)
		selected.grid_position = original_position
	_clear_selection()

func _on_end_turn():
	if GameState.current_phase != GameState.Phase.PLAYER:
		return
	_clear_selection()
	TurnManager.start_enemy_turn()
	_update_hud()

func _on_phase_changed(phase):
	_update_hud()
	match phase:
		GameState.Phase.VICTORY:
			game_over_panel.visible = true
			result_label.text = "胜利!"
			next_chapter_btn.visible = true
			restart_btn.visible = true
		GameState.Phase.DEFEAT:
			game_over_panel.visible = true
			result_label.text = "败北..."
			next_chapter_btn.visible = false
			restart_btn.visible = true

func _on_unit_acted(unit: Node):
	if GameState.current_phase == GameState.Phase.PLAYER:
		if TurnManager.check_victory():
			return
		if TurnManager.all_player_units_acted():
			info_panel.visible = true
			info_label.text = "[center]所有单位已行动，自动结束回合…[/center]"
			await get_tree().create_timer(0.8).timeout
			info_panel.visible = false
			_on_end_turn()

func _on_combat_ended(atk, def, result):
	_update_hud()

func _on_unit_died(unit: Node):
	GameState.remove_unit(unit)
	unit.queue_free()
	if GameState.current_phase == GameState.Phase.PLAYER:
		TurnManager.check_defeat()
		if not GameState.current_phase == GameState.Phase.DEFEAT:
			TurnManager.check_victory()
	else:
		TurnManager.check_defeat()

func _update_hud():
	match GameState.current_phase:
		GameState.Phase.PLAYER:
			turn_label.text = "玩家回合"
			end_turn_btn.disabled = false
		GameState.Phase.ENEMY:
			turn_label.text = "敌方回合"
			end_turn_btn.disabled = true
		GameState.Phase.VICTORY:
			turn_label.text = "胜利!"
			end_turn_btn.disabled = true
		GameState.Phase.DEFEAT:
			turn_label.text = "败北..."
			end_turn_btn.disabled = true
	phase_label.text = "第%d回合" % GameState.turn_count

func _on_unit_leveled_up(unit: Node):
	level_up_label.text = "%s 升级为 Lv.%d!" % [unit.get_class_name_str(), unit.level]
	level_up_label.visible = true
	var ws = DisplayServer.window_get_size()
	level_up_label.position = Vector2((ws.x - level_up_label.size.x) / 2, ws.y / 2 - 40)
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(level_up_label, "visible", false, 0)

func _on_next_chapter():
	game_over_panel.visible = false
	next_chapter_btn.visible = false
	GameState.reset()
	_start_battle_with_map(MapData.MapID.CHAPTER_2)

func _start_battle_with_map(map_id: int):
	var map_data = MapData.new().get_map(map_id)
	map_controller.setup_map(map_data)
	_spawn_units(map_data)

	_center_map_and_setup_ui()

	ai_controller.setup(map_controller, combat_system)
	TurnManager.start_battle()
	_update_hud()

func _has_enemy_in_range(range_positions: Array) -> bool:
	for pos in range_positions:
		var unit = GameState.get_unit_at(pos)
		if unit and unit.allegiance == "enemy":
			return true
	return false

func _show_action_menu(pos: Vector2i):
	var selected = GameState.selected_unit
	if selected == null:
		return
	current_target = pos
	var weapon = selected.weapon
	var atk_range = map_controller.get_attack_range(pos, weapon.get("range_min", 1), weapon.get("range_max", 1))
	attack_btn.visible = _has_enemy_in_range(atk_range)
	var world_pos = $Map.position + map_controller.grid_to_world(pos)
	action_menu.position = world_pos - action_menu.size / 2
	action_menu.visible = true

func _on_restart():
	game_over_panel.visible = false
	next_chapter_btn.visible = false
	GameState.reset()
	get_tree().reload_current_scene()
