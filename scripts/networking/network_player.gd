extends FreeLookCamera
class_name Player

var steam_id : int
@export var display_name : String:
	set(val):
		display_name = val
var beyblade_node : BeyBlade = null

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if is_multiplayer_authority():
		Master.register_steam_id.rpc(name.to_int(), Steam.getSteamID())
		
		for i in Master.game_manager.current_scene.player_path.get_children():
			Master.player_list[i.name.to_int()] = i
		Master.local_player = self

		display_name = Steam.getPersonaName()
		$Label3D.text = display_name
		current = true
		%Model.visible = false
	
	steam_id = await _await_steam_id()
	Master.load_avatar(name.to_int())

func _await_avatar():
	while not Master.avatar_cache.has(name.to_int()):
		await get_tree().process_frame
	return Master.avatar_cache[name.to_int()]

func _await_steam_id() -> int:
	while not Master.steam_ids.has(name.to_int()):
		await get_tree().process_frame
	return Master.steam_ids[name.to_int()]
