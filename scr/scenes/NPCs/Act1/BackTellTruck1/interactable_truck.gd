extends BaseQuestGiver

# --- Export
@export_group("Toots Scenes")
@export var scene_first_toot: PackedScene
@export var scene_second_toot: PackedScene
@export var scene_final_toot: PackedScene

# Logic Mapping
func get_quest_state() -> int:
	var s = QuestManager.truck_current_state
	
	# we return action mode 0 - Give Ammo + farts
	if s == QuestManager.TruckState.FRESH:
		opening_cutscene = scene_first_toot
		return 0 
		
	elif s == QuestManager.TruckState.TOOTED_ONCE:
		opening_cutscene = scene_second_toot
		return 0
		
	else:
		opening_cutscene = scene_final_toot
		return 0
		
		
func start_the_quest():
	print("Truck; Dispensing Fart Ammo")
	
	#1. Give Ammo
	if AmmoManager:
		AmmoManager.add_ammo("bullet_fart", 10)
		
	#2. Update the state
	if QuestManager.truck_current_state == QuestManager.TruckState.FRESH:
		QuestManager.truck_current_state = QuestManager.TruckState.TOOTED_ONCE
		
	elif QuestManager.truck_current_state == QuestManager.TruckState.TOOTED_ONCE:
		QuestManager.truck_current_state = QuestManager.TruckState.TOOTED_TWICE
		
		
# UNUSED
func finish_the_quest():
	pass
	
func trigger_special_ending():
	pass
	
