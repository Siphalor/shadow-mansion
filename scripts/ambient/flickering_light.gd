extends Light

export var max_light_energy: float = 1
var time_until_next_flicker = 0
var light_energy_dest = 1

func _ready():
	pass

func _process(delta):
	if light_energy != 0 and visible:
		time_until_next_flicker -= delta
		if time_until_next_flicker <= 0:
			if light_energy_dest == 1:
				light_energy_dest = rand_range(0.6, 0.8)
				light_energy_dest *= max_light_energy
				time_until_next_flicker = rand_range(0.1, 1)
			else:
				light_energy_dest = max_light_energy
				time_until_next_flicker = rand_range(0.1, 6)
		if abs(light_energy - light_energy_dest) < 0.05:
			light_energy = light_energy_dest
		else:
			light_energy = lerp(light_energy, light_energy_dest, 0.1)
