extends BaseQuestGiver

# --- 1. DEFINE THE STATES ---
# 0 = Not Started (Action: Start Quest)
# 1 = Accepted (Passive: Wait)
# 2 = Eaten (Action: Finish Quest)
# 3 = Completed (Passive: Done)
func get_quest_state() -> int:
	var s = QuestManager.burritoQuest_current_state
	
	if s == QuestManager.BurritoQuestState.NOT_STARTED:
		return 0 # Triggers Opening Cutscene -> start_the_quest()
	elif s == QuestManager.BurritoQuestState.ACCEPTED:
		return 1 # Triggers Waiting Cutscene
	elif s == QuestManager.BurritoQuestState.BURRITO_EATEN:
		return 2 # Triggers Closing Cutscene -> finish_the_quest()
	else:
		return 3 # Quest is totally done

# --- 2. DEFINE ACTIONS ---

# This runs when the Opening Cutscene finishes
func start_the_quest():
	print("Quest Giver: You accepted the mission!")
	QuestManager.accept_burritoQuest()

# This runs when the Closing Cutscene finishes (Triggered by F key)
func finish_the_quest():
	print("Quest Giver: Smelled the fart. Quest Complete!")
	QuestManager.completed_burritoQuest()

# This runs immediately after finishing
func trigger_special_ending():
	print("Quest Giver: FART EXPLOSION!")
	# Add particle effects here
	queue_free()
