extends Control

@onready var player : Player = $"../.."
var player_id : int
var world : GameWorld
var linked_beyblade : BeyBlade

func _input(_event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	
	if Input.is_action_just_pressed("pause"):
		if %PauseMenu.visible:
			%PauseMenu.save_settings()
			%PauseMenu.hide()
			if world.current_state == GameWorld.GAME_STATE.SELECTION:
				player.set_movement(false)
			else:
				player.set_movement(true)
		else:
			%PauseMenu.show()
			player.set_movement(false)

func _ready() -> void:
	world = Master.game_manager.current_scene
	%PauseMenu.hide()
	%GameUI.hide()
	%AbilityBar.hide()

func _process(_delta: float) -> void:
	if !is_multiplayer_authority(): return
	if %PauseMenu.visible and Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		player.set_movement(false)
	if linked_beyblade:
		%SpinBar.value = abs(linked_beyblade.current_spin)
		%SpinnerAnim.speed_scale = abs(%SpinBar.value/%SpinBar.max_value)
		%SpinLabel.text = str(int(abs(linked_beyblade.current_spin))," m/s")
		if linked_beyblade.ability_node:
			%AbilityBar.value = linked_beyblade.ability_node.current_charge

func _on_leave_lobby_pressed() -> void:
	Master.game_manager.remove_from_lobby(player_id)
func _on_quit_button_pressed() -> void:
	get_tree().quit()
func _on_resume_pressed() -> void:
	if %PauseMenu.visible:
		%PauseMenu.save_settings()
		%PauseMenu.hide()
		if world.current_state == GameWorld.GAME_STATE.SELECTION:
			player.set_movement(false)
		else:
			player.set_movement(true)
func _on_invite_friend_pressed() -> void:
	Steam.activateGameOverlayInviteDialog(Master.game_manager.lobby_id)

func show_game_ui(beyblade : BeyBlade):
	if !is_multiplayer_authority(): return
	linked_beyblade = beyblade
	
	%SpinnerAnim.speed_scale = 1.0
	%SpinnerAnim.play("speed_spinner")
	%SpinBar.max_value = abs(beyblade.spin_speed)
	%SpinBar.value = %SpinBar.max_value
	
	%AbilityBar.self_modulate = Color(0.662, 0.662, 0.662, 0.817)
	if linked_beyblade.ability_node:
		%AbilityBar.show()
		linked_beyblade.ability_node.ability_charged.connect(on_ability_charged)
		linked_beyblade.ability_node.ability_used.connect(on_ability_used)
		%AbilityName.text = linked_beyblade.ability_node.ability_data.ability_name
		%AbilityBody.text = linked_beyblade.ability_node.ability_data.ability_description
	else:
		%AbilityBar.hide()
	
	%GameUI.show()
func hide_game_ui():
	linked_beyblade = null
	%GameUI.hide()
	
	%SpinnerAnim.stop()
	%AbilityBar.self_modulate = Color(0.662, 0.662, 0.662, 0.817)
	%AbilityBar.hide()

func on_ability_charged():
	%AbilityBar.pivot_offset = %AbilityBar.size/2.0
	var t = get_tree().create_tween()
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(%AbilityBar, "scale", Vector2(1.15,1.15), 0.3)
	t.parallel().tween_property(%AbilityBar, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	t.tween_property(%AbilityBar, "scale", Vector2(1.0,1.0), 0.3)
func on_ability_used():
	%AbilityBar.pivot_offset = %AbilityBar.size/2.0
	var t = get_tree().create_tween()
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	t.tween_property(%AbilityBar, "self_modulate", Color(0.662, 0.662, 0.662, 0.817), 0.2)
