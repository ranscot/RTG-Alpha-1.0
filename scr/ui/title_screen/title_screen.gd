extends Control

@onready var loading_label: Label = $LoadingLabel
@onready var loading_background: ColorRect = $LoadingBackground


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

func _input(event):
	if GameManager.current_state == GameManager.GameState.CUTSCENE:
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
			
			set_process_input(false)
			
			# 1. Hide and stop the video
			$VideoStreamPlayer.hide()
			$VideoStreamPlayer.stop()
			
			GameManager.change_state(GameManager.GameState.PLAYING)
			
			# 2. Show your custom loading screen elements
			loading_background.show()
			loading_label.show() 
			
			# 3. Tell Godot to start building the massive city in the background!
			var city_path = "res://scr/scenes/top_level_v1/level_w.tscn" # <--- YOUR PATH HERE
			ResourceLoader.load_threaded_request(city_path)
			
			# 4. Keep the loading screen running smoothly while we wait
			while ResourceLoader.load_threaded_get_status(city_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				# This tells the engine: "Update the screen, then check the load status again"
				await get_tree().process_frame
				
			# 5. The absolute millisecond it finishes building the city, swap to it instantly
			if ResourceLoader.load_threaded_get_status(city_path) == ResourceLoader.THREAD_LOAD_LOADED:
				var new_scene = ResourceLoader.load_threaded_get(city_path)
				get_tree().change_scene_to_packed(new_scene)

# 3. The video finishes playing
func _on_video_stream_player_finished():
	# Update the state machine to playing
	GameManager.change_state(GameManager.GameState.PLAYING)
	
	# Destroy the title screen and load the city!
	# IMPORTANT: Change this string to the actual path of your city level
	get_tree().change_scene_to_file("res://scr/scenes/top_level_v1/level_w.tscn")
