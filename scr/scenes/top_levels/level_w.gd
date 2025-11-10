extends Node2D

@onready var player = $Player

func _ready() -> void:
	# Connect the player's "shoot" signal to a function in this script.
	# When the player emits "shoot", the "_on_player_shoot" function will run.
	# player.shoot.connect(_on_player_shoot)
	pass
# This function runs whenever the player emits the "shoot" signal.
# It receives the parameters we sent with it.
func _on_player_shoot(bullet_scene: PackedScene, direction: Vector2, location: Vector2) -> void:
	# Create a new instance of the bullet scene
	var new_bullet = bullet_scene.instantiate()

	# Set the bullet's properties
	new_bullet.direction = direction
	new_bullet.global_position = location

	# Add the new bullet to the scene tree
	add_child(new_bullet)
	print("Bullet Fired!")
