extends Control

const ATTACK_ICON = preload("uid://bkogjswam2hv3")
const BALANCE_ICON = preload("uid://cbj57nyqrtlm5")
const DEFENSE_ICON = preload("uid://bhv528cguyywf")
const STAMINA_ICON = preload("uid://brj7y2jpu6axb")

@export var current_disc : int = 0:
	set(value):
		current_disc = wrapi(value, 0, %DiscDisplay.get_children().size())
		_update_visuals()
@export var current_core : int = 0:
	set(value):
		current_core = wrapi(value, 0, %CoreDisplay.get_children().size())
		_update_visuals()
@export var current_tip : int = 0:
	set(value):
		current_tip = wrapi(value, 0, %TipDisplay.get_children().size())
		_update_visuals()

@onready var bey_assembler: BeyAssembler = %BeyAssembler

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	spawn_visuals(BeyPart.PART_TYPE.TIP)
	spawn_visuals(BeyPart.PART_TYPE.CORE)
	spawn_visuals(BeyPart.PART_TYPE.DISC)
	
	%NameLabel.text = Steam.getPersonaName()
	if !is_multiplayer_authority():
		for i in [$Picker/DiscRight, $Picker/DiscLeft, $Picker/CoreRight, $Picker/CoreLeft, $Picker/TipRight, $Picker/TipLeft]:
			i.hide()

func spawn_visuals(part : BeyPart.PART_TYPE):
	var spawn_path : Node; var cur_index := 0
	match part:
		BeyPart.PART_TYPE.TIP:
			spawn_path = %TipDisplay; cur_index = current_tip
		BeyPart.PART_TYPE.CORE:
			spawn_path = %CoreDisplay; cur_index = current_core
		BeyPart.PART_TYPE.DISC:
			spawn_path = %DiscDisplay; cur_index = current_disc
	
	for i in spawn_path.get_children(): i.free()
	
	for file:PackedScene in Registry.part_registry[part]:
		var inst = file.instantiate()
		spawn_path.add_child(inst, true)
		if spawn_path.get_child(cur_index) != inst:
			inst.hide()
	_update_visuals()

func _disc_button_pressed(increase : bool):
	if !is_multiplayer_authority(): return
	current_disc += 1 if increase else -1
	Effects.play_ui(&"ButtonPress")
func _core_button_pressed(increase : bool):
	if !is_multiplayer_authority(): return
	current_core += 1 if increase else -1
	Effects.play_ui(&"ButtonPress")
func _tip_button_pressed(increase : bool):
	if !is_multiplayer_authority(): return
	current_tip += 1 if increase else -1
	Effects.play_ui(&"ButtonPress")

func _update_visuals():
	var disc : BeyDisc = %DiscDisplay.get_child(current_disc)
	var core : BeyCore = %CoreDisplay.get_child(current_core)
	var tip : BeyTip = %TipDisplay.get_child(current_tip)
	
	for i in %DiscDisplay.get_children(): i.hide()
	for i in %CoreDisplay.get_children(): i.hide()
	for i in %TipDisplay.get_children(): i.hide()
	disc.show()
	core.show()
	tip.show()
	
	for i in [disc, core, tip]:
		i.show()
		var type_icon : TextureRect
		match i:
			disc: type_icon = %DiscType
			core: type_icon = %CoreType
			tip: type_icon = %TipType
		match i.type:
			BeyBlade.TYPE.ATTACK: type_icon.texture = ATTACK_ICON
			BeyBlade.TYPE.DEFENSE: type_icon.texture = DEFENSE_ICON
			BeyBlade.TYPE.STAMINA: type_icon.texture = STAMINA_ICON
			BeyBlade.TYPE.BALANCE: type_icon.texture = BALANCE_ICON
	
	%DiscName.text = str(disc.part_name, "  (", disc.part_weight*100,"g)")
	%DiscInfo.text = str(
		"Defense: ", disc.burst_resitance, "x\n",
		"Damage:  ",disc.burst_damage, "x\n",
	)
	
	%CoreName.text = str(core.part_name, "  (", core.part_weight*100,"g)")
	%CoreInfo.text = str(
		"Weight Mult:  ", core.weight_mult, "x\n",
	)
	
	%TipName.text = str(tip.part_name, "  (", tip.part_weight*100,"g)")
	%TipInfo.text = str(
		"Spin Speed:  ", tip.spin_mult, "x\n",
		"Stamina:  ", tip.stamina_mult*10, "\n",
	)
	
	%BeyAssembler.disc = disc
	%BeyAssembler.core = core
	%BeyAssembler.tip = tip
