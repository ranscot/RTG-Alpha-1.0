extends Area2D

@onready var engage_ammo_pickup: AudioStreamPlayer2D = $EngageAmmo_Pickup

func _ready():
	# Connect the signal to our function
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the body that entered is the player
	if body.is_in_group("player"): # <-- ASSUMING YOUR PLAYER IS IN THE "player" GROUP
		# Add 1 coin
		AmmoManager.add_ammo("bullet_engage", 10)
		
		# (Optional: play a sound)
		engage_ammo_pickup
		# Remove the coin from the world
		queue_free()
