# walk_state.gd
extends State

func process_physics(_delta: float) -> void:
	# If the player stops moving...
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction == Vector2.ZERO:
		# ...transition to the Idle state.
		state_machine.change_state(state_machine.get_node("Idle"))
		return

	# Otherwise, apply movement logic.
	character.velocity = direction * character.speed
	
	# Use 'direction', not 'input_direction'
	character.facing_direction = direction.normalized()
	
	character.move_and_slide()
	update_animation()

func update_animation() -> void:
	if abs(character.velocity.x) > abs(character.velocity.y):
		if character.velocity.x > 0:
			play_animation("walk_right")
		else:
			play_animation("walk_left")
	else:
		if character.velocity.y > 0:
			play_animation("walk_down")
		else:
			play_animation("walk_up")

func play_animation(anim_name: String) -> void:
	if character.animated_sprite.animation != anim_name:
		character.animated_sprite.play(anim_name)
