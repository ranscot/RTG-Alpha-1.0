extends Control

func _ready():
	# Tell the node to listen for whenever it gets hidden or shown
	visibility_changed.connect(_on_visibility_changed)
	
	# Force a sync right now on boot just to be safe
	_on_visibility_changed()

func _on_visibility_changed():
	# Only update the sliders if the menu is actually opening
	if visible:
		# We use "no_signal" so we don't accidentally trigger 
		# the save file to overwrite itself just by opening the menu!
		%FullScreenToggle.set_pressed_no_signal(SettingsManager.fullscreen)
		%VSyncToggle.set_pressed_no_signal(SettingsManager.vsync)
		%CRTToggle.set_pressed_no_signal(SettingsManager.crt_enabled)
		
		%MasterSlider.set_value_no_signal(SettingsManager.master_vol)
		%MusicSlider.set_value_no_signal(SettingsManager.music_vol)
		%EffectsSlider.set_value_no_signal(SettingsManager.sfx_vol)

# --- THE VIDEO SIGNALS ---

func _on_full_screen_toggle_toggled(toggled_on):
	# Update the brain, apply it to the monitor, and save to the hard drive
	SettingsManager.fullscreen = toggled_on
	SettingsManager.apply_video_settings()
	SettingsManager.save_settings()

func _on_v_sync_toggle_toggled(toggled_on):
	SettingsManager.vsync = toggled_on
	SettingsManager.apply_video_settings()
	SettingsManager.save_settings()

func _on_crt_toggle_toggled(toggled_on):
	SettingsManager.crt_enabled = toggled_on
	SettingsManager.apply_video_settings()
	SettingsManager.save_settings()

# --- THE AUDIO SIGNALS ---

func _on_master_slider_value_changed(value: float):
	SettingsManager.master_vol = value
	SettingsManager.apply_audio_settings()
	SettingsManager.save_settings()

func _on_music_slider_value_changed(value: float):
	SettingsManager.music_vol = value
	SettingsManager.apply_audio_settings()
	SettingsManager.save_settings()

func _on_effects_volume_value_changed(value: float) -> void:
	SettingsManager.sfx_vol = value
	SettingsManager.apply_audio_settings()
	SettingsManager.save_settings()


# --- NAVIGATION ---

func _on_back_button_pressed():
	# When they click Back, just hide this specific menu. 
	# (The Title Screen script will handle making the Main Menu reappear)
	hide()
