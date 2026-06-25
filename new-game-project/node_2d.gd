extends CharacterBody2D

const SPEED = 220.0
const JUMP_VELOCITY = -400.0

const KNOCKBACK_X = 300.0
const KNOCKBACK_Y = -200.0

@onready var animator: AnimatedSprite2D = $AnimatedSprite2D
@onready var invincible_timer: Timer = $InvincibleTimer

var score = 0

var health = 100

var is_attacking = false
var is_hurt = false
var is_invincible = false

func _ready():
	animator.sprite_frames.set_animation_loop("attack", false)
	animator.sprite_frames.set_animation_loop("hurt", false)
	animator.animation_finished.connect(_on_animation_finished)

func take_damage(amount, enemy_position = Vector2.ZERO):
	if is_invincible or health <= 0:
		return

	health -= amount
	print("Health:", health)

	if health <= 0:
		die()
		return

	is_hurt = true
	is_attacking = false
	is_invincible = true

	var direction = sign(global_position.x - enemy_position.x)

	if direction == 0:
		direction = -1

	velocity.x = direction * KNOCKBACK_X
	velocity.y = KNOCKBACK_Y

	animator.play("hurt")

	invincible_timer.start()

func die():
	print("Player Died")
	get_tree().reload_current_scene()

func _physics_process(delta):

	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_hurt:
		move_and_slide()
		return

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction > 0:
		animator.flip_h = false
	elif direction < 0:
		animator.flip_h = true

	if Input.is_action_just_pressed("attack") and !is_attacking:
		is_attacking = true
		animator.play("attack")

	if !is_attacking:
		if !is_on_floor():
			if animator.animation != "jump":
				animator.play("jump")
		elif direction != 0:
			if animator.animation != "run":
				animator.play("run")
		else:
			if animator.animation != "idle":
				animator.play("idle")

	move_and_slide()

func _on_animation_finished():

	if animator.animation == "attack":
		is_attacking = false

	elif animator.animation == "hurt":
		is_hurt = false

func _on_invincible_timer_timeout():
	is_invincible = false


func _on_timer_timeout() -> void:
	pass # Replace with function body.
