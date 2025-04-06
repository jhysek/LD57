extends Sprite2D

func init(type):
	if type == "iridium":
		set_texture(load("res://Assets/iridium_piece.png"))
	if type == "crystal":
		set_texture(load("res://Assets/crystal_piece.png"))
	$AnimationPlayer.play("Pulse")
