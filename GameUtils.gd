extends Node

func get_world_position(position) -> Vector2:
	var x = position.x + GameData.grid_offset_x + GameData.half_tile_size
	var y = position.y + GameData.grid_offset_y + GameData.half_tile_size
	return Vector2(x, y)

func get_mirrored_position(position):
	var mirrored_x = (GameData.grid_width + GameData.grid_offset_x) - (position.x + GameData.half_tile_size)
	var mirrored_y = (GameData.grid_height + GameData.grid_offset_y) - (position.y + GameData.half_tile_size)
	return Vector2(mirrored_x, mirrored_y)
