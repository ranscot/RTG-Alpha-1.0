extends Area2D

@onready var on_pickup_sound: AudioStreamPlayer2D = $On_pickup_sound
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	print("chasing pickup")
	# Connect the signal to our function
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	# Check if the body that entered is the player
	if body.is_in_group("player"): # <-- ASSUMING YOUR PLAYER IS IN THE "player" GROUP
		# Add 1 coin
		AmmoManager.add_coins(1)
		on_pickup_sound.play()		
		animated_sprite_2d.visible = false
		
		await  on_pickup_sound.finished
		
		# Remove the coin from the world
		queue_free()
