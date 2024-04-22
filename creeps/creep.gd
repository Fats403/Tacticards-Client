extends Node2D

var health
var speed
var target_position = Vector2.ZERO
var last_update_time = 0  # Time of the last position update
var last_walk_direction = "s"  # Default walking direction

var is_alive = true
var has_died = false
var is_attacking = false  # State to manage if the creep is currently attacking

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
	is_attacking = creep_data.attacking

func update(creep_data):
	$HealthBar.value = round(creep_data.health)
	is_attacking = creep_data.attacking
	
	if Global.is_leader:
		target_position = GameUtils.get_world_position(creep_data.position)
	else:
		target_position = GameUtils.get_mirrored_position(creep_data.position)
	
	last_update_time = Time.get_ticks_msec()
	
func _process(delta):
	if is_alive:
		if is_attacking:
			determine_attack_animation()
		else:
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
		last_walk_direction = "s"
		_animated_sprite.play("walk_s")
		_animated_sprite.flip_h = movement_delta.x > 0
	else:
		if movement_delta.y < 0:
			last_walk_direction = "u"
			_animated_sprite.play("walk_u")
		else:
			last_walk_direction = "d"
			_animated_sprite.play("walk_d")

func determine_attack_animation():
	var attack_animation = "attack_" + last_walk_direction
	# Check if there's a specific attack animation for the last walk direction
	if _animated_sprite.sprite_frames.has_animation(attack_animation):
		_animated_sprite.play(attack_animation)
	else:
		_animated_sprite.play("walk_" + last_walk_direction)

func trigger_death_animation():
	var death_anim = "death_" + last_walk_direction
	$HealthBar.hide()
	_animated_sprite.play(death_anim)
	has_died = true

func _on_AnimationFinished():
	if not is_alive and has_died:
		queue_free()

func kill():
	is_alive = false
