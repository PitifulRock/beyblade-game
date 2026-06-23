extends Control

var current_score : int = 0
var won := false

@onready var point_bar: ProgressBar = %PointBar
@onready var win_icon: TextureRect = %WinIcon
@onready var score_label: Label = %ScoreLabel
@onready var name_label: Label = %PlayerName

func reset():
	current_score = 0
	won = false
	%PointBar.value = 0

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if is_multiplayer_authority():
		name_label.text = Steam.getPersonaName()

func prepare():
	%WinIcon.hide()
	%ScoreLabel.self_modulate.a = 0.0
	%ScoreLabel.text = ""
func tween_scores(scores : Array, longest_score := false):
	var world : GameWorld = Master.game_manager.current_scene
	var tweened_score = current_score
	current_score = world.player_scores[name.to_int()]
	point_bar.max_value = world.gameplay_config.points_to_win
	score_label.text = ""
	
	await get_tree().create_timer(0.5).timeout
	if scores.is_empty(): return
	
	var tween_time = 0.8
	var t = get_tree().create_tween()
	t.set_parallel(false)
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_EXPO)
	
	var score_pitch := 1.0
	for point_type in scores:
		var label_text = GameWorld.point_names[point_type]
		tweened_score += GameWorld.point_values[point_type]
		
		score_pitch += 0.2
		
		t.tween_callback(func():
			score_label.text = label_text
			score_label.self_modulate.a = 1.0
			
			if longest_score == true:
				%ScoreNoise.pitch_scale = score_pitch
				%ScoreNoise.play()
		)
		
		t.tween_property(point_bar, "value", tweened_score, tween_time)
		t.parallel().tween_property(score_label, "self_modulate:a", 0.8, tween_time)
	await t.finished
	current_score = tweened_score
	
	if Master.is_host:
		world.player_scores[name.to_int()] = current_score
	if current_score >= world.gameplay_config.points_to_win:
		won = true
