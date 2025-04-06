extends Sprite2D

@export var hp = 100
var full_hp = hp

var dead = false
var fixed = false
var fuelled = false

signal hp_changed(new_hp)
signal base_destroyed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ProgressBar.max_value = hp
	$ProgressBar.value = hp

func fix():
	fixed = true
	var tween = create_tween()
	tween.tween_property(self, 'rotation', 0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	$AnimationPlayer.play("Hovering")

func fuel():
	fuelled = true

func set_light(on: bool):
	if dead:
		return
	$Light.enabled = on

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		set_light(true)
		body.set_boarded(true)
		body.store_inventory()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		set_light(false)
		body.set_boarded(false)

func heal(diff):
	hp += diff
	$ProgressBar.value = round(hp)
	if hp >= full_hp:
		hp = full_hp
		$ProgressBar.value = full_hp
		$ProgressBar.hide()

func hit(damage):
	hp -= damage

	$AnimationPlayer.play("Hit")
	$Sfx/Hit.play()
	if hp < $ProgressBar.max_value:
		$ProgressBar.visible = true

	$ProgressBar.value = hp
	if hp <= 0:
		hp = 0
		destroyed()

	emit_signal("hp_changed", hp)

func destroyed():
	emit_signal("base_destroyed")
	explode()

func explode():
	$AnimationPlayer.play("Explode")
