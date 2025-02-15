extends AnimatedSprite2D


func _ready():
	# Play the explosion animation
	play("default")
	

func _on_animation_finished() -> void:
	# Destroy the explosion instance after the animation finishes
	queue_free()
