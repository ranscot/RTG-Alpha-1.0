extends Control

@onready var loading_label: Label = $LoadingLabel
@onready var loading_background: ColorRect = $LoadingBackground

func _ready():
	# 1. Tell the Global Brain we are on the Title Screen
	GameManager.change_state(GameManager.GameState.TITLE)
	
	# 2. UI Routing: Ensure Main Menu is visible, Settings is hidden
	$MainMenu.show()
	$SettingsMenu.hide()

# --- MAIN MENU BUTTONS ---

func _on_start_button_pressed():
	# Update the state machine
	GameManager.change_state(GameManager.GameState.CUTSCENE)
	
	# Hide the new UI container and kill the menu music
	$TextureRect.hide()
	$MainMenu.hide()
	$AudioStreamPlayer2D.stop()
	
	# Reveal the video player and hit play
	$VideoStreamPlayer.show()
	$VideoStreamPlayer.play()

func _on_settings_button_pressed():
	# Hide the main buttons, and show the settings widget
	$MainMenu.hide()
	$SettingsMenu.show()

func _on_quit_button_pressed():
	# The nuclear option
	get_tree().quit()

# --- THE RETURN TRIP ---

func _on_settings_menu_hidden():
	# When the Settings Menu hides itself, turn the Main Menu back on!
	$MainMenu.show()

# --- CUTSCENE & LOADING LOGIC ---

func _input(event):
	if GameManager.current_state == GameManager.GameState.CUTSCENE:
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
			
			set_process_input(false)
			
			# 1. Hide and stop the video
			$VideoStreamPlayer.hide()
			$VideoStreamPlayer.stop()
			
			# (GameManager.change_state removed from here to prevent auto-pausing)
			
			# 2. Show your custom loading screen elements
			loading_background.show()
			loading_label.show() 
			
			# 3. Tell Godot to start building the massive city in the background!
			var city_path = "res://scr/scenes/top_level_v1/level_w.tscn"
			ResourceLoader.load_threaded_request(city_path)
			
			# 4. Keep the loading screen running smoothly while we wait
			while ResourceLoader.load_threaded_get_status(city_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				await get_tree().process_frame
				
			# 5. The absolute millisecond it finishes building the city, swap to it instantly
			if ResourceLoader.load_threaded_get_status(city_path) == ResourceLoader.THREAD_LOAD_LOADED:
				
				# ---> FIX 1 IS HERE! <---
				# We tell the Autoload we are officially PLAYING right before loading the city.
				GameManager.change_state(GameManager.GameState.PLAYING)
				
				var new_scene = ResourceLoader.load_threaded_get(city_path)
				get_tree().change_scene_to_packed(new_scene)

func _on_video_stream_player_finished():
	# Update the state machine to playing
	GameManager.change_state(GameManager.GameState.PLAYING)
	
	# Destroy the title screen and load the city!
	get_tree().change_scene_to_file("res://scr/scenes/top_level_v1/level_w.tscn")
