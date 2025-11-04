# player.gd
extends CharacterBody2D

# --- Signals and Exports ---
signal shoot(bullet_scene, direction, location)

@export var bullet_scene: PackedScene
@export var laser_scene: PackedScene
@export var grenade_scene: PackedScene
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
		if bullet_scene and AmmoManager.use_ammo("standard"):
			shoot.emit(bullet_scene, fire_direction, muzzle.global_position)

	if event.is_action_pressed("fire_secondary"):
		if laser_scene and AmmoManager.use_ammo("laser"):
			shoot.emit(laser_scene, fire_direction, muzzle.global_position)

	if event.is_action_pressed("fire_tertiary"):
		if grenade_scene and AmmoManager.use_ammo("grenade"):
			shoot.emit(grenade_scene, fire_direction, muzzle.global_position)

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
