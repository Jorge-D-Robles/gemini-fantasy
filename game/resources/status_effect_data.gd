class_name StatusEffectData
extends Resource

## Defines a status effect's type, duration, stat modifiers, and tick behavior.
## Used as a template — active instances are tracked by Battler with remaining
## turn counts.

enum EffectType {
	BUFF,
	DEBUFF,
	DAMAGE_OVER_TIME,
	HEAL_OVER_TIME,
	STUN,
}

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Behavior")
@export var effect_type: EffectType = EffectType.DEBUFF
## Duration in turns. 0 = permanent (must be removed explicitly).
@export var duration: int = 3
## Damage dealt per tick (for DAMAGE_OVER_TIME).
@export var tick_damage: int = 0
## Healing per tick (for HEAL_OVER_TIME).
@export var tick_heal: int = 0
## Whether tick damage uses magic defense calculation.
@export var is_magical: bool = false
## Whether the affected battler cannot act.
@export var prevents_action: bool = false

@export_group("Stat Modifiers")
@export var attack_modifier: int = 0
@export var magic_modifier: int = 0
@export var defense_modifier: int = 0
@export var resistance_modifier: int = 0
@export var speed_modifier: int = 0
@export var luck_modifier: int = 0

@export_group("Visuals")
@export var icon_path: String = ""
