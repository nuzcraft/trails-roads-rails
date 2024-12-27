extends Control

signal next_level(add_array: Array[Card])

@onready var choose_label: Label = $ChooseLabel
@onready var delete_tile_grid_container: HBoxContainer = $DeletePanelContainer/MarginContainer/DeleteTileGridContainer
@onready var add_tile_grid_container: HBoxContainer = $AddPanelContainer/MarginContainer/AddTileGridContainer

var max_num_choices: int = 2
var num_choices: int = max_num_choices
var num_selected: int = 0

var add_array: Array[Card]

# NOTE make it so we pull cards from the deck, reparent them to the delete tile grid, then anything 
# we don't select from there gets re-added back into the deck
# NEVERMIND i forgot the deck instances aren't parented so unparenting them here is fine
# add back in the delete array or figure it out

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in delete_tile_grid_container.get_children():
		if child is Card:
			child.card_selected.connect(_on_card_selected)
			child.card_unselected.connect(_on_card_unselected)
			child.switch_state_to_selectable()
	for child in add_tile_grid_container.get_children():
		if child is Card:
			child.card_selected.connect(_on_card_selected)
			child.card_unselected.connect(_on_card_unselected)
			child.switch_state_to_selectable()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	choose_label.text = "choose up to\n~ %d ~\ntiles" % num_choices

func reset() -> void:
	num_choices = max_num_choices
	num_selected = 0

	add_array = []
	# TODO make sure this is working ok
	for child in delete_tile_grid_container.get_children():
		if child is Card:
			delete_tile_grid_container.remove_child(child)
	for child in add_tile_grid_container.get_children():
		if child is Card:
			add_tile_grid_container.remove_child(child)

func _on_next_level_button_pressed() -> void:
	for child in delete_tile_grid_container.get_children():
		if child is Card and not child.selected:
			add_array.append(child)
	for child in add_tile_grid_container.get_children():
		if child is Card and child.selected:
			add_array.append(child)
	#print("delete array: ", delete_array)
	#print("add_array: ", add_array)
	next_level.emit(add_array)
	
func _on_card_selected(card: Card) -> void:
	num_choices -= 1
	num_selected += 1
	if num_selected > max_num_choices:
		await get_tree().create_timer(0.2).timeout
		await card.unselect()

func _on_card_unselected(card: Card) -> void:
	if num_selected > 0:
		num_choices += 1
		num_selected -= 1
