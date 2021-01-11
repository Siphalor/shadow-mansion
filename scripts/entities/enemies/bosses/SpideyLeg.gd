extends EnemyPart
class_name SpideyLeg

func _ready():
	pass

func is_attacking() -> bool:
	return $animator.current_animation == 'attack'

func attack():
	$animator.play("attack")

func _on_animation_finished(anim_name):
	if anim_name == "attack":
		$animator.play("idle")
