extends Node3D
class_name GameWorld

enum GAME_STATE{NEW_GAME, SELECTION, PLACEMENT, BATTLE, RESULTS, WINNER}
enum POINT_TYPE{KNOCKOUT, STAMINA, DESTRUCTION, WINNER}

const point_values = {
	POINT_TYPE.KNOCKOUT : 1,
	POINT_TYPE.STAMINA : 1,
	POINT_TYPE.DESTRUCTION : 2,
	POINT_TYPE.WINNER : 2,
}
const point_names = {
	POINT_TYPE.KNOCKOUT : "Knockout",
	POINT_TYPE.STAMINA : "Survivor",
	POINT_TYPE.DESTRUCTION : "Destruction",
	POINT_TYPE.WINNER : "Winner",
}

@onready var place_cam: Camera3D = $PlaceCam

@export var assembly_menu : Control
@export var results_menu : Control

@export_category("Spawn Paths")
@export var player_path : Node3D
@export var beyblade_path : Node3D
@export var particle_path : Node3D
@export var stadium_path : Node3D


@export_group("Synced Variables")
@export var gameplay_config : GameplayConfig
@export var current_state : GAME_STATE = GAME_STATE.SELECTION
@export var player_scores : Dictionary[int, int] = {}
@export var round_points : Dictionary[int, Array] = {}
@export var current_stadium_name := ""

@rpc("authority", "call_local", "reliable")
func change_game_state(new_state : GAME_STATE):
	match new_state:
		GAME_STATE.SELECTION:
			round_points = {}
			results_menu.hide()
			assembly_menu.show()
			for i in beyblade_path.get_children(): i.queue_free()
			for i in particle_path.get_children(): i.queue_free()
		GAME_STATE.PLACEMENT:
			assembly_menu.hide()
			place_cam.current = true
		GAME_STATE.BATTLE:
			Master.local_player.current = true
		GAME_STATE.RESULTS:
			results_menu.show()
			results_menu.start_scoring(round_points)
		GAME_STATE.WINNER:
			results_menu.hide()
			
		GAME_STATE.NEW_GAME:
			for i in player_scores.keys():
				player_scores[i] = 0

func _ready() -> void:
	if Master.is_host:
		change_game_state.rpc(GAME_STATE.SELECTION)

func _bey_death(point_type : POINT_TYPE, point_winner_id : int = -1):
	if point_type == POINT_TYPE.DESTRUCTION: _on_bey_burst.rpc()
	
	if point_winner_id > 0:
		if round_points.keys().has(point_winner_id):
			round_points[point_winner_id].append(point_type)
		else:
			round_points[point_winner_id] = [point_type]
	
	var alive_count := 0
	for i:BeyBlade in beyblade_path.get_children():
		if i.dead == false: alive_count += 1
	
	if alive_count <= 1:
		if alive_count == 1:
			for i:BeyBlade in beyblade_path.get_children():
				if i.dead == false:
					if round_points.keys().has(i.name.to_int()):
						round_points[i.name.to_int()].append(POINT_TYPE.WINNER)
					else:
						round_points[i.name.to_int()] = [POINT_TYPE.WINNER]
		
		if Master.is_host:
			_set_round_points.rpc(round_points)
			change_game_state.rpc(GAME_STATE.RESULTS)

@rpc("any_peer", "call_remote", "reliable")
func _set_round_points(updated_round_points:Dictionary[int, Array]):
	round_points = updated_round_points

func change_stadium():
	if !Master.is_host: return
	
	var stadium_scene : PackedScene
	var rand_ind = PartRegistry.stadiums.keys().pick_random()
	stadium_scene = PartRegistry.stadiums[rand_ind]
	current_stadium_name = rand_ind
	
	for i in stadium_path.get_children(): 
		i.queue_free()
		
	var stadium_inst = stadium_scene.instantiate()
	stadium_path.add_child(stadium_inst)

@rpc("any_peer", "call_local", "reliable")
func _on_bey_burst():
	var tween = get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(Engine,"time_scale", 0.3, 0.8)
	tween.tween_interval(0.3)
	tween.tween_property(Engine,"time_scale", gameplay_config.game_speed, 0.8)

func player_added(id : int):
	assembly_menu.add_selection_menu(id)
	results_menu.add_player_bar(id)
	player_scores[id] = 0
	round_points[id] = []
	
	if Master.is_host: change_game_state.rpc_id(id, current_state)
func player_removed(id : int):
	assembly_menu.remove_selection_menu(id)
	results_menu.remove_player_bar(id)
	player_scores.erase(id)
	round_points.erase(id)
