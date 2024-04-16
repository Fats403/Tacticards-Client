extends Node

# Steam variables
var is_online: bool = false
var is_owned: bool = false
var steam_app_id: int = 480
var steam_id: int = 0
var steam_username: String = ""
var current_lobby_id: int = 0
var is_leader = false

func _ready() -> void:
	initialize_steam()

func set_lobby_id(new_lobby_id: int) -> void:
	current_lobby_id = new_lobby_id

func get_lobby_id() -> int:
	return current_lobby_id;

func initialize_steam() -> void:
	var initialize_response: Dictionary = Steam.steamInitEx(false, steam_app_id, true)
	print("Did Steam initialize?: %s" % initialize_response)

	if initialize_response['status'] > 0:
		print("Failed to initialize Steam. Shutting down. %s" % initialize_response)
		get_tree().quit()

	# Gather additional data
	is_online = Steam.loggedOn()
	is_owned = Steam.isSubscribed()
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()

	# Check if account owns the game
	# if is_owned == false:
		# print("User does not own this game")
		# get_tree().quit()
		
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST: 
		Steam.steamShutdown();
		get_tree().quit()
