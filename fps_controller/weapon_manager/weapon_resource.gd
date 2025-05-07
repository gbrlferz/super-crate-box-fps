class_name WeaponResource
extends Resource

@export var damage := 10

## Weapon Logic
var trigger_down := false:
	set(new_trigger_state):
		if trigger_down != new_trigger_state:
			trigger_down = new_trigger_state
			if trigger_down:
				on_trigger_down()
			else:
				on_trigger_up()

var is_equipped := false:
	set(new_equipped_state):
		if is_equipped != new_equipped_state:
			if is_equipped:
				on_equip()
			else:
				on_unequip()


func on_trigger_down():
	print("SHOOT!!!")
	pass



func on_trigger_up():
	print("STOPPER SHOOT!!!")
	pass


func on_equip():
	pass


func on_unequip():
	pass
