extends CharacterBody3D


@export var look_sensitivity : float = 0.006

@onready var camera := %Camera3D
@onready var world_model := %WorldModel


func _ready() -> void:
	for child in world_model.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sensitivity)
			camera.rotate_x(-event.relative.y * look_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(_delta: float) -> void:
	pass


func _process(_delta: float) -> void:
	pass
