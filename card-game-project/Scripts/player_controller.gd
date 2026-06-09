extends Control
class_name PlayerController

@onready var hand: Hand = $Hand
@export var player: Player
#top deck is max index
var deck: Deck = WarriorDeck.new()
var discard: Array[Card]


@export var starting_hand_size: int = 5

@onready var player_ui: PlayerController = $"."

@onready var deck_container: Button = $Deck
@onready var discard_container: Button = $Discard

signal player_end_turn

func _ready() -> void:
	hand.player = player
	start_turn()
	
func start_turn() -> void:
	player.is_player_turn = true
	hand.update_action_points(player.action_points)
	if deck.get_size() >= starting_hand_size:
		for i in starting_hand_size:
			add_to_hand(deck.remove_card(deck.get_size()-1))

func add_to_hand(card_data: Card) -> void:
	hand.draw_card(card_data, deck_container.position)
	
func _on_deck_pressed() -> void:
	if deck.get_size() > 0:
		add_to_hand(deck.remove_card(deck.get_size()-1))

func _on_discard_pressed() -> void:
	player.is_player_turn = false
	emit_signal("player_end_turn")
	for card_view in hand.card_views.duplicate():
		var card = hand.remove_card(card_view)
		if card:
			discard.append(card)
