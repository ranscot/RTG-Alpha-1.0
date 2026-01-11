extends BaseDialogueCutscene

# Export the face so you can set it in the Inspector
@export var npc_face_image: Texture2D

@export var player_neutral: Texture2D


func _ready() -> void:
	# Define the data BEFORE calling super._ready()
	dialogue_data = [
		{
			"speaker": "player",
			"text": "I have no idea, maybe I should look it up?",
			"texture": player_neutral
		},
		{
			"speaker": "npc",
			"text": "Have you seen the Burrito Dealer yet?",
			"texture": npc_face_image
		},
		{
			"speaker": "npc",
			"text": "I am so hungryy I may PASS out.",
			"texture": npc_face_image
		},
		{
			"speaker": "player",
			"text": "...",
			"texture": player_neutral
		},
		{
			"speaker": "npc",
			"text": "...",
			"texture": npc_face_image
		}
	]
	
	# Run the base logic to start the display
	super._ready()
