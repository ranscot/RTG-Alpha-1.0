extends BaseDialogueCutscene

# 1 EXPORT VARIABLES - Create one for each new player/npc image
@export_group("Player Portraits")
@export var player_neutral: Texture2D
@export var player_happy: Texture2D

@export_group("NPC Portraits")
@export var npc_neutral: Texture2D
@export var npc_angry: Texture2D
	
@export var spid_couch: Texture2D

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
			"text": "With great power, comes greater responsibility. Just ask Spiderman on a couch.",
			"texture": npc_angry
		},
			{
			"speaker": "spiderman_ona_couch",
			"text": "Toot Toot! Coming through! Eat the burrito, drop a mixtape out your backside.",
			"texture": spid_couch
		},
			{
			"speaker": "spiderman_ona_couch",
			"text": "Nothing like dustcropping the hates.
			Or the ones who love your the most. Spiderman out!",
			"texture": spid_couch
		},
		{
			"speaker": "player",
			"text": "Thanks, I'm kind a gas-hole now.",
			"texture": player_happy
		}
	]
	
	# 3. RUN PARENT LOGIC
	super._ready()
