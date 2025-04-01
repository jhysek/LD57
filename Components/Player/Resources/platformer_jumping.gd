class_name PlatformerJumping
extends BehaviorResource

signal on_jumped
signal on_double_jumped
signal on_flapped

@export var SPEED: int = 5
@export var FLAP_SPEED  = 6
@export var COYOTE_TIME: int = 0.12
@export var DOUBLE_JUMP: bool = false
@export var FLAPPY_BIRD: bool = false

var in_air: bool = false
var double_jumped: bool = false
var jump_timeout: float = 0.0

func on_process(delta):
	if !enabled:
		return

	var grounded = character.is_on_floor()
	in_air = !grounded
	_handle_coyote_time(delta, grounded)

	if (grounded or !double_jumped) and Input.is_action_just_pressed("ui_jump"):
		if in_air and !DOUBLE_JUMP and !FLAPPY_BIRD:
			return

		if in_air and DOUBLE_JUMP and !FLAPPY_BIRD:
			double_jumped = true
			emit_signal("on_double_jumped")
		else:
			in_air = true
			double_jumped = false
			if FLAPPY_BIRD:
				emit_signal("on_flapped")
			else:
				emit_signal("on_jumped")

		jump_timeout = 0
		character.velocity.y = -SPEED


func _handle_coyote_time(delta, grounded):
	if grounded:
		in_air = false
		double_jumped = true
		jump_timeout = 0

	elif !in_air and jump_timeout <= 0:
		jump_timeout = COYOTE_TIME

	if jump_timeout > 0:
		jump_timeout -= delta
		if jump_timeout <= 0:
			in_air = true
