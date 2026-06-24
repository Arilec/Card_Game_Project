extends Node
class_name PlayerMovement

##a helper script for player movement

# -- player ref
var player: Player

# -- pathfinder reference
var pathfinder: Pathfinder

# -- pathfinder line reference & Cell cache
var path_line: Line2D

var preview_path: Array[Vector2i] = []
var commit_path: Array[Vector2i] = []

var hover_cell: Vector2i

# -- movement states
enum State { IDLE, CHARACTER_SELECTED, MOVING }

var state = State.IDLE

# -- input handlers

##input handler for cicks
##cell: Vector2i // the cell clicked
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
		
##input handler for hover
##cell: Vector2i // the cell being hovered over
func hover(cell: Vector2i) -> void:
	if (Grid.is_within_grid(cell)):
		match state:
			State.CHARACTER_SELECTED:
				preview_path = pathfinder.pathfinder_logic.get_id_path(player.current_cell, cell)
				path_line.clear_points()
				for c in preview_path:
					path_line.add_point(Grid.grid_to_world(c))


# -- State shifting

##state machine mechanical heart
##new_state: State
func change_state(new_state: State):
	#exit State
	match state:
		State.CHARACTER_SELECTED:
			path_line.clear_points()
			preview_path.clear()
	
	#enter State
	state = new_state

##cancels current move action and resets state
func cancel() -> void: 
	match state:
		State.CHARACTER_SELECTED:
			change_state(State.IDLE)

# -- commit move
func commit_move() -> void:
	commit_path = preview_path.duplicate()
	change_state(State.MOVING)
	await player.walk_path(commit_path)
	change_state(State.IDLE)
	
