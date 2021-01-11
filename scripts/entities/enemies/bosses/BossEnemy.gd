extends Enemy
class_name BossEnemy

func _ready():
	begin_fight()

func begin_fight():
	Global.boss = self
	Global.update_shadow_bar()

func on_damage_taken(damage: float):
	.on_damage_taken(damage)
	Global.update_shadow_bar()

func on_death(type: String = ''):
	if type == 'player_shadow_collect':
		.on_death(type)
	else:
		Global.update_shadow_bar()

func collect_shadows():
	$shadowParticles.emitting = true
	pass
