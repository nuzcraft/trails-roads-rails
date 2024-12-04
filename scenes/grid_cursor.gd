@tool
extends Node2D
class_name GridCursor


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var pos = get_global_mouse_position()
	var quantized_pos: Vector2 = 16 * floor(pos / 16) + Vector2(8, 8)
	global_position = quantized_pos
