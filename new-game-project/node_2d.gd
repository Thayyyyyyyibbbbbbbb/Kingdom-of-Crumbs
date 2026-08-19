extends CharacterBody2D

const SPEED = 220.0
const JUMP_VELOCITY = -400

const KNOCKBACK_X = 300.0
const KNOCKBACK_Y = -200.0
const KNOCKBACK_FRICTION = 600.0

@onready var animator: AnimatedSprite2D = $AnimatedSprite2D
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var hitbox_area: Area2D = $Hitbox
@onready var hitbox: CollisionShape2D = $Hitbox/CollisionShape2D2
@onready var health_bar = $HealthBar  # <-- Added reference to HealthBar

var score = 0
var max_health = 100                  # <-- Added max_health reference
var health = 100

var is_attacking = false
var is_hurt = false
var is_invincible = false
var is_dead = false

func _ready():
	# Initialize HealthBar limits and starting value
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

	# Attack hitbox starts disabled
	hitbox.disabled = true

	animator.sprite_frames.set_animation_loop("attack", false)
	animator.sprite_frames.set_animation_loop("hurt", false)
	animator.sprite_frames.set_animation_loop("death", false)

	animator.animation_finished.connect(_on_animation_finished)
	invincible_timer.timeout.connect(_on_invincible_timer_timeout)

func take_damage(amount, enemy_position = Vector2.ZERO):
	if is_invincible or is_dead or health <= 0:
		return

	health -= amount
	health = max(0, health) # Prevents health from dropping below 0
	
	# Update the health bar UI
	if health_bar:
		health_bar.value = health

	print("Player Health:", health)

	# Instantly cancel attacks so clicking can't overlap with hurt state
	is_attacking = false
	hitbox.set_deferred("disabled", true)

	if health <= 0:
		die(enemy_position)
		return

	is_hurt = true
	is_invincible = true

	var direction = sign(global_position.x - enemy_position.x)
	if direction == 0:
		direction = -1

	velocity.x = direction * KNOCKBACK_X
	velocity.y = KNOCKBACK_Y

	animator.stop()
	animator.play("hurt")

	invincible_timer.start()

func die(enemy_position = Vector2.ZERO):
	is_dead = true
	is_hurt = false
	is_attacking = false
	is_invincible = true

	var direction = sign(global_position.x - enemy_position.x)
	if direction == 0:
		direction = -1

	velocity.x = direction * KNOCKBACK_X
	velocity.y = KNOCKBACK_Y

	animator.stop()
	animator.play("death")

func _physics_process(delta):
	# Apply gravity whenever in air
	if not is_on_floor():
		velocity += get_gravity() * delta

	# State: Dead
	if is_dead:
		velocity.x = move_toward(velocity.x, 0, KNOCKBACK_FRICTION * delta)
		move_and_slide()
		return

	# State 1: Locked in Hurt State
	if is_hurt:
		velocity.x = move_toward(velocity.x, 0, KNOCKBACK_FRICTION * delta)
		move_and_slide()
		return

	# State 2: Normal Movement
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
		animator.flip_h = (direction < 0)
		
		# Flips the attack hitbox to match player facing direction
		if direction < 0:
			hitbox_area.scale.x = -1
		else:
			hitbox_area.scale.x = 1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# CAN ONLY ATTACK IF NOT HURT AND NOT ALREADY ATTACKING
	if Input.is_action_just_pressed("attack") and not is_attacking and not is_hurt:
		perform_attack()

	# Handle Default Animations
	if not is_attacking:
		if not is_on_floor():
			if animator.animation != "jump":
				animator.play("jump")
		elif direction != 0:
			if animator.animation != "run":
				animator.play("run")
		else:
			if animator.animation != "idle":
				animator.play("idle")

	move_and_slide()

func perform_attack():
	is_attacking = true
	animator.play("attack")
	hitbox.set_deferred("disabled", false)

func _on_animation_finished():
	if animator.animation == "attack":
		is_attacking = false
		hitbox.set_deferred("disabled", true)

	elif animator.animation == "hurt":
		is_hurt = false
		if Input.get_axis("ui_left", "ui_right") == 0:
			velocity.x = 0

	elif animator.animation == "death":
		get_tree().reload_current_scene()

func _on_invincible_timer_timeout():
	if not is_dead:
		is_invincible = false
