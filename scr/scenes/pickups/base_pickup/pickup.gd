# pickup.gd
extends Area2D

# We use an enum to define all the possible types of pickups.
enum PickupType { LASER_AMMO, GRENADE_AMMO, COIN }

# We can choose the type of this pickup in the Inspector.
@export var type: PickupType

# You can set the amount for ammo pickups in the Inspector.
@export var amount: int = 10

func _on_body_entered(body: Node) -> void:
	# Check if the body that entered is the player.
	if not body.is_in_group("player"):
		return
	
	# Based on the type, call the correct function on the AmmoManager.
	match type:
		PickupType.LASER_AMMO:
			AmmoManager.add_ammo("laser", amount)
		PickupType.GRENADE_AMMO:
			AmmoManager.add_ammo("grenade", amount)
		PickupType.COIN:
			AmmoManager.add_coins(1) # Coins are usually picked up one at a time
	
	# Destroy the pickup after it's been collected.
	call_deferred("queue_free") # after frames calculated
