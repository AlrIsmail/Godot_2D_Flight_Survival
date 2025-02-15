extends Node2D

@export var EnemyScene: PackedScene = preload("res://Scenes/enemy.tscn")
@export var UIScene: PackedScene = preload("res://Scenes/UI.tscn")
@export var MenuScene: PackedScene = preload("res://Scenes/Menu.tscn")
@export var spawn_distance_threshold: float = 1000.0  # Minimum distance from player to spawn enemies
@export var percentage_spawn_distance_threshold: float = 0.6  # Percentage of spawn distance threshold
@export var percentage_flee_distance_threshold: float = 1.3  # Percentage of spawn distance threshold for enemies to flee
@export var initial_enemy_count: int = 10  # Number of enemies to spawn initially
@export var max_enemy_count: int = 20  # Maximum number of enemies at a time
@export var spawn_interval: float = 2.0  # Initial spawn interval in seconds
@export var difficulty_increase_interval: float = 10.0  # Time in seconds to increase difficulty
@export var max_spawn_interval: float = 0.5  # Minimum spawn interval in seconds

var player: Node2D = null
var enemy_count: int = 0  # Variable to keep track of the number of enemies
var spawn_timer: Timer = null
var difficulty_timer: Timer = null
var ui: CanvasLayer = null
var menu_ui: CanvasLayer = null
var quit_button: Button = null
var continue_button: Button = null
var title_label: Label = null
var timer_label = null
var elapsed_time: float = 0.0  # Add this variable to store the elapsed time
var score_label: Label = null
var score: int = 0
var paused: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	# Find the player if it's in the scene
	player = get_tree().get_nodes_in_group("player").front() if get_tree().has_group("player") else null
	
	if player:
		player.connect("health_changed", Callable(self, "update_health"))
		player.connect("player_died", Callable(self, "game_over"))
	# Create initial enemies
	for i in range(initial_enemy_count):
		spawn_enemy()
	
	# Create an enemy at regular intervals
	spawn_enemies()
	
	# Increase difficulty at regular intervals
	increase_difficulty()
	
	# Load and add the UI scene
	ui = UIScene.instantiate()
	get_viewport().add_child(ui)  # Add the UI to the viewport to keep it in the corner of the screen
	ui.get_node("Control/Panel/VBox/HealthLabel").text = "Health: " + str(player.current_health)
	timer_label = ui.get_node("Control/Panel/VBox/TimerLabel")
	timer_label.text = "Time: 0:00"
	score_label = ui.get_node("Control/Panel/VBox/ScoreLabel")
	score_label.text = "Score: 0"

	menu_ui = MenuScene.instantiate()
	var ui_pre_path = "Control/MenuPanel/VBox/"
	menu_ui.get_node(ui_pre_path + "RestartButton").connect("pressed", Callable(self, "restart_game"))
	menu_ui.get_node(ui_pre_path + "QuitButton").connect("pressed", Callable(self, "quit_game"))
	continue_button = menu_ui.get_node(ui_pre_path + "ContinueButton")
	title_label = menu_ui.get_node(ui_pre_path + "TitleLabel")
	continue_button.connect("pressed", Callable(self, "continue_game"))
	title_label.text = "Paused"
	get_viewport().add_child(menu_ui)

func restart_game() -> void:
	# remove everything from the scene
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	for bullet in get_tree().get_nodes_in_group("bullets"):
		bullet.queue_free()
	for fix_pickup in get_tree().get_nodes_in_group("fix_pickup"):
		fix_pickup.queue_free()
	get_node("TileMapLayer").queue_free()
	ui.queue_free()
	menu_ui.queue_free()

	# reload the scene
	get_tree().reload_current_scene()

func quit_game() -> void:
	get_tree().quit()

func pause_game() -> void:
	paused = true
	spawn_timer.stop()
	# Pause the game
	player.set_physics_process(false)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	menu_ui.visible = true

func continue_game() -> void:
	paused = false
	spawn_timer.start()
	# Continue the game
	player.set_physics_process(true)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.set_physics_process(true)
	menu_ui.visible = false

func update_health(health: int) -> void:
	ui.get_node("Control/Panel/VBox/HealthLabel").text = "Health: " + str(health)

func game_over() -> void:
	# Show game over screen
	paused = true
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	for bullet in get_tree().get_nodes_in_group("bullets"):
		bullet.set_physics_process(false)
	for fix_pickup in get_tree().get_nodes_in_group("fix_pickup"):
		fix_pickup.set_physics_process(false)
	get_node("TileMapLayer").set_physics_process(false)
	title_label.text = "Game Over"
	menu_ui.visible = true
	continue_button.disabled = true

func spawn_enemies() -> void:
	# Use a timer to spawn enemies at regular intervals
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_enemy_timeout"))
	add_child(spawn_timer)
	spawn_timer.start()

func increase_difficulty() -> void:
	# Use a timer to increase difficulty at regular intervals
	difficulty_timer = Timer.new()
	difficulty_timer.wait_time = difficulty_increase_interval
	difficulty_timer.one_shot = false
	difficulty_timer.connect("timeout", Callable(self, "_on_increase_difficulty_timeout"))
	add_child(difficulty_timer)
	difficulty_timer.start()

func _on_spawn_enemy_timeout() -> void:
	if enemy_count < max_enemy_count:
		spawn_enemy()

func _on_increase_difficulty_timeout() -> void:
	# Decrease spawn interval
	if spawn_interval > max_spawn_interval:
		spawn_interval = max(spawn_interval - 0.2, max_spawn_interval)
		spawn_timer.wait_time = spawn_interval
	max_enemy_count += 1
	
	# Restart the difficulty timer
	difficulty_timer.start()

func spawn_enemy() -> void:
	if not player:
		return
	
	var enemy = EnemyScene.instantiate()
	var spawn_position: Vector2
	
	var angle = randf() * TAU
	var distance = randf_range(spawn_distance_threshold * percentage_spawn_distance_threshold, spawn_distance_threshold)
	spawn_position = player.global_position + Vector2(cos(angle), sin(angle)) * distance
	enemy.global_position = spawn_position
	add_child(enemy)
	enemy.add_to_group("enemies")
	enemy_count += 1
	enemy.connect("tree_exited", Callable(self, "_on_enemy_destroyed"))

func _on_enemy_destroyed() -> void:
	enemy_count -= 1
	score += 2
	score_label.text = "Score: " + str(score)


func _physics_process(delta: float) -> void:
	if not player:
		return

	update_timer(delta)
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.global_position.distance_to(player.global_position) > spawn_distance_threshold * percentage_flee_distance_threshold:
			# Respawn the enemy closer to the player
			var spawn_position: Vector2
			var angle = randf() * TAU
			var distance = randf_range(spawn_distance_threshold * percentage_spawn_distance_threshold, spawn_distance_threshold)
			spawn_position = player.global_position + Vector2(cos(angle), sin(angle)) * distance
			enemy.global_position = spawn_position
				
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if paused:
			continue_game()
		else:
			pause_game()

func update_timer(delta: float) -> void:
	if not paused:
		# Update the elapsed time
		elapsed_time += delta
		# Format the elapsed time as minutes and seconds
		var minutes = int(elapsed_time) / 60
		var seconds = int(elapsed_time) % 60
		timer_label.text = "Time: %d:%02d" % [minutes, seconds]
