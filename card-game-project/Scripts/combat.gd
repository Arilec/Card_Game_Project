#root of all combat encounters
extends Node2D

#Player References
@onready var player: Player = $Player
@onready var player_movement: PlayerMovement = $PlayerMovement
@onready var path_line: Line2D = $Line2D

#Enemy References
@onready var goblin: Enemy = $Goblin

#Player UI References
@onready var player_ui: PlayerController = $PlayerUI


#A* initiation
var pathfinder: Pathfinder

func _ready() -> void:
	pathfinder = Pathfinder.new()
	player_movement.pathfinder = pathfinder
	player_movement.player = player
	player_movement.path_line = path_line
	player_ui.connect("player_end_turn", do_enemy_turn)


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
	var path = pathfinder.pathfinder_logic.get_id_path(goblin.current_cell, player.current_cell)
	goblin.take_turn(self, path)
