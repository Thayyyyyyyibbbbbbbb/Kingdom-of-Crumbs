extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animator: AnimatedSprite2D = $AnimatedSprite2D

var is_attacking: bool = false

func _ready() -> void:
	# --- NEW: Forces the attack animation to stop looping! ---
	animator.sprite_frames.set_animation_loop("attack", false)
	animator.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
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
		
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		animator.play("attack")
		
	if not is_attacking:
		if not is_on_floor():
			animator.play("jump")
		else:
			if direction != 0:
				animator.play("run")
			else:
				animator.play("idle")
	
	move_and_slide()

func _on_animation_finished() -> void:
	if animator.animation == "attack":
		is_attacking = false
