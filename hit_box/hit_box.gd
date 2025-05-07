class_name HitBox
extends Area3D


signal hit_received(damage: float, source: Node)


func take_hit(damage: float, source: Node):
	hit_received.emit(damage, source)
	_notify_components(damage)


func _notify_components(damage: float):
	for child in get_children():
		if child is HitBoxComponent:
			child.handle_hit(damage)
