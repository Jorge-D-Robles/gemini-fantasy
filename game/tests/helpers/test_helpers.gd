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


static func make_ability(overrides: Dictionary = {}) -> AbilityData:
	var a := AbilityData.new()
	a.id = overrides.get("id", &"test_ability")
	a.display_name = overrides.get("display_name", "Test Ability")
	a.ee_cost = overrides.get("ee_cost", 10)
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
