extends RefCounted

## Shared test factories for creating test data without touching autoloads.


static func make_battler_data(overrides: Dictionary = {}) -> BattlerData:
	var d := BattlerData.new()
	d.id = overrides.get("id", &"test_battler")
	d.display_name = overrides.get("display_name", "Test Battler")
	d.max_hp = overrides.get("max_hp", 100)
	d.max_ee = overrides.get("max_ee", 50)
	d.attack = overrides.get("attack", 20)
	d.magic = overrides.get("magic", 15)
	d.defense = overrides.get("defense", 10)
	d.resistance = overrides.get("resistance", 10)
	d.speed = overrides.get("speed", 10)
	d.luck = overrides.get("luck", 5)
	var abilities_override: Array = overrides.get("abilities", [])
	var typed_abilities: Array[Resource] = []
	for a in abilities_override:
		typed_abilities.append(a)
	d.abilities = typed_abilities
	return d


static func make_battler(
	overrides: Dictionary = {},
) -> Battler:
	var b := Battler.new()
	b.data = make_battler_data(overrides)
	b.initialize_from_data()
	return b


static func make_party_battler(
	overrides: Dictionary = {},
) -> PartyBattler:
	var b := PartyBattler.new()
	b.data = make_battler_data(overrides)
	b.initialize_from_data()
	return b


static func make_enemy_data(overrides: Dictionary = {}) -> EnemyData:
	var d := EnemyData.new()
	d.id = overrides.get("id", &"test_enemy")
	d.display_name = overrides.get("display_name", "Test Enemy")
	d.max_hp = overrides.get("max_hp", 80)
	d.max_ee = overrides.get("max_ee", 30)
	d.attack = overrides.get("attack", 15)
	d.magic = overrides.get("magic", 10)
	d.defense = overrides.get("defense", 8)
	d.resistance = overrides.get("resistance", 8)
	d.speed = overrides.get("speed", 12)
	d.luck = overrides.get("luck", 5)
	d.ai_type = overrides.get("ai_type", EnemyData.AiType.BASIC)
	d.exp_reward = overrides.get("exp_reward", 20)
	d.gold_reward = overrides.get("gold_reward", 10)
	var loot_override: Array = overrides.get("loot_table", [])
	var typed_loot: Array[Dictionary] = []
	for entry in loot_override:
		typed_loot.append(entry)
	d.loot_table = typed_loot
	var abilities_override: Array = overrides.get("abilities", [])
	var typed_abilities: Array[Resource] = []
	for a in abilities_override:
		typed_abilities.append(a)
	d.abilities = typed_abilities
	return d


static func make_enemy_battler(
	overrides: Dictionary = {},
) -> EnemyBattler:
	var b := EnemyBattler.new()
	b.data = make_enemy_data(overrides)
	b.initialize_from_data()
	return b


static func make_ability(overrides: Dictionary = {}) -> AbilityData:
	var a := AbilityData.new()
	a.id = overrides.get("id", &"test_ability")
	a.display_name = overrides.get("display_name", "Test Ability")
	a.ee_cost = overrides.get("ee_cost", 10)
	a.resonance_cost = overrides.get("resonance_cost", 0.0)
	a.damage_base = overrides.get("damage_base", 30)
	a.damage_stat = overrides.get(
		"damage_stat", AbilityData.DamageStat.MAGIC
	)
	a.target_type = overrides.get(
		"target_type", AbilityData.TargetType.SINGLE_ENEMY
	)
	a.element = overrides.get("element", AbilityData.Element.FIRE)
	a.status_effect = overrides.get("status_effect", "")
	a.status_chance = overrides.get("status_chance", 0.0)
	a.status_effect_duration = overrides.get(
		"status_effect_duration", 3
	)
	return a


static func make_item(overrides: Dictionary = {}) -> ItemData:
	var i := ItemData.new()
	i.id = overrides.get("id", &"test_item")
	i.display_name = overrides.get("display_name", "Test Potion")
	i.item_type = overrides.get(
		"item_type", ItemData.ItemType.CONSUMABLE
	)
	i.effect_type = overrides.get(
		"effect_type", ItemData.EffectType.HEAL_HP
	)
	i.effect_value = overrides.get("effect_value", 50)
	return i


static func make_status_effect(
	overrides: Dictionary = {},
) -> StatusEffectData:
	var s := StatusEffectData.new()
	s.id = overrides.get("id", &"test_effect")
	s.display_name = overrides.get("display_name", "Test Effect")
	s.effect_type = overrides.get(
		"effect_type", StatusEffectData.EffectType.DEBUFF
	)
	s.duration = overrides.get("duration", 3)
	s.tick_damage = overrides.get("tick_damage", 0)
	s.tick_heal = overrides.get("tick_heal", 0)
	s.is_magical = overrides.get("is_magical", false)
	s.prevents_action = overrides.get("prevents_action", false)
	s.attack_modifier = overrides.get("attack_modifier", 0)
	s.magic_modifier = overrides.get("magic_modifier", 0)
	s.defense_modifier = overrides.get("defense_modifier", 0)
	s.resistance_modifier = overrides.get("resistance_modifier", 0)
	s.speed_modifier = overrides.get("speed_modifier", 0)
	s.luck_modifier = overrides.get("luck_modifier", 0)
	return s


static func make_equipment(
	overrides: Dictionary = {},
) -> EquipmentData:
	var e := EquipmentData.new()
	e.id = overrides.get("id", &"test_sword")
	e.display_name = overrides.get("display_name", "Test Sword")
	e.slot_type = overrides.get(
		"slot_type", EquipmentData.SlotType.WEAPON
	)
	e.weapon_type = overrides.get(
		"weapon_type", EquipmentData.WeaponType.SWORD
	)
	e.attack_bonus = overrides.get("attack_bonus", 0)
	e.magic_bonus = overrides.get("magic_bonus", 0)
	e.defense_bonus = overrides.get("defense_bonus", 0)
	e.resistance_bonus = overrides.get("resistance_bonus", 0)
	e.speed_bonus = overrides.get("speed_bonus", 0)
	e.luck_bonus = overrides.get("luck_bonus", 0)
	e.max_hp_bonus = overrides.get("max_hp_bonus", 0)
	e.max_ee_bonus = overrides.get("max_ee_bonus", 0)
	e.element = overrides.get(
		"element", AbilityData.Element.NONE
	)
	e.buy_price = overrides.get("buy_price", 0)
	e.sell_price = overrides.get("sell_price", 0)
	return e


static func make_character_data(
	overrides: Dictionary = {},
) -> CharacterData:
	var c := CharacterData.new()
	c.id = overrides.get("id", &"test_hero")
	c.display_name = overrides.get("display_name", "Test Hero")
	c.max_hp = overrides.get("max_hp", 100)
	c.max_ee = overrides.get("max_ee", 50)
	c.attack = overrides.get("attack", 10)
	c.magic = overrides.get("magic", 10)
	c.defense = overrides.get("defense", 10)
	c.resistance = overrides.get("resistance", 10)
	c.speed = overrides.get("speed", 10)
	c.luck = overrides.get("luck", 5)
	c.level = overrides.get("level", 1)
	c.current_xp = overrides.get("current_xp", 0)
	c.hp_growth = overrides.get("hp_growth", 10.0)
	c.ee_growth = overrides.get("ee_growth", 5.0)
	c.attack_growth = overrides.get("attack_growth", 1.5)
	c.magic_growth = overrides.get("magic_growth", 1.5)
	c.defense_growth = overrides.get("defense_growth", 1.5)
	c.resistance_growth = overrides.get("resistance_growth", 1.5)
	c.speed_growth = overrides.get("speed_growth", 1.0)
	c.luck_growth = overrides.get("luck_growth", 1.0)
	var abilities_override: Array = overrides.get("abilities", [])
	var typed_abilities: Array[Resource] = []
	for a in abilities_override:
		typed_abilities.append(a)
	c.abilities = typed_abilities
	return c


static func make_quest(overrides: Dictionary = {}) -> QuestData:
	var q := QuestData.new()
	q.id = overrides.get("id", &"test_quest")
	q.title = overrides.get("title", "Test Quest")
	q.description = overrides.get("description", "A test quest.")
	var raw_obj: Array = overrides.get(
		"objectives", ["Objective A", "Objective B"]
	)
	var obj: Array[String] = []
	for s in raw_obj:
		obj.append(s)
	q.objectives = obj
	q.reward_gold = overrides.get("reward_gold", 100)
	q.reward_exp = overrides.get("reward_exp", 50)
	var raw_items: Array = overrides.get("reward_item_ids", [])
	var items: Array[StringName] = []
	for item in raw_items:
		items.append(item)
	q.reward_item_ids = items
	q.quest_type = overrides.get(
		"quest_type", QuestData.QuestType.MAIN
	)
	var raw_prereqs: Array = overrides.get("prerequisites", [])
	var prereqs: Array[String] = []
	for p in raw_prereqs:
		prereqs.append(p)
	q.prerequisites = prereqs
	return q
