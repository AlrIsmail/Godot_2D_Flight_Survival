extends Area2D

var heal_amount: int = 20

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.heal(heal_amount)
		queue_free()
		pass
