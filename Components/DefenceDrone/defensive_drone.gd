extends Area2D

var Bullet = preload("res://Components/Bullet/bullet.tscn")
enum State {
	INITIALIZING,
	IDLE,
	PATROLING,
	ATTACKING
}

var hp = 20
var cooldown = 5
var state = State.INITIALIZING
var game

@onready var radar = $Radar

func init(_game):
	game = _game
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
		for enemy in radar.get_overlapping_areas():
			if enemy.is_in_group("Enemy"):
				$Sfx/Detected.play()
				state = State.ATTACKING

func patroling_handler(delta):
	cooldown -= delta
	if cooldown <= 0:
		cooldown = 1
		state = State.PATROLING
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
