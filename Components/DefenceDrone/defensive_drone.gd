extends Area2D

var Bullet = preload("res://Components/Bullet/bullet.tscn")
enum State {
	INITIALIZING,
	IDLE,
	PATROLING,
	ATTACKING
}

var hp = 20
var cooldown = 1
var state = State.INITIALIZING
var game
var route
var current_route_idx = 0
var target = null
var direction

@onready var radar = $Radar
@onready var SPEED = 50

func init(_game, patrol_path):
	game = _game
	route = patrol_path
	if game:
		state = State.IDLE

	$Health.max_value = hp
	$Health.value = hp
	$Health.hide()

func _process(delta: float) -> void:
	if state == State.IDLE:
		idle_handler(delta)
		return

	if state == State.PATROLING:
		patroling_handler(delta)
		return

	if state == State.ATTACKING:
		attacking_handler(delta)
		return

func hit(damage):
	hp -= damage
	$Health.value = hp
	$Health.show()

	if hp <= 0:
		$Health.hide()
		die()

func die():
	# TODO: explosion
	queue_free()

func idle_handler(delta):
	cooldown -= delta
	if cooldown <= 0:
		cooldown = 1
		state = State.PATROLING
		target = route[current_route_idx]
		direction = position.direction_to(target)
		for enemy in radar.get_overlapping_areas():
			if enemy.is_in_group("Enemy"):
				$Sfx/Detected.play()
				state = State.ATTACKING

func patroling_handler(delta):
	if !target:
		target = route[current_route_idx]

	if global_position.distance_to(target) <= 20:
		current_route_idx = (current_route_idx + 1) % route.size()
		target = route[current_route_idx]
		direction = position.direction_to(target)
	else:
		position += direction * delta * SPEED

	for enemy in radar.get_overlapping_areas():
		if enemy.is_in_group("Enemy"):
			$Sfx/Detected.play()
			state = State.ATTACKING

func attacking_handler(delta):
	cooldown -= delta

	if cooldown <= 0:
		cooldown = game.parameters.drone_attack_cooldown
		shoot()

func shoot():
	var shots = 0
	print(str(radar.get_overlapping_areas()))
	for enemy in radar.get_overlapping_areas():
		if enemy.is_in_group("Enemy"):
			var bullet = Bullet.instantiate()
			get_node("/root/Game").add_child(bullet)
			bullet.position = global_position
			bullet.fire(self, bullet.global_position.direction_to(enemy.global_position), game.parameters.drone_damage)
			$Sfx/Shoot.play()
			shots += 1
			if shots >= game.parameters.drone_max_shots:
				return
	if shots == 0:
		state = State.IDLE

func _on_radar_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		cooldown = game.parameters.drone_attack_cooldown
		state = State.ATTACKING

func _on_radar_area_exited(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		for enemy in get_overlapping_areas():
			if enemy.is_in_group("Enemy"):
				return
		cooldown = 1
		state = State.IDLE
