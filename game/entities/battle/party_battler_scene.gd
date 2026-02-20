class_name PartyBattlerScene
extends Node2D

## Visual representation of a party member in battle.
## Connects to a PartyBattler logic node for stat/signal data.

const UITheme = preload("res://ui/ui_theme.gd")
const BATTLE_SPRITE_SCALE: float = 3.0

@export var character_data: CharacterData

var battler: PartyBattler = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var hp_bar: ProgressBar = $HPBar
@onready var ee_bar: ProgressBar = $EEBar
@onready var status_icons: HBoxContainer = $StatusIcons


func _ready() -> void:
	_setup_bars()
	if character_data and not character_data.battle_sprite_path.is_empty():
		var tex := load(character_data.battle_sprite_path) as Texture2D
		if tex:
			sprite.texture = tex
			sprite.scale = Vector2.ONE * BATTLE_SPRITE_SCALE
			sprite.flip_h = true
		else:
			push_error(
				"Failed to load '%s' — reopen Godot editor to import"
				% character_data.battle_sprite_path
			)


func bind_battler(target: PartyBattler) -> void:
	battler = target
	battler.hp_changed.connect(_on_hp_changed)
	battler.ee_changed.connect(_on_ee_changed)
	battler.damage_taken.connect(_on_damage_taken)
	battler.status_effect_applied.connect(_on_status_applied)
	battler.status_effect_removed.connect(_on_status_removed)
	battler.defeated.connect(_on_defeated)
	update_bars()


func update_bars() -> void:
	if not battler:
		return
	hp_bar.max_value = battler.max_hp
	hp_bar.value = battler.current_hp
	ee_bar.max_value = battler.max_ee
	ee_bar.value = battler.current_ee


func play_attack_anim() -> void:
	if anim_player.has_animation("attack"):
		anim_player.play("attack")
		await anim_player.animation_finished
	else:
		# Step forward toward enemies (left), then snap back
		var origin_x := position.x
		var tween := create_tween()
		tween.tween_property(self, "position:x", origin_x - 24.0, 0.12)
		tween.tween_interval(0.06)
		tween.tween_property(self, "position:x", origin_x, 0.08)
		await tween.finished


func play_damage_anim() -> void:
	if anim_player.has_animation("damage"):
		anim_player.play("damage")
		await anim_player.animation_finished
	else:
		# Flash white then red, with a small recoil shake
		var origin_x := position.x
		var tween := create_tween()
		tween.tween_property(sprite, "modulate", Color(1.5, 1.5, 1.5), 0.04)
		tween.tween_property(self, "position:x", origin_x + 4.0, 0.03)
		tween.tween_property(sprite, "modulate", Color.RED, 0.06)
		tween.tween_property(self, "position:x", origin_x - 3.0, 0.03)
		tween.tween_property(self, "position:x", origin_x, 0.04)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.12)
		await tween.finished


func play_heal_anim() -> void:
	await _flash_color(Color.GREEN)


func play_idle_anim() -> void:
	if anim_player.has_animation("idle"):
		anim_player.play("idle")


func show_damage_number(amount: int) -> void:
	var popup := DamagePopup.new()
	add_child(popup)
	popup.setup(amount, DamagePopup.PopupType.DAMAGE)


func show_heal_number(amount: int) -> void:
	var popup := DamagePopup.new()
	add_child(popup)
	popup.setup(amount, DamagePopup.PopupType.HEAL)


func _setup_bars() -> void:
	hp_bar.min_value = 0
	hp_bar.show_percentage = false
	hp_bar.size = Vector2(48, 4)
	hp_bar.position = Vector2(-24, -54)

	ee_bar.min_value = 0
	ee_bar.show_percentage = false
	ee_bar.size = Vector2(48, 3)
	ee_bar.position = Vector2(-24, -49)


func _flash_color(color: Color) -> void:
	var original_mod := sprite.modulate
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", color, 0.08)
	tween.tween_property(sprite, "modulate", original_mod, 0.15)
	await tween.finished


func _on_hp_changed(new_hp: int, max_hp_val: int) -> void:
	hp_bar.max_value = max_hp_val
	hp_bar.value = new_hp


func _on_ee_changed(new_ee: int, max_ee_val: int) -> void:
	ee_bar.max_value = max_ee_val
	ee_bar.value = new_ee


func _on_damage_taken(amount: int) -> void:
	show_damage_number(amount)
	play_damage_anim()


func _on_status_applied(effect: StringName) -> void:
	var icon := Label.new()
	icon.name = String(effect)
	icon.text = String(effect).left(2).to_upper()
	icon.add_theme_font_size_override("font_size", 8)
	var color := UITheme.LOG_STATUS
	if battler:
		var eff_data: StatusEffectData = battler.get_effect_data(effect)
		if eff_data:
			color = UITheme.get_status_color(eff_data.effect_type)
	icon.add_theme_color_override("font_color", color)
	status_icons.add_child(icon)


func _on_status_removed(effect: StringName) -> void:
	var icon: Node = status_icons.get_node_or_null(String(effect))
	if icon:
		icon.queue_free()


func _on_defeated() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.3, 0.4)
	await tween.finished
