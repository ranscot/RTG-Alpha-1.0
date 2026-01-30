extends BaseQuestGiver

# --- EXPORTS ---
@export_group("Quest Scenes")
@export var scene_assign_quest: PackedScene  # "Go see Tondagossa, he knows about Clout."
@export var scene_reminder: PackedScene      # "He is over by the bar. Go!"
@export var scene_post_quest: PackedScene    # "I see you got that Clout Train working."

func get_quest_state() -> int:
	var s = QuestManager.clout_train_quest_state
	
	if s == QuestManager.CloutTrainQuestState.NOT_STARTED:
		opening_cutscene = scene_assign_quest
		return 0 # ACTION MODE (Run start_the_quest)
		
	elif s == QuestManager.CloutTrainQuestState.STARTED:
		waiting_cutscene = scene_reminder
		return 1 # PASSIVE MODE
		
	else:
		waiting_cutscene = scene_post_quest
		return 1 # PASSIVE MODE

func start_the_quest():
	# This runs after the "Go see Tondagossa" movie finishes
	QuestManager.start_clout_train_quest()
