extends "res://scripts/Spawner.gd"


func _ready():
	pass

func _on_body_exited(body):
	if body is BossEnemy:
		fight_end()

func trigger():
	.trigger()
	fight_begin()

func fight_begin():
	$doorAnimator.play("door_close")
	$camera.make_current()
	pass

func fight_end():
	$doorAnimator.play("door_open")
	Global.player_camera.make_current()
	pass
