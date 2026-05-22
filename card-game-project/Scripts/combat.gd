#root of all combat encounters
extends Node2D


var astar: AStarGrid2D

#Hardcoded Obstacles
var obstacles: Array[Vector2i] = [
	Vector2i(3, 0),
	Vector2i(3, 1),
	Vector2i(3, 2),
	Vector2i(3, 3),
	Vector2i(3, 4),
]

func _ready() -> void:
	setup_pathfinding()
	test_pathfinding()

#creates and defines our AStarGrid2D
func setup_pathfinding() -> void:
	#instantiate AStarGrid2D
	astar = AStarGrid2D.new()
	
	#region of valid cells
	astar.region = Rect2i(Vector2i.ZERO, Grid.SIZE)
	astar.cell_size = Grid.CELL_SIZE
	
	#diagonal movement?
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	#update must be called after configuration
	astar.update()
	
	for obstacle in obstacles:
		astar.set_point_solid(obstacle, true)
		
		
#temp function to test pathfinding
func test_pathfinding() -> void:
	var path: Array[Vector2i] = astar.get_id_path(Vector2i(2, 3), Vector2i(4, 2))
	print("path from (2, 3) to (4, 2):")
	for cell in path:
		print(" ", cell)
	print("total cells: ", path.size())
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	
# Checks if the mouse moves. prints the relative grid position of the mouse
"""
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var cell = Grid.world_to_grid(get_global_mouse_position())
		if Grid.is_within_grid(cell):
			print("Hovering Cell: ", cell)
"""
#draws the grid		
func _draw() -> void:
	for x in Grid.SIZE.x:
		for y in Grid.SIZE.y:
			var rect = Rect2(Vector2(x, y) * Grid.CELL_SIZE, Grid.CELL_SIZE)
			draw_rect(rect, Color.BLACK, false, 2.0)
