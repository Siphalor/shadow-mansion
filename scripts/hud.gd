extends Node
class_name HUD

func _ready():
	set_lanterns(3)
	Global.set_hud(self)

func set_lanterns(lantern_count: int):
	if lantern_count > 0:
		$lanterns.margin_right = 256 * lantern_count
		$lanterns.visible = true
	else:
		$lanterns.visible = false

func get_shadow_bar_visible() -> bool:
	return $shadowBar.visible

func set_shadow_bar_visible(visible: bool) -> void:
	if visible:
		$animator.play("boss_fight_begin")
	else:
		$animator.play("boss_fight_end")

func set_shadow_bar(value: int, length: int):
	$shadowBar.value = value
	$shadowBar.max_value = length
