extends Control

var current_score : int = 0

@onready var point_bar: ProgressBar = %PointBar
@onready var win_icon: TextureRect = %WinIcon
@onready var score_label: Label = %ScoreLabel
@onready var name_label: Label = %PlayerName

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if is_multiplayer_authority():
		name_label.text = Steam.getPersonaName()

func tween_scores(scores : Array):
	var world : World = Master.game_manager.current_scene
	var tweened_score = current_score
	current_score = world.player_scores[name.to_int()]
	point_bar.max_value = world.gameplay_config.points_to_win
	score_label.text = ""
	
	await get_tree().create_timer(0.5).timeout
	if scores.is_empty(): return
	
	var t = get_tree().create_tween()
	t.set_parallel(false)
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_CUBIC)
	
	for point_type in scores:
		var label_text = World.point_names[point_type]
		tweened_score += World.point_values[point_type]
		
		t.tween_callback(func():
			score_label.text = label_text
			score_label.self_modulate.a = 1.0
		)
		
		t.tween_property(point_bar, "value", tweened_score, 1.0)
		t.parallel().tween_property(score_label, "self_modulate:a", 0.5, 1.0)
	await t.finished
	current_score = tweened_score
	
	if Master.is_host:
		world.player_scores[name.to_int()] = current_score
