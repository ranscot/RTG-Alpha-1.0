# player.gd
extends CharacterBody2D

# --- Signals and Exports ---
signal shoot(bullet_scene, direction, location)

@export var bullet_fart: PackedScene
@export var bullet_cloat: PackedScene
@export var bullet_engage: PackedScene
@export var speed: float = 300.0

@export var max_health: float = 100.0
var health: float

# --- Node References ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $ProgressBar
@onready var death_timer: Timer = $timers/DeathTimer
@onready var state_machine: Node = $StateMachine

# --- Properties ---
var last_move_direction: Vector2 = Vector2.DOWN

# --- Built-in Godot Functions ---
func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health

func _input(event: InputEvent) -> void:
	var muzzle = $Muzzle
	var fire_direction = last_move_direction

	# We now check with the AmmoManager BEFORE emitting the signal.
	if event.is_action_pressed("fire"):
		if bullet_fart and AmmoManager.use_ammo("bullet_fart"):
			shoot.emit(bullet_fart, fire_direction, muzzle.global_position)

	if event.is_action_pressed("fire_secondary"):
		if bullet_cloat and AmmoManager.use_ammo("bullet_cloat"):
			shoot.emit(bullet_cloat, fire_direction, muzzle.global_position)

	if event.is_action_pressed("fire_tertiary"):
		if bullet_engage and AmmoManager.use_ammo("bullet_engage"):
			shoot.emit(bullet_engage, fire_direction, muzzle.global_position)

# --- Custom Functions ---
func take_damage(amount: float) -> void:

	if health <= 0:
		return
	
	health -= amount
	health = clamp(health, 0, max_health)

	health_bar.value = health
	print(health_bar)
	
	if health <= 0:
		print("Player has died!")
	# Instead of disabling self, we disable the StateMachine.
		state_machine.process_mode = PROCESS_MODE_DISABLED
		$CollisionShape2D.set_deferred("disabled", true)
		
		# Instead of awaiting, we just start the timer
		death_timer.start()

# This new function is called by the DeathTimer's timeout signal
func _on_death_timer_timeout() -> void:
	# The queue_free() call is now here
	queue_free()
