extends Area2D

@export var damage_amount: int = 40
@export var max_health: int = 3

# White damage flash
@export var flash_time: float = 0.18

# Medium red death flash
@export var death_flash_time: float = 0.25

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $HealthBar

var current_health: int
var is_dead: bool = false

var flash_material: ShaderMaterial


func _ready() -> void:
	current_health = max_health

	# Create flash shader
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

	# Health bar
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health

	# Player touching enemy
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


# ==================================================
# PLAYER TOUCHES ENEMY
# ==================================================

func _on_body_entered(body: Node) -> void:
	if is_dead:
		return

	# Kill player instantly
	# No knockback
	# Enemy does NOT die
	if body.has_method("take_damage"):
		body.take_damage(999999)


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

	# Check if enemy died
	if current_health <= 0:
		die()
		return

	# Flash white when hit
	flash_white()


# ==================================================
# WHITE DAMAGE FLASH
# ==================================================

func flash_white() -> void:
	if is_dead:
		return

	if flash_material == null:
		return

	# Set flash colour to white
	flash_material.set_shader_parameter(
		"flash_color",
		Vector3(1.0, 1.0, 1.0)
	)

	# Make completely white
	flash_material.set_shader_parameter(
		"flash_amount",
		1.0
	)

	# Slowly return to normal
	var tween := create_tween()

	tween.tween_property(
		flash_material,
		"shader_parameter/flash_amount",
		0.0,
		flash_time
	)


# ==================================================
# TAKE HIT
# ==================================================

func take_hit(amount: int = 1) -> void:
	take_damage(amount)


# ==================================================
# ENEMY DEATH
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

	# Stop current animation
	animated_sprite.stop()

	# ==================================================
	# MEDIUM RED DEATH FLASH
	# ==================================================

	if flash_material:
		# Medium red
		flash_material.set_shader_parameter(
			"flash_color",
			Vector3(0.6, 0.0, 0.0)
		)

		# Make enemy completely medium red
		flash_material.set_shader_parameter(
			"flash_amount",
			1.0
		)

	# Keep red flash visible
	await get_tree().create_timer(death_flash_time).timeout

	# Remove enemy
	if is_instance_valid(self):
		queue_free()
