extends CharacterBody2D
class_name Player

var is_player_turn: bool = true

@export var max_health: int
var health: int
@export var action_points: int = 3
var spendable_ap: int
@export var speed: float = 0.2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

signal player_deal_damage
signal player_take_damage
signal player_heal
signal player_max_health_update
signal player_update_ap
signal player_end_turn
signal player_dead

var current_cell: Vector2i:
	get: 
		return Grid.world_to_grid(global_position)

func _ready() -> void:
	health = max_health
	
func _physics_process(delta: float) -> void:
	pass

func update_action_points(ap: int) -> void:
	spendable_ap = ap
	player_update_ap.emit(ap)
	
func walk_path(path: Array[Vector2i]) -> void:
	var tween = create_tween()
	animated_sprite.play("Run")
	for cell in path.slice(1):
		var world_pos = Grid.grid_to_world(cell)
		tween.tween_property(self, "global_position", world_pos, speed)
	await tween.finished
	animated_sprite.play("Idle")

func deal_damage(amount: int) -> int:
	player_deal_damage.emit(amount)
	return amount

func take_damage(amount: int) -> void:
	health -= amount
	player_take_damage.emit(health, "damage")
	if health <= 0:
		player_dead.emit()

func heal(amount: int) -> void:
	health += amount
	if health > max_health:
		var heal_amount = health - max_health
		health = max_health
		player_heal.emit(health, "heal")
	else:
		player_heal.emit(amount, "heal")

func update_max_health(new_max: int, new_health: int = new_max - max_health) -> void:
	max_health = new_max
	player_max_health_update.emit(new_max, "max_raise")
	heal(new_health)
	
func end_turn() -> void:
	print("I have ended my turn")
	is_player_turn = false
	player_end_turn.emit()
