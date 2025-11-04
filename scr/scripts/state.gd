# state.gd
# This is our abstract base class for all states.
class_name State
extends Node

# We'll get a reference to the player and state machine.
var character: CharacterBody2D
var state_machine

func _ready() -> void:
	# Wait for the parent (the StateMachine) to be ready.
	await get_parent().ready
	# The StateMachine's parent is any parent that is a CharacterBody2D.
	character = get_parent().get_parent()
	state_machine = get_parent()


# Virtual functions that we'll override in our other state scripts.
func enter() -> void:
	pass # Logic to run when we enter this state.

func exit() -> void:
	pass # Logic to run when we exit this state.

func process_input(_event: InputEvent) -> void:
	pass # For handling input events.

func process_frame(_delta: float) -> void:
	pass # For frame-by-frame logic (_process).

func process_physics(_delta: float) -> void:
	pass # For physics-based logic (_physics_process).
