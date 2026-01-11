extends BaseDialogueCutscene

@export var npc_face_image: Texture2D

@export var player_neutral: Texture2D

func _ready() -> void:
	dialogue_data = [
		{
			"speaker": "npc",
			"text": "Using a burrito power would be flatus-tically funny. ",
			"texture": npc_face_image
		},
		{
			"speaker": "npc",
			"text": "I hope you didn't come back to blow off some steam",
			"texture": npc_face_image
		},
		{
			"speaker": "player",
			"text": "I was gonna let Joe do a shout out later, but I decided to let this grind.",
			"texture": player_neutral
		},		
		{
			"speaker": "npc",
			"text": "I feel like I was kust gaslighted, butt seriously Wind-erful performance.",
			"texture": npc_face_image
		},
				
		{
			"speaker": "npc",
			"text": "Thy shall pass. Fly you fool. You must have your Night at the Cheesecake Factory!",
			"texture": npc_face_image
		},

		{
			"speaker": "npc",
			"text": "(Press 'Space' to unleash a Fart Attack)", # Prompt for the player
			"texture": npc_face_image
		},
	]
	
	super._ready()
