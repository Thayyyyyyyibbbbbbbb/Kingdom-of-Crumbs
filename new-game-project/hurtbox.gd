extends Area2D

var health := 3  # Change this to whatever health you want

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		health -= 1
		print("Gummy worm's health is: ", health)
		
		if health <= 0:
			print("Dead gummy worm")
			get_parent().queue_free()  # Deletes the Gummy Worm root node
