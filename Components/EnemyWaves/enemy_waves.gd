extends Node2D

var Enemy1 = preload("res://Components/Fish1/enemy.tscn")
var Enemy2 = preload("res://Components/Fish2/fish_2.tscn")

var next_spawn_delay = 0
var cooldown = 0
var enemy_pool = []
var spawn_points = []
var game: Node2D
var seconds = 0

enum State {
	IDLE,
	WAITING_FOR_WAVE,
	SPAWNING,
	WAITING_FOR_CLEARING,
	DONE
}

var waves = [
  { delay = 10, enemies = [1, 1] },
  { delay = 33, enemies = [1, 1, 1] },
  { delay = 36, enemies = [1, 1, 1, 1] },
  { delay = 40, enemies = [1, 1, 1, 1, 1] },
  { delay = 44, enemies = [1, 1, 2, 1, 1] },
  { delay = 48, enemies = [1, 1, 2, 1, 2, 1] },
  { delay = 53, enemies = [1, 1, 2, 2, 1, 2] },
  { delay = 58, enemies = [1, 1, 2, 2, 2, 1, 2] },
  { delay = 64, enemies = [1, 1, 2, 2, 2, 2, 1] },
  { delay = 70, enemies = [1, 1, 2, 2, 2, 2, 2] },
  { delay = 77, enemies = [1, 1, 2, 2, 2, 2, 2, 1] },
  { delay = 85, enemies = [1, 1, 2, 2, 2, 2, 2, 2] },
  { delay = 93, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 1] },
  { delay = 102, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2] },
  { delay = 112, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 1] },
  { delay = 123, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2] },
  { delay = 135, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1] },
  { delay = 148, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2] },
  { delay = 163, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1] },
  { delay = 179, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2] },
  { delay = 197, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1] },
  { delay = 217, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2] },
  { delay = 238, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1] },
  { delay = 261, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2] },
  { delay = 287, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1] },
  { delay = 315, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2] },
  { delay = 347, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1] },
  { delay = 381, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2] },
  { delay = 419, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1] },
  { delay = 461, enemies = [1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2] }
]

var current_wave = 0

var state = State.WAITING_FOR_WAVE

func _ready():
	game = get_node("/root/Game")
	for spawn_point in get_tree().get_nodes_in_group("SpawnPoint"):
		spawn_points.append(spawn_point.global_position)
	start_wave()

func start_wave():
	$Label.show()
	var wave = waves[current_wave]
	cooldown = wave.delay
	state = State.WAITING_FOR_WAVE

func _process(delta):
	if game.paused:
		return

	if state == State.DONE:
		return

	if state == State.WAITING_FOR_WAVE:
		cooldown -= delta
		var prev_seconds = seconds
		seconds = round(cooldown)

		$Label.text = "Next  wave  in  " + str(seconds) + "   s"
		if prev_seconds > seconds && seconds <= 5:
			if seconds == 0:
				$Sfx/Incoming.play()
			else:
				$Sfx/Tick.pitch_scale = 1 + (5 - seconds) * 0.02
				$Sfx/Tick.play()

		if cooldown <= 0:
			state = State.SPAWNING
			$Label.text = "Wave  " + str(current_wave + 1) + "  incoming..."
			enemy_pool = waves[current_wave].enemies
			spawn_next_enemy_from_pool()
			cooldown = 0.5

	if state == State.SPAWNING:
		cooldown -= delta
		if cooldown <= 0:
			cooldown = randf_range(0.5, 3.0)
			spawn_next_enemy_from_pool()
			if enemy_pool.is_empty():
				state = State.WAITING_FOR_CLEARING

	if state == State.WAITING_FOR_CLEARING:
		$Label.hide()
		check_enemies()

func spawn_next_enemy_from_pool():
	if enemy_pool.size() == 0:
		return

	var enemy_type = enemy_pool.pop_front()
	var spawn_position = spawn_points.pick_random()
	var enemy
	if enemy_type == 1:
		enemy = Enemy1.instantiate()
	if enemy_type == 2:
		enemy = Enemy2.instantiate()

	enemy.position = spawn_position
	game.get_node("Enemies").add_child(enemy)
	enemy.activate(game.get_node("Base"))

func check_enemies():
	if get_tree().get_nodes_in_group("Enemy").size() == 0:
		current_wave += 1
		if current_wave > waves.size() - 1:
			state = State.DONE
		else:
			start_wave()
