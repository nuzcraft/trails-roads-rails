extends Control
class_name Card

signal card_dropped(card, atlas_position)
signal card_picked_up(card)
signal card_returned_to_hand(card)

@export var card_name: String = "single road"
@export var connection_array: Array[String] = ["N", "S", "E", "W"]
@export var nice_score: int
@export var exciting_score: int
@export var forest_nice_modifier: int
@export var forest_exciting_modifier: int

var return_pos: Vector2
#var return_global_pos: Vector2

enum STATE {
	STATIC,
	FOLLOWING,
	FROZEN
}

var current_state: int =  STATE.STATIC
var atlas_pos: Vector2

func _ready() -> void:
	return_pos = position
	#return_global_pos = global_position
	var tex: AtlasTexture = $PanelContainer/VBoxContainer/TextureRect.texture
	atlas_pos = tex.region.position / 16
	$PanelContainer/VBoxContainer/Label.text = card_name
	
func _process(delta: float) -> void:
	match current_state:
		STATE.STATIC:
			modulate.a = 1.0
		STATE.FOLLOWING:
			global_position = round(get_global_mouse_position() - (size / 4))
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
			tween.finished.connect(on_static_tween_finished)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(self, "position", return_pos, 0.2)
			#tween.parallel().tween_property(self, "global_position", return_global_pos, 0.2)
			current_state = state
		STATE.FOLLOWING:
			card_picked_up.emit(self)
			current_state = state
		_:
			current_state = state

func on_static_tween_finished():
	card_returned_to_hand.emit(self)
