extends TileMapLayer

var tile_size = 16
var map_size = Vector2(0,0)
var nav: AStar2D
@onready var particles = $Particles

const CELL_EMPTY = -1
const CELL_DIRT_1 = 1
const CELL_DIRT_2 = 2
const CELL_BROKEN_3 = 5
const CELL_BROKEN_2 = 4
const CELL_BROKEN_1 = 3
const CELL_UNBREAKABLE = 6

const RESOURCE_IRIDIUM = 8
const RESOURCE_CRYSTAL = 9

@export var WALKABLE_IDS = [-1]
@export var RESOURCE_IDS = [RESOURCE_IRIDIUM, RESOURCE_CRYSTAL]

@export var tile_hitpoints = 10

var states = {}
var resources = {
	iridium = {},
	crystal = {}
}

func _ready() -> void:
	tile_size = tile_set.tile_size.x

	var rect = get_used_rect()
	map_size = rect.end - rect.position

	init_resources()

	nav = AStar2D.new()
	refresh_nav(nav)


func init_resources():
	for iridium in get_used_cells_by_id(RESOURCE_IRIDIUM):
		resources.iridium[iridium] = randi_range(20,80)
		if !neighbors_with_accessible(iridium):
			set_cell(iridium, CELL_DIRT_1, Vector2.ZERO)

	for crystal in get_used_cells_by_id(RESOURCE_CRYSTAL):
		resources.crystal[crystal] = randi_range(10,30)
		if !neighbors_with_accessible(crystal):
			set_cell(crystal, CELL_DIRT_1, Vector2.ZERO)

func reveal_resource(digged_map_pos):
	for iridium in resources.iridium:
		if are_neighbors(digged_map_pos, iridium):
			set_cell(iridium, RESOURCE_IRIDIUM, Vector2.ZERO)

	for crystal in resources.crystal:
		if are_neighbors(digged_map_pos, crystal):
			set_cell(crystal, RESOURCE_CRYSTAL, Vector2.ZERO)

func is_breakable(map_pos: Vector2):
	var cell_id = get_cell(map_pos)
	return cell_id >= 0 && cell_id != CELL_UNBREAKABLE

func hit(map_pos: Vector2, hp: int):
	if !is_breakable(map_pos):
		return

	if !states.has(map_pos):
		states[map_pos] = tile_hitpoints
	particles.position = map_to_world(map_pos)
	particles.emitting = true

	states[map_pos] -= hp
	update_tile_state(map_pos)

func dig_effect(map_pos):
	particles.position = map_to_world(map_pos)
	particles.emitting = true

func update_tile_state(map_pos):
	if states.has(map_pos):
		var hp = states[map_pos]
		if hp <= 0:
			set_cell(map_pos, -1)
			reveal_resource(map_pos)
			refresh_nav(nav)
		elif hp <= 3:
			set_cell(map_pos, CELL_BROKEN_3, Vector2.ZERO)
		elif hp <= 6:
			set_cell(map_pos, CELL_BROKEN_2, Vector2.ZERO)
		elif hp <= 8:
			set_cell(map_pos, CELL_BROKEN_1, Vector2.ZERO)

func are_neighbors(pos_a, pos_b):
	return abs(pos_a.x - pos_b.x) <= 1 && abs(pos_a.y - pos_b.y) <= 1

func world_to_map(pos: Vector2):
	return local_to_map(pos / scale)

func map_to_world(map_pos: Vector2i):
	return map_to_local(map_pos) * scale

func get_cell(map_pos):
	return get_cell_source_id(map_pos)

func get_cell_id(x, y) -> int:
	return int(y * map_size.x + x) + 10000

func get_cell_id_vec(vec: Vector2) -> int:
	return int(vec.y * map_size.x + vec.x) + 10000

func accessible_cell(map_pos):
	return WALKABLE_IDS.has(get_cell(map_pos))

func neighbors_with_accessible(map_pos):
	return WALKABLE_IDS.has(get_cell(map_pos + Vector2i.LEFT)) || \
		WALKABLE_IDS.has(get_cell(map_pos + Vector2i.RIGHT)) || \
		WALKABLE_IDS.has(get_cell(map_pos + Vector2i.UP)) || \
		WALKABLE_IDS.has(get_cell(map_pos + Vector2i.DOWN))

func refresh_nav(nav):
	var rect = get_used_rect()

	# Add nodes
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			if accessible_cell(Vector2(x, y)):
				nav.add_point(get_cell_id_vec(Vector2(x, y)), Vector2(x, y))

	# Add connections
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			# print(" => " + str(Vector2(x,y)))
			var neighbors = get_surrounding_cells(Vector2i(x, y))
			for neighbor in neighbors:
				if accessible_cell(neighbor):
					nav.connect_points(
						get_cell_id_vec(Vector2(x, y)),
						get_cell_id_vec(neighbor))


func add_label_to(pos, text):
	var label = Label.new()
	label.text = text
	label.position = pos - Vector2(16, 16)
	add_child(label)

func add_line(from, to):
	# print("Adding line... " + str(from) + " -> " + str(to))
	var line = Line2D.new()
	line.width = 2
	line.default_color = Color.WHEAT
	line.add_point(from)
	line.add_point(to)
	add_child(line)


func get_nearest_path(from, to):
	return Array(nav.get_point_path(get_cell_id_vec(Vector2(from.x, from.y)), get_cell_id_vec(Vector2(to.x, to.y))))


# TODO: multiple resource types....
func get_resource_tile_neighbor():
	var resource_cells = []

	for resource_id in RESOURCE_IDS:
		resource_cells = resource_cells + get_used_cells_by_id(resource_id)

	if resource_cells.is_empty():
		return null

	for resource in resource_cells:
		if accessible_cell(resource + Vector2i.UP):
			return resource + Vector2i.UP

		if accessible_cell(resource + Vector2i.DOWN):
			return resource + Vector2i.DOWN

		if accessible_cell(resource + Vector2i.LEFT):
			return resource + Vector2i.LEFT

		if accessible_cell(resource + Vector2i.RIGHT):
			return resource + Vector2i.RIGHT

	return null
