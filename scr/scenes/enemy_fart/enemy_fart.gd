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

# --- CHANGED: Replaced patrol points with a radius ---
@export var patrol_radius: float = 250.0 # How far to wander

var current_state = State.PATROL
var player = null

## 3. Node references
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea
@onready var animated_sprite = $AnimatedSprite2D
@onready var navigation_agent = $NavigationAgent2D
@onready var patrol_timer = $PatrolTimer # <-- CHANGED

func _ready():
	# --- CHANGED: Connect the timer ---
	patrol_timer.timeout.connect(_on_patrol_timer_timeout)
	
	# We no longer connect navigation_finished
	# We no longer call _go_to_next_patrol_point()
	_pick_new_patrol_target()
	animated_sprite.animation_finished.connect(_on_animation_finished)
	
## The "State Machine"
func _physics_process(delta):
	match current_state:
		State.PATROL:
			patrol_state(delta)
		State.CHASE:
			chase_state(delta)
		State.ATTACK:
			attack_state(delta)
		State.DEATH:
			death_state(delta)
	
	if current_state == State.ATTACK:
		velocity = Vector2.ZERO
		if animated_sprite.animation != "attack":
			animated_sprite.play("attack")
	
	elif current_state == State.DEATH:
		velocity = Vector2.ZERO # Make sure we stop moving
	
	elif not navigation_agent.is_navigation_finished():
		var next_path_pos = navigation_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
			
		if current_state == State.PATROL:
			velocity = direction * patrol_speed
		else: # CHASE
			velocity = direction * speed
			
		_update_animations(direction)
		
	else:
			velocity = Vector2.ZERO
			# --- CHANGED: Play idle when we arrive at a patrol point ---
			if current_state == State.PATROL:
				if animated_sprite.animation != "idle":
					animated_sprite.play("idle")
	
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
	
	
func death_state(delta):
	# This function is called every frame, but we only need to run our "die:
	# logic once. We check the animation to see if its already playing
	if animated_sprite.animation == "death":
		return # We're already playing, just wait
	# -- Stopping logic
	patrol_timer.stop()
	# disable collisions so enemy cannot be hit or block
	$CollisionShape2D.disabled = true
	$DetectionArea.monitoring = false
	$AttackArea.monitoring = false
	 
	# Play the death animation 
	animated_sprite.play("death")



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
	#check if the animation that just finished was the death one
	if animated_sprite.animation == "death":
		if drop_scene:
			var drop = drop_scene.instantiate()
			get_tree().root.add_child(drop)
			drop.global_position = global_position # Spawn it where the enemy died
		queue_free()

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

	health -= amount
	print("Enemy health: ", health)
	
	if health <= 0:
		current_state = State.DEATH
