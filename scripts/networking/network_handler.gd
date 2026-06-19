extends Node
class_name GameManager

signal scene_ready

@export var player_scene : PackedScene
@export var world_scene : PackedScene
@export var menu_scene : PackedScene
@export var default_scene : Node

var spawn_path : Node3D
var lobby_id : int = 0
var peer : SteamMultiplayerPeer
var is_host : bool = false
var is_joining : bool = false
var current_scene : Node

func _ready() -> void:
	randomize()
	current_scene = default_scene
	Master.game_manager = self
	#Steam.steamInitEx(480, true)
	#Steam.initRelayNetworkAccess()
	
	if not Steam.isSteamRunning():
		push_error("Steam not running")
		return
	
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	multiplayer.server_disconnected.connect(_on_lobby_closed)

func host_server() -> void:
	Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC, 16)
	Master.is_host = true
	is_host = true

func _on_lobby_created(result: int, passed_lobby_id:int):
	if result == Steam.Result.RESULT_OK:
		lobby_id = passed_lobby_id
		
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.connect(_remove_player)
		
		switch_scene(world_scene)
		await scene_ready
		_add_player()
		print("Lobby ID: ", lobby_id)

func join_lobby(passed_lobby_id : int):
	is_joining = true
	Steam.joinLobby(passed_lobby_id)

func _on_lobby_joined(passed_lobby_id : int, _perms : int, _locked : bool, _response : int):
	if !is_joining: return
	
	lobby_id = passed_lobby_id
	peer = SteamMultiplayerPeer.new()
	peer.server_relay = true
	peer.create_client(Steam.getLobbyOwner(passed_lobby_id))
	multiplayer.multiplayer_peer = peer
	switch_scene(world_scene)
	
	is_joining = false

func _add_player(id : int = 1):
	if current_scene is not World: return
	if multiplayer.is_server() and current_scene is World:
		var player = player_scene.instantiate()
		player.name = str(id)
		current_scene.player_path.call_deferred("add_child", player)
		Master.player_list[id] = player
		current_scene.assembly_menu.add_selection_menu(id)

func _remove_player(id : int):
	if !current_scene.player_path.has_node(str(id)):
		return
	
	if Master.player_list.has(id):
		Master.player_list.erase(id)
	current_scene.player_path.get_node(str(id)).queue_free()

func remove_from_lobby(_player_id : int):
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	Steam.leaveLobby(lobby_id)
	
func _on_lobby_closed():
	multiplayer.multiplayer_peer.close()
	Master.player_list = {}
	switch_scene(menu_scene)

func switch_scene(scene : PackedScene):
	current_scene.queue_free()
	await get_tree().process_frame
	
	var inst = scene.instantiate()
	add_child(inst)
	
	await get_tree().process_frame
	current_scene = inst
	
	if inst is World:
		$MultiplayerSpawner.spawn_path = inst.player_path.get_path()
	else:
		$MultiplayerSpawner.spawn_path = inst.get_path()
	
	scene_ready.emit()

func _process(_delta: float) -> void:
	Steam.run_callbacks()
