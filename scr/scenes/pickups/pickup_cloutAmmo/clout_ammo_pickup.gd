extends Area2D

func _ready():
	# Connect the signal to our function
	# self.body_entered.connect(_on_body_entered)
	pass
	
func _on_body_entered(body):
	print("chasing pickup")
	# Check if the body that entered is the player
	if body.is_in_group("player"): # <-- ASSUMING YOUR PLAYER IS IN THE "player" GROUP
		# Add 1 coin
		AmmoManager.add_ammo("bullet_clout", 10)
		
		# (Optional: play a sound)
		
		# Remove the coin from the world
		queue_free()
