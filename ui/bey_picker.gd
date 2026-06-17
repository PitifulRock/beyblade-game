extends Control

const ATTACK_ICON = preload("uid://bkogjswam2hv3")
const BALANCE_ICON = preload("uid://cbj57nyqrtlm5")
const DEFENSE_ICON = preload("uid://bhv528cguyywf")
const STAMINA_ICON = preload("uid://brj7y2jpu6axb")

@export var parts_path := "res://beyblades/parts/"
var discs_path : String:
	get(): return str(parts_path, "discs")
var cores_path : String:
	get(): return str(parts_path, "cores")
var tips_path : String:
	get(): return str(parts_path, "tips")

var current_disc : int = 0
var current_core : int = 0
var current_tip : int = 0

@onready var bey_assembler: BeyAssembler = %BeyAssembler

func _ready() -> void:
	spawn_visuals(BeyPart.PART_TYPE.TIP)
	spawn_visuals(BeyPart.PART_TYPE.CORE)
	spawn_visuals(BeyPart.PART_TYPE.DISC)

func spawn_visuals(part : BeyPart.PART_TYPE):
	var folder_path := ""; var spawn_path : Node; var cur_index := 0
	match part:
		BeyPart.PART_TYPE.TIP:
			folder_path = tips_path; spawn_path = %TipDisplay; cur_index = current_tip
		BeyPart.PART_TYPE.CORE:
			folder_path = cores_path; spawn_path = %CoreDisplay; cur_index = current_core
		BeyPart.PART_TYPE.DISC:
			folder_path = discs_path; spawn_path = %DiscDisplay; cur_index = current_disc
	
	for i in spawn_path.get_children(): i.free()
	
	var dir := DirAccess.open(folder_path)
	if dir == null: return
	dir.list_dir_begin()
	for file: String in dir.get_files():
		var resource := load(dir.get_current_dir() + "/" + file)
		var inst = resource.instantiate()
		spawn_path.add_child(inst, true)
		if spawn_path.get_child(cur_index) != inst:
			inst.hide()
	_update_visuals()

func _disc_button_pressed(increase : bool):
	current_disc += 1 if increase else -1
	current_disc = wrapi(current_disc, 0, %DiscDisplay.get_children().size())
	_update_visuals()
func _core_button_pressed(increase : bool):
	current_core += 1 if increase else -1
	current_core = wrapi(current_core, 0, %CoreDisplay.get_children().size())
	_update_visuals()
func _tip_button_pressed(increase : bool):
	current_tip += 1 if increase else -1
	current_tip = wrapi(current_tip, 0, %TipDisplay.get_children().size())
	_update_visuals()

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
	
	%DiscName.text = disc.part_name
	%DiscInfo.text = str(
		"Defense: ", disc.burst_resitance, "x\n",
		"Damage:  ",disc.burst_damage, "x\n",
		disc.part_weight*100,"g"
	)
	
	%CoreName.text = core.part_name
	%CoreInfo.text = str(
		"Weight Mult:  ", core.weight_mult, "x\n",
		disc.part_weight*100,"g"
	)
	
	%TipName.text = tip.part_name
	%TipInfo.text = str(
		"Spin Speed:  ", tip.spin_mult, "x\n",
		"Stamina:  ", tip.stamina_mult*10, "x\n",
		disc.part_weight*100,"g"
	)
	
	%BeyAssembler.disc = disc
	%BeyAssembler.core = core
	%BeyAssembler.tip = tip
