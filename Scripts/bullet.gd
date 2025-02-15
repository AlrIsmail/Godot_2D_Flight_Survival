extends Area2D

# Bullet speed
@export var speed: float = 500.0

# Direction of movement (normalized Vector2)
var direction: Vector2 = Vector2.ZERO

var rotation_inertia: float = 0.0
var inertia_adjustment: float = 0.3
func _ready():
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _process(delta: float):
	# Move the bullet in the set direction
	rotation += rotation_inertia * delta
	direction = Vector2.UP.rotated(rotation)
	if rotation_inertia != 0:
		if rotation_inertia > inertia_adjustment:
			rotation_inertia -= inertia_adjustment
		elif rotation_inertia < inertia_adjustment:
			rotation_inertia += inertia_adjustment
		else:
			rotation_inertia = 0
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage()
		queue_free()
		pass
