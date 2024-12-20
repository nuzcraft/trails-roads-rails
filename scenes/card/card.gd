extends Control
class_name Card

signal card_dropped(card, atlas_position)
signal card_picked_up(card)
signal card_returned_to_hand(card)

@export var card_name: String = "single road"
@export var type: String = "road"
@export var connection_array: Array[String] = ["N", "S", "E", "W"]
@export var nice_score: int
@export var exciting_score: int
@export var combo_score: int = 1

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
	$PanelContainer/VBoxContainer/HBoxContainer/NiceLabel.text = str(nice_score)
	if nice_score == 0:
		$PanelContainer/VBoxContainer/HBoxContainer/NiceLabel.hide()
	$PanelContainer/VBoxContainer/HBoxContainer/ExcitingLabel.text = str(exciting_score)
	if exciting_score == 0:
		$PanelContainer/VBoxContainer/HBoxContainer/ExcitingLabel.hide()
	
func _process(delta: float) -> void:
	match current_state:
		STATE.STATIC:
			modulate.a = 1.0
		STATE.FOLLOWING:
			global_position = round(get_global_mouse_position() - (size / 4))
			modulate.a = 0.5
	tooltip_text = "%s" % [card_name]
	if nice_score: tooltip_text += "\nNICE = +%d" % nice_score
	if exciting_score: tooltip_text += "\nEXCITING = +%d" % exciting_score
	if forest_nice_modifier or forest_exciting_modifier: 
		tooltip_text += "\nForest Modifier:\n"
		if forest_nice_modifier: tooltip_text += "  NICE = +%d" % forest_nice_modifier
		if forest_exciting_modifier: tooltip_text += "  EXCITING = +%d" % forest_exciting_modifier
	if combo_score: tooltip_text += "\nCombo Modifier = %d" % combo_score

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				switch_state(STATE.FOLLOWING)
			MOUSE_BUTTON_RIGHT:
				switch_state_to_static(true)
		wiggle()
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
			modulate.a = 1.0
			current_state = state
		STATE.FOLLOWING:
			card_picked_up.emit(self)
			current_state = state
		_:
			current_state = state
			
func switch_state_to_static(twn: bool = false) -> void:
	if twn:
		var tween = get_tree().create_tween()
		tween.finished.connect(on_static_tween_finished)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "position", return_pos, 0.2)
	switch_state(STATE.STATIC)

func on_static_tween_finished():
	card_returned_to_hand.emit(self)
	
func wiggle() -> void:
	randomize()
	var deg: float = randf_range(10.0, 15.0)
	var dur: float = randf_range(0.05, 0.15)
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($PanelContainer, 'rotation_degrees', deg, dur)
	tween.tween_property($PanelContainer, 'rotation_degrees', -deg, dur)
	tween.tween_property($PanelContainer, 'rotation_degrees', 0, dur)	
	
func _on_mouse_entered() -> void:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, 'scale', Vector2(1.1, 1.1), 0.1)
	tween.parallel().tween_property($PanelContainer/BorderPanel, 'visible', true, 0.1)
	z_index += 1

func _on_mouse_exited() -> void:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, 'scale', Vector2(1.0, 1.0), 0.1)
	tween.parallel().tween_property($PanelContainer/BorderPanel, 'visible', false, 0.1)
	z_index -=1
