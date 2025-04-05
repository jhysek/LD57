extends Node2D

@export var map: TileMapLayer
@export var indicator: Sprite2D
@export var player: CharacterBody2D
@export var cam: Camera2D

var current_tile = null

func _ready():
	assert(map, "Map has to be assigned!")
	assert(indicator, "Indicator has to be assigned!")
	assert(player, "Player has to be assigned!")
	assert(cam, "Camera has to be assigned")
	$Enemies/Enemy.activate($Base)
	$MiningDrone.init(map, $Base.position)

func _input(event):
	if event is InputEventMouse:
		var mouse_pos = get_global_mouse_position()
		var tile_pos = map.world_to_map(mouse_pos)
		var tile = map.get_cell(tile_pos)

		indicator.position = map.map_to_world(tile_pos)

		if map.is_breakable(tile_pos):
			current_tile = tile_pos
			indicator.show()
		else:
			current_tile = null
			indicator.hide()

	if event is InputEventMouseButton and event.pressed:
		var player_map_pos = map.world_to_map(player.position)

		if current_tile and map.are_neighbors(player_map_pos, current_tile):
			map.hit(current_tile, player.params.mining_damage)
