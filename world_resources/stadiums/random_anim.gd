extends AnimationPlayer

@export var await_round_start := true
@export var cooldown := 0.5
@export var animations : Array[String]

var world : GameWorld

func _ready() -> void:
	await get_tree().process_frame
	world = Master.game_manager.current_scene
	if Master.is_host:
		play_anim.rpc(animations.pick_random())

func _process(_delta: float) -> void:
	if await_round_start and world:
		if world.current_state != GameWorld.GAME_STATE.BATTLE:
			speed_scale = 0.0
			play_anim("RESET")
		else:
			speed_scale = 1.0

@rpc("any_peer", "call_local", "reliable")
func play_anim(anim_name : StringName):
	play(anim_name)
	await animation_finished
	if Master.is_host:
		await get_tree().create_timer(cooldown).timeout
		play_anim.rpc(animations.pick_random())
