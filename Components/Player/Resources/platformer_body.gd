class_name PlatformerBody
extends BehaviorResource

@export var GRAVITY = 70 * 70;

func on_physics_process(delta):
	if !enabled:
		return

	if character.state == character.State.STATIC:
		return

	character.velocity.y += GRAVITY * delta
