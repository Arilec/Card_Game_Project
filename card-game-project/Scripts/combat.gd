#root of all combat encounters
extends Node2D

#Player References
@onready var player: Player = $Player


#pathfinder line reference & Cell cache
@export var path_line: Line2D
var preview_path: Array[Vector2i] = []
var commit_path: Array[Vector2i] = []
var hover_cell: Vector2i

#A* initiation
var pathfinder: Pathfinder
func _ready() -> void:
	pathfinder = Pathfinder.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	
#draws the grid		
func _draw() -> void:
	for x in Grid.SIZE.x:
		for y in Grid.SIZE.y:
			var rect = Rect2(Vector2(x, y) * Grid.CELL_SIZE, Grid.CELL_SIZE)
			draw_rect(rect, Color.BLACK, false, 2.0)

enum State { IDLE, CHARACTER_SELECTED, MOVING }

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
		if Grid.world_to_grid(get_global_mouse_position()) == player.current_cell:
			change_state(State.CHARACTER_SELECTED)

#input handler for CHARACTER_SELECTED State
func _input_CHARACTER_SELECTED(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if Grid.world_to_grid(get_global_mouse_position()) == player.current_cell:
					change_state(State.IDLE)
				else:
					commit_move()
			MOUSE_BUTTON_RIGHT:
				change_state(State.IDLE)
	elif event is InputEventMouseMotion:
		hover_cell = Grid.world_to_grid(get_global_mouse_position())
		if (Grid.is_within_grid(hover_cell)):
			preview_path = pathfinder.pathfinder_logic.get_id_path(player.current_cell, hover_cell)
			path_line.clear_points()
			for cell in preview_path:
				path_line.add_point(Grid.grid_to_world(cell))
		

#State Machine Mechanical Heart
func change_state(new_state: State):
	#exit State
	match state:
		State.CHARACTER_SELECTED:
			path_line.clear_points()
			preview_path.clear()
	
	#enter State
	state = new_state

func commit_move() -> void:
	commit_path = preview_path.duplicate()
	change_state(State.MOVING)
	await player.walk_path(commit_path)
	change_state(State.IDLE)
	
