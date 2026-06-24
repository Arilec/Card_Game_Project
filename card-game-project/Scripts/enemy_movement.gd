extends Node
class_name EnemyMovement

##a helper script for enemy movement

# -- pathfinder
var pathfinder: Pathfinder

# -- pathfinder line reference & Cell cache
var preview_path: Array[Vector2i] = []
var commit_path: Array[Vector2i] = []

# -- movement states
enum State { IDLE, ATTACKING, MOVING }
var state = State.IDLE

# -- state shifting

##State Machine Mechanical Heart
##new_state: State
func change_state(new_state: State):
	#TODO: exit State
	
	#enter State
	state = new_state

##commits the movement of the enemy
##entity: enemy // the thing that is moving
func commit_move(entity: Enemy) -> void: 
	commit_path = preview_path.duplicate()
	change_state(State.MOVING)
	await entity.walk_path(commit_path)
	change_state(State.IDLE)

##reset state back to idle
func cancel() -> void:
	change_state(State.IDLE)

var reference_the_creator: String = "Ari"
