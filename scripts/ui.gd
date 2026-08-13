extends CanvasLayer

@onready var health_bar: ProgressBar = $HUD/HealthBar
@onready var ammo_label: Label = $HUD/AmmoLabel
@onready var alive_label: Label = $HUD/AliveLabel
@onready var zone_label: Label = $HUD/ZoneLabel
@onready var message_label: Label = $HUD/MessageLabel
@onready var game_over_panel: Panel = $GameOverPanel
@onready var winner_label: Label = $GameOverPanel/WinnerLabel
@onready var restart_button: Button = $GameOverPanel/RestartButton

var player_ref: Node = null

func _ready() -> void:
	game_over_panel.visible = false
	message_label.text = ""
	restart_button.pressed.connect(_on_restart)

func setup(player: Node, game_manager: Node) -> void:
	player_ref = player
	if player.has_signal("health_updated"):
		player.health_updated.connect(_on_health_updated)
	if player.has_signal("ammo_updated"):
		player.ammo_updated.connect(_on_ammo_updated)
	if game_manager.has_signal("players_alive_changed"):
		game_manager.players_alive_changed.connect(_on_alive_changed)
	if game_manager.has_signal("game_over"):
		game_manager.game_over.connect(_on_game_over)
	if game_manager.has_signal("bot_died"):
		game_manager.bot_died.connect(_on_bot_died)

func _on_health_updated(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	if current < 30:
		health_bar.modulate = Color(1, 0.3, 0.3)
	else:
		health_bar.modulate = Color(0.2, 0.9, 0.3)

func _on_ammo_updated(current: int, maximum: int) -> void:
	ammo_label.text = "Ammo: %d / %d" % [current, maximum]

func _on_alive_changed(count: int) -> void:
	alive_label.text = "Alive: %d" % count

func _on_bot_died(bot_name: String) -> void:
	message_label.text = bot_name + " eliminated"
	await get_tree().create_timer(2.0).timeout
	if message_label.text.begins_with(bot_name):
		message_label.text = ""

func _on_game_over(winner: String) -> void:
	game_over_panel.visible = true
	if winner == "You":
		winner_label.text = "VICTORY ROYALE!\nYou are the last one standing"
		winner_label.modulate = Color(1, 0.85, 0.2)
	else:
		winner_label.text = "DEFEATED\nWinner: " + winner
		winner_label.modulate = Color(1, 0.3, 0.3)

func update_zone_info(radius: float) -> void:
	zone_label.text = "Zone: %.0fm" % radius

func _on_restart() -> void:
	get_tree().reload_current_scene()
