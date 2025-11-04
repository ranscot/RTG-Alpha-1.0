# idle_state.gd
extends State

func enter() -> void:
	# When entering the idle state, play the idle animation.
	character.animated_sprite.play("idle")
	# Stop movement from the previous state.
	character.velocity = Vector2.ZERO

func process_physics(_delta: float) -> void:
	# If the player provides movement input...
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		# ...transition to the Walk state.
		state_machine.change_state(state_machine.get_node("Walk"))
