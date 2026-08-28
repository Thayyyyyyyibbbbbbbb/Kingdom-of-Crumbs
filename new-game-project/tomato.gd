extends Area2D

@export var damage_amount: int = 40
@export var max_health: int = 3

# White damage flash
@export var flash_time: float = 0.18

# Medium red death flash
@export var death_flash_time: float = 0.25

# Attack cycle
const ATTACK_ENABLE_TIME: float = 3.0
const ATTACK_DISABLE_TIME: float = 3.0

# Blue frozen flash
@export var frozen_flash_time: float = 0.20

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $HealthBar

var current_health: int
var is_dead: bool = false
var attack_disabled: bool = false

var flash_material: ShaderMaterial


func _ready() -> void:
	current_health = max_health

	# ==================================================
	# CREATE FLASH SHADER
	# ==================================================

	var shader := Shader.new()

	shader.code = """
shader_type canvas_item;

uniform float flash_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec3 flash_color : source_color = vec3(1.0, 1.0, 1.0);

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);

	vec3 final_color = mix(
		texture_color.rgb,
		flash_color,
		flash_amount
	);

	COLOR = vec4(final_color, texture_color.a);
}
"""

	flash_material = ShaderMaterial.new()
	flash_material.shader = shader

	animated_sprite.material = flash_material

	# ==================================================
	# HEALTH BAR
	# ==================================================

	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health

	# ==================================================
	# PLAYER TOUCHING ENEMY
	# ==================================================

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	# Start attack cycle
	start_attack_cycle()


# ==================================================
# PLAYER TOUCHES ENEMY
# ==================================================

func _on_body_entered(body: Node) -> void:
	if is_dead:
		return

	if attack_disabled:
		return

	if body.has_method("take_damage"):
		body.take_damage(damage_amount, global_position)


# ==================================================
# AUTOMATIC ATTACK CYCLE
# ==================================================

func start_attack_cycle() -> void:

	while not is_dead:

		# ==================================================
		# ATTACK ENABLED FOR EXACTLY 3 SECONDS
		# ==================================================

		attack_disabled = false
		monitoring = true

		print("Enemy attack ENABLED - 3 seconds")

		animated_sprite.play("idle")

		await get_tree().create_timer(ATTACK_ENABLE_TIME).timeout

		if is_dead:
			return

		# ==================================================
		# DISABLE ATTACK
		# ==================================================

		attack_disabled = true
		monitoring = false

		print("Enemy attack DISABLED - 3 seconds")

		animated_sprite.play("idle")

		# Blue effect
		flash_blue()

		# ==================================================
		# DISABLED FOR EXACTLY 3 SECONDS
		# ==================================================

		await get_tree().create_timer(ATTACK_DISABLE_TIME).timeout

		if is_dead:
			return

		# ==================================================
		# ENABLE AGAIN
		# ==================================================

		remove_blue_flash()

		attack_disabled = false
		monitoring = true

		print("Enemy attack ENABLED again")

		animated_sprite.play("idle")


# ==================================================
# ENEMY TAKES DAMAGE
# ==================================================

func take_damage(amount: int = 1) -> void:
	if is_dead:
		return

	current_health -= amount
	current_health = max(0, current_health)

	print(
		"Gummy worm health: ",
		current_health,
		"/",
		max_health
	)

	if health_bar:
		health_bar.value = current_health

	if current_health <= 0:
		die()
		return

	flash_white()


# ==================================================
# WHITE DAMAGE FLASH
# ==================================================

func flash_white() -> void:
	if is_dead:
		return

	if flash_material == null:
		return

	flash_material.set_shader_parameter(
		"flash_color",
		Vector3(1.0, 1.0, 1.0)
	)

	flash_material.set_shader_parameter(
		"flash_amount",
		1.0
	)

	var tween := create_tween()

	tween.tween_property(
		flash_material,
		"shader_parameter/flash_amount",
		0.0,
		flash_time
	)


# ==================================================
# BLUE DISABLED FLASH
# ==================================================

func flash_blue() -> void:
	if is_dead:
		return

	if flash_material == null:
		return

	flash_material.set_shader_parameter(
		"flash_color",
		Vector3(0.0, 0.4, 1.0)
	)

	flash_material.set_shader_parameter(
		"flash_amount",
		1.0
	)

	var tween := create_tween()

	tween.tween_property(
		flash_material,
		"shader_parameter/flash_amount",
		0.65,
		frozen_flash_time
	)


# ==================================================
# REMOVE BLUE EFFECT
# ==================================================

func remove_blue_flash() -> void:
	if flash_material == null:
		return

	var tween := create_tween()

	tween.tween_property(
		flash_material,
		"shader_parameter/flash_amount",
		0.0,
		0.15
	)


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

	set_process(false)
	set_physics_process(false)

	attack_disabled = true
	monitoring = false

	if health_bar:
		health_bar.visible = false

	animated_sprite.stop()

	# Medium red death flash
	if flash_material:
		flash_material.set_shader_parameter(
			"flash_color",
			Vector3(0.6, 0.0, 0.0)
		)

		flash_material.set_shader_parameter(
			"flash_amount",
			1.0
		)

	await get_tree().create_timer(death_flash_time).timeout

	if is_instance_valid(self):
		queue_free()
