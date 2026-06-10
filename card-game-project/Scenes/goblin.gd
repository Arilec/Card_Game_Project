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
	for cell in path:
		var world_pos = Grid.grid_to_world(cell)
		tween.tween_property(self, "global_position", world_pos, speed)
	await tween.finished
	animated_sprite.play("Idle")

#enemy turn sequence (different for each enemy
func take_turn(combat_state, path: Array[Vector2i]):
	spendable_ap = action_points
	var commit_path = path.slice(1, spendable_ap + 1)
	await walk_path(commit_path)
	spendable_ap -= commit_path.size()
	if spendable_ap < 0:
		spendable_ap = 0
	if Grid.is_in_range(self, combat_state.player, 1) && spendable_ap > 0:
		print("stab")
