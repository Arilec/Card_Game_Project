extends Resource
class_name CardEffect

##parent class for all possible card effects
##Children are specific card effects
##this_amount is the amount of an effect the card does

# -- this amount instantiation
@export var this_amount: int

# -- execute
func execute(combat: Combat, source: Player, target_cell: Vector2i, target: Enemy) -> void:
	pass
