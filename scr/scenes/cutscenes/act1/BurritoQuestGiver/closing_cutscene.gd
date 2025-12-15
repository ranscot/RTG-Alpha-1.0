extends BaseDialogueCutscene

@export var npc_face_image: Texture2D

func _ready() -> void:
	dialogue_data = [
		{
			"speaker": "npc",
			"text": "Finally! You're back.",
			"texture": npc_face_image
		},
		{
			"speaker": "npc",
			"text": "Wait... why do you smell like beans?",
			"texture": npc_face_image
		},
		{
			"speaker": "npc",
			"text": "YOU ATE IT?! I'm going to starve!",
			"texture": npc_face_image
		},
		{
			"speaker": "npc",
			"text": "(Press 'F' to unleash a Fart Attack)", # Prompt for the player
			"texture": npc_face_image
		}
	]
	
	super._ready()
