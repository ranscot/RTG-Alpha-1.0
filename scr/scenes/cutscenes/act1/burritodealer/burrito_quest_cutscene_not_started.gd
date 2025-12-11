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
			"text": "What are you selling",
			"texture": player_happy  # <--- Using the exported variable
		},
		{
			"speaker": "npc",
			"text": "Magic beyond your current understanding!",
			"texture": npc_angry
		},
		{
			"speaker": "player",
			"text": "Cool, I am just gonna go.",
			"texture": player_happy
		}
	]
	
	# 3. RUN PARENT LOGIC
	super._ready()
