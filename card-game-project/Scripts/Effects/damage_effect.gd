extends CardEffect
class_name DamageEffect

##damaging effect
##this_amount is damage amount


# -- execute
func execute(combat: Combat, source: Player, cast: TargetCast, card: Card) -> void:
	combat.handle_damage(source, cast.target, card.damage)
