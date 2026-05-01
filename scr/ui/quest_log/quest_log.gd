extends MarginContainer

const QUEST_BTN_SCENE = preload("res://scr/ui/quest_button/quest_button.tscn")
const OBJECTIVE_CB_SCENE = preload("res://scr/ui/quest_objective/quest_objective.tscn")

# Grab references to the exact nodes we built in the Scene Tree
@onready var quest_list: VBoxContainer = $SplitScreen/LeftColumn/QuestList
@onready var title_label: Label = $SplitScreen/RightColumn/TitleLabel
@onready var desc_label: RichTextLabel = $SplitScreen/RightColumn/DescLabel
@onready var objectives_box: VBoxContainer = $SplitScreen/RightColumn/ObjectivesBox

func _ready():
	# 1. Clear the default text on startup
	clear_right_column()
	
	# 2. Tell the UI to listen for when the player opens the Quests tab
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	# Only rebuild the menu if the screen just became visible
	if visible:
		refresh_quest_list()
		clear_right_column()

# --- THE LEFT COLUMN (Building the Menu) ---

func refresh_quest_list():
	# 1. Wipe out the old buttons so they don't duplicate
	for child in quest_list.get_children():
		child.queue_free()
		
	# 2. Ask the Kitchen for the array of active quests
	var active_quests = QuestManager.get_all_active_quests()
	
	# 3. Create a button for every active quest
	for quest_id in active_quests:
		var quest_data = QuestManager.get_quest_data(quest_id)
		
		var btn = QUEST_BTN_SCENE.instantiate()

		btn.text = quest_data["title"]
		
		# Give the button some breathing room (optional AAA polish)
		btn.custom_minimum_size = Vector2(0, 40)
		
		# When clicked, pass the specific quest_id to the right column!
		btn.pressed.connect(show_quest_details.bind(quest_id)) 
		
		quest_list.add_child(btn)

# --- THE RIGHT COLUMN (Serving the Details & Mystery Math) ---

func show_quest_details(quest_id: String):
	# 1. Wipe the old quest details
	clear_right_column()
	
	# 2. Ask the Kitchen for the full dictionary
	var quest_data = QuestManager.get_quest_data(quest_id)
	if quest_data.is_empty(): 
		return
	
	# 3. Set the Lore text
	title_label.text = quest_data["title"]
	
	# Because we checked 'Bbcode Enabled', this will automatically parse colors and bolding!
	desc_label.text = quest_data["description"] 
	
	# 4. The Objective Math (Hiding future steps)
	var current_step = quest_data["current_step"]
	var all_objectives = quest_data["objectives"]
	
	# print("THE UI THINKS THE CURRENT STEP IS: ", current_step) # debug for quest stepping
	
	for i in range(all_objectives.size()):
		# If this index is higher than our current step, it's a future mystery. Stop drawing!
		if i > current_step:
			break 
			
		# Create a checkbox for the allowed steps
		var cb = OBJECTIVE_CB_SCENE.instantiate()
		cb.text = all_objectives[i]
		
		# Tell the UI to completely ignore the player's mouse clicks
		cb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		if i < current_step:
			# We already beat this step! Check it off.
			cb.button_pressed = true
		else:
			# This is the active step! Leave it unchecked.
			cb.button_pressed = false
			
		objectives_box.add_child(cb)

func clear_right_column():
	title_label.text = "Select a Quest"
	desc_label.text = ""
	
	for child in objectives_box.get_children():
		child.queue_free()
