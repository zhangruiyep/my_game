extends Node
class_name MapData

enum MapID { CHAPTER_1, CHAPTER_2 }

var chapter_1 = {
	"id": MapID.CHAPTER_1,
	"name": "序幕：初阵",
	"width": 9,
	"height": 16,
	"tiles": [],
	"player_deployments": [],
	"enemy_deployments": []
}

var chapter_2 = {
	"id": MapID.CHAPTER_2,
	"name": "第二章：山贼讨伐",
	"width": 9,
	"height": 16,
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
			if x in [3, 4, 5] and y == 7:
				terrain = 1
			if x in [3, 4] and y in [7, 8]:
				terrain = 1
			if x == 2 and y == 6:
				terrain = 1
			if x == 6 and y == 6:
				terrain = 1
			if x == 1 and y == 4:
				terrain = 2
			if x == 7 and y == 4:
				terrain = 2
			if x == 4 and y == 10:
				terrain = 2
			if (y == 10 or y == 11) and x <= 2:
				terrain = 3
			if x == 4 and y == 2:
				terrain = 4
			if x == 7 and y == 1:
				terrain = 4
			if x == 1 and y == 12:
				terrain = 4
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
		{ "preset": lord, "pos": Vector2i(3, 0) },
		{ "preset": cav, "pos": Vector2i(4, 0) },
		{ "preset": merc, "pos": Vector2i(5, 0) },
		{ "preset": archer, "pos": Vector2i(3, 1) },
	]

	var bandit1 = { "class": UnitData.ClassType.BANDIT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }
	var bandit2 = { "class": UnitData.ClassType.BANDIT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }
	var archer_e = { "class": UnitData.ClassType.ARCHER, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.BOW, "tier": "iron" }, "allegiance": "enemy" }

	chapter_1["enemy_deployments"] = [
		{ "preset": bandit1, "pos": Vector2i(3, 7) },
		{ "preset": bandit2, "pos": Vector2i(5, 7) },
		{ "preset": archer_e, "pos": Vector2i(4, 8) },
	]

func _generate_chapter_2():
	var w = chapter_2["width"]
	var h = chapter_2["height"]
	chapter_2["tiles"] = []
	for y in range(h):
		var row = []
		for x in range(w):
			var terrain = 0
			if x in [3, 4, 5] and y in [6, 7]:
				terrain = 1
			if x in [7, 8] and y == 5:
				terrain = 1
			if x in [1, 2] and y in [4, 5]:
				terrain = 2
			if x == 6 and y == 2:
				terrain = 2
			if y == 8 and x in [1, 2]:
				terrain = 3
			if y == 9 and x in [1, 2]:
				terrain = 3
			if x == 6 and y == 6:
				terrain = 4
			if x == 3 and y == 10:
				terrain = 4
			if x == 7 and y == 12:
				terrain = 4
			if x in [0, 1] and y == 12:
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
		{ "preset": lord, "pos": Vector2i(3, 0) },
		{ "preset": cav, "pos": Vector2i(4, 0) },
		{ "preset": merc, "pos": Vector2i(5, 0) },
		{ "preset": mage, "pos": Vector2i(3, 1) },
	]

	var bandit1 = { "class": UnitData.ClassType.BANDIT, "level": 3, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }
	var bandit2 = { "class": UnitData.ClassType.BANDIT, "level": 3, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }
	var merc_e = { "class": UnitData.ClassType.MERCENARY, "level": 3, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "steel" }, "allegiance": "enemy" }
	var archer_e = { "class": UnitData.ClassType.ARCHER, "level": 3, "equipped_weapon": { "type": UnitData.WeaponType.BOW, "tier": "iron" }, "allegiance": "enemy" }
	var knight_e = { "class": UnitData.ClassType.KNIGHT, "level": 4, "equipped_weapon": { "type": UnitData.WeaponType.LANCE, "tier": "iron" }, "allegiance": "enemy" }

	chapter_2["enemy_deployments"] = [
		{ "preset": bandit1, "pos": Vector2i(2, 2) },
		{ "preset": bandit2, "pos": Vector2i(3, 2) },
		{ "preset": merc_e, "pos": Vector2i(5, 3) },
		{ "preset": archer_e, "pos": Vector2i(6, 2) },
		{ "preset": knight_e, "pos": Vector2i(4, 4) },
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
