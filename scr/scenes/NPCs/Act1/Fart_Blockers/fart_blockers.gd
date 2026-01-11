extends BaseQuestGiver

# --- EXPORTS ---
@export_group("Combat Stats")
@export var max_health: int = 21
@export var drop_scene: PackedScene
@export var damage_cooldown: float = 0.5 # <--- NEW: How long they are safe after a hit

@export_group("Health Based Cutscenes")
@export var scene_full_health: PackedScene
@export var scene_hurt: PackedScene
@export var scene_near_death: PackedScene

# --- INTERNAL VARIABLES ---
var health: int 
var is_invincible: bool = false # <--- NEW: The Gatekeeper

@onready var hit_sound: AudioStreamPlayer2D = $HitSoundPlayer
@onready var death_sound: AudioStreamPlayer2D = $DeathSoundPlayer
@onready var anim_player: AnimationPlayer = $AnimationPlayer 

func _ready() -> void:
	health = max_health
	print("NPC Spawned. Health: ", health)

func get_quest_state() -> int:
	var percent = float(health) / float(max_health)
	
	if percent > 0.66:
		waiting_cutscene = scene_full_health
		return 1 
	elif percent > 0.33:
		waiting_cutscene = scene_hurt
		return 1 
	else:
		waiting_cutscene = scene_near_death
		return 1

# --- UPDATED DAMAGE LOGIC ---
func take_damage(amount: int):
	# 1. GATEKEEPER CHECK
	if is_invincible:
		return # Stop reading here. Don't take damage.
		
	# 2. APPLY DAMAGE
	if anim_player and anim_player.has_animation("Hit_Flash"):
		anim_player.play("Hit_Flash")
	
	if hit_sound:
		hit_sound.play()
		
	health -= amount
	print("NPC Hit! Health: ", health)
	
	if health <= 0:
		die()
		return # If dead, don't start the timer

	# 3. START COOLDOWN (The Logic)
	is_invincible = true
	
	# Create a temporary timer in code (no node needed)
	await get_tree().create_timer(damage_cooldown).timeout
	
	# Check if we still exist (in case we died during the wait)
	if is_inside_tree():
		is_invincible = false
		# Optional: print("NPC vulnerable again")

func die():
	print("NPC Died!")
	# ... (Death logic stays the same) ...
	if death_sound: death_sound.play()
	if drop_scene:
		var drop = drop_scene.instantiate()
		get_tree().root.add_child(drop)
		drop.global_position = global_position
	queue_free()
