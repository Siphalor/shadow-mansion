extends Pickup

func _ready():
	pass

func set_highlight(highlight: bool):
	if highlight:
		$light.time_until_next_flicker = INF
		$light.light_energy_dest = 3
	else:
		$light.time_until_next_flicker = 0
		$light.light_energy_dest = 1
