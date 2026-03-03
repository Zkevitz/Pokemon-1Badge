extends Node
class_name NpcPathfindingComponent

var _npc : CharacterBody2D


func setup(npc: CharacterBody2D) -> void:
	_npc = npc


func setup_astar_grid(center: Vector2i, radius: int) -> AStarGrid2D:
	var astar := AStarGrid2D.new()
	astar.region = Rect2i(center - Vector2i(radius, radius),
							Vector2i(radius * 2 + 1, radius * 2 + 1))
	astar.cell_size = Vector2(Game.tileSize, Game.tileSize)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	return astar


func follow_path(astar_point: Array[Vector2i], last_point_exception := 0) -> void:
	for i in range(1, astar_point.size() - last_point_exception):
		var direction = (astar_point[i] - astar_point[i - 1]).sign()
		if direction != Vector2i(_npc.move_direction):
			_npc.move_direction = direction
		await _npc.go_to(_npc.Walkinggrid.map_to_local(astar_point[i]))
