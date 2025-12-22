extends BaseDialogueCutscene


# 1 EXPORT VARIABLES - Create one for each new player/npc image
@export_group("Player Portraits")
@export var player_neutral: Texture2D

@export_group("NPC Portraits")
@export var npc_face_image: Texture2D

func _ready() -> void:
		# Define the dialogue 
	dialogue_data = [
		{
			"speaker": "npc",
			"text": "WOW! THE RetrogradeTom! What is going on!",
			"texture": npc_face_image
		},
		{
			"speaker": "player",
			"text": "On my way to the cheese cake factory, I think I am finally famous enough to get a table.",
			"texture": player_neutral
		},
		{
			"speaker": "npc",
			"text": "Cool! I wish I could visit such a valhalla.",
			"texture": npc_face_image
		},		
		{
			"speaker": "player",
			"text": "Mind if I get by here?",
			"texture": player_neutral
		},
		{
			"speaker": "npc",
			"text": "Actually, yes I do mind. I want to match the mind of the greatest PuzzWizz of all time, basically Mensa. I will not let you pass unless you do as well.",
			"texture": npc_face_image
		}
	]
	
	super._ready() # run base setup
