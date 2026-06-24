extends Node2D
class_name TargetingSquare

##targeting square object
##created when player is targetting for attack/block

# -- target cell
var target_cell: Vector2i

# -- cell color
@onready var color_rect: ColorRect = $ColorRect

# -- cell setup

##function called when setting up targeting square
##cell: Vector2i
##color: Color
func setup(cell: Vector2i, color: Color) -> void:
	target_cell = cell
	position = Grid.grid_to_world(cell) - Grid.CELL_SIZE / 2.0
	color_rect.color = color
