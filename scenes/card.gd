extends Control
class_name Card

var return_pos: Vector2

enum STATE {
	STATIC,
	FOLLOWING
}

var current_state: int =  STATE.STATIC

func _ready() -> void:
	return_pos = position

func _process(delta: float) -> void:
	match current_state:
		STATE.STATIC:
			modulate.a = 1.0
			pass
		STATE.FOLLOWING:
			position = round(get_global_mouse_position() - (size / 4))
			modulate.a = 0.5

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				print("Left mouse button")
				current_state = STATE.FOLLOWING
			#MOUSE_BUTTON_RIGHT:
				#print("right mouse button")
				#var tween = get_tree().create_tween()
				#tween.set_ease(Tween.EASE_IN_OUT)
				#tween.tween_property(self, "position", return_pos, 0.2)
				#current_state = STATE.STATIC
	elif event is InputEventMouseButton and not event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				print("Left mouse button released")
				var tween = get_tree().create_tween()
				tween.set_ease(Tween.EASE_IN_OUT)
				tween.tween_property(self, "position", return_pos, 0.2)
				current_state = STATE.STATIC
			#MOUSE_BUTTON_RIGHT:
				#print("right mouse button")
				#var tween = get_tree().create_tween()
				#tween.set_ease(Tween.EASE_IN_OUT)
				#tween.tween_property(self, "position", return_pos, 0.2)
				#current_state = STATE.STATIC
