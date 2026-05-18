extends Node2D

const TILE_SIZE: int = 64
var grid_width: int = 10
var grid_height: int = 10
var tiles: Array = []
var highlighter_scene = preload("res://scenes/battle/TileHighlighter.tscn")

var move_highlights: Array = []
var attack_highlights: Array = []
var move_path: Array = []

signal tile_clicked(grid_pos)
signal unit_move_complete

func _ready():
	pass

func setup_map(map_data: Dictionary):
	grid_width = map_data["width"]
	grid_height = map_data["height"]
	tiles = map_data["tiles"]
	GameState.current_map_data = map_data
	_draw_map()

func _draw_map():
	for y in range(grid_height):
		for x in range(grid_width):
			var tile = _create_tile_sprite(x, y)
			add_child(tile)

func _create_tile_sprite(x: int, y: int) -> TextureRect:
	var tex_rect = TextureRect.new()
	tex_rect.name = "Tile_%d_%d" % [x, y]
	tex_rect.size = Vector2(TILE_SIZE - 2, TILE_SIZE - 2)
	tex_rect.position = Vector2(x * TILE_SIZE + 1, y * TILE_SIZE + 1)
	tex_rect.texture = UnitData.generate_terrain_texture(tiles[y][x])
	tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
	tex_rect.mouse_filter = Control.MOUSE_FILTER_STOP

	tex_rect.gui_input.connect(_on_tile_input.bind(x, y))
	return tex_rect

func _on_tile_input(event: InputEvent, x: int, y: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tile_clicked.emit(Vector2i(x, y))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * TILE_SIZE + TILE_SIZE / 2, grid_pos.y * TILE_SIZE + TILE_SIZE / 2)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / TILE_SIZE), int(world_pos.y / TILE_SIZE))

func is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height

func get_terrain_cost(pos: Vector2i) -> int:
	if not is_in_bounds(pos):
		return 999
	return UnitData.get_terrain_data(tiles[pos.y][pos.x])["movement_cost"]

func is_passable(pos: Vector2i, ignore_units: bool = false) -> bool:
	if not is_in_bounds(pos):
		return false
	var cost = get_terrain_cost(pos)
	if cost >= 999:
		return false
	if not ignore_units:
		if GameState.get_unit_at(pos) != null:
			return false
	return true

func get_move_range(start: Vector2i, move_points: int, move_type: int) -> Array:
	var result: Array = []
	var open: Array = [start]
	var visited: Dictionary = {}
	visited["%d,%d" % [start.x, start.y]] = 0

	while not open.is_empty():
		var current = open.pop_front()
		var current_cost = visited["%d,%d" % [current.x, current.y]]

		for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next = current + dir
			if not is_in_bounds(next):
				continue
			var terrain_cost = get_terrain_cost(next)
			if terrain_cost >= 999:
				continue
			var total_cost = current_cost + terrain_cost
			var key = "%d,%d" % [next.x, next.y]

			if total_cost > move_points:
				continue
			if key in visited and visited[key] <= total_cost:
				continue

			visited[key] = total_cost
			open.append(next)
			if next != start and GameState.get_unit_at(next) == null:
				result.append(next)

	return result

func get_attack_range(start: Vector2i, weapon_min: int, weapon_max: int) -> Array:
	var result: Array = []
	for y in range(-weapon_max, weapon_max + 1):
		for x in range(-weapon_max, weapon_max + 1):
			if x == 0 and y == 0:
				continue
			var dist = abs(x) + abs(y)
			if dist >= weapon_min and dist <= weapon_max:
				var pos = start + Vector2i(x, y)
				if is_in_bounds(pos):
					result.append(pos)
	return result

func find_path(start: Vector2i, end: Vector2i, move_type: int) -> Array:
	var open_set: Array = [start]
	var came_from: Dictionary = {}
	var g_score: Dictionary = {}
	var f_score: Dictionary = {}

	var start_key = "%d,%d" % [start.x, start.y]
	g_score[start_key] = 0
	f_score[start_key] = _heuristic(start, end)

	while not open_set.is_empty():
		var current: Vector2i = open_set[0]
		var current_key = "%d,%d" % [current.x, current.y]
		var lowest_f = f_score.get(current_key, 9999)

		for node in open_set:
			var key = "%d,%d" % [node.x, node.y]
			var f = f_score.get(key, 9999)
			if f < lowest_f:
				lowest_f = f
				current = node
				current_key = key

		if current == end:
			return _reconstruct_path(came_from, current, start)

		open_set.erase(current)

		for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var neighbor = current + dir
			if not is_in_bounds(neighbor):
				continue
			var terrain_cost = get_terrain_cost(neighbor)
			if terrain_cost >= 999:
				continue
			var neighbor_key = "%d,%d" % [neighbor.x, neighbor.y]
			var tentative_g = g_score.get(current_key, 9999) + terrain_cost

			if neighbor != end and GameState.get_unit_at(neighbor) != null:
				continue

			if tentative_g < g_score.get(neighbor_key, 9999):
				came_from[neighbor_key] = current
				g_score[neighbor_key] = tentative_g
				f_score[neighbor_key] = tentative_g + _heuristic(neighbor, end)
				if neighbor not in open_set:
					open_set.append(neighbor)

	return []

func _heuristic(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

func _reconstruct_path(came_from: Dictionary, current: Vector2i, start: Vector2i) -> Array:
	var path: Array = [current]
	var current_key = "%d,%d" % [current.x, current.y]
	while current_key in came_from:
		current = came_from[current_key]
		current_key = "%d,%d" % [current.x, current.y]
		if current != start:
			path.insert(0, current)
	return path

func highlight_move_range(positions: Array, color: Color = Color(0.2, 0.5, 1.0, 0.4)):
	clear_move_highlights()
	for pos in positions:
		var hl = highlighter_scene.instantiate()
		hl.position = Vector2(pos.x * TILE_SIZE, pos.y * TILE_SIZE)
		hl.color = color
		add_child(hl)
		move_highlights.append(hl)

func highlight_attack_range(positions: Array, color: Color = Color(1.0, 0.2, 0.2, 0.4)):
	clear_attack_highlights()
	for pos in positions:
		var hl = highlighter_scene.instantiate()
		hl.position = Vector2(pos.x * TILE_SIZE, pos.y * TILE_SIZE)
		hl.color = color
		add_child(hl)
		attack_highlights.append(hl)

func draw_path(path: Array):
	for pos in path:
		var hl = highlighter_scene.instantiate()
		hl.position = Vector2(pos.x * TILE_SIZE, pos.y * TILE_SIZE)
		hl.color = Color(0.0, 1.0, 0.0, 0.5)
		add_child(hl)
		move_highlights.append(hl)

func clear_move_highlights():
	for hl in move_highlights:
		hl.queue_free()
	move_highlights.clear()

func clear_attack_highlights():
	for hl in attack_highlights:
		hl.queue_free()
	attack_highlights.clear()

func clear_all_highlights():
	clear_move_highlights()
	clear_attack_highlights()
