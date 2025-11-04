# enemy_walk_state.gd
extends State

func enter() -> void:
#	character.animated_sprite.play("walk")
	pass
	
func process_physics(_delta: float) -> void:
	if not character.player:
		state_machine.change_state(state_machine.get_node("Idle"))
		return

	var distance_to_player = character.global_position.distance_to(character.player.global_position)
	
	# Check if we are close enough AND ready to attack
	if distance_to_player <= character.stopping_distance and character.can_attack:
		state_machine.change_state(state_machine.get_node("Attack"))
		return # Stop further execution in this frame
	
	# If we are outside the stopping distance, move towards the player.
	if distance_to_player > character.stopping_distance:
		var direction = character.global_position.direction_to(character.player.global_position)
		character.velocity = direction * character.speed
		character.move_and_slide()
	# If we are close but on cooldown, just stop.
	else:
		character.velocity = Vector2.ZERO
	# Call our function to update the animation based on velocity
	update_animation()

# --- New Functions Below ---

# This function determines which animation to play.
func update_animation() -> void:
	# If the enemy stopped, we can either go idle or just show a static frame.
	# For simplicity, we'll let the Idle state handle the idle animation.
	if character.velocity.length() == 0:
		return

	# We check which axis has the greater movement.
	if abs(character.velocity.x) > abs(character.velocity.y):
		# Moving more horizontally
		if character.velocity.x > 0:
			play_animation("walk_right")
		else:
			play_animation("walk_left")
	else:
		# Moving more vertically
		if character.velocity.y > 0:
			play_animation("walk_down")
		else:
			play_animation("walk_up")

# This helper function prevents restarting the animation on every frame.
func play_animation(anim_name: String) -> void:
	if character.animated_sprite.animation != anim_name:
		character.animated_sprite.play(anim_name)
