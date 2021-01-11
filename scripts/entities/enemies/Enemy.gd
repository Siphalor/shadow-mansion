extends LivingEntity
class_name Enemy

const _REMAINS_VELOCITY = 1
const _REMAINS_VELOCITY_ANGLE = 1

export(GDScript) var movement
export var collision_damage: float = 0
export(Array, PackedScene) var death_remains: Array = []

func _ready():
	if movement != null:
		movement = movement.new()
	pass

func _apply_velocities(delta):
	._apply_velocities(delta)
	if movement is AIMovement:
		velocity = movement.apply_velocities(self, velocity, delta)

func on_damage_taken(damage: float):
	_try_play_sound('hurtSound')
	if has_node("hurtParticles"):
		var node = get_node("hurtParticles")
		if node is Particles:
			node.restart()
			node.emitting = true
	.on_damage_taken(damage)
	
func on_death(type: String = ''):
	for remain in death_remains:
		var node: Node = remain.instance()
		node.translation = translation
		if node is RigidBody:
			var angle := rand_range(-_REMAINS_VELOCITY_ANGLE, _REMAINS_VELOCITY_ANGLE)
			var x := sin(angle) * _REMAINS_VELOCITY
			var y := cos(angle) * _REMAINS_VELOCITY
			node.linear_velocity = Vector3(x, y, 0)
			angle = rand_range(0, 2 * PI)
			node.rotation.z = angle
		get_parent().add_child(node)
	
	var particles: Particles = null
	if has_node("deathParticles"):
		var node = get_node("deathParticles")
		if node is Particles:
			particles = node
	elif has_node("hurtParticles"):
		var node = get_node("hurtParticles")
		if node is Particles:
			particles = node
	
	if particles != null:
		remove_child(particles)
		var t := Timer.new()
		t.one_shot = true
		t.wait_time = 3
		t.connect("timeout", particles, "queue_free")
		particles.add_child(t)
		particles.translation = translation + particles.translation
		get_parent().add_child(particles)
		
		particles.restart()
		particles.emitting = true
	
	if has_node("deathSound"):
		var sound = $deathSound
		remove_child(sound)
		get_parent().add_child(sound)
		sound.translation = translation + sound.translation
		sound.connect("finished", sound, "queue_free")
		sound.play()
		queue_free()
	else:
		queue_free()
	
func _try_play_sound(path: String) -> bool:
	if has_node(path):
		var node = get_node(path)
		if node is AudioStreamPlayer3D:
			node.play()
			return true
	return false
