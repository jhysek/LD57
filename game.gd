extends Node2D

@export var map: TileMapLayer
@export var indicator: Sprite2D
@export var player: CharacterBody2D
@export var cam: Camera2D

@export var oxygen_tank_seconds: int = 30

var ShopItem = preload("res://Components/ShopItem/item.tscn")
var current_tile = null
var paused = false

var parameters = {
	iridium_bots_carry = 1,
	crystal_bots_carry = 1,
	oxygen_tank_seconds = oxygen_tank_seconds
}

var inventory = {
	iridium = 10,
	crystal = 5,
	oxygen = oxygen_tank_seconds
}

var deals = [
	{
		title = "Oxygen   tank",
		level = 0,
		max_levels = 10,
		price_iridium = 10,
		price_crystals = 0,
		iridium_multiplier = 1.3,
		node = null
	},

	{
		title = "Drills",
		level = 0,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		node = null
	},

		{
		title = "Weapon",
		level = 0,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		node = null
	},

	{
		title = "Iridium   mining   drone",
		level = 0,
		price_iridium = 20,
		price_crystals = 0,
		iridium_multiplier = 1.3,
		node = null
	},

	{
		title = "Crystal   mining   drone",
		level = 0,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		node = null
	},

	{
		title = "Defensive   drone",
		level = 0,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		node = null
	},

	{
		title = "Submarine   repair   10%",
		level = 0,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		node = null
	},

	{
		title = "Fix   droplet   engine",
		level = 0,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		node = null
	},

	{
		title = "Fuel   for   escape",
		level = 0,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		node = null
	}
]

func _ready():
	assert(map, "Map has to be assigned!")
	assert(indicator, "Indicator has to be assigned!")
	assert(player, "Player has to be assigned!")
	assert(cam, "Camera has to be assigned")

	player.upgrade_parameter("oxygen_tank_seconds", parameters.oxygen_tank_seconds)
	$UI/Indicators.set_oxygen_max(parameters.oxygen_tank_seconds)

	initialize_deals()

	#####

	$Enemies/Enemy.activate($Base)
	$MiningDrone.init(map, $Base.position)
	$MiningDrone.resource_offloaded.connect(func(type):
		print("RESOURCE OFFLOADED: " + type)
		if type == "iridium":
			update_inventory(type, parameters.iridium_bots_carry)
		if type == "crystal":
			update_inventory(type, parameters.crystal_bots_carry)
		)

func update_inventory(resource, diff):
	if inventory.has(resource):
		inventory[resource] += diff
		if resource == 'iridium':
			$UI/Indicators.update_iridium(inventory.iridium)
		if resource == 'crystal':
			$UI/Indicators.update_crystals(inventory.crystal)

func initialize_deals():
	var idx = 0
	for deal in deals:
		var item = ShopItem.instantiate()
		item.position = Vector2(-50, idx * 50)
		item.init(self, idx)
		$UI/Upgrades.add_child(item)
		deals[idx].node = item
		idx += 1

func purchase(deal):
	if has_enough_resources(deal):
		inventory.iridium -= deal.price_iridium
		inventory.crystal -= deal.crystal



func has_enough_resources(deal):
	return inventory.iridium >= deal.price_iridium && inventory.crystal >= deal.price_crystals

func _input(event):
	if paused:
		return

	if event is InputEventMouse:
		var mouse_pos = get_global_mouse_position()
		var tile_pos = map.world_to_map(mouse_pos)

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
			map.hit(current_tile, player.parameters.mining_damage)

func _on_player_oxygen_level_changed(new_value: float) -> void:
	inventory.oxygen = new_value
	$UI/Indicators.update_oxygen(inventory.oxygen)


func _on_button_pressed() -> void:
	for deal in deals:
		if paused:
			deal.node.close()
		else:
			deal.node.open()
	paused = !paused
