extends AIMovement

export(float) var speed = 6

func _ready():
	pass

func apply_velocities(entity: Entity, velocity: Vector3, delta: float):
	var norm := (Global.player.translation - entity.translation).normalized()
	velocity.x = lerp(velocity.x, norm.x * speed, 0.2 * delta)
	velocity.y = lerp(velocity.y, norm.y * speed, 0.2 * delta)
	return velocity
