extends Node
class_name MapData

enum MapID { CHAPTER_1, CHAPTER_2 }

var chapter_1 = {
	"id": MapID.CHAPTER_1,
	"name": "序幕：初阵",
	"width": 10,
	"height": 10,
	"tiles": [],
	"player_deployments": [],
	"enemy_deployments": []
}

var chapter_2 = {
	"id": MapID.CHAPTER_2,
	"name": "第二章：山贼讨伐",
	"width": 12,
	"height": 10,
	"tiles": [],
	"player_deployments": [],
	"enemy_deployments": []
}

func _init():
	_generate_chapter_1()
	_generate_chapter_2()

func _generate_chapter_1():
	var w = chapter_1["width"]
	var h = chapter_1["height"]
	chapter_1["tiles"] = []
	for y in range(h):
		var row = []
		for x in range(w):
			var terrain = 0
			if x == 4 and y in [3, 4, 5]:
				terrain = 1
			if y == 4 and x in [3, 4, 5]:
				terrain = 1
			if x == 1 and y == 1:
				terrain = 2
			if x == 8 and y == 8:
				terrain = 2
			if x == 6 and y == 0:
				terrain = 4
			if (y == 6 or y == 7) and x <= 2:
				terrain = 3
			row.append(terrain)
		chapter_1["tiles"].append(row)

	var lord = {
		"class": UnitData.ClassType.LORD,
		"level": 1,
		"equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" },
		"allegiance": "player"
	}
	var cav = {
		"class": UnitData.ClassType.CAVALIER,
		"level": 1,
		"equipped_weapon": { "type": UnitData.WeaponType.LANCE, "tier": "iron" },
		"allegiance": "player"
	}
	var merc = {
		"class": UnitData.ClassType.MERCENARY,
		"level": 1,
		"equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" },
		"allegiance": "player"
	}
	var archer = {
		"class": UnitData.ClassType.ARCHER,
		"level": 1,
		"equipped_weapon": { "type": UnitData.WeaponType.BOW, "tier": "iron" },
		"allegiance": "player"
	}

	chapter_1["player_deployments"] = [
		{ "preset": lord, "pos": Vector2i(0, 0) },
		{ "preset": cav, "pos": Vector2i(0, 1) },
		{ "preset": merc, "pos": Vector2i(1, 0) },
		{ "preset": archer, "pos": Vector2i(1, 1) },
	]

	var bandit1 = { "class": UnitData.ClassType.BANDIT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }
	var bandit2 = { "class": UnitData.ClassType.BANDIT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }
	var archer_e = { "class": UnitData.ClassType.ARCHER, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.BOW, "tier": "iron" }, "allegiance": "enemy" }

	chapter_1["enemy_deployments"] = [
		{ "preset": bandit1, "pos": Vector2i(8, 7) },
		{ "preset": bandit2, "pos": Vector2i(9, 7) },
		{ "preset": archer_e, "pos": Vector2i(8, 8) },
	]

func _generate_chapter_2():
	var w = chapter_2["width"]
	var h = chapter_2["height"]
	chapter_2["tiles"] = []
	for y in range(h):
		var row = []
		for x in range(w):
			var terrain = 0
			if x in [5, 6] and y in [4, 5]:
				terrain = 1
			if x in [9, 10] and y in [3, 4]:
				terrain = 2
			if (y == 2 or y == 3) and x == 3:
				terrain = 3
			if x == 7 and y == 7:
				terrain = 4
			if x == 3 and y == 7:
				terrain = 4
			if x in [0, 1] and y == 5:
				terrain = 2
			row.append(terrain)
		chapter_2["tiles"].append(row)

	var lord = {
		"class": UnitData.ClassType.LORD, "level": 3,
		"equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" },
		"allegiance": "player"
	}
	var cav = {
		"class": UnitData.ClassType.CAVALIER, "level": 2,
		"equipped_weapon": { "type": UnitData.WeaponType.LANCE, "tier": "iron" },
		"allegiance": "player"
	}
	var merc = {
		"class": UnitData.ClassType.MERCENARY, "level": 2,
		"equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" },
		"allegiance": "player"
	}
	var mage = {
		"class": UnitData.ClassType.MAGE, "level": 1,
		"equipped_weapon": { "type": UnitData.WeaponType.MAGIC, "tier": "fire" },
		"allegiance": "player"
	}

	chapter_2["player_deployments"] = [
		{ "preset": lord, "pos": Vector2i(0, 0) },
		{ "preset": cav, "pos": Vector2i(0, 1) },
		{ "preset": merc, "pos": Vector2i(1, 0) },
		{ "preset": mage, "pos": Vector2i(1, 1) },
	]

	var bandit1 = { "class": UnitData.ClassType.BANDIT, "level": 3, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }
	var bandit2 = { "class": UnitData.ClassType.BANDIT, "level": 3, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }
	var merc_e = { "class": UnitData.ClassType.MERCENARY, "level": 3, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "steel" }, "allegiance": "enemy" }
	var archer_e = { "class": UnitData.ClassType.ARCHER, "level": 3, "equipped_weapon": { "type": UnitData.WeaponType.BOW, "tier": "iron" }, "allegiance": "enemy" }
	var knight_e = { "class": UnitData.ClassType.KNIGHT, "level": 4, "equipped_weapon": { "type": UnitData.WeaponType.LANCE, "tier": "iron" }, "allegiance": "enemy" }

	chapter_2["enemy_deployments"] = [
		{ "preset": bandit1, "pos": Vector2i(8, 2) },
		{ "preset": bandit2, "pos": Vector2i(9, 2) },
		{ "preset": merc_e, "pos": Vector2i(10, 3) },
		{ "preset": archer_e, "pos": Vector2i(9, 5) },
		{ "preset": knight_e, "pos": Vector2i(7, 8) },
	]

var current_map: int = MapID.CHAPTER_1

func get_map(map_id: int = -1) -> Dictionary:
	if map_id == -1:
		map_id = current_map
	match map_id:
		MapID.CHAPTER_1:
			return chapter_1
		MapID.CHAPTER_2:
			return chapter_2
	return chapter_1

func get_next_map() -> Dictionary:
	match current_map:
		MapID.CHAPTER_1:
			current_map = MapID.CHAPTER_2
			return chapter_2
	return chapter_1
