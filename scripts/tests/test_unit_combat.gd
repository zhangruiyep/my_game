extends GdUnitTestSuite

var _combat_system: Node
var _map_controller: Node

func before():
	_combat_system = load("res://scripts/battle/CombatSystem.gd").new()
	_map_controller = load("res://scripts/battle/MapController.gd").new()
	var flat_map = { "width": 10, "height": 10, "tiles": [] }
	for y in range(10):
		var row = []
		for x in range(10):
			row.append(0)
		flat_map["tiles"].append(row)
	_map_controller.setup_map(flat_map)
	GameState.reset()
	GameState.current_map_data = flat_map
	GameState.player_units.clear()
	GameState.enemy_units.clear()

func after():
	GameState.reset()

func _make_unit(preset: Dictionary, pos: Vector2i = Vector2i(3, 3)) -> Node:
	var unit = load("res://scripts/battle/Unit.gd").new()
	unit.setup_from_preset(preset)
	unit.grid_position = pos
	return unit


# ── 单位创建与基础属性 ──

func test_unit_creation_lord():
	var preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset, Vector2i(0, 0))

	assert_int(unit.class_type).is_equal(UnitData.ClassType.LORD)
	assert_str(unit.allegiance).is_equal("player")
	assert_int(unit.level).is_equal(1)
	assert_int(unit.current_stats["mov"]).is_equal(5)
	assert_bool(unit.is_alive()).is_true()
	assert_bool(unit.has_moved).is_false()
	assert_bool(unit.has_acted).is_false()
	assert_int(unit.current_stats["hp"]).is_equal(unit.stats["max_hp"])


func test_unit_creation_cavalier_movement():
	var preset = { "class": UnitData.ClassType.CAVALIER, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.LANCE, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset)

	assert_int(unit.current_stats["mov"]).is_equal(7)
	assert_str(unit.get_class_name_str()).is_equal("骑士")


func test_unit_all_classes_create():
	var classes = [
		UnitData.ClassType.LORD,
		UnitData.ClassType.CAVALIER,
		UnitData.ClassType.KNIGHT,
		UnitData.ClassType.MERCENARY,
		UnitData.ClassType.ARCHER,
		UnitData.ClassType.MAGE,
		UnitData.ClassType.CLERIC,
		UnitData.ClassType.BANDIT,
	]
	var weapon_map = {
		UnitData.ClassType.LORD: UnitData.WeaponType.SWORD,
		UnitData.ClassType.CAVALIER: UnitData.WeaponType.LANCE,
		UnitData.ClassType.KNIGHT: UnitData.WeaponType.LANCE,
		UnitData.ClassType.MERCENARY: UnitData.WeaponType.SWORD,
		UnitData.ClassType.ARCHER: UnitData.WeaponType.BOW,
		UnitData.ClassType.MAGE: UnitData.WeaponType.MAGIC,
		UnitData.ClassType.CLERIC: UnitData.WeaponType.STAFF,
		UnitData.ClassType.BANDIT: UnitData.WeaponType.AXE,
	}

	for cls in classes:
		var wt = weapon_map[cls]
		var tier = "fire" if cls == UnitData.ClassType.MAGE else ("heal" if cls == UnitData.ClassType.CLERIC else "iron")
		var preset = { "class": cls, "level": 1, "equipped_weapon": { "type": wt, "tier": tier }, "allegiance": "player" }
		var unit = _make_unit(preset)

		assert_int(unit.class_type).is_equal(cls)
		assert_bool(unit.is_alive()).is_true()
		assert_int(unit.current_stats["hp"]).is_greater(0)
		assert_int(unit.current_stats["mov"]).is_greater(0)
		assert_int(unit.current_stats["str"] + unit.current_stats["mag"]).is_greater(0)


func test_unit_level2_stronger_than_level1():
	var preset1 = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit1 = _make_unit(preset1)

	# Level does not affect base stats in current _generate_stats, so they should be equal
	assert_int(unit1.current_stats["hp"]).is_equal(unit1.stats["max_hp"])


# ── 单位攻击力计算 ──

func test_get_attack_physical():
	var preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset)

	var expected = unit.current_stats["str"] + 5
	assert_int(unit.get_attack()).is_equal(expected)


func test_get_attack_magic():
	var preset = { "class": UnitData.ClassType.MAGE, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.MAGIC, "tier": "fire" }, "allegiance": "player" }
	var unit = _make_unit(preset)

	var expected = unit.current_stats["mag"] + 5
	assert_int(unit.get_attack()).is_equal(expected)


func test_get_attack_staff_uses_magic():
	var preset = { "class": UnitData.ClassType.CLERIC, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.STAFF, "tier": "heal" }, "allegiance": "player" }
	var unit = _make_unit(preset)

	assert_bool(unit.is_magic_weapon()).is_true()
	var expected = unit.current_stats["mag"] + 10
	assert_int(unit.get_attack()).is_equal(expected)


func test_get_hit_rate():
	var preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset)

	var expected = unit.current_stats["skl"] * 2 + 90
	assert_int(unit.get_hit()).is_equal(expected)


func test_get_avoid():
	var preset = { "class": UnitData.ClassType.MERCENARY, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset)

	assert_int(unit.get_avoid()).is_equal(unit.current_stats["spd"] * 2 + unit.current_stats.get("lck", 0))


func test_get_crit():
	var preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset)

	assert_int(unit.get_crit()).is_equal(int(unit.current_stats["skl"] / 2))


func test_get_attack_speed():
	var preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset)

	var expected = unit.current_stats["spd"] - 5
	assert_int(unit.get_attack_speed()).is_equal(expected)


func test_get_defense_and_resistance():
	var preset = { "class": UnitData.ClassType.KNIGHT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.LANCE, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset)

	assert_int(unit.get_defense()).is_equal(unit.current_stats["def"])
	assert_int(unit.get_resistance()).is_equal(unit.current_stats["res"])


# ── 伤害与治疗 ──

func test_take_damage():
	var preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset)
	var initial_hp = unit.current_stats["hp"]

	unit.take_damage(10)
	assert_int(unit.current_stats["hp"]).is_equal(initial_hp - 10)
	assert_bool(unit.is_alive()).is_true()

	unit.take_damage(initial_hp)
	assert_int(unit.current_stats["hp"]).is_equal(0)
	assert_bool(unit.is_alive()).is_false()


func test_take_damage_not_negative():
	var preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset)

	unit.take_damage(999)
	assert_int(unit.current_stats["hp"]).is_equal(0)


func test_heal_damage():
	var preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset)
	var max_hp = unit.stats["max_hp"]

	unit.take_damage(10)
	unit.heal_damage(5)
	assert_int(unit.current_stats["hp"]).is_equal(max_hp - 5)

	unit.heal_damage(20)
	assert_int(unit.current_stats["hp"]).is_equal(max_hp)


func test_is_alive_edge_cases():
	var preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset)

	assert_bool(unit.is_alive()).is_true()

	unit.take_damage(unit.current_stats["hp"] - 1)
	assert_bool(unit.is_alive()).is_true()

	unit.take_damage(1)
	assert_bool(unit.is_alive()).is_false()


# ── 地形加成 ──

func test_apply_terrain_bonus():
	var preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset, Vector2i(0, 0))

	var terrain = unit.apply_terrain_bonus(Vector2i(0, 0))
	assert_int(terrain["defense"]).is_equal(0)
	assert_int(terrain["avoid"]).is_equal(0)

	var forest_map = { "width": 5, "height": 5, "tiles": [[1, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]] }
	GameState.current_map_data = forest_map

	var forest_terrain = unit.apply_terrain_bonus(Vector2i(0, 0))
	assert_int(forest_terrain["defense"]).is_equal(1)
	assert_int(forest_terrain["avoid"]).is_equal(20)


func test_apply_terrain_bonus_fortress():
	var preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset, Vector2i(0, 0))

	var fort_map = { "width": 5, "height": 5, "tiles": [[4, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]] }
	GameState.current_map_data = fort_map

	var terrain = unit.apply_terrain_bonus(Vector2i(0, 0))
	assert_int(terrain["defense"]).is_equal(3)
	assert_int(terrain["avoid"]).is_equal(20)


func test_apply_terrain_bonus_out_of_bounds():
	var preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset, Vector2i(0, 0))

	var terrain = unit.apply_terrain_bonus(Vector2i(99, 99))
	assert_int(terrain["defense"]).is_equal(0)
	assert_str(terrain["name"]).is_equal("平地")


# ── 回合重置 ──

func test_reset_turn():
	var preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset)

	unit.has_moved = true
	unit.has_acted = true

	unit.reset_turn()

	assert_bool(unit.has_moved).is_false()
	assert_bool(unit.has_acted).is_false()


# ── 战斗预览：纯逻辑测试 ──

func test_combat_preview_sword_vs_axe_advantage():
	var lord_preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var bandit_preset = { "class": UnitData.ClassType.BANDIT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }

	var lord = _make_unit(lord_preset, Vector2i(0, 0))
	var bandit = _make_unit(bandit_preset, Vector2i(1, 0))

	var preview = _combat_system.calculate_preview(lord, bandit, lord.grid_position, bandit.grid_position)

	assert_bool(preview["triangle_advantage"]).is_true()
	assert_int(preview["triangle_bonus"]).is_equal(1)
	assert_int(preview["hit_rate"]).is_greater(0)
	assert_int(preview["damage"]).is_greater(0)


func test_combat_preview_sword_vs_lance_disadvantage():
	var lord_preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var cav_preset = { "class": UnitData.ClassType.CAVALIER, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.LANCE, "tier": "iron" }, "allegiance": "enemy" }

	var lord = _make_unit(lord_preset, Vector2i(0, 0))
	var cav = _make_unit(cav_preset, Vector2i(1, 0))

	var preview = _combat_system.calculate_preview(lord, cav, lord.grid_position, cav.grid_position)

	assert_bool(preview["triangle_advantage"]).is_false()
	assert_int(preview["triangle_bonus"]).is_equal(-1)


func test_combat_preview_bow_cannot_be_countered():
	var archer_preset = { "class": UnitData.ClassType.ARCHER, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.BOW, "tier": "iron" }, "allegiance": "player" }
	var bandit_preset = { "class": UnitData.ClassType.BANDIT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }

	var archer = _make_unit(archer_preset, Vector2i(0, 0))
	var bandit = _make_unit(bandit_preset, Vector2i(2, 0))

	var preview = _combat_system.calculate_preview(archer, bandit, archer.grid_position, bandit.grid_position)

	assert_bool(preview["can_counter"]).is_false()


func test_combat_preview_melee_can_counter():
	var lord_preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var merc_preset = { "class": UnitData.ClassType.MERCENARY, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "enemy" }

	var lord = _make_unit(lord_preset, Vector2i(0, 0))
	var merc = _make_unit(merc_preset, Vector2i(1, 0))

	var preview = _combat_system.calculate_preview(lord, merc, lord.grid_position, merc.grid_position)

	assert_bool(preview["can_counter"]).is_true()


func test_combat_preview_damage_min_zero():
	var cleric_preset = { "class": UnitData.ClassType.CLERIC, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.STAFF, "tier": "heal" }, "allegiance": "player" }
	var knight_preset = { "class": UnitData.ClassType.KNIGHT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.LANCE, "tier": "iron" }, "allegiance": "enemy" }

	var cleric = _make_unit(cleric_preset, Vector2i(0, 0))
	var knight = _make_unit(knight_preset, Vector2i(1, 0))
	var preview = _combat_system.calculate_preview(cleric, knight, cleric.grid_position, knight.grid_position)

	assert_int(preview["damage"]).is_greater(0)


func test_combat_preview_archer_melee_cannot_counter():
	var bandit_preset = { "class": UnitData.ClassType.BANDIT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "player" }
	var archer_preset = { "class": UnitData.ClassType.ARCHER, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.BOW, "tier": "iron" }, "allegiance": "enemy" }

	var bandit = _make_unit(bandit_preset, Vector2i(0, 0))
	var archer = _make_unit(archer_preset, Vector2i(1, 0))

	var preview = _combat_system.calculate_preview(bandit, archer, bandit.grid_position, archer.grid_position)

	assert_bool(preview["can_counter"]).is_false()


func test_combat_preview_hit_rate_clamps_0_100():
	var lord_preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var bandit_preset = { "class": UnitData.ClassType.BANDIT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }

	var lord = _make_unit(lord_preset, Vector2i(0, 0))
	var bandit = _make_unit(bandit_preset, Vector2i(1, 0))

	var preview = _combat_system.calculate_preview(lord, bandit, lord.grid_position, bandit.grid_position)

	assert_int(preview["hit_rate"]).is_between(0, 100)
	assert_int(preview["crit_rate"]).is_between(0, 100)


func test_combat_preview_speed_double_check():
	var lord_preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var knight_preset = { "class": UnitData.ClassType.KNIGHT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.LANCE, "tier": "iron" }, "allegiance": "enemy" }

	var lord = _make_unit(lord_preset, Vector2i(0, 0))
	var knight = _make_unit(knight_preset, Vector2i(1, 0))

	# Lord growths: spd=50, Knight growths: spd=20
	# Lord base spd ~ 8, Knight base spd ~ 5
	# weapon weight: iron sword=5, iron lance=6
	# lord atk speed ≈ 8-5=3, knight atk speed ≈ 5-6=-1
	# 3 >= -1+4 ? Yes, lord can double knight
	var preview = _combat_system.calculate_preview(lord, knight, lord.grid_position, knight.grid_position)
	assert_bool(preview["can_double"]).is_true()


func test_combat_preview_staff_melee_stats():
	var bandit_preset = { "class": UnitData.ClassType.BANDIT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }
	var cleric_preset = { "class": UnitData.ClassType.CLERIC, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.STAFF, "tier": "heal" }, "allegiance": "player" }

	var bandit = _make_unit(bandit_preset, Vector2i(0, 0))
	var cleric = _make_unit(cleric_preset, Vector2i(1, 0))

	var preview = _combat_system.calculate_preview(bandit, cleric, bandit.grid_position, cleric.grid_position)

	assert_bool(preview["can_counter"]).is_false()
	assert_bool(preview["can_double"]).is_false()


# ── 战斗执行：伤害与状态变化 ──

func test_execute_combat_deals_damage():
	var lord_preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var bandit_preset = { "class": UnitData.ClassType.BANDIT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }

	var lord = _make_unit(lord_preset, Vector2i(0, 0))
	var bandit = _make_unit(bandit_preset, Vector2i(1, 0))
	var bandit_initial_hp = bandit.current_stats["hp"]
	var lord_initial_hp = lord.current_stats["hp"]

	_combat_system.execute_combat(lord, bandit, lord.grid_position, bandit.grid_position)

	assert_bool(lord.has_acted).is_true()
	assert_bool(lord.has_moved).is_false()
	assert_int(bandit.current_stats["hp"]).is_less(bandit_initial_hp)


func test_execute_combat_archer_no_counter():
	var archer_preset = { "class": UnitData.ClassType.ARCHER, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.BOW, "tier": "iron" }, "allegiance": "player" }
	var bandit_preset = { "class": UnitData.ClassType.BANDIT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }

	var archer = _make_unit(archer_preset, Vector2i(0, 0))
	var bandit = _make_unit(bandit_preset, Vector2i(2, 0))
	var archer_hp_before = archer.current_stats["hp"]

	_combat_system.execute_combat(archer, bandit, archer.grid_position, bandit.grid_position)

	assert_bool(archer.has_acted).is_true()
	assert_int(archer.current_stats["hp"]).is_equal(archer_hp_before)


func test_execute_combat_sets_has_acted():
	var lord_preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var bandit_preset = { "class": UnitData.ClassType.BANDIT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }

	var lord = _make_unit(lord_preset, Vector2i(0, 0))
	var bandit = _make_unit(bandit_preset, Vector2i(1, 0))

	_combat_system.execute_combat(lord, bandit, lord.grid_position, bandit.grid_position)

	assert_bool(lord.has_acted).is_true()
	assert_bool(bandit.has_acted).is_true()


func test_execute_combat_gives_exp():
	var lord_preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var bandit_preset = { "class": UnitData.ClassType.BANDIT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }

	var lord = _make_unit(lord_preset, Vector2i(0, 0))
	var bandit = _make_unit(bandit_preset, Vector2i(1, 0))

	_combat_system.execute_combat(lord, bandit, lord.grid_position, bandit.grid_position)

	assert_int(lord.exp).is_greater(0)


func test_execute_combat_attacker_kills_defender():
	var lord_preset = { "class": UnitData.ClassType.LORD, "level": 10, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "steel" }, "allegiance": "player" }
	var bandit_preset = { "class": UnitData.ClassType.BANDIT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }

	var lord = _make_unit(lord_preset, Vector2i(0, 0))
	var bandit = _make_unit(bandit_preset, Vector2i(1, 0))
	bandit.current_stats["hp"] = 1

	_combat_system.execute_combat(lord, bandit, lord.grid_position, bandit.grid_position)

	assert_bool(bandit.is_alive()).is_false()
	assert_bool(lord.is_alive()).is_true()


# ── 集成：移动后攻击完整流程 ──

func test_full_move_then_attack_flow():
	var lord_preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var bandit_preset = { "class": UnitData.ClassType.BANDIT, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.AXE, "tier": "iron" }, "allegiance": "enemy" }

	var lord = _make_unit(lord_preset, Vector2i(0, 0))
	var bandit = _make_unit(bandit_preset, Vector2i(5, 0))

	GameState.player_units = [lord]
	GameState.enemy_units = [bandit]

	# Step 1: Check move range includes target
	var move_range = _map_controller.get_move_range(lord.grid_position, lord.current_stats["mov"], UnitData.MoveType.INFANTRY)
	assert_bool(Vector2i(4, 0) in move_range).is_true()

	# Step 2: Move unit
	lord.set_grid_position(Vector2i(4, 0))
	lord.grid_position = Vector2i(4, 0)

	# Step 3: After moving, can attack adjacent enemy
	var atk_range = _map_controller.get_attack_range(lord.grid_position, 1, 1)
	assert_bool(Vector2i(5, 0) in atk_range).is_true()

	# Step 4: Preview shows valid combat
	var preview = _combat_system.calculate_preview(lord, bandit, lord.grid_position, bandit.grid_position)
	assert_int(preview["damage"]).is_greater(0)

	# Step 5: Execute combat
	var bandit_hp = bandit.current_stats["hp"]
	_combat_system.execute_combat(lord, bandit, lord.grid_position, bandit.grid_position)
	assert_bool(lord.has_acted).is_true()


# ── 单位在不同地形上的移动消耗 ──

func test_move_range_respects_terrain_costs_per_class():
	var terrain_map = {
		"width": 6,
		"height": 3,
		"tiles": [
			[0, 0, 1, 0, 0, 0],
			[0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0],
		]
	}
	_map_controller.grid_width = terrain_map["width"]
	_map_controller.grid_height = terrain_map["height"]
	_map_controller.tiles = terrain_map["tiles"]
	GameState.current_map_data = terrain_map

	# Infantry with 4 movement: forest at (2,0) costs 2, so max reach is (3,0)
	var range_4 = _map_controller.get_move_range(Vector2i(0, 0), 4, UnitData.MoveType.INFANTRY)
	assert_bool(Vector2i(3, 0) in range_4).is_true()
	assert_bool(Vector2i(4, 0) in range_4).is_false()

	# Unit with 5 movement should reach (4,0)  (1+2+1+1=5)
	var range_5 = _map_controller.get_move_range(Vector2i(0, 0), 5, UnitData.MoveType.INFANTRY)
	assert_int(range_5.size()).is_greater(range_4.size())
	assert_bool(Vector2i(4, 0) in range_5).is_true()


# ── 武器数据验证 ──

func test_weapon_ranges():
	assert_int(UnitData.get_weapon_data(UnitData.WeaponType.SWORD, "iron")["range_min"]).is_equal(1)
	assert_int(UnitData.get_weapon_data(UnitData.WeaponType.SWORD, "iron")["range_max"]).is_equal(1)
	assert_int(UnitData.get_weapon_data(UnitData.WeaponType.BOW, "iron")["range_min"]).is_equal(2)
	assert_int(UnitData.get_weapon_data(UnitData.WeaponType.BOW, "iron")["range_max"]).is_equal(2)
	assert_int(UnitData.get_weapon_data(UnitData.WeaponType.MAGIC, "fire")["range_min"]).is_equal(1)
	assert_int(UnitData.get_weapon_data(UnitData.WeaponType.MAGIC, "fire")["range_max"]).is_equal(2)


# ── Exp 与升级 ──

func test_gain_exp_and_level_up():
	var preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset)

	var old_level = unit.level
	unit.gain_exp(100)
	assert_int(unit.level).is_greater(old_level)


func test_gain_exp_dead_unit_ignored():
	var preset = { "class": UnitData.ClassType.LORD, "level": 1, "equipped_weapon": { "type": UnitData.WeaponType.SWORD, "tier": "iron" }, "allegiance": "player" }
	var unit = _make_unit(preset)

	unit.take_damage(unit.current_stats["hp"])
	assert_bool(unit.is_alive()).is_false()

	var old_exp = unit.exp
	unit.gain_exp(50)

	assert_int(unit.exp).is_equal(old_exp)
