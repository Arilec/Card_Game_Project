extends Control
class_name Hand

##script for the player's hand
##as of 06/21, largest script for the game
##keeps track of the visual aspect of the cards
##also manages card interactions

# -- card view instance
const CardView := preload("res://Scenes/CardView.tscn")

# -- hand contents
var hand_content: Array[Card] = []
var card_views: Array[Control] = []

# -- hand spread core

@export_category("Hand Spread Core")
@export var fan_curve: Curve
@export var hand_width: float = 512.0
@export var fan_height: float = 10.0
@export var angle: float = 10
@export var card_width: float = 160.0
@export var card_spacing: float = 40.0

# -- Animation and visuals

@export_category("Animation and Visuals")
@export var anim_speed: float = 0.1
@export var hover_offset: float = 60.0
var save_position: Vector2

# -- signals
signal card_grabbed
signal card_released

# -- animate cards


##handles animations (tweens) of cards for inputted positions and rotations
##card: Control
##pos: Vector2
##rot: float
func _tween_card_to(card: Control, pos: Vector2, rot: float) -> void:
	if card.tween:
		card.tween.kill()
	card.tween = create_tween().set_parallel(true)
	card.tween.tween_property(card, "position", pos, anim_speed).set_trans(Tween.TRANS_SINE)
	card.tween.tween_property(card, "rotation", rot, anim_speed).set_trans(Tween.TRANS_SINE)

##organizes the hand spread and animates the cards
##card: Array
func organize_hand(cards: Array) -> void:
	for i in cards.size():
		var card: Control = cards[i]
		var layout := position_card(card, i, cards.size())
		card.home_position = layout.position
		card.home_rotation = layout.rotation
		_tween_card_to(card, layout.position, layout.rotation)

##returns a dictionary of the correct position and rotation of the cards
##card: Control
##index: int
##total: int
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


# -- draw cards


##handles whenever the player draws a card
##card_data: Card
##deck_location: Vector2
func draw_card(card_data: Card, deck_location: Vector2) -> void:
	hand_content.append(card_data)
	var view := CardView.instantiate()
	add_child(view)
	view.setup(card_data)
	card_views.append(view)
	view.position -= position - deck_location
	organize_hand(card_views)

##starts connecting signals to functions
##card_view: control
func connect_card_signals(card_view: Control):
	card_view.connect("mouse_entered_card", _on_card_view_mouse_entered_card)
	card_view.connect("mouse_exited_card", _on_card_view_mouse_exited_card)
	card_view.connect("mouse_release", _on_card_view_mouse_release)
	card_view.connect("mouse_pressed", _on_card_view_mouse_pressed)

# -- remove cards


##disconnects and removes child card node
##view: Control
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

# -- input handling


##triggers on mouse entering
##card_view: Control
func _on_card_view_mouse_entered_card(card_view: Control) -> void:
	if card_view.card_dragging:
		return
	_tween_card_to(card_view, card_view.home_position - Vector2(0, hover_offset), 0.0)

##triggers on mouse exit
##card_view: Control
func _on_card_view_mouse_exited_card(card_view: Control) -> void:
	if card_view.card_dragging:
		return
	_tween_card_to(card_view, card_view.home_position, card_view.home_rotation)

##triggers on mouse button pressed
##card_view: Control
func _on_card_view_mouse_pressed(card_view: Control) -> void:
	card_grabbed.emit(card_view)

##triggers on mouse button release
##card_view: Control
func _on_card_view_mouse_release(card_view: Control) -> void:
	card_released.emit(get_global_mouse_position(), card_view)
	
	"""
	if card_view.global_position.y < global_position.y - play_card_offset:
		if card_view.card_data.ap_cost <= player.spendable_ap:
			card_is_played(card_view)
	organize_hand(card_views)
	"""
