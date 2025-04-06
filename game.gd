extends Node2D

@export var map: TileMapLayer
@export var indicator: Sprite2D
@export var player: CharacterBody2D
@export var cam: Camera2D

@export var oxygen_tank_seconds: int = 30

var ShopItem = preload("res://Components/ShopItem/item.tscn")
var MiningBot = preload("res://Components/MiningDrone/mining_drone.tscn")

var current_tile = null
var paused = false

var parameters = {
	iridium_bots_carry = 1,
	crystal_bots_carry = 1,
	oxygen_tank_seconds = oxygen_tank_seconds,
	drill_damage = 1,
	fire_damage = 1,

	drone_damage = 1,
	drone_attack_cooldown = 2,
	drone_max_shots = 1
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
		crystal_multiplier = 1.5,
		parameter_name = "oxygen_tank_seconds",
		parameter_multiplier = 1.1,
		node = null
	},

	{
		title = "Drills",
		level = 0,
		max_levels = 10,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		parameter_name = "drill_damage",
		parameter_addition = 1,
		node = null
	},

		{
		title = "Weapon",
		level = 0,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		parameter_name = "fire_damage",
		parameter_addition = 1,
		node = null
	},

	{
		title = "Iridium   mining   drone",
		level = 0,
		price_iridium = 20,
		price_crystals = 0,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		action = "iridium_bot",
		node = null
	},

	{
		title = "Crystal   mining   drone",
		level = 0,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		action = "crystal_bot",
		node = null
	},

	{
		title = "Defensive   drone",
		level = 0,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		action = "defensive_bot",
		node = null
	},

	{
		title = "Submarine   repair   10%",
		level = 0,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		parameter_name = "submarine_hp",
		parameter_addition = 10,
		node = null
	},

	{
		title = "Fix   droplet   engine",
		level = 0,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		action = "goal_1",
		node = null
	},

	{
		title = "Fuel   for   escape",
		level = 0,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		action = "goal_2",
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
	$UI/Indicators.update_crystals(inventory.crystal)
	$UI/Indicators.update_iridium(inventory.iridium)

	$Fish1.activate($Base)
	$Fish2.activate($Base)
	$Fish3.activate($Base)
	$Fish4.activate($Base)
	$Fish5.activate($Base)
	$Fish6.activate($Base)

	$MiningDrone.init(map, $Base.global_position, "iridium")
	$MiningDrone.resource_offloaded.connect(func(amount):
		update_inventory($MiningDrone.type, parameters.iridium_bots_carry)
		)
	$MiningDrone2.init(map, $Base.global_position, "crystal")
	$MiningDrone2.resource_offloaded.connect(func(amount):
		update_inventory($MiningDrone2.type, parameters.crystal_bots_carry)
		)
	$DefensiveDrone.init(self)

	initialize_deals()


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
		inventory.crystal -= deal.price_crystals
		$UI/Indicators.update_crystals(inventory.crystal)
		$UI/Indicators.update_iridium(inventory.iridium)
		deal.level += 1
		deal.price_iridium *= deal.iridium_multiplier
		deal.price_crystals *= deal.crystal_multiplier

		if deal.has("parameter_name"):
			assert(parameters.has(deal.parameter_name), "Parameters don't have '" + deal.parameter_name + "' refered by a deal.")
			if deal.has("parameter_multiplier"):
				parameters[deal.parameter_name] *= deal.parameter_multiplier
			if deal.has("parameter_addition"):
				parameters[deal.parameter_name] += deal.parameter_addition

		if deal.has("action"):
			match deal.action:
				'iridium_bot':
					deploy_iridium_bot()
				'crystal_bot':
					print("Deploying CRYSTAL BOT")
				'defensive_bot':
					print("Deploying DEFENSIVE BOT")

		for d in deals:
			d.node.update_deal_info()

func has_enough_resources(deal):
	return inventory.iridium >= deal.price_iridium && inventory.crystal >= deal.price_crystals

func deploy_iridium_bot():
	var miner = MiningBot.instantiate()
	miner.position = $Base.position
	add_child(miner)
	miner.init(map, $Base.position)
	miner.resource_offloaded.connect(func(type):
		print("RESOURCE OFFLOADED: " + type)
		if type == "iridium":
			update_inventory(type, parameters.iridium_bots_carry)
		if type == "crystal":
			update_inventory(type, parameters.crystal_bots_carry)
		)

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

		if !current_tile:
			player.shoot()

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
