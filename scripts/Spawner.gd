extends Area

export var shots: int = 1
export(Array, PackedScene) var entities: Array = []

var _triggered := 0

func _ready():
	var test = $CollisionShape
	pass

func player_entered(body: Node):
	if body is Player:
		if _triggered < shots:
			trigger()

func reset():
	_triggered = 0

func trigger():
	var global_translation = translation
	var world_node: Node = get_parent()
	while world_node != null and not world_node.is_in_group("world"):
		if world_node is Spatial:
			global_translation += world_node.translation
		world_node = world_node.get_parent()
		print(world_node)
	
	if world_node is Spatial:
		for entity in entities:
			entity = entity.instance()
			if entity is Spatial:
				entity.translation = global_translation
			_triggered += 1
			world_node.add_child(entity)
	
	$Particles.restart()
	$Particles.emitting = true
