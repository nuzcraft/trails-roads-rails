extends Node

@onready var sub_viewport_container: SubViewportContainer = $Control/SubViewportContainer
@onready var tile_map_layer_base: TileMapLayer = $Control/SubViewportContainer/SubViewport/TileMapLayerBase
@onready var tile_map_layer_path: TileMapLayer = $Control/SubViewportContainer/SubViewport/TileMapLayerPath
@onready var label: Label = $Control/SubViewportContainer/SubViewport2/Label
@onready var hand_container: GridContainer = $Control/HandContainer

# card types
const VERT_ROAD_CARD = preload("res://scenes/card/road/vert_road_card.tscn")

var astar: AStar2D
var all_cards: Array[Card]
var hand_cards: Array[Card]
var deck_cards: Array[Card]
var cards_in_play: Dictionary # [Vector2, Card]
var source := Vector2(1, 2)
var target := Vector2(11, 2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sub_viewport_container.stretch_shrink = 3
	
	for i in 8:
		var crd = VERT_ROAD_CARD.instantiate()
		add_card_to_hand(crd)
	
	label.text = "not connected"
	astar = initialize_astar()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_card_dropped(card: Card, atlas_position: Vector2) -> void:
	var cell_coord: Vector2i = tile_map_layer_path.local_to_map(tile_map_layer_path.get_local_mouse_position())
	tile_map_layer_path.set_cell(cell_coord, 0, atlas_position)
	add_point_to_astar(cell_coord, card.connection_array)
	card.queue_free()
	if check_astar_path(source, target):
		label.text = "you win"
	else:
		label.text = "not a path"
		
func on_card_picked_up(card: Card) -> void:
	#card.reparent(self)
	pass
		
func on_card_returned_to_hand(card: Card) -> void:
	hand_container.queue_sort()
	
func initialize_astar() -> AStar2D:
	var astar: AStar2D = AStar2D.new()
	var current_id: int
	for cell in tile_map_layer_path.get_used_cells():
		current_id = astar.get_available_point_id()
		astar.add_point(current_id, cell)
		for other_id in astar.get_point_ids():
			var diff: Vector2 = abs(astar.get_point_position(other_id) - Vector2(cell))
			if (diff.x == 1 and diff.y == 0) or (diff.x == 0 and diff.y == 1):
				astar.connect_points(current_id, other_id)
	return astar
	
func add_point_to_astar(cell_pos: Vector2, conn_array: Array[String]) -> void:
	var current_id: int = astar.get_available_point_id()
	astar.add_point(current_id, cell_pos)
	#print(cell_pos)
	for other_id in astar.get_point_ids():
		var diff: Vector2 = abs(astar.get_point_position(other_id) - Vector2(cell_pos))
		#print(diff)
		for conn in conn_array:
			if conn == "N" and diff == Vector2(0, 1):
				astar.connect_points(current_id, other_id)
			elif conn == "S" and diff == Vector2(0, -1):
				astar.connect_points(current_id, other_id)

func check_astar_path(src: Vector2, trgt: Vector2) -> Array:
	var src_id = astar.get_closest_point(src)
	var trgt_id = astar.get_closest_point(trgt)
	return astar.get_point_path(src_id, trgt_id)
	
func add_card_to_hand(card: Card) -> void:
	hand_container.add_child(card)
	card.card_dropped.connect(on_card_dropped)
	card.card_picked_up.connect(on_card_picked_up)
	card.card_returned_to_hand.connect(on_card_returned_to_hand)
	hand_container.queue_sort()
