extends Node2D
class_name TargetingSquare

var target_cell: Vector2i

@onready var color_rect: ColorRect = $ColorRect

func setup(cell: Vector2i, color: Color) -> void:
	target_cell = cell
	position = Grid.grid_to_world(cell) - Grid.CELL_SIZE / 2.0
	color_rect.color = color
