extends CharacterBody2D

@export var opening_cutscene: PackedScene # this is the first dialogue with questGiver
@export var closing_cutscene: PackedScene # this is the first dialogue with questGiver
@export var waiting_cutscene: PackedScene # this is the first dialogue with questGiver

# Set Variables 
var player_in_range: bool = false
var active_cutscene_instance = null

func _process(_delta) -> void:
	# 1. Handle starting the interaction (Press T)
	if player_in_range and active_cutscene_instance == null and Input.is_action_just_pressed("interaction"):
		if QuestManager.burritoQuest_current_state == QuestManager.BurritoQuestState.NOT_STARTED:
			start_cutscene()
	if player_in_range and active_cutscene_instance == null and Input.is_action_just_pressed("interaction"):
		if QuestManager.burritoQuest_current_state == QuestManager.BurritoQuestState.NOT_STARTED:
			awaiting_cutscene()
			
	# 2, Gabdke Fart Finish 
	if active_cutscene_instance != null and Input.is_action_just_pressed("fire"):
		if QuestManager.burritoQuest_current_state == QuestManager.BurritoQuestState.BURRITO_EATEN:
			trigger_fart_ending()
			
	
func start_cutscene():
	# Instantiate the cutscene
	active_cutscene_instance = opening_cutscene.instantiate()
	
	# add it to the scene tree
	get_tree().root.add_child(active_cutscene_instance)
	
	
func awaiting_cutscene():
	# Instantiate the cutscene
	active_cutscene_instance = opening_cutscene.instantiate()
	
	# add it to the scene tree
	get_tree().root.add_child(active_cutscene_instance)
	
func trigger_fart_ending():
	# Instantiate the cutscene
	active_cutscene_instance = opening_cutscene.instantiate()
	
	# add it to the scene tree
	get_tree().root.add_child(active_cutscene_instance)

	


func _on_quest_detection_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_quest_detection_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
