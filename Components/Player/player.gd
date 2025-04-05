extends BehaviorCharacter

@onready var animation = $AnimationPlayer
@export var map: TileMapLayer

func _ready():
	super()
	assert(animation, "AnimationPlayer is missing?!")
	assert(map, "Please connect map to player")
