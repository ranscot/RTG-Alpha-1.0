extends CharacterBody2D
class_name BaseQuestGiver

# --- EXPORTS ---
@export_group("Cutscenes")
@export var opening_cutscene: PackedScene 
@export var waiting_cutscene: PackedScene 
@export var closing_cutscene: PackedScene 

# --- INTERNAL STATE ---
var player_in_range: bool = false
var active_cutscene_instance = null
var is_interacting_cooldown: bool = false 

# --- VIRTUAL FUNCTIONS ---
func get_quest_state():
	return 0 
	
func start_the_quest():
	print("Base class: Quest Started")

func finish_the_quest():
	print("Base class: Quest Finished")

func trigger_special_ending():
	queue_free()

# --- NEW HELPER: PLAYER LOCKING ---
func set_player_lock(is_locked: bool) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Assuming your Player script has this variable!
		player.is_cutscene_locked = is_locked

# --- MAIN LOGIC LOOP ---
func _process(_delta) -> void:
	# Handle Interaction (T)
	if player_in_range and active_cutscene_instance == null and not is_interacting_cooldown and Input.is_action_just_pressed("interaction"):
		
		var current_state = get_quest_state()
		
		if current_state == 0: # NOT STARTED / ACTION
			_play_scene_and_start(opening_cutscene)
			
		elif current_state == 1: # ACCEPTED / PASSIVE
			_play_scene_standard(waiting_cutscene)
			
		elif current_state == 2: # READY TO FINISH
			set_player_lock(true) # <--- NEW: Lock immediately
			active_cutscene_instance = closing_cutscene.instantiate()
			get_tree().root.add_child(active_cutscene_instance)

	# Handle Ending Trigger (F key)
	if active_cutscene_instance != null and Input.is_action_just_pressed("fire"):
		if get_quest_state() == 2: # READY TO FINISH
			finish_the_quest()
			trigger_special_ending()
			
			set_player_lock(false) # <--- NEW: Unlock after explosion
			
			if active_cutscene_instance:
				active_cutscene_instance.queue_free()

# --- HELPER FUNCTIONS ---
func _play_scene_and_start(scene_to_load):
	if scene_to_load:
		set_player_lock(true) # <--- NEW: Lock before playing
		
		active_cutscene_instance = scene_to_load.instantiate()
		get_tree().root.add_child(active_cutscene_instance)
		
		if active_cutscene_instance.has_signal("finished"):
			await active_cutscene_instance.finished
		
		start_the_quest() 
		cleanup_interaction()

func _play_scene_standard(scene_to_load):
	if scene_to_load:
		set_player_lock(true) # <--- NEW: Lock before playing
		
		active_cutscene_instance = scene_to_load.instantiate()
		get_tree().root.add_child(active_cutscene_instance)
		
		if active_cutscene_instance.has_signal("finished"):
			await active_cutscene_instance.finished
			
		cleanup_interaction()

func cleanup_interaction():
	is_interacting_cooldown = true
	
	set_player_lock(false) # <--- NEW: Unlock when scene is done
	
	if is_instance_valid(active_cutscene_instance):
		active_cutscene_instance.queue_free()
	active_cutscene_instance = null
	await get_tree().create_timer(0.5).timeout 
	is_interacting_cooldown = false

# --- SIGNALS ---
func _on_quest_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_quest_detection_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
