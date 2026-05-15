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
