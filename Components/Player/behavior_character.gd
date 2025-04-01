class_name BehaviorCharacter
extends CharacterBody2D

var BehaviorResource = load("res://Components/Player/Resources/BehaviorResource.gd")

enum State {
	STATIC,
	PAUSED,
	IDLE,
	DEAD
}

@export var behaviors: Array[BehaviorResource];
@export var state: State = State.IDLE;

func _ready():
	for_each_behavior("on_ready", self)

func _process(delta):
	for_each_behavior("on_process", delta)

func _physics_process(delta):
	for_each_behavior("on_physics_process", delta)
	move_and_slide()

func _input(event):
	for_each_behavior("on_input", event)

func for_each_behavior(function_name, argument = null):
	for behavior in behaviors:
		if behavior != null and behavior.has_method(function_name):
			var callable = Callable(behavior, function_name)
			callable.call(argument)

func get_behavior_by_name(resource_name):
	for behavior in behaviors:
		if behavior.resource_name == resource_name:
			return behavior
	return null

func enable_behavior(resource_name):
	var behavior = get_behavior_by_name(resource_name)
	if behavior:
		behavior.enable()

func disable_behavior(resource_name):
	var behavior = get_behavior_by_name(resource_name)
	if behavior:
		behavior.disable
