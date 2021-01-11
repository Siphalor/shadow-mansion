extends KinematicBody
class_name Entity

const UP_DIRECTION := Vector3(0, 1, 0)

export var gravity: float = 60
export var knock_back_resistance: float = 0

var velocity := Vector3(0, 0, 0)
var mirrored: bool = false

func is_mirrored():
	return mirrored

func set_mirrored(m):
	if (m):
		if (!mirrored):
			scale.x = -abs(scale.x)
	else:
		if (mirrored):
			scale.x = abs(scale.x)
	mirrored = m
	
func knock_back(origin: Vector3, strength: float):
	var v := origin.direction_to(translation)
	v.z = 0
	velocity = v.normalized() * strength * (1 - knock_back_resistance)

func _ready():
	pass

func _physics_process(delta):
	if is_on_floor():
		velocity.y = 0
	else:
		velocity.y -= gravity * delta
	_apply_velocities(delta)
	
	velocity = move_and_slide(velocity, UP_DIRECTION)
	if abs(velocity.x) > 0.0002 or abs(velocity.y) > 0.0002:
		_on_moved()
		
func _apply_velocities(delta):
	pass
	
func _on_moved():
	pass
