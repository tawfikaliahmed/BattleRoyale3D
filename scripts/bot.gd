extends CharacterBody3D

signal died(bot_name: String)

@export var move_speed: float = 5.5
@export var max_health: float = 80.0
@export var detection_range: float = 45.0
@export var attack_range: float = 28.0
@export var fire_rate: float = 0.35
@export var damage: float = 15.0

var health: float = 80.0
var is_dead: bool = false
var bot_name: String = "Bot"

var target: Node3D = null
var can_shoot: bool = true
var wander_timer: float = 0.0
var wander_direction: Vector3 = Vector3.ZERO
var state: String = "wander"  # wander, chase, attack

@onready var muzzle: Marker3D = $Muzzle
@onready var body_mesh: MeshInstance3D = $Body
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
var gravity: float = 20.0

func _ready() -> void:
	health = max_health
	add_to_group("bots")
	bot_name = "Bot_" + str(randi() % 900 + 100)
	collision_layer = 4  # enemy
	collision_mask = 1 | 2 | 5  # world, player, pickup
	wander_timer = randf_range(1.0, 3.0)
	_pick_wander_direction()

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta

	_update_ai(delta)
	move_and_slide()

func _update_ai(delta: float) -> void:
	# Find player
	if target == null or not is_instance_valid(target) or target.get("is_dead"):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0 and not players[0].get("is_dead"):
			target = players[0]
		else:
			target = null

	var dist_to_target = 9999.0
	if target:
		dist_to_target = global_position.distance_to(target.global_position)

	match state:
		"wander":
			wander_timer -= delta
			if wander_timer <= 0.0:
				_pick_wander_direction()
				wander_timer = randf_range(2.0, 5.0)
			velocity.x = wander_direction.x * move_speed * 0.6
			velocity.z = wander_direction.z * move_speed * 0.6
			if target and dist_to_target < detection_range:
				state = "chase"

		"chase":
			if not target or dist_to_target > detection_range * 1.3:
				state = "wander"
				return
			if dist_to_target < attack_range:
				state = "attack"
				return
			var dir = (target.global_position - global_position).normalized()
			dir.y = 0
			velocity.x = dir.x * move_speed
			velocity.z = dir.z * move_speed
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)

		"attack":
			if not target or dist_to_target > attack_range * 1.2:
				state = "chase"
				return
			velocity.x = 0
			velocity.z = 0
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
			if can_shoot:
				_shoot_at_target()

func _pick_wander_direction() -> void:
	var angle = randf() * TAU
	wander_direction = Vector3(cos(angle), 0, sin(angle)).normalized()

func _shoot_at_target() -> void:
	if not target or not can_shoot:
		return
	can_shoot = false
	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	# Aim slightly towards target
	var aim_dir = (target.global_position + Vector3(0, 1.2, 0) - muzzle.global_position).normalized()
	bullet.look_at(muzzle.global_position + aim_dir)
	bullet.setup(damage, false)  # false = from bot

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func take_damage(amount: float, from_player: bool = false) -> void:
	if is_dead:
		return
	health -= amount
	if health <= 0.0:
		die(from_player)

func die(from_player: bool = false) -> void:
	if is_dead:
		return
	is_dead = true
	died.emit(bot_name)
	collision_layer = 0
	collision_mask = 0
	visible = false
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm:
		gm.on_bot_death(bot_name)
	# Remove after short delay
	await get_tree().create_timer(2.0).timeout
	queue_free()
