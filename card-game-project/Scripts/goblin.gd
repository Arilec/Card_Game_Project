extends Enemy
class_name Goblin

## basic goblin script for basic enemy

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
