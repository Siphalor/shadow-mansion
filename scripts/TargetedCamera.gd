extends Camera
class_name TargetedCamera

var target_pos: Vector3 = Vector3(0, 0, 0)

func _ready():
	target_pos = translation
	pass

func _process(delta):
	if (target_pos - translation).length_squared() > 0.1:
		translation = lerp(translation, target_pos, min(delta, 1))
