extends Node

var registry : Dictionary[BeyPart.PART_TYPE, Array] = {
	BeyPart.PART_TYPE.DISC : [
		preload("uid://d3qu3u35ga7jv")
		,preload("uid://br18bnql65kv3")
		,preload("uid://cir2mlfxmsgvs")
		,preload("uid://c3oukgafy5ekt")
		,preload("uid://bdtcnn433hps0")
	],
	
	BeyPart.PART_TYPE.CORE : [
		preload("uid://bypde2dma35k7")
		,preload("uid://cn5vix3nilj0g")
		,preload("uid://csagck7ipt2dk")
		,preload("uid://c36abfwysh4c1")
		,preload("uid://ccxb1tme31sjq")
	],
	
	BeyPart.PART_TYPE.TIP : [
		preload("uid://don4m0xc3m072")
		,preload("uid://e81ijemc301w")
		,preload("uid://b8eaeyuj64x3m")
		,preload("uid://dlnn34fp632ub")
		,preload("uid://557pdyn50028")
	]
}

var stadiums : Dictionary[String, PackedScene] = {
	"Standard" : preload("uid://bbgn044maydvg"),
	"Icy" : preload("uid://bxm3h0pqddpkb"),
	"Trampoline" : preload("uid://bpcf2tc7tw6r0"),
	"Half-Pipe" : preload("uid://rolc6m5qgevp"),
	"Elevator" : preload("uid://8br8n6rcj3os"),
	"Invasion" :preload("uid://ctg2a6iawxmt0"),
	
}
