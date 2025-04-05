extends Panel

@export var title = "Oxygen"
@export var price_iridium = 10
@export var price_crystals = 10
@export var output = "oxygen_lvl2"

var game: Node2D
var deal_idx
var original_pos

func init(_game, _deal_idx):
	game = _game
	deal_idx = _deal_idx
	original_pos = position
	position = Vector2(original_pos.x, -150 - _deal_idx * 50)
	modulate = Color(1,1,1,0)
	update_deal_info()

func update_deal_info():
	var deal = game.deals[deal_idx]
	$Name.text = deal.title
	$Price/Iridium.text = str(deal.price_iridium)

	if deal.price_crystals > 0:
		$Price/Crystal.text = str(deal.price_crystals)
		$Price/Crystal.show()
		$Price/CrystalIcon.show()
	else:

		$Price/Crystal.hide()
		$Price/CrystalIcon.hide()


func open():
	var deal = game.deals[deal_idx]
	if game.has_enough_resources(deal):
		$Name.modulate = Color(1,1,1,1)
	else:
		$Name.modulate = Color(1,1,1,0.3)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position", original_pos, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_delay(0.1)
	tween.tween_property(self, 'modulate', Color(1,1,1,1), 1)

func close():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position", Vector2(original_pos.x, -150 - deal_idx * 50), 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_delay(0.1)
	tween.tween_property(self, 'modulate', Color(1,1,1,0), 1)

func _on_button_pressed() -> void:
	var deal = game.deals[deal_idx]
	if game.has_enough_resources(deal):
		game.deal(self)
	else:
		$AnimationPlayer.play("No")
