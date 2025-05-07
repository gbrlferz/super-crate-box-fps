extends CharacterBody3D

@onready var nav_agent := $NavigationAgent3D

@export var speed := 3.5
@export var target: Node3D


func _physics_process(_delta: float) -> void:
	target_position()


func _process(delta: float) -> void:
	if not is_on_floor():
		velocity -= get_gravity() * delta
	else:
		velocity.y -= 2
	
	var next_location: Vector3 = nav_agent.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * speed
	
	velocity = velocity.move_toward(new_velocity, 0.25)
	move_and_slide()


func target_position():
	nav_agent.target_position = target.position
