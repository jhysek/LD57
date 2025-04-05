extends Sprite2D

@export var hp = 100

var dead = false

signal hp_changed(new_hp)
signal base_destroyed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ProgressBar.max_value = hp
	$ProgressBar.value = hp

func set_light(on: bool):
	if dead:
		return
	$Light.enabled = on

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		set_light(true)
		body.set_boarded(true)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		set_light(false)
		body.set_boarded(false)

func hit(damage):
	hp -= damage
	print("BASE HIT! " + str(hp))
	if hp < $ProgressBar.max_value:
		$ProgressBar.visible = true

	$ProgressBar.value = hp
	if hp <= 0:
		hp = 0
	emit_signal("hp_changed", hp)
	destroyed()

func destroyed():
	emit_signal("base_destroyed")

	explode()

func explode():
	$AnimationPlayer.play("Explode")
