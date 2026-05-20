extends GdUnitTestSuite

# Test player-controllable unit movement system
# Covers: get_move_range, find_path, terrain costs, boundary checks, unit blocking

var _map_controller: Node
var _game_state: Node

# Mock a simple unit for testing occupancy
class TestUnit:
	var grid_position: Vector2i
	var is_dead: bool = false

	func _init(pos: Vector2i):
		grid_position = pos

	func is_alive() -> bool:
		return not is_dead


func before():
	# Create MapController instance for testing
	_map_controller = load("res://scripts/battle/MapController.gd").new()

	# Setup a simple 10x10 flat map for isolated tests
	var flat_map = {
		"width": 10,
		"height": 10,
		"tiles": []
	}
	for y in range(10):
		var row = []
		for x in range(10):
			row.append(0)  # 0 = 平地, cost 1
		flat_map["tiles"].append(row)

	_map_controller.setup_map(flat_map)

	# Ensure GameState is in a known state
	GameState.reset()
	GameState.current_map_data = flat_map


func before_each():
	# Clear units between tests
	GameState.player_units.clear()
	GameState.enemy_units.clear()


# ── 基础移动范围测试 ──

func test_move_range_basic():
	# Unit with 5 movement from (0,0) on flat terrain
	var move_range = _map_controller.get_move_range(Vector2i(0, 0), 5, UnitData.MoveType.INFANTRY)

	assert_int(len(move_range)).is_greater(0)

	# (5,0) is 5 steps away, should be reachable
	assert_bool(Vector2i(5, 0) in move_range).is_true()

	# (0,5) is 5 steps away, should be reachable
	assert_bool(Vector2i(0, 5) in move_range).is_true()

	# (3,3) is 6 steps away, should NOT be reachable
	assert_bool(Vector2i(3, 3) in move_range).is_false()


func test_move_range_zero_movement():
	var move_range = _map_controller.get_move_range(Vector2i(5, 5), 0, UnitData.MoveType.INFANTRY)
	assert_int(len(move_range)).is_equal(0)


func test_move_range_start_not_in_result():
	var move_range = _map_controller.get_move_range(Vector2i(3, 3), 3, UnitData.MoveType.INFANTRY)
	assert_bool(Vector2i(3, 3) in move_range).is_false()


# ── 边界测试 ──

func test_move_range_out_of_bounds():
	var move_range = _map_controller.get_move_range(Vector2i(0, 0), 20, UnitData.MoveType.INFANTRY)

	for pos in move_range:
		assert_bool(pos.x >= 0).is_true()
		assert_bool(pos.x < 10).is_true()
		assert_bool(pos.y >= 0).is_true()
		assert_bool(pos.y < 10).is_true()


# ── 地形消耗测试 ──

func test_terrain_cost_blocks_river():
	var blocked_map = {
		"width": 5,
		"height": 5,
		"tiles": [
			[0, 3, 0, 0, 0],
			[0, 3, 0, 0, 0],
			[0, 3, 0, 0, 0],
			[0, 3, 0, 0, 0],
			[0, 3, 0, 0, 0],
		]
	}
	_map_controller.setup_map(blocked_map)
	GameState.current_map_data = blocked_map

	var move_range = _map_controller.get_move_range(Vector2i(0, 2), 10, UnitData.MoveType.INFANTRY)

	# River at x=1 blocks eastward movement
	assert_bool(Vector2i(2, 2) in move_range).is_false()

	# Tiles on same side still reachable
	assert_bool(Vector2i(0, 0) in move_range).is_true()


func test_terrain_high_cost_limits():
	var terrain_map = {
		"width": 4,
		"height": 4,
		"tiles": [
			[0, 1, 2, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
		]
	}
	_map_controller.setup_map(terrain_map)
	GameState.current_map_data = terrain_map

	var move_range = _map_controller.get_move_range(Vector2i(0, 0), 2, UnitData.MoveType.INFANTRY)

	# (1,0) is forest (cost 2), reachable
	assert_bool(Vector2i(1, 0) in move_range).is_true()

	# (2,0) costs 5 (forest + mountain), NOT reachable
	assert_bool(Vector2i(2, 0) in move_range).is_false()

	# (0,1) flat (cost 1), reachable
	assert_bool(Vector2i(0, 1) in move_range).is_true()

	# (1,1) via (0,1): 1+1=2, reachable
	assert_bool(Vector2i(1, 1) in move_range).is_true()


# ── 单位阻挡测试 ──

func test_unit_blocks_tile():
	var enemy = TestUnit.new(Vector2i(2, 0))
	GameState.enemy_units = [enemy]

	var move_range = _map_controller.get_move_range(Vector2i(0, 0), 5, UnitData.MoveType.INFANTRY)

	# Occupied tile not in move range
	assert_bool(Vector2i(2, 0) in move_range).is_false()

	# Can go around
	assert_bool(Vector2i(2, 1) in move_range).is_true()


func test_dead_unit_does_not_block():
	var dead_enemy = TestUnit.new(Vector2i(2, 0))
	dead_enemy.is_dead = true
	GameState.enemy_units = [dead_enemy]

	var move_range = _map_controller.get_move_range(Vector2i(0, 0), 5, UnitData.MoveType.INFANTRY)

	# Dead units don't block (GameState.get_unit_at checks is_alive())
	assert_bool(Vector2i(2, 0) in move_range).is_true()


# ── A* 寻路测试 ──

func test_find_path_direct():
	var path = _map_controller.find_path(Vector2i(0, 0), Vector2i(3, 0), UnitData.MoveType.INFANTRY)

	assert_int(len(path)).is_greater(0)
	assert_bool(Vector2i(1, 0) in path).is_true()
	assert_bool(Vector2i(2, 0) in path).is_true()
	assert_bool(Vector2i(3, 0) in path).is_true()


func test_find_path_around_river():
	var terrain_map = {
		"width": 4,
		"height": 3,
		"tiles": [
			[0, 0, 3, 0],
			[0, 0, 3, 0],
			[0, 3, 0, 0],
		]
	}
	_map_controller.setup_map(terrain_map)
	GameState.current_map_data = terrain_map

	var path = _map_controller.find_path(Vector2i(0, 0), Vector2i(3, 0), UnitData.MoveType.INFANTRY)
	# Should go around the river (down or up)
	assert_int(len(path)).is_greater(0)


func test_find_path_no_path():
	var terrain_map = {
		"width": 3,
		"height": 3,
		"tiles": [
			[3, 3, 3],
			[3, 0, 3],
			[3, 3, 3],
		]
	}
	_map_controller.setup_map(terrain_map)
	GameState.current_map_data = terrain_map

	var path = _map_controller.find_path(Vector2i(1, 1), Vector2i(0, 0), UnitData.MoveType.INFANTRY)
	assert_int(len(path)).is_equal(0)


func test_find_path_start_equals_end():
	var path = _map_controller.find_path(Vector2i(5, 5), Vector2i(5, 5), UnitData.MoveType.INFANTRY)
	assert_int(len(path)).is_equal(0)


# ── 工具函数测试 ──

func test_is_in_bounds():
	assert_bool(_map_controller.is_in_bounds(Vector2i(0, 0))).is_true()
	assert_bool(_map_controller.is_in_bounds(Vector2i(9, 9))).is_true()
	assert_bool(_map_controller.is_in_bounds(Vector2i(-1, 0))).is_false()
	assert_bool(_map_controller.is_in_bounds(Vector2i(0, 10))).is_false()


func test_get_terrain_cost():
	assert_int(_map_controller.get_terrain_cost(Vector2i(0, 0))).is_equal(1)
	assert_int(_map_controller.get_terrain_cost(Vector2i(100, 100))).is_equal(999)


func test_attack_range_bow():
	var atk_range = _map_controller.get_attack_range(Vector2i(5, 5), 2, 2)
	assert_bool(Vector2i(3, 5) in atk_range).is_true()
	assert_bool(Vector2i(4, 4) in atk_range).is_true()
	assert_bool(Vector2i(4, 5) in atk_range).is_false()
	assert_bool(Vector2i(5, 5) in atk_range).is_false()


func test_attack_range_sword():
	var atk_range = _map_controller.get_attack_range(Vector2i(5, 5), 1, 1)
	assert_int(len(atk_range)).is_equal(4)
	assert_bool(Vector2i(5, 4) in atk_range).is_true()
	assert_bool(Vector2i(5, 6) in atk_range).is_true()


# ── BFS 重复项验证 ──

func test_move_range_no_duplicates():
	var mix_map = {
		"width": 4,
		"height": 3,
		"tiles": [
			[0, 1, 1, 0],
			[0, 0, 0, 0],
			[0, 0, 0, 0],
		]
	}
	_map_controller.setup_map(mix_map)
	GameState.current_map_data = mix_map

	var move_range = _map_controller.get_move_range(Vector2i(0, 1), 3, UnitData.MoveType.INFANTRY)

	var seen = {}
	for pos in move_range:
		var key = "%d,%d" % [pos.x, pos.y]
		if seen.has(key):
			assert_bool(false, "Duplicate tile in move range: " + key).is_true()
		seen[key] = true
