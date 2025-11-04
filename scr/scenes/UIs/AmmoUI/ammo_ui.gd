# ammo_ui.gd
extends Control

@onready var standard_label = $VBoxContainer/StandardLabel
@onready var laser_label = $VBoxContainer/LaserLabel
@onready var grenade_label = $VBoxContainer/GrenadeLabel

func _ready() -> void:
	AmmoManager.ammo_changed.connect(_on_ammo_changed)
	update_all_labels()

func update_all_labels() -> void:
	# Use the '%' operator to insert the values
	standard_label.text = "Standard: %s" % AmmoManager.get_ammo_count('standard')
	laser_label.text = "Laser: %s" % AmmoManager.get_ammo_count('laser')
	grenade_label.text = "Grenade: %s" % AmmoManager.get_ammo_count('grenade')

func _on_ammo_changed(ammo_type: String, new_count: int) -> void:
	match ammo_type:
		"standard":
			# Use the '%' operator here
			standard_label.text = "Standard: %s" % new_count
		"laser":
			# Use the '%' operator here
			laser_label.text = "Laser: %s" % new_count
		"grenade":
			# Use the '%' operator here
			grenade_label.text = "Grenade: %s" % new_count
