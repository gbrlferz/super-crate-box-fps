class_name Crate
extends Area3D


func _init() -> void:
	body_entered.connect(_on_body_entered)


func _ready() -> void:
	position = get_random_position()
	

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		Global.add_points(1)
		position = get_random_position()


func get_random_position() -> Vector3:
	return Vector3(randf_range(-24,24), 0.0, randf_range(-24,24))
