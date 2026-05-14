extends Node

enum Phase { NONE, PLAYER, ENEMY, VICTORY, DEFEAT }

var current_phase: Phase = Phase.NONE
var player_units: Array = []
var enemy_units: Array = []
var current_map_data: Dictionary = {}

var turn_count: int = 0
var gold: int = 0

var selected_unit: Node = null

func reset():
	current_phase = Phase.NONE
	player_units.clear()
	enemy_units.clear()
	current_map_data.clear()
	turn_count = 0
	gold = 0
	selected_unit = null

func get_all_units() -> Array:
	return player_units + enemy_units

func get_unit_at(grid_pos: Vector2i) -> Node:
	for unit in get_all_units():
		if unit.grid_position == grid_pos and unit.is_alive():
			return unit
	return null

func remove_unit(unit: Node):
	player_units.erase(unit)
	enemy_units.erase(unit)
