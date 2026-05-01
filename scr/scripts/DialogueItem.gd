extends Resource
class_name DialogueItem

# --- This script defines ONE Box of text
@export var character_name: String = ""
@export_enum("player", "npc") var speaker: String = "npc"
@export_multiline var text: String = ""
@export var portrait: Texture2D
