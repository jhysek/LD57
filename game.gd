extends Node2D

@export var map: TileMapLayer
@export var indicator: Sprite2D
@export var player: CharacterBody2D
@export var cam: Camera2D

@export var oxygen_tank_seconds: int = 30

var ShopItem = preload("res://Components/ShopItem/item.tscn")
var MiningBot = preload("res://Components/MiningDrone/mining_drone.tscn")
var DefensiveBot = preload("res://Components/DefenceDrone/defensive_drone.tscn")

var current_tile = null
var paused = false
var player_inventory = null
var goals_left = 2

var parameters = {
	player_inventory_size = 3,

	iridium_bots_carry = 1,
	crystal_bots_carry = 1,

	oxygen_tank_seconds = oxygen_tank_seconds,
	drill_damage = 1,
	fire_damage = 1,
	shoot_speed = 1,

	drone_damage = 1,
	drone_attack_cooldown = 2,
	drone_max_shots = 1
}

var inventory = {
	iridium = 1000,
	crystal = 500,
	oxygen = oxygen_tank_seconds
}

var deals = [
	{
		title = "Oxygen   tank   size",
		level = 0,
		max_levels = 20,
		price_iridium = 10,
		price_crystals = 0,
		iridium_multiplier = 1.1,
		crystal_multiplier = 1,
		parameter_name = "oxygen_tank_seconds",
		parameter_multiplier = 1.1,
		node = null
	},

	{
		title = "Backpack   size",
		level = 3,
		max_levels = 10,
		price_iridium = 10,
		price_crystals = 0,
		iridium_multiplier = 1.2,
		crystal_multiplier = 1,
		parameter_name = "player_inventory_size",
		parameter_addition = 1,
		node = null
	},

	{
		title = "Drill   efficiency",
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
		title = "Weapon   damage",
		level = 0,
		max_levels = 10,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		parameter_name = "fire_damage",
		parameter_addition = 1,
		node = null
	},

	{
		title = "Drone  shooting  speed",
		level = 0,
		max_levels = 10,
		price_iridium = 5,
		price_crystals = 5,
		iridium_multiplier = 1.25,
		crystal_multiplier = 1.01,
		parameter_name = "shoot_speed",
		parameter_multiplier = 1.19,
		node = null
	},

	{
		title = "Iridium   mining   drone",
		level = 0,
		price_iridium = 20,
		price_crystals = 0,
		iridium_multiplier = 1.2,
		crystal_multiplier = 1,
		action = "iridium_bot",
		node = null
	},

	{
		title = "Crystal   mining   drone",
		level = 0,
		price_iridium = 20,
		price_crystals = 10,
		iridium_multiplier = 1.2,
		crystal_multiplier = 1.14,
		action = "crystal_bot",
		node = null
	},

	{
		title = "Defensive   drone",
		level = 0,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.2,
		crystal_multiplier = 1.3,
		action = "defensive_bot",
		node = null
	},

	{
		title = "Submarine   repair   10%",
		level = 0,
		price_iridium = 20,
		price_crystals = 5,
		iridium_multiplier = 1.1,
		crystal_multiplier = 1.1,
		parameter_name = "submarine_hp",
		parameter_addition = 10,
		node = null
	},

	{
		title = "GOAL 1:  Fix   engine",
		level = 0,
		max_levels = 1,
		price_iridium = 200,
		price_crystals = 100,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		action = "goal_1",
		node = null
	},

	{
		title = "GOAL 2:   Fuel   for   escape",
		level = 0,
		max_levels = 1,
		price_iridium = 0,
		price_crystals = 100,
		iridium_multiplier = 1.3,
		crystal_multiplier = 1.5,
		action = "goal_2",
		node = null
	}
]

func _ready():
	Transition.openScene()
	assert(map, "Map has to be assigned!")
	assert(indicator, "Indicator has to be assigned!")
	assert(player, "Player has to be assigned!")
	assert(cam, "Camera has to be assigned")

	player.upgrade_parameter("oxygen_tank_seconds", parameters.oxygen_tank_seconds)
	$UI/Indicators.set_oxygen_max(parameters.oxygen_tank_seconds)
	$UI/Indicators.update_crystals(inventory.crystal)
	$UI/Indicators.update_iridium(inventory.iridium)

	player_inventory = player.inventory

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
		deal.price_iridium = round(deal.price_iridium * deal.iridium_multiplier)
		deal.price_crystals = round(deal.price_crystals * deal.crystal_multiplier)

		if deal.has("parameter_name"):
			assert(parameters.has(deal.parameter_name), "Parameters don't have '" + deal.parameter_name + "' refered by a deal.")
			if deal.has("parameter_multiplier"):
				parameters[deal.parameter_name] *= deal.parameter_multiplier
				parameters[deal.parameter_name] = round(parameters[deal.parameter_name])

			if deal.has("parameter_addition"):
				parameters[deal.parameter_name] += deal.parameter_addition

				print(parameters[deal.parameter_name])

			if deal.parameter_name == "player_inventory_size":
				player_inventory.refresh()

		if deal.has("action"):
			match deal.action:
				'iridium_bot':
					deploy_mining_bot("iridium")

				'crystal_bot':
					deploy_mining_bot("crystal")

				'defensive_bot':
					deploy_defensive_bot()

				'goal_1':
					$Base.fix()
					goals_left -= 1
					if goals_left <= 0:
						finished()

				'goal_2':
					$Base.fuel()
					goals_left -= 1
					if goals_left <= 0:
						finished()

		for d in deals:
			d.node.update_deal_info()

func finished():
	Transition.switchTo("res://Scenes/Finished.tscn")

func has_enough_resources(deal):
	return inventory.iridium >= deal.price_iridium && inventory.crystal >= deal.price_crystals

func deploy_mining_bot(type):
	print("DEPLOYING bot for " + type)
	var miner = MiningBot.instantiate()
	miner.position = $Base.position
	add_child(miner)
	miner.init(map, $Base.position, type)

	miner.resource_offloaded.connect(func(type):
		print("RESOURCE OFFLOADED: " + type)
		if type == "iridium":
			update_inventory(type, parameters.iridium_bots_carry)
		if type == "crystal":
			update_inventory(type, parameters.crystal_bots_carry)
		)

func deploy_defensive_bot():
	print("instantiating")
	var bot = DefensiveBot.instantiate()
	bot.position = $Base.global_position - Vector2(0, 80)
	add_child(bot)
	var route = $PatrolRoute.get_children().map(func(marker): return marker.global_position)
	bot.init(self, route)

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
	$Sfx/Click.play()
	for deal in deals:
		if paused:
			deal.node.close()
		else:
			deal.node.open()
	paused = !paused

func _on_map_resource_mined(type: Variant) -> void:
	player_inventory.add(type)

func _on_to_menu_pressed() -> void:
	Transition.switchTo("res://Scenes/menu.tscn")

func _on_revive_pressed() -> void:
	$Base.heal($Base.full_hp)
	player.heal(player.full_hp)
	player.state = player.State.IDLE
	paused = false
	$UI/Died.hide()
	$UI/Died.position = Vector2(-1000, -1000)

func _on_player_player_died() -> void:
	print("PLAYER DIED")
	paused = true
	$UI/Died.show()

func _on_base_base_destroyed() -> void:
	print("BASE DESTROYED")
	paused = true
	$UI/Died.show()
