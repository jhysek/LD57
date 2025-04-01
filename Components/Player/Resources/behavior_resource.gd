class_name BehaviorResource
extends Resource

var required_behaviors = []
var character: CharacterBody2D;
@export var enabled = true;

func on_ready(parent):
	character = parent
	assert(character)
	assert_required_behaviors()

func assert_required_behaviors():
	for required in required_behaviors:
		assert(character.get_behavior_by_name(required))

func enable():
	if !enabled:
		enabled = true
		on_enabled()

func disable():
	if enabled:
		enabled = false
		on_disabled()

func on_input(event):
	pass

func on_process(delta):
	pass

func on_physic_process(delta):
	pass

func on_enabled():
	pass

func on_disabled():
	pass
