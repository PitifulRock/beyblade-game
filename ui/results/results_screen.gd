extends Control

const SCORE_BAR = preload("uid://ddqna4jy4mno4")


func _ready() -> void:
	for i in %ScoresContainer.get_children(): i.free()

func start_scoring(player_points : Dictionary[int, Array]):
	for i in player_points.keys():
		if player_points[i].has(World.POINT_TYPE.WINNER): 
			%ScoresContainer.get_node(str(i)).win_icon.show()
		else:
			%ScoresContainer.get_node(str(i)).win_icon.hide()
	
	var score_lengths := {}
	for i in player_points.keys():
		score_lengths[i] = player_points[i].size()
	var longest_score = score_lengths.find_key(score_lengths.values().max())
	for id in player_points.keys():
		var score_bar = %ScoresContainer.get_node(str(id))
		if id != longest_score:
			score_bar.tween_scores(player_points[id])
	await %ScoresContainer.get_node(str(longest_score)).tween_scores(player_points[longest_score])
	
	await get_tree().create_timer(0.8).timeout
	
	var world : World = Master.game_manager.current_scene
	world.round_points = {}
	if Master.is_host: world.change_game_state.rpc(World.GAME_STATE.SELECTION)

func add_player_bar(player_id : int):
	var inst = SCORE_BAR.instantiate()
	inst.name = str(player_id)
	%ScoresContainer.add_child(inst)
func remove_player_bar(player_id : int):
	%ScoresContainer.get_node(str(player_id)).queue_free()
