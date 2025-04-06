class_name UnderwaterSwimming
extends BehaviorResource

@export var SPEED: int = 50000
var cam: Camera2D

var movement: BehaviorResource;
var arm_light

func on_ready(parent):
	super(parent)
	movement = character.get_behavior_by_name('topdown_walking')
	assert(movement)

	cam = character.get_viewport().get_camera_2d()
	arm_light = character.get_node("Visual/Body/ArmLeft/Flashlight")

func on_physics_process(delta):
	if !enabled:
		return

	var pos = character.position
	var target = pos + (movement.direction * SPEED * delta)

	if movement.direction == Vector2.ZERO:
		target = pos - Vector2(0, 200)

	var mouse_pos = cam.get_global_mouse_position()
	arm_light.look_at(mouse_pos)
	arm_light.rotation += PI/1.5

	var angle = (target - character.global_position).angle() + PI / 2
	character.global_rotation = lerp_angle(character.global_rotation, angle, delta * 3)
