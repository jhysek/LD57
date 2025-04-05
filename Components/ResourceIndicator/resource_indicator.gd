extends Panel

func update(value, max):
	$Label.text = str(value) + " / " + str(max)
