extends Area2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# --- Add a GateKeeper
var is_collected: bool = false


	
func _on_body_entered(body):
	# Check the gate
	if is_collected:
		return
	
	# 1. Give the ammo
	if body.is_in_group("player"): # <-- ASSUMING YOUR PLAYER IS IN THE "player" GROUP
		is_collected = true
		
		# Disable physics
		collision_shape_2d.set_deferred("disabled", true)
		
		# Add 10 coin
		AmmoManager.add_ammo("bullet_clout", 10)

		# 2. PLay the sound
		audio_stream_player.play()
		
		# 3. Make the object "disappear" immediately
		animated_sprite_2d.visible = false
		
		# 4. Wait for the sound to finish playing
		await audio_stream_player.finished  
	
		# 5. Now delete the object
		queue_free()
