extends Area2D

@export var damage_amount := 25

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage_amount, global_position)
