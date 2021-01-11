extends "res://scripts/ambient/flickering_light.gd"
class_name PlayerLantern

const _ACTION_NONE := 0
const _ACTION_TURN_OFF := 1
const _ACTION_TURN_ON := 2

var _action: int = _ACTION_NONE

func _ready():
	pass

func turn_off(time: float = 0):
	_action = _ACTION_TURN_OFF
	time_until_next_flicker = time

func turn_on(time: float = 0):
	_action = _ACTION_TURN_ON
	time_until_next_flicker = time

func _process(delta):
	if _action == _ACTION_NONE:
		._process(delta)
	elif _action == _ACTION_TURN_OFF:
		if time_until_next_flicker - delta < 0:
			get_parent().visible = false
			light_energy_dest = 0
			time_until_next_flicker = INF
			_action = _ACTION_NONE
		._process(delta)
	elif _action == _ACTION_TURN_ON:
		time_until_next_flicker -= delta
		if time_until_next_flicker < 0:
			get_parent().visible = true
			light_energy = 0.01
			light_energy_dest = max_light_energy
			time_until_next_flicker = 2
			_action = _ACTION_NONE
