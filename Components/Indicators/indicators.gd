extends Control

var iridium = 0
var crystal = 0
var oxygen = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func update_iridium(new_count):
	iridium = new_count
	var iridium_count = $IridiumCount
	iridium_count.text = str(iridium)
	$AnimationPlayer.play("IridiumBounce")

func update_crystals(new_count):
	crystal = new_count
	$CrystalCount.text = str(crystal)
	$AnimationPlayer.play("CrystalBounce")

func update_oxygen(new_count):
	oxygen = new_count
	$OxygenProgress.value = oxygen

func set_oxygen_max(new_max):
	$OxygenProgress.max_value = new_max
	if $OxygenProgress.value > new_max:
		$OxygenProgress.value = new_max
