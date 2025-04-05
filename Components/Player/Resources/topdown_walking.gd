class_name TopdownWalking
extends BehaviorResource

@export var SPEED: int = 5000
var direction: Vector2 = Vector2.ZERO

func on_process(delta):
	if character.state == character.State.DEAD:
		return

	if !enabled:
		return

	direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if direction.length() > 1.0:
		direction = direction.normalized()

	character.velocity = delta * SPEED * direction
	character.move_and_slide()
