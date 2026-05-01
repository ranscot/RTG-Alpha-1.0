extends CanvasLayer

func _ready():
	hide()

func _input(event):
	if GameManager.current_state == GameManager.GameState.PLAYING or GameManager.current_state == GameManager.GameState.PAUSED:
		if event.is_action_pressed("ui_cancel"):
			toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	
	if get_tree().paused:
		show()
		# Always default to the System tab when opening the menu
		switch_tab($MainLayout/ContentArea/SystemPane)
		GameManager.change_state(GameManager.GameState.PAUSED)
	else:
		hide()
		GameManager.change_state(GameManager.GameState.PLAYING)

# --- THE VIEW MANAGER ---

func switch_tab(active_pane):
	# 1. Hide every single pane currently inside the Content Area
	for child in $MainLayout/ContentArea.get_children():
		child.hide()
	
	# 2. Show only the specific pane we requested
	active_pane.show()

# --- NAV BAR TAB BUTTONS ---

func _on_system_tab_pressed():
	switch_tab($MainLayout/ContentArea/SystemPane)

func _on_settings_tab_pressed():
	switch_tab($MainLayout/ContentArea/SettingsMenu)
	
func _on_quests_tab_pressed() -> void:
	switch_tab($MainLayout/ContentArea/QuestLog)
	
func _on_bestiary_tab_pressed() -> void:
	switch_tab($MainLayout/ContentArea/ChatiaryUI)



# --- SYSTEM PANE BUTTONS ---

func _on_resume_button_pressed():
	toggle_pause()

func _on_quit_button_pressed():
	get_tree().quit()
