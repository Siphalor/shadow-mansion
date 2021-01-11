extends Entity
class_name LivingEntity

export (int) var max_health = 3
export (int) var _damage_cooldown = 1

var health: float
var _damage_cooldown_time = 0

func _ready():
	health = max_health
	pass

func _apply_velocities(delta):
	if _damage_cooldown_time > 0:
		_damage_cooldown_time -= delta
	._apply_velocities(delta)

func take_damage(damage: float, type: String = ''):
	if _damage_cooldown_time > 0:
		return
	else:
		_damage_cooldown_time = _damage_cooldown
	health -= damage
	if health <= 0:
		on_death(type)
	elif damage > 0:
		on_damage_taken(damage)

func on_death(type: String = ''):
	queue_free()
	pass

func on_damage_taken(damage: float):
	pass
