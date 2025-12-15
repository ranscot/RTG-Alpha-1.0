extends BaseDialogueCutscene

# Export the face so you can set it in the Inspector
@export var npc_face_image: Texture2D

func _ready() -> void:
	# Define the data BEFORE calling super._ready()
	dialogue_data = [
		{
			"speaker": "npc",
			"text": "Have you seen the Burrito Dealer yet?",
			"texture": npc_face_image
		},
		{
			"speaker": "npc",
			"text": "I am extremely hungry. Please hurry.",
			"texture": npc_face_image
		}
	]
	
	# Run the base logic to start the display
	super._ready()
