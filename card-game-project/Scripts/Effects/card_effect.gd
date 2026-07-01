extends Resource
class_name CardEffect

##parent class for all possible card effects
##Children are specific card effects
##this_amount is the amount of an effect the card does

# -- this amount instantiation
@export var this_amount: int

# -- execute
func execute(combat: Combat, source: Player, cast: TargetCast, card: Card) -> void:
	pass

func target(combat: Combat, card_data: Card, source_position: Vector2i):
	return await combat.build_target_cast(card_data, self, source_position)

func target_range(card: Card):
	return card.range

func next_origin(cast: TargetCast, origin: Vector2i) -> Vector2i:
	return origin
