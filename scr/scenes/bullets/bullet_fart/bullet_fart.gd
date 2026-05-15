extends Area2D

@export var speed: float = 5.0  # Pixels per second
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# This will be set by the scene that creates the bullet
var direction: Vector2 = Vector2.UP

func _ready() -> void:
	animation_player.play("fart_bullet_animation")

func _process(delta: float) -> void:
	# Move the bullet every frame
	direction = Vector2.RIGHT.rotated(rotation)
	global_position += direction * speed * delta

# This function is called when the bullet hits another physics body
func _on_body_entered(body: Node) -> void:
	# You can add logic here to damage the body
	# For example: if body.has_method("take_damage"):
	#     body.take_damage(10)
	print("FART!")
	if body.has_method("take_damage"):
		body.take_damage(10) # We'll create this function on the enemy. 
	# call_deferred("queue_free") # Destroy the bullet on impact after frames calculated


	
	


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
