extends Node

var current_stadium_order : Array[StringName]

var part_registry : Dictionary[BeyPart.PART_TYPE, Array] = {
	BeyPart.PART_TYPE.DISC : [
		preload("uid://d3qu3u35ga7jv")
		,preload("uid://br18bnql65kv3")
		,preload("uid://cir2mlfxmsgvs")
		,preload("uid://c3oukgafy5ekt")
		,preload("uid://bdtcnn433hps0")
		,preload("uid://c0v0f2qod0l5")
		,preload("uid://cg71nf4fq4wod")
		,preload("uid://b8v033j11us8u")
	],
	
	BeyPart.PART_TYPE.CORE : [
		preload("uid://bypde2dma35k7")
		,preload("uid://cn5vix3nilj0g")
		,preload("uid://csagck7ipt2dk")
		,preload("uid://c36abfwysh4c1")
		,preload("uid://ccxb1tme31sjq")
		,preload("uid://b00yrmi5tfoas")
	],
	
	BeyPart.PART_TYPE.TIP : [
		preload("uid://don4m0xc3m072")
		,preload("uid://e81ijemc301w")
		,preload("uid://b8eaeyuj64x3m")
		,preload("uid://dlnn34fp632ub")
		,preload("uid://557pdyn50028")
		,preload("uid://cxuwkutmag0dv")
		,
	]
}

var stadiums : Dictionary[StringName, PackedScene] = {
	"Standard" : preload("uid://bbgn044maydvg"),
	"Icy" : preload("uid://bxm3h0pqddpkb"),
	"Trampoline" : preload("uid://bpcf2tc7tw6r0"),
	"Half-Pipe" : preload("uid://rolc6m5qgevp"),
	"Elevator" : preload("uid://8br8n6rcj3os"),
	"Invasion" :preload("uid://ctg2a6iawxmt0"),
	"Mountains" :preload("uid://i8iqhyap2e6r"),
	
}

func _ready() -> void:
	current_stadium_order = get_shuffled_stadium_names()

func get_shuffled_stadium_names() -> Array[StringName]:
	var keys = stadiums.keys()
	keys.shuffle()
	return keys

func get_next_stadium_name(index : int) -> StringName:
	var list_index := wrapi(index, 0, stadiums.size())
	if list_index >= current_stadium_order.size():
		current_stadium_order = get_shuffled_stadium_names()
	return current_stadium_order[list_index]
