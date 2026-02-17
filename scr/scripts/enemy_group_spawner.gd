extends Node2D

# --- CONFIGURATION ---
@export_group("Spawn Settings")
@export var enemy_scene: PackedScene 
@export var count_per_node: int = 1 
@export var patrol_radius: float = 300.0 

# --- IDENTITY ---
@export_group("Identity")
@export var name_database: EnemyNameData # The "Master List" (Resource)

# --- VISUALS ---
@export_group("Visuals")
@export var possible_variants: Array[EnemyVariant] 

@export_group("Navigation")
@export_flags_2d_navigation var nav_layer_mask: int = 1 

# Internal variable to track unused names (The "Deck of Cards")
var _session_name_pool: Array[String] = []

func _ready():
	# Wait one physics frame so the Navigation Server is ready
	await NavigationServer2D.map_changed
	spawn_all()

func spawn_all():
	if not enemy_scene:
		print("Error: No Enemy Scene assigned to ", name)
		return

	# 1. INITIALIZE THE POOL
	# We duplicate the list so we can remove names without deleting them from the file!
	if name_database and name_database.names.size() > 0:
		_refill_name_pool()

	# 2. SPAWN EVERYONE
	# We loop through every child node (Markers and Rects)
	for child in get_children():
		if child is Marker2D:
			_spawn_cluster(child)
		elif child is ReferenceRect:
			_spawn_scatter(child)

# --- HELPER: Refills the deck when empty ---
func _refill_name_pool():
	_session_name_pool = name_database.names.duplicate()
	_session_name_pool.shuffle() # Randomize the order

# --- STRATEGY A: CLUSTER (Tight Squads) ---
func _spawn_cluster(marker: Marker2D):
	for i in range(count_per_node):
		# Random offset so they don't stack perfectly on one pixel
		var offset = Vector2(randf_range(-40, 40), randf_range(-40, 40))
		var pos = marker.global_position + offset
		
		# Home Base is the Marker itself
		_create_enemy(pos, marker.global_position)

# --- STRATEGY B: SCATTER (Wide Area with Safety Snap) ---
func _spawn_scatter(rect: ReferenceRect):
	# Get the World ID so we can ask the Server for help
	var map = get_world_2d().get_navigation_map()
	
	for i in range(count_per_node):
		# 1. Blind Guess inside the box
		var random_x = randf_range(0, rect.size.x)
		var random_y = randf_range(0, rect.size.y)
		var guess_pos = rect.global_position + Vector2(random_x, random_y)
		
		# 2. SAFETY SNAP (The Pro Move)
		# Snaps the point to the nearest valid floor. 
		var safe_pos = NavigationServer2D.map_get_closest_point(map, guess_pos)
		
		# Home Base is just where they spawned (they wander from there)
		# Note: We pass 'safe_pos' twice because for scattered enemies, 
		# their "Home" is just the spot where they appeared.
		_create_enemy(safe_pos, safe_pos)

# --- THE FACTORY ---
func _create_enemy(spawn_pos: Vector2, home_pos: Vector2):
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(enemy)
	
	enemy.global_position = spawn_pos
	
	# --- UNIQUE NAME LOGIC ---
	var assigned_name = "Enemy"
	
	# Check if we have a database
	if name_database:
		# If we ran out of unique names, refill the bag!
		if _session_name_pool.is_empty():
			_refill_name_pool()
		
		# Take the last name off the list (Removes it so it can't be picked again)
		assigned_name = _session_name_pool.pop_back()
	
	# INJECT ORDERS (Name, Logic, Layers)
	# This requires your enemy script to have the 'setup_enemy' function!
	if enemy.has_method("setup_enemy"):
		enemy.call_deferred("setup_enemy", home_pos, patrol_radius, nav_layer_mask, assigned_name)
	
	# INJECT VISUALS
	# This requires your enemy script to have the 'apply_variant' function!
	if possible_variants.size() > 0 and enemy.has_method("apply_variant"):
		var random_pick = possible_variants.pick_random()
		enemy.call_deferred("apply_variant", random_pick)
