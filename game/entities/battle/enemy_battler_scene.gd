class_name EnemyBattlerScene
extends Node2D

## Visual representation of an enemy in battle.
## Connects to an EnemyBattler logic node for stat/signal data.

@export var enemy_data: EnemyData

var battler: EnemyBattler = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var hp_bar: ProgressBar = $HPBar
@onready var damage_label: Label = $DamageLabel


func _ready() -> void:
	hp_bar.visible = false
	damage_label.visible = false
	if enemy_data and not enemy_data.sprite_path.is_empty():
		var tex := load(enemy_data.sprite_path) as Texture2D
		if tex == null:
			push_error(
				"Failed to load '%s' — reopen Godot editor to import"
				% enemy_data.sprite_path
			)
			return
		var cols: int = enemy_data.sprite_columns
		var rows: int = enemy_data.sprite_rows
		if cols > 1 or rows > 1:
			var frame_w: float = tex.get_width() / float(cols)
			var frame_h: float = tex.get_height() / float(rows)
			var center_col: int = cols / 2
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(
				center_col * frame_w, 0,
				frame_w, frame_h,
			)
			atlas.filter_clip = true
			sprite.texture = atlas
		else:
			sprite.texture = tex
		sprite.scale = Vector2.ONE * enemy_data.battle_scale


func bind_battler(target: EnemyBattler) -> void:
	battler = target
	battler.hp_changed.connect(_on_hp_changed)
	battler.damage_taken.connect(_on_damage_taken)
	battler.defeated.connect(_on_defeated)

	hp_bar.max_value = battler.max_hp
	hp_bar.value = battler.current_hp
	hp_bar.min_value = 0
	hp_bar.show_percentage = false


func play_attack_anim() -> void:
	if anim_player.has_animation("attack"):
		anim_player.play("attack")
		await anim_player.animation_finished
	else:
		# Lunge forward toward party (right), then snap back
		var origin_x := position.x
		var tween := create_tween()
		tween.tween_property(self, "position:x", origin_x + 20.0, 0.1)
		tween.tween_interval(0.06)
		tween.tween_property(self, "position:x", origin_x, 0.08)
		await tween.finished


func play_damage_anim() -> void:
	if anim_player.has_animation("damage"):
		anim_player.play("damage")
		await anim_player.animation_finished
	else:
		# Flash white then red with recoil
		var origin_x := position.x
		var tween := create_tween()
		tween.tween_property(sprite, "modulate", Color(1.5, 1.5, 1.5), 0.04)
		tween.tween_property(self, "position:x", origin_x - 4.0, 0.03)
		tween.tween_property(sprite, "modulate", Color.RED, 0.06)
		tween.tween_property(self, "position:x", origin_x + 3.0, 0.03)
		tween.tween_property(self, "position:x", origin_x, 0.04)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.12)
		await tween.finished


func play_death_anim() -> void:
	if anim_player.has_animation("death"):
		anim_player.play("death")
		await anim_player.animation_finished
	else:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
		tween.tween_property(sprite, "scale", Vector2(0.5, 0.5), 0.5)
		await tween.finished


func show_damage_number(amount: int) -> void:
	damage_label.text = str(amount)
	damage_label.visible = true
	damage_label.modulate.a = 1.0
	damage_label.position = Vector2(0, -20)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(damage_label, "position:y", damage_label.position.y - 24.0, 0.6)
	tween.tween_property(damage_label, "modulate:a", 0.0, 0.6).set_delay(0.3)
	await tween.finished
	damage_label.visible = false


func show_hp_bar() -> void:
	hp_bar.visible = true


func hide_hp_bar() -> void:
	hp_bar.visible = false


func _on_hp_changed(new_hp: int, max_hp_val: int) -> void:
	hp_bar.max_value = max_hp_val
	hp_bar.value = new_hp
	show_hp_bar()


func _on_damage_taken(amount: int) -> void:
	show_damage_number(amount)
	play_damage_anim()


func _on_defeated() -> void:
	play_death_anim()
