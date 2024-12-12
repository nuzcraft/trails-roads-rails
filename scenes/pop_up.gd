extends Control

@export var operator: String = "+"
@export var amount: int = 1
@export var mod: Color = Color.WHITE

func _ready() -> void:
	$PanelContainer/MarginContainer/HBoxContainer/OperationLabel.text = operator
	$PanelContainer/MarginContainer/HBoxContainer/AmountLabel.text = str(amount)
	$PanelContainer/MarginContainer/HBoxContainer/OperationLabel.modulate = mod
	$PanelContainer/MarginContainer/HBoxContainer/AmountLabel.modulate = mod

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"fade":
			queue_free()
