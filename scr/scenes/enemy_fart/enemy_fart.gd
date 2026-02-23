extends CharacterBody2D

## 1. Define all possible states
enum State {
	PATROL,
	CHASE,
	ATTACK,
	DEATH
}

## 2. Variables
@export var speed: float = 100.0
@export var patrol_speed: float = 60.0
@export var attack_range: float = 50.0
@export var health: int = 50
# set the drop scene
@export var drop_scene: PackedScene

@export var patrol_radius: float = 250.0 # How far to wander

var current_state = State.PATROL
var player = null
var is_dying: bool = false
# Optional: Keep track of where we spawned so we don't wander off the map
@onready var home_position: Vector2 = global_position 

## 3. Node references
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea
@onready var animated_sprite = $AnimatedSprite2D
@onready var navigation_agent = $NavigationAgent2D
@onready var patrol_timer = $PatrolTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var death_sound_player: AudioStreamPlayer2D = $DeathSoundPlayer
@onready var hit_sound_player: AudioStreamPlayer2D = $HitSoundPlayer

func _ready():
	# Safety Wait
	# We must wait for the Navigation Server to sync the map befor asking for a path
	# this prevents "Navigation map query failed" error on spawn 
	await get_tree().physics_frame
	
	# Await Critical Connections
	# makes sure the defined avoidance function is connected 
	# navigation_agent.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	
	# set home if not set externally
	if home_position == Vector2.ZERO:
		home_position = global_position
	
	# Connect the timer
	patrol_timer.timeout.connect(_on_patrol_timer_timeout)
	# animated_sprite.animation_finished.connect(_on_animation_finished)
	
	# Start patrolling immediately
	_pick_new_patrol_target()
	
# Call this function immeditately after .instantiate() to assign a specific zone
func setup_patrol(target_zone_center: Vector2, patrol_size: float):
	home_position = target_zone_center
	patrol_radius = patrol_size
	
func _physics_process(delta):
	# 1. Run State Logic
	match current_state:
		State.PATROL:
			patrol_state(delta)
		State.CHASE:
			chase_state(delta)
		State.ATTACK:
			attack_state(delta)
		State.DEATH:
			death_state(delta)

	# 2. CALCULATE INTENDED VELOCITY
	var intended_velocity = Vector2.ZERO
	
	if current_state == State.ATTACK or current_state == State.DEATH:
		intended_velocity = Vector2.ZERO
		# Start attack animation if not already playing
		if current_state == State.ATTACK and animated_sprite.animation != "attack":
			animated_sprite.play("attack")
			
	elif not navigation_agent.is_navigation_finished():
		var next_path_pos = navigation_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		
		# Apply logic for speed based on state
		var current_speed = speed
		if current_state == State.PATROL:
			current_speed = patrol_speed
			
		# Chase Distance Check
		if current_state == State.CHASE:
			# If we are close enough to attack, stop moving (prevents jitter)
			if global_position.distance_to(player.global_position) > 40.0:
				intended_velocity = direction * current_speed
			else:
				intended_velocity = Vector2.ZERO
		else:
			# Normal movement for Patrol
			intended_velocity = direction * current_speed
			
		# Update animations
		if intended_velocity.length() > 0:
			_update_animations(direction)
		elif current_state == State.PATROL:
			animated_sprite.play("idle")

	# 3. SEND VELOCITY TO AGENT
	# if Avoidance is on, we send the velocity to the agent
	# if Avoidance is off, we move immediately 
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(intended_velocity)
	else: 
		_on_navigation_agent_2d_velocity_computed(intended_velocity)

# --- SIGNAL CALLBACK: Avoidance ---
func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	if current_state == State.DEATH: return
	
	velocity = safe_velocity
	move_and_slide()

# --- State Logic Functions ---

func patrol_state(_delta):
	if current_state != State.PATROL: return
	
	if player != null:
		current_state = State.CHASE
		return

func chase_state(_delta):
	if current_state != State.CHASE: return
	
	if player:
		navigation_agent.set_target_position(player.global_position)
	else:
		current_state = State.PATROL

func attack_state(_delta):
	if current_state != State.ATTACK: return
	# Note: Actual damage dealing should happen here or via Animation Method Track
	# print("ATTACKING PLAYER!")

func death_state(_delta):
	# 1. THE LOCK: If we are already dying, ignore all future frames
	if is_dying:
		return 
		
	is_dying = true # Lock the door! 
	
	# 2. Stopping logic
	velocity = Vector2.ZERO
	patrol_timer.stop()
	
	# Disable collisions and areas safely
	$CollisionShape2D.set_deferred("disabled", true)
	$DetectionArea.set_deferred("monitoring", false)
	$AttackArea.set_deferred("monitoring", false)
	
	# Play sound
	if death_sound_player:
		death_sound_player.play()
	
	# 3. SAFETY CHECK & ANIMATION
	if animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.play("death")
		await animated_sprite.animation_finished
	else:
		print("Warning: No 'death' animation found for ", name)
		# Wait half a second so the death sound can finish playing
		await get_tree().create_timer(0.5).timeout
		
	# 4. SPAWN LOOT
	if drop_scene:
		var drop = drop_scene.instantiate()
		# current_scene is generally safer than root for pausing/scene changes
		get_tree().current_scene.add_child(drop)
		drop.global_position = global_position
		
	# 5. GOODBYE
	queue_free()

## --- Helper Functions ---

func _update_animations(direction: Vector2):
	animated_sprite.flip_h = false
	var new_anim = "" 

	if abs(direction.x) > abs(direction.y):
		if direction.x < 0:
			new_anim = "walk_left"   
		else:
			new_anim = "walk_right" 
	else:
		if direction.y < 0:
			new_anim = "walk_up"  
		else:
			new_anim = "walk_down" 
	
	if animated_sprite.animation != new_anim:
		animated_sprite.play(new_anim)

## --- Signal Callbacks ---

func _on_detection_area_body_entered(body):
	if current_state == State.DEATH: return
	
	if body.is_in_group("player"):
		player = body
		patrol_timer.stop() 

func _on_detection_area_body_exited(body):
	if current_state == State.DEATH: return
	
	if body.is_in_group("player"):
		player = null
		current_state = State.PATROL
		patrol_timer.start()
		_pick_new_patrol_target()

func _on_attack_area_body_entered(body):
	if current_state == State.DEATH: return
	
	if body.is_in_group("player"):
		current_state = State.ATTACK
		patrol_timer.stop()

func _on_attack_area_body_exited(body):
	if current_state == State.DEATH: return
	
	if body.is_in_group("player"):
		# If player leaves attack range but is still detected, Chase
		if player != null:
			current_state = State.CHASE
			patrol_timer.stop()

func _on_animation_finished():
	pass

func _on_patrol_timer_timeout():
	if current_state == State.DEATH: return
	
	if current_state == State.PATROL:
		_pick_new_patrol_target()

func _pick_new_patrol_target():
	var random_direction = Vector2.from_angle(randf_range(0, 2 * PI))
	var random_distance = randf_range(0, patrol_radius)
	
	# Use home_position to prevent drifting across the entire map
	var target_position = home_position + (random_direction * random_distance)
	navigation_agent.set_target_position(target_position)

func take_damage(amount: int):
	if current_state == State.DEATH:
		return
	
	animation_player.play("Hit_Flash")
	hit_sound_player.play()
	health -= amount
	# print("Enemy health: ", health)
	
	if health <= 0:
		current_state = State.DEATH

# --- SPAWNER CONFIGURATION ---
# This function is called by the Spawner immediately after creation
func setup_enemy(home_pos: Vector2, patrol_range: float, nav_layers: int, new_name: String = ""):
	# 1. Store the Patrol Data
	home_position = home_pos
	patrol_radius = patrol_range
	
	# 2. Set the Navigation Layer (Park vs Street)
	# (Make sure your node is actually named 'NavigationAgent2D')
	if has_node("NavigationAgent2D"):
		$NavigationAgent2D.navigation_layers = nav_layers
	
	# 3. Apply the Name Label
	# (Make sure you added a Label node named 'LabelName' to your scene!)
	if has_node("LabelName") and new_name != "":
		$LabelName.text = new_name
	
	# 4. Kickstart the Logic
	# If the enemy was idle, this forces them to pick a target immediately
	if has_method("_pick_new_patrol_target"):
		_pick_new_patrol_target()

# --- VISUAL VARIATION ---
# This function applies the specific look (SpriteFrames)
func apply_variant(variant_data: EnemyVariant):
	# 1. Override the Name (Optional, if the Variant has a specific name like "Boss")
	# If the variant name is empty, we keep the random name we just got.
	if variant_data.name_text != "" and has_node("LabelName"):
		$LabelName.text = variant_data.name_text

	# 2. Swap the Animation Set (The Costume)
	# (Make sure your node is actually named 'AnimatedSprite2D')
	if has_node("AnimatedSprite2D") and variant_data.animation_set:
		var anim_sprite = $AnimatedSprite2D
		anim_sprite.sprite_frames = variant_data.animation_set
		
		# CRITICAL: Play an animation immediately so it doesn't disappear
		# Ensure ALL your variants have an animation with this exact name!
		if anim_sprite.sprite_frames.has_animation("idle"):
			anim_sprite.play("idle")
		elif anim_sprite.sprite_frames.has_animation("default"):
			anim_sprite.play("default")
