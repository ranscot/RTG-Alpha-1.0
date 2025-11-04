# ammo_manager.gd
extends Node

# Signal to notify the UI when any ammo count changes.
signal ammo_changed(ammo_type: String, new_count: int)
signal coins_changed(new_count: int)

# The dictionary to store our ammo counts.
var ammo_counts: Dictionary = {
	"standard": 150,
	"laser": 50,
	"grenade": 10
}
var coin_count: int = 0


# This function lets other scripts ask if a shot can be fired.
# If there is enough ammo, it reduces the count and returns true.
func use_ammo(ammo_type: String) -> bool:
	if ammo_counts.has(ammo_type) and ammo_counts[ammo_type] > 0:
		ammo_counts[ammo_type] -= 1
		ammo_changed.emit(ammo_type, ammo_counts[ammo_type])
		return true
	else:
		# Optionally, you could play an "empty clip" sound here.
		print("Out of {ammo_type} ammo!")
		return false

# This lets other scripts (like the UI) get the current count without changing it.
func get_ammo_count(ammo_type: String) -> int:
	if ammo_counts.has(ammo_type):
		return ammo_counts[ammo_type]
	return 0

# We can use this later for ammo pickups.
func add_ammo(ammo_type: String, amount: int) -> void:
	if ammo_counts.has(ammo_type):
		ammo_counts[ammo_type] += amount
		ammo_changed.emit(ammo_type, ammo_counts[ammo_type])


func add_coins(amount: int) -> void:
	coin_count += amount
	coins_changed.emit(coin_count)
	print("Picked up {amount} coin(s). Total: {coin_count}")
