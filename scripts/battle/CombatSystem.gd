extends Node

enum CombatResult { ATTACKER_WIN, DEFENDER_WIN, DRAW }

var attacker: Node = null
var defender: Node = null
var preview: Dictionary = {}

signal combat_started(attacker, defender)
signal combat_ended(attacker, defender, result)
signal combat_preview_ready(preview)

func calculate_preview(atk: Node, def: Node, atk_pos: Vector2i, def_pos: Vector2i) -> Dictionary:
	var terrain = def.apply_terrain_bonus(def_pos)
	var atk_power = atk.get_attack()
	var def_stat = def.get_resistance() if atk.is_magic_weapon() else def.get_defense()
	var triangle = UnitData.get_weapon_triangle_bonus(atk.weapon.get("type", -1), def.weapon.get("type", -1))

	var base_damage = max(0, atk_power - (def_stat + terrain["defense"])) + triangle["damage_bonus"]
	if def.weapon.get("type") == UnitData.WeaponType.STAFF:
		base_damage = atk.get_attack()

	var hit_rate = atk.get_hit() - (def.get_avoid() + terrain["avoid"]) + triangle["hit_bonus"]
	hit_rate = clamp(hit_rate, 0, 100)

	var crit_rate = atk.get_crit()
	crit_rate = clamp(crit_rate, 0, 100)

	var can_double = false
	var atk_speed = atk.get_attack_speed()
	var def_speed = def.get_attack_speed()
	if def.weapon.get("type") != UnitData.WeaponType.STAFF:
		can_double = atk_speed >= def_speed + 4

	var can_counter = false
	if def.weapon.get("type") != UnitData.WeaponType.STAFF:
		var def_range_min = def.weapon.get("range_min", 1)
		var def_range_max = def.weapon.get("range_max", 1)
		var dist = abs(atk_pos.x - def_pos.x) + abs(atk_pos.y - def_pos.y)
		can_counter = dist >= def_range_min and dist <= def_range_max

	return {
		"attacker": atk,
		"defender": def,
		"damage": base_damage,
		"hit_rate": hit_rate,
		"crit_rate": crit_rate,
		"can_double": can_double,
		"can_counter": can_counter,
		"triangle_advantage": triangle["advantage"],
		"triangle_bonus": triangle["damage_bonus"]
	}

func execute_combat(atk: Node, def: Node, atk_pos: Vector2i, def_pos: Vector2i) -> CombatResult:
	combat_started.emit(atk, def)

	var p = calculate_preview(atk, def, atk_pos, def_pos)
	var result = CombatResult.DRAW
	var atk_exp = UnitData.get_combat_exp()
	var def_exp = UnitData.get_combat_exp()

	var hit_roll = randi() % 100
	if hit_roll < p["hit_rate"]:
		var is_crit = (randi() % 100) < p["crit_rate"]
		var dmg = p["damage"] * (2 if is_crit else 1)
		def.take_damage(dmg)
		atk_exp += 5

	if not def.is_alive():
		def.unit_died.emit(def)
		atk_exp = UnitData.get_kill_exp(def.level, atk.level)
		atk.gain_exp(atk_exp)
		combat_ended.emit(atk, def, CombatResult.ATTACKER_WIN)
		return CombatResult.ATTACKER_WIN

	if p["can_counter"]:
		var counter_damage = _calc_counter_damage(def, atk, def_pos, atk_pos)
		if counter_damage > 0:
			var counter_hit = _calc_counter_hit(def, atk, def_pos, atk_pos)
			if (randi() % 100) < counter_hit:
				atk.take_damage(counter_damage)
				def_exp += 5

	if not atk.is_alive():
		atk.unit_died.emit(atk)
		def.gain_exp(UnitData.get_kill_exp(atk.level, def.level))
		combat_ended.emit(atk, def, CombatResult.DEFENDER_WIN)
		return CombatResult.DEFENDER_WIN

	if p["can_double"] and def.is_alive():
		var hit_roll2 = randi() % 100
		if hit_roll2 < p["hit_rate"]:
			var is_crit2 = (randi() % 100) < p["crit_rate"]
			var dmg2 = p["damage"] * (2 if is_crit2 else 1)
			def.take_damage(dmg2)

		if not def.is_alive():
			def.unit_died.emit(def)
			atk.gain_exp(clamp(UnitData.get_combat_exp() + 10, 5, 100))
			combat_ended.emit(atk, def, CombatResult.ATTACKER_WIN)
			return CombatResult.ATTACKER_WIN

	atk.has_acted = true
	def.has_acted = true
	atk.gain_exp(atk_exp)
	if def.weapon.get("type") != UnitData.WeaponType.STAFF:
		def.gain_exp(def_exp)

	combat_ended.emit(atk, def, CombatResult.DRAW)
	return CombatResult.DRAW

func _calc_counter_damage(defender: Node, attacker: Node, def_pos: Vector2i, atk_pos: Vector2i) -> int:
	var terrain = attacker.apply_terrain_bonus(atk_pos)
	var atk_stat = attacker.get_resistance() if defender.is_magic_weapon() else attacker.get_defense()
	return max(0, defender.get_attack() - (atk_stat + terrain["defense"]))

func _calc_counter_hit(defender: Node, attacker: Node, def_pos: Vector2i, atk_pos: Vector2i) -> int:
	var terrain = attacker.apply_terrain_bonus(atk_pos)
	var hit = defender.get_hit() - (attacker.get_avoid() + terrain["avoid"])
	return clamp(hit, 0, 100)
