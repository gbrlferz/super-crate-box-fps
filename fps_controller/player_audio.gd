extends AudioStreamPlayer3D

@export var weapon_manager: WeaponManager

@export_group("Audio Stream")
@export var shoot_clip: AudioStream


func _ready() -> void:
	weapon_manager.on_shoot.connect(_play_shoot)


func _play_shoot() -> void:
	stream = shoot_clip
	play()
