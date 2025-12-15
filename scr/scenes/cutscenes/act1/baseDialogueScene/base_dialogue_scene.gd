extends Node

class_name BaseDialogueCutscene

signal finished

# --- CONFIGURATION ---
# The input action name you set in Project Settings (or check key code directly)
const INPUT_ACTION = "interaction" 

# --- UI NODES ---
@onready var player_group = $CanvasLayer/DialogueControl/Panel/PlayerGroup
@onready var player_portrait = $CanvasLayer/DialogueControl/Panel/PlayerGroup/PlayerPortrait
@onready var player_label = $CanvasLayer/DialogueControl/Panel/PlayerGroup/PlayerText

@onready var npc_group = $CanvasLayer/DialogueControl/Panel/NPCGroup
@onready var npc_portrait = $CanvasLayer/DialogueControl/Panel/NPCGroup/NPCPortrait
@onready var npc_label = $CanvasLayer/DialogueControl/Panel/NPCGroup/NPCText

# --- STATE ---
var dialogue_data: Array = []
var current_line_index: int = -1

func _ready() -> void:
	# Ensure UI is hidden at start until data loads
	player_group.visible = false
	npc_group.visible = false
	
	# If the child script defined dialogue in _ready, start it now.
	# Use call_deferred to ensure the child's _ready runs first.
	call_deferred("start_dialogue")

func _unhandled_input(event: InputEvent) -> void:
	# Check for "T" press
	if event.is_action_pressed(INPUT_ACTION):
		advance_dialogue()

func start_dialogue() -> void:
	if dialogue_data.is_empty():
		print("Warning: Dialogue Array is empty. Ending immediately.")
		end_cutscene()
		return
		
	advance_dialogue()

func advance_dialogue() -> void:
	current_line_index += 1
	
	# CHECK: Have we reached the end?
	if current_line_index >= dialogue_data.size():
		end_cutscene()
		return
	
	# GET DATA: Current line
	var line_data = dialogue_data[current_line_index]
	display_line(line_data)

func display_line(data: Dictionary) -> void:
	var speaker = data.get("speaker", "npc") # Default to npc if missing
	var text = data.get("text", "...")
	var texture = data.get("texture", null) # Optional: pass a loaded texture resource
	
	# 1. Reset Visibility
	player_group.visible = false
	npc_group.visible = false
	
	# 2. Update the active speaker
	if speaker == "player":
		player_group.visible = true
		player_label.text = text
		if texture: player_portrait.texture = texture
		
	else: # NPC
		npc_group.visible = true
		npc_label.text = text
		if texture: npc_portrait.texture = texture

func end_cutscene() -> void:
	# Hide everything
	player_group.visible = false
	npc_group.visible = false
	
	emit_signal("finished")
	queue_free()
