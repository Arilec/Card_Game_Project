extends Control
class_name PlayerController

@onready var hand: Control = $Hand
#top deck is max index
var deck: Deck = WarriorDeck.new()
var discard: Array[Card]

var is_player_turn: bool = true

@export var player_ref: Player
@onready var player_ui: PlayerController = $"."

@onready var deck_container: Button = $Deck

func add_to_hand(card_data: Card) -> void:
	hand.draw_card(card_data, deck_container.position)

#end turn
func end_turn() -> void:
	pass
	
func _on_deck_pressed() -> void:
	if deck.get_size() > 0:
		add_to_hand(deck.remove_card(deck.get_size()-1))
