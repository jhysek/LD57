extends Area2D

@export var attack_speed = 1
@export var attack_damage = 1
@export var speed = 100
@export var hp = 4

enum State {
	IDLE,
	ACTIVE,
	ATTACKING,
	ATTACKING_BASE
}

var state = State.ACTIVE
var direction = Vector2.ZERO
var target = null
var attack_cooldown = attack_speed
var base

func activate(base_node):
	base = base_node
	direction = position.direction_to(base.position)
	state = State.ACTIVE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == State.ACTIVE:
		if position.distance_to(base.position) < 100:
			state = State.ATTACKING_BASE
			target = base

		position += direction * speed * delta
		return

	if state == State.ATTACKING or state == State.ATTACKING_BASE:
		attack_cooldown -= delta
		if attack_cooldown <= 0:
			attack_cooldown = attack_speed
			attack()

func attack():
	if target && !target.dead:
		target.hit(attack_damage)
	else:
		if state != State.ATTACKING_BASE:
			state = State.ACTIVE

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		state = State.ATTACKING
