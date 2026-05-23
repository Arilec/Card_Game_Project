#root of all combat encounters
extends Node2D

#Player References
@onready var player: Node2D = $Player
@onready var player_cell = Grid.world_to_grid(player.global_position)

#pathfinder line reference & Cell cache
@export var pathfinder: Line2D
var path: Array[Vector2i] = []
var hover_cell: Vector2i

#A* initiation
var astar: AStar
func _ready() -> void:
	astar = AStar.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	
#draws the grid		
func _draw() -> void:
	for x in Grid.SIZE.x:
		for y in Grid.SIZE.y:
			var rect = Rect2(Vector2(x, y) * Grid.CELL_SIZE, Grid.CELL_SIZE)
			draw_rect(rect, Color.BLACK, false, 2.0)

enum State { IDLE, CHARACTER_SELECTED }

var state = State.IDLE

#general input handler
func _input(event: InputEvent) -> void:
	#sends input to proper channels based on input
	match state:
		State.IDLE:
			_input_IDLE(event)
		State.CHARACTER_SELECTED:
			_input_CHARACTER_SELECTED(event)

#input handler for IDLE State
func _input_IDLE(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT:
		if Grid.world_to_grid(get_global_mouse_position()) == player_cell:
			change_state(State.CHARACTER_SELECTED)

#input handler for CHARACTER_SELECTED State
func _input_CHARACTER_SELECTED(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_RIGHT:
				change_state(State.IDLE)
	elif event is InputEventMouseMotion:
		hover_cell = Grid.world_to_grid(get_global_mouse_position())
		if (Grid.is_within_grid(hover_cell)):
			path = astar.pathfinder_logic.get_id_path(player_cell, hover_cell)
			pathfinder.clear_points()
			for cell in path:
				pathfinder.add_point(Grid.grid_to_world(cell))
		

#State Machine Mechanical Heart
func change_state(new_state: State):
	#exit State
	match state:
		State.CHARACTER_SELECTED:
			pathfinder.clear_points()
			path.clear()
	
	#enter State
	state = new_state

#the entirity of the A*grid implementation
class AStar:
	
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
