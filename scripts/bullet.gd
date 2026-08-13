extends Area3D

var speed: float = 80.0
var damage: float = 20.0
var from_player: bool = false
var lifetime: float = 2.5
var direction: Vector3 = Vector3.FORWARD

func setup(dmg: float, is_player_bullet: bool) -> void:
	damage = dmg
	from_player = is_player_bullet
	direction = -global_transform.basis.z.normalized()
	# Set collision layers
	if from_player:
		collision_layer = 8  # projectile
		collision_mask = 1 | 4  # world + enemy
	else:
		collision_layer = 8
		collision_mask = 1 | 2  # world + player

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Auto destroy
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage, from_player)
	queue_free()
