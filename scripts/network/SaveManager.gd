extends Node

var api: Node = null
var user_id: String = ""
var username: String = ""

func setup(_api: Node):
	api = _api

func save_current_game(save_name: String):
	if user_id.is_empty():
		return
	var data = {
		"map_name": GameState.current_map_data.get("name", "test"),
		"turn": GameState.turn_count,
		"gold": GameState.gold,
		"phase": GameState.current_phase,
		"units": _serialize_units()
	}
	api.save_game(user_id, save_name, data, _on_save_result)

func load_game(save_data: Dictionary):
	GameState.current_phase = save_data["phase"]
	GameState.turn_count = save_data["turn"]
	GameState.gold = save_data.get("gold", 0)

func _serialize_units() -> Array:
	var result = []
	for unit in GameState.player_units:
		result.append({
			"class_name": unit.get_class_name_str(),
			"grid_pos": {"x": unit.grid_position.x, "y": unit.grid_position.y},
			"stats": unit.current_stats,
			"level": unit.level,
			"allegiance": unit.allegiance
		})
	for unit in GameState.enemy_units:
		result.append({
			"class_name": unit.get_class_name_str(),
			"grid_pos": {"x": unit.grid_position.x, "y": unit.grid_position.y},
			"stats": unit.current_stats,
			"level": unit.level,
			"allegiance": unit.allegiance
		})
	return result

func _on_save_result(success: bool, data):
	if success:
		print("Save successful")
	else:
		print("Save failed: ", data)
