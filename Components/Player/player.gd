extends BehaviorCharacter

@onready var animation = $AnimationPlayer
@export var map: TileMapLayer

var onboard = true

func _ready():
	super()
	assert(animation, "AnimationPlayer is missing?!")
	assert(map, "Please connect map to player")

func set_boarded(is_boarded: bool):
	onboard = is_boarded
	if onboard:
		self_modulate = Color(1.0, 1.0, 1.0, 0.8)
	else:
		self_modulate = Color(1.0, 1.0, 1.0, 1)
