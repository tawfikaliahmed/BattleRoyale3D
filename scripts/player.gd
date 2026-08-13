extends CharacterBody3D

signal health_updated(current: float, maximum: float)
signal ammo_updated(current: int, maximum: int)
signal died

@export var move_speed: float = 7.0
@export var sprint_speed: float = 11.0
@export var jump_velocity: float = 6.5
@export var mouse_sensitivity: float = 0.003
@export var max_health: float = 100.0
@export var gravity: float = 20.0

var health: float = 100.0
var is_dead: bool = false
var is_sprinting: bool = false

# Weapon
var current_ammo: int = 30
var max_ammo: int = 30
var reserve_ammo: int = 90
var fire_rate: float = 0.12
var can_shoot: bool = true
var is_reloading: bool = false
var reload_time: float = 1.8
var damage: float = 22.0

# Touch input
var touch_move_vector: Vector2 = Vector2.ZERO
var touch_look_vector: Vector2 = Vector2.ZERO
var shoot_pressed: bool = false
var jump_pressed: bool = false
var reload_pressed: bool = false

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var muzzle: Marker3D = $Muzzle
@onready var body_mesh: MeshInstance3D = $Body
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")

func _ready() -> void:
	health = max_health
	add_to_group("player")
	health_updated.emit(health, max_health)
	ammo_updated.emit(current_ammo, max_ammo)
	# Make sure collision layers are set
	collision_layer = 2  # player
	collision_mask = 1 | 3 | 5  # world, enemy, pickup

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if jump_pressed and is_on_floor():
		velocity.y = jump_velocity
		jump_pressed = false

	# Movement from touch joystick
	var input_dir = touch_move_vector
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var speed = sprint_speed if is_sprinting else move_speed
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	# Look / rotate from right touch pad
	if touch_look_vector.length() > 0.1:
		rotate_y(-touch_look_vector.x * mouse_sensitivity * 60.0 * delta)
		camera_pivot.rotate_x(-touch_look_vector.y * mouse_sensitivity * 60.0 * delta)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-60), deg_to_rad(40))

	# Shooting
	if shoot_pressed and can_shoot and not is_reloading and current_ammo > 0:
		shoot()

	# Reload
	if reload_pressed and not is_reloading and current_ammo < max_ammo and reserve_ammo > 0:
		start_reload()
		reload_pressed = false

func shoot() -> void:
	can_shoot = false
	current_ammo -= 1
	ammo_updated.emit(current_ammo, max_ammo)

	var bullet = bullet_scene.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	bullet.setup(damage, true)  # true = from player

	# Simple recoil
	camera_pivot.rotate_x(deg_to_rad(-1.5))

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

	if current_ammo <= 0 and reserve_ammo > 0:
		start_reload()

func start_reload() -> void:
	if is_reloading:
		return
	is_reloading = true
	await get_tree().create_timer(reload_time).timeout
	var needed = max_ammo - current_ammo
	var taken = mini(needed, reserve_ammo)
	current_ammo += taken
	reserve_ammo -= taken
	is_reloading = false
	ammo_updated.emit(current_ammo, max_ammo)

func take_damage(amount: float, _from_player: bool = false) -> void:
	if is_dead:
		return
	health -= amount
	health = max(health, 0.0)
	health_updated.emit(health, max_health)
	if health <= 0.0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	died.emit()
	# Disable collision and hide
	collision_layer = 0
	collision_mask = 0
	visible = false
	# Notify game manager
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm:
		gm.on_player_death()

func heal(amount: float) -> void:
	health = min(health + amount, max_health)
	health_updated.emit(health, max_health)

func add_ammo(amount: int) -> void:
	reserve_ammo += amount
	ammo_updated.emit(current_ammo, max_ammo)

func set_touch_move(vec: Vector2) -> void:
	touch_move_vector = vec

func set_touch_look(vec: Vector2) -> void:
	touch_look_vector = vec

func set_shoot(pressed: bool) -> void:
	shoot_pressed = pressed

func set_jump(pressed: bool) -> void:
	if pressed:
		jump_pressed = true

func set_reload(pressed: bool) -> void:
	if pressed:
		reload_pressed = true

func set_sprint(pressed: bool) -> void:
	is_sprinting = pressed
