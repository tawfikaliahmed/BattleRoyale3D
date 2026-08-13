extends Node3D

signal zone_shrunk(new_radius: float)

@export var initial_radius: float = 120.0
@export var final_radius: float = 15.0
@export var shrink_duration: float = 420.0  # 7 minutes
@export var damage_per_second: float = 8.0
@export var damage_tick: float = 1.0

var current_radius: float = 120.0
var shrink_timer: float = 0.0
var damage_timer: float = 0.0
var is_active: bool = true

@onready var mesh_instance: MeshInstance3D = $ZoneMesh
@onready var collision_shape: CollisionShape3D = $Area3D/CollisionShape3D

func _ready() -> void:
	current_radius = initial_radius
	_update_visuals()
	$Area3D.body_exited.connect(_on_body_exited)
	$Area3D.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if not is_active:
		return

	shrink_timer += delta
	var t = clamp(shrink_timer / shrink_duration, 0.0, 1.0)
	current_radius = lerp(initial_radius, final_radius, t)
	_update_visuals()

	# Damage outside
	damage_timer += delta
	if damage_timer >= damage_tick:
		damage_timer = 0.0
		_apply_zone_damage()

func _update_visuals() -> void:
	if mesh_instance and mesh_instance.mesh is CylinderMesh:
		var cyl = mesh_instance.mesh as CylinderMesh
		cyl.top_radius = current_radius
		cyl.bottom_radius = current_radius
	if collision_shape and collision_shape.shape is CylinderShape3D:
		var shape = collision_shape.shape as CylinderShape3D
		shape.radius = current_radius

func _apply_zone_damage() -> void:
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if is_instance_valid(p) and not p.get("is_dead"):
			var dist = Vector2(p.global_position.x, p.global_position.z).length()
			if dist > current_radius:
				p.take_damage(damage_per_second * damage_tick, false)

	var bots = get_tree().get_nodes_in_group("bots")
	for b in bots:
		if is_instance_valid(b) and not b.get("is_dead"):
			var dist = Vector2(b.global_position.x, b.global_position.z).length()
			if dist > current_radius:
				b.take_damage(damage_per_second * damage_tick * 0.7, false)

func _on_body_exited(_body: Node3D) -> void:
	pass

func _on_body_entered(_body: Node3D) -> void:
	pass

func get_radius() -> float:
	return current_radius
