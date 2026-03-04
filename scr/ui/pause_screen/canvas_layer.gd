extends CanvasLayer

func _ready():
	# 1. The absolute millisecond the game boots, hide this menu
	hide()

func _input(event):
	# 2. Only allow pausing if we are actively playing or already paused
	if GameManager.current_state == GameManager.GameState.PLAYING or GameManager.current_state == GameManager.GameState.PAUSED:
		
		# ui_cancel is the Escape key
		if event.is_action_pressed("ui_cancel"):
			toggle_pause()

func toggle_pause():
	# 3. Flip the engine's built-in time-stop switch
	# (If it's false, make it true. If it's true, make it false)
	get_tree().paused = !get_tree().paused
	
	# 4. Update our UI and the Global Brain based on the new state
	if get_tree().paused:
		show()
		GameManager.change_state(GameManager.GameState.PAUSED)
	else:
		hide()
		GameManager.change_state(GameManager.GameState.PLAYING)

# 5. The buttons
func _on_resume_button_pressed():
	# Resume just does the exact same thing as hitting Escape again
	toggle_pause()

func _on_quit_button_pressed():
	# The nuclear option to close the application entirely
	get_tree().quit()
