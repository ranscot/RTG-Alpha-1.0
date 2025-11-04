# enemy_hurt_state.gd
extends State

@onready var hurt_timer = Timer.new()

func _ready() -> void:
	super()
	add_child(hurt_timer)
	hurt_timer.one_shot = true
	hurt_timer.timeout.connect(on_hurt_timer_timeout)

func enter() -> void:
	character.animated_sprite.play("hurt")
	hurt_timer.start(0.5) # Stay in hurt state for 0.5 seconds

func on_hurt_timer_timeout() -> void:
	# After being hurt, go back to chasing the player.
	state_machine.change_state(state_machine.get_node("Walk"))
