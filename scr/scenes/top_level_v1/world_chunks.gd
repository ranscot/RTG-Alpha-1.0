extends Node2D

# QA Array to track active chunks
var active_chunks: Array[String] = []

func _ready():
	for chunk in get_children():
		var trigger_zone = chunk.get_node_or_null("Area2D")
		if trigger_zone:
			trigger_zone.area_entered.connect(_on_chunk_entered.bind(chunk))
			trigger_zone.area_exited.connect(_on_chunk_exited.bind(chunk))
			_sleep_chunk(chunk)
		else:
			print("Warning: ", chunk.name, " is missing its Area2D trigger zone.")

func _on_chunk_entered(_area: Area2D, chunk: Node2D):
	_wake_chunk(chunk)

func _on_chunk_exited(_area: Area2D, chunk: Node2D):
	_sleep_chunk(chunk)

func _wake_chunk(chunk: Node2D):
	for child in chunk.get_children():
		if child.name != "Area2D":
			child.process_mode = Node.PROCESS_MODE_INHERIT
			child.show()
	
	if not active_chunks.has(chunk.name):
		active_chunks.append(chunk.name)
	print("☀ WOKE UP: ", chunk.name, " | Currently Active: ", active_chunks)
	
	# Godot's built-in recursive trigger. It will find the spawner script 
	# no matter how deep it is inside the chunk folders.
	chunk.propagate_call("spawn_all")

# --- NEW HELPER FUNCTION ---
func _search_and_spawn(current_node: Node):
	# Look at every single child of the current node
	for child in current_node.get_children():
		# If this specific child has the script attached, trigger it
		if child.has_method("spawn_all"):
			print("🎯 FOUND SPAWNER: ", child.name, " inside ", current_node.name)
			child.spawn_all()
		
		# Recursively dig deeper into this child to check its children
		_search_and_spawn(child)

func _sleep_chunk(chunk: Node2D):
	for child in chunk.get_children():
		if child.name != "Area2D":
			child.process_mode = Node.PROCESS_MODE_DISABLED
			child.hide()
			
	if active_chunks.has(chunk.name):
		active_chunks.erase(chunk.name)
	print("💤 ASLEEP: ", chunk.name, " | Currently Active: ", active_chunks)
