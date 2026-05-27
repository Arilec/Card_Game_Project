extends Control
class_name PlayerController

const CardView := preload("res://Scenes/CardView.tscn")

var hand: Array[Card]
var deck: Array[Card]
var discard: Array[Card]

var is_player_turn: bool = true

@export var player_ref: Player
@onready var player_ui: PlayerController = $"."

@onready var hand_forward: Control = $HandForward
@onready var deck_container: ColorRect = $Deck

func add_to_hand(card_data: Card) -> void:
	var view := CardView.instantiate()
	hand_forward.add_child(view)
	view.setup(card_data)
	
#end turn
func end_turn() -> void:
	pass

func add_card(card: Card) -> void:
	pass

func remove_card(card: Card) -> void:
	pass
