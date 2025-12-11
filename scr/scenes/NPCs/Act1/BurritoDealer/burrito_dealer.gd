extends CharacterBody2D

# Signal to send to the Quest Manager or UI
signal quest_requested

var player_in_range: bool = false

func _ready() -> void:
	$Area2D.body_entered.connect(_on_area_2d_body_entered)
	$Area2D.body_exited.connect(_on_area_2d_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("ui_accept"):
		start_interaction()

func start_interaction() -> void:
	# 1. CASE: The Quest is Active (The "Happy Path")
	# We need to check if the quest is actually running so we can perform the action
	if QuestManager.burritoQuest_current_state == QuestManager.BurritoQuestState.ACCEPTED:
		print("Ah, you look starving! Here is that special burrito.")
		# Add logic here to actually give the item or advance the quest
		# e.g., QuestManager.advance_quest() 
		
	# 2. CASE: Quest hasn't started yet (Your code)
	elif QuestManager.burritoQuest_current_state == QuestManager.BurritoQuestState.NOT_STARTED: 
		print("I can't sell you this. You don't look hungry enough (Start the quest first).") 
	
	# 3. CASE: Quest is already finished (Your code)
	elif QuestManager.burritoQuest_current_state == QuestManager.BurritoQuestState.BURRITO_EATEN: 
		print("You already ate one! Do you want to explode?")

# ... (Rest of the area enter/exit code stays the same)
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_range = false
