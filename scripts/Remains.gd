extends RigidBody

var _time_since_creation: float

func _ready():
	_time_since_creation = 0
	pass

func _physics_process(delta):
	_time_since_creation += delta
	if _time_since_creation > 50:
		queue_free()
