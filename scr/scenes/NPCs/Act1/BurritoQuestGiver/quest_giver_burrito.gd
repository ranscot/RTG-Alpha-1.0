extends BaseQuestGiver

@export var chatter_id: String = ""

# --- 1. DEFINE THE STATES ---
# We map your 0, 1, 2, 3 directly to the new Dictionary's status and current_step!

func get_quest_state() -> int:
	var quest = QuestManager.get_quest_data("burrito_fart")
	
	# Failsafe just in case
	if quest.is_empty(): 
		return 3 
	
	if quest.status == QuestManager.QuestStatus.UNAVAILABLE:
		return 0 # Triggers Opening Cutscene -> start_the_quest()
		
	elif quest.status == QuestManager.QuestStatus.ACTIVE:
		# Step 1: Quest accepted, waiting for Tom to get the burrito
		if quest.current_step == 1:
			return 1 # Triggers Waiting Cutscene
			
		# Step 2: Tom ate the burrito and came back!
		elif quest.current_step >= 2: 
			return 2 # Triggers Closing Cutscene -> finish_the_quest()
			
	# If status is QuestStatus.COMPLETED
	return 3 

# --- 2. DEFINE ACTIONS ---

# This runs when the Opening Cutscene finishes
func start_the_quest():
	if chatter_id != "":
		ChatiaryManager.unlock_chatter(chatter_id)
	print("Quest Giver: You accepted the mission!")
	# THE NEW WAY: Tell the dictionary to wake up the quest
	QuestManager.start_quest("burrito_fart")

	

# This runs when the Closing Cutscene finishes (Triggered by F key)
func finish_the_quest():
	print("Quest Giver: Smelled the fart. Quest Complete!")
	# THE NEW WAY: Tell the dictionary to move to the next step (or complete it)
	QuestManager.advance_quest("burrito_fart")

# This runs immediately after finishing
func trigger_special_ending():
	print("Quest Giver: FART EXPLOSION!")
	# Add particle effects here
	queue_free()
