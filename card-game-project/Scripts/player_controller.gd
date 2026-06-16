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

@onready var ap_graphic: Label = $AP_graphic

@onready var player_hp: PlayerHP = $HBoxContainer/PlayerHP


func _ready() -> void:
	hand.player = player
	player.connect("player_update_ap", update_action_points)
	
	player.connect("player_heal", _on_health_update)
	player.connect("player_take_damage", _on_health_update)
	player.connect("player_max_health_update", _on_health_update)
	
	player_hp.update_max_health(player.max_health)
	player_hp.update_health(player.health)
	start_turn()
	
#updates action point data and graphics
func update_action_points(ap: int) -> void:
	ap_graphic.text = str(ap)

func start_turn() -> void:
	player.is_player_turn = true
	player.update_action_points(player.action_points)
	if deck.get_size() >= starting_hand_size:
		for i in starting_hand_size:
			add_to_hand(deck.remove_card(deck.get_size()-1))

func add_to_hand(card_data: Card) -> void:
	hand.draw_card(card_data, deck_container.position)
	
func _on_deck_pressed() -> void:
	if deck.get_size() > 0:
		add_to_hand(deck.remove_card(deck.get_size()-1))

func _on_discard_pressed() -> void:
	player.end_turn()
	for card_view in hand.card_views.duplicate():
		var card = hand.remove_card(card_view)
		if card:
			discard.append(card)

func _on_health_update(amount: int, type: String) -> void:
	if type == "max_raise":
		player_hp.update_max_health(amount)
	player_hp.update_health(amount)
