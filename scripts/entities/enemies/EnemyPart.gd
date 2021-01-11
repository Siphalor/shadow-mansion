extends Node
class_name EnemyPart

export var collision_damage: int = 1

func _ready():
	pass

func get_enemy() -> Enemy:
	var node = get_parent()
	while node != null and not node is Enemy:
		node = node.get_parent()
	return node
