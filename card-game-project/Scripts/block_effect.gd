extends CardEffect
class_name BlockEffect

##blocking effect
##this_amount is the amount of block given

# -- execute
func execute(combat: Combat, source: Player, target_cell: Vector2i, target: Node2D) -> void:
	combat.handle_block(source, target, this_amount)
