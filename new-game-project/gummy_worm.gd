extends Area2D

@export var damage_amount := 40

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


var is_dead := false

func _ready() -> void:
	

	animated_sprite.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body: Node) -> void:
	if is_dead:
		return

	if body.has_method("take_damage"):
		body.take_damage(damage_amount, global_position)

func _on_body_exited(body: Node) -> void:
	pass

func _on_hurtbox_hurted() -> void:
	if !is_dead:
		animated_sprite.play("hurt")

func _on_hurtbox_died() -> void:
	is_dead = true
	animated_sprite.play("death") # Change to "die" if that's your animation name.

func _on_animation_finished() -> void:
	if animated_sprite.animation == "death":
		queue_free()
		
