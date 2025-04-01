class_name PlatformerWalking
extends BehaviorResource

@export var SPEED: int = 5000
var direction: Vector2 = Vector2.ZERO

func on_process(delta):
	if !enabled:
		return

	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_left"):
		direction += Vector2.LEFT
		character.velocity.x = max(character.velocity.x - SPEED * delta, -SPEED * delta)

	if Input.is_action_pressed("ui_right"):
		direction += Vector2.RIGHT
		character.velocity.x = min(character.velocity.x + SPEED * delta, SPEED * delta)

	if direction == Vector2.ZERO:
		character.velocity.x = 0
