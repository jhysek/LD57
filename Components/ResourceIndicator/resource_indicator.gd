extends Panel

var value = 0
var max = 0

func update(_value, _max):
	value = _value
	max = _max
	$Label.text = str(value) + " / " + str(max)

func update_amount(amount):
	value = amount
	$Label.text = str(value) + " / " + str(max)
	if value <= 0:
		queue_free()
