extends Node

signal lobby_closed

var local_player : Player
var is_host := false
var player_list : Dictionary[int, Player] = {}
var game_manager : GameManager
var pickup_success := false

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
