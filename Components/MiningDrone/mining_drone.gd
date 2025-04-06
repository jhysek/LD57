extends Area2D

var map: TileMapLayer

@export var speed = 100
@export var mining_time = 5
@export var resource_carry = 1
@export var hp = 10
@export var type = "iridium"
var digging_at = null

signal resource_offloaded(resource_type)

var dig_cooldown = 1

const IRIDIUM_UNIT_HP = 5
const CRYSTAL_UNIT_HP = 10

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
var resources = 0
var game

func init(world_map, base_pos, resource):
	game = get_node("/root/Game")
	type = resource
	map = world_map
	base_map_position = map.world_to_map(base_pos)

	if resource == "iridium":
		$Body/iridium.show()
	if resource == "crystal":
		$Body/crystal.show()

	assert(resource == "iridium" || resource == "crystal", "Invalid resource type for drone! '" + str(type) + "'")

	if map:
		state = State.IDLE
	else:
		print("NEMAME WORLD MAP")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game.paused:
		return

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
		var resource = map.get_resource_tile_neighbor(type)

		if resource:
			print("GOT RESOURCE, approaching...")
			var resource_tile_position = resource.neighbor
			digging_at = resource.resource

			cooldown = 1
			state = State.APPROACHING_RESOURCE
			route = map.get_nearest_path(map.world_to_map(position), resource_tile_position)

			if route.size() > 0:
				target = map.map_to_world(route.pop_front())
			else:
				state = State.IDLE


func approaching_resource_handler(delta):
	if target:
		var direction = position.direction_to(target)
		position += direction * delta * speed

		if position.distance_to(target) < 10:
			if route.size() > 0:
				target = map.map_to_world(route.pop_front())
			else:
				print("APPROACHED, mining... cooldown" + str(cooldown))
				target = null
				state = State.MINING
				cooldown = IRIDIUM_UNIT_HP / game.parameters.drill_damage

func approaching_base_handler(delta):
	if target:
		var direction = position.direction_to(target)
		position += direction * delta * speed

		if position.distance_to(target) < 10:
			if route.size() > 0:
				target = map.map_to_world(route.pop_front())
			else:
				target = null
				resources = 0
				emit_signal("resource_offloaded", type)
				state = State.IDLE
				cooldown = 1

func hit(damage):
	hp -= damage
	if hp <= 0:
		die()

func die():
	# TODO: explosion
	queue_free()

func mining_handler(delta):
	if cooldown >= 0:
		cooldown -= delta
	else:
		if digging_at:
			map.dig_effect(digging_at)
		$Sfx/Dig.play()
		resources += 1
		if type == "iridium":
			cooldown = IRIDIUM_UNIT_HP / game.parameters.drill_damage
		if type == "crystal":
			cooldown = CRYSTAL_UNIT_HP / game.parameters.drill_damage
		map.decrease_resource_amount(type, digging_at, 1)

		if resources >= game.parameters.drone_carry_amount:
			digging_at = null
			state = State.APPROACHING_BASE
			route = map.get_nearest_path(map.world_to_map(position), base_map_position)
			if route.size() > 0:
				target = map.map_to_world(route.pop_front())
