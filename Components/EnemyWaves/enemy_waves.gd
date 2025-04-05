extends Node2D

@export var max_waves = 20


enum State {
	IDLE,
	WAITING,
	SPAWNING
}

var WAVES = [
	{
		delay = 120,
		enemies = []
	},
	{
		delay = 120,
		enemies = []
	}
]

var STATE = State.WAITING

var current_wave = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
