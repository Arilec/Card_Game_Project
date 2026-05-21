#root of all combat encounters
extends Node2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	
# Checks if the mouse moves. prints the relative grid position of the mouse
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var cell = Grid.world_to_grid(get_global_mouse_position())
		if Grid.is_within_grid(cell):
			print("Hovering Cell: ", cell)

#draws the grid		
func _draw() -> void:
	for x in Grid.SIZE.x:
		for y in Grid.SIZE.y:
			var rect = Rect2(Vector2(x, y) * Grid.CELL_SIZE, Grid.CELL_SIZE)
			draw_rect(rect, Color.BLACK, false, 2.0)
