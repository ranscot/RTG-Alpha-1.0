extends CharacterBody2D

# --- Signals and Exports ---
# We don't need this signal, we will spawn the bullet directly.
# signal shoot(bullet_scene, direction, location) 

@export var bullet_fart: PackedScene
@export var bullet_cloat: PackedScene
@export var bullet_engage: PackedScene
@export var speed: float = 300.0
@export var max_health: float = 100.0
var health: float

# an array of enemies inside of the DamageArea
var enemies_in_area: Array = []

# --- Node References ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $ProgressBar
@onready var death_timer: Timer = $timers/DeathTimer
@onready var state_machine: Node = $StateMachine
@onready var muzzle: Marker2D = $Muzzle # <-- ADD THIS
@onready var damage_area: Area2D = $DamageArea
@onready var damage_timer: Timer = $DamageTimer

# --- Properties ---
# We rename this so it's clear what it's for.
var facing_direction: Vector2 = Vector2.DOWN # <-- RENAMED

# --- Built-in Godot Functions ---
func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	
	# Add this check to make sure the Muzzle exists
	if not muzzle:
		print("ERROR: Player script needs a Marker2D node named 'Muzzle'.")
		
	# checks every second for damage
	damage_timer.timeout.connect(_on_damage_timer_timeout)
	damage_area.body_entered.connect(_on_damage_area_body_entered)
	damage_area.body_exited.connect(_on_damage_area_body_exited)
	
	

func _input(event: InputEvent) -> void:
	# --- THIS IS THE SHOOTING FIX ---
	# We've removed "var muzzle = $Muzzle" because it's an @onready var now
	# We've removed "var fire_direction = ..."
	
	# Check with the AmmoManager and spawn bullet directly. 
	# 1, Act is "fire_fart"
	# 2. Ammo key is "bullet_fart"
	if event.is_action_pressed("fire"):

		if bullet_fart and AmmoManager.use_ammo("bullet_fart"):
			_spawn_bullet(bullet_fart) # <-- CHANGED

	if event.is_action_pressed("fire_secondary"):
		if bullet_cloat and AmmoManager.use_ammo("bullet_clout"):
			_spawn_bullet(bullet_cloat) # <-- CHANGED 
  
	if event.is_action_pressed("fire_tertiary"):
		if bullet_engage and AmmoManager.use_ammo("bullet_engage"):
			_spawn_bullet(bullet_engage) # <-- CHANGED

# --- Custom Functions ---

# --- ADD THIS NEW FUNCTION ---
func _spawn_bullet(bullet_scene: PackedScene):
	print("fire fart")
	if not muzzle: return # Don't spawn if muzzle is missing
		
	# Create an instance of the bullet
	var bullet = bullet_scene.instantiate()
	
	# Set its position and rotation from the muzzle
	bullet.global_position = muzzle.global_position
	# The bullet script will move forward based on its rotation
	bullet.rotation = facing_direction.angle() 
	
	# Add the bullet to the main game world
	get_tree().root.add_child(bullet)
# --- END NEW FUNCTION ---


func take_damage(amount: float) -> void:
	# (Your take_damage function is perfect, no changes needed)
	if health <= 0:
		return
	
	health -= amount
	health = clamp(health, 0, max_health)

	health_bar.value = health
	
	if health <= 0:
		print("Player has died!")
		state_machine.process_mode = PROCESS_MODE_DISABLED
		$CollisionShape2D.set_deferred("disabled", true)
		death_timer.start()

func _on_death_timer_timeout() -> void:
	queue_free()

# this function is called every 1 second by the DamageTime
func _on_damage_timer_timeout() -> void:
	print("Enemies in list: ", enemies_in_area.size())
	# loop through our list of enemies
	for enemy in enemies_in_area:
		#take 1 dagage for each enemy
		take_damage(1)
		
# Called by the DamageArea's 'body-entered" signal
func _on_damage_area_body_entered(body):
# This will print the exact name of *what* touched the player
	
	if body.is_in_group("overworld_enemies"):
		if not enemies_in_area.has(body):
			enemies_in_area.append(body)
			# Use an array [] for multiple values
			print("--- Added %s to list. List size: %s" % [body.name, enemies_in_area.size()])
	else:
		# This will tell us if it's the wrong group
		print("--- FAILURE: %s is NOT in the group." % body.name)
			
			
# called by the DamageArea's 'body-entered" signal
func _on_damage_area_body_exited(body):
	# Check if its an enemy
	if body.is_in_group("overworld_enemies"):
		# remove from our list
		if enemies_in_area.has(body):
			enemies_in_area.erase(body)
