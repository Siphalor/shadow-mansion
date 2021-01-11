extends BossEnemy

export(Array, NodePath) var legs = []
var _time_until_next_attack = 10

func _ready():
	_time_until_next_attack = 2 * pow(0.8, max_health - health)
	var i := 0
	while i < legs.size():
		legs[i] = get_node(legs[i])
		i += 1

func _physics_process(delta):
	_time_until_next_attack -= delta
	
	if _time_until_next_attack <= 0:
		var leg_index := int(randf() * legs.size())
		var leg: SpideyLeg = legs[leg_index]
		if not leg.is_attacking():
			leg.attack()
		_time_until_next_attack = .5
