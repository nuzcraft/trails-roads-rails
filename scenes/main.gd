extends Node

@onready var sub_viewport_container: SubViewportContainer = $Control/SubViewportContainer
@onready var tile_map_layer_base: TileMapLayer = $Control/SubViewportContainer/SubViewport/TileMapLayerBase
@onready var tile_map_layer_path: TileMapLayer = $Control/SubViewportContainer/SubViewport/TileMapLayerPath
@onready var tile_map_layer_feature: TileMapLayer = $Control/SubViewportContainer/SubViewport/TileMapLayerFeature
@onready var label: Label = $Control/SubViewportContainer/SubViewport2/Label
@onready var hand_container: GridContainer = $Control/HandContainer
@onready var deck_label: Label = $Control/DeckContainer/PanelContainer/Panel/VBoxContainer/Label
@onready var nice_value_label: Label = $Control/VBoxContainer/HBoxContainer/MarginContainer/NicePanelContainer/MarginContainer/VBoxContainer/NiceValueLabel
@onready var exciting_value_label: Label = $Control/VBoxContainer/HBoxContainer/MarginContainer2/ExcitingPanelContainer/MarginContainer/VBoxContainer/ExcitingValueLabel
@onready var total_value_label: Label = $Control/VBoxContainer/PanelContainer/HBoxContainer/TotalValueLabel
@onready var goal_value_label: Label = $Control/VBoxContainer/GoalContainer/HBoxContainer/GoalValueLabel
@onready var need_points_label: Label = $Control/VBoxContainer/VBoxContainer/NeedPointsLabel
@onready var level_label: Label = $Control/VBoxContainer/LevelLabel
@onready var pause_end_panel: Panel = $Control/PauseEndPanel
@onready var quit_button: Button = $Control/PauseEndPanel/VBoxContainer/HBoxContainer2/QuitButton
@onready var resume_button: Button = $Control/PauseEndPanel/VBoxContainer/HBoxContainer2/ResumeButton
@onready var try_again_label: Label = $Control/PauseEndPanel/VBoxContainer/TryAgainLabel
@onready var pause_label: Label = $Control/PauseEndPanel/VBoxContainer/PauseLabel
@onready var discard_draw_button: Button = $Control/VBoxContainer/VBoxContainer/DiscardDrawButton
@onready var high_score_value_label: Label = $Control/PauseEndPanel/VBoxContainer/HBoxContainer/HighScoreValueLabel
@onready var effect_volume_h_slider: HSlider = $Control/PauseEndPanel/VBoxContainer/EffectVolumeHSlider
@onready var music_volume_h_slider: HSlider = $Control/PauseEndPanel/VBoxContainer/MusicVolumeHSlider

# card types
const VERT_ROAD_CARD = preload("res://scenes/card/road/vert_road_card.tscn")
const HORIZ_ROAD_CARD = preload("res://scenes/card/road/horiz_road_card.tscn")
const NORTH_EAST_ROAD = preload("res://scenes/card/road/north_east_road.tscn")
const NORTH_WEST_ROAD = preload("res://scenes/card/road/north_west_road.tscn")
const SOUTH_EAST_ROAD = preload("res://scenes/card/road/south_east_road.tscn")
const SOUTH_WEST_ROAD = preload("res://scenes/card/road/south_west_road.tscn")
const VERT_TRAIL_CARD = preload("res://scenes/card/trail/vert_trail_card.tscn")
const HORIZ_TRAIL_CARD = preload("res://scenes/card/trail/horiz_trail_card.tscn")
const NORTH_EAST_TRAIL = preload("res://scenes/card/trail/north_east_trail.tscn")
const NORTH_WEST_TRAIL = preload("res://scenes/card/trail/north_west_trail.tscn")
const SOUTH_EAST_TRAIL = preload("res://scenes/card/trail/south_east_trail.tscn")
const SOUTH_WEST_TRAIL = preload("res://scenes/card/trail/south_west_trail.tscn")
const VERT_RAIL_CARD = preload("res://scenes/card/rail/vert_rail_card.tscn")
const HORIZ_RAIL_CARD = preload("res://scenes/card/rail/horiz_rail_card.tscn")
const NORTH_EAST_RAIL = preload("res://scenes/card/rail/north_east_rail.tscn")
const NORTH_WEST_RAIL = preload("res://scenes/card/rail/north_west_rail.tscn")
const SOUTH_EAST_RAIL = preload("res://scenes/card/rail/south_east_rail.tscn")
const SOUTH_WEST_RAIL = preload("res://scenes/card/rail/south_west_rail.tscn")
# feature cards
const FOREST = preload("res://scenes/card/feature_card/forest.tscn")
const HILLS = preload("res://scenes/card/feature_card/hills.tscn")
const MOUNTAIN = preload("res://scenes/card/feature_card/mountain.tscn")
const FLOWER_FIELD = preload("res://scenes/card/feature_card/flower_field.tscn")

# other scenes
const POP_UP = preload("res://scenes/pop_up.tscn")
const DECK_EDIT_MENU = preload("res://scenes/deck_edit_menu.tscn")

# feature atlas position
const FOREST_ATLAS: Array[Vector2] = [Vector2(4, 5), Vector2(4, 6)]
const HILL_ATLAS: Array[Vector2] = [Vector2(8, 11)]
const MOUNTAIN_ATLAS: Array[Vector2] = [Vector2(8, 12)]
const FLOWER_FIELD_ATLAS: Array[Vector2] = [Vector2(8, 13)]

var astar: AStar2D
var all_cards: Array[Card]
var hand_cards: Array[Card]
var deck_cards: Array[Card]
var cards_in_play: Dictionary # [Vector2, Card]
var source: Vector2
var src_id: int
var target: Vector2
var trgt_id: int

var nice_score: int = 1
var exciting_score: int = 1
var total_score: int = 1
var level: int = 0
var score_needed: int = 0
var high_score: int = 0

var shake: float = 0.0

var rng := RandomNumberGenerator.new()

enum {
	PLAYING,
	PAUSED
}

var state = PLAYING

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	
	sub_viewport_container.stretch_shrink = 3
	
	astar = initialize_astar()
	
	new_game()
	next_level([])
	label.text = "not connected"
	
	if OS.has_feature("web"):
		quit_button.hide()
	
	effect_volume_h_slider.value = 75
	music_volume_h_slider.value = 50
	SoundPlayer.play_music(SoundPlayer.JD_SHERBERT___AMBIENCES_MUSIC_PACK___DESERT_SIROCCO)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		PLAYING:
			deck_label.text = "%d/%d" % [deck_cards.size(), all_cards.size()]
			nice_value_label.text = str(nice_score)
			exciting_value_label.text = str(exciting_score)
			total_value_label.text = str(total_score)
			goal_value_label.text = str(score_needed)
			level_label.text = "Level " + str(level)
			high_score_value_label.text = str(high_score)
			
			if shake:
				shake = max(shake - 2.0 * delta, 0)
				screenshake()
				
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		match state:
			PLAYING:
				pause()
				state = PAUSED
			PAUSED:
				unpause()
				state = PLAYING

func on_card_dropped(card: Card, atlas_position: Vector2) -> void:
	var cell_coord: Vector2 = tile_map_layer_path.local_to_map(tile_map_layer_path.get_local_mouse_position())
	if cell_coord.x < 0 or cell_coord.y < 0 or\
			cell_coord.x > 16 or cell_coord.y > 9 or\
			cell_coord == source or cell_coord == target:
		card.switch_state_to_static(true)
		return
	if card.card_name == "mountain":
		for coord in cards_in_play.keys():
			if coord == cell_coord and cards_in_play[coord].type != "trail":
				card.switch_state_to_static(true)
				return
	if card.type != "trail" && card.type != "feature":
		# print(tile_map_layer_feature.get_cell_atlas_coords(cell_coord))
		if MOUNTAIN_ATLAS.has(Vector2(tile_map_layer_feature.get_cell_atlas_coords(cell_coord))):
			card.switch_state_to_static(true)
			return
	match card.type:
		"feature":
			tile_map_layer_feature.set_cell(cell_coord, 0, atlas_position)
		_:
			tile_map_layer_path.set_cell(cell_coord, 0, atlas_position)
			add_point_to_astar(cell_coord, card.connection_array)
			cards_in_play[cell_coord] = card
	add_screenshake(0.3)
	SoundPlayer.play_sound(SoundPlayer.SWITCH_8)
	hand_cards.remove_at(hand_cards.find(card))
	hand_container.remove_child(card)
	card.switch_state_to_static()
	if check_astar_path(source, target):
		label.text = "you win"
		var path = check_astar_path(source, target)
		tally_score(path)
	else:
		label.text = "not a path"
		
func on_card_picked_up(card: Card) -> void:
	add_screenshake(0.25)
		
func on_card_returned_to_hand(card: Card) -> void:
	hand_container.queue_sort()
	
func initialize_astar() -> AStar2D:
	var astar: AStar2D = AStar2D.new()
	#var current_id: int
	#for cell in tile_map_layer_path.get_used_cells():
		#current_id = astar.get_available_point_id()
		#astar.add_point(current_id, cell)
		#for other_id in astar.get_point_ids():
			#var diff: Vector2 = abs(astar.get_point_position(other_id) - Vector2(cell))
			#if (diff.x == 1 and diff.y == 0) or (diff.x == 0 and diff.y == 1):
				#astar.connect_points(current_id, other_id)
	return astar
	
func add_point_to_astar(cell_pos: Vector2, conn_array: Array[String]) -> int:
	for id in astar.get_point_ids():
		if astar.get_point_position(id) == cell_pos:
			#print('removing old astar point')
			astar.remove_point(id)
	var current_id: int = astar.get_available_point_id()
	astar.add_point(current_id, cell_pos)
	#print("current cell is %d at point %d, %d with conns %s" % [current_id, cell_pos.x, cell_pos.y, conn_array])
	for other_id in astar.get_point_ids():
		var other_pos: Vector2 = astar.get_point_position(other_id)
		var diff: Vector2 = other_pos - cell_pos
		var other_card: Card
		if cards_in_play.has(other_pos):
			other_card = cards_in_play[other_pos]
		#print("other id %d is %d, %d spaces away" % [other_id, diff.x, diff.y])
		#print(diff)
		for conn in conn_array:
			if conn == "N" and diff == Vector2(0, -1):
				if other_pos == source or other_pos == target: 
					astar.connect_points(current_id, other_id)
					#print("connected to the north")
				elif other_card:
					if other_card.connection_array.has("S"):
						astar.connect_points(current_id, other_id)
						#print("connected to the north")
			elif conn == "S" and diff == Vector2(0, 1):
				if other_pos == source or other_pos == target: 
					astar.connect_points(current_id, other_id)
					#print("connected to the south")
				elif other_card:
					if other_card.connection_array.has("N"):
						astar.connect_points(current_id, other_id)
						#print("connected to the south")
			elif conn == "E" and diff == Vector2(1, 0):
				if other_pos == source or other_pos == target: 
					astar.connect_points(current_id, other_id)
					#print("connected to the east")
				elif other_card:
					if other_card.connection_array.has("W"):
						astar.connect_points(current_id, other_id)
						#print("connected to the east")
			elif conn == "W" and diff == Vector2(-1, 0):
				if other_pos == source or other_pos == target: 
					astar.connect_points(current_id, other_id)
					#print("connected to the west")
				elif other_card:
					if other_card.connection_array.has("E"):
						astar.connect_points(current_id, other_id)
						#print("connected to the west")
	return current_id

func check_astar_path(src: Vector2, trgt: Vector2) -> Array:
	var src_id = astar.get_closest_point(src)
	var trgt_id = astar.get_closest_point(trgt)
	return astar.get_point_path(src_id, trgt_id)
	
func add_card_to_hand(card: Card) -> void:
	card.modulate.a = 0.0
	hand_cards.append(card)
	hand_container.add_child(card)
	var new_global_pos = Vector2(hand_container.size.x / hand_container.columns\
	 	* (hand_container.get_child_count() - 1), hand_container.global_position.y)
	card.return_pos = new_global_pos
	card.global_position = $Control/DeckContainer.global_position
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(card, "global_position", new_global_pos, 0.25)
	tween.parallel().tween_property(card, "modulate:a", 1.0, 0.25)
	SoundPlayer.play_sound(SoundPlayer.BOOK_FLIP_3)
	await get_tree().create_timer(0.25).timeout
	add_screenshake(0.25)
	hand_container.queue_sort()
	
	
func add_card_to_deck(card: Card) -> void:
	card.switch_state_to_static()
	deck_cards.append(card)
	
func add_card_to_all(card: Card) -> void:
	all_cards.append(card)
	if not card.card_dropped.is_connected(on_card_dropped):
		card.card_dropped.connect(on_card_dropped)
	if not card.card_picked_up.is_connected(on_card_picked_up):
		card.card_picked_up.connect(on_card_picked_up)
	if not card.card_returned_to_hand.is_connected(on_card_returned_to_hand):
		card.card_returned_to_hand.connect(on_card_returned_to_hand)
	
func draw_cards_to_hand(num: int) -> void:
	deck_cards.shuffle()
	for i in num:
		if not deck_cards.is_empty():
			var crd: Card = deck_cards.pop_front()
			await add_card_to_hand(crd)
	
func generate_map(lvl: int) -> Array[Vector2]:
	# generate features (forest)
	tile_map_layer_feature.clear()
	for x in 18:
		for y in 10:
			if randf() <= 0.2 - (lvl * 0.01):
				tile_map_layer_feature.set_cell(Vector2(x, y), 0, FOREST_ATLAS.pick_random())
	# generate source/target flags
	var src: Vector2
	var trgt: Vector2
	const GREY_FLAG_ATLAS := Vector2(16, 0)
	const GREEN_FLAG_ATLAS := Vector2(16, 1)
	const BLUE_FLAG_ATLAS := Vector2(16, 2)
	const RED_FLAG_ATLAS := Vector2(16, 3)
	const ORANGE_FLAG_ATLAS := Vector2(16, 4)
	var flag_array: Array[Vector2] = [GREY_FLAG_ATLAS, GREEN_FLAG_ATLAS,\
		BLUE_FLAG_ATLAS, RED_FLAG_ATLAS, ORANGE_FLAG_ATLAS]
	
	var min_x: int = floor(6 - (float(7) / float(12) * (lvl - 1))) # floor(7 - (7/12 * (A3 - 1)))
	var max_x: int = floor(10 + (float(7) / float(12) * (lvl - 1)))
	var min_y: int = 4 -lvl/3
	var max_y: int = 6 + lvl/3
	
	src = Vector2(randi_range(min_x, 7), randi_range(min_y, max_y))
	trgt = Vector2(randi_range(9, max_x), randi_range(min_y, max_y))
	while src.distance_to(trgt) < 3:
		src = Vector2(randi_range(min_x, 7), randi_range(min_y, max_y))
		trgt = Vector2(randi_range(9, max_x), randi_range(min_y, max_y))
	tile_map_layer_path.clear()
	tile_map_layer_feature.set_cell(src)
	tile_map_layer_feature.set_cell(trgt)
	tile_map_layer_path.set_cell(src, 0, flag_array.pick_random())
	tile_map_layer_path.set_cell(trgt, 0, flag_array.pick_random())
	return [src, trgt]
	
func tally_score(path: Array) -> void:
	total_score = 0
	nice_score = 1
	exciting_score = 1
	var combo = 1
	var dur: float = 0.4
	for i in path.size():
		if i > 4: dur = 0.3
		if i > 12: dur = 0.2
		if i > 24: dur = 0.1
		if cards_in_play.has(path[i]):
			#print("%d, %d is worth %d nice points" % [pos.x, pos.y, cards_in_play[pos].nice_score])
			var nice = cards_in_play[path[i]].nice_score
			var exciting = cards_in_play[path[i]].exciting_score
			if nice: 
				await score_popup("nice", nice, path[i], dur, "+", false)
			if exciting:
				await score_popup("exciting", exciting, path[i], dur, "+", false)
			# check for forest modifier
			for cell in tile_map_layer_feature.get_used_cells():
				if Vector2(cell) == path[i] and \
						FOREST_ATLAS.has(Vector2(tile_map_layer_feature.get_cell_atlas_coords(cell))):
					var forest_nice = cards_in_play[path[i]].forest_nice_modifier
					var forest_exciting = cards_in_play[path[i]].forest_exciting_modifier
					if forest_nice: 
						await score_popup("nice", forest_nice, path[i], dur, "+", false)
					if forest_exciting:
						await score_popup("exciting", forest_exciting, path[i], dur, "+", false)
				if Vector2(cell) == path[i] and \
						MOUNTAIN_ATLAS.has(Vector2(tile_map_layer_feature.get_cell_atlas_coords(cell))):
					await score_popup("nice", 3, path[i], dur, "+", false)
					await score_popup("exciting", 3, path[i], dur, "+", false)
				if Vector2(cell) == path[i] and \
						HILL_ATLAS.has(Vector2(tile_map_layer_feature.get_cell_atlas_coords(cell))):
					await score_popup("nice", 2, path[i], dur, "+", false)
					await score_popup("exciting", 2, path[i], dur, "+", false)
				if Vector2(cell) == path[i] and \
						FLOWER_FIELD_ATLAS.has(Vector2(tile_map_layer_feature.get_cell_atlas_coords(cell))):
					await score_popup("nice", 5, path[i], dur, "+", false)
			# check for combo
			if cards_in_play.has(path[i-1]):
				var prev_card: Card = cards_in_play[path[i-1]]
				var card: Card = cards_in_play[path[i]]
				if prev_card.type == card.type:
					combo += 1
				else: combo = 1
				#print("combo is %d" % combo)
				var combo_mult = (combo / 3) * card.combo_score
				#print('combo mult is %d' % combo_mult)
				if combo_mult > 0:
					await score_popup("exciting", combo_mult, path[i] - Vector2(0.5, 0), dur, "+", true)
	if total_score > high_score: high_score = total_score
	if total_score >= score_needed:
		need_points_label.hide()
		SoundPlayer.play_sound(SoundPlayer.JINGLES_SAX_10)
		await discard_all()
		create_deck_edit_menu()
	else:
		SoundPlayer.play_sound(SoundPlayer.JINGLES_SAX_11)
		need_points_label.show()

func score_popup(type: String, amount: int, pos: Vector2, duration: float, operator: String, combo: bool) -> void:
	var pop = POP_UP.instantiate()
	pop.operator = operator
	pop.amount = amount
	if combo:
		pop.combo()
	match type:
		"nice": 
			pop.mod = KenneyColors.BLUE
			SoundPlayer.play_sound(SoundPlayer.IMPACT_GLASS_LIGHT_000, 70)
		"exciting": 
			pop.mod = KenneyColors.RED
			SoundPlayer.play_sound(SoundPlayer.IMPACT_GLASS_MEDIUM_000, 70)
		_: pop.mod = KenneyColors.GREEN
	sub_viewport_container.add_child(pop)
	pop.position = pos * 16 * 3
	add_screenshake(0.7 - duration)
	await get_tree().create_timer(duration).timeout
	match type:
		"nice": nice_score += amount
		"exciting": exciting_score += amount
		_: pass
	total_score = nice_score * exciting_score

func new_game() -> void:
	all_cards = []
	for i in 48:
		var crd: Card
		match i % 24:
			0: crd = VERT_TRAIL_CARD.instantiate()
			1: crd = VERT_TRAIL_CARD.instantiate()
			2: crd = HORIZ_TRAIL_CARD.instantiate()
			3: crd = HORIZ_TRAIL_CARD.instantiate()
			4: crd = NORTH_EAST_TRAIL.instantiate()
			5: crd = NORTH_WEST_TRAIL.instantiate()
			6: crd = SOUTH_EAST_TRAIL.instantiate()
			7: crd = SOUTH_WEST_TRAIL.instantiate()
			8: crd = VERT_ROAD_CARD.instantiate()
			9: crd = VERT_ROAD_CARD.instantiate()
			10: crd = HORIZ_ROAD_CARD.instantiate()
			11: crd = HORIZ_ROAD_CARD.instantiate()
			12: crd = NORTH_EAST_ROAD.instantiate()
			13: crd = NORTH_WEST_ROAD.instantiate()
			14: crd = SOUTH_EAST_ROAD.instantiate()
			15: crd = SOUTH_WEST_ROAD.instantiate()
			16: crd = VERT_RAIL_CARD.instantiate()
			17: crd = VERT_RAIL_CARD.instantiate()
			18: crd = HORIZ_RAIL_CARD.instantiate()
			19: crd = HORIZ_RAIL_CARD.instantiate()
			20: crd = NORTH_EAST_RAIL.instantiate()
			21: crd = NORTH_WEST_RAIL.instantiate()
			22: crd = SOUTH_EAST_RAIL.instantiate()
			23: crd = SOUTH_WEST_RAIL.instantiate()
		add_card_to_all(crd)
	
func next_level(cards_to_add: Array[Card]) -> void:
	var deck_edit_screen = get_node("DeckEditMenu")
	for crd in cards_to_add:
		crd.get_parent().remove_child(crd)
		add_card_to_all(crd)
	if deck_edit_screen:
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(deck_edit_screen, "modulate:a", 0, 0.2)
		tween.tween_callback(deck_edit_screen.queue_free)
		await tween
	await discard_all()
	level += 1
	score_needed = 20 + 20 * ((level - 1) * 1.5)
	total_score = 0
	nice_score = 1
	exciting_score = 1
	deck_cards = []
	cards_in_play = {}
	
	var src_target_array: Array[Vector2] = generate_map(level)
	source = src_target_array[0]
	target = src_target_array[1]
	src_id = add_point_to_astar(source, ['N', 'S', 'E', 'W'])
	trgt_id = add_point_to_astar(target, ['N', 'S', 'E', 'W'])
	
	for crd in all_cards:
		add_card_to_deck(crd)
	await draw_cards_to_hand(6)
	
	discard_draw_button.text = "Discard & Draw"
	discard_draw_button.modulate = Color.WHITE

func _on_discard_draw_button_pressed() -> void:
	SoundPlayer.play_sound(SoundPlayer.CLICK_3)
	discard_draw_button.disabled = true
	if deck_cards.size() <= 0:
		discard_draw_button.disabled = false
		game_over()
	else:
		await discard_all()
		await draw_cards_to_hand(6)
		discard_draw_button.disabled = false
	if deck_cards.size() <= 0:
		discard_draw_button.text = "End Game"
		discard_draw_button.modulate = KenneyColors.YELLOW
	else:
		discard_draw_button.text = "Discard & Draw"
		discard_draw_button.modulate = Color.WHITE
	
func discard_all() -> void:
	hand_cards.reverse()
	for card in hand_cards:
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(card, "global_position", $Control/DeckContainer.global_position, 0.25)
		tween.parallel().tween_property(card, "modulate:a", 0.0, 0.25)
		SoundPlayer.play_sound(SoundPlayer.BOOK_FLIP_3)
		await get_tree().create_timer(0.25).timeout
		add_screenshake(0.25)
		hand_container.remove_child(card)
	if not level == 0: await get_tree().create_timer(0.25).timeout
	hand_cards.clear()
	
func add_screenshake(amount: float) -> void:
	shake = min(shake + amount, 1.0)
	
func screenshake() -> void: 
	var decay := 0.8
	var max_offset := Vector2(20, 20)
	var power = 2
	var amount = pow(shake, power)
	$Control.position.x = max_offset.x * amount * randi_range(-1, 1)
	$Control.position.y = max_offset.y * amount * randi_range(-1, 1)
		


func _on_restart_button_pressed() -> void:
	SoundPlayer.play_sound(SoundPlayer.CLICK_4)
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	SoundPlayer.play_sound(SoundPlayer.CLICK_4)
	get_tree().quit()
	
func pause() -> void:
	SoundPlayer.play_sound(SoundPlayer.CLICK_5)
	pause_end_panel.show()
	pause_label.show()
	try_again_label.hide()
	resume_button.show()
	
func unpause() -> void:
	SoundPlayer.play_sound(SoundPlayer.CLICK_4)
	pause_end_panel.hide()
	
func game_over() -> void:
	SoundPlayer.play_sound(SoundPlayer.JINGLES_SAX_03)
	SoundPlayer.stop_music()
	pause_end_panel.show()
	pause_label.hide()
	try_again_label.show()
	resume_button.hide()


func _on_resume_button_pressed() -> void:
	unpause()


func _on_discard_draw_button_mouse_entered() -> void:
	SoundPlayer.play_sound(SoundPlayer.ROLLOVER_2)


func _on_effect_volume_h_slider_value_changed(value: float) -> void:
	var effect_bus = AudioServer.get_bus_index("Effects")
	AudioServer.set_bus_volume_db(effect_bus, linear_to_db(value / 100.0))


func _on_music_volume_h_slider_value_changed(value: float) -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value / 100.0))


func _on_resume_button_mouse_entered() -> void:
	SoundPlayer.play_sound(SoundPlayer.ROLLOVER_4)


func _on_restart_button_mouse_entered() -> void:
	SoundPlayer.play_sound(SoundPlayer.ROLLOVER_4)


func _on_quit_button_mouse_entered() -> void:
	SoundPlayer.play_sound(SoundPlayer.ROLLOVER_4)
	
func create_deck_edit_menu():
	var deck_edit_menu = DECK_EDIT_MENU.instantiate()
	deck_edit_menu.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(deck_edit_menu, "modulate:a", 1.0, 0.5)
	add_child(deck_edit_menu)
	deck_edit_menu.next_level.connect(next_level)
	all_cards.shuffle()
	var arr = [FOREST, HILLS, MOUNTAIN, FLOWER_FIELD]
	var arr2 = [VERT_RAIL_CARD, VERT_ROAD_CARD, VERT_TRAIL_CARD, \
			HORIZ_RAIL_CARD, HORIZ_ROAD_CARD, HORIZ_TRAIL_CARD]
	for i in 4:
		var crd = all_cards.pop_front()
		deck_edit_menu.add_card_to_delete_list(crd)
		if i % 2:
			var crd2 = arr.pick_random().instantiate()
			deck_edit_menu.add_card_to_add_list(crd2)
		else:
			var crd2 = arr2.pick_random().instantiate()
			deck_edit_menu.add_card_to_add_list(crd2)
	
