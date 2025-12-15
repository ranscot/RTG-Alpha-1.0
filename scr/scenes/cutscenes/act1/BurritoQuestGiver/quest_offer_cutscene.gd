extends BaseDialogueCutscene

# Signal to tell QuestGiver what the Player has choosen
signal choice_made(was_accepted)

@onready var button_container: HBoxContainer = $CanvasLayer/DialogueControl/Panel/ButtonContainer
@onready var yes_button: Button = $CanvasLayer/DialogueControl/Panel/ButtonContainer/YesButton
@onready var no_button: Button = $CanvasLayer/DialogueControl/Panel/ButtonContainer/NoButton

func _ready() -> void:
		# Define the dialogue 
	dialogue_data = [
		{
			"speaker": "npc",
			"text": "I need a joke that can choke. I need eye watering clout.",
			"texture": npc_portrait
		},
		{
			"speaker": "npc",
			"text": "I need a joke that can choke. I need eye watering clout.",
			"texture": npc_portrait
		}
	]
	
		# connect tbusston
	yes_button.pressed.connect(_on_yes_pressed)
	no_button.pressed.connect(_on_no_pressed)
	button_container.hide()
	
	super._ready() # run bas setup
	
func _process(_delta: float) -> void:
	# D. CHECK FOR END OF DIALOGUE
	# We use 'current_line_index' because that is what your Base Class uses.
	if current_line_index == dialogue_data.size() - 1:
		
		# Only run this once when we hit the last page
		if not button_container.visible:
			button_container.show()
			
			# CRITICAL: Stop the "T" key from working so they MUST click a button
			set_process_unhandled_input(false)
		

func _on_yes_pressed():
	emit_signal("choise_made", true)
	queue_free()
	
func _on_no_pressed():
	emit_signal("choice_made", false)
	queue_free()
