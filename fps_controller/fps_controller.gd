extends CharacterBody3D


@onready var camera := %Camera3D
@onready var world_model := %WorldModel

@export var look_sensitivity := 0.006
@export var controller_look_sensitivity := 0.05
@export var jump_velocity := 6.0
@export var auto_bhop := true
@export var walk_speed := 7.0
@export var sprint_speed := 8.5

const HEADBOB_MOVE_AMOUNT := 0.06
const HEADBOB_FREQUENCY := 2.04
var headbob_time := 0.0

var wish_dir := Vector3.ZERO


func get_move_speed() -> float:
	return sprint_speed if Input.is_action_pressed("sprint") else walk_speed


func _ready() -> void:
	for child in world_model.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)


func _unhandled_input(event: InputEvent) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sensitivity)
			camera.rotate_x(-event.relative.y * look_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	else:
		if event.is_action_pressed("ui_cancel"):
			get_tree().quit()

	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _headbob_effect(delta: float) -> void:
		headbob_time += delta * self.velocity.length()
		camera.transform.origin = Vector3(
					cos(headbob_time * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUNT,
					sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUNT,
					0,
			)


func _handle_controller_look_input(_delta: float) -> void:
	var target_look := Input.get_vector("look_left", "look_right", "look_down", "look_up")
	var _cur_controller_look := target_look
	rotate_y(-_cur_controller_look.x * controller_look_sensitivity) # turn left and right
	camera.rotate_x(_cur_controller_look.y * controller_look_sensitivity) # turn up and down
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _process(delta: float) -> void:
	_handle_controller_look_input(delta)


func _handle_ground_physics(delta: float) -> void:
	self.velocity.x = wish_dir.x * get_move_speed()
	self.velocity.z = wish_dir.z * get_move_speed()

	_headbob_effect(delta)


func _handle_air_physics(delta: float) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	# self.velocity -= get_gravity()


func _physics_process(delta: float) -> void:
	var input_dir: Vector2
	if InputEventJoypadMotion:
		input_dir = Input.get_vector("left", "right", "up", "down")
	else:
		input_dir = Input.get_vector("left", "right", "up", "down").normalized()

	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)

	if is_on_floor():
		if Input.is_action_pressed("jump") || (auto_bhop && Input.is_action_pressed("jump")):
			self.velocity.y = jump_velocity
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)

	move_and_slide()
