extends BehaviorCharacter

signal oxygen_tank_using(enabled: bool)
signal oxygen_level_changed(new_value: float)

signal player_died

@onready var animation = $AnimationPlayer
@export var map: TileMapLayer
@export var hp = 20

var onboard = true
var parameters = {
	mining_damage = 1,
	oxygen_tank_seconds = 10,
	backpack_capacity = 1
}

var backpack = []

func _ready():
	super()
	assert(animation, "AnimationPlayer is missing?!")
	assert(map, "Please connect map to player")

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
