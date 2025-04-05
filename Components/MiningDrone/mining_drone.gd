extends Area2D

var map: TileMapLayer

@export var speed = 100
@export var mining_time = 5
@export var resource_carry = 1

signal resource_offloaded(resource_type)

var dig_cooldown = 1

enum State {
	INITIALIZING,
	IDLE,
	APPROACHING_RESOURCE,
	MINING,
	APPROACHING_BASE
}

var base_map_position = Vector2(0,0)
var state = State.INITIALIZING
var cooldown = 1
var route = []
var target = null

func init(world_map, base_pos):
	map = world_map
	base_map_position = map.world_to_map(base_pos)

	if map:
		state = State.IDLE
	else:
		print("NEMAME WORLD MAP")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == State.IDLE:
		idle_handler(delta)
		return

	if state == State.APPROACHING_RESOURCE:
		approaching_resource_handler(delta)
		return

	if state == State.MINING:
		mining_handler(delta)
		return

	if state == State.APPROACHING_BASE:
		approaching_base_handler(delta)
		return

func idle_handler(delta):
	cooldown -= delta
	if cooldown <= 0:
		print("IDLE... looking for a resource...")
		var resource_tile_position = map.get_resource_tile_neighbor()

		if resource_tile_position:
			cooldown = 1
			print("RESOURCE FOUND: " + str(resource_tile_position))
			state = State.APPROACHING_RESOURCE
			route = map.get_nearest_path(map.world_to_map(position), resource_tile_position)
			print("NEAREST PATH: " + str(route))

			if route.size() > 0:
				target = map.map_to_world(route.pop_front())

				print("TARGET: " + str(target))
				print("ROUTE: " + str(route))
			else:
				print("NO ROUTE....  idling")
				state = State.IDLE


func approaching_resource_handler(delta):
	if target:
		var direction = position.direction_to(target)
		position += direction * delta * speed

		if position.distance_to(target) < 10:
			if route.size() > 0:
				target = map.map_to_world(route.pop_front())
			else:
				print("NO MORE ROUTE: " + str(route) + " I guess I should mine now....")
				target = null
				state = State.MINING
				cooldown = mining_time

func approaching_base_handler(delta):
	if target:
		var direction = position.direction_to(target)
		position += direction * delta * speed

		if position.distance_to(target) < 10:
			if route.size() > 0:
				target = map.map_to_world(route.pop_front())
			else:
				target = null
				emit_signal("resource_offloaded", "iridium")
				state = State.IDLE
				cooldown = 1


func mining_handler(delta):
	if dig_cooldown >= 0:
		dig_cooldown -= delta
	else:
		pass
		# TODO
		# map.dig()
	if cooldown >= 0:
		cooldown -= delta
	else:
		cooldown = 1
		state = State.APPROACHING_BASE
		route = map.get_nearest_path(map.world_to_map(position), base_map_position)
		if route.size() > 0:
			target = map.map_to_world(route.pop_front())
