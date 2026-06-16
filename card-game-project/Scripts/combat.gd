#root of all combat encounters
extends Node2D
class_name Combat

const TARGETING_SQUARE = preload("uid://f3ux2xwtp1hu")
var targeting_squares: Array = []

#Player References
@onready var player: Player = $Player
@onready var player_movement: PlayerMovement = $PlayerMovement
@onready var path_line: Line2D = $Line2D

#Enemy References
@onready var goblin: Enemy = $Goblin
@onready var enemies: Array[Enemy] = [goblin]

#Player UI References
@onready var player_ui: PlayerController = $PlayerUI
var hand: Hand


#A* initiation
var pathfinder: Pathfinder

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	
#draws the grid	
func _draw() -> void:
	for x in Grid.SIZE.x:
		for y in Grid.SIZE.y:
			var rect = Rect2(Vector2(x, y) * Grid.CELL_SIZE, Grid.CELL_SIZE)
			draw_rect(rect, Color.BLACK, false, 2.0)

#general input handler
func _input(event: InputEvent) -> void:
	var cell = Grid.world_to_grid(get_global_mouse_position())
	if event is InputEventMouseButton && event.is_pressed():
		match event.button_index:
			MOUSE_BUTTON_LEFT: player_movement.click(cell)
			MOUSE_BUTTON_RIGHT: player_movement.cancel()
	elif event is InputEventMouseMotion:
		player_movement.hover(Grid.world_to_grid(get_global_mouse_position()))

func do_enemy_turn() -> void:
	print("enemy taking turn now")
	var path = pathfinder.pathfinder_logic.get_id_path(goblin.current_cell, player.current_cell)
	await goblin.take_turn(self, path)
	player_ui.start_turn()

func handle_damage(source: Node2D, target: Node2D, amount: int):
	if target.has_method("take_damage"):
		target.take_damage(amount)
	
func _begin_targeting(card_view: Control):
	var card_data = card_view.card_data
	if card_data.range == 0:
		_spawn_targeting_tile(player.current_cell, color_by_card(card_data))
		return

	for direction in Grid.CARDINAL_DIRECTIONS:
		for i in range(1, card_data.range + 1):
			var cell = player.current_cell + direction * i
			if not Grid.is_within_grid(cell):
				break
			if pathfinder.pathfinder_logic.is_point_solid(cell):
				break
			_spawn_targeting_tile(cell, color_by_card(card_data))

func _end_targeting(target_position: Vector2, card_view: Control):
	var card: Card = card_view.card_data
	var square := get_targeted_tile(target_position)
	
	if square == null:
		_clear_targeting()
		hand.organize_hand(hand.card_views)
		return
		
	if card.ap_cost > player.spendable_ap:
		_clear_targeting()
		hand.organize_hand(hand.card_views)
		return
		
	var target := enemy_on_cell(square.target_cell)
	if card.does_damage and target == null:
		_clear_targeting()
		hand.organize_hand(hand.card_views)
		return
		
	_resolve_card(card, square.target_cell, target)
	hand.remove_card(card_view)
	player.update_action_points(player.spendable_ap - card.ap_cost)
	_clear_targeting()
	
func _spawn_targeting_tile(cell: Vector2i, color: Color) -> void:
	var tile = TARGETING_SQUARE.instantiate()
	add_child(tile)
	tile.setup(cell, color)
	targeting_squares.append(tile)
	
func get_targeted_tile(target_position) -> TargetingSquare:
	var cell = Grid.world_to_grid(target_position)
	for square in targeting_squares:
		if square.target_cell == cell:
			return square
	return null

func enemy_on_cell(cell: Vector2i) -> Enemy:
	for enemy in enemies:
		if enemy.current_cell == cell:
			return enemy
	return null

func color_by_card(card: Card) -> Color:
	if card.does_damage:
		return Color(1, 0, 0, 0.4)
	if card.gives_block:
		return Color(0, 0, 1, 0.4)
	return Color(1, 1, 1, 0.4)

func _clear_targeting() -> void:
	for square in targeting_squares:
		square.queue_free()
	targeting_squares.clear()

func _resolve_card(card: Card, target_cell: Vector2i, target):
	if card.does_damage and target != null:
		handle_damage(player, target, card.damage)

func _on_enemy_dead(enemy: Enemy) -> void:
	enemies.erase(enemy)
	enemy.queue_free()
	if enemies.is_empty():
		print("Victory")
