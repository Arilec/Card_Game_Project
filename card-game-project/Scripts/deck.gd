extends Node
class_name Deck

var _ninetynine: Array[Card] = []:
	get:
		return _ninetynine

#Accepts either an Array or Card object and appends them to deck
func add_cards(card) -> void:
	if card is Card:
		_ninetynine.append(card)
	
	if card is Array:
		for c in card:
			if c is Card:
				_ninetynine.append(c)

func remove_card(card_index: int) -> Card:
	var card: Card = _ninetynine[card_index]
	_ninetynine.remove_at(card_index)
	return card

func get_size() -> int:
	return _ninetynine.size()

func print_debug() -> void:
	for card in _ninetynine:
		print(card.card_name)
