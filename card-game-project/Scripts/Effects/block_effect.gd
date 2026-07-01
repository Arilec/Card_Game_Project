extends CardEffect
class_name BlockEffect

##blocking effect
##this_amount is the amount of block given

# -- execute
func execute(combat: Combat, source: Player, cast: TargetCast, card: Card) -> void:
	await combat.handle_block(source, cast.target, card.block)
	
