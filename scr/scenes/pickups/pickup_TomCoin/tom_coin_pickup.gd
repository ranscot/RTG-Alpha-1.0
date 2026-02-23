extends Area2D

@onready var on_pickup_sound: AudioStreamPlayer2D = $On_pickup_sound
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# --- Add a GateKeeper
var is_collected: bool = false


	
func _on_body_entered(body):
	
	print("im in the coin")
	# Check the gate
	if is_collected:
		return
	
	# 1. Give the ammo
	if body.is_in_group("player"): # <-- ASSUMING YOUR PLAYER IS IN THE "player" GROUP
		is_collected = true
		
		# Disable physics
		collision_shape_2d.set_deferred("disabled", true)
		
		# Add 10 coin to TomCoins
		AmmoManager.add_coins(10)

		# 2. PLay the sound
		on_pickup_sound.play()
		
		# 3. Make the object "disappear" immediately
		animated_sprite_2d.visible = false
		
		# 4. Wait for the sound to finish playing
		await on_pickup_sound.finished  
	
		# 5. Now delete the object
		queue_free()
