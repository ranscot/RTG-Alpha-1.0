extends CanvasLayer

# --- 1. UI COMPONENT REFERENCES ---

@onready var health_bar: ProgressBar = $HUD_Margins/Master_VBox/Health_HBox/HealthBar

# Grab the 4 slots in Arsenal hotbar
@onready var slot_fart: VBoxContainer = $HUD_Margins/Master_VBox/Arsenal_HBox/WeaponSlot_1
@onready var slot_clout: VBoxContainer = $HUD_Margins/Master_VBox/Arsenal_HBox/WeaponSlot_2
@onready var slot_engage: VBoxContainer = $HUD_Margins/Master_VBox/Arsenal_HBox/WeaponSlot_3
@onready var slot_coin: VBoxContainer = $HUD_Margins/Master_VBox/Arsenal_HBox/WeaponSlot_4


# --- THE MAGIC TRICK ---
# We map your AmmoManager string IDs directly to the UI nodes!
@onready var weapon_slots = {
	"bullet_fart": slot_fart,
	"bullet_clout": slot_clout,
	"bullet_engage": slot_engage
}

func _ready() -> void:
	# ==========================================
	# 1. HEALTH SYSTEM SETUP
	# ==========================================
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(update_health)
		await get_tree().process_frame
		update_health(player.health, player.max_health)
	else:
		print("HUD Warning: Could not find node in 'Player' group.")

	# ==========================================
	# 2. AMMO & COIN SETUP
	# ==========================================
	AmmoManager.ammo_changed.connect(_on_ammo_changed)
	AmmoManager.coins_changed.connect(_on_coin_changed)
	
	# 3. Hide weapons Tom hasn't unlocked yet
	slot_clout.hide()
	slot_engage.hide()
	
	# 4. Pull the initial data to fill the UI
	update_all_labels()
	
	# 5. Set the starting highlighted weapon
	set_active_weapon("bullet_fart")

func update_all_labels() -> void:
	# Prime the pump with the starting numbers
	_on_ammo_changed("bullet_fart", AmmoManager.get_ammo_count("bullet_fart"))
	_on_ammo_changed("bullet_clout", AmmoManager.get_ammo_count("bullet_clout"))
	_on_ammo_changed("bullet_engage", AmmoManager.get_ammo_count("bullet_engage"))
	_on_coin_changed(AmmoManager.get_coin_count())

# --- 2. SIGNAL RECEIVERS ---

func _on_ammo_changed(ammo_type: String, new_count: int) -> void:
	# If the AmmoManager shouts an ID we know about, update that specific slot
	if weapon_slots.has(ammo_type):
		var target_label = weapon_slots[ammo_type].get_node("AmmoText")
		# Using your preferred %s formatting! 
		# (Add "Farts: " before the %s if you still want the word next to the icon)
		target_label.text = "%s" % new_count

func _on_coin_changed(new_count: int) -> void:
	var coin_label = slot_coin.get_node("AmmoText")
	coin_label.text = "%s" % new_count

# --- 3. HOTBAR HIGHLIGHT LOGIC ---

func set_active_weapon(active_ammo_type: String) -> void:
	# Loop through our dictionary and dim everything EXCEPT the active weapon
	for current_type in weapon_slots.keys():
		if current_type == active_ammo_type:
			weapon_slots[current_type].modulate = Color(1.0, 1.0, 1.0, 1.0) # Fully bright
		else:
			weapon_slots[current_type].modulate = Color(1.0, 1.0, 1.0, 1.0) # Ghosted out

# --- 4. HEALTH LOGIC ---

func update_health(current_hp: int, max_hp: int) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current_hp
