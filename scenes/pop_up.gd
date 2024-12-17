extends Control

@export var operator: String = "+"
@export var amount: int = 1
@export var mod: Color = Color.WHITE

func _ready() -> void:
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/OperationLabel.text = operator
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/AmountLabel.text = str(amount)
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/OperationLabel.modulate = mod
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/AmountLabel.modulate = mod

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"fade":
			queue_free()
			
func combo() -> void:
	$PanelContainer/MarginContainer/VBoxContainer/ComboLabel.show()
