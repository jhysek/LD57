extends BehaviorCharacter

signal oxygen_tank_using(enabled: bool)
signal oxygen_level_changed(new_value: float)
signal player_died

var Bullet = preload("res://Components/Bullet/bullet.tscn")

@onready var animation = $AnimationPlayer
@onready var visual = $Visual
@export var game: Node2D
@export var map: TileMapLayer
@export var hp = 20


var onboard = true
var parameters = {
	mining_damage = 1,
	oxygen_tank_seconds = 10,
	backpack_capacity = 1,
	fire_damage = 2
}

var backpack = []
var movement

func _ready():
	super()
	assert(animation, "AnimationPlayer is missing?!")
	assert(map, "Please connect map to player")
	assert(game, "Please assign game")

func upgrade_parameter(parameter_name, new_value):
	if parameter_name == "oxygen_tank_seconds":
		parameters.oxygen_tank_seconds = new_value
		get_behavior_by_name('oxygen_tank').update_oxygen_tank_secods(new_value)

func hit(damage):
	if state == State.DEAD:
		return

	hp -= damage

	print("PLAYER HIT. HP: " + str(hp))
	if hp <= 0:
		hp = 0
		die()

func shoot():
	var bullet = Bullet.instantiate()
	bullet.position = $Visual/Body/ArmRight/Spawner.global_position
	get_node("/root/Game").add_child(bullet)
	bullet.fire($Collider, bullet.position.direction_to(get_global_mouse_position()), game.parameters.fire_damage)

func die():
	print("PLAYER DIED")
	if state == State.DEAD:
		return
	state = State.DEAD
	emit_signal("player_died")

func set_boarded(is_boarded: bool):
	if state == State.DEAD:
		return

	onboard = is_boarded
	if onboard:
		self_modulate = Color(1.0, 1.0, 1.0, 0.8)
	else:
		self_modulate = Color(1.0, 1.0, 1.0, 1)

func flip(should_be_flipped):
	if should_be_flipped:
		visual.scale.x = -0.1
	else:
		visual.scale.x = 0.1

func swim():
	if !animation.current_animation == "Swim":
		animation.play("Swim")

func idle():
	if !animation.current_animation == "Idle":
		animation.play("Idle")


func _on_collider_area_entered(area: Area2D) -> void:
	if state == State.DEAD:
		return

	if area.is_in_group("AirSource"):
		emit_signal("oxygen_tank_using", false)

func _on_collider_area_exited(area: Area2D) -> void:
	if state == State.DEAD:
		return

	if area.is_in_group("AirSource"):
		emit_signal("oxygen_tank_using", true)


func _on_bubble_timer_timeout() -> void:
	$BubbleParticles.emitting = true
	$Sfx/Bubble.play()
