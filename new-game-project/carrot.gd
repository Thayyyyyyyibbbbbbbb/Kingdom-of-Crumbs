extends Area2D

@export var damage_amount: int = 40
@export var max_health: int = 3

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $HealthBar

var current_health: int
var is_dead: bool = false


func _ready() -> void:
	current_health = max_health

	# Make sure hurt only plays once
	if animated_sprite.sprite_frames.has_animation("hurt"):
		animated_sprite.sprite_frames.set_animation_loop("hurt", false)

	# Make sure death only plays once
	if animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.sprite_frames.set_animation_loop("death", false)

	# Health bar
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health

	# Player touching enemy
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	# Detect when animations finish
	if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.connect(_on_animation_finished)


# ==================================================
# PLAYER TOUCHES ENEMY
# ==================================================

func _on_body_entered(body: Node) -> void:
	if is_dead:
		return

	if body.has_method("take_damage"):
		body.take_damage(damage_amount, global_position)


# ==================================================
# ENEMY TAKES DAMAGE
# ==================================================

func take_damage(amount: int = 1) -> void:
	if is_dead:
		return

	current_health -= amount
	current_health = max(0, current_health)

	print("Gummy worm health: ", current_health, "/", max_health)

	# Update health bar
	if health_bar:
		health_bar.value = current_health

	# Enemy dies
	if current_health <= 0:
		die()
		return

	# Play hurt animation
	if animated_sprite.sprite_frames.has_animation("hurt"):
		animated_sprite.stop()
		animated_sprite.play("hurt")


# ==================================================
# TAKE HIT
# ==================================================

func take_hit(amount: int = 1) -> void:
	take_damage(amount)


# ==================================================
# DEATH
# ==================================================

func die() -> void:
	if is_dead:
		return

	is_dead = true

	print("Gummy worm died")

	# Stop enemy from attacking/moving
	set_process(false)
	set_physics_process(false)

	# Hide health bar
	if health_bar:
		health_bar.visible = false

	# Play death animation
	if animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.stop()
		animated_sprite.play("death")
	else:
		# If there is no death animation, remove immediately
		queue_free()


# ==================================================
# ANIMATION FINISHED
# ==================================================

func _on_animation_finished() -> void:

	# If enemy is dead, remove it after death animation
	if is_dead:
		if animated_sprite.animation == "death":
			queue_free()
		return

	# Hurt animation finished
	if animated_sprite.animation == "hurt":
		animated_sprite.play("default")
