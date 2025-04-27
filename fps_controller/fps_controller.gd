extends CharacterBody3D


@onready var camera := %Camera3D
@onready var world_model := %WorldModel

@export var look_sensitivity := 0.006
@export var controller_look_sensitivity := 0.05
@export var jump_velocity := 6.0
@export var auto_bhop := true

const HEADBOB_MOVE_AMOUNT := 0.06
const HEADBOB_FREQUENCY := 2.04
var headbob_time := 0.0

# Ground movement settings.
@export_group("Ground movement")
@export var walk_speed := 7.0
@export var sprint_speed := 8.5
@export var ground_accel := 14.0
@export var ground_decel := 10.0
@export var ground_friction := 6.0

# Air movement settings. Need to tweak these to get the feeling dialed in.
@export_group("Air movement")
@export var air_cap := 0.85 ## Can surf steeper ramps if this is higher, makes it easier to stick and bhop.
@export var air_accel := 800.0
@export var air_move_speed := 500.0

var wish_dir := Vector3.ZERO
var cam_aligned_wish_dir := Vector3.ZERO

var no_clip_speed_mult := 3.0
var no_clip := false


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


func _handle_noclip(delta: float) -> bool:
	if Input.is_action_just_pressed("no_clip") and OS.has_feature("debug"):
		no_clip = !no_clip
	
	$CollisionShape3D.disabled = no_clip

	if not no_clip:
		return false

	var speed = get_move_speed() * no_clip_speed_mult
	if Input.is_action_pressed("sprint"):
		speed *= 3.0

	if Input.is_action_pressed("jump"):
		global_position += Vector3.UP * speed * delta
	elif Input.is_action_pressed("crouch"):
		global_position += Vector3.DOWN * speed * delta

	self.velocity = cam_aligned_wish_dir * speed
	global_position += self.velocity * delta

	return true


func _handle_ground_physics(delta: float) -> void:
	# Similar to air movement. Acceleration and friction on ground.
	var cur_speed_in_wish_dir := self.velocity.dot(wish_dir)
	var add_speed_till_cap := get_move_speed() - cur_speed_in_wish_dir
	if add_speed_till_cap >0:
		var accel_speed := ground_accel * delta * get_move_speed()
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir

	# Apply friction
	var control: float = max(self.velocity.length(), ground_decel)
	var drop := control * ground_friction * delta
	var new_speed: float = max(self.velocity.length() - drop, 0.0)
	if self.velocity.length() > 0:
		new_speed /= self.velocity.length()
	self.velocity *= new_speed

	_headbob_effect(delta)


func _handle_air_physics(delta: float) -> void:
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	# self.velocity -= get_gravity()

	# Classic battle tested & fan favorite source/quake air movement
	# CSS players gonna feel their gamer instincts kick in with this one
	var cur_speed_in_wish_dir := self.velocity.dot(wish_dir) # Dot product of velocity and the wish direction.
	# Wish speed (if wish_dir > 0 length) capped to air_cap
	var capped_speed: float = min((air_move_speed * wish_dir).length(), air_cap)
	# How much to get to the speed the player wishes (in the new dir)
	# Notice this allows for infinite speed. If wish_dir is perpendicular, we always need to add velocity
	#  no matter how fast we are going. This is what allows for things like bhop in CSS & Quake.
	# Also happens to just give some very nice feeling movement & responsiveness when in air.
	var add_speed_till_cap := capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed := air_accel * air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		self.velocity += accel_speed * wish_dir


func _physics_process(delta: float) -> void:
	var input_dir: Vector2

	if InputEventJoypadMotion: # Don't normalize input if it's a controller
		input_dir = Input.get_vector("left", "right", "up", "down")
	else:
		input_dir = Input.get_vector("left", "right", "up", "down").normalized()

	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	cam_aligned_wish_dir = camera.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)

	if not _handle_noclip(delta):
		if is_on_floor():
			if Input.is_action_pressed("jump") || (auto_bhop && Input.is_action_pressed("jump")):
				self.velocity.y = jump_velocity
			_handle_ground_physics(delta)
		else:
			_handle_air_physics(delta)

		move_and_slide()
