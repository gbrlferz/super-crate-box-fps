class_name WeaponManager
extends Node3D


signal on_shoot

@export var current_weapon: WeaponResource
@export var player: CharacterBody3D
@export var bullet_raycast: RayCast3D


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		on_shoot.emit()
		current_weapon.trigger_down = true
		bullet_raycast.force_raycast_update()
		if bullet_raycast.is_colliding():
			var collider = bullet_raycast.get_collider()
			if collider is HitBox:
				collider.take_hit(current_weapon.damage, self)
	if event.is_action_released("shoot"):
		current_weapon.trigger_down = false
