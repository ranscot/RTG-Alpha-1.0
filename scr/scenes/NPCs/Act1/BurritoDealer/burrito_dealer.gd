extends CharacterBody2D

# --- Configuration ---
@export var ammo_to_give: int = 10
@export var cooldown_time: float = 5.0
# define exactly which key in the AmmoManager dictonaru we are adding to 
@export var ammo_type_key: String = "bullet_fart"

# --- Cutscene Resource ---
var cutscene_scene = preload("res://scr/scenes/cutscenes/act1/burritodealer/burrito_cutscene.tscn")

# --- Start Variables 
var player_in_range = null
var can_give_burrito = true 
var is_talking: bool = false # to prevent delta spam while talking

# --- Node References ---
@onready var label: Label = $Label
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var talking_zone: Area2D = $TalkingZone

func _ready() -> void:
	# connect signals for detection
	$TalkingZone.body_entered.connect(_on_TalkingZone_body_entered)
	$TalkingZone.body_exited.connect(_on_TalkingZone_body_exited)
	
	# 1. Setup cooldown timer
	cooldown_timer.wait_time = cooldown_time
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_finished)
		
	if label:
		label.visible = false 
		
		
func _input(event: InputEvent) -> void:
	# check if player pressed "interact" (Space/Enter or "E")
	if event.is_action_pressed("interaction") and player_in_range and can_give_burrito and not is_talking:
		start_conversation()
		
		
func start_conversation():
	print("Starting conversation")
	is_talking = true
	
	if label:
		label.visible = false
		
	# instantiate and add the cutscene
	var cutscene_instance = cutscene_scene.instantiate()
	get_tree().root.add_child(cutscene_instance)
		
	# listen for the cutscene is done
	cutscene_instance.cutscene_finished.connect(_on_cutscene_ended)
	
	
func _on_cutscene_ended():
	print("Conversation is over. giving rewards")
	is_talking = false
	
	give_burrito()	
# -- Reward Logic ---

func give_burrito():
	print("Burrito BlaST GIVEN")
	
	# 1. -- Intregrate with the Ammo Manager
	# Call the "add_ammo" function in Ammo Manager
	AmmoManager.add_ammo(ammo_type_key, ammo_to_give)
	
	# 2. Start cooldown
	can_give_burrito = false
	cooldown_timer.start()
	
	# 3. Visual Feedback
	if label:
		label.text = "EATING AT BACO TELL "
		label.visible = true
		
func _on_cooldown_finished():
	can_give_burrito = true
	if player_in_range and label:
		label.text = "Press T for Burrito"
		label.visible = true
		
		
# --- Signal callbacks --- 

func _on_TalkingZone_body_entered(body: Node2D) -> void:
	print("BODY WAS ENTERED FOR BURRITO BOY")
	if body.is_in_group("player"):
		player_in_range = body
		if can_give_burrito and label:
			label.text = "Press T for Burrito"
			label.visible = true


func _on_TalkingZone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = null
		if label:
			label.visible = false
