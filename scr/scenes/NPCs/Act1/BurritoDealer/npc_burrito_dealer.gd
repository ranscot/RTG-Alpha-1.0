extends BaseQuestGiver

# --- EXPORTS: The specific movies for the Dealer ---
@export_group("Dealer Scenes")
@export var scene_not_started: PackedScene   # Idle chat
@export var scene_accepted: PackedScene      # THE TRANSACTION (Give Item)
@export var scene_already_eaten: PackedScene # Idle chat
@export var scene_completed: PackedScene     # Idle chat

# --- 1. LOGIC MAPPING ---
func get_quest_state() -> int:
	var s = QuestManager.burritoQuest_current_state
	
	# SCENARIO 1: Quest Not Started
	# Just chatting. No rewards.
	if s == QuestManager.BurritoQuestState.NOT_STARTED:
		waiting_cutscene = scene_not_started
		return 1 # Return 1 = Passive Mode (Just plays the scene)

	# SCENARIO 2: Quest Accepted
	# This is the "Transaction". We want to run code after the movie.
	elif s == QuestManager.BurritoQuestState.ACCEPTED:
		opening_cutscene = scene_accepted
		return 0 # Return 0 = Action Mode (Plays scene -> Runs start_the_quest)

	# SCENARIO 3: Burrito Eaten
	# Player has the ammo/item. Just chatting.
	elif s == QuestManager.BurritoQuestState.BURRITO_EATEN:
		waiting_cutscene = scene_already_eaten
		return 1 # Return 1 = Passive Mode

	# SCENARIO 4: Completed
	# Quest is over. Just chatting.
	else:
		waiting_cutscene = scene_completed
		return 1 # Return 1 = Passive Mode

# --- 2. THE ACTION (GIVING THE ITEM) ---
# This runs automatically ONLY when we return 0 (State: ACCEPTED)
func start_the_quest():
	print("Dealer: Transaction complete. Burrito delivered.")
	
	# 1. Give the Ammo (Just like the Truck!)
	if AmmoManager:
		AmmoManager.add_ammo("bullet_fart", 10)
	
	# 2. Advance the Quest State
	# This moves the state from ACCEPTED -> BURRITO_EATEN
	QuestManager.eat_burrito() 

# --- 3. UNUSED OVERRIDES ---
# The dealer does not finish the quest (The Giver does that)
func finish_the_quest():
	pass

# The dealer does not explode
func trigger_special_ending():
	pass
