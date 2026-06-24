extends Node
class_name Deck

## Logical variable handling what is actually in the deck
## can add cards, remove cards, and get size

# -- content 
var _ninetynine: Array[Card] = []:
	get:
		return _ninetynine

# -- access content 

## function for adding cards to the deck
## Accepts either an Array or Card object and appends them to deck
func add_cards(card) -> void:
	if card is Card:
		_ninetynine.append(card)
	
	if card is Array:
		for c in card:
			if c is Card:
				_ninetynine.append(c)

## function for removing specific cards from the deck
## card_index: int
func remove_card(card_index: int) -> Card:
	var card: Card = _ninetynine[card_index]
	_ninetynine.remove_at(card_index)
	return card

## size getter for deck
func get_size() -> int:
	return _ninetynine.size()

## debugs the content of the deck by printing its contents
func debug_contents() -> void:
	for card in _ninetynine:
		print(card.card_name)

var reference_the_creator: String = "Ari"
