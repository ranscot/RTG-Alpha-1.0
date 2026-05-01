extends Node

# 1. THE GENERIC QUEST RULES
# Every single quest in the game will use these exact same three states.
enum QuestStatus {
	UNAVAILABLE, # Locked, hasn't been discovered
	ACTIVE,      # Currently in the player's quest log
	COMPLETED    # Finished and crossed off
}

# 2. WORLD STATE (Entity Tracking)
# Kept exactly as you had it! Perfect for tracking specific objects.
enum TruckState {
	FRESH, 
	TOOTED_ONCE,
	TOOTED_TWICE
}
var truck_current_state: TruckState = TruckState.FRESH

enum CloutTrainQuestState {
	NOT_START,
	QUEST_FOR_TONDA,
	CLOUTTRAIN_FROM_TONDA,
	CLOUTTRAIN_COMPLETE
}

# 2. The Variable (This is what the error was looking for!)
# It defaults to NOT_START when the game boots up.
var clout_train_quest_state: CloutTrainQuestState = CloutTrainQuestState.NOT_START


# 3. THE MASTER QUEST DATABASE
# This is the single source of truth for every quest in the game.
# To add a new quest, you just type a new dictionary entry here. No new code needed!
var quest_database = {
	
	"burrito_fart": {
		"title": "The Burrito Fart Quest",
		"description": "I need to find the [color=orange]BacoTell[/color] truck and unleash [b]absolute havoc[/b].",
		"status": QuestStatus.UNAVAILABLE,
		"current_step": 0, 
		"objectives": [
			"Accept the quest.",      # Step 0 to 1
			"Eat the burrito.",       # Step 1 to 2
			"Figure out how to get by NuclearLord."      # Step 2 to 3 (Completed)
		]
	},
	
	"clout_train": {
		"title": "Hype Train",
		"description": "I need to find Tonda and charge my Clout Weapon.",
		"status": QuestStatus.UNAVAILABLE,
		"current_step": 0,
		"objectives": [
			"Talk to Killer Moon.",               # Step 0 to 1
			"Find Tonda at DayTonda Driving.",    # Step 1 to 2
			"Defeat Tonda."                       # Step 2 to 3 (Completed)
		]
	},
	
	
	
	
}

# --- THE GENERIC QUEST ENGINE ---

func start_quest(quest_id: String):
	if quest_database.has(quest_id):
		quest_database[quest_id].status = QuestStatus.ACTIVE
		quest_database[quest_id].current_step = 1
		print("QUEST STARTED: " + quest_database[quest_id].title)

func advance_quest(quest_id: String):
	if quest_database.has(quest_id):
		var quest = quest_database[quest_id]
		
		# Only advance if the quest is actually active
		if quest.status == QuestStatus.ACTIVE:
			quest.current_step += 1
			print(quest.title + " advanced to step: " + str(quest.current_step))
			
			# Check if we just completed the final objective
			if quest.current_step >= quest.objectives.size():
				complete_quest(quest_id)

func complete_quest(quest_id: String):
	if quest_database.has(quest_id):
		quest_database[quest_id].status = QuestStatus.COMPLETED
		print("QUEST COMPLETED: " + quest_database[quest_id].title)


# --- THE UI "WAITER" FUNCTIONS ---
# The QuestLog UI will call these functions to build its visual menus!

func get_all_active_quests() -> Array:
	var active_quests = []
	
	# Loop through the database and hand the UI a list of everything currently active
	for quest_id in quest_database.keys():
		if quest_database[quest_id].status == QuestStatus.ACTIVE:
			# We pass the ID so the UI knows exactly which quest to ask for later
			active_quests.append(quest_id) 
			
	return active_quests

func get_quest_data(quest_id: String) -> Dictionary:
	# The UI asks for a specific quest, we hand it the entire dictionary!
	if quest_database.has(quest_id):
		return quest_database[quest_id]
	return {}
