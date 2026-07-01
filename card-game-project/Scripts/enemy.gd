extends CharacterBody2D
class_name Enemy

##general enemy script
##parent class to all ENEMIES

# -- animation tweening

## animations must include "Run", "Idle", and "Hit"
@export var animated_sprite: AnimatedSprite2D

var tween: Tween

# -- stats
@export var max_health: int
var health: int
@export var action_points: int = 4
var spendable_ap: int
@export var speed: float = 0.2
@export var initiative: int
@export var damage: int = 4

## current grid cell, derived from world prosition
var current_cell: Vector2i:
	get: 
		return Grid.world_to_grid(global_position)


# -- signals
signal enemy_deal_damage
signal enemy_take_damage
signal enemy_dead

# -- ready
func _ready() -> void:
	health = max_health


# -- combat

## emits a signal that the enemy will deal damage and returns the damage dealt.
## amount: int
## Return: int
func deal_damage(amount: int) -> int:
	enemy_deal_damage.emit(amount)
	return amount

## enemy takes damage and emits signals. If health == 0, emit death
## amount: int
func take_damage(amount: int) -> void:
	health -= amount
	enemy_take_damage.emit(amount)
	animated_sprite.play("Hit")
	await animated_sprite.animation_finished
	animated_sprite.play("Idle")
	if health <= 0:
		enemy_dead.emit()
	print(health)

## enemy heals damage and emits signal
## amount: int
func heal(amount: int) -> void:
	health += amount
	if health > max_health:
		health = max_health

## Update enemy max health and heals a certain amount
## new_max: int
## new_health: int = new_max - max_health
func update_max_health(new_max: int, new_health: int = new_max - max_health) -> void:
	max_health = new_max
	heal(new_health)


# -- movement

## moves the enemy through an inputted array path
## path: Array[vector2i]
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


# -- turn logic

##turn AI for the enemy
##combat_state: Combat // script reference
##path: Array[Vector2i] // the route you take
func take_turn(combat_state: Combat, path: Array[Vector2i]):
	pass

var reference_the_father: String = "Ari"
