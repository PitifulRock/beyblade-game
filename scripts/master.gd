extends Node

signal lobby_closed

var game_manager : GameManager

var is_online = false

var local_player : Player
var is_host := false

var player_list : Dictionary[int, Player] = {}
var steam_ids : Dictionary[int, int] = {}
var avatar_cache : Dictionary[int, Texture2D] = {}

func _ready():
	Steam.avatar_loaded.connect(_on_avatar_loaded)

func get_host_id():
	if !game_manager or !game_manager.lobby_id: return null
	return Steam.getLobbyData(game_manager.lobby_id, "host_id").to_int()

@rpc("any_peer", "call_local", "reliable")
func delete_node(node_path: NodePath):
	var node_inst = get_node_or_null(node_path)
	if node_inst != null:
		node_inst.queue_free()

@rpc("any_peer", "call_local", "reliable")
func spawn_node(scene_path: NodePath, spawn_position:= Vector3.ZERO, spawn_path: NodePath = game_manager.current_scene.spawned_items_path.get_path()):
	var scene_resource = load(scene_path)
	if scene_resource != null:
		var scene_inst = scene_resource.instantiate()
		var node_path = get_node_or_null(spawn_path)
		if node_path == null:
			node_path = get_node_or_null(game_manager.current_scene.spawned_items.get_path())
		
		node_path.add_child(scene_inst)
		scene_inst.position = spawn_position

@rpc("any_peer", "call_remote", "reliable")
func spawn_node_for_peers(scene_path: NodePath, spawn_position:= Vector3.ZERO, spawn_path: NodePath = game_manager.current_scene.spawned_items_path.get_path(), disable_node := true):
	var scene_resource = load(scene_path)
	if scene_resource != null:
		var scene_inst : Node = scene_resource.instantiate()
		var node_path = get_node_or_null(spawn_path)
		if node_path == null:
			node_path = get_node_or_null(game_manager.current_scene.spawned_items.get_path())
		
		node_path.add_child(scene_inst)
		if disable_node: scene_inst.process_mode = scene_inst.PROCESS_MODE_DISABLED
		scene_inst.position = spawn_position

@rpc("any_peer", "call_local", "reliable")
func register_steam_id(peer_id : int, steam_id: int):
	Master.steam_ids[peer_id] = steam_id
	if multiplayer.is_server() and peer_id != 1:
		sync_steam_ids.rpc_id(peer_id, steam_ids)
@rpc("authority", "reliable")
func sync_steam_ids(all_ids: Dictionary):
	steam_ids = all_ids

func load_avatar(player_id):
	var id = Master.steam_ids[player_id]
	Steam.getPlayerAvatar(3, id)

func _on_avatar_loaded(avatar_id: int, size: int, data: Array):
	var avatar_image: Image = Image.create_from_data(size, size, false, Image.FORMAT_RGBA8, data)
	if size > 128:
		avatar_image.resize(128, 128, Image.INTERPOLATE_LANCZOS)

	var avatar_texture: ImageTexture = ImageTexture.create_from_image(avatar_image)
	
	var avatar_owner_id = steam_ids.find_key(avatar_id)
	avatar_cache[avatar_owner_id] = avatar_texture
	Console._print(avatar_owner_id, "avatar cached")

func clear_game_cache():
	Master.avatar_cache.clear()
	Master.local_player = null
	Master.player_list.clear()
	Master.steam_ids.clear()
	Master.is_host = false
