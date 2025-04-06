extends Node2D

var IndicatorIcon = preload("res://Components/Inventory/crystal_indicator.tscn")

var resources = []
var game
@onready var label = $Label


func _ready():
	game = get_node("/root/Game")

func full():
	return resources.size() >= game.parameters.player_inventory_size

func add(resource_type):
	if !full():
		print("Added resource " + resource_type)
		resources.append(resource_type)
		label.text = "Backpack   "  + str(resources.size()) + "   /  " + str(game.parameters.player_inventory_size)
		add_indicator(resource_type)
	else:
		print("Inventory full")

func refresh():
	label.text = "Backpack   "  + str(resources.size()) + "   /  " + str(game.parameters.player_inventory_size)

func add_indicator(type):
	var indicator = IndicatorIcon.instantiate()

	indicator.position = Vector2(resources.size() * 40, 0)
	$Indicators.add_child(indicator)
	indicator.init(type)

func pop():
	for child in $Indicators.get_children():
		child.queue_free()
	label.text = "Backpack   0   /  " + str(game.parameters.player_inventory_size)
	var content = resources
	resources = []
	return content
