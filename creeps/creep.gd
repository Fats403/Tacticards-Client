extends Node2D

var health
var speed
var target_position = Vector2.ZERO
var last_update_time = 0  # Time of the last position update

var is_alive = true
var has_died = false

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _health_bar = $HealthBar
	
func _ready():
	$HealthBar.max_value = health
	_animated_sprite.animation_finished.connect(Callable(self, "_on_AnimationFinished"))

func init(creep_data):
	name = "Creep_%s" % creep_data.id
	
	var initial_position:Vector2
	
	if Global.is_leader:
		initial_position = GameUtils.get_world_position(creep_data.position)
	else:
		initial_position = GameUtils.get_mirrored_position(creep_data.position)
	
	position = initial_position
	target_position = initial_position
	
	health = creep_data.health
	speed = creep_data.speed
	
# Function to update position based on incoming data
func update(creep_data):
	
	$HealthBar.value = round(creep_data.health)
	
	if Global.is_leader:
		target_position = GameUtils.get_world_position(creep_data.position)
	else:
		target_position = GameUtils.get_mirrored_position(creep_data.position)
	
	last_update_time = Time.get_ticks_msec()
	
func _process(delta):
	if is_alive:
		update_position(delta)
	elif not has_died:
		trigger_death_animation()

func update_position(delta):
	
	var now = Time.get_ticks_msec()
	var time_since_update = (now - last_update_time) / 1000.0
	var lerp_factor = clamp(time_since_update, 0.1, 0.5)
	
	determine_animation()
	
	position = position.lerp(target_position, lerp_factor)
	last_update_time = now

func determine_animation():
	var movement_delta = target_position - position
	if abs(movement_delta.x) > abs(movement_delta.y):
		_animated_sprite.play("walk_s")
		_animated_sprite.flip_h = movement_delta.x > 0
	else:
		if movement_delta.y < 0:
			_animated_sprite.play("walk_u")
		else:
			_animated_sprite.play("walk_d")

func trigger_death_animation():
	# Play the appropriate death animation
	var death_anim = "death_s"
	if _animated_sprite.animation == "walk_u":
		death_anim = "death_u"
	elif _animated_sprite.animation == "walk_d":
		death_anim = "death_d"

	$HealthBar.hide()
	
	_animated_sprite.play(death_anim)
	has_died = true

func _on_AnimationFinished():
	if not is_alive and has_died:
		queue_free()

func kill():
	is_alive = false
