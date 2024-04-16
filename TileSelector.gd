extends Node2D

signal selector_clicked(allowed_corners)

var selector_half_size = Vector2(GameData.tile_size, GameData.tile_size)

var can_place = false
var selector_corners = []

func _ready():
	self.modulate = Color(1, 1, 1, 0.5)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		if is_mouse_within_grid(mouse_pos) and can_place:
			update_position(mouse_pos)
			emit_signal("selector_clicked", selector_corners)
			return
		self.visible = false if event.is_action_pressed("ui_cancel") else self.visible

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	if is_mouse_within_grid(mouse_pos):
		update_position(mouse_pos)
		if GameData.tile_map.size() > 0:
			check_tiles()
			update_selector_corners()
		self.visible = true
	else:
		self.visible = false

func update_position(mouse_pos):
	var grid_pos = mouse_pos - selector_half_size - Vector2(GameData.grid_offset_x, GameData.grid_offset_y)
	var snapped_pos = grid_pos.snapped(Vector2(GameData.tile_size, GameData.tile_size))
	position = snapped_pos + selector_half_size + Vector2(GameData.grid_offset_x, GameData.grid_offset_y)

func check_tiles():
	can_place = true
	for i in range(4):  # Assumes a 2x2 selector
		var local_x = i % 2
		var local_y = int(i / 2)
		var base_tile_pos = (position - selector_half_size - Vector2(GameData.grid_offset_x, GameData.grid_offset_y)) / GameData.tile_size
		var tile_pos = base_tile_pos + Vector2(local_x, local_y)
		
		var is_in_right_side = tile_pos.y >= GameData.grid_size.y / 2
		
		if not Global.is_leader:  # Mirror positions if not the leader
			tile_pos.x = GameData.grid_size.x - 1 - tile_pos.x
			tile_pos.y = GameData.grid_size.y - 1 - tile_pos.y
		
		if tile_pos.x >= 0 and tile_pos.y >= 0 and tile_pos.x < GameData.grid_size.x and tile_pos.y < GameData.grid_size.y:
			var sprite = get_node_or_null("Sprite" + str(i))
			if sprite:
				var tile = GameData.tile_map[int(tile_pos.x)][int(tile_pos.y)]
				if tile != null and tile['walkable'] and not tile['tower_id'] and is_in_right_side:
					sprite.texture = preload("res://pixel-ui/green_tile.png")
				else:
					sprite.texture = preload("res://pixel-ui/red_tile.png")
					can_place = false

func is_mouse_within_grid(mouse_pos):
	if GameData.grid_size:
		var grid_pos = mouse_pos - Vector2(GameData.grid_offset_x, GameData.grid_offset_y)
		return grid_pos.x >= GameData.tile_size and grid_pos.y >= GameData.tile_size and grid_pos.x < GameData.grid_size.x * GameData.tile_size - GameData.tile_size and grid_pos.y < GameData.grid_size.y * GameData.tile_size - GameData.tile_size

func update_selector_corners():
	var base_pos = (position - selector_half_size - Vector2(GameData.grid_offset_x, GameData.grid_offset_y)) / GameData.tile_size
	
	var corners = [
		base_pos,
		base_pos + Vector2(1, 0),
		base_pos + Vector2(1, 1),
		base_pos + Vector2(0, 1)
	]
	
	if not Global.is_leader:
		var mirrored_corners = []
		for corner in corners:
			var mirrored_x = GameData.grid_size.x - 1 - corner.x
			var mirrored_y = GameData.grid_size.y - 1 - corner.y
			mirrored_corners.append(Vector2(mirrored_x, mirrored_y))
		corners = mirrored_corners
		
	selector_corners = corners
