extends Area3D

enum PickupType { AMMO, HEALTH, WEAPON }

@export var pickup_type: PickupType = PickupType.AMMO
@export var amount: float = 30.0

@onready var mesh: MeshInstance3D = $Mesh

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Simple rotation animation
	var tween = create_tween().set_loops()
	tween.tween_property(mesh, "rotation:y", mesh.rotation.y + TAU, 2.0)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and body.has_method("heal"):
		match pickup_type:
			PickupType.AMMO:
				if body.has_method("add_ammo"):
					body.add_ammo(int(amount))
			PickupType.HEALTH:
				body.heal(amount)
			PickupType.WEAPON:
				if body.has_method("add_ammo"):
					body.add_ammo(60)
					body.damage = 28.0  # upgrade damage a bit
		queue_free()
