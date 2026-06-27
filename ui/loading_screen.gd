extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !OS.has_feature("editor"):
		await load_parts()
		await load_stadiums()
		await load_disasters()
	else:
		await get_tree().process_frame
	Master.game_manager.switch_scene(preload("uid://b42uq41g0gs64"))

func load_parts():
	for type in Registry.part_registry:
		for part in Registry.part_registry[type]:
			var inst = part.instantiate()
			%BeyLoad.add_child(inst)
			await get_tree().create_timer(0.1).timeout
			inst.queue_free()

func load_stadiums():
	for stadium in Registry.stadiums.values():
		var inst = stadium.instantiate()
		%Render.add_child(inst)
		await get_tree().create_timer(0.2).timeout
		inst.queue_free()

func load_disasters():
	for disaster in Registry.disasters:
		var inst = disaster.instantiate()
		%DisasterLoad.add_child(inst)
		await get_tree().create_timer(0.4).timeout
		inst.queue_free()
