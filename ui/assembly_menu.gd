extends Control

const BEY_PICKER = preload("uid://bc0qxhg451sac")

@export var bey_amount := 2
@export var spawn_positions : Array[Marker3D]

func _ready() -> void:
	#for i in %SelectionContainer.get_children(): i.free()
	
	#for i in bey_amount:
		#var picker = BEY_PICKER.instantiate()
		#%SelectionContainer.add_child(picker)
	for i in %SelectionContainer.get_children():
		var index = %SelectionContainer.get_children().find(i)
		i.bey_assembler.global_position = spawn_positions[index].global_position
		%LaunchButton.pressed.connect(i.bey_assembler.launch)
	%LaunchButton.pressed.connect(hide)
