extends CardEffect
class_name ChargeEffect

##blocking effect
##this_amount is the amount of block given

# -- execute
func execute(combat: Combat, source: Player, cast: TargetCast, card: Card) -> void:
	await source.charge_path(source.current_cell, cast.cell)
	
func target_range(card: Card):
	return this_amount

func next_origin(cast: TargetCast, origin: Vector2i) -> Vector2i:
	return cast.cell
