extends Node

@export var enemy: PackedScene
@export var spawn_rate := 5.0

var spawn_timer := 0.0

func _process(delta: float) -> void:
	spawn_timer += delta

	if spawn_timer > spawn_rate:
		spawn_timer = 0.0
		var enemy_spawned := enemy.instantiate()
		add_child(enemy_spawned)
