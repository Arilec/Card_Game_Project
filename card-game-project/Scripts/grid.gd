class_name PathFinder
extends Resource

var _size
var _cell_size

func _init(size: Vector2i, cell_size: Vector2) -> void:
	_size = size
	_cell_size = cell_size
