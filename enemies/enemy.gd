extends CharacterBody3D

@export var speed := 3.5

@onready var nav_agent := $NavigationAgent3D
@onready var target : Node3D = Global.portal

var spawn_position: Vector3
var hostile := false


func _ready() -> void:
	spawn_position = Vector3(randf_range(-10.0, 10.0), 0.0, randf_range(-10.0, 10.0))
	position = spawn_position


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

	if current_location.distance_to(target.position) < 1.5:
		if hostile:
			print("LOSER")
		else:
			position = spawn_position
			target = Global.player
			hostile = true
			speed *= 2

	if is_on_floor():
		velocity = velocity.move_toward(new_velocity, 0.25)
	else:
		velocity = Vector3.ZERO

	move_and_slide()


func target_position():
	if target:
		nav_agent.target_position = target.position
