extends Spatial
class_name Pickup

export var lanterns: int = 1

func _ready():
	pass

func apply():
	Global.player.set_health(min(Global.player.max_health, Global.player.health + lanterns))
	
	if has_node("pickupSound"):
		var node = get_node("pickupSound")
		if node is AudioStreamPlayer3D:
			node.connect("finished", node, "queue_free")
			self.remove_child(node)
			node.translation = translation + node.translation
			get_parent().add_child(node)
			node.play()
			queue_free()

func set_highlight(highlight: bool):
	pass
