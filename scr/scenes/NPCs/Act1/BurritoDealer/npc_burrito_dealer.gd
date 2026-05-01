extends BaseQuestGiver

# --- EXPORTS: The specific movies for the Dealer ---
@export_group("Dealer Scenes")
@export var scene_not_started: PackedScene   # Idle chat
@export var scene_accepted: PackedScene      # THE TRANSACTION (Give Item)
@export var scene_already_eaten: PackedScene # Idle chat
@export var scene_completed: PackedScene     # Idle chat

# --- 1. LOGIC MAPPING ---
func get_quest_state() -> int:
	var quest = QuestManager.get_quest_data("burrito_fart")
	
	if quest.is_empty() or quest.status == QuestManager.QuestStatus.UNAVAILABLE:
		# SCENARIO 1: Quest Not Started
		# Just chatting. No rewards.
		waiting_cutscene = scene_not_started
		return 1 # Return 1 = Passive Mode
		
	elif quest.status == QuestManager.QuestStatus.ACTIVE:
		# SCENARIO 2: Quest Accepted (Waiting for Tom to get the burrito)
		if quest.current_step == 1:
			opening_cutscene = scene_accepted
			return 0 # Return 0 = Action Mode (Plays scene -> Runs start_the_quest)
			
		# SCENARIO 3: Burrito Eaten (Tom already got the ammo)
		elif quest.current_step >= 2:
			waiting_cutscene = scene_already_eaten
			return 1 # Return 1 = Passive Mode
			
	# SCENARIO 4: Completed
	waiting_cutscene = scene_completed
	return 1 # Return 1 = Passive Mode

# --- 2. THE ACTION (GIVING THE ITEM) ---
# This runs automatically ONLY when we return 0 (State: ACTIVE, Step 1)
func start_the_quest():
	print("Dealer: Transaction complete. Burrito delivered.")
	
	# 1. Give the Ammo 
	if AmmoManager:
		AmmoManager.add_ammo("bullet_fart", 10)
	
	# 2. Advance the Quest State
	# THE NEW WAY: This moves the state to Step 2!
	QuestManager.advance_quest("burrito_fart") 

# --- 3. UNUSED OVERRIDES ---
func finish_the_quest():
	pass

func trigger_special_ending():
	pass
