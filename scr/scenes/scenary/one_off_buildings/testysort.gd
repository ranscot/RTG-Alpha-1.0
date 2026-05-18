extends Node2D

@export var tom: Node2D
@export var bodega: Node2D

func _process(delta):
	if tom and bodega:
		print("Tom Y: ", tom.global_position.y, " | Bodega Y: ", bodega.global_position.y)
