extends MarginContainer

@export var points_label: Label


func _ready() -> void:
	Global.on_point.connect(_on_point)


func _on_point() -> void:
	points_label.text = str(Global.points)
