extends FreeLookCamera
class_name Player

@export var throwables : Array[PackedScene]

var steam_id : int
@export var display_name : String:
	set(val):
		display_name = val
var beyblade_node : BeyBlade = null

var cheats_enabled := false

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _input(_event):
	if !is_multiplayer_authority(): return
	super._input(_event)
	if Input.is_action_just_pressed("blow") and !%BlowAnim.is_playing() and cheats_enabled:
		blow.rpc()
	if Input.is_action_just_pressed("throw") and %ThrowTimer.is_stopped() and cheats_enabled:
		%ThrowTimer.start()
		throw_object.rpc()

func _ready() -> void:
	disable_cheats()
	if is_multiplayer_authority():
		%OutlineShader.visible = Settings.get_video_settings()["outlines"] as bool
		%AudioListener3D.make_current()
		Master.register_steam_id.rpc(name.to_int(), Steam.getSteamID())
		
		for i in Master.game_manager.current_scene.player_path.get_children():
			Master.player_list[i.name.to_int()] = i
		Master.local_player = self

		display_name = Steam.getPersonaName()
		$Label3D.text = display_name
		current = true
		%Model.visible = false
	else:
		%OutlineShader.hide()
	
	steam_id = await _await_steam_id()
	Master.load_avatar(name.to_int())

func enable_cheats():
	cheats_enabled = true
	%CheatsScreen.show()
func disable_cheats():
	cheats_enabled = false
	%CheatsScreen.hide()

func set_outlines(enabled:bool):
	%OutlineShader.visible=enabled

@rpc("any_peer", "call_local")
func blow():
	%BlowAnim.play("blow")
@rpc("any_peer", "call_local")
func throw_object():
	var obj : RigidBody3D = throwables.pick_random().instantiate()
	Master.game_manager.current_scene.particle_path.add_child(obj)
	obj.global_position = %ThrowPoint.global_position
	obj.linear_velocity = -global_transform.basis.z * 20.0

func _await_avatar():
	while not Master.avatar_cache.has(name.to_int()):
		await get_tree().process_frame
	return Master.avatar_cache[name.to_int()]

func _await_steam_id() -> int:
	while not Master.steam_ids.has(name.to_int()):
		await get_tree().process_frame
	return Master.steam_ids[name.to_int()]

func _bey_enter(linked_beyblade : BeyBlade):
	%PlayerUI.show_game_ui(linked_beyblade)
func _bey_exit():
	%PlayerUI.hide_game_ui()
