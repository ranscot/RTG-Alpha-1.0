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
@export var health: int = 200

# set the drop scene
@export var drop_scene: PackedScene

# --- CHANGED: Replaced patrol points with a radius ---
var home_position: Vector2 = Vector2.ZERO
var patrol_radius: float = 300.0 # How far to wander

var current_state = State.PATROL
var player = null
var is_dying: bool = false

## 3. Node references
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var patrol_timer = $PatrolTimer # <-- CHANGED

@onready var on_death_sound: AudioStreamPlayer2D = $Sounds/On_death
@onready var on_hurt_sound: AudioStreamPlayer2D = $Sounds/On_hurt


func _ready():
	# --- CHANGED: Connect the timer ---
	patrol_timer.timeout.connect(_on_patrol_timer_timeout)
	
	# We no longer connect navigation_finished
	# We no longer call _go_to_next_patrol_point()
	_pick_new_patrol_target()
	# animated_sprite.animation_finished.connect(_on_animation_finished) - can be used for attack animations
	
## The "State Machine"
func _physics_process(delta):
	# 1. Run State Logic (Decides Intent)
	match current_state:
		State.PATROL:
			patrol_state(delta)
		State.CHASE:
			chase_state(delta)
		State.ATTACK:
			attack_state(delta)
		State.DEATH:
			death_state(delta)

	# 2. CALCULATE INTENDED VELOCITY (But do NOT move yet)
	var intended_velocity = Vector2.ZERO
	
	if current_state == State.ATTACK or current_state == State.DEATH:
		intended_velocity = Vector2.ZERO
		if current_state == State.ATTACK and animated_sprite.animation != "attack":
			animated_sprite.play("attack")
			
	elif not navigation_agent.is_navigation_finished():
		var next_path_pos = navigation_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		
		# Apply logic for speed based on state
		var current_speed = speed
		if current_state == State.PATROL:
			current_speed = patrol_speed
			
		# --- CHASE DISTANCE CHECK (From our previous fix) ---
		if current_state == State.CHASE:
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
	# Instead of moving, we tell the agent: "I want to go this fast."
	# The agent will calculate avoidance and then call the signal below.
	navigation_agent.set_velocity(intended_velocity)


# --- NEW SIGNAL CALLBACK ---
# This function is called automatically by the NavigationAgent
# once it has calculated a safe path around other enemies.
func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	if current_state == State.DEATH: return
	
	# Apply the safe velocity calculated by the avoidance algorithm
	velocity = safe_velocity
	move_and_slide()

# --- State Logic Functions ---

func patrol_state(_delta):
	# Check for Death State, basically if not Patrol return out
	if current_state != State.PATROL: return
	
	# Check for player (transition to CHASE)
	if player != null:
		current_state = State.CHASE
		return
	
	# --- CHANGED: All logic is now handled by the timer ---
	# We just wait for the timer to tell us to move.

func chase_state(_delta):
	# Check for Death State, basically if not Chase return out
	if current_state != State.CHASE: return
	
	if player:
		# Constantly update the agent's target to the player's position
		navigation_agent.set_target_position(player.global_position)
	else:
		# Player got away, go back to patrolling
		current_state = State.PATROL

func attack_state(_delta):
	# Check for Death State, basically if not Attack return out
	if current_state != State.ATTACK: return
	
	print("ATTACKING PLAYER!")
	
	
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
	if on_death_sound:
		on_death_sound.play()
	
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

# --- REMOVED: _go_to_next_patrol_point() ---

func _update_animations(direction: Vector2):
	# (This function is unchanged)
	animated_sprite.flip_h = false 
	var new_anim = "" # Variable to hold the new animation name

	# Decide which animation *should* be playing
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
	
	# --- THIS IS THE FIX ---
	# Only call .play() if the new animation is different
	# from the one currently playing.
	if animated_sprite.animation != new_anim:
		animated_sprite.play(new_anim)
## --- Signal Callbacks ---

func _on_detection_area_body_entered(body):
	if current_state == State.DEATH: return
	
	if body.is_in_group("player"):
		player = body
		patrol_timer.stop() # <-- CHANGED: Stop timer while chasing

func _on_detection_area_body_exited(body):
	if current_state == State.DEATH: return
	
	if body.is_in_group("player"):
		player = null
		current_state = State.PATROL
		patrol_timer.start() # <-- CHANGED: Restart timer
		_pick_new_patrol_target() # <-- CHANGED: Find a new spot now

func _on_attack_area_body_entered(body):
	if current_state == State.DEATH: return
	
	if body.is_in_group("player"):
		current_state = State.ATTACK
		patrol_timer.stop() # <-- CHANGED: Stop timer while attacking

func _on_attack_area_body_exited(body):
	if current_state == State.DEATH: return
	
	if body.is_in_group("player"):
		if player != null:
			current_state = State.CHASE
			patrol_timer.stop() # <-- CHANGED: Keep timer stopped

func _on_animation_finished():
	pass
	# can be used to attack animations 

# --- REMOVED: _on_navigation_finished() ---

# --- NEW FUNCTION: Called by the PatrolTimer ---
func _on_patrol_timer_timeout():
	if current_state == State.DEATH: return
	
	# If we are patrolling, pick a new random target
	if current_state == State.PATROL:
		_pick_new_patrol_target()

# --- NEW FUNCTION: Finds a random spot ---
func _pick_new_patrol_target():
	# Generate a random direction and distance
	var random_direction = Vector2.from_angle(randf_range(0, 2 * PI))
	var random_distance = randf_range(0, patrol_radius)
	
	# Calculate the new target position
	var target_position = global_position + (random_direction * random_distance)
	
	# Set the agent's target
	navigation_agent.set_target_position(target_position)

# --- NEW FUNCTION: Calculates damage and Death State ---
func take_damage(amount: int):
	# Don't take damage if already dead
	if current_state == State.DEATH:
		return

	on_hurt_sound.play()
	health -= amount
	print("Enemy health: ", health)
	
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


func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	# 1. Wake the brain back up
	set_physics_process(true)
	
	# 2. Throw them back into the Avoidance calculations
	if has_node("NavigationAgent2D"):
		$NavigationAgent2D.avoidance_enabled = true



func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
		# 1. Put the enemy's brain to sleep
	set_physics_process(false)
	
	# 2. Pull them out of the Avoidance mosh pit (Saves massive CPU)
	if has_node("NavigationAgent2D"):
		$NavigationAgent2D.avoidance_enabled = false
	
