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
			"text": "Can I buy a burrito please?",
			"texture": player_happy  # <--- Using the exported variable
		},
		{
			"speaker": "npc",
			"text": "No! You don't look hungry enough!",
			"texture": npc_angry
		},
		{
			"speaker": "player",
			"text": "But I skipped lunch...",
			"texture": player_happy
		}
	]
	
	# 3. RUN PARENT LOGIC
	super._ready()
