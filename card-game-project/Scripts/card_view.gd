extends Control

@onready var card_name: Label = $Name
@onready var cost: Label = $Cost
@onready var typeline: Label = $Typeline
@onready var description: RichTextLabel = $Description

const SIZE := Vector2(160.0, 224.0)

var card_hovering: bool = false
var card_dragging: bool = false
var offset: Vector2 = Vector2(0, 0)
var home_position: Vector2
var home_rotation: float

var tween: Tween
#signals
signal mouse_entered_card
signal mouse_exited_card
signal mouse_pressed
signal mouse_release

var card_data: Card	

func _process(delta: float) -> void:
	if card_dragging: 
		global_position = get_global_mouse_position() - offset
	
func setup(data: Card) -> void:
	card_data = data
	card_name.text = data.card_name
	cost.text = str(data.ap_cost)
	typeline.text = str(data.type,  " - ", data.subtype)
	size = SIZE
	get_parent().connect_card_signals(self)


func _on_button_mouse_entered() -> void:
	card_hovering = true
	mouse_entered_card.emit(self)

func _on_button_mouse_exited() -> void:
	card_hovering = false
	mouse_exited_card.emit(self)

func _on_button_button_down() -> void:
	card_dragging = true
	offset = get_global_mouse_position() - global_position
	mouse_pressed.emit(self)

func _on_button_button_up() -> void:
	card_dragging = false
	mouse_release.emit(self)
