extends Node

@onready var sub_viewport_container: SubViewportContainer = $Control/SubViewportContainer
@onready var tile_map_layer_base: TileMapLayer = $Control/SubViewportContainer/SubViewport/TileMapLayerBase
@onready var tile_map_layer_path: TileMapLayer = $Control/SubViewportContainer/SubViewport/TileMapLayerPath
@onready var tile_map_layer_feature: TileMapLayer = $Control/SubViewportContainer/SubViewport/TileMapLayerFeature
@onready var label: Label = $Control/SubViewportContainer/SubViewport2/Label
@onready var hand_container: GridContainer = $Control/HandContainer
@onready var deck_label: Label = $Control/CenterContainer/PanelContainer/Panel/VBoxContainer/Label
@onready var nice_value_label: Label = $Control/VBoxContainer/HBoxContainer/MarginContainer/NicePanelContainer/MarginContainer/VBoxContainer/NiceValueLabel
@onready var exciting_value_label: Label = $Control/VBoxContainer/HBoxContainer/MarginContainer2/ExcitingPanelContainer/MarginContainer/VBoxContainer/ExcitingValueLabel
@onready var total_value_label: Label = $Control/VBoxContainer/PanelContainer/HBoxContainer/TotalValueLabel

# card types
const VERT_ROAD_CARD = preload("res://scenes/card/road/vert_road_card.tscn")
const HORIZ_ROAD_CARD = preload("res://scenes/card/road/horiz_road_card.tscn")
const NORTH_EAST_ROAD = preload("res://scenes/card/road/north_east_road.tscn")

# other scenes
const POP_UP = preload("res://scenes/pop_up.tscn")

# feature atlas position
const FOREST_ATLAS: Array[Vector2] = [Vector2(4, 5), Vector2(4, 6)]

var astar: AStar2D
var all_cards: Array[Card]
var hand_cards: Array[Card]
var deck_cards: Array[Card]
var cards_in_play: Dictionary # [Vector2, Card]
var source: Vector2
var target: Vector2

var nice_score: int = 1
var exciting_score: int = 1
var total_score: int = 1

var rng := RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	sub_viewport_container.stretch_shrink = 3
	
	for i in 16:
		var crd: Card
		match i % 3:
			0: crd = VERT_ROAD_CARD.instantiate()
			1: crd = HORIZ_ROAD_CARD.instantiate()
			2: crd = NORTH_EAST_ROAD.instantiate()
		add_card_to_all(crd)
		add_card_to_deck(crd)
	draw_cards_to_hand(8)
	
	label.text = "not connected"
	var src_target_array: Array[Vector2] = generate_map()
	source = src_target_array[0]
	target = src_target_array[1]
	astar = initialize_astar()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	deck_label.text = "%d/%d" % [deck_cards.size(), all_cards.size()]
	nice_value_label.text = str(nice_score)
	exciting_value_label.text = str(exciting_score)
	total_value_label.text = str(total_score)

func on_card_dropped(card: Card, atlas_position: Vector2) -> void:
	var cell_coord: Vector2 = tile_map_layer_path.local_to_map(tile_map_layer_path.get_local_mouse_position())
	tile_map_layer_path.set_cell(cell_coord, 0, atlas_position)
	add_point_to_astar(cell_coord, card.connection_array)
	cards_in_play[cell_coord] = card
	card.get_parent().remove_child(card)
	if check_astar_path(source, target):
		label.text = "you win"
		var path = check_astar_path(source, target)
		tally_score(path)
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
			elif conn == "E" and diff == Vector2(-1, 0):
				astar.connect_points(current_id, other_id)
			elif conn == "W" and diff == Vector2(1, 0):
				astar.connect_points(current_id, other_id)

func check_astar_path(src: Vector2, trgt: Vector2) -> Array:
	var src_id = astar.get_closest_point(src)
	var trgt_id = astar.get_closest_point(trgt)
	return astar.get_point_path(src_id, trgt_id)
	
func add_card_to_hand(card: Card) -> void:
	hand_cards.append(card)
	hand_container.add_child(card)
	card.card_dropped.connect(on_card_dropped)
	card.card_picked_up.connect(on_card_picked_up)
	card.card_returned_to_hand.connect(on_card_returned_to_hand)
	hand_container.queue_sort()
	
func add_card_to_deck(card: Card) -> void:
	deck_cards.append(card)
	
func add_card_to_all(card: Card) -> void:
	all_cards.append(card)
	
func draw_cards_to_hand(num: int) -> void:
	deck_cards.shuffle()
	for i in num:
		if not deck_cards.is_empty():
			var crd: Card = deck_cards.pop_front()
			add_card_to_hand(crd)
	
func generate_map() -> Array[Vector2]:
	var src: Vector2
	var trgt: Vector2
	const GREY_FLAG_ATLAS := Vector2(16, 0)
	const GREEN_FLAG_ATLAS := Vector2(16, 1)
	const BLUE_FLAG_ATLAS := Vector2(16, 2)
	const RED_FLAG_ATLAS := Vector2(16, 3)
	const ORANGE_FLAG_ATLAS := Vector2(16, 4)
	var flag_array: Array[Vector2] = [GREY_FLAG_ATLAS, GREEN_FLAG_ATLAS,\
		BLUE_FLAG_ATLAS, RED_FLAG_ATLAS, ORANGE_FLAG_ATLAS]
	
	src = Vector2(2, 2)
	trgt = Vector2(4, 5)
	tile_map_layer_path.clear()
	tile_map_layer_path.set_cell(src, 0, flag_array.pick_random())
	tile_map_layer_path.set_cell(trgt, 0, flag_array.pick_random())
	return [src, trgt]
	
func tally_score(path: Array) -> void:
	for pos in path:
		if cards_in_play.has(pos):
			#print("%d, %d is worth %d nice points" % [pos.x, pos.y, cards_in_play[pos].nice_score])
			var nice = cards_in_play[pos].nice_score
			var exciting = cards_in_play[pos].exciting_score
			
			if nice: 
				var pop = POP_UP.instantiate()
				pop.operator = "+"
				pop.amount = nice
				pop.mod = Color.DODGER_BLUE
				sub_viewport_container.add_child(pop)
				pop.position = pos * 16 * 3 #+ Vector2(16, -16)
				await get_tree().create_timer(0.4).timeout
				nice_score += nice
				total_score = nice_score * exciting_score
			
			if exciting:
				var pop = POP_UP.instantiate()
				pop.operator = "+"
				pop.amount = exciting
				pop.mod = Color.LIGHT_CORAL
				sub_viewport_container.add_child(pop)
				pop.position = pos * 16 * 3 #+ Vector2(16, -16)
				await get_tree().create_timer(0.4).timeout
				exciting_score += exciting
				total_score = nice_score * exciting_score
			
			# check for forest modifier
			for cell in tile_map_layer_feature.get_used_cells():
				if Vector2(cell) == pos and \
						FOREST_ATLAS.has(Vector2(tile_map_layer_feature.get_cell_atlas_coords(cell))):
					var forest_nice = cards_in_play[pos].forest_nice_modifier
					var forest_exciting = cards_in_play[pos].forest_exciting_modifier
					if forest_nice: 
						var pop = POP_UP.instantiate()
						pop.operator = "+"
						pop.amount = forest_nice
						pop.mod = Color.DODGER_BLUE
						sub_viewport_container.add_child(pop)
						pop.position = pos * 16 * 3 #+ Vector2(16, -16)
						await get_tree().create_timer(0.4).timeout
						nice_score += forest_nice
						total_score = nice_score * exciting_score
					
					if forest_exciting:
						var pop = POP_UP.instantiate()
						pop.operator = "+"
						pop.amount = forest_exciting
						pop.mod = Color.LIGHT_CORAL
						sub_viewport_container.add_child(pop)
						pop.position = pos * 16 * 3 #+ Vector2(16, -16)
						await get_tree().create_timer(0.4).timeout
						exciting_score += forest_exciting
						total_score = nice_score * exciting_score
