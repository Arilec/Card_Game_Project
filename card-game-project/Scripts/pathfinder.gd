extends Node
class_name Pathfinder

##the entirity of the A*grid implementation
##A*grid allows grid-based pathfinding
##in direct communication with the grid

# -- AStarGrid2d
var pathfinder_logic: AStarGrid2D

# -- Hardcoded Obstacles
var obstacles: Array[Vector2i] = [
	Vector2i(3, 0),
	Vector2i(3, 1),
	Vector2i(3, 2),
	Vector2i(3, 3),
	Vector2i(3, 4),
]

# -- setup pathfinding

##runs on initialization
func _init():
	setup_pathfinding()
		
##creates and defines our AStarGrid2D
func setup_pathfinding() -> void:
	#instantiate AStarGrid2D
	pathfinder_logic = AStarGrid2D.new()
	
	#region of valid cells
	pathfinder_logic.region = Rect2i(Vector2i.ZERO, Grid.SIZE)
	pathfinder_logic.cell_size = Grid.CELL_SIZE
	
	#diagonal movement?
	pathfinder_logic.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	#update must be called after configuration
	pathfinder_logic.update()
	
	for obstacle in obstacles:
		pathfinder_logic.set_point_solid(obstacle, true)	


func _cell_blocks(cell: Vector2i) -> bool:
	return not Grid.is_within_grid(cell) || pathfinder_logic.is_point_solid(cell)


func has_LOS(from: Vector2i, to: Vector2i) -> bool:
	var cells := Grid.line_cells(from, to)
	for i in range(1, cells.size() - 1):
		if pathfinder_logic.is_point_solid(cells[i]):
			return false
	return true


func cast_proj(a: Vector2i, b: Vector2i, max_dist: int) -> Array[Vector2i]:
	var lane: Array[Vector2i] = []
	
	#change in x and y
	var dx = abs(a.x - b.x)
	var dy = abs(a.y - b.y)
	
	#slope of x and y
	var sx = 1 if a.x < b.x else -1
	var sy = 1 if a.y < b.y else -1
	
	#distance from true line
	var err = dx - dy
	var cell = a
	
	for i in max_dist:
		var e2 = err * 2
		var step_x = e2 > -dy
		var step_y = e2 < dx
		if step_x && step_y:
			var sa = Vector2i(cell.x + sx, cell.y)
			var sb = Vector2i(cell.x, cell.y + sy)
			if _cell_blocks(sa) && _cell_blocks(sb):
				break
			if step_x:
				err -= dy
				cell.x += sx
			if step_y:
				err += dx
				cell.y += sy
			if _cell_blocks(cell):
				break
			lane.append(cell)
			if cell == b:
				break
	return lane
