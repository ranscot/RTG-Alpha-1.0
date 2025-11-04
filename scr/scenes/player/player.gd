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
@onready var animated_sprite = $AnimatedSprite2D
@onready var health_bar = $ProgressBar

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

	if event.is_action_pressed("fire"):
		if bullet_scene:
			shoot.emit(bullet_scene, fire_direction, muzzle.global_position)

	if event.is_action_pressed("fire_secondary"):
		if laser_scene:
			shoot.emit(laser_scene, fire_direction, muzzle.global_position)

	if event.is_action_pressed("fire_tertiary"):
		if grenade_scene:
			shoot.emit(grenade_scene, fire_direction, muzzle.global_position)

# --- Custom Functions ---
func take_damage(amount: float) -> void:
	if health <= 0:
		return
	
	# --- Start of Debug Block ---
	print("--- Taking Damage ---")
	print("Health before damage: {health}")
	print("ProgressBar value before update: {health_bar.value}")
	
	health -= amount
	health = clamp(health, 0, max_health)
	health_bar.value = health
	
	print("Health after damage: {health}")
	print("ProgressBar value after update: {health_bar.value}")
	print("--------------------")
	# --- End of Debug Block ---

	if health <= 0:
		print("Player has died!")
		
		self.process_mode = PROCESS_MODE_DISABLED
		$CollisionShape2D.set_deferred("disabled", true)
		
		await get_tree().create_timer(1.0).timeout
		
		queue_free()
