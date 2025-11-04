# state_machine.gd
extends Node

@export var initial_state: State

var current_state: State

func _ready() -> void:
	await get_tree().process_frame
	
	current_state = initial_state
	current_state.enter()

func change_state(new_state: State) -> void:
	if new_state == current_state:
		return

	current_state.exit()
	current_state = new_state
	current_state.enter()

# We pass Godot's built-in functions down to the current state.
func _input(event: InputEvent) -> void:
	# NEW: Check if current_state is valid before using it.
	if not current_state:
		return
	current_state.process_input(event)

func _process(delta: float) -> void:
	# NEW: Add the same check here for safety.
	if not current_state:
		return
	current_state.process_frame(delta)

func _physics_process(delta: float) -> void:
	# NEW: And here as well.
	if not current_state:
		return
	current_state.process_physics(delta)
