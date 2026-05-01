extends Resource
class_name ChatterData

# The master ID (e.g., "killer_moon")
@export var id: String 

@export var name: String
@export_multiline var bio: String
@export var weakness: String

# We export a Texture2D so you can literally drag and drop the image in the editor!
@export var avatar: Texture2D 

# The current state
@export var is_unlocked: bool = false
