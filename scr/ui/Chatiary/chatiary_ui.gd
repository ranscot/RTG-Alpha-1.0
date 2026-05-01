extends Control

# --- 1. GRAB THE UI NODES ---
# (Make sure these paths perfectly match your scene tree!)
@onready var chatter_list: VBoxContainer = $MarginContainer/HBoxContainer/LeftColumn/ScrollContainer/ChatterList
@onready var name_label: Label = $MarginContainer/HBoxContainer/RightColumn/NameLabel
@onready var weakness_label: Label = $MarginContainer/HBoxContainer/RightColumn/WeaknessLabel
@onready var bio_label: RichTextLabel = $MarginContainer/HBoxContainer/RightColumn/BioLabel
@onready var avatar_rect: TextureRect = $MarginContainer/HBoxContainer/RightColumn/AvatarRect


# --- 2. TRIGGER WHEN THE MENU OPENS ---
# Just like the Quest Log, we refresh the data every time Tom looks at it.
func _on_visibility_changed():
	if not is_node_ready():
		return
		
	if visible:
		refresh_chatter_list()
		clear_right_column() # Wipes the stale ghost data!


# --- 3. BUILD THE LEFT COLUMN (THE BUTTONS) ---
func refresh_chatter_list():
	# First, delete any old buttons so we don't get duplicates
	for child in chatter_list.get_children():
		child.queue_free()
		
	# Ask the Kitchen for the unlocked VIPs
	var unlocked_ids = ChatiaryManager.get_unlocked_chatters()
	
	if unlocked_ids.is_empty():
		name_label.text = "No chatters encountered yet..."
		return

	# Generate a button for every unlocked chatter
	for chatter_id in unlocked_ids:
		var data = ChatiaryManager.get_chatter_data(chatter_id)
		
		if data:
			var btn = Button.new()
			btn.text = data.name
			
			# CRITICAL MAGIC TRICK: 
			# Use .bind(chatter_id) so the button remembers exactly WHO to look up when clicked!
			btn.pressed.connect(show_chatter_details.bind(chatter_id))
			
			# Add the button to the Left Column
			chatter_list.add_child(btn)


# --- 4. FILL THE RIGHT COLUMN (THE DOSSIER) ---
# This runs when Tom clicks one of the buttons we generated above
func show_chatter_details(chatter_id: String):
	var data = ChatiaryManager.get_chatter_data(chatter_id)
	
	if data:
		print("FOUND BIO: ", data.bio)
		name_label.text = data.name
		weakness_label.text = "Weakness: " + data.weakness
		bio_label.text = data.bio
		
		# Load the visual Avatar!
		if data.avatar:
			avatar_rect.texture = data.avatar
		else:
			avatar_rect.texture = null


# --- 5. CLEANUP ---
func clear_right_column():
	name_label.text = "Select a Chatter"
	weakness_label.text = ""
	bio_label.text = ""
	avatar_rect.texture = null
