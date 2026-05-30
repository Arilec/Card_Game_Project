extends Control

@onready var card_name: Label = $Name
@onready var cost: Label = $Cost
@onready var typeline: Label = $Typeline
@onready var description: RichTextLabel = $Description

const SIZE := Vector2(160.0, 224.0)

var card_data: Card

func setup(data: Card) -> void:
	card_data = data
	card_name.text = data.card_name
	cost.text = str(data.ap_cost)
	typeline.text = str(data.type,  " - ", data.subtype)
	size = SIZE
