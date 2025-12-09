extends CharacterBody2D

# --- Signals and Exports ---
# We don't need this signal, we will spawn the bullet directly.
# signal shoot(bullet_scene, direction, location) 

@export var bullet_fart: PackedScene
@export var bullet_clout: PackedScene
@export var bullet_engage: PackedScene
@export var speed: float = 300.0
@export var max_health: float = 100.0
var health: float

# for rotating engage weapon
# The higher this number, the faster it snaps. 
# 10.0 is snappy, 3.0 is heavy/slow.
@export var rotation_speed: float = 10.0

# an array of enemies inside of the DamageArea
var enemies_in_area: Array = []

# --- Node References ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $ProgressBar
@onready var death_timer: Timer = $DeathTimer
@onready var state_machine: Node = $StateMachine
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var clout_weapon_muzzle: Marker2D = $WeaponPivot/CloutWeapon_Muzzle
@onready var fart_weapon_muzzle: Marker2D = $WeaponPivot/Muzzle
@onready var engage_weapon_muzzle: Marker2D = $WeaponPivot/EngageWeapon_Muzzle
@onready var damage_area: Area2D = $DamageArea
@onready var damage_timer: Timer = $DamageTimer
@onready var fart_weapon_shoot: AudioStreamPlayer2D = $Sounds/Fart_Weapon_Shoot
@onready var clout_weapon_shoot: AudioStreamPlayer2D = $Sounds/Clout_Weapon_Shoot
@onready var engage_weapon_shoot: AudioStreamPlayer2D = $Sounds/Engage_Weapon_Shoot

@onready var engage_cone: Area2D = $WeaponPivot/EngageCone
@onready var cone_visuals: Sprite2D = $WeaponPivot/EngageCone/Sprite2D
@onready var cone_damage_timer: Timer = $WeaponPivot/EngageCone/ConeDamageTimer

# accumulator for ammo drain ( so we dont drain 60 ammo per second)
var ammo_drain_timer: float = 0.0

# --- Properties ---
# We rename this so it's clear what it's for.
var facing_direction: Vector2 = Vector2.DOWN # <-- RENAMED

# --- Built-in Godot Functions ---
func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	
	# Add this check to make sure the Muzzle exists
	if not fart_weapon_muzzle or clout_weapon_muzzle or engage_weapon_muzzle:
		print("ERROR: Player script needs a Marker2D node named 'Muzzle'.")
		
	# checks every second for damage
	damage_timer.timeout.connect(_on_damage_timer_timeout)
	damage_area.body_entered.connect(_on_damage_area_body_entered)
	damage_area.body_exited.connect(_on_damage_area_body_exited)
	
	# connect the timer that deals the damage ticks 
	cone_damage_timer.timeout.connect(_on_cone_damage_timer_timeout)
	
	# Ensure engagement cone starts invisible and disabled
	engage_cone.monitoring = false
	cone_visuals.visible = false
	
	
func _physics_process(delta: float) -> void:


	# 2. AIMING - ROTATE THE PIVOT
	# This rotates the parent, carrying all muzzles around the player
# 2. AIMING - ROTATE THE PIVOT
	if weapon_pivot:
		var target_angle = facing_direction.angle()
		
		# lerp_angle automatically handles the "wrap around" 
		# (like going from 359 degrees to 1 degree) so it doesn't spin the long way.
		weapon_pivot.rotation = lerp_angle(weapon_pivot.rotation, target_angle, rotation_speed * delta)
	
	# new engage weapon logic 
	handle_engage_weapon(delta)
 	
		
func _input(event: InputEvent) -> void:
	# --- THIS IS THE SHOOTING FIX ---
	# We've removed "var muzzle = $Muzzle" because it's an @onready var now
	# We've removed "var fire_direction = ..."
	
	# Check with the AmmoManager and spawn bullet directly. 
	# 1, Act is "fire_fart"
	# 2. Ammo key is "bullet_fart"
	if event.is_action_pressed("fire"):

		if bullet_fart and AmmoManager.use_ammo("bullet_fart"):
			fart_weapon_shoot.play()
			_spawn_bullet(bullet_fart, fart_weapon_muzzle) # <-- CHANGED

	if event.is_action_pressed("fire_secondary"):

		if bullet_clout and AmmoManager.use_ammo("bullet_clout"):
			print("CLOUT FIRE")
			clout_weapon_shoot.play()
			_spawn_bullet(bullet_clout, clout_weapon_muzzle) # <-- CHANGED 
  
#	if event.is_action_pressed("fire_tertiary"):
#		if bullet_engage and AmmoManager.use_ammo("bullet_engage"):
#			_spawn_bullet(bullet_engage, engage_weapon_muzzle) # <-- CHANGED

# --- Custom Functions ---
func handle_engage_weapon(delta):
	# 1. check if holding button AND has ammo
	if Input.is_action_pressed("fire_tertiary") and AmmoManager.get_ammo_count("bullet_engage") > 0:
		# turn ON the weapon
		
		print("Engage Weapon Active!")

		if not engage_cone.monitoring:
			engage_cone.monitoring = true
			cone_visuals.visible = true
			engage_cone.visible = true
			cone_damage_timer.start() # start the damage ticks on enemy
			engage_weapon_shoot.play()
		# Drain ammo over time ( 1 ammo every .1 seconds)
		ammo_drain_timer += delta
		if ammo_drain_timer >= 0.1:
			ammo_drain_timer = 0.0
			AmmoManager.use_ammo("bullet_engage")	
			
	else:
		# turn OFF the weapon
		if engage_cone.monitoring:
			engage_cone.monitoring = false
			cone_visuals.visible = false
			cone_damage_timer.stop()
			engage_weapon_shoot.stop()
			
func _on_cone_damage_timer_timeout():
	# get everything currently inside the cone
	var bodies = engage_cone.get_overlapping_bodies()
	
	# --- ADD THIS DEBUG LINE ---
	print("Cone hit count: %s" % bodies.size())
	
	for body in bodies:
		# check if its has health logic 
		if body.has_method("take_damage") and body.is_in_group("overworld_enemies"):
			# deal damage!
			body.take_damage(100)
			print("engaged Damaged ")
			
# --- ADD THIS NEW FUNCTION ---
func _spawn_bullet(bullet_scene: PackedScene, which_muzzle: Marker2D):
	if not which_muzzle: return # Don't spawn if muzzle is missing
		
	# Create an instance of the bullet
	var bullet = bullet_scene.instantiate()
	
	# Setting the muzzle for the weapon type
	bullet.global_position = which_muzzle.global_position
	# Setting the rotation based on player direction 
	bullet.rotation = which_muzzle.global_rotation
	
		
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
