#AutoLoad Script
extends Node

## this script creates the game grid

const SIZE: Vector2i = Vector2i(6, 6)
const CELL_SIZE: Vector2 = Vector2(32, 32)

const CARDINAL_DIRECTIONS: Array[Vector2i] = [
	Vector2i(0, -1), #N
	Vector2i(1, 0), #E
	Vector2i(0, 1), #S
	Vector2i(-1, 0) #W
]

##Converts Pixel Coords to Vector grid locations
func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i((world_pos / CELL_SIZE).floor())
	
##converts grid position to the center of that cell in the worldspace
func grid_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell) *CELL_SIZE + CELL_SIZE/2
	
##Returns true if the cell is on the grid
func is_within_grid(cell: Vector2i) -> bool:
	return cell.x >= 0 && cell.x < SIZE.x && cell.y >= 0 && cell.y < SIZE.y

##checks if a target is in range of anything
func is_in_range(object: Node2D, target: Node2D, range: int) -> bool:
	var object_location = world_to_grid(object.global_position)
	var target_location = world_to_grid(target.global_position)
	if is_within_grid(object_location) && is_within_grid(target_location):
		var diff = object_location - target_location
		return abs(diff.x) + abs(diff.y) <= range
	return false

##every cell in a straight line from a to b
func line_cells(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	
	#change in x and y
	var dx = abs(a.x - b.x)
	var dy = abs(a.y - b.y)
	
	#slope of x and y
	var sx = 1 if a.x < b.x else -1
	var sy = 1 if a.y < b.y else -1
	
	#distance from the true line
	var err = dx - dy
	
	var cell = a
	while true:
		cells.append(cell)
		if cell == b:
			break
		var e2 = err * 2
		if e2 > -dy:
			err -= dy
			cell.x += sx
		if e2 < dx:
			err += dx
			cell.y += sy
	return cells
