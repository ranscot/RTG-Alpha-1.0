extends Node2D

## 1. Exported Variables
# Drag the bullet scenes into the Inspector
@export var fart_bullet: PackedScene
@export var cloat_bullet: PackedScene
@export var engage_bullet: PackedScene

# 2. Node References
@onready var muzzle: Marker2D = $Muzzle
@onready var fire_timer: Timer = $FireTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fire_timer.timeout.connect(_on_fire_timer_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# ---- 1. Aiming ----
	# The WeaponManage (this very node) will always point a
	pass
