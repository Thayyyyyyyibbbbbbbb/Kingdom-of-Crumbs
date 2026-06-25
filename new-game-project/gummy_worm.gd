extends Area2D

@export var damage_amount := 25

func _on_body_entered(body):
	print("Player entered")

	if body.has_method("take_damage"):
		print("Damaging player")
		body.take_damage(damage_amount, global_position)

func _on_body_exited(body):
	print("Player exited")
