extends Node

var registry : Dictionary[BeyPart.PART_TYPE, Array] = {
	BeyPart.PART_TYPE.DISC : [
		preload("uid://d3qu3u35ga7jv"),
		preload("uid://br18bnql65kv3"),
	],
	
	BeyPart.PART_TYPE.CORE : [
		preload("uid://bypde2dma35k7"),
		preload("uid://cn5vix3nilj0g"),
	],
	
	BeyPart.PART_TYPE.TIP : [
		preload("uid://don4m0xc3m072"),
		preload("uid://e81ijemc301w"),
		preload("uid://b8eaeyuj64x3m"),
	]
}
