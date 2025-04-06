extends Area2D

var SPEED = 1000
var fired = false
var direction = Vector2(0,0)
var livespan = 2
var damage = 1
var fired_by


func _process(delta: float) -> void:
	if fired:

		position += direction * delta * SPEED
		print("BULET POS: " + str(position))

		livespan -= delta
		if livespan <= 0:
			print("BULLED IS TOO OLD")
			queue_free()

func fire(self_area, to, damage):
	fired_by = self_area
	direction = to
	$Sprite.rotation = atan2(direction.y, direction.x)
	print("BULLET FIRED")
	fired = true

func _on_area_entered(area: Area2D) -> void:
	if area != fired_by && area.is_in_group("Hittable"):
		print("Bullet hitted to " + str(area.name))
		area.hit(damage)
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Map":
		print("HIT TO MAP")
		queue_free()
