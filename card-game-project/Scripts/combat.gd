
extends Node2D
class_name Combat

##root of all combat encounters
##helps handle grid-based transforms, turn order, and targeting
##the physical heart of the game

# -- targeting squares
const TARGETING_SQUARE = preload("uid://f3ux2xwtp1hu")
var targeting_squares: Array = []

# -- Player References
@onready var player: Player = $Player
@onready var player_movement: PlayerMovement = $PlayerMovement
@onready var path_line: Line2D = $Line2D

# -- Player UI References
@onready var player_ui: PlayerController = $PlayerUI
var hand: Hand

# -- Enemy References
@onready var goblin: Enemy = $Goblin
@onready var enemies: Array[Enemy] = [goblin]

#-- A* initiation
var pathfinder: Pathfinder


# -- ready

func _ready() -> void:
	pathfinder = Pathfinder.new()
	player_movement.pathfinder = pathfinder
	player_movement.player = player
	player_movement.path_line = path_line
	player.player_end_turn.connect(do_enemy_turn)
	print(player.is_connected("player_end_turn", do_enemy_turn))
	
	hand = player_ui.hand
	hand.connect("card_grabbed", _begin_targeting)
	hand.connect("card_released", _end_targeting)
	
	goblin.enemy_dead.connect(_on_enemy_dead.bind(goblin))


# -- grid instancing

func _process(delta: float) -> void:
	queue_redraw()
	
##draws the grid	
func _draw() -> void:
	for x in Grid.SIZE.x:
		for y in Grid.SIZE.y:
			var rect = Rect2(Vector2(x, y) * Grid.CELL_SIZE, Grid.CELL_SIZE)
			draw_rect(rect, Color.BLACK, false, 2.0)


# -- input handling

##general input handler, mainly for mouse
func _input(event: InputEvent) -> void:
	var cell = Grid.world_to_grid(get_global_mouse_position())
	if event is InputEventMouseButton && event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_LEFT: player_movement.click(cell)
			MOUSE_BUTTON_RIGHT: player_movement.cancel()
	elif event is InputEventMouseMotion:
		player_movement.hover(Grid.world_to_grid(get_global_mouse_position()))


# -- targeting squares logic


func targetable_cells(origin: Vector2i, radius: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for y in range(origin.y - radius, origin.y + radius + 1):
		for x in range(origin.x - radius, origin.x + radius + 1):
			var cell = Vector2i(x, y)
			if cell == origin or not Grid.is_within_grid(cell):
				continue
			var dist = abs(cell.x - origin.x) + abs(cell.y - origin.y)
			if dist <= radius && pathfinder.has_LOS(origin, cell):
				result.append(cell)
	return result


func aimable_cells(origin: Vector2i, radius: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for y in range(origin.y - radius, origin.y + radius + 1):
		for x in range(origin.x - radius, origin.x + radius + 1):
			var cell = Vector2i(x, y)
			if cell == origin or not Grid.is_within_grid(cell):
				continue
			if abs(cell.x - origin.x) + abs(cell.y - origin.y) <= radius:
				result.append(cell)
	return result

##starts the targetting process for the players cards based on card_view data
##card_view: Control
func _begin_targeting(card_view: Control):
	var card_data = card_view.card_data
	match card_data.target_type:
		Card.TargetType.SELF:
			_spawn_targeting_tile(player.current_cell, color_by_card(card_data))
		Card.TargetType.POINT:
			for cell in targetable_cells(player.current_cell, card_data.range):
				_spawn_targeting_tile(cell, color_by_card(card_data))
		Card.TargetType.PROJECTILE:
			for cell in aimable_cells(player.current_cell, card_data.range):
				_spawn_targeting_tile(cell, color_by_card(card_data))

##terminates targeting and resolves card if conditions allow
##target_position: Vector2
##card_view: Control
func _end_targeting(target_position: Vector2, card_view: Control):
	var card: Card = card_view.card_data
	var square := get_targeted_tile(target_position)
	
	if square == null || card.ap_cost > player.spendable_ap:
		_clear_targeting()
		hand.organize_hand(hand.card_views)
		return
		
	var cast = _build_cast(card, square.target_cell)
	if card.target_type == Card.TargetType.POINT && cast.target == null:
		_clear_targeting()
		hand.organize_hand(hand.card_views)
		return
		
	_resolve_card(card, square.target_cell, cast.target)
	hand.remove_card(card_view)
	player.update_action_points(player.spendable_ap - card.ap_cost)
	_clear_targeting()


func _build_cast(card: Card, aim: Vector2i) -> TargetCast:
	var cast = TargetCast.new()
	cast.cell = aim
	if card.target_type == Card.TargetType.PROJECTILE:
		for cell in pathfinder.cast_proj(player.current_cell, aim, card.range):
			var occupant = entity_on_cell(cell)
			if occupant != null:
				cast.target = occupant
				break
			cast.lane.append(cell)
	else:
		cast.target = entity_on_cell(aim)
	return cast


##spawns the targeting tiles
##cell: Vector2i
##color: Color
func _spawn_targeting_tile(cell: Vector2i, color: Color) -> void:
	var tile = TARGETING_SQUARE.instantiate()
	add_child(tile)
	tile.setup(cell, color)
	targeting_squares.append(tile)

##erases all targeting squares
func _clear_targeting() -> void:
	for square in targeting_squares:
		square.queue_free()
	targeting_squares.clear()


# -- targeting tile data references

##returns the targeting square at a certain position, using the grid 
##target_position: Vector2
func get_targeted_tile(target_position: Vector2) -> TargetingSquare:
	var cell = Grid.world_to_grid(target_position)
	for square in targeting_squares:
		if square.target_cell == cell:
			return square
	return null

##checks if there is an enemy on a certain cell
##cell: Vector2i // the cell on the grid
func entity_on_cell(cell: Vector2i) -> Node2D:
	if player.current_cell == cell:
		return player
	for enemy in enemies:
		if enemy.current_cell == cell:
			return enemy
	return null

##changes the targeting squares color depending on the card being played
##card: Card // card data
func color_by_card(card: Card) -> Color:
	if card.type == card.Type.ATTACK:
		return Color(1, 0, 0, 0.4)
	if card.type == card.Type.SKILL:
		return Color(0, 0, 1, 0.4)
	return Color(1, 1, 1, 0.4)


# -- enemy logic

##handles enemy turns and then passes to the player
func do_enemy_turn() -> void:
	print("enemy taking turn now")
	var path = pathfinder.pathfinder_logic.get_id_path(goblin.current_cell, player.current_cell)
	await goblin.take_turn(self, path)
	player_ui.start_turn()

##handles the death of an enemy
##enemy: Enemy
func _on_enemy_dead(enemy: Enemy) -> void:
	enemies.erase(enemy)
	enemy.queue_free()
	if enemies.is_empty():
		print("Victory")


# -- card logic

##uses the card data to handle the card being playee
##card: Card
##target_cell: Vector2i
##target: All // keeping it nonspecific for now
func _resolve_card(card: Card, target_cell: Vector2i, target):
	for e in card.effects:
		e.execute(self, player, target_cell, target)


# -- handle damage

##damage value station manager, directs damage to proper target
##source: Node2D
##target: Node2D
##amount: int
func handle_damage(source: Node2D, target: Node2D, amount: int):
	if target.has_method("take_damage"):
		target.take_damage(amount)


# -- handle block

##block station manager, directs block to proper target
##source: Node2D
##target: Node2D
##amount: int
func handle_block(source: Node2D, target: Node2D, amount: int):
	if target.has_method("gain_block"):
		target.gain_block(amount)



var reference_the_creator: String = "Ari"
