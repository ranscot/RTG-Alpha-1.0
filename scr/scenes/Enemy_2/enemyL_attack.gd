# enemy_attack_state.gd
extends State

# This function runs the moment we switch to the Attack state.
func enter() -> void:
	# Stop all movement
	character.velocity = Vector2.ZERO
	
	# Play the attack animation. Make sure you have one named "attack"!
	character.animated_sprite.play("attack")
	
	# Connect to the animation_finished signal to know when to transition back
	character.animated_sprite.animation_finished.connect(_on_animation_finished)
	
	# --- Deal Damage and Start Cooldown ---
	# Ensure the player is still in range before dealing damage
	var distance_to_player = character.global_position.distance_to(character.player.global_position)
	if distance_to_player <= character.stopping_distance:
		character.player.take_damage(10)
		
	# Prevent another immediate attack and start the cooldown timer
	character.can_attack = false
	character.attack_cooldown_timer.start()


func process_physics(_delta: float) -> void:
	# If the player moves out of range during the attack animation...
	var distance_to_player = character.global_position.distance_to(character.player.global_position)
	if distance_to_player > character.stopping_distance:
		# ...immediately go back to chasing them.
		state_machine.change_state(state_machine.get_node("Walk"))

# This function runs when we leave the Attack state.
func exit() -> void:
	# Disconnect the signal to prevent it from firing when not in this state
	if character.animated_sprite.is_connected("animation_finished", _on_animation_finished):
		character.animated_sprite.animation_finished.disconnect(_on_animation_finished)

# This function is called when any animation on the enemy finishes.
func _on_animation_finished() -> void:
	# We only care if the "attack" animation finished.
	if character.animated_sprite.animation == "attack":
		# Transition back to the Walk state to chase the player again.
		state_machine.change_state(state_machine.get_node("Walk"))
