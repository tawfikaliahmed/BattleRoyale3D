extends Node3D

@onready var game_manager: Node = $GameManager
@onready var player: CharacterBody3D = $Player
@onready var safe_zone: Node3D = $SafeZone
@onready var ui: CanvasLayer = $UI
@onready var touch_controls: CanvasLayer = $TouchControls
@onready var bots_container: Node3D = $Bots

var bot_scene: PackedScene = preload("res://scenes/bot.tscn")
var pickup_scene: PackedScene = preload("res://scenes/pickup.tscn")

func _ready() -> void:
	# Connect touch controls to player
	touch_controls.move_input.connect(player.set_touch_move)
	touch_controls.look_input.connect(player.set_touch_look)
	touch_controls.shoot_pressed.connect(player.set_shoot)
	touch_controls.jump_pressed.connect(player.set_jump)
	touch_controls.reload_pressed.connect(player.set_reload)
	touch_controls.sprint_pressed.connect(player.set_sprint)

	# Setup UI
	ui.setup(player, game_manager)

	# Spawn bots
	_spawn_bots()

	# Spawn some pickups
	_spawn_pickups()

	# Start game
	game_manager.start_game()

	# Update zone info periodically
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(func():
		if safe_zone:
			ui.update_zone_info(safe_zone.get_radius())
	)
	add_child(timer)
	timer.start()

func _spawn_bots() -> void:
	var spawn_points = [
		Vector3(40, 1, 40), Vector3(-40, 1, 40), Vector3(40, 1, -40), Vector3(-40, 1, -40),
		Vector3(60, 1, 0), Vector3(-60, 1, 0), Vector3(0, 1, 60), Vector3(0, 1, -60)
	]
	for i in range(mini(game_manager.MAX_BOTS, spawn_points.size())):
		var bot = bot_scene.instantiate()
		bots_container.add_child(bot)
		bot.global_position = spawn_points[i] + Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
		bot.look_at(Vector3.ZERO)

func _spawn_pickups() -> void:
	var positions = [
		Vector3(20, 0.5, 15), Vector3(-25, 0.5, 30), Vector3(35, 0.5, -20),
		Vector3(-15, 0.5, -35), Vector3(50, 0.5, 25), Vector3(-40, 0.5, -10),
		Vector3(10, 0.5, 50), Vector3(-30, 0.5, 45)
	]
	for pos in positions:
		var p = pickup_scene.instantiate()
		add_child(p)
		p.global_position = pos
