extends Node

class_name BaseDialogueCutscene

signal finished

# --- CONFIGURATION ---
# The input action name you set in Project Settings (or check key code directly)
const INPUT_ACTION = "interaction" 

# --- UI NODES ---

@onready var player_group: HBoxContainer = $CanvasLayer/DialogueControl/Panel/PlayerGroup
@onready var player_portrait: TextureRect = $CanvasLayer/DialogueControl/Panel/PlayerGroup/PlayerPortrait
@onready var player_name_label: Label = $CanvasLayer/DialogueControl/Panel/PlayerGroup/PlayerTextPadding/PlayerTextColumn/PlayerName
@onready var player_text: RichTextLabel = $CanvasLayer/DialogueControl/Panel/PlayerGroup/PlayerTextPadding/PlayerTextColumn/PlayerText

@onready var npc_group: HBoxContainer = $CanvasLayer/DialogueControl/Panel/NPCGroup
@onready var npc_portrait: TextureRect = $CanvasLayer/DialogueControl/Panel/NPCGroup/NPCPortrait
@onready var npc_text: RichTextLabel = $CanvasLayer/DialogueControl/Panel/NPCGroup/NPCTextPadding/NPCTextColumn/NPCText
@onready var npc_name_label: Label = $CanvasLayer/DialogueControl/Panel/NPCGroup/NPCTextPadding/NPCTextColumn/NPCNameLabel

# --- STATE ---
#--- Replaced old Arry variable with an Export Resource Array 
@export var dialogue_timeline: Array[DialogueItem]
@export var chatter_id: String = ""

var current_line_index: int = -1

func _ready() -> void:
	# Ensure UI is hidden at start until data loads
	player_group.visible = false
	npc_group.visible = false
	# Check if this enemy actually has a Chatiary profile
	if chatter_id != "":
		ChatiaryManager.unlock_chatter(chatter_id)
	# --- we dont need call_defferred because the data is loaded in Inspector 
	start_dialogue()
	
func _unhandled_input(event: InputEvent) -> void:
	# Check for "T" press
	if event.is_action_pressed(INPUT_ACTION):
		advance_dialogue()

func start_dialogue() -> void:
	if dialogue_timeline.is_empty():
		print("Warning: Dialogue Timeline in Inspector is empty. Ending immediately.")
		end_cutscene()
		return
		
	advance_dialogue()

func advance_dialogue() -> void:
	current_line_index += 1
	
	# CHECK: Have we reached the end?
	if current_line_index >= dialogue_timeline.size():
		end_cutscene()
		return
	
	# GET DATA: Current line
	var line_data = dialogue_timeline[current_line_index]
	display_line(line_data)

func display_line(item: DialogueItem) -> void:
	# --- Read the properties from Form in Inspector	
	var speaker = item.speaker
	var text = item.text
	var texture = item.portrait
	var display_name = item.character_name
	
	# 1. Reset Visibility
	player_group.visible = false
	npc_group.visible = false
	
	# 2. Update the active speaker
	if speaker == "player":
		player_group.visible = true
		player_text.text = text
		player_name_label.text = display_name
		if texture: player_portrait.texture = texture
		
	else: # NPC
		npc_group.visible = true
		npc_text.text = text
		npc_name_label.text = display_name
		if texture: npc_portrait.texture = texture

func end_cutscene() -> void:
	# Hide everything
	player_group.visible = false
	npc_group.visible = false
	
	emit_signal("finished")
	queue_free()
