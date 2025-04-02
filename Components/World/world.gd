extends TileMapLayer

var tile_size = 16
var map_size = Vector2(0,0)
var nav: AStar2D

@export var WALKABLE_IDS = [1, 2]

func _ready() -> void:
	tile_size = tile_set.tile_size.x

	var rect = get_used_rect()
	map_size = rect.end - rect.position

	nav = AStar2D.new()
	refresh_nav(nav)

func world_to_map(pos: Vector2):
	return local_to_map(pos / scale)

func map_to_world(map_pos: Vector2i):
	return map_to_local(map_pos) * scale

func get_cell(map_pos):
	return get_cell_source_id(map_pos)

func get_cell_id(x, y):
	return x * map_size.x + y

func get_cell_id_vec(vec: Vector2):
	return vec.x * map_size.x + vec.y

func accessible_cell(map_pos):
	return WALKABLE_IDS.has(get_cell(map_pos))

func refresh_nav(nav):
	var rect = get_used_rect()

	# Add nodes
	for x in range(rect.position.x, rect.size.x):
		for y in range(rect.position.y, rect.size.y):
			nav.add_point(get_cell_id(x, y), Vector2(x, y))

	# Add connections
	for x in range(rect.position.x, rect.size.x):
		for y in range(rect.position.y, rect.size.y):
			var neighbors = get_surrounding_cells(Vector2i(x, y))
			for neighbor in neighbors:
				if accessible_cell(neighbor):
					nav.connect_points(
						get_cell_id_vec(Vector2(x, y)),
						get_cell_id_vec(neighbor))

func get_nearest_path(from, to):
	return nav.get_point_path(get_cell_id(from.x, from.y), get_cell_id(to.x, to.y))
