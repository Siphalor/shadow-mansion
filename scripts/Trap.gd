extends Node
class_name Trap

export var damage: int = 0

func _ready():
	pass

func trigger(entity: LivingEntity):
	if damage > 0:
		entity.take_damage(damage, "trap")
