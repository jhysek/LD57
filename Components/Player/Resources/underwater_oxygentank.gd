class_name UnderwaterOxygenTank
extends BehaviorResource

@export var CAPACITY = 100

var remains = CAPACITY
var oxygen_depleting = false

func on_ready(parent):
	super(parent)
	print(character)
	# character.oxygentank_using.connect(on_oxygen_mode_changed)

func on_oxygen_mode_changed(depleting: bool):
	print("Depleting oxygen: " + str(depleting))
	oxygen_depleting = depleting
