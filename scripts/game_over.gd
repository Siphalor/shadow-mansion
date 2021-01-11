extends Control


func _ready():
	pass

func _on_restart_pressed():
	Global.change_scene('scenes/level.tscn')
