extends Control

const SCORE_BAR = preload("uid://ddqna4jy4mno4")
const WINNER_PROFILE = preload("uid://38he62wl8n72")

var world : GameWorld

func _ready() -> void:
	for i in %ScoresContainer.get_children(): i.free()
	for i in %WinnerContainer.get_children(): i.free()
	hide()

func start_scoring(player_points : Dictionary[int, Array]):
	%ScoresContainer.hide()
	%WinnerContainer.hide()
	
	var round_winner_id : int
	for player in player_points.keys():
		if round_winner_id: break
		for point in player_points[player]:
			if point == GameWorld.POINT_TYPE.WINNER:
				round_winner_id = player
				break
	
	if round_winner_id:
		%RoundFinish.text = str(
			"Round  Over!\n",
			Master.player_list[round_winner_id].display_name, "  wins!"
		)
	else:
		%RoundFinish.text = str(
			"Round  Over!\n",
			"No  winners"
		)
	
	%ResultsAnim.play("round_finish")
	await %ResultsAnim.animation_finished
	
	show_scoring(player_points)

func show_scoring(player_points : Dictionary[int, Array]):
	world = Master.game_manager.current_scene
	%Title.text = "Round  Results"
	%Title.show()
	%ScoresContainer.show()
	%WinnerContainer.hide()
	%MapName.hide()
	
	for i in player_points.keys():
		if player_points[i].has(GameWorld.POINT_TYPE.WINNER): 
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
	if longest_score != null:
		await %ScoresContainer.get_node(str(longest_score)).tween_scores(player_points[longest_score])
	
	await get_tree().create_timer(0.4).timeout
	
	world.round_points = {}
	
	var winner_list : Array[int] = []
	for i in %ScoresContainer.get_children():
		if i.won:
			winner_list.append(i.name.to_int())
	
	if !winner_list.is_empty():
		show_winners(winner_list)
	else:
		end_scoring()

func show_winners(winner_list : Array[int]):
	for i in %WinnerContainer.get_children(): i.queue_free()
	%ScoresContainer.hide()
	%WinnerContainer.show()
	
	%Title.text = "Winner!" if winner_list.size() == 1 else "Tie!"
	for i in winner_list:
		var inst = WINNER_PROFILE.instantiate()
		%WinnerContainer.add_child(inst)
		
		var id = i if i != 1 else Master.get_host_id()
		
		inst.player_pfp = Master.avatar_cache[id]
		inst.player_name = Steam.getFriendPersonaName(id)
		Steam.getPlayerAvatar()
	await get_tree().create_timer(4.5).timeout
	%WinnerContainer.hide()
	show_next_map()

func show_next_map():
	%Title.text = "Next  Map:"
	world.change_stadium()
	await get_tree().create_timer(0.5).timeout
	%MapName.text = world.current_stadium_name
	%MapName.show()
	await get_tree().create_timer(3.0).timeout
	%MapName.hide()
	end_scoring()

func end_scoring():
	if Master.is_host: 
		world.change_game_state.rpc(GameWorld.GAME_STATE.SELECTION)

func add_player_bar(player_id : int):
	var inst = SCORE_BAR.instantiate()
	inst.name = str(player_id)
	%ScoresContainer.add_child(inst)
func remove_player_bar(player_id : int):
	%ScoresContainer.get_node(str(player_id)).queue_free()
