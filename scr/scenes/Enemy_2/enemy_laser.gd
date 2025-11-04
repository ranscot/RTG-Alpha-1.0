# enemy.gd
extends CharacterBody2D

@export var speed: float = 90.0
@export var health: int = 30
@export var stopping_distance: float = 40.0 # To stop moving when it gets close enough to the player
@export var drop_pickup_scene: PackedScene

# We need a reference to the player to chase them.
var player: CharacterBody2D

@onready var state_machine = $StateMachine
@onready var animated_sprite = $AnimatedSprite2D

# Attack cooldown logic
var can_attack: bool = true
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer

func _ready() -> void:
	# Find the player in the scene tree. Make sure your player node has been added to a group called "player".
	player = get_tree().get_first_node_in_group("player")

# This is the function our standard bullet calls.
func take_damage(amount: int) -> void:
	health -= amount
	state_machine.change_state(state_machine.get_node("Hurt"))

	if health <= 0:
		if drop_pickup_scene:
			var pickup_instance = drop_pickup_scene.instantiate()
			get_parent().call_deferred("add_child", pickup_instance)
			pickup_instance.global_position = self.global_position

		call_deferred("queue_free")

# This function is connected to the DetectionRadius's "body_entered" signal.
func _on_detection_radius_body_entered(body: Node) -> void:
	# If the player enters our detection radius, start walking towards them.

	if body == player:
		state_machine.change_state(state_machine.get_node("Walk"))


# NEW: This function is called when the cooldown timer finishes
func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true # Allow the enemy to attack again


func _on_detection_radius_body_exited(body: Node2D) -> void:
# First, check if the body that left is the player.
	if body == player:
		# If so, tell the state machine to go back to the Idle state.
		state_machine.change_state(state_machine.get_node("Idle"))
