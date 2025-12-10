# QuestManager.gd
extends Node

# Define our states
enum BurritoQuestState {
	NOT_STARTED,
	ACCEPTED,
	BURRITO_EATEN, # The FART State is Ready
	COMPLETED
}

# Current State Variable for BurritoQuest
var burritoQuest_current_state: BurritoQuestState = BurritoQuestState.NOT_STARTED

func accept_burritoQuest():
	burritoQuest_current_state = BurritoQuestState.ACCEPTED
	print("QUEST BURRITO ACCEPTED")
	
	
func eat_burrito():
	if burritoQuest_current_state == BurritoQuestState.ACCEPTED:
		burritoQuest_current_state = BurritoQuestState.BURRITO_EATEN
		print("QUEST BURRITO EATEN")
		
		
func completed_burritoQuest():
	burritoQuest_current_state = BurritoQuestState.COMPLETED
	print("QUEST BURRITO COMPLETED")
