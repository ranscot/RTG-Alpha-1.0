# ammo_ui.gd
extends Control

@onready var clout_label: Label = $VBoxContainer/CloutLabel
@onready var engage_label: Label = $VBoxContainer/EngageLabel
@onready var fart_label: Label = $VBoxContainer/FartLabel
@onready var tom_coin_label: Label = $VBoxContainer/TomCoinLabel

func _ready() -> void:
	AmmoManager.ammo_changed.connect(_on_ammo_changed)
	AmmoManager.coins_changed.connect(_on_coin_changed)
	update_all_labels()

func update_all_labels() -> void:
	# Use the '%' operator to insert the values
	fart_label.text = "Farts: %s" % AmmoManager.get_ammo_count('bullet_fart')
	clout_label.text = "Clout: %s" % AmmoManager.get_ammo_count('bullet_clout')
	engage_label.text = "Engage: %s" % AmmoManager.get_ammo_count('bullet_engage')
	tom_coin_label.text = "TomCoin: %s" % AmmoManager.get_coin_count()
	
func _on_coin_changed(new_count: int) -> void:
	tom_coin_label.text = "TomCoins: %s" % new_count	
	
func _on_ammo_changed(ammo_type: String, new_count: int) -> void:
	match ammo_type:
		"bullet_fart":
			# Use the '%' operator here
			fart_label.text = "Farts: %s" % new_count
		"bullet_clout":
			# Use the '%' operator here
			clout_label.text = "Clout: %s" % new_count
		"bullet_engage":
			# Use the '%' operator here
			engage_label.text = "Engage: %s" % new_count
