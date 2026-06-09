extends Deck
class_name WarriorDeck

const Strike := preload("res://Resources/Strike.tres")
const Block := preload("res://Resources/Block.tres")
const Cleave := preload("res://Resources/Cleave.tres")

func _init() -> void:
	for n in 4:
		add_cards(Block)
	for n in 5:
		add_cards(Strike)
	add_cards([Cleave])
	
