extends CanvasLayer

# Signal to tell the Game the cutscene is done
signal cutscene_finished

# 1. Define the Dialogue data
# Use "Speaker" to decide which nodes to show

var dialogue_lines = [
	{
		"speaker": "dealer",
		"text": "Hola! You look like you need a burrito!"
	},
	{
		"speaker": "player",
		"text": "Hark! Do you have the legendary Baco Tell burritos!"
	},
	{
		"speaker": "dealer",
		"text": "For you! FOR YOU! World famous RetroGrade Tom?"
	},
	{
		"speaker": "dealer",
		"text": "This one is on the house!"
	}
]

var current_index = 0
var can_advance = false # safety lock

# 2. grab references to all of the UI elements
@onready var player_portrait: TextureRect = $Panel/PlayerPortrait
@onready var dealer_portrait: TextureRect = $Panel/DealerPortrait
@onready var player_label: Label = $Panel/PlayerLabel
@onready var dealer_label: Label = $Panel/DealerLabel

func _ready() -> void:
	print("A NEW CUTSCENE WAS BORN! Total: ", get_parent().get_child_count())
	update_display()
	
	# safety buffer so that the T that opened the cutscen doesnt advance it
	await get_tree(). create_timer(0.2).timeout
	can_advance = true 
	
func _input(event):
	if event.is_action_pressed("interaction") and can_advance: # spacebar
		advance_cutscene()
		
		
func advance_cutscene():
	current_index += 1
	if current_index < dialogue_lines.size():
		update_display()
	else: 
		close_cutscene()
		
		
func update_display():
	# get the current line of dialogue
	var current_line = dialogue_lines[current_index]
	var speaker = current_line["speaker"]
	var text_content = current_line["text"]
	
	# RESET Hide EVERYONE FIRST
	player_portrait.visible = false
	player_label.visible = false
	dealer_label.visible = false
	dealer_portrait.visible = false
	
	#3. toggle logic
	if speaker == "dealer":
		# show dealer stuff, hide player stuff
		dealer_portrait.visible = true
		dealer_label.visible = true
		dealer_label.text = text_content
		

		
	elif speaker == "player":
		# show Player show, hide dealer stuff
		player_portrait.visible = true
		player_label.visible = true
		player_label.text = text_content
		
	else:
		print("ERROR: UNKNOWN SPEAKER ", speaker)
	
	
func close_cutscene():
	emit_signal("cutscene_finished")
	queue_free()
