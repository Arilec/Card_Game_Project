extends Control
class_name CardView

## Visual portion of card
## data is taken from Card and put into a graphical card
## attached to a control node 

# -- references 
@onready var card_name: Label = $Name
@onready var cost: Label = $Cost
@onready var typeline: Label = $Typeline
@onready var description: RichTextLabel = $Description

# -- size of card
const SIZE := Vector2(160.0, 224.0)

# -- hovering and dragging variables
var card_dragging: bool = false
var offset: Vector2 = Vector2(0, 0)
var home_position: Vector2
var home_rotation: float

# -- animation tween
var tween: Tween

# -- signals
signal mouse_entered_card
signal mouse_exited_card
signal mouse_pressed
signal mouse_release

# -- card data
var card_data: Card	

# -- Dragging Logic

func _process(delta: float) -> void:
	if card_dragging: 
		global_position = get_global_mouse_position() - offset

## signal for mouse pressed down
func _on_button_button_down() -> void:
	card_dragging = true
	offset = get_global_mouse_position() - global_position
	mouse_pressed.emit(self)

## signal for mouse release
func _on_button_button_up() -> void:
	card_dragging = false
	mouse_release.emit(self)

# -- Setup

## graphical setup for the card, typically called on instantiation
## data: Card
func setup(data: Card) -> void:
	card_data = data
	card_name.text = data.card_name
	cost.text = str(data.ap_cost)
	typeline.text = str(data.type,  " - ", data.subtype)
	size = SIZE
	get_parent().connect_card_signals(self)

# -- Animation helpers

## signal for mouse entering, emits mouse entered
func _on_button_mouse_entered() -> void:
	mouse_entered_card.emit(self)

##signal for mouse exiting, emits mouse exited
func _on_button_mouse_exited() -> void:
	mouse_exited_card.emit(self)

var reference_the_creator: String = "Ari"
