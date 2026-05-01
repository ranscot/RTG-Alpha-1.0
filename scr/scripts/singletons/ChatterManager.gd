extends Node

# The empty dictionary that will hold all our loaded chatters
var chat_database: Dictionary = {}

# The exact path to the folder where you save all your .tres files
const CHATIARY_FOLDER = "res://scr/scripts/chatter/Chatiary_Data/"

func _ready():
	# The absolute first thing the Kitchen does when the game boots:
	_load_all_chatters()

func _load_all_chatters():
	# 1. Open the physical folder on the hard drive
	var dir = DirAccess.open(CHATIARY_FOLDER)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		# 2. Loop through every single file in the folder
		while file_name != "":
			
			# 3. We only care about resource files (ignore hidden files/folders)
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				
				# Build the full path (e.g., "res://Chatiary_Data/killer_moon.tres")
				var full_path = CHATIARY_FOLDER + file_name
				
				# Load the resource into memory and cast it to our custom blueprint
				var chatter_resource = load(full_path) as ChatterData
				
				if chatter_resource:
					# Use the 'id' string you typed in the Inspector as the dictionary key!
					var master_key = chatter_resource.id
					
					# Add it to the dictionary
					chat_database[master_key] = chatter_resource
					
			# Move to the next file
			file_name = dir.get_next()
			
		dir.list_dir_end()
		print("Chatiary Loaded! Total entries: ", chat_database.size())
	else:
		print("Warning: Could not open the folder. Did you create 'res://Chatiary_Data/'?")


# --- THE HELPER FUNCTIONS (Unchanged) ---

func get_unlocked_chatters() -> Array:
	var unlocked_list = []
	for chatter_id in chat_database:
		if chat_database[chatter_id].is_unlocked: 
			unlocked_list.append(chatter_id)
	return unlocked_list

func get_chatter_data(chatter_id: String) -> ChatterData:
	if chat_database.has(chatter_id):
		return chat_database[chatter_id]
	return null

func unlock_chatter(chatter_id: String) -> void:
	if chat_database.has(chatter_id):
		var chatter = chat_database[chatter_id]
		if not chatter.is_unlocked:
			chatter.is_unlocked = true
			print("Chatiary Updated: Unlocked ", chatter.name)
