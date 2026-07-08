extends Node

var current_stadium_order : Array[StringName]

var part_registry : Dictionary[BeyPart.PART_TYPE, Array] = {
	BeyPart.PART_TYPE.DISC : [
		preload("uid://d3qu3u35ga7jv") ## Star
		,preload("uid://br18bnql65kv3") ## Rounded
		,preload("uid://cir2mlfxmsgvs") ## Flow
		,preload("uid://c3oukgafy5ekt") ## Strike
		,preload("uid://bdtcnn433hps0") ## Cyclone
		,preload("uid://c0v0f2qod0l5") ## Halo
		,preload("uid://cg71nf4fq4wod") ## Sword
		,preload("uid://b8v033j11us8u") ## Orbit
		,preload("uid://yna1x1lfrnc2") ## Axe
	],
	
	BeyPart.PART_TYPE.CORE : [
		preload("uid://bypde2dma35k7") ## Tri Spike
		,preload("uid://cn5vix3nilj0g") ## Disc
		,preload("uid://csagck7ipt2dk") ## Clover
		,preload("uid://c36abfwysh4c1") ## Gear
		,preload("uid://ccxb1tme31sjq") ## Tungsten
		,preload("uid://b00yrmi5tfoas") ## Cage
		,preload("uid://dfh2uy4ahdou2") ## Pierce
		,preload("uid://cav4c6hgxs133") ## Waist
	],
	
	BeyPart.PART_TYPE.TIP : [
		preload("uid://don4m0xc3m072") ## Rush
		,preload("uid://e81ijemc301w") ## Dome
		,preload("uid://b8eaeyuj64x3m") ## Drill
		,preload("uid://dlnn34fp632ub") ## Pounce
		,preload("uid://557pdyn50028") ## One SHot
		,preload("uid://cxuwkutmag0dv") ## Barrage
		,preload("uid://bb2y1jtraro5k") ## Spider
		,preload("uid://t44p4hh1hxtg") ## Pirouette
		,preload("uid://cl0124djugvo2") ## Structure
		,preload("uid://dqlanvfm0v87e") ## Nothing
		,preload("uid://bonneqqdh2xxo") ## Crystal
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
	"Spikes" :preload("uid://bg0hce42w5sid"),
	"UFO" :preload("uid://crshblwnm08nc"),
	"Fractured" :preload("uid://cumag18d15u2b"),
	"Farm" :preload("uid://cf68t08axsdph"),
	"Pendulum" :preload("uid://38mi1a37c1gl"),
}

var disasters : Array[PackedScene] = [
	preload("uid://j85u7ce8mk35")
	,preload("uid://6titwrw7r26j")
	,preload("uid://bkko7pq28y3oo")
]

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
