extends Node2D

var target_position = Vector2.ZERO

func init(bullet_data):
	name = "Bullet_%s" % bullet_data.id

	var initial_position:Vector2
	
	if Global.is_leader:
		initial_position = GameUtils.get_world_position(bullet_data.position)
	else:
		initial_position = GameUtils.get_mirrored_position(bullet_data.position)
	
	target_position = initial_position
	position = initial_position

func update(bullet_data):
	if Global.is_leader:
		target_position = GameUtils.get_world_position(bullet_data.position)
	else:
		target_position = GameUtils.get_mirrored_position(bullet_data.position)

func update_position(delta):
	# Use linear interpolation to smoothly transition to the target position
	position = position.lerp(target_position, 0.9)

func _process(delta):
	update_position(delta)
