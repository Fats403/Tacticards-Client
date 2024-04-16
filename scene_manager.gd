extends Node

func change_to_lobby(lobby_id:int):

	if has_node("/root/Menu"):
		get_node("/root/Menu").free()
	
	var lobby_scene = load("res://lobby.tscn").instantiate()
	lobby_scene.name = "Lobby_%s" % lobby_id
	
	get_tree().root.add_child(lobby_scene)

func change_to_game(lobby_id:int, leader_id):
	var lobby_node = "/root/Lobby_%s" % str(lobby_id)
	
	if has_node(lobby_node):
		get_node(lobby_node).queue_free()
	
	var game_scene = load("res://game.tscn").instantiate()
	game_scene.name = "Game_%s" % lobby_id
	
	get_tree().root.add_child(game_scene)
