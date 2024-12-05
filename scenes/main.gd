extends Node

@onready var tile_map_layer_feature: TileMapLayer = $Control/SubViewportContainer/SubViewport/TileMapLayerFeature

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Control/Card.card_dropped.connect(on_card_dropped)
	$Control/Card2.card_dropped.connect(on_card_dropped)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_card_dropped(card: Card, atlas_position: Vector2) -> void:
	print("card dropped heh")
	print(tile_map_layer_feature.get_local_mouse_position())
	print(tile_map_layer_feature.local_to_map(tile_map_layer_feature.get_local_mouse_position()))
	var cell_coord: Vector2i = tile_map_layer_feature.local_to_map(tile_map_layer_feature.get_local_mouse_position())
	tile_map_layer_feature.set_cell(cell_coord, 0, atlas_position)
	card.queue_free()
