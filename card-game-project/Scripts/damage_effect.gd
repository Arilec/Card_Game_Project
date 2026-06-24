extends CardEffect
class_name DamageEffect

##damaging effect
##this_amount is damage amount


# -- execute
func execute(combat: Combat, source: Player, target_cell: Vector2i, target: Enemy) -> void:
	combat.handle_damage(source, target, this_amount)
