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
		OS.alert("Steam is not running", "Alert")
		Master.is_online = false
		return
	else:
		Master.is_online = true
	
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	multiplayer.server_disconnected.connect(_on_lobby_closed)

func host_server() -> void:
	Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC, 4)
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
		
		await switch_scene(world_scene)
		
		_add_player()
		
		Steam.setLobbyData(lobby_id, "host_id", str(Steam.getSteamID()))
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
	switch_scene.call_deferred(world_scene)
	
	is_joining = false

func _add_player(id : int = 1):
	if current_scene is not GameWorld: 
		return
	if multiplayer.is_server():
		var player = player_scene.instantiate()
		player.name = str(id)
		current_scene.player_path.call_deferred("add_child", player)
		Master.player_list[id] = player
		
		current_scene.player_added(id)

func _remove_player(id : int):
	if !current_scene.player_path.has_node(str(id)):
		return
	
	if Master.player_list.has(id):
		Master.player_list.erase(id)
	current_scene.player_path.get_node(str(id)).queue_free()
	
	current_scene.player_removed(id)

func remove_from_lobby(_player_id : int):
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	Steam.leaveLobby(lobby_id)
	Master.avatar_cache.clear()
	Master.player_list.clear()
	
func _on_lobby_closed():
	multiplayer.multiplayer_peer.close()
	Master.player_list = {}
	switch_scene(menu_scene)

func switch_scene(scene : PackedScene):
	await Effects.transition()
	
	if current_scene:
		current_scene.queue_free()
	
	var inst = scene.instantiate()
	add_child(inst)
	
	if not inst.is_node_ready():
		await inst.ready
	
	current_scene = inst
	
	if inst is GameWorld:
		$MultiplayerSpawner.spawn_path = inst.player_path.get_path()
	else:
		$MultiplayerSpawner.spawn_path = inst.get_path()
	
	scene_ready.emit()

func _process(_delta: float) -> void:
	Steam.run_callbacks()
