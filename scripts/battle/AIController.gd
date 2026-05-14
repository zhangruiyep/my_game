extends Node

var map_controller: Node = null
var combat_system: Node = null
var units_to_process: Array = []
var current_ai_unit: Node = null

signal ai_turn_complete

func _ready():
	TurnManager.enemy_turn_started.connect(_on_enemy_turn)

func setup(_map_controller: Node, _combat_system: Node):
	map_controller = _map_controller
	combat_system = _combat_system

func _on_enemy_turn():
	units_to_process = GameState.enemy_units.duplicate()
	_process_next_unit()

func _process_next_unit():
	if units_to_process.is_empty():
		_on_all_enemies_done()
		return

	current_ai_unit = units_to_process.pop_front()
	if not current_ai_unit.is_alive():
		_process_next_unit()
		return

	await get_tree().create_timer(0.5).timeout
	_execute_enemy_action()

func _execute_enemy_action():
	var enemy = current_ai_unit
	var move_range = enemy.current_stats["mov"]
	var move_type = enemy.unit_data["move_type"]
	var reachable = map_controller.get_move_range(enemy.grid_position, move_range, move_type)

	var best_target: Node = null
	var best_distance: int = 9999

	for player_unit in GameState.player_units:
		if not player_unit.is_alive():
			continue
		var dist = abs(enemy.grid_position.x - player_unit.grid_position.x) + abs(enemy.grid_position.y - player_unit.grid_position.y)
		if dist < best_distance:
			best_distance = dist
			best_target = player_unit

	if best_target == null:
		_after_action()
		return

	var weapon_range = enemy.weapon.get("range_max", 1)
	var current_dist = abs(enemy.grid_position.x - best_target.grid_position.x) + abs(enemy.grid_position.y - best_target.grid_position.y)

	if current_dist <= weapon_range:
		_attack_target(enemy, best_target)
		return

	var best_move: Vector2i = enemy.grid_position
	var best_new_dist: int = 9999

	for pos in reachable:
		var new_dist = abs(pos.x - best_target.grid_position.x) + abs(pos.y - best_target.grid_position.y)
		if new_dist < best_new_dist:
			best_new_dist = new_dist
			best_move = pos

	if best_move != enemy.grid_position:
		var path = map_controller.find_path(enemy.grid_position, best_move, move_type)
		if not path.is_empty():
			enemy.set_grid_position(path[-1])
			enemy.grid_position = path[-1]
			await get_tree().create_timer(0.3).timeout

	current_dist = abs(enemy.grid_position.x - best_target.grid_position.x) + abs(enemy.grid_position.y - best_target.grid_position.y)
	if current_dist <= weapon_range:
		_attack_target(enemy, best_target)
	else:
		_after_action()

func _attack_target(attacker: Node, target: Node):
	combat_system.execute_combat(attacker, target, attacker.grid_position, target.grid_position)
	await get_tree().create_timer(0.5).timeout
	_after_action()

func _after_action():
	TurnManager.mark_unit_acted(current_ai_unit)
	if TurnManager.check_defeat():
		return
	await get_tree().create_timer(0.3).timeout
	_process_next_unit()

func _on_all_enemies_done():
	TurnManager.end_enemy_turn()
