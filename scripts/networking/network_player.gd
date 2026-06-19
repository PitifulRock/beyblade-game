extends FreeLookCamera
class_name Player

var steam_id : int
var display_name : String:
	set(val):
		display_name = val
var beyblade_node : BeyBlade = null

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if !is_multiplayer_authority(): return
	display_name = Steam.getPersonaName()
	current = true
	Master.local_player = self
	$Label3D.text = display_name
