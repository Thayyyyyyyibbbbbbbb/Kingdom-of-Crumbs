extends Area2D

@export var max_health: int = 3
var health: int

@onready var health_bar = $"../HealthBar"


func _ready() -> void:
	health = max_health

	# Start health bar at 100%
	if health_bar:
		health_bar.max_value = 100
		health_bar.value = 100

	# Detect player's HitBox
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player_hitbox"):
		return

	var enemy = get_parent()

	# Tell the enemy it has been hit
	if enemy.has_method("take_damage"):
		enemy.take_damage(1)
