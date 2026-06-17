extends Node3D
class_name BeyPart

enum PART_TYPE{TIP, CORE, DISC}

@export var part_name : String
@export var type : BeyBlade.TYPE = BeyBlade.TYPE.ATTACK
@export var part_weight := 0.025

var placement_point : Marker3D

func _ready() -> void:
	if !(self is BeyDisc):
		placement_point = $Placement
