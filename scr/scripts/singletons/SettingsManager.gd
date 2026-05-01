extends Node

# 1. The universal save path
const SAVE_PATH = "user://settings.cfg"
var config = ConfigFile.new()

# 2. The Default Values (In case the player boots the game for the very first time)
var fullscreen: bool = false
var vsync: bool = true
var crt_enabled: bool = false

# Volume is stored from 0.0 (silent) to 1.0 (100% max volume)
var master_vol: float = 1.0 
var music_vol: float = 1.0
var sfx_vol: float = 1.0

func _ready():
	# The absolute millisecond the game boots, read the file and apply the settings
	load_settings()

# --- THE ARCHIVIST (File I/O) ---

func load_settings():
	var err = config.load(SAVE_PATH)
	if err != OK:
		# If the file doesn't exist yet, just save our default values to create it
		save_settings()
		return
		
	# Read the values from the file. If a value is missing, use our default variable as a backup.
	fullscreen = config.get_value("Video", "fullscreen", fullscreen)
	vsync = config.get_value("Video", "vsync", vsync)
	crt_enabled = config.get_value("Video", "crt_enabled", crt_enabled)
	
	master_vol = config.get_value("Audio", "master_vol", master_vol)
	music_vol = config.get_value("Audio", "music_vol", music_vol)
	sfx_vol = config.get_value("Audio", "sfx_vol", sfx_vol)
	
	# Actually tell the engine to change the monitor and speakers!
	apply_video_settings()
	apply_audio_settings()

func save_settings():
	# Write the current variables into the config file structure
	config.set_value("Video", "fullscreen", fullscreen)
	config.set_value("Video", "vsync", vsync)
	config.set_value("Video", "crt_enabled", crt_enabled)
	
	config.set_value("Audio", "master_vol", master_vol)
	config.set_value("Audio", "music_vol", music_vol)
	config.set_value("Audio", "sfx_vol", sfx_vol)
	
	# Save it to the hard drive
	config.save(SAVE_PATH)

# --- THE SYSTEM ADMINISTRATOR (Talking to the Engine) ---

func apply_video_settings():
	if fullscreen:
		# Force macOS and Windows to completely surrender the monitor
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
	if vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
	if crt_enabled:
		CrtFilter.show()
	else:
		CrtFilter.hide()

func apply_audio_settings():
	# Find specific channels on the mixing board
	var master_bus = AudioServer.get_bus_index("Master")
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus = AudioServer.get_bus_index("SFX")
	
	# Convert 0.0-1.0 slider math into Logarithmic Decibels (dB) so it sounds natural
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_vol))
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_vol))
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_vol))
