extends Enemy

class_name Goblin

var is_player_turn: bool = true

var tween: Tween
@export var health: int
@export var action_points: int = 4
var spendable_ap: int
@export var speed: float = 0.2
@export var initiative: int


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_cell: Vector2i:
	get: 
		return Grid.world_to_grid(global_position)

func walk_path(path: Array[Vector2i]) -> void:
	if path.size() <= 1:
		return
	tween = create_tween()
	animated_sprite.play("Run")
	for cell in path.slice(1):
		var world_pos = Grid.grid_to_world(cell)
		tween.tween_property(self, "global_position", world_pos, speed)
	await tween.finished
	animated_sprite.play("Idle")

func take_turn(combat_state):
	pass
