extends BaseDialogueCutscene

# 1 EXPORT VARIABLES - Create one for each new player/npc image
@export_group("Player Portraits")
@export var player_neutral: Texture2D
@export var player_happy: Texture2D

@export_group("NPC Portraits")
@export var npc_neutral: Texture2D
@export var npc_angry: Texture2D
	
func _ready() -> void:
	# --- 2. USE THEM IN THE ARRAY ---
	# Now we reference the variables (p_sad, n_angry) instead of loading paths
	dialogue_data = [
		{
			"speaker": "player",
			"text": "That burrito was incredible!",
			"texture": player_happy  # <--- Using the exported variable
		},
		{
			"speaker": "npc",
			"text": "The Baco Tell Burrito Experience will keep your adoring public at bay.",
			"texture": npc_angry
		},
		{
			"speaker": "player",
			"text": "What do I do now?",
			"texture": player_happy
		},
		{
			"speaker": "npc",
			"text": "Show the one who sent you you no longer chop by hand.",
			"texture": npc_angry
		}
	]
	
	# 3. RUN PARENT LOGIC
	super._ready()
