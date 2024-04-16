extends Node2D

var attack_range
var current_rotation

func init(tower_data):
	name = "Tower_%s" % tower_data.id
	
	var tower_position = tower_data.positions[0]
	
	if Global.is_leader:
		position = get_world_position(tower_position)
	else:
		position = get_mirrored_position(tower_position)
	
	current_rotation = tower_data.rotation
	attack_range = tower_data.attack_range
	
	$TowerGun.rotation = current_rotation

func update(tower_data):
	var target_rotation = tower_data.rotation + PI / 2
	
	# Smoothly interpolate rotation
	current_rotation = lerp_angle(current_rotation, target_rotation, 0.8) 
	
	# Add PI to mirror rotation on x/y for non leader players
	var rotation_offset = PI if not Global.is_leader else 0
	$TowerGun.rotation = current_rotation + rotation_offset

func get_mirrored_position(position):
	var x = (GameData.grid_size.x - 1 - position.x) * GameData.tile_size + GameData.grid_offset_x
	var y = (GameData.grid_size.y - 1 - position.y) * GameData.tile_size + GameData.grid_offset_y
	
	return Vector2(x, y)

func get_world_position(position):
	var x = position.x * GameData.tile_size + GameData.grid_offset_x
	var y = position.y * GameData.tile_size + GameData.grid_offset_y
	
	return Vector2(x, y)
