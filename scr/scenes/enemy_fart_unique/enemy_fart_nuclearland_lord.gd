extends CharacterBody2D

# Assign these in the Inspector
@export var opening_cutscene: PackedScene  # Interaction 1: "Do you want a quest?"
@export var waiting_cutscene: PackedScene  # Interaction 2: "I am still waiting."
@export var closing_cutscene: PackedScene  # Interaction 3: "Press F to Fart"

# State Variables
var player_in_range: bool = false
var active_cutscene_instance = null

func _process(_delta) -> void:
	
	# --- 1. HANDLE INTERACTION (Press T) ---
	# We only start a dialogue if the player is close, no cutscene is open, and they press Interact
	if player_in_range and active_cutscene_instance == null and Input.is_action_just_pressed("interaction"):
		
		print("Quest moving forwards")
		# Scenario A: Quest hasn't started yet
		if QuestManager.burritoQuest_current_state == QuestManager.BurritoQuestState.NOT_STARTED:
			start_cutscene()
			
		# Scenario B: Quest is accepted, waiting for burrito
		elif QuestManager.burritoQuest_current_state == QuestManager.BurritoQuestState.ACCEPTED:
			start_awaiting_cutscene()
			
		# Scenario C: Player has the burrito (Ready to Fart)
		elif QuestManager.burritoQuest_current_state == QuestManager.BurritoQuestState.BURRITO_EATEN:
			start_closing_cutscene()

	# --- 2. HANDLE FART FINISH (Press F) ---
	# Only allow this if the cutscene is open AND we are in the correct state
	if active_cutscene_instance != null and Input.is_action_just_pressed("fire"):
		if QuestManager.burritoQuest_current_state == QuestManager.BurritoQuestState.BURRITO_EATEN:
			trigger_fart_ending()

# --- CUTSCENE FUNCTIONS ---

func start_cutscene():
	active_cutscene_instance = opening_cutscene.instantiate()
	get_tree().root.add_child(active_cutscene_instance)
	
#  We now wait for the standard 'finished' signal
	if active_cutscene_instance.has_signal("finished"):
		await active_cutscene_instance.finished
	
	# AUTOMATIC ACCEPTANCE
	# Since there is no "No" button, we assume if they finished reading, they accepted.
	print("Dialogue finished - Quest Started")
	QuestManager.accept_burritoQuest()
	
	# Cleanup
	if is_instance_valid(active_cutscene_instance):
		active_cutscene_instance.queue_free()
	active_cutscene_instance = null
	
func start_awaiting_cutscene():
	active_cutscene_instance = waiting_cutscene.instantiate()
	get_tree().root.add_child(active_cutscene_instance)

	# This uses the standard "finished" signal from BaseDialogueCutscene
	if active_cutscene_instance.has_signal("finished"):
		await active_cutscene_instance.finished
		
	# --- FIX: TYPO CORRECTED HERE ---
	if is_instance_valid(active_cutscene_instance):
		active_cutscene_instance.queue_free()
	active_cutscene_instance = null

func start_closing_cutscene():
# We don't await this one, because we are waiting for the 'F' key event
	active_cutscene_instance = closing_cutscene.instantiate()
	get_tree().root.add_child(active_cutscene_instance)

func trigger_fart_ending():
	print("FART ATTACK INITIATED")
	
	# 1. Close the UI
	if active_cutscene_instance:
		active_cutscene_instance.queue_free()
	active_cutscene_instance = null
		
		
	# 2. Update Quest State
	QuestManager.burritoQuest_current_state = QuestManager.BurritoQuestState.COMPLETED
	
	# 3. Handle NPC Death/Flight
	# Add explosion effect or animation code here
	queue_free() # Removes the NPC from the game

# --- SIGNAL CONNECTIONS ---

func _on_quest_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"): # Ensure this matches your Player node name
		player_in_range = true

func _on_quest_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		# Optional: Close cutscene if player walks away
		if active_cutscene_instance != null:
			active_cutscene_instance.queue_free()
			active_cutscene_instance = null
