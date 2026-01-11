extends CharacterBody2D

# Signal to send to the Quest Manager or UI
signal quest_requested


# --- EXPORT VARIABLES (The cutscenes depending on State)
@export_group("Cutscenes")
@export var cutscene_quest_accepted: PackedScene
@export var cutscene_quest_not_started: PackedScene
@export var cutscene_quest_already_eaten: PackedScene
@export var cutscene_quest_completed: PackedScene

# --- SET VARIABLES
var player_in_range: bool = false
var is_cutscene_playing: bool = false


@onready var talking_zone: Area2D = $TalkingZone


func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interaction") and not is_cutscene_playing:
		start_interaction()

func start_interaction() -> void:
	# 1. NOT STARTED (You have this hooked up!)
	if QuestManager.burritoQuest_current_state == QuestManager.BurritoQuestState.NOT_STARTED: 
		await play_scene_cutscene(cutscene_quest_not_started)

	# 2. ACCEPTED (Needs to give item)
	elif QuestManager.burritoQuest_current_state == QuestManager.BurritoQuestState.ACCEPTED:
		await play_scene_cutscene(cutscene_quest_accepted)
		# CRITICAL: After the cutscene, give the item!
		print("Giving the burrito to the player...")
		# Example: Inventory.add_item("Burrito")
		# Example: QuestManager.burritoQuest_current_state = QuestManager.BurritoQuestState.BURRITO_RECEIVED
		
		# Update the manager state
		QuestManager.eat_burrito() # Sets state to Burrito_Eatn
		
		# give ammo
		AmmoManager.add_ammo("bullet_fart", 10)
		
		
	# 3. ALREADY EATEN (Funny dialogue)
	elif QuestManager.burritoQuest_current_state == QuestManager.BurritoQuestState.BURRITO_EATEN: 
		await play_scene_cutscene(cutscene_quest_already_eaten)

	# 4. COMPLETED (The new state - maybe for "Thanks for eating at my shop")
	elif QuestManager.burritoQuest_current_state == QuestManager.BurritoQuestState.COMPLETED:
		await play_scene_cutscene(cutscene_quest_completed)

# --- this plays the passed cutscene from Start Interaction
func play_scene_cutscene(scene_to_play: PackedScene) -> void:
	if scene_to_play == null:
		print("Error: No cutscene assigned for this state - BurritoDealer")
		return
		
	is_cutscene_playing = true
	
	# A. Lock the Player (Using the new variable)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_cutscene_locked = true  # <--- CHANGED THIS
	
	# B. Spawn the Cutscene
	var cutscene_instance = scene_to_play.instantiate()
	get_tree().root.add_child(cutscene_instance)
	
	# C. Wait for the cutscene to finish
	if cutscene_instance.has_signal("finished"):
		await cutscene_instance.finished
	else:
		await get_tree().create_timer(2.0).timeout
		
	# D. Cleanup
	if is_instance_valid(cutscene_instance):
		cutscene_instance.queue_free()

	await get_tree().create_timer(0.5).timeout

	# E. Unlock Player
	if player:
		player.is_cutscene_locked = false # <--- CHANGED THIS
		
	is_cutscene_playing = false
	
