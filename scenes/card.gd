extends Control
class_name Card

signal card_dropped(card, atlas_position)

var return_pos: Vector2

enum STATE {
	STATIC,
	FOLLOWING,
	FROZEN
}

var current_state: int =  STATE.STATIC
var atlas_pos: Vector2

func _ready() -> void:
	return_pos = position
	var tex: AtlasTexture = $PanelContainer/VBoxContainer/TextureRect.texture
	atlas_pos = tex.region.position / 16
	
func _process(delta: float) -> void:
	match current_state:
		STATE.STATIC:
			modulate.a = 1.0
		STATE.FOLLOWING:
			position = round(get_global_mouse_position() - (size / 4))
			modulate.a = 0.5

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				switch_state(STATE.FOLLOWING)
			MOUSE_BUTTON_RIGHT:
				switch_state(STATE.STATIC)
	elif event is InputEventMouseButton and not event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if current_state == STATE.FOLLOWING:
					card_dropped.emit(self, atlas_pos)
					switch_state(STATE.FROZEN)
				#switch_state(STATE.STATIC)

func switch_state(state: int) -> void:
	match state:
		STATE.STATIC:
			var tween = get_tree().create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(self, "position", return_pos, 0.2)
			current_state = state
		_:
			current_state = state
