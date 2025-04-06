extends Node2D

func _ready() -> void:
	Transition.openScene()

func _on_start_pressed() -> void:
	Transition.switchTo("res://game.tscn")
