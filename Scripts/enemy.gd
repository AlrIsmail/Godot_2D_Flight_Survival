extends CharacterBody2D

@export var speed: float = 20.0  # Movement speed
@export var health: int = 2  # Number of hits before the enemy is destroyed
var target: Node2D = null  # The player object to follow
var explosion: PackedScene = preload("res://Scenes/explosion.tscn")
@export var FixPickupScene: PackedScene = preload("res://Scenes/FixPickup.tscn")

func _ready():
	# Find the player if it's in the scene
	target = get_tree().get_nodes_in_group("player").front() if get_tree().has_group("player") else null

func _physics_process(delta):
	if target:
		var direction = (target.global_position - global_position).normalized()
		rotation = direction.angle() + PI / 2  # Rotate the enemy to face the player
		velocity = direction * speed  # Move toward the player
		move_and_slide()

func take_damage():
	health -= 1

	if health <= 0:
		speed = 0  # Stop the enemy from moving
		# Stop 2D Sprite animation
		get_node("AnimatedSprite2D").stop()
		# Play an sprite explosion effect
		var explosion_instance = explosion.instantiate()
		explosion_instance.global_position = global_position
		get_parent().add_child(explosion_instance)

		if randf() < 0.1:
			var fix_pickup = FixPickupScene.instantiate()
			fix_pickup.global_position = global_position
			get_parent().add_child(fix_pickup)

		queue_free()  # Destroy enemy

	# Wiggle the enemy a bit
	var original_speed = speed
	speed = 0
	for i in range(5):
		global_position.x += 2
		await get_tree().create_timer(0.05).timeout
		global_position.x -= 4
		await get_tree().create_timer(0.05).timeout
		global_position.x += 2
		await get_tree().create_timer(0.05).timeout
	speed = original_speed



func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body)
	if body.is_in_group("player"):
		var player = body as CharacterBody2D
		if player:
			print("Player entered")
			player.take_damage(2)
		take_damage()
