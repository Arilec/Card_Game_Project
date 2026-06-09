extends Node
class_name PlayerMovement

var player: Player
var path_line: Line2D

var pathfinder: Pathfinder

#pathfinder line reference & Cell cache
var preview_path: Array[Vector2i] = []
var commit_path: Array[Vector2i] = []

enum State { IDLE, CHARACTER_SELECTED, MOVING }

var state = State.IDLE

#pathfinder line reference & Cell cache
var hover_cell: Vector2i

#input handler for cicks
func click(cell: Vector2i) -> void:
	match state:
		State.IDLE:
			if cell == player.current_cell:
				change_state(State.CHARACTER_SELECTED)
		State.CHARACTER_SELECTED:
			if cell == player.current_cell:
				change_state(State.IDLE)
			else: 
				commit_move()
		
#input handler for hover
func hover(cell: Vector2i) -> void:
	if (Grid.is_within_grid(cell)):
		match state:
			State.CHARACTER_SELECTED:
				preview_path = pathfinder.pathfinder_logic.get_id_path(player.current_cell, cell)
				path_line.clear_points()
				for c in preview_path:
					path_line.add_point(Grid.grid_to_world(c))

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
	
func cancel() -> void: 
	match state:
		State.CHARACTER_SELECTED:
			change_state(State.IDLE)
