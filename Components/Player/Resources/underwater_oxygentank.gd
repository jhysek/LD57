class_name UnderwaterOxygenTank
extends BehaviorResource

@export var CAPACITY = 30

var remains = CAPACITY
var oxygen_depleting = false

func on_ready(parent):
	super(parent)
	remains = character.game.parameters.oxygen_tank_seconds
	character.oxygen_tank_using.connect(on_oxygen_mode_changed)

func update_oxygen_tank_secods(new_value):
	CAPACITY = character.parameters.oxygen_tank_seconds

func on_oxygen_mode_changed(depleting: bool):
	oxygen_depleting = depleting

func set_remains(new_value):
	remains = new_value
	if remains > character.game.parameters.oxygen_tank_seconds:
		remains = character.game.parameters.oxygen_tank_seconds
	character.emit_signal("oxygen_level_changed", remains)

func on_process(delta):
	if character.game.paused:
		return

	if oxygen_depleting:
		remains -= delta

		if remains <= 0:
			remains = 0
			character.hit(3 * delta)
		character.emit_signal("oxygen_level_changed", remains)

	else:
		remains += delta * 5

		if remains > character.game.parameters.oxygen_tank_seconds:
			remains = character.game.parameters.oxygen_tank_seconds
		# Heal player
		character.heal(delta)
		character.emit_signal("oxygen_level_changed", remains)
