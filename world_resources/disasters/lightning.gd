extends Node3D

var shocking := false
var current_bey : BeyBlade
var stored_velocity : Vector3

func _ready() -> void:
	await get_tree().create_timer(1.4).timeout
	shock_random()

func shock_random():
	if !Master.is_host: return
	var beyblades : Array = Master.game_manager.current_scene.beyblade_path.get_children()
	if beyblades.is_empty(): 
		cooldown()
		return
	var bey : BeyBlade = beyblades.pick_random()
	shock.rpc(bey.name)

@rpc("any_peer", "call_local", "reliable")
func shock(id : String):
	var bey : BeyBlade = Master.game_manager.current_scene.beyblade_path.get_node_or_null(id)
	if bey == null: return
	stored_velocity = bey.linear_velocity
	
	current_bey = bey
	shocking = true
	
	%ShockParticles.global_position = bey.global_position
	%ShockParticles.emitting = true
	%ShockSound.global_position = bey.global_position
	%ShockSound.play()
	
	await get_tree().create_timer(0.9).timeout
	shocking = false
	bey.linear_velocity = stored_velocity * (-1.1 if randf() < 0.5 else 1.1)
	cooldown()

func cooldown():
	await get_tree().create_timer(2.8).timeout
	shock_random()

func _physics_process(_delta: float) -> void:
	if current_bey and shocking:
		current_bey.linear_velocity = Vector3.ZERO
