extends Area2D

@export var attack_speed = 1
@export var attack_damage = 1
@export var speed = 100
@export var hp = 4

enum State {
	IDLE,
	ACTIVE,
	ATTACKING,
	HITTED,
	ATTACKING_BASE,
	DEAD
}

var state = State.ACTIVE
var direction = Vector2.ZERO
var target = null
var attack_cooldown = attack_speed
var base
var prev_state
var game

func _ready():
	base = get_tree().get_nodes_in_group("Base")[0]
	game = get_node("/root/Game")

	$Health.max_value = hp
	$Health.value = hp
	$Health.hide()

func activate(base_node):
	base = base_node

	face_toward(base.global_position)
	state = State.ACTIVE

func face_toward(target_pos: Vector2):
	direction = position.direction_to(base.position)

	if direction.x > 0:
		scale.x = -1
	else:
		scale.x = 1

	$Visual.look_at(target_pos)

func hit(damage):
	hp -= damage
	$Health.show()
	prev_state = state
	state = State.HITTED
	$AnimationPlayer.play("Hit")
	attack_cooldown = 0.5
	$Health.value = hp
	if hp <= 0:
		$Health.hide()
		die()

func die():
	$Visual.hide()
	monitorable = false
	monitoring = false
	$Splash.emitting = true
	$Splash.finished.connect(func():
		queue_free())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game.paused:
		return

	if state == State.DEAD:
		return

	if state == State.ACTIVE:
		if position.distance_to(base.position) < 100:
			state = State.ATTACKING_BASE
			target = base

		position += direction * speed * delta
		return

	if state == State.HITTED:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			state = prev_state

	if state == State.ATTACKING or state == State.ATTACKING_BASE:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			attack_cooldown = attack_speed
			attack()

func attack():
	$AnimationPlayer.play("Attack")
	if target:
		target.hit(attack_damage)
	else:
		if state != State.ATTACKING_BASE:
			state = State.ACTIVE

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		# TODO
		return
		target = area
		state = State.ATTACKING


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$AnimationPlayer.play("Swimming")
