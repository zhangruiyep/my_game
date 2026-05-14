extends Node

enum TurnState { WAITING, UNIT_SELECTED, UNIT_MOVING, ACTION_MENU, BATTLE_PREVIEW, ANIMATING }

var state: TurnState = TurnState.WAITING
var current_unit: Node = null
var units_moved_this_turn: Array = []

signal player_turn_started
signal enemy_turn_started
signal phase_changed(new_phase)
signal unit_acted(unit)
signal turn_ended

func start_battle():
	GameState.current_phase = GameState.Phase.PLAYER
	GameState.turn_count = 1
	units_moved_this_turn.clear()
	phase_changed.emit(GameState.current_phase)
	player_turn_started.emit()

func start_enemy_turn():
	GameState.current_phase = GameState.Phase.ENEMY
	units_moved_this_turn.clear()
	phase_changed.emit(GameState.current_phase)
	enemy_turn_started.emit()

func end_enemy_turn():
	GameState.turn_count += 1
	GameState.current_phase = GameState.Phase.PLAYER
	units_moved_this_turn.clear()
	phase_changed.emit(GameState.current_phase)
	player_turn_started.emit()

func mark_unit_acted(unit: Node):
	if unit not in units_moved_this_turn:
		units_moved_this_turn.append(unit)
	unit_acted.emit(unit)

func has_unit_acted(unit: Node) -> bool:
	return unit in units_moved_this_turn

func check_victory() -> bool:
	for unit in GameState.enemy_units:
		if unit.is_alive():
			return false
	GameState.current_phase = GameState.Phase.VICTORY
	phase_changed.emit(GameState.current_phase)
	return true

func check_defeat() -> bool:
	for unit in GameState.player_units:
		if unit.is_alive() and unit.class_type == UnitData.ClassType.LORD:
			return false
	GameState.current_phase = GameState.Phase.DEFEAT
	phase_changed.emit(GameState.current_phase)
	return true
