extends Control

signal next_level

@onready var choose_label: Label = $ChooseLabel
@onready var tile_grid_container: GridContainer = $TileGridContainer

var num_choices: int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	choose_label.text = "choose up to\n~ %d ~\ntiles" % num_choices


func _on_next_level_button_pressed() -> void:
	next_level.emit()
