class_name HealthComponent
extends HitBoxComponent


signal died

@export var max_health := 100.0
var current_health: float


func _ready() -> void:
	current_health = max_health


func handle_hit(damage: float) -> void:
	current_health = max(current_health - damage, 0)

	if current_health <= 0:
		get_parent().get_parent().queue_free()
		died.emit()
