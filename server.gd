extends Node

const DEFAULT_PORT = 8910
const DEFAULT_IP = 'ec2-15-156-96-172.ca-central-1.compute.amazonaws.com'

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	
	connect_to_server()

func connect_to_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer

func _on_connected_to_server() -> void:
	print("Successfully connected to server!")
	
func _on_connection_failed() -> void:
	print("Failed connection to server!")
	
@rpc("any_peer", "reliable")
func join_lobby(lobby_id:int) -> void:
	rpc_id(1, "join_lobby", multiplayer.get_unique_id(), lobby_id)

@rpc("any_peer", "reliable")
func create_lobby(lobby_id:int) -> void:
	Global.is_leader = true
	rpc_id(1, "create_lobby", multiplayer.get_unique_id(), lobby_id)

@rpc("reliable", "authority")
func client_opponent_disconnected():
	var game_node = "/root/Game_%s" % Global.get_lobby_id()
	
	if has_node(game_node):
		get_node(game_node).queue_free()
		
	var menu_scene = load("res://menu.tscn").instantiate()
	get_tree().root.add_child(menu_scene)
	
	Global.is_leader = false
