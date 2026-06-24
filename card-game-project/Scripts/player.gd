extends CharacterBody2D
class_name Player

## Player's on-grid actor: position, health, action points, and movement
## Turn ownership and AP live here as a source to the UI
## (PlayerController, Hand) and Combat read these values

# --turn state ----------------------
var is_player_turn: bool = true

# --stats ---------------------------
@export var max_health: int
@export var action_points: int = 3
@export var speed: float = 0.2

# --runtime stats -------------------
var health: int
var block: int
var spendable_ap: int

# --node references -----------------
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# --signals -------------------------
signal player_deal_damage
signal player_take_damage
signal player_heal
signal player_max_health_update
signal player_update_ap
signal player_update_block
signal player_end_turn
signal player_dead

## current grid cell, derived from world prosition
var current_cell: Vector2i:
	get: 
		return Grid.world_to_grid(global_position)


func _ready() -> void:
	health = max_health

# --action points

## updates player action points and emits the signal for the change
## ap: int
func update_action_points(ap: int) -> void:
	spendable_ap = ap
	player_update_ap.emit(ap)
	
# --movement

## moves the player through an inputted array path
## path: Array[vector2i]
func walk_path(path: Array[Vector2i]) -> void:
	var tween = create_tween()
	animated_sprite.play("Run")
	for cell in path.slice(1):
		var world_pos = Grid.grid_to_world(cell)
		tween.tween_property(self, "global_position", world_pos, speed)
	await tween.finished
	animated_sprite.play("Idle")

# --combat

## emits a signal that the player will deal damage and returns the damage dealt.
## amount: int
## Return: int
func deal_damage(amount: int) -> int:
	player_deal_damage.emit(amount)
	return amount

## player takes damage and emits signals. If health == 0, emit death
## amount: int
func take_damage(amount: int) -> void:
	#comparison: if amount - block < 0, damage_taken = 0
	var damage_taken = maxi(amount - block, 0)
	
	#comparison: if amount < block, deduct block by amount
	block -= mini(block, amount)
	
	health -= damage_taken
	player_take_damage.emit(health, "damage")
	if health <= 0:
		player_dead.emit()

## player heals damage and emits signal
## amount: int
func heal(amount: int) -> void:
	health += amount
	if health > max_health:
		var heal_amount = health - max_health
		health = max_health
		player_heal.emit(health, "heal")
	else:
		player_heal.emit(amount, "heal")

## Update player max health and heals a certain amount
## new_max: int
## new_health: int = new_max - max_health
func update_max_health(new_max: int, new_health: int = new_max - max_health) -> void:
	max_health = new_max
	player_max_health_update.emit(new_max, "max_raise")
	heal(new_health)

## the player's block stat increases.
## amount: int
func gain_block(amount: int) -> void:
	block += amount
	player_update_block.emit(block)

## the player's block stat resets
func reset_block() -> void:
	block = 0
	player_update_block.emit(block)


# --turn

func end_turn() -> void:
	print("I have ended my turn")
	is_player_turn = false
	player_end_turn.emit()
