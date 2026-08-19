extends Area2D

@export var damage_amount := 40

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_shape: CollisionShape2D = $CollisionShape2D

var is_dead := false

func _ready() -> void:
	# Disable attack box on spawn so player isn't hurt by just standing near
	attack_shape.disabled = true
	
	# Connect signals
	animated_sprite.animation_finished.connect(_on_animation_finished)
	body_entered.connect(_on_body_entered)

# Call this function whenever you want the Ramen to whip its noodles!
func attack() -> void:
	if is_dead:
		return
	animated_sprite.play("attack")
	attack_shape.set_deferred("disabled", false) # Enable hitbox during attack

func _on_body_entered(body: Node) -> void:
	if is_dead:
		return

	# Deals damage to player if they are inside the noodle box
	if body.has_method("take_damage"):
		body.take_damage(damage_amount, global_position)

func _on_hurtbox_hurted() -> void:
	if not is_dead:
		animated_sprite.play("hurt")

func _on_hurtbox_died() -> void:
	is_dead = true
	attack_shape.set_deferred("disabled", true)
	animated_sprite.play("death")

func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		# Turn off attack box when noodle animation finishes
		attack_shape.set_deferred("disabled", true)
	elif animated_sprite.animation == "death":
		queue_free()
