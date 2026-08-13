extends Node

signal player_died
signal bot_died(bot_name: String)
signal game_over(winner: String)
signal zone_damage(amount: float)
signal ammo_changed(current: int, max_ammo: int)
signal health_changed(current: float, max_health: float)
signal players_alive_changed(count: int)

var players_alive: int = 0
var game_started: bool = false
var game_ended: bool = false
var winner_name: String = ""

const MAX_BOTS: int = 8
const MATCH_TIME: float = 600.0  # 10 minutes max

var match_timer: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_game() -> void:
	game_started = true
	game_ended = false
	match_timer = 0.0
	players_alive = 1 + MAX_BOTS
	players_alive_changed.emit(players_alive)
	print("Game started. Players alive: ", players_alive)

func register_bot() -> void:
	# Called when bot is spawned
	pass

func on_player_death() -> void:
	if game_ended:
		return
	players_alive -= 1
	players_alive_changed.emit(players_alive)
	player_died.emit()
	check_end_game("Bots")

func on_bot_death(bot_name: String) -> void:
	if game_ended:
		return
	players_alive -= 1
	players_alive_changed.emit(players_alive)
	bot_died.emit(bot_name)
	check_end_game("Player")

func check_end_game(potential_winner: String) -> void:
	if players_alive <= 1:
		game_ended = true
		if potential_winner == "Player" and players_alive == 1:
			winner_name = "You"
		else:
			winner_name = potential_winner
		game_over.emit(winner_name)
		print("Game Over. Winner: ", winner_name)

func _process(delta: float) -> void:
	if not game_started or game_ended:
		return
	match_timer += delta
	if match_timer >= MATCH_TIME:
		game_ended = true
		winner_name = "Time Out"
		game_over.emit(winner_name)
