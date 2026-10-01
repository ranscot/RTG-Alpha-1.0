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
	# Loop through all children of the chunk (Area2D, Scenery, Spawners)
	for child in chunk.get_children():
		# Wake up everything EXCEPT the trigger zone (which never sleeps)
		if child.name != "Area2D":
			child.process_mode = Node.PROCESS_MODE_INHERIT
			child.show()
	
	if not active_chunks.has(chunk.name):
		active_chunks.append(chunk.name)
	print("☀ WOKE UP: ", chunk.name, " | Currently Active: ", active_chunks)

func _sleep_chunk(chunk: Node2D):
	for child in chunk.get_children():
		if child.name != "Area2D":
			child.process_mode = Node.PROCESS_MODE_DISABLED
			child.hide()
			
	if active_chunks.has(chunk.name):
		active_chunks.erase(chunk.name)
	print("💤 ASLEEP: ", chunk.name, " | Currently Active: ", active_chunks)
