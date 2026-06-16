extends Enemy

class_name Goblin

var tween: Tween
@export var max_health: int
var health: int
@export var action_points: int = 4
var spendable_ap: int
@export var speed: float = 0.2
@export var initiative: int
@export var damage: int = 4

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

signal enemy_deal_damage
signal enemy_take_damage
signal enemy_dead

func _ready() -> void:
	health = max_health
	

var current_cell: Vector2i:
	get: 
		return Grid.world_to_grid(global_position)

func walk_path(path: Array[Vector2i]) -> void:
	if path.is_empty():
		return
	tween = create_tween()
	animated_sprite.play("Run")
	for cell in path:
		var world_pos = Grid.grid_to_world(cell)
		tween.tween_property(self, "global_position", world_pos, speed)
	await tween.finished
	animated_sprite.play("Idle")

##enemy turn sequence (different for each enemy)
## path includes both endpoints: path[0] is the goblin's own cell,
## path[-1] is the player's cell. We slice [1, final_index) to walk the
## intermediate cells only — never onto the player, never re-stepping our origin.
func take_turn(combat_state: Combat, path: Array[Vector2i]):
	spendable_ap = action_points
	if path.is_empty():
		return
	
	var final_index = path.size() - 1
	var commit_path = path.slice(1, mini(spendable_ap + 1, final_index))
	await walk_path(commit_path)
	spendable_ap -= commit_path.size()
	if spendable_ap < 0:
		spendable_ap = 0
	if Grid.is_in_range(self, combat_state.player, 1):
		print("stab")
		combat_state.handle_damage(self, combat_state.player, deal_damage(damage))

func deal_damage(amount: int) -> int:
	enemy_deal_damage.emit(amount)
	return amount

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		enemy_dead.emit()
	print(health)

func heal(amount: int) -> void:
	health += amount
	if health > max_health:
		health = max_health
		
func update_max_health(new_max: int, new_health: int = new_max - max_health) -> void:
	max_health = new_max
	heal(new_health)
