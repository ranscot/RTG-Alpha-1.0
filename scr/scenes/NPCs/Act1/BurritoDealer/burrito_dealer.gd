extends CharacterBody2D

@export var ammo_to_give: int = 10
@export var cooldown_time: float = 5.0

# define exaclty which key in the AmmoManager dictonaru we are adding to 
@export var ammo_type_key: String = "bullet_fart"

var player_in_range = null
var can_give_burrito = true 

@onready var label: Label = $Label
@onready var cooldown_timer: Timer = $CooldownTimer

func _ready() -> void:
	# connect signals for detection
	$TalkingZone.body_entered.connect(_on_TalkingZone_body_entered)
	$TalkingZone.body_exited.connect(_on_TalkingZone_body_exited)
	
	# setup cooldown timer
	cooldown_timer.wait_time = cooldown_time
	cooldown_timer.one_shot = true
	cooldown_timer.connect("timeout", _on_cooldown_finished)
	
	if label:
		label.visible = false
		
		
func _input(event: InputEvent) -> void:
	# check if player pressed "interact" (Space/Enter or "E")
	if event.is_action_pressed("interaction") and player_in_range and can_give_burrito:
		give_burrito()
		
		
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
		
func _on_cooldown_finished():
	can_give_burrito = true
	if player_in_range and label:
		label.text = "Press T for Burrito"
		label.visible = true
		
		
# --- Signal callbacks --- 

func _on_TalkingZone_body_entered(body):
	print("BODY WAS ENTERED FOR BURRITO BOY")
	if body.is_in_group("player"):
		player_in_range = body
		if can_give_burrito and label:
			label.text  = "Press T for Burrito"
			label.visible = true
			
		
func _on_TalkingZone_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = null
		if label:
			label.visible = false
