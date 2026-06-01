extends Control

const CardView := preload("res://Scenes/CardView.tscn")
var tween: Tween

var hand_content: Array[Card] = []
var card_views: Array[Control] = []

@export_category("Hand Spread Core")
@export var fan_curve: Curve
@export var hand_width: float = 512.0
@export var fan_height: float = 10.0
@export var angle: float = 10
@export var card_width: float = 160.0
@export var card_spacing: float = 40.0

@export_category("Animation and Visuals")
@export var anim_speed: float = 0.1
@export var hover_offset: float = 30.0
var save_position: Vector2
var card_is_dragging: bool = false

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
	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true)
	for i in cards.size():
		var card: Control = cards[i]
		var layout := position_card(card, i, cards.size())
		tween.tween_property(card, "position", layout.position, anim_speed).set_trans(Tween.TRANS_SINE)
		tween.tween_property(card, "rotation", layout.rotation, anim_speed).set_trans(Tween.TRANS_SINE)

#returns a dictionary of the correct position and rotation of the cards
func position_card(card: Control, index: int, total: int) -> Dictionary:
	var a := 0.5
	if total > 1:
		a = float(index) / float(total - 1)
	
	#card spacing calculations
	var total_cards_length = card_width * total + card_spacing * (total - 1)
	var final_card_spacing := card_spacing
	if total_cards_length > hand_width:
		final_card_spacing = (hand_width - card_width * total) / (total-1)
		total_cards_length = hand_width
		
	#positional offset for card start
	var  b: float = (hand_width - total_cards_length) / 2
	
	
	var x := b + index * (card_width + final_card_spacing)
	var y := fan_curve.sample(a) * fan_height
	
	var angle_rad = deg_to_rad(lerp(-angle/2.0, angle/2.0, a))
	
	return {
		"position": Vector2(x, y),
		"rotation": angle_rad,
	}

func connect_card_signals(card_view: Control):
	card_view.connect("mouse_entered_card", _on_card_view_mouse_entered_card)
	card_view.connect("mouse_exited_card", _on_card_view_mouse_exited_card)
	card_view.connect("mouse_release", _on_card_view_mouse_release)
	card_view.connect("mouse_pressed", _on_card_view_mouse_pressed)

func _on_card_view_mouse_entered_card(card_view: Control) -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true)
	save_position = card_view.position
	if card_view.card_hovering  && card_is_dragging && !card_view.card_dragging:
		tween.tween_property(card_view, "position", save_position - Vector2(0, hover_offset), anim_speed).set_trans(Tween.TRANS_SINE)
		tween.tween_property(card_view, "rotation", 0.0, anim_speed).set_trans(Tween.TRANS_SINE)
		await tween.finished

func _on_card_view_mouse_exited_card(card_view: Control) -> void:
	if   card_is_dragging && !card_view.card_dragging:
		organize_hand(card_views)
	
func _on_card_view_mouse_release(card_view: Control) -> void:
	card_is_dragging = false
	organize_hand(card_views)
	
func _on_card_view_mouse_pressed(card_view: Control) -> void:
	card_is_dragging = true
