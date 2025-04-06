extends TileMapLayer

var Particles = preload("res://Components/World/particles.tscn")
var ResourceIndicator = preload("res://Components/ResourceIndicator/resource_indicator.tscn")

var tile_size = 16
var map_size = Vector2(0,0)
var nav: AStar2D

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
	crystal = {},
	total_iridium = 0,
	total_crystal = 0
}

func _ready() -> void:
	tile_size = tile_set.tile_size.x

	var rect = get_used_rect()
	map_size = rect.end - rect.position

	init_resources()

	nav = AStar2D.new()
	refresh_nav()


func init_resources():
	for iridium in get_used_cells_by_id(RESOURCE_IRIDIUM):
		var capacity = randi_range(50,80)
		resources.iridium[iridium] = {
			remaining = capacity,
			max = capacity,
			indicator_node = null
		}
		resources.total_iridium += capacity

		if !neighbors_with_accessible(iridium):
			set_cell(iridium, CELL_DIRT_1, Vector2.ZERO)

	for crystal in get_used_cells_by_id(RESOURCE_CRYSTAL):
		var capacity = randi_range(20,30)
		resources.crystal[crystal] = {
			remaining = capacity,
			max = capacity,
			indicator_node = null
		}
		resources.total_crystal += capacity
		if !neighbors_with_accessible(crystal):
			set_cell(crystal, CELL_DIRT_1, Vector2.ZERO)

	print("TOTAL RESOURCES: " + str(resources.total_iridium) + " / " + str(resources.total_crystal))

func reveal_resource(digged_map_pos):
	for iridium in resources.iridium:
		if are_neighbors(digged_map_pos, iridium):
			set_cell(iridium, RESOURCE_IRIDIUM, Vector2.ZERO)
			# TODO: add indicator

	for crystal in resources.crystal:
		if are_neighbors(digged_map_pos, crystal):
			set_cell(crystal, RESOURCE_CRYSTAL, Vector2.ZERO)

func decrease_resource_amount(type, map_pos, by_amount):
	if type == "iridium" and resources.iridium.has(map_pos):
		resources.iridium[map_pos].remaining -= by_amount
		if resources.iridium[map_pos].indicator_node:
			resources.iridium[map_pos].indicator_node.update_amount(resources.iridium[map_pos].remaining)

		if resources.iridium[map_pos].remaining <= 0:
			set_cell(map_pos, CELL_EMPTY, Vector2.ZERO)

func is_breakable(map_pos: Vector2):
	var cell_id = get_cell(map_pos)
	return cell_id >= 0 && cell_id != CELL_UNBREAKABLE

func hit(map_pos: Vector2, hp: int):
	if !is_breakable(map_pos):
		return

	if !states.has(map_pos):
		states[map_pos] = tile_hitpoints

	dig_effect(map_pos)

	states[map_pos] -= hp
	update_tile_state(map_pos)

func dig_effect(map_pos):
	var particles = Particles.instantiate()
	particles.position = map_to_world(map_pos)
	add_child(particles)
	particles.emitting = true

func update_tile_state(map_pos):
	if states.has(map_pos):
		var hp = states[map_pos]
		if hp <= 0:
			set_cell(map_pos, -1)
			reveal_resource(map_pos)
			refresh_nav()
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

func refresh_nav():
	var rect = get_used_rect()

	# Add nodes
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			if accessible_cell(Vector2(x, y)):
				nav.add_point(get_cell_id_vec(Vector2(x, y)), Vector2(x, y))

	# Add connections
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			if nav.has_point(get_cell_id_vec(Vector2i(x,y))):
				var neighbors = get_surrounding_cells(Vector2i(x, y))
				for neighbor in neighbors:
					if nav.has_point(get_cell_id_vec(neighbor)) and accessible_cell(neighbor):
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


func get_resource_tile_neighbor(resource_type):
	var resource_cells = []
	var resource_id = null

	if resource_type == "iridium":
		resource_id = RESOURCE_IRIDIUM

	if resource_type == "crystal":
		resource_id = RESOURCE_CRYSTAL

	if !resource_id:
		return null

	resource_cells = resource_cells + get_used_cells_by_id(resource_id)

	if resource_cells.is_empty():
		return null

	for resource in resource_cells:
		if accessible_cell(resource + Vector2i.UP):
			return {
				resource = resource,
				neighbor = resource + Vector2i.UP
			}

		if accessible_cell(resource + Vector2i.DOWN):
			return {
				neighbor = resource + Vector2i.DOWN,
				resource = resource
			}

		if accessible_cell(resource + Vector2i.LEFT):
			return {
				resource = resource,
				neighbor = resource + Vector2i.LEFT
			}

		if accessible_cell(resource + Vector2i.RIGHT):
			return {
				resource = resource,
				neighbor = resource + Vector2i.RIGHT
			}

	return null
