# enemy_idle_state.gd
extends State

func enter() -> void:
	character.animated_sprite.play("idle")
