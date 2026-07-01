extends Node3D
class_name GameWorld

enum GAME_STATE{SELECTION, PLACEMENT, BATTLE, RESULTS, WINNER}
enum POINT_TYPE{KNOCKOUT, STAMINA, DESTRUCTION, WINNER}

const point_values = {
	POINT_TYPE.KNOCKOUT : 1,
	POINT_TYPE.STAMINA : 1,
	POINT_TYPE.DESTRUCTION : 1,
	POINT_TYPE.WINNER : 2,
}
const point_names = {
	POINT_TYPE.KNOCKOUT : "Knockout",
	POINT_TYPE.STAMINA : "Survivor",
	POINT_TYPE.DESTRUCTION : "Destruction",
	POINT_TYPE.WINNER : "Winner",
}

@export var assembly_menu : Control
@export var results_menu : Control

@export_category("Spawn Paths")
@export var player_path : Node3D
@export var beyblade_path : Node3D
@export var particle_path : Node3D
@export var stadium_path : Node3D
@export var disaster_path : Node3D

@export_group("Synced Variables")
@export var gameplay_config : GameplayConfig
@export var current_state : GAME_STATE = GAME_STATE.SELECTION
@export var player_scores : Dictionary[int, int] = {}
@export var round_points : Dictionary[int, Array] = {}
@export var current_stadium_name := ""

@onready var disaster_timer: Timer = $DisasterTimer

var round_count := 0

@rpc("authority", "call_local", "reliable")
func change_game_state(new_state : GAME_STATE):
	current_state = new_state
	match new_state:
		GAME_STATE.SELECTION:
			Effects.fade_drum_track(false)
			if Master.local_player: Master.local_player.set_movement(false)
			round_points = {}
			results_menu.hide()
			assembly_menu.show()
			if gameplay_config.cheating_enabled and Master.is_host and Master.local_player:
				disable_cheats.rpc()
			for i in beyblade_path.get_children(): i.queue_free()
			for i in particle_path.get_children(): i.queue_free()
		GAME_STATE.PLACEMENT:
			Effects.fade_drum_track(true)
			Master.local_player.set_movement(true)
		GAME_STATE.BATTLE:
			Effects.fade_drum_track(true)
			Master.local_player.set_movement(true)
			if gameplay_config.disasters_enabled and Master.is_host:
				disaster_timer.start()
			if gameplay_config.cheating_enabled and Master.is_host:
				enable_cheats.rpc()
		GAME_STATE.RESULTS:
			Master.local_player.set_movement(true)
			disable_cheats.rpc()
			clear_disasters.rpc()
			disaster_timer.stop()
			
			results_menu.show()
			results_menu.start_scoring(round_points)
		GAME_STATE.WINNER:
			Master.local_player.set_movement(true)
			for i in player_scores.keys():
				player_scores[i] = 0

func _ready() -> void:
	Effects.set_sync_music()
	Effects.fade_drum_track(false, true)
	if Master.is_host:
		gameplay_config = Settings.gameplay_config
		
		Engine.time_scale = gameplay_config.game_speed
		await get_tree().process_frame
		change_game_state.rpc(GAME_STATE.SELECTION)

func _bey_death(point_type : POINT_TYPE, point_winner_id : int = -1):
	if current_state != GAME_STATE.BATTLE: return
	
	if point_type == POINT_TYPE.DESTRUCTION: _on_bey_burst.rpc()
	
	if point_winner_id > 0:
		if round_points.keys().has(point_winner_id):
			round_points[point_winner_id].append(point_type)
		else:
			round_points[point_winner_id] = [point_type]
	
	var alive_count := 0
	for i:BeyBlade in beyblade_path.get_children():
		var alive_condition : bool
		if Settings.gameplay_config.wait_for_npcs:
			alive_condition = (i.dead==false)
		else:
			alive_condition = (i.dead==false and !i.is_npc)
		if alive_condition: alive_count += 1
	
	if alive_count <= 1:
		if alive_count == 1:
			for i:BeyBlade in beyblade_path.get_children():
				if i.dead == false and !i.is_npc:
					if round_points.keys().has(i.name.to_int()):
						round_points[i.name.to_int()].append(POINT_TYPE.WINNER)
					else:
						round_points[i.name.to_int()] = [POINT_TYPE.WINNER]
		
		if Master.is_host:
			_set_round_points.rpc(round_points)
			change_game_state.rpc(GAME_STATE.RESULTS)

func change_stadium():
	if !Master.is_host: return
	
	round_count += 1
	var next := Registry.get_next_stadium_name(round_count)
	
	replace_stadium_scene.rpc(next)

@rpc("any_peer", "call_remote", "reliable")
func _set_round_points(updated_round_points:Dictionary[int, Array]):
	round_points = updated_round_points
@rpc("any_peer", "call_remote", "reliable")
func _set_game_config(points_to_win : int, game_speed : float, cheating_enabled : bool, npc_count : int = 0):
	Engine.time_scale = game_speed
	
	if !Master.is_host:
		gameplay_config = GameplayConfig.new()
		gameplay_config.points_to_win = points_to_win
		gameplay_config.game_speed = game_speed
		gameplay_config.cheating_enabled = cheating_enabled
		gameplay_config.npc_count = npc_count

@rpc("authority", "call_local", "reliable")
func replace_stadium_scene(new_stadium : StringName):
	current_stadium_name = new_stadium
	for i in stadium_path.get_children(): 
		i.queue_free()
	
	var stadium_scene : PackedScene
	stadium_scene = Registry.stadiums[new_stadium]
	var stadium_inst = stadium_scene.instantiate()
	
	stadium_path.add_child(stadium_inst, true)

@rpc("any_peer", "call_local", "reliable")
func _on_bey_burst():
	var tween = get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(Engine,"time_scale", 0.5, 0.2)
	tween.tween_interval(0.2)
	tween.tween_property(Engine,"time_scale", gameplay_config.game_speed, 0.4)

func player_added(id : int):
	assembly_menu.add_selection_menu(id)
	results_menu.add_player_bar(id)
	
	if id>0:
		player_scores[id] = 0
		round_points[id] = []
	
	if Master.is_host and id != 1: 
		change_game_state.rpc_id(id, current_state)
		_set_game_config.rpc_id(id, gameplay_config.points_to_win, gameplay_config.game_speed, gameplay_config.cheating_enabled)
		
		for i in Master.player_list:
			pass

func player_removed(id : int):
	assembly_menu.remove_selection_menu(id)
	results_menu.remove_player_bar(id)
	player_scores.erase(id)
	round_points.erase(id)

func _on_disaster_timer_timeout() -> void:
	if gameplay_config.disasters_enabled and current_state == GAME_STATE.BATTLE and Master.is_host:
		var disaster_index := randi_range(0, Registry.disasters.size()-1)
		start_disaster.rpc(disaster_index)

@rpc("any_peer", "call_local", "reliable")
func start_disaster(index : int):
	%DisasterAnim.play("warning")
	var inst = Registry.disasters[index].instantiate()
	disaster_path.add_child(inst)
@rpc("any_peer", "call_local", "reliable")
func clear_disasters():
	for i in disaster_path.get_children():
		i.queue_free()

@rpc("any_peer", "call_local", "reliable")
func enable_cheats():
	Master.local_player.enable_cheats()
@rpc("any_peer", "call_local", "reliable")
func disable_cheats():
	Master.local_player.disable_cheats()
func reset_disaster_timer():
	disaster_timer.stop()
	disaster_timer.start()
