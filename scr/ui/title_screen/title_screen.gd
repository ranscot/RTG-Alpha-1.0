extends Control

# 1. When the game boots up, tell the Global Brain we are on the Title Screen
func _ready():
	GameManager.change_state(GameManager.GameState.TITLE)

# 2. The player clicks "Start Game"
func _on_button_pressed():
	# Update the state machine
	GameManager.change_state(GameManager.GameState.CUTSCENE)
	
	# Hide the UI and kill the menu music
	$TextureRect.hide()
	$Button.hide()
	$AudioStreamPlayer2D.stop()
	
	# Reveal the video player and hit play
	$VideoStreamPlayer.show()
	$VideoStreamPlayer.play()

# 3. The video finishes playing
func _on_video_stream_player_finished():
	# Update the state machine to playing
	GameManager.change_state(GameManager.GameState.PLAYING)
	
	# Destroy the title screen and load the city!
	# IMPORTANT: Change this string to the actual path of your city level
	get_tree().change_scene_to_file("res://scr/scenes/top_level_v1/level_w.tscn")
