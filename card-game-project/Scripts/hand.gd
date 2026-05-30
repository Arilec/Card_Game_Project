extends Control

const CardView := preload("res://Scenes/CardView.tscn")


var hand_content: Array[Card] = []
var card_views: Array[Control] = []

@export_category("Hand Spread Core")
@export var fan_curve: Curve
@export var hand_width: float = 512.0
@export var fan_height: float = 100.0
@export var angle: float = 90

@export_category("Animation")
@export var anim_speed: float = 0.1

#handles whenever the player draws a card
func draw_card(card_data: Card, deck_location: Vector2) -> void:
	hand_content.append(card_data)
	var view := CardView.instantiate()
	add_child(view)
	view.setup(card_data)
	card_views.append(view)
	view.position -= position - deck_location
	organize_hand(card_views)

#organizes the hand spread and animates the cards	
func organize_hand(cards: Array) -> void:
	var tween = create_tween()
	for i in cards.size():
		var card: Control = cards[i]
		var layout := position_card(card, i, cards.size())
		tween.tween_property(card, "position", layout.position, anim_speed).set_trans(Tween.TRANS_SINE)
		tween.tween_property(card, "rotation", layout.rotation, anim_speed).set_trans(Tween.TRANS_SINE)

#returns a transform of the correct position of the cards
func position_card(card: Control, index: int, total: int) -> Dictionary:
	var a := 0.5
	if total > 1:
		a = float(index) / float(total - 1)
	
	var x := a * hand_width
	var y := fan_curve.sample(a) * fan_height
	
	var angle_rad = deg_to_rad(lerp(-angle/2.0, angle/2.0, a))
	
	return {
		"position": Vector2(x, y) - card.size / 2.0,
		"rotation": angle_rad,
	}
