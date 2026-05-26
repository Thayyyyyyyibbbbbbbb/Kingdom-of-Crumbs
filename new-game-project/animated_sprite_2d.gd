extends AnimatedSprite2D

func _process(delta):
	# Check if the right arrow key is pressed
	if Input.is_action_pressed("ui_right"):
		play("run")
		flip_h = false # Faces the sprite to the right
		
	# Check if the left arrow key is pressed
	elif Input.is_action_pressed("ui_left"):
		play("run")
		flip_h = true  # Flips the sprite to face left
		
	# If no keys are pressed, play the idle animation
	else:
		play("idle")
