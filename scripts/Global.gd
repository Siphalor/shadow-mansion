extends Node

var mouse_position = Vector2(0,0)
var camera_z_distance: float = 0
var player_camera: Camera = null
var current_scene: Node = null
var player: Player = null
var boss: BossEnemy = null
var hud: HUD = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position

func change_scene(scene_path: String):
	call_deferred('_change_scene', scene_path)

func _change_scene(scene_path: String):
	current_scene.free()
	var scene: PackedScene = ResourceLoader.load(scene_path)
	current_scene = scene.instance()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	
func set_player(p: Player):
	player = p
	camera_z_distance = abs(get_viewport().get_camera().translation.z - player.translation.z)
	player_camera = get_viewport().get_camera()

func set_hud(h: HUD):
	hud = h

func update_player_health():
	hud.set_lanterns(player.health - 1)

func hide_shadow_bar():
	hud.set_shadow_bar_visible(false)

func update_shadow_bar():
	if not hud.get_shadow_bar_visible():
		hud.set_shadow_bar_visible(true)
	var value: int = boss.max_health - boss.health
	hud.set_shadow_bar(value, boss.max_health)
	if boss.health == 0:
		player.set_shadow_energy_ready(true)
