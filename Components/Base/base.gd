extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_light(on: bool):
	$Light.enabled = on

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		set_light(true)
		body.set_boarded(true)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		set_light(false)
		body.set_boarded(false)
