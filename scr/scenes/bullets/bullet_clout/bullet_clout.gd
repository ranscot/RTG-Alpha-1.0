extends Area2D

@export var speed: float = 800.0  # Pixels per second

# This will be set by the scene that creates the bullet
var direction: Vector2 = Vector2.UP

func _process(delta: float) -> void:
	# Move the bullet every frame
	global_position += direction * speed * delta

# This function is called when the bullet hits another physics body
func _on_body_entered(body: Node) -> void:
# Check if the body is an enemy and can take damage.
	if body.has_method("take_damage"):
		body.take_damage(15) # Lasers can do a bit more damage!
	call_deferred("queue_free") # Destroy the bullet on impact after frames calculated

# This function is called when the bullet leaves the screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() # Destroy the bullet when it's off-screen
	
	
