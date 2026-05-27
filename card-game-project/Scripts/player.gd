extends CharacterBody2D
class_name Player

@export var health: int
@export var action_points: int = 3
@export var speed: float = 0.2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_cell: Vector2i:
	get: 
		return Grid.world_to_grid(global_position)

func _physics_process(delta: float) -> void:
	pass

func walk_path(path: Array[Vector2i]) -> void:
	var tween = create_tween()
	animated_sprite.play("Run")
	for cell in path.slice(1):
		var world_pos = Grid.grid_to_world(cell)
		tween.tween_property(self, "global_position", world_pos, speed)
	await tween.finished
	animated_sprite.play("Idle")
