extends Node
#the entirity of the A*grid implementation
class_name Pathfinder

var pathfinder_logic: AStarGrid2D

#Hardcoded Obstacles
var obstacles: Array[Vector2i] = [
	Vector2i(3, 0),
	Vector2i(3, 1),
	Vector2i(3, 2),
	Vector2i(3, 3),
	Vector2i(3, 4),
]

#runs on initialization
func _init():
	setup_pathfinding()
		
#creates and defines our AStarGrid2D
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
