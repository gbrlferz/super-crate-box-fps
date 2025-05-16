extends Node


signal on_point

var player: Player
var portal: Portal
var points: int


func add_points(value: int) -> void:
	points += value
	on_point.emit()
