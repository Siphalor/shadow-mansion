extends LivingEntity
class_name Player

const WALK_SPEED = 4
const JUMP_STRENGTH = 7
const ATTACK_COOLDOWN = 0.8
const WAND_KNOCK_BACK = 3
const WAND_ATTACK_SWIPE_ANGLE = 0.6
const WAND_ATTACK_SWIPE_TIME = 0.2
const DAMAGE_KNOCK_BACK = 5
const MIN_WAND_ANGLE = -PI / 2 + 0.2
const MAX_WAND_ANGLE = PI / 2 + 0.3
const OUTER_WAND_HALF = ((MIN_WAND_ANGLE + 2 * PI) + MAX_WAND_ANGLE) / 2
const MAX_CAMERA_X_ANGLE = 0.4
const MAX_CAMERA_Y_ANGLE = 0.3

var _wand_angle_offset: float = 0
var _time_since_last_attack: float = ATTACK_COOLDOWN
var _shadow_energy_ready: bool = false
var _z_fixed: float

func _ready():
	_z_fixed = translation.z
	Global.set_player(self)
	set_health(4)
	$listener.make_current()

func _apply_velocities(delta):
	._apply_velocities(delta)
	velocity.x = 0
	if Input.is_action_pressed("game_right"):
		velocity.x += WALK_SPEED
	if Input.is_action_pressed("game_left"):
		velocity.x -= WALK_SPEED
	if Input.is_action_just_pressed("game_jump"):
		if is_on_floor():
			velocity.y = JUMP_STRENGTH
	
	if is_idle_or_walk():
		if velocity.x == 0:
			$animator.play('idle')
		else:
			$animator.play("walk")
			set_mirrored(velocity.x < 0)

func _process(delta):
	$wand/wandSprite.rotation.z = _wand_angle_offset

func _physics_process(delta):
	_time_since_last_attack += delta
	if _time_since_last_attack < WAND_ATTACK_SWIPE_TIME:
		_wand_angle_offset = -_time_since_last_attack / WAND_ATTACK_SWIPE_TIME * 2 * WAND_ATTACK_SWIPE_ANGLE + WAND_ATTACK_SWIPE_ANGLE
	else:
		_wand_angle_offset = 0
	if _time_since_last_attack < ATTACK_COOLDOWN:
		var o: float = 1 - _time_since_last_attack / ATTACK_COOLDOWN
		$wand/swipeSprite.opacity = o * o
	else:
		$wand/swipeSprite.opacity = 0
	._physics_process(delta)
	translation.z = _z_fixed

func _on_moved():
	point_wand_to(Global.mouse_position)
	
	if velocity.x > 0:
		$lantern.rotate_z(1)
	
	var cam := get_viewport().get_camera()
	if cam is TargetedCamera:
		if abs(cam.translation.x - translation.x) / Global.camera_z_distance > MAX_CAMERA_X_ANGLE or abs(cam.translation.y - translation.y) / Global.camera_z_distance > MAX_CAMERA_Y_ANGLE:
			cam.target_pos = Vector3(translation.x, translation.y + 1 / Global.camera_z_distance, cam.translation.z)
			
	if translation.y < -1000:
		on_death()

func set_mirrored(m: bool):
	.set_mirrored(m)
	if m:
		$listener.scale.x = -abs($listener.scale.x)
	else:
		$listener.scale.x = abs($listener.scale.x)

func is_walking():
	return $animator.current_animation == 'walk'

func is_idle_or_walk():
	var a: String = $animator.current_animation
	return a == 'idle' or a == 'walk'

func is_collecting_shadows():
	return $animator.current_animation == 'collect_shadows'

func set_health(new_health: int):
	health = new_health
	Global.update_player_health()
	if health > 1:
		$lantern.visible = true
		$lantern/lanternLight.turn_on(0)

func take_damage(damage: float, type: String = ''):
	if is_collecting_shadows():
		return
	
	.take_damage(damage, type)
	
	print('Took ' + str(damage) + ' damage of type ' + type)
	$lantern/lanternLight.light_energy_dest = 16
	if health <= 1:
		$lantern/lanternLight.turn_off(2)
	else:
		$lantern/lanternLight.time_until_next_flicker = 2
	$lantern/breakSound.play()
	$lantern/breakParticles.restart()
	$lantern/breakParticles.emitting = true
	var bodies = $interactionArea.get_overlapping_bodies()
	for body in bodies:
		if body is Enemy:
			body.take_damage(1, 'player_lantern')
			body.knock_back(translation, DAMAGE_KNOCK_BACK)

func point_wand_to(point: Vector2):
	if _wand_angle_offset != 0 or is_collecting_shadows():
		return
	
	var cam: Camera = get_viewport().get_camera()
	if not cam is Camera:
		return
	var cursorPos: Vector3 = cam.project_position(point, abs(cam.translation.z - translation.z))
	var playerX: float = translation.x
	var playerY: float = translation.y
	if mirrored:
		cursorPos.x = 2 * playerX - cursorPos.x
		playerX = -playerX
		playerY = -playerY
	
	var deltaX: float = cursorPos.x - translation.x
	var angle: float
	if deltaX == 0:
		angle = PI / 2
	else:
		angle = atan((cursorPos.y - translation.y) / deltaX)
		if deltaX < 0:
			angle += PI
	
	if angle < MIN_WAND_ANGLE:
		angle = MIN_WAND_ANGLE
	elif angle > MAX_WAND_ANGLE:
		if is_walking():
			angle = fmod(angle, 2*PI)
			if angle < OUTER_WAND_HALF:
				angle = MAX_WAND_ANGLE
			else:
				angle = MIN_WAND_ANGLE
		else:
			set_mirrored(!mirrored)
			point_wand_to(point)
	
	$wand.rotation.z = angle

func wand_attack():
	if _time_since_last_attack < ATTACK_COOLDOWN:
		return
	var bodies = $wand/attackArea.get_overlapping_bodies() + $wand/attackArea.get_overlapping_areas()
	var hit: bool = false
	for body in bodies:
		if body is Enemy:
			body.take_damage(1, 'player_melee')
			body.knock_back(translation, WAND_KNOCK_BACK)
			hit = true
		elif body is EnemyPart:
			var enemy: Enemy = body.get_enemy()
			if enemy != null:
				enemy.take_damage(1, 'player_melee')
				enemy.knock_back(translation, WAND_KNOCK_BACK)
				hit = true
		elif body is RigidBody:
			if body.is_in_group('remains'):
				body.linear_velocity = translation.direction_to(body.translation).normalized() * WAND_KNOCK_BACK
				hit = true
	
	if hit:
		$wand/hitSound.play()
	else:
		$wand/missSound.play()
	
	_time_since_last_attack = 0

func player_interaction():
	var bodies = $interactionArea.get_overlapping_areas()
	for body in bodies:
		if body is Pickup:
			body.apply()

func _unhandled_input(event):
	if event is InputEvent:
		if event.is_action_pressed("game_attack"):
			wand_attack()
		if event.is_action_pressed("game_interact"):
			player_interaction()
		if event is InputEventMouseMotion:
			point_wand_to(event.position)
		if event.is_action_pressed("game_collect_shadows"):
			trigger_shadow_collection()

func _on_collisionArea_body_entered(body):
	if body is Enemy:
		if body.collision_damage > 0:
			take_damage(body.collision_damage, 'enemy_collision')
	elif body is EnemyPart:
		if body.collision_damage > 0:
			take_damage(body.collision_damage, 'enemy_collision')
		pass
	if body is Trap:
		body.trigger(self)

func _on_interactionArea_area_entered(area):
	if area is Pickup:
		area.set_highlight(true)

func _on_interactionArea_area_exited(area):
	if area is Pickup:
		area.set_highlight(false)

func _on_animation_finished(anim_name):
	if anim_name == "collect_shadows":
		$wand/shadowEnergy.visible = false
		$wand/shadowEnergy/Particles.emitting = false
		$collectionSound.play()
		$animator.play("idle")
		Global.boss.take_damage(100, "player_shadow_collect")
		Global.hide_shadow_bar()
	
func on_damage_taken(damage: float):
	Global.update_player_health()

func on_death(type: String = ''):
	Global.change_scene('scenes/game_over.tscn')

func set_shadow_energy_ready(ready: bool):
	_shadow_energy_ready = ready
	if ready:
		$wand/shadowEnergy.visible = true
	else:
		$wand/shadowEnergy.visible = false

func trigger_shadow_collection():
	if not _shadow_energy_ready:
		return
	_shadow_energy_ready = false
	$animator.play("collect_shadows")
	$wand/shadowEnergy/Particles.restart()
	$wand/shadowEnergy/Particles.emitting = true
	Global.boss.collect_shadows()
	

