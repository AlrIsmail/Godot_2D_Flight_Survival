# Movement where the character rotates and moves forward or backward.
extends CharacterBody2D

var BulletScene = preload("res://Scenes/bullet.tscn")

# Movement speed in pixels per second.
@export var speed := 50
# Rotation speed in radians per second.
@export var angular_speed := 5.0

# Dash properties
@export var dash_speed := 300
@export var dash_duration := 0.2
@export var dash_cooldown := 1.0

# Fire properties
@export var fire_rate := 0.5  # Time between shots in seconds
var fire_cooldown := 0.0

var is_dashing := false
var dash_time_left := 0.0
var dash_cooldown_left := 0.0
var rotate_direction := 0.0

# Player health properties
var max_health := 50
var current_health := max_health

signal health_changed(new_health)
signal player_died # Signal emitted when the player dies

func _physics_process(delta):
	# Handle dash cooldown
	if dash_cooldown_left > 0:
		dash_cooldown_left -= delta
	
	# Handle dashing
	if is_dashing:
		dash_time_left -= delta
		if dash_time_left <= 0:
			is_dashing = false
			dash_cooldown_left = dash_cooldown
	else:
		# Check for dash input
		if Input.is_action_just_pressed("dash") and dash_cooldown_left <= 0:
			is_dashing = true
			dash_time_left = dash_duration
	
	rotate_direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	rotation += rotate_direction * angular_speed * delta
	
	# Base speed in the upward direction
	var base_velocity := -transform.y * speed
	
	# Adjust speed based on input
	var speed_multiplier := Input.get_action_strength("down") - Input.get_action_strength("up")
	speed_multiplier = clamp(speed_multiplier, -0.8, 1.0)  # Ensure the multiplier doesn't reduce speed too much
	
	var new_velocity := base_velocity * (1.0 - speed_multiplier * 0.5)
	
	# Apply dash speed if dashing
	if is_dashing:
		new_velocity = -transform.y * dash_speed
	
	set_velocity(new_velocity)
	move_and_slide()

	# Handle fire cooldown
	if fire_cooldown > 0:
		fire_cooldown -= delta
	
	# Check for fire input
	if Input.is_action_pressed("fire") and fire_cooldown <= 0:
		fire()
		fire_cooldown = fire_rate

# Function to handle firing
func fire() -> void:
	if not is_instance_valid(BulletScene):
		print("Bullet scene is not valid.")
		return
	var bullet_instance = BulletScene.instantiate()
	bullet_instance.position = position
	bullet_instance.rotation = rotation
	bullet_instance.direction = -transform.y.normalized()
	bullet_instance.rotation_inertia = rotate_direction * angular_speed
	get_parent().add_child(bullet_instance)

# Function to decrease health
func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		current_health = 0
		die()
	emit_signal("health_changed", current_health)

# Function to increase health
func heal(amount: int) -> void:
	current_health += amount
	if current_health > max_health:
		current_health = max_health
	emit_signal("health_changed", current_health)

# Function to kill the player
func die() -> void:
	# instintiate another camera with the same settings
	var new_camera = self.get_node("Camera2D").duplicate()
	self.get_parent().add_child(new_camera)
	new_camera.position = self.get_node("Camera2D").position
	new_camera.zoom = self.get_node("Camera2D").zoom
	new_camera.rotation = self.get_node("Camera2D").rotation
	new_camera.set_enabled(true)
	# Emit signal to notify the game that the player has died
	emit_signal("player_died")
	# play death animation then a timer to restart the game
	queue_free()
