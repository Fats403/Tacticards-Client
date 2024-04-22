extends Node2D

@onready var wave_timer = $WaveTimer
@onready var health_bar_player = $HealthBarPlayer
@onready var health_bar_opponent = $HealthBarOpponent

@onready var choose_card_overlay = $ChooseCardOverlay

var selector
var tile_map = []
var creep_nodes = {}
var tower_nodes = {}
var bullet_nodes = {}
var lobby_id = Global.get_lobby_id()

func _ready():
	selector = preload("res://tile_selector.tscn").instantiate()
	selector.connect("selector_released", Callable($PlayerField, "_on_selector_released"))
	add_child(selector)
	
	$PlayerField.connect('request_place_card', Callable(self, "_on_request_place_card"))
	$PlayerField.connect('start_drag_card', Callable(selector, "_on_start_drag"))
	$PlayerField.connect('stop_drag_card', Callable(selector, "_on_stop_drag"))
	
	choose_card_overlay.connect("card_choices_selected", Callable(self, "_on_card_choices_selected"))
	
func _on_request_place_card(card_id, corners):
	rpc_id(1, "request_place_card", multiplayer.get_unique_id(), card_id, corners)
	
func _on_card_choices_selected(selected_cards):
	rpc_id(1, "request_card_choices", multiplayer.get_unique_id(), selected_cards)
	
@rpc("reliable", "authority")
func client_set_initial_game_state(map, players_data):
	
	GameData.tile_map = map
	GameData.grid_size = Vector2(map.size(), map[0].size())
	GameData.grid_width = GameData.grid_size.x * GameData.tile_size
	GameData.grid_height = GameData.grid_size.y * GameData.tile_size
	
	GameData.player = players_data.player
	GameData.opponent = players_data.opponent
	
	health_bar_player.max_value = GameData.player.health
	health_bar_player.value = GameData.player.health
	
	health_bar_opponent.max_value = GameData.opponent.health
	health_bar_opponent.value = GameData.opponent.health
	
	$ChooseCardOverlay.set_card_choices(GameData.player.choices)
	

@rpc("reliable", "authority")
func client_update_player_state(player):
	health_bar_player.value = player.health
	
	$PlayerField.set_player_data(player)

@rpc("reliable", "authority")
func client_update_opponent_state(opponent):
	print(opponent)
	GameData.opponent = opponent
	health_bar_opponent.value = opponent.health
			
@rpc("reliable", "authority")
func client_kill_creep(_id):
	var creep_id = 'Creep_%s' % str(_id)
	
	if has_node(creep_id):
		var creep_node = get_node(creep_id)
		creep_node.kill()
	
	if _id in creep_nodes:
		creep_nodes.erase(_id)

@rpc("reliable", "authority")
func client_remove_bullet(bullet_id):
	var bullet_node = 'Bullet_%s' % str(bullet_id)
	
	if has_node(bullet_node):
		get_node(bullet_node).free()
		
	if bullet_id in bullet_nodes:
		bullet_nodes.erase(bullet_id)

@rpc("reliable", "authority")
func client_update_wave_timer(time):
	if time < 0:
		time = 0
	wave_timer.text = str(abs(floor(time)))

@rpc("reliable", "authority")
func client_update_player_health(player_id, health):
	if player_id == multiplayer.get_unique_id():
		health_bar_player.value = health
	else:
		health_bar_opponent.value = health

@rpc("reliable", "authority")
func client_update_map_state(map):
	# TODO: only send what needs to be updated
	GameData.tile_map = map

@rpc("reliable", "authority")
func client_create_tower(creator_id, serialized_tower):
	var player_id = multiplayer.get_unique_id()
	if not serialized_tower.id in tower_nodes:
		var tower_scene_ref = GameData.tower_scene_ref[serialized_tower.type]
		var tower_instance = load(tower_scene_ref).instantiate()
		
		tower_instance.init(player_id, creator_id, serialized_tower)
		tower_nodes[serialized_tower.id] = tower_instance
		add_child(tower_instance)
	
@rpc("unreliable", "authority")
func client_update_creep_positions(serialized_creeps):
	for serialized_creep in serialized_creeps:
		var creep_id = serialized_creep.id
		
		if not creep_id in creep_nodes:
			return
			
		var creep_node = creep_nodes[creep_id]
		creep_node.update(serialized_creep)

@rpc("unreliable", "authority")
func client_update_tower_states(serialized_towers):
	for serialized_tower in serialized_towers:
		var tower_id = serialized_tower.id
		
		if not tower_id in tower_nodes:
			return
		
		var tower_node = tower_nodes[tower_id]
		tower_node.update(serialized_tower)

@rpc("unreliable", "authority")
func client_update_bullets(serialized_bullets):
	for serialized_bullet in serialized_bullets:
		var bullet_id = serialized_bullet.id
		
		if bullet_id in bullet_nodes:
			var bullet_node = bullet_nodes[bullet_id]
			bullet_node.update(serialized_bullet)
		else:
			var bullet_scene_ref = GameData.bullet_scene_ref[serialized_bullet.type]
			var bullet_instance = load(bullet_scene_ref).instantiate()
			
			bullet_instance.init(serialized_bullet)
			bullet_nodes[serialized_bullet.id] = bullet_instance
			add_child(bullet_instance)

@rpc("unreliable", "authority")
func client_create_creep(serialized_creep):
	var creep_id = serialized_creep.id
	
	if creep_id in creep_nodes:
		# Already exists
		return
		
	var creep_scene_ref = GameData.creep_scene_ref[serialized_creep.type]
	var creep_instance = load(creep_scene_ref).instantiate()
	
	creep_instance.init(serialized_creep)
	creep_nodes[creep_id] = creep_instance
	add_child(creep_instance)

@rpc("any_peer", "reliable")
func request_place_card():
	pass

@rpc("any_peer", "reliable")
func request_card_choices():
	pass
