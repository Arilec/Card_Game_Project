extends Control
class_name PlayerController

##The player UI script
##Connected to hand
##helps with other card functions

# -- hand connection
@onready var hand: Hand = $Hand
@export var starting_hand_size: int = 5

# -- player reference
@export var player: Player

# -- deck
@onready var deck_container: Button = $Deck
##top deck is max index
var deck: Deck = WarriorDeck.new()

# -- discard
@onready var discard_container: Button = $Discard
var discard: Array[Card]

# -- self reference
@onready var player_ui: PlayerController = $"."

# -- other graphics
@onready var ap_graphic: Label = $AP_graphic
@onready var player_hp: PlayerHP = $HBoxContainer/PlayerHP


# -- ready

##connects player signals and player_hp
func _ready() -> void:
	player.connect("player_update_ap", update_action_points)
	
	player.connect("player_heal", _on_health_update)
	player.connect("player_take_damage", _on_health_update)
	player.connect("player_max_health_update", _on_health_update)
	player.connect("player_update_block", _on_block_update)
	player_hp.update_max_health(player.max_health)
	player_hp.update_health(player.health)
	start_turn()


# -- player turn

##starts player turn.
func start_turn() -> void:
	player.is_player_turn = true
	player.reset_block()
	player.update_action_points(player.action_points)
	if deck.get_size() >= starting_hand_size:
		for i in starting_hand_size:
			add_to_hand(deck.remove_card(deck.get_size()-1))


# -- card interactions

##adds cards to hand
##card_data: Card
func add_to_hand(card_data: Card) -> void:
	hand.draw_card(card_data, deck_container.position)

##interaction caused by clicking on the deck
##currently, it draws cards
func _on_deck_pressed() -> void:
	if deck.get_size() > 0:
		add_to_hand(deck.remove_card(deck.get_size()-1))

##interaction caused by clicking on the discard
##currently, it ends turn
func _on_discard_pressed() -> void:
	player.end_turn()
	for card_view in hand.card_views.duplicate():
		var card = hand.remove_card(card_view)
		if card:
			discard.append(card)


# -- update other graphics

##called on health update
func _on_health_update(amount: int, type: String) -> void:
	if type == "max_raise":
		player_hp.update_max_health(amount)
	player_hp.update_health(amount)

##called on block update
func _on_block_update(amount: int) -> void:
	player_hp.update_block(amount)
	
##updates action point data and graphics
func update_action_points(ap: int) -> void:
	ap_graphic.text = str(ap)
