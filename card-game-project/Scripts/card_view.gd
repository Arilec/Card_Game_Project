extends Control

@onready var card_name: Label = $ColorRect/Name
@onready var cost: Label = $ColorRect/Cost
@onready var typeline: Label = $ColorRect/Typeline
@onready var description: RichTextLabel = $ColorRect/Description

var card_data: Card

func setup(data: Card) -> void:
	card_data = data
	card_name.text = data.card_name
	cost.text = str(data.ap_cost)
	typeline.text = str(data.type,  " - ", data.subtype)
