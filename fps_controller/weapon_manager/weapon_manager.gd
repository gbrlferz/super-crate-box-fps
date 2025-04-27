class_name WeaponManager
extends Node3D

@export var current_weapon: WeaponResource

@export var player: CharacterBody3D
@export var bullet_raycast: RayCast3D

@export var view_model_container: Node3D

var current_weapon_view_model: Node3D


func _ready() -> void:
	update_weapon_model()


func update_weapon_model() -> void:
	if current_weapon:
		if view_model_container || current_weapon_view_model:
			current_weapon_view_model = current_weapon.view_model.instantiate()
			view_model_container.add_child(current_weapon_view_model)
			current_weapon_view_model.position = current_weapon.pos
			current_weapon_view_model.rotation = current_weapon.rot
			play_animation(current_weapon.view_idle_animation)


func play_animation(animation_name: String) -> void:
	var animation_player : AnimationPlayer = current_weapon_view_model.get_node_or_null("AnimationPlayer")
	if not animation_player || !animation_player.has_animation(animation_name):
		return

	animation_player.seek(0.0)
	animation_player.play(animation_name)
