extends Node
class_name UnitData

enum ClassType { LORD, CAVALIER, KNIGHT, MERCENARY, ARCHER, MAGE, CLERIC, BANDIT }
enum MoveType { INFANTRY, CAVALRY, ARMORED, FLYING }
enum WeaponType { SWORD, LANCE, AXE, BOW, MAGIC, STAFF }

static func get_class_data(class_type: ClassType) -> Dictionary:
	match class_type:
		ClassType.LORD:
			return {
				"name": "领主",
				"move_type": MoveType.INFANTRY,
				"base_movement": 5,
				"usable_weapons": [WeaponType.SWORD],
				"promotes_to": -1,
				"growths": { "hp": 80, "str": 50, "mag": 5, "skl": 50, "spd": 50, "def": 30, "res": 25 }
			}
		ClassType.CAVALIER:
			return {
				"name": "骑士",
				"move_type": MoveType.CAVALRY,
				"base_movement": 7,
				"usable_weapons": [WeaponType.SWORD, WeaponType.LANCE],
				"promotes_to": -1,
				"growths": { "hp": 70, "str": 45, "mag": 5, "skl": 40, "spd": 40, "def": 30, "res": 20 }
			}
		ClassType.KNIGHT:
			return {
				"name": "重甲骑士",
				"move_type": MoveType.ARMORED,
				"base_movement": 4,
				"usable_weapons": [WeaponType.LANCE],
				"promotes_to": -1,
				"growths": { "hp": 90, "str": 50, "mag": 0, "skl": 40, "spd": 20, "def": 55, "res": 15 }
			}
		ClassType.MERCENARY:
			return {
				"name": "佣兵",
				"move_type": MoveType.INFANTRY,
				"base_movement": 5,
				"usable_weapons": [WeaponType.SWORD],
				"promotes_to": -1,
				"growths": { "hp": 80, "str": 45, "mag": 5, "skl": 50, "spd": 45, "def": 30, "res": 20 }
			}
		ClassType.ARCHER:
			return {
				"name": "弓箭手",
				"move_type": MoveType.INFANTRY,
				"base_movement": 5,
				"usable_weapons": [WeaponType.BOW],
				"promotes_to": -1,
				"growths": { "hp": 65, "str": 40, "mag": 5, "skl": 50, "spd": 45, "def": 25, "res": 20 }
			}
		ClassType.MAGE:
			return {
				"name": "法师",
				"move_type": MoveType.INFANTRY,
				"base_movement": 5,
				"usable_weapons": [WeaponType.MAGIC],
				"promotes_to": -1,
				"growths": { "hp": 55, "str": 0, "mag": 60, "skl": 45, "spd": 40, "def": 15, "res": 45 }
			}
		ClassType.CLERIC:
			return {
				"name": "修女",
				"move_type": MoveType.INFANTRY,
				"base_movement": 5,
				"usable_weapons": [WeaponType.STAFF],
				"promotes_to": -1,
				"growths": { "hp": 50, "str": 5, "mag": 50, "skl": 40, "spd": 40, "def": 15, "res": 55 }
			}
		ClassType.BANDIT:
			return {
				"name": "山贼",
				"move_type": MoveType.INFANTRY,
				"base_movement": 5,
				"usable_weapons": [WeaponType.AXE],
				"promotes_to": -1,
				"growths": { "hp": 90, "str": 60, "mag": 0, "skl": 25, "spd": 35, "def": 25, "res": 10 }
			}
	return {}

static func get_weapon_data(weapon_type: WeaponType, tier: String = "iron") -> Dictionary:
	var weapons = {
		WeaponType.SWORD: {
			"iron": { "name": "铁剑", "might": 5, "hit": 90, "crit": 0, "weight": 5, "range_min": 1, "range_max": 1, "uses": 46, "type": WeaponType.SWORD },
			"steel": { "name": "钢剑", "might": 8, "hit": 80, "crit": 0, "weight": 10, "range_min": 1, "range_max": 1, "uses": 30, "type": WeaponType.SWORD }
		},
		WeaponType.LANCE: {
			"iron": { "name": "铁枪", "might": 6, "hit": 85, "crit": 0, "weight": 6, "range_min": 1, "range_max": 1, "uses": 45, "type": WeaponType.LANCE }
		},
		WeaponType.AXE: {
			"iron": { "name": "铁斧", "might": 8, "hit": 75, "crit": 0, "weight": 10, "range_min": 1, "range_max": 1, "uses": 45, "type": WeaponType.AXE }
		},
		WeaponType.BOW: {
			"iron": { "name": "铁弓", "might": 6, "hit": 85, "crit": 0, "weight": 5, "range_min": 2, "range_max": 2, "uses": 45, "type": WeaponType.BOW }
		},
		WeaponType.MAGIC: {
			"fire": { "name": "火焰", "might": 5, "hit": 90, "crit": 0, "weight": 4, "range_min": 1, "range_max": 2, "uses": 40, "type": WeaponType.MAGIC }
		},
		WeaponType.STAFF: {
			"heal": { "name": "治疗", "might": 10, "hit": 100, "crit": 0, "weight": 2, "range_min": 1, "range_max": 1, "uses": 30, "type": WeaponType.STAFF }
		}
	}
	return weapons.get(weapon_type, {}).get(tier, {})

static func get_terrain_data(terrain_type: int) -> Dictionary:
	match terrain_type:
		0: return { "name": "平地", "defense": 0, "avoid": 0, "movement_cost": 1 }
		1: return { "name": "森林", "defense": 1, "avoid": 20, "movement_cost": 2 }
		2: return { "name": "山地", "defense": 1, "avoid": 30, "movement_cost": 3 }
		3: return { "name": "河流", "defense": 0, "avoid": 0, "movement_cost": 999 }
		4: return { "name": "堡垒", "defense": 3, "avoid": 20, "movement_cost": 1 }
	return { "name": "平地", "defense": 0, "avoid": 0, "movement_cost": 1 }

static func get_terrain_color(terrain_type: int) -> Color:
	match terrain_type:
		0: return Color(0.4, 0.7, 0.3)
		1: return Color(0.15, 0.45, 0.1)
		2: return Color(0.5, 0.4, 0.3)
		3: return Color(0.2, 0.4, 0.7)
		4: return Color(0.55, 0.5, 0.4)
	return Color(0.4, 0.7, 0.3)

static func generate_terrain_texture(terrain_type: int) -> ImageTexture:
	var size := 64
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var rng = RandomNumberGenerator.new()
	rng.seed = terrain_type * 1000

	match terrain_type:
		0:
			var base = Color(0.35, 0.65, 0.25)
			var light = Color(0.45, 0.75, 0.35)
			var dark = Color(0.25, 0.50, 0.15)
			for y in size:
				for x in size:
					var rand_val = rng.randf()
					if rand_val < 0.7:
						img.set_pixel(x, y, base)
					elif rand_val < 0.85:
						img.set_pixel(x, y, light)
					else:
						img.set_pixel(x, y, dark)
		1:
			var bg = Color(0.1, 0.35, 0.05)
			var tree = Color(0.15, 0.25, 0.08)
			var leaf = Color(0.2, 0.5, 0.1)
			for y in size:
				for x in size:
					img.set_pixel(x, y, bg)
					if x > 4 and x < 60 and y > 4 and y < 60:
						if (x + y * 3) % 23 < 8:
							img.set_pixel(x, y, tree)
						elif (x * 3 + y) % 29 < 10:
							img.set_pixel(x, y, leaf)
		2:
			var rock = Color(0.45, 0.35, 0.25)
			var dark_rock = Color(0.35, 0.28, 0.2)
			var light_rock = Color(0.55, 0.45, 0.35)
			for y in size:
				for x in size:
					var v = rng.randf()
					if v < 0.5:
						img.set_pixel(x, y, rock)
					elif v < 0.8:
						img.set_pixel(x, y, dark_rock)
					else:
						img.set_pixel(x, y, light_rock)
			for dx in [-1, 0, 1]:
				for dy in [-1, 0, 1]:
					if dx == 0 and dy == 0:
						continue
					if rng.randf() < 0.01:
						var cx = 8 + rng.randi() % 48
						var cy = 8 + rng.randi() % 48
						var snow = Color(0.85, 0.85, 0.8)
						for sy in range(max(0, cy - 2), min(size, cy + 3)):
							for sx in range(max(0, cx - 2), min(size, cx + 3)):
								if (sx - cx) * (sx - cx) + (sy - cy) * (sy - cy) < 5:
									img.set_pixel(sx, sy, snow)
		3:
			var blue_water = Color(0.15, 0.3, 0.6)
			var light_water = Color(0.2, 0.4, 0.7)
			var ripple = Color(0.3, 0.55, 0.85)
			for y in size:
				for x in size:
					var wave = sin(x * 0.3) * cos(y * 0.3) * 0.5 + 0.5
					if wave > 0.6:
						img.set_pixel(x, y, ripple)
					elif wave > 0.4:
						img.set_pixel(x, y, light_water)
					else:
						img.set_pixel(x, y, blue_water)
		4:
			var stone = Color(0.5, 0.45, 0.4)
			var mortar = Color(0.6, 0.55, 0.45)
			var dark_stone = Color(0.4, 0.35, 0.3)
			for y in size:
				for x in size:
					var in_brick = (x % 22 >= 2 and y % 14 >= 2)
					var dark_brick = ((x / 22 + y / 14) % 2 == 0)
					if in_brick:
						img.set_pixel(x, y, dark_stone if dark_brick else stone)
					else:
						img.set_pixel(x, y, mortar)
		_:
			for y in size:
				for x in size:
					img.set_pixel(x, y, Color(0.4, 0.7, 0.3))

	var fallback = ImageTexture.create_from_image(img)
	return fallback

static func get_weapon_triangle_bonus(atk_weapon: WeaponType, def_weapon: WeaponType) -> Dictionary:
	# Sword > Axe > Lance > Sword. Bows/Magic/Staff are neutral.
	if atk_weapon == WeaponType.SWORD and def_weapon == WeaponType.AXE:
		return { "advantage": true, "damage_bonus": 1, "hit_bonus": 15 }
	if atk_weapon == WeaponType.AXE and def_weapon == WeaponType.LANCE:
		return { "advantage": true, "damage_bonus": 1, "hit_bonus": 15 }
	if atk_weapon == WeaponType.LANCE and def_weapon == WeaponType.SWORD:
		return { "advantage": true, "damage_bonus": 1, "hit_bonus": 15 }
	if atk_weapon == WeaponType.SWORD and def_weapon == WeaponType.LANCE:
		return { "advantage": false, "damage_bonus": -1, "hit_bonus": -15 }
	if atk_weapon == WeaponType.LANCE and def_weapon == WeaponType.AXE:
		return { "advantage": false, "damage_bonus": -1, "hit_bonus": -15 }
	if atk_weapon == WeaponType.AXE and def_weapon == WeaponType.SWORD:
		return { "advantage": false, "damage_bonus": -1, "hit_bonus": -15 }
	return { "advantage": true, "damage_bonus": 0, "hit_bonus": 0 }

static func get_triangle_advantage_name(advantage: bool) -> String:
	if advantage:
		return "武器克制!"
	else:
		return "武器劣势..."

static func get_total_exp_needed(level: int) -> int:
	return 100

static func get_kill_exp(enemy_level: int, unit_level: int) -> int:
	var base = 30 + (enemy_level - unit_level) * 5
	return clamp(base, 5, 100)

static func get_combat_exp() -> int:
	return 10

static func get_growth_rate(stat_name: String, unit_growths: Dictionary) -> int:
	return unit_growths.get(stat_name, 30)

static func generate_unit_texture(class_name_str: String) -> ImageTexture:
	var size := 48
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var skin = Color(0.95, 0.8, 0.65)
	var darker_skin = Color(0.8, 0.65, 0.5)
	var hair_color = Color(0.3, 0.2, 0.1)

	var body_color: Color
	var accent: Color
	var emblem: int = 0

	match class_name_str:
		"领主":
			body_color = Color(0.2, 0.3, 0.75)
			accent = Color(0.9, 0.85, 0.2)
			hair_color = Color(0.3, 0.2, 0.6)
			emblem = 1
		"骑士":
			body_color = Color(0.7, 0.15, 0.15)
			accent = Color(0.9, 0.9, 0.9)
			emblem = 2
		"重甲骑士":
			body_color = Color(0.45, 0.45, 0.5)
			accent = Color(0.7, 0.7, 0.75)
			emblem = 3
		"佣兵":
			body_color = Color(0.15, 0.5, 0.3)
			accent = Color(0.6, 0.4, 0.2)
			hair_color = Color(0.5, 0.3, 0.15)
			emblem = 4
		"弓箭手":
			body_color = Color(0.15, 0.55, 0.15)
			accent = Color(0.6, 0.3, 0.1)
			hair_color = Color(0.2, 0.5, 0.2)
			emblem = 5
		"法师":
			body_color = Color(0.4, 0.15, 0.55)
			accent = Color(0.85, 0.7, 0.2)
			hair_color = Color(0.7, 0.7, 0.85)
			emblem = 6
		"修女":
			body_color = Color(0.9, 0.9, 0.95)
			accent = Color(0.85, 0.75, 0.55)
			skin = Color(0.98, 0.88, 0.8)
			hair_color = Color(0.85, 0.75, 0.55)
			emblem = 7
		"山贼":
			body_color = Color(0.5, 0.2, 0.15)
			accent = Color(0.3, 0.15, 0.1)
			hair_color = Color(0.6, 0.1, 0.05)
			skin = Color(0.8, 0.65, 0.5)
			emblem = 8
		_:
			body_color = Color(0.4, 0.4, 0.4)
			accent = Color(0.6, 0.6, 0.6)

	_draw_unit_body(img, size, body_color, accent, skin, darker_skin, hair_color)

	var border = Color(max(body_color.r - 0.15, 0), max(body_color.g - 0.15, 0), max(body_color.b - 0.15, 0), 1)
	for i in size:
		img.set_pixel(i, 0, border)
		img.set_pixel(i, size - 1, border)
		img.set_pixel(0, i, border)
		img.set_pixel(size - 1, i, border)

	return ImageTexture.create_from_image(img)

static func _draw_unit_body(img: Image, size: int, body: Color, accent: Color, skin: Color, darker_skin: Color, hair: Color):
	# hair
	for y in range(4, 11):
		var w = int(11 - abs(y - 7) * 0.6)
		for x in range(24 - w, 24 + w + 1):
			if x >= 0 and x < size:
				img.set_pixel(x, y, hair)
	# face
	for y in range(8, 14):
		for x in range(20, 29):
			if x >= 0 and x < size and y >= 0 and y < size:
				img.set_pixel(x, y, skin)
	# eyes
	var eye = Color(0.1, 0.1, 0.1)
	img.set_pixel(22, 10, eye)
	img.set_pixel(26, 10, eye)
	# body
	for y in range(14, 31):
		for x in range(18, 31):
			var ny = y - 14
			var w = 6 + int(sin(ny * 0.3) * 1.5)
			if x >= 23 - w and x <= 25 + w:
				if x >= 0 and x < size:
					var c = body
					if y >= 21 and y <= 24 and (x == 19 or x == 20):
						c = accent
					img.set_pixel(x, y, c)
	# arms
	for y in range(16, 27):
		for dx in [0, 1]:
			if 17 + dx < size:
				img.set_pixel(17 + dx, y, body)
			if 30 + dx < size:
				img.set_pixel(30 + dx, y, body)
	# hands
	for y in range(27, 29):
		for dx in range(-1, 2):
			if 17 + dx >= 0 and 17 + dx < size:
				img.set_pixel(17 + dx, y, skin)
			if 30 + dx >= 0 and 30 + dx < size:
				img.set_pixel(30 + dx, y, skin)
	# legs
	for y in range(31, 41):
		for dx in range(0, 3):
			if 20 + dx < size:
				img.set_pixel(20 + dx, y, body)
			if 26 + dx < size:
				img.set_pixel(26 + dx, y, body)
	# boots
	var boot = Color(body.r * 0.5, body.g * 0.5, body.b * 0.5)
	for y in range(41, 46):
		for dx in range(-1, 4):
			if 20 + dx >= 0 and 20 + dx < size:
				img.set_pixel(20 + dx, y, boot)
			if 26 + dx >= 0 and 26 + dx < size:
				img.set_pixel(26 + dx, y, boot)
