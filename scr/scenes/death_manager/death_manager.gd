extends CanvasLayer

@onready var black_screen: ColorRect = $BlackScreen
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var video_player: VideoStreamPlayer = $AspectRatioContainer/CutscenePlayer


func _ready() -> void:
	# Ensure the screen is hidden when the game starts
	black_screen.modulate.a = 0
	video_player.hide()

# Call this function when the player dies
func play_death_sequence(player: Node2D) -> void:
	# 1. Lock game state
	GameManager.change_state(GameManager.GameState.CUTSCENE)
	
	# 2. FADE TO BLACK
	anim_player.play("fade_to_black")
	await anim_player.animation_finished # Code pauses here until the fade is done
	
	# 3. THE CUTSCENE (Only if it's the first death)
	if not GameManager.has_died_before: # Assuming your Autoload is named GameManager
		GameManager.has_died_before = true # Mark that he has died!
		
		video_player.show()
		video_player.play()
		await video_player.finished # Code pauses here until the video ends
		
		video_player.hide() # Hide the video player to reveal the black screen behind it
	
	# 4. THE RESPAWN (This happens while the screen is still black!)
	print("DeathManager is trying to teleport Tom to: ", GameManager.current_spawn_location)
	# Teleport Tom to the stored coordinates
	player.global_position = GameManager.current_spawn_location
	
	# Heal Tom and turn his collision/movement back on
	player.respawn()
	
	# Optional: Wait half a second in the dark for dramatic effect
	await get_tree().create_timer(0.5).timeout
	
	# 5. FADE BACK IN
	anim_player.play("fade_in")
	
	# 6. Unlock Game State
	GameManager.change_state(GameManager.GameState.PLAYING)
	
