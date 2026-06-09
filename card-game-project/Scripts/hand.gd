extends Control
class_name Hand

const CardView := preload("res://Scenes/CardView.tscn")

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
@export var hover_offset: float = 60.0
var save_position: Vector2

@export_category("Play Cards")
@export var play_card_offset: float = 50.0
var player: Player

#references
@onready var ap_graphic: Label = $AP_graphic

#updates action point data and graphics
func update_action_points(ap: int) -> void:
	player.update_action_points(ap)
	ap_graphic.text = str(ap)
	
#handles whenever the player draws a card
func draw_card(card_data: Card, deck_location: Vector2) -> void:
	hand_content.append(card_data)
	var view := CardView.instantiate()
	add_child(view)
	view.setup(card_data)
	card_views.append(view)
	view.position -= position - deck_location
	organize_hand(card_views)

#handles animations (tweens) of cards for inputted positions and rotations
func _tween_card_to(card: Control, pos: Vector2, rot: float) -> void:
	if card.tween:
		card.tween.kill()
	card.tween = create_tween().set_parallel(true)
	card.tween.tween_property(card, "position", pos, anim_speed).set_trans(Tween.TRANS_SINE)
	card.tween.tween_property(card, "rotation", rot, anim_speed).set_trans(Tween.TRANS_SINE)
	
#organizes the hand spread and animates the cards	
func organize_hand(cards: Array) -> void:
	for i in cards.size():
		var card: Control = cards[i]
		var layout := position_card(card, i, cards.size())
		card.home_position = layout.position
		card.home_rotation = layout.rotation
		_tween_card_to(card, layout.position, layout.rotation)

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

#starts connecting signals to functions
func connect_card_signals(card_view: Control):
	card_view.connect("mouse_entered_card", _on_card_view_mouse_entered_card)
	card_view.connect("mouse_exited_card", _on_card_view_mouse_exited_card)
	card_view.connect("mouse_release", _on_card_view_mouse_release)
	card_view.connect("mouse_pressed", _on_card_view_mouse_pressed)

func _on_card_view_mouse_entered_card(card_view: Control) -> void:
	if card_view.card_dragging:
		return
	_tween_card_to(card_view, card_view.home_position - Vector2(0, hover_offset), 0.0)

func _on_card_view_mouse_exited_card(card_view: Control) -> void:
	if card_view.card_dragging:
		return
	_tween_card_to(card_view, card_view.home_position, card_view.home_rotation)
	
func _on_card_view_mouse_release(card_view: Control) -> void:
	if card_view.global_position.y < global_position.y - play_card_offset:
		if card_view.card_data.ap_cost <= player.spendable_ap:
			card_is_played(card_view)
	organize_hand(card_views)


func _on_card_view_mouse_pressed(card_view: Control) -> void:
	pass
	
#handles card being played
func card_is_played(card_view: Control) -> void:
	var card := remove_card(card_view)
	print(card.card_name + " is played")
	card.play()
	update_action_points(player.spendable_ap - card.ap_cost)

#disconnects and removes child card node
func remove_card(view: Control) -> Card:
	var index := card_views.find(view)
	if index == -1:
		return null
	var data: Card = hand_content[index]
	hand_content.remove_at(index)
	card_views.remove_at(index)
	view.disconnect("mouse_entered_card", _on_card_view_mouse_entered_card)
	view.disconnect("mouse_exited_card", _on_card_view_mouse_exited_card)
	view.disconnect("mouse_release", _on_card_view_mouse_release)
	view.disconnect("mouse_pressed", _on_card_view_mouse_pressed)
	view.queue_free()
	organize_hand(card_views)
	return data

	
