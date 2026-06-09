extends Node
class_name EnemyMovement

var pathfinder: Pathfinder

#pathfinder line reference & Cell cache
var preview_path: Array[Vector2i] = []
var commit_path: Array[Vector2i] = []

enum State { IDLE, ATTACKING, MOVING }

var state = State.IDLE

#State Machine Mechanical Heart
func change_state(new_state: State):
	#TODO: exit State
	
	#enter State
	state = new_state

func commit_move(entity: Enemy) -> void: 
	commit_path = preview_path.duplicate()
	change_state(State.MOVING)
	await entity.walk_path(commit_path)
	change_state(State.IDLE)

func cancel() -> void:
	change_state(State.IDLE)
