extends TabContainer

const BEY_PICKER = preload("uid://bc0qxhg451sac")

@export var bey_amount := 2
@export var ready_players := 0:
	set(val):
		ready_players = val
		_on_ready_players_changed()
@export var spawn_positions : Array[Marker3D]

var ready_count_started := false
var launch_count_started := false

func _ready() -> void:
	current_tab = 0
	hide()
	for i in %SelectionContainer.get_children(): i.free()
	for i in %ReadyIcons.get_children(): i.hide()
	%LabelID.text = str("Lobby ID: \n", Master.game_manager.lobby_id)
	%CopiedNotif.self_modulate.a = 0.0

func _process(_delta: float) -> void:
	if !%ReadyTimer.is_stopped():
		%ReadyTimerBar.value = (%ReadyTimer.wait_time-%ReadyTimer.time_left)/%ReadyTimer.wait_time
		if !ready_count_started: ready_countdown()
	else:
		%ReadyTimerBar.value = 0
		%ReadyTimerLabel.visible = false

func ready_countdown():
	ready_count_started = true
	%ReadyTimerLabel.visible = true
	for i in ceili(%ReadyTimer.time_left):
		if %ReadyTimerLabel.visible == false: break
		Effects.play_sfx(&"Timer")
		%ReadyTimerLabel.text = str(int(%ReadyTimer.wait_time - i))
		await get_tree().create_timer(1.0).timeout
	ready_count_started = false

func launch_countdown():
	%PlaceTimer.start()
	launch_count_started = true
	for i in ceili(%PlaceTimer.time_left):
		if %PlaceTimerLabel.visible == false: break
		Effects.play_sfx(&"Countdown")
		%PlaceTimerLabel.text = str(int(%PlaceTimer.wait_time - i))
		await get_tree().create_timer(1.0).timeout
	launch_count_started = false

func add_selection_menu(player_id : int):
	var picker = BEY_PICKER.instantiate()
	picker.name = str(player_id)
	%SelectionContainer.call_deferred("add_child", picker)
	await picker.ready 
	
	var index = %SelectionContainer.get_children().find(picker)
	picker.bey_assembler.global_position = spawn_positions[index].global_position
func remove_selection_menu(player_id : int):
	%SelectionContainer.get_node(str(player_id)).queue_free()

func _on_ready_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%ReadyButton.text = "Unready"
	else:
		%ReadyButton.text = "Ready"
	submit_ready.rpc(toggled_on)
	
@rpc("any_peer", "call_local", "reliable")
func submit_ready(is_ready: bool):
	if not multiplayer.is_server(): return
	ready_players += 1 if is_ready else -1

func _on_ready_players_changed():
	for i in %ReadyIcons.get_children(): i.hide()
	
	var ready_threshold = ceili(float(Master.player_list.size())/2)
	if ready_players > 0:
		for i in ready_players:
			%ReadyIcons.get_child(i).show()
		
		if ready_players > ready_threshold:
			if %ReadyTimer.is_stopped(): %ReadyTimer.start()
		if ready_players == Master.player_list.size():
			%ReadyTimer.stop()
			_on_ready_timer_timeout()
	else:
		%ReadyTimer.stop()

func _on_ready_timer_timeout() -> void:
	if not multiplayer.is_server(): return
	start_bey_placement.rpc()

@rpc("any_peer", "call_local", "reliable")
func start_bey_placement():
	%ReadyButton.button_pressed = false
	current_tab = 1
	launch_countdown()
	for i in %SelectionContainer.get_children():
		i.bey_assembler.prepare_launch()


func _on_copy_id_button_pressed() -> void:
	DisplayServer.clipboard_set(str(Master.game_manager.lobby_id))
	var t = get_tree().create_tween()
	%CopiedNotif.self_modulate.a = 1.0
	t.tween_property(%CopiedNotif, "self_modulate:a", 0.0, 0.8)


func _on_place_timer_timeout() -> void:
	for i in %SelectionContainer.get_children():
		i.bey_assembler.launch()
	if Master.is_host:
		Master.game_manager.current_scene.change_game_state.rpc(GameWorld.GAME_STATE.BATTLE)
	
	%PlaceTip.hide()
	%PlaceTimerLabel.text = "Launch!"
	await get_tree().create_timer(0.8).timeout
	
	hide()
	%PlaceTip.show()
	current_tab = 0
